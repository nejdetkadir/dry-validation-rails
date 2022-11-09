# frozen_string_literal: true

module Dry
  module Validation
    module Rails
      module Helpers
        SUPPORTED_VALIDATORS = [
          Dry::Validation::Contract,
          Dry::Schema.Params,
          Dry::Schema::JSON
        ].freeze

        def default_schema_for(record, options = {})
          prefix = options.fetch(:schema_prefix, Dry::Validation::Rails.configuration.default_schema_prefix).to_s
          suffix = options.fetch(:schema_suffix, Dry::Validation::Rails.configuration.default_schema_suffix).to_s

          begin
            "#{prefix}#{record.class.name}#{suffix}".classify.constantize
          rescue StandardError
            raise Dry::Validation::Rails::SchemaNotFound, "Schema not found for #{record.class.name}"
          end
        end

        # rubocop:disable Layout/LineLength
        def valid_schema?(schema)
          if schema.respond_to?(:ancestors)
            return schema.ancestors.any? do |ancestor|
                     SUPPORTED_VALIDATORS.include?(ancestor)
                   end
          end

          schema.is_a?(Dry::Validation::Contract) || schema.is_a?(Dry::Schema::Params) || schema.is_a?(Dry::Schema::JSON)
        end
        # rubocop:enable Layout/LineLength

        def need_to_validate?(record, options)
          return true if options[:on].blank? || options[:on] == :all

          record.new_record? if options[:on] == :create

          record.persisted? if options[:on] == :update

          raise ArgumentError, "Invalid value for :on option: #{options[:on]}"
        end

        # rubocop:disable Naming/PredicateName
        def is_dry_schema?(schema)
          schema.is_a?(Dry::Schema::Params) || schema.is_a?(Dry::Schema::JSON)
        end

        def is_dry_validation_contract?(schema)
          schema.respond_to?(:ancestors) && schema.ancestors.include?(Dry::Validation::Contract)
        end
        # rubocop:enable Naming/PredicateName

        def pass_record_to_contract?(options)
          value = options[:pass_record_to_contract]

          return true if boolean?(value) || value.is_a?(Hash)

          false
        end

        def record_key_for_passing_to_contract(options)
          return :record if boolean?(options[:pass_record_to_contract])

          options.fetch(:pass_record_to_contract, {}).fetch(:as, :record)
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def skip_validation?(options, record)
          if_val = options[:if]
          unless_val = options[:unless]

          if if_val.present?
            return false unless if_val.is_a?(Symbol) || if_val.is_a?(Proc)
            return false if if_val.is_a?(Symbol) && record.respond_to?(if_val) && record.send(if_val)
            return false if if_val.is_a?(Proc) && if_val.call(record)
          end

          if unless_val.present?
            return false unless unless_val.is_a?(Symbol) || unless_val.is_a?(Proc)
            return false if unless_val.is_a?(Symbol) && record.respond_to?(unless_val) && !record.send(unless_val)
            return false if unless_val.is_a?(Proc) && !unless_val.call(record)
          end

          false
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        private

        def boolean?(value)
          value.is_a?(TrueClass) || value.is_a?(FalseClass)
        end
      end
    end
  end
end
