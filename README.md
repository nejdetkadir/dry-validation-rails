[![Gem Version](https://badge.fury.io/rb/dry-validation-rails.svg)](https://badge.fury.io/rb/dry-validation-rails)
![test](https://github.com/nejdetkadir/dry-validation-rails/actions/workflows/test.yml/badge.svg?branch=main)
![rubocop](https://github.com/nejdetkadir/dry-validation-rails/actions/workflows/rubocop.yml/badge.svg?branch=main)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
![Ruby Version](https://img.shields.io/badge/ruby_version->=_2.7.0-blue.svg)

# Dry::Validation::Rails

Rails plugin for implementing [dry-validation](https://github.com/dry-rb/dry-validation) gem for your [Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html).

## Installation

```ruby
gem 'dry-validation-rails', github: 'nejdetkadir/dry-validation-rails', branch: 'main'
```

Install the gem and add to the application's Gemfile by executing:
```bash
$ bundle add dry-validation-rails
```

If bundler is not being used to manage dependencies, install the gem by executing:
```bash
$ gem install dry-validation-rails
```

## Configuration
```ruby
Dry::Validation::Rails.configure do |config|
  config.default_schema_prefix = 'ApplicationContract::' 
  config.default_schema_suffix = 'Schema'
end

Dry::Validation::Rails.configuration.default_schema_prefix = 'ApplicationContract::'
Dry::Validation::Rails.configuration.default_schema_suffix = 'Contract'
```

## Usage

Simply drop in followability to a model:

```ruby
class User < ActiveRecord::Base
  validates_with_dry
end

class UserSchema < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
  end
end

user = User.new(name: '', email: '')
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string"]
```

### With DRY Schema
You can use [dry-schema](https://dry-rb.org/gems/dry-schema/) for defining your schema and use it in your model.

```ruby
class User < ActiveRecord::Base
  validates_with_dry
end

UserSchema = Dry::Schema.Params do
  required(:name).filled(:string)
  required(:email).filled(:string)
end

user = User.new(name: '', email: '')
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string"]
```

### With DRY Validation Contract
You can use [dry-validation](https://dry-rb.org/gems/dry-validation/) for defining your schema and use it in your model.

```ruby
class User < ActiveRecord::Base
  validates_with_dry
end

class UserSchema < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
  end
end

user = User.new(name: '', email: '')
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string"]
```

### Passing options

You can pass options to the schema by passing a hash to the `validates_with_dry` method.


#### Prefix and Suffix
```ruby
class User < ActiveRecord::Base
  # You can pass custom prefix and suffix for validator class
  validates_with_dry schema_prefix: 'ApplicationContract::', schema_suffix: 'Contract'
end

class Application
  class UserContract < Dry::Validation::Contract
    params do
      required(:name).filled(:string)
      required(:email).filled(:string)
    end
  end
end

user = User.new(name: '', email: '')
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string"]
```

#### Custom Schema
```ruby
class User < ActiveRecord::Base
  validates_with_dry schema: UserCustomSchema # custom schema
end

class UserCustomSchema < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
  end
end

user = User.new(name: '', email: '')
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string"]
```

#### Pass record to contract
We can define it as an external dependency that will be injected to the contract's constructor for Dry Validation Contract. You can pass record to the contract like this:

```ruby
class User < ActiveRecord::Base
  validates_with_dry schema: UserSchema, pass_record_to_contract: true # default key is :record
end

class UserSchema < Dry::Validation::Contract
  option :record # this is the record that will be passed to the contract as an option

  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
    required(:age).filled(:integer).value(gteq?: 18)
  end

  rule(:age) do
    key.failure('must be greater than 20') if record.role.admin? && value < 20
  end
end

user = User.new(name: '', email: '')
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string"]
```

**Custom key for record**

```ruby
class User < ActiveRecord::Base
  validates_with_dry schema: UserSchema, pass_record_to_contract: { as: :user }
end

class UserSchema < Dry::Validation::Contract
  option :user

  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
    required(:age).filled(:integer).value(gteq?: 18)
  end

  rule(:age) do
    key.failure('must be greater than 20') if user.role.admin? && value < 20
  end
end

user = User.new(name: '', email: '')
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string"]
```

#### Run validation on update or create
Default is `:all` which means it will run on both create and update. You can pass `:create` or `:update` to run validation only on create or update.

```ruby
class User < ActiveRecord::Base
  validates_with_dry schema: UserSchema, on: :create
end

class UserSchema < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
  end
end

user = User.first
user.name = ''
user.valid? # => true
user.errors.full_messages # => []
```

### Run validation with if or unless
You can pass `if` or `unless` option as a symbol or a proc to run validation only if the condition is true.

***if***

```ruby
class User < ActiveRecord::Base
  validates_with_dry schema: AdminSchema, if: Proc.new { |user| user.admin? }
  validates_with_dry schema: UserSchema, if: :normal_user?

  def admin?
    role.admin?
  end

  def normal_user?
    !admin?
  end
end
```

***unless***

```ruby
class User < ActiveRecord::Base
  validates_with_dry schema: AdminSchema, unless: :normal_user?
  validates_with_dry schema: UserSchema, unless: Proc.new { |user| user.admin? }

  def admin?
    role.admin?
  end

  def normal_user?
    !admin?
  end
end
```

## JSON / JSONB Attributes
You can validate json/jsonb columns with like this:

```ruby
class User < ActiveRecord::Base
  validates_with_dry schema: UserSchema
end

class UserSchema < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
    required(:preferences).hash do
      required(:color).filled(:string)
      required(:font).filled(:string)
    end
  end
end

user = User.new(name: '', email: '', preferences: { color: '', font: '' })
user.valid? # => false
user.errors.full_messages # => ["Name is missing", "Name must be a string", "Email is missing", "Email must be a string", "Preferences is missing", "Preferences must be a hash", "Preferences.color is missing", "Preferences.color must be a string", "Preferences.font is missing", "Preferences.font must be a string"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nejdetkadir/dry-validation-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nejdetkadir/dry-validation-rails/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Code of Conduct

Everyone interacting in the Dry::Validation::Rails project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nejdetkadir/dry-validation-rails/blob/main/CODE_OF_CONDUCT.md).
