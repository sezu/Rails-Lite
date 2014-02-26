class Flash
  def initialize(req)
    req.cookies.each do |cookie|
      @value = JSON.parse(cookie.value) if cookie.name == '_rails_lite_app_flash'
    end

    @value ||= {}
  end

  def [](key)
    @value[key]
  end

  def []=(key, val)
    @value[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app_flash', @value.to_json)
  end
end
