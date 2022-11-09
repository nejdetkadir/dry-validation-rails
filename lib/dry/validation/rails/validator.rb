# frozen_string_literal: true

require_relative 'helpers'

module Dry
  module Validation
    module Rails
      class Validator < ActiveModel::Validator
        include Dry::Validation::Rails::Helpers

        def validate(record)
          return if skip_validation?(options, record)

          schema = options.fetch(:schema, default_schema_for(record, options))

          unless valid_schema?(schema)
            raise ArgumentError,
                  'Schema must be a Dry::Schema::Params or Dry::Schema::JSON or Dry::Validation::Contract'
          end

          validate_schema(record, schema, options) if need_to_validate?(record, options)
        end

        def validate_schema(record, schema, options)
          if is_dry_validation_contract?(schema)
            validate_dry_validation_contract(record, schema, options)
          elsif is_dry_schema?(schema)
            validate_dry_schema(record, schema, options)
          else
            raise ArgumentError,
                  'Schema must be a Dry::Schema::Params or Dry::Schema::JSON or Dry::Validation::Contract'
          end
        end

        private

        def validate_dry_validation_contract(record, schema, options)
          validator_schema = if pass_record_to_contract?(options)
                               key = record_key_for_passing_to_contract(options)
                               schema.new(key => record)
                             else
                               schema.new
                             end

          result = validator_schema.call(record.attributes)

          return if result.success?

          validate_each(record, result.errors.to_h)
        end

        def validate_dry_schema(record, schema, _options)
          result = schema.call(record.attributes)

          return if result.success?

          validate_each(record, result.errors.to_h)
        end

        def validate_each(record, errors)
          errors.each do |attribute, all_errors|
            all_errors.each do |error|
              record.errors.add(attribute, error) if record.respond_to?(attribute.to_sym)
            end
          end
        end
      end
    end
  end
end
