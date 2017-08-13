class TestController < ActionController::Base

  include Rough::BaseController

  def test
    response_proto.message = "Hello #{request_proto.name}!"
  end

end
