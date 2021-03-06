# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/decorate/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-decorate'
  spec.version       = GraphQL::Decorate::VERSION
  spec.authors       = ['Ben Brook']
  spec.email         = ['bbrook154@gmail.com']

  spec.summary       = 'A decorator integration for the GraphQL gem'
  spec.homepage      = 'https://www.github.com/TrueCar/graphql-decorate'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_runtime_dependency 'graphql', '>= 1.3', '< 2'

  spec.add_development_dependency 'bundler', '>= 2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', ' >= 1.11.0 '
  spec.add_development_dependency 'rubocop-rspec', '2.2.0'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'yard', '~> 0.9.26'
end
