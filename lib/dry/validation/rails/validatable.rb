# frozen_string_literal: true

module Dry
  module Validation
    module Rails
      module Validatable
        def validates_with_dry(**options)
          validates_with Dry::Validation::Rails::Validator, **options
        end
      end
    end
  end
end
