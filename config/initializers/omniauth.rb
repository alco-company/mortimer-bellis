Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  # provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider(:entra_id, { client_id: ENV["MS_AD_ID"], client_secret: ENV["MS_AD_SECRET"], callback_path: "/users/auth/entra_id/callback" })
end
