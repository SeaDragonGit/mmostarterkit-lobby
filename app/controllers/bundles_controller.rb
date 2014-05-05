class BundlesController < ApplicationController

  load_and_authorize_resource
  skip_load_resource only: [:create]
  before_action :set_bundle, only: [:show, :edit, :update, :destroy]

  # GET /bundles
  def index
    @bundles = Bundle.all
  end

  # GET /bundles/1
  def show
  end

  # GET /bundles/new
  def new
    @bundle = Bundle.new()
  end

  # GET /bundles/1/edit
  def edit
  end

  # POST /bundles
  def create
    if invalid_file?
      @bundle = Bundle.new(update_bundle_params)
      @bundle.errors[:file] = I18n.t('bundle.error.file')
      render :new
    else

      @bundle = Bundle.new(create_bundle_params)

      if @bundle.save
        begin
          @bundle.create_bundle_body!(body:params[:bundle][:file].read)
          redirect_to @bundle, notice: 'Bundle was successfully created.'
        rescue
          @bundle.destroy
          @bundle = Bundle.new(update_bundle_params)
          @bundle.errors[:file] = I18n.t('bundle.error.file')
          render :new
        end
      else
        render :new
      end
    end
  end

  # PATCH/PUT /bundles/1
  def update
    if @bundle.update(bundle_params)
      redirect_to @bundle, notice: 'Bundle was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /bundles/1
  def destroy
    @bundle.destroy
    redirect_to bundles_url, notice: 'Bundle was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bundle
      @bundle = Bundle.find(params[:id])
    end

    def invalid_file?
      #TODO put more detail check here
      if params[:bundle][:file]
        params[:bundle][:file].size > 256*1024*1024
      else
        true
      end
    end

    # Only allow a trusted parameter "white list" through.
    def create_bundle_params
      if params[:bundle][:file]
        params[:bundle][:original_filename] = params[:bundle][:file].original_filename
        params[:bundle][:mime_type] = params[:bundle][:file].content_type
        params[:bundle][:size] = params[:bundle][:file].size
      end

      params.require(:bundle).permit(:name, :description, :data, :memory, :original_filename, :mime_type, :size).merge(user_id: current_user.id)
    end

    # Only allow a trusted parameter "white list" through.
    def bundle_params
      params.require(:bundle).permit(:name, :description, :deploy, :memory, :num, :vcpu).merge(user_id: current_user.id)
    end

    # Only allow a trusted parameter "white list" through.
    def update_bundle_params
      params.require(:bundle).permit(:name, :description, :memory, :num, :vcpu)
    end

end
