class ServersController < ActionController::Base

  before_action :set_servers, only: [:index]
  before_action :set_searches, only: [:index]

  # GET /servers
  def index

  end

  # GET /servers/1
  def show
  end

  # GET/PUT /servers/hartbeat
  def hartbeat
    $redis.setex("server_#{server_params[:uuid]}", 10, server_params.to_json)
    render :json=>{succeed:true}
  end

  private
    # Only allow a trusted parameter "white list" through.
    def server_params
      params.permit(:uuid, :addr, :port, :status)
    end

    def set_servers
      @servers = $redis.keys('server_*').map { |k| JSON.parse($redis.get(k)) }
    end

    def set_searches
      @searches = $redis.keys('search_*').map { |k| JSON.parse($redis.get(k)) }
    end

end
