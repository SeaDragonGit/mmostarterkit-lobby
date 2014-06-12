class ServersController < ActionController::Base

  # GET /servers
  def index
    @servers = Server.all
  end

  # GET /servers/1
  def show
  end

  # GET/PUT /servers/hartbeat
  def hartbeat

    render :json=>{:succeed=>true}
  end

  private
    # Only allow a trusted parameter "white list" through.
    def server_params
      params.require(:server).permit(:uuid, :addr, :port, :status)
    end
end
