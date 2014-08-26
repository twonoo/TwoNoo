Rails.configuration.stripe = {
  :publishable_key => 'pk_test_yX8BKkdT9SQMwcx6yOMsIucu',
  :secret_key      => 'sk_test_xJ3lZu74hvNK3hqtILDwgD3l'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]