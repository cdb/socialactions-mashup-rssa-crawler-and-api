class ActionsController < ApplicationController
  
  def index
    @search = Search.new(search_params)
    @actions = @search.results(params[:page])
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def random
    @search = Search.new(search_params.merge(:kind => 'random'))
    @actions = @search.results(params[:page])
    if @actions.empty?
      redirect_to(:back)
    else
      redirect_to(@actions.first.url)
    end
  end
  
  def show
    @action = Action.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false}
      format.xml
    end    
  end

end

