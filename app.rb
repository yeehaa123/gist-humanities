require 'sinatra'
require 'json'
require 'rack/cors'
require_relative './lib/vision'

configure :production do
  require 'newrelic_rpm'
end

use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '/api/*', :headers => :any, :methods => :get
  end 
end

before do
  @vision = Vision.new
end

get '/api/concepts' do
  content_type :json
  @vision.concepts
end
