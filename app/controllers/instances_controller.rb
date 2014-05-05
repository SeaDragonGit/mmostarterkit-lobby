class InstancesController < ApplicationController
  load_and_authorize_resource
  before_action :set_instance, only: [:show]

  # GET /instances
  def index
    @instances = current_user.instances
  end

  # GET /instances/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instance
      @instance = Instance.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def instance_params
      params.require(:instance).permit(:bundle_id, :node_id, :pending, :terminate, :active, :port, :address, :node_session, :activated_at, :terminated_at)
    end
end
