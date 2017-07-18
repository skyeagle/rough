require_relative 'middleware'
require_relative 'base_controller'
require_relative 'actiondispatch_routing_ext'
require 'rails/engine'

module Rough

  class Engine < Rails::Engine

    initializer 'rough_engine.middleware' do |app|
      app.middleware.insert_after ActionDispatch::Flash, Rough::Middleware
    end

  end

end
