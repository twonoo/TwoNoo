Rails.configuration.stripe = {
  :publishable_key => 'pk_live_rTZqMKTHoYfCfBO5Ai0FkOzu',
  :secret_key      => 'sk_live_NGWElgonyPgTahbTbwD06rFR'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
