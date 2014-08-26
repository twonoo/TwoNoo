class CreditsController < ApplicationController
  def index
  	@user_transactions = Transaction.where(user_id: current_user).order("id DESC")
  end

  def new
  end

  def create
  	# Amount in cents
	  @amount = 1000

	  customer = Stripe::Customer.create(
	    :email => current_user.email,
	    :card  => params[:stripeToken]
	  )

	  charge = Stripe::Charge.create(
	    :customer    => customer.id,
	    :amount      => @amount,
	    :description => 'Pretty bauss like',
	    :currency    => 'usd'
	  )

	rescue Stripe::CardError => e
	  flash[:error] = e.message
	  redirect_to charges_path
	  end
end
