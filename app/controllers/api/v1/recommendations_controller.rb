class Api::V1::RecommendationsController < Api::V1::BaseController

  def index
  end

  def new
  end

  def create
  	# initiate Neography
  	@neo = Neography::Rest.new

  	# getting similarity
  	queryMatch = @neo.execute_query("")

  end

  def edit
  end

  def update
  end

  def destroy
  end

end

