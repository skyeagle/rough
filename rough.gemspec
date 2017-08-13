require File.expand_path('../lib/rough/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rough'

  gem.authors       = ['john crepezzi']
  gem.email         = ['johnc@squareup.com']
  gem.description   = 'protobuf-driven APIs in Rails'
  gem.summary       = 'protobuf APIs'
  gem.homepage      = 'https://rubygems.org/gems/rough'

  gem.add_dependency 'rails', '~> 3.2'
  gem.add_dependency 'google-protobuf', '~> 3.3'
  gem.add_dependency 'grpc', '~> 1.3'

  gem.add_development_dependency 'actionpack', '~> 3.2'
  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'rspec-rails', '~> 3'
  gem.add_development_dependency 'simplecov', '~> 0.8'
  gem.add_development_dependency 'rubocop', '~> 0.28'
  gem.add_development_dependency 'combustion', '~> 0.5'
  gem.add_development_dependency 'test-unit', '~> 3.0'

  gem.files         = Dir.glob('lib/**/*.rb')
  gem.require_paths = ['lib']
  gem.version       = Rough::VERSION
  gem.licenses      = ['Apache']
end
