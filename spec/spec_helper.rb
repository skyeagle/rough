# Setup simplecov

require 'simplecov'
SimpleCov.start { add_filter('/spec/') }

# Setup combustion

require 'combustion'
Combustion.path = 'spec/dummy'
Combustion.initialize! :action_controller

# Load library

require 'rspec/rails'
require_relative '../lib/rough'

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "greeter.Request" do
    optional :name, :string, 1
  end
  add_message "greeter.Response" do
    optional :message, :string, 1
  end
end

module Greeter
  Request = Google::Protobuf::DescriptorPool.generated_pool.lookup("greeter.Request").msgclass
  Response = Google::Protobuf::DescriptorPool.generated_pool.lookup("greeter.Response").msgclass

  class Service

    include GRPC::GenericService

    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode

    rpc :say_hello, Request, Response
  end

  def say_hello(req, _unused_call)
    Response.new(message: "Hello #{req.name}")
  end

end

# For testing middleware

class MockRackApp

  attr_reader :env

  def call(env)
    @env = env
    [200, {}, ['OK']]
  end

end
