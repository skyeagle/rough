Rails.application.routes.draw do
  post 'test-rpc' => 'test#test', rpc: 'Greeter#say_hello'
  post 'test-not-rpc' => 'test#not_rpc'
end
