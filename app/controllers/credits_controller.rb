class CreditsController < ApplicationController
  def index
  	@user_transactions = Transaction.where(user_id: current_user).order("id DESC")
  end

  def new
  	@transaction = Transaction.new
  end

  def purchase
  end

  def create

  	@number_of_credits = params[:number_of_credits].to_i

  	# Cost Calculation
  	if @number_of_credits <= 5
  		@cost = 125
  	elsif @number_of_credits > 5 && @number_of_credits <= 10
  		@cost = 100
  	elsif @number_of_credits > 10 && @number_of_credits <= 20
  		@cost = 75
  	else
  		@cost = 50
  	end

  	# Amount in cents
	  @amount = @cost * @number_of_credits

	  customer = Stripe::Customer.create(
	    :email => current_user.email,
	    :card  => params[:stripeToken]
	  )

	  charge = Stripe::Charge.create(
	    :customer    => customer.id,
	    :amount      => @amount,
	    :description => "#{@number_of_credits} credits were purchased @ #{@cost} cents / ea",
	    :currency    => 'usd'
	  )


    redirect_to credits_purchase_path, flash[:success] = "Woohoo! You got dem credits son! #{@number_of_credits} to be exact!"

	rescue Stripe::CardError => e
	  flash[:error] = e.message
	  redirect_to credits_path
	end
end
