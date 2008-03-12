class ActionsController < ApplicationController
  make_resourceful do
    actions :index, :show
    response_for :index do |format|
      format.html
      format.xml
    end
    response_for :show do |format|
      format.html
      format.xml
    end
  end
  

  
end
