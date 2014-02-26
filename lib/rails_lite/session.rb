require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.each do |cookie|
      @value = JSON.parse(cookie.value) if cookie.name == '_rails_lite_app'
    end

    @value ||= {}
    @value[:csrf_token] ||= generate_csrf_token
  end

  def [](key)
    @value[key]
  end

  def []=(key, val)
    @value[key] = val
  end

  def generate_csrf_token
    SecureRandom::urlsafe_base64(16)
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    @value[:csrf_token] = generate_csrf_token
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @value.to_json)
  end
end
