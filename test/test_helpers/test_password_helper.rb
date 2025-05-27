require "bcrypt"

module TestPasswordHelper
  def default_password_digest
    BCrypt::Password.create(default_password, cost: 4)
  end

  def default_password
    "password"
  end

  def login_as(user)
    # Craft session cookie to make request authenticated (to pass even routing constraints)
    # Compilation of these:
    #  - https://dev.to/nejremeslnici/migrating-selenium-system-tests-to-cuprite-42ah#faster-signin-in-tests
    #  - https://turriate.com/articles/2011/feb/how-to-generate-signed-rails-session-cookie
    #  - https://github.com/rails/rails/blob/43e29f0f5d54294ed61c31ddecdf76c2e1a474f7/actionpack/test/dispatch/cookies_test.rb#L350
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookie_jar = ActionDispatch::Cookies::CookieJar.new(request)
    session_key = Rails.configuration.session_options[:key]
    session_hash = { "session_id" => SecureRandom.hex(16) }
    # warden_serializer = Warden::SessionSerializer.new(request.env)
    # session_hash[warden_serializer.key_for(:user)] = warden_serializer.user_serialize(user)
    cookie_jar.signed_or_encrypted[session_key] = { value: session_hash }
    page.driver.set_cookie(
      session_key,
      cookie_jar[session_key],
      domain: "localhost:3000",
      sameSite: :Lax,
      httpOnly: true
    )
  end

  def logout
    page.driver.clear_cookies
  end
end
ActiveRecord::FixtureSet.context_class.send :include, TestPasswordHelper
