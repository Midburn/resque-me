# environment space
require "sinatra"
require 'sinatra/cross_origin'
require "dotenv"; Dotenv.load

# application space
require "pry"
require "redis"
require "resque"
require "csv"
require "./worker.rb"

# App Configurations
QUEUE_IS_OPEN_REDIS_KEY     = ENV["QUEUE_IS_OPEN_REDIS_KEY"]  || "queue_is_open"
USERS_EMAIL_PARAM           = ENV["USERS_EMAIL_PARAM"] || "email"
REGISTER_FORM_URL           = ENV["REGISTER_FORM_URL"] || "register.html"
ACCESS_CONTROL_ALLOW_ORIGIN = ENV["ACCESS_CONTROL_ALLOW_ORIGIN"] || "*"
REGISTER_ROUTE              = ENV["REGISTER_ROUTE"] || "/register"

class MidburnQueue < Sinatra::Base
  configure do
    enable :cross_origin
  end  

  set(:method) do |method|
    method = method.to_s.upcase
    condition { request.request_method == method }
  end

  before :method => :post do
    load_params
    set_response_headers
    access_log
  end 

  def access_log
    puts "[access log] #{self.env["REQUEST_METHOD"]} #{self.env["REQUEST_PATH"]} from #{self.env["REMOTE_ADDR"]}: #{params}"
  end

  def set_response_headers
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    response.headers["Access-Control-Allow-Origin"] = ACCESS_CONTROL_ALLOW_ORIGIN
  end

  def load_params
    return @params if @request_body_read
    begin
      @params = JSON.parse(request.body.read)
      @request_body_read = true
    rescue Exception => e
      @params = {}
    end
  end

  def queue_is_open?
    Resque.redis.get(QUEUE_IS_OPEN_REDIS_KEY) == "true"
  end

  options "*" do
    set_response_headers
    response.headers["Allow"] = "HEAD,POST,OPTIONS"
    200
  end

  post '/status' do
    halt(403) if not queue_is_open?
    { register_page: REGISTER_FORM_URL }.to_json
  end

  post "#{REGISTER_ROUTE}" do
    halt(400) if params[USERS_EMAIL_PARAM].empty?
    order_json = %{{"ip":"#{request.ip}","timestamp":"#{Time.now.to_i}","email":"#{params[USERS_EMAIL_PARAM]}"}}

    if queue_is_open?
      Resque.enqueue(TicketsQueue, order_json)
    else
      Resque.enqueue(BannedOrder, order_json)
      halt(403)
    end
  end
end