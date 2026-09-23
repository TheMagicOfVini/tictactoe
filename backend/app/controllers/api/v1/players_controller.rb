# frozen_string_literal: true

class Api::V1::PlayersController < ApplicationController
  RESULT_COLUMNS = { 'win' => :wins, 'loss' => :losses, 'draw' => :draws }.freeze

  before_action :set_player, only: %i[show update destroy]
  # GET /players
  def index
    @players = Player.all

    render json: @players
  end

  # GET /players/1
  def show
    render json: @player
  end

  # POST /players
  def create
    @player = Player.new(player_params)


    if @player.save
      render json: @player, status: :created, location: api_v1_player_url(@player)
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /players/1
  def update
    if @player.update(player_params)
      render json: @player
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # POST /players/results
  # Body: { "name": "...", "result": "win" | "loss" | "draw" }
  # Creates the player if the name is new, then adds 1 to the matching counter.
  def results
    column = RESULT_COLUMNS[params[:result]]
    errors = {}
    errors[:result] = ['must be win, loss or draw'] unless column
    name = params[:name]
    errors[:name] = ["can't be blank"] unless name.is_a?(String) && name.present?
    return render json: errors, status: :unprocessable_entity if errors.any?

    player = find_or_create_player(name)
    # One atomic SQL update: SET wins = COALESCE(wins, 0) + 1
    Player.update_counters(player.id, column => 1, touch: true)
    render json: player.reload, status: :ok
  end

  # DELETE /players/1
  def destroy
    @player.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end

  # Another request can create the same name between the find and the insert.
  # Then the unique index or the uniqueness validation fails, and we find that row.
  def find_or_create_player(name)
    Player.find_or_create_by!(name: name)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    Player.find_by!(name: name)
  end


  # Only allow a trusted parameter "white list" through.
  def player_params
    params.require(:player).permit(:name, :wins, :losses, :draws)
  end
end
