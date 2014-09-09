class CreditsController < ApplicationController
  def index
  	@user_transactions = Transaction.where(user_id: current_user).order("id DESC")
  end

  def new
  	@transaction = Transaction.new
  end

  def purchase
    if Transaction.get_balance(current_user) == 0
      flash[:error] = "Before creating an activity, you'll need to buy more credits."
    else
      @user_transactions = Transaction.where(user_id: current_user).order("id DESC")
    end
  end

  def create

  	number_of_credits = params[:number_of_credits].to_i

  	# Cost Calculation
    case number_of_credits
      when 1..4
        cost = 129
      when 5
        cost = 125.8
      when 6..9
        cost = 124
      when 10
        cost = 119.9
      when 11..19
        cost = 119
      when 20
        cost = 109.95
      when 21..49
        cost = 109
      when 50 
        cost = 99.98
      when 51..99
        cost = 99
      else
        cost = 98.99
    end

  	# Amount in cents
	  amount = cost * number_of_credits
    amount = amount.to_i

	  customer = Stripe::Customer.create(
	    :email => current_user.email,
	    :card  => params[:stripeToken]
	  )

	  charge = Stripe::Charge.create(
	    :customer    => customer.id,
	    :amount      => amount,
	    :description => "#{number_of_credits} credits were purchased @ #{cost} cents / ea",
	    :currency    => 'usd'
	  )

    logger.info "#{amount / 100.to_f}"
    Transaction.create!(transaction_type_id: 1, user_id: current_user.id, amount: number_of_credits, cost: amount / 100.to_f, balance: (Transaction.get_balance(current_user) + number_of_credits))

    flash[:notice] = "Thank you for your purchase"
    redirect_to credits_purchase_path

	rescue Stripe::CardError => e
	  flash[:error] = e.message
	  redirect_to credits_purchase_path
	end

end
