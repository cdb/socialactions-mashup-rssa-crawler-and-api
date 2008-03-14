class ActionsController < ApplicationController
  
  def index
    @actions = Action.paginate(:all, :page => params[:page], :order => 'created_at DESC')
    respond_to do |format|
      format.html
      format.xml
    end
    
  end
  
  def show
    @action = Action.find(params[:id])
    respond_to do |format|
      format.html
      format.xml
    end    
  end
end
