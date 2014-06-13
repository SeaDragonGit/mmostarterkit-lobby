desc 'player matchmaker script'
task :matchmaker => :environment do
  # utils
  require 'open-uri'
  require 'fileutils'


  # write pid if asked
  File.open(ENV['PIDFILE'], 'w') { |f| f << Process.pid } if ENV['PIDFILE']

  # get uuids dir
  uuids_dir = Rails.root.join('tmp','uuids')
  FileUtils.mkpath uuids_dir

  # uuid file path
  uuid_path = uuids_dir.join('matchmaker.uuid')

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



  }

end