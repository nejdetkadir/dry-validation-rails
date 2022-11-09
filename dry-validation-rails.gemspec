# frozen_string_literal: true

require_relative 'lib/dry/validation/rails/version'

Gem::Specification.new do |spec|
  spec.name = 'dry-validation-rails'
  spec.version = Dry::Validation::Rails::VERSION
  spec.authors = ['nejdetkadir']
  spec.email = ['nejdetkadir.550@gmail.com']

  spec.summary = 'Rails plugin for implementing dry-validation gem for your Active Record Validations.'
  spec.description = spec.summary
  spec.homepage = "https://github.com/nejdetkadir/#{spec.name}"
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'dry-validation', '~> 1.10'
  spec.add_dependency 'rails', '>= 6.0.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
