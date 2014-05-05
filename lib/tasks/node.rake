desc 'Node manager script'
task :node => :environment do

  # utils
  require 'open-uri'
  require 'fileutils'
  require 'erb'
  require 'zip'
  require 'utils/usagewatch'
  require 'utils/shell'
  require 'utils/instance_god_config_writer'
  require 'socket'

  INSTANCE_VCPU = Rails.application.config.instance.vcpu.count
  MINFREEMEMORY = 200*1024

  # for development take local ip
  if Rails.application.config.instance.publicip
    PUBLICIP = open('http://whatismyip.akamai.com').read
  else
    Socket.ip_address_list.each do |addr_info|
      if addr_info.ipv4? and not addr_info.ipv4_loopback?
        PUBLICIP = addr_info.ip_address
      end
    end
  end

  # write pid if asked
  File.open(ENV['PIDFILE'], 'w') { |f| f << Process.pid } if ENV['PIDFILE']

  # get uuids dir
  uuids_dir = Rails.root.join('tmp','uuids')
  FileUtils.mkpath uuids_dir

  # uuid file path
  uuid_path = uuids_dir.join('node.uuid')

  # determine node uuid
  uuid  = SecureRandom.uuid

  # read or write node uuid
  if uuid_path.exist?
    File.open(uuid_path,'r') {|f| uuid = f.readline}
  else
    File.open(uuid_path,'w') {|f| f.write(uuid)}
  end

  # session uuid
  session  = SecureRandom.uuid

  # stop instance's group
  Shell::God.stop 'instances'

  # instances dir
  instances_dir = Rails.root.join('tmp','instances')
  FileUtils.rm_rf instances_dir
  FileUtils.mkpath instances_dir

  node = Node.find_or_create_by(uuid: uuid)
  node.address = PUBLICIP
  node.session = session
  node.active = true
  node.activated_at = DateTime.now.utc
  node.cpu_usage = Usagewatch.uw_cpuused
  node.memory_usage = Usagewatch.uw_memused
  node.free_memory = Usagewatch.uw_freemem
  node.free_vcpu = INSTANCE_VCPU
  node.save

  ActiveRecord::Base.uncached do

    loop do

      node = Node.find_or_create_by(uuid: uuid)
      node.cpu_usage = Usagewatch.uw_cpuused
      node.memory_usage = Usagewatch.uw_memused
      node.free_memory = Usagewatch.uw_freemem

      vcpu = INSTANCE_VCPU

      # validate active instances
      node.active_instances.each {|i|
        if i.node_session == session
          i.status = 'active'
          vcpu -= i.bundle.vcpu
        else
          i.status = 'terminated'
          i.active = false
        end
        i.terminated_at = DateTime.now.utc
        i.save
      }

      node.free_vcpu = vcpu
      node.active = (node.free_memory > MINFREEMEMORY && vcpu > 0) ? true : false
      node.save

      # terminate instances
      node.terminate_instances.where(node_session:session).each {|i|
        Shell::God.stop "instance_#{i.id}"
        Shell::God.remove "instance_#{i.id}"
        i.status = 'terminated'
        i.active = false
        i.terminate = false
        i.terminated_at = DateTime.now.utc
        i.save
        instance_dir = instances_dir.join("instance_#{i.id}")
        FileUtils.rm_rf instance_dir
      }

      # deploy a pending instances
      node.pending_instances.each do |i|

        instance_dir = instances_dir.join("instance_#{i.id}")

        bundle_dir = instance_dir.join('bundle')

        FileUtils.mkdir_p(bundle_dir)

        begin

          zip = instance_dir.join('bundle.zip')

          File.open(zip, 'wb') {|f| f.write i.bundle.bundle_body.body}

          Shell::Zip.unzip(zip, bundle_dir)

          exe = nil
          Dir.glob(bundle_dir.join('**','*.x86_64')).select { |fn|
            raise Shell::Zip::Error.new('Only one executable is allowed.') unless exe.nil?
            exe = fn
          }

          raise Shell::Zip::Error.new('No executable in bundle. (*.x86_64)') if exe.nil?

          start = "#{exe}"
          dir = File.dirname(exe)
          god_cfg = instance_dir.join('instance.god.rb')
          uid = "user_#{i.bundle.user.id}"
          gid = uid
          instance_log_dir = instance_dir.join('log')
          FileUtils.mkdir_p(instance_log_dir)
          log = instance_log_dir.join('instance.log')

          # add system user
          Shell.useradd(uid)

          # generate config file
          InstanceGodConfigWriter.new(name: "instance_#{i.id}",
                                      start: start,
                                      uid: uid,
                                      gid: gid,
                                      log: log,
                                      addr: PUBLICIP,
                                      memory: i.bundle.memory,
                                      cpu: i.bundle.vcpu * Rails.application.config.instance.vcpu.percentage,
                                      dir: dir ).write(god_cfg)


          # change folder owner to the bundle user
          Shell.chown(uid, gid, bundle_dir)
          Shell.chown(uid, gid, instance_log_dir)

          # change mod of the executable
          Shell.chmod('+x',exe)

          # tell to god load config
          Shell::God.load(god_cfg)

          i.node_session = session
          i.active = true
          i.address = PUBLICIP
          i.pending = false
          i.status = 'active'
          i.activated_at = DateTime.now.utc
          i.terminated_at = i.activated_at
          i.save

          node.free_vcpu -= i.bundle.vcpu
          node.active = false
          node.save

          # give some time to let god load the instance
          #sleep(5.second)

        rescue Shell::Zip::Error => e

          instance_dir = instances_dir.join("instance_#{i.id}")
          FileUtils.rm_rf instance_dir

          # mark bundle as broken
          i.bundle.fail = true
          i.bundle.fail_reason = e.message
          i.bundle.save

          # save exception message and remove pending flag
          i.node_session = session
          i.status = 'fail'
          i.pending = false
          i.save

        end

      end

      # release memory
      GC.start

      # sleep
      sleep(5.second)

    end

  end

end