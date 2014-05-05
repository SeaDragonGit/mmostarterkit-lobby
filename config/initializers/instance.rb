module Rails::Application::Config
  class Instance < Settingslogic
    source "#{Rails.root}/config/instance.yml"
    namespace Rails.env
    load!
  end
end

Rails.application.config.instance = Rails::Application::Config::Instance
