class DonationsController < ApplicationController
  
  # ssl_required              :new, :create
  # filter_parameter_logging  :cardNumber
  
  before_filter             :load_action
  

  def new
    @donation = Donation.new
    @donor = Donor.new
    @credit_card = CreditCard.new
  end
  
  def create
    # @donation = Donation.new(params[:donation])
    # @donation.designation                   = current_project.name
    # @donation.partnerTransactionIdentifier  = "#{current_project.id}_#{current_user.id || ''}_#{Time.now.to_i}"
    # @donation.designation                   = current_project.name
    # @donation.npoEin                        = current_project.ein
    # @donation.donorIpAddress                = request.remote_ip
    # if @donation.valid? && @donation.process
    #   @measurement = Measurement.create!(
    #     :user_id    => current_user.id, 
    #     :project_id => current_project.id,
    #     :metric_id  => Metric.donation_metric.id,
    #     :quantity   => @donation.amount
    #   )
    #   flash[:notice] = "The transaction was completed successfully. Thank you for your donation."
    #   redirect_to project_path(current_project)
    # else
    #   flash[:error] = "There was an error while processing your donation: #{@donation.error_message}" if !@donation.error_message.empty?
    #   render :action => 'new'
    # end
  end

protected 

  def load_action
    @action = Action.find(params[:social_action])
  rescue ActiveRecord::RecordNotFound
    redirect_to :back
  end

end
