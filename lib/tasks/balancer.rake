desc 'instance balancer/manager script'
task :balancer => :environment do
  # utils
  require 'open-uri'
  require 'fileutils'

  PUBLICIP = open('http://whatismyip.akamai.com').read

  # write pid if asked
  File.open(ENV['PIDFILE'], 'w') { |f| f << Process.pid } if ENV['PIDFILE']

  # get uuids dir
  uuids_dir = Rails.root.join('tmp','uuids')
  FileUtils.mkpath uuids_dir

  # uuid file path
  uuid_path = uuids_dir.join('balancer.uuid')

  # determine node uuid
  uuid  = SecureRandom.uuid

  # read or write node uuid
  if uuid_path.exist?
    File.open(uuid_path,'r') {|f| uuid = f.readline}
  else
    File.open(uuid_path,'w') {|f| f.write(uuid)}
  end


  loop {
    sleep(1.second)

    # clean active flag for instances & nodes which doesn't update last 5 minutes
    Node.active.where(['updated_at<?', 5.minutes.ago.utc]).update_all(active:false)
    Instance.where(['updated_at<?', 5.minutes.ago.utc]).update_all(active:false,pending:false)

    # make order for nodes
    Bundle.where(fail: false).where(deploy: true).each { |b|
      active_num = b.active_instances.count
      pending_num = b.num - active_num
      if pending_num > 0
        ActiveRecord::Base.connection.execute("SELECT * FROM ( SELECT nodes.id AS id, nodes.free_memory, COUNT(instances.id) AS inscnt FROM nodes LEFT OUTER JOIN instances ON instances.node_id = nodes.id AND instances.pending=true WHERE nodes.active = true GROUP BY nodes.id ) AS n WHERE n.inscnt=0 ORDER BY n.free_memory DESC LIMIT 1").each {|r|
          node = Node.find(r['id'])
          node.pending_instances.create(bundle_id:b.id,status:'pending')
        }
      elsif pending_num < 0
        b.active_instances.limit(-pending_num).update_all(terminate:true)
      end
    }

    # terminate instances which bundles don't want to deploy anymore
    Instance.eager_load(:bundle).where(active:true,terminate:false).where('bundles.deploy'=> false).each { |i|
      i.terminate = true
      i.save
    }

  }

end