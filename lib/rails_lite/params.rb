require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.query_string) if req.query_string
    parse_www_encoded_form(req.body) if req.body
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_key ||= []
    @permitted_key.concat(keys)
  end

  def require(key)
    raise AttributeNotFoundError unless @params[key]
  end

  def permitted?(key)
    @permitted_key.include?(key)
  end

  def to_s
    @params.to_json
  end


  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    format = URI.decode_www_form(www_encoded_form)
    format.map!{ |key, val| parse_key(key) << val }

    format.each do |arr|
      parent = @params
      arr.each_with_index do |ele, idx|
        if(idx == arr.length - 2)
          parent[ele] = arr.last
          break
        else
          parent[ele] ||= {}
          parent = parent[ele]
        end
      end
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.to_s.gsub(/]/, '[').split("[").reject{ |x| x == "" }
  end

end
