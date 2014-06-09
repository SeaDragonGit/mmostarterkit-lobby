rails_root = File.expand_path(File.dirname(File.dirname(__FILE__)))
rails_env = 'development'
rake = '/usr/local/bin/rake'

God.watch do |w|
  w.dir = "#{rails_root}"
  w.uid = 'star'
  w.gid = 'star'
  w.name = 'matchmaker'
  w.interval = 10.seconds
  w.env = {"RAILS_ROOT" => rails_root, "RAILS_ENV" => rails_env}
  w.start = "#{rake} matchmaker"
  w.log = "#{rails_root}/log/#{w.name}.log"
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running = false
    end
  end
end

God.watch do |w|
  w.dir = "#{rails_root}"
  w.uid = 'star'
  w.gid = 'star'
  w.name = 'sidekiq'
  w.interval = 10.seconds
  w.env = {"RAILS_ROOT" => rails_root, "RAILS_ENV" => rails_env}
  w.start = 'sidekiq'
  w.log = "#{rails_root}/log/#{w.name}.log"
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running = false
    end
  end
end