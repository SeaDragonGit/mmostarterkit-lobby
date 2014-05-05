desc 'Test instance god script'
task :test_instance_erb => :environment do

  # utils
  require 'utils/instance_god_config_writer'

  InstanceGodConfigWriter.new(name: 'xxx', uid:"sdsd").write Rails.root.join('tmp','instance.shell.rb')

end