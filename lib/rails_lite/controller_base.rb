require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Already Rendered" if already_rendered?
    flash.clear_messages

    @res.body = content
    @res.content_type = type

    store_cookies(@res)
    @already_built_response = @res
  end

  # helper method to alias @already_rendered
  def already_rendered?
    !!@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "Already Rendered" if already_rendered?
    flash.clear_messages

    @res.status = 302
    @res["location"] = url

    store_cookies(@res)
    @already_built_response = @res
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    content = ERB.new(template).result(binding)
    render_content(content, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def store_cookies(res)
    session.store_session(res)
    flash.store_session(res)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_rendered?
  end
end
