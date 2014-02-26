class Flash
  attr_accessor :now

  def initialize(req)
    req.cookies.each do |cookie|
      @value = JSON.parse(cookie.value) if cookie.name == '_rails_lite_app_flash'
    end

    @value ||= {}

    #flash.now[:errors] = "message", cleared on every request
    @now = {}
  end

  #returns array of messages
  #flash[:errors]
  def [](selected_key)
    msgs = @value.select{ |key, _val| selected_key == key }.values
    msgs.concat(@now.select{ |key, _val| selected_key == key }.values)
    msgs
  end

  #flash[:errors] = "message"
  def []=(key, val)
    @value[key] = val
    add_to_recent(key, val)
  end

  def clear_messages
    @value.delete_if { |key, val| !recent?(key, val) }
    #@value now contains only persistent messages

    clear_recent_list
  end

  def add_to_recent(key, val)
    @recent ||= {}
    @recent[key] = val
  end

  def recent?(key, val)
    @recent[key] == val
  end

  def clear_recent_list
    @recent = {}
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app_flash', @value.to_json)
  end
end

#Maybe I need this? Maybe I don't

  #flash.now[:errors] = "message"
  # def now(key, val)
#     @now ||= {}
#     @now[key] = val
#   end

  # def now?(key, val)
  #   @now.has_value?(val) && @now.has_key?(key)
  # end

  #returns JSON array of messages
  #flash.messages(:errors)
  # def messages(selected_key)
  #   msgs = @value.select{ |key, val| selected_key == key}.values
  #   msgs.to_json
  # end

