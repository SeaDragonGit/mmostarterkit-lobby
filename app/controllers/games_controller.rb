class GamesController < ApplicationController
  load_and_authorize_resource
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  layout 'game', only: [:index]

  # GET /games
  def index
    @games = Game.all
  end

  # GET /games/1
  def show
  end

  # GET /games/new
  def new

  end


  def matchmaking_status
    search_json = $redis.get("search_#{current_user.id}")
    if search_json.nil?
      render json:{active:false,searching:false,status:''}
    else
      $redis.expire("search_#{current_user.id}",120)
      search = JSON.parse(search_json)
      if search['session'].nil?
        render json:{active:true,searching:true,status:'searching...'}
      else
        render json:{active:true,searching:false,session:search['session'],status:'game '}
      end
    end
  end

  def start_matchmaking
    $redis.setex("search_#{current_user.id}", 120, {user_id:current_user.id, session:nil}.to_json)
    render nothing: true
  end

  def stop_matchmaking
    $redis.del("search_#{current_user.id}")
    render nothing: true
  end


  # GET /games/1/edit
  def edit
  end

  # POST /games
  def create
    @game = Game.new(game_params)

    if @game.save
      redirect_to @game, notice: 'Game was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /games/1
  def update
    if @game.update(game_params)
      redirect_to @game, notice: 'Game was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy
    redirect_to games_url, notice: 'Game was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def game_params
      params.require(:game).permit(:uuid, :server_uuid, :server_addr, :server_port, :started_at, :over_at)
    end
end
