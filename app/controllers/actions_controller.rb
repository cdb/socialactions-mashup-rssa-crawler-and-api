class ActionsController < ApplicationController
  
  def index
    @search = Search.new(params[:search])
    @actions = @search.results(params[:page])
    respond_to do |format|
      format.html
      format.xml
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

