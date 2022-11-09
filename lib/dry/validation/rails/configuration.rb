# frozen_string_literal: true

module Dry
  module Validation
    module Rails
      class Configuration
        DEFAULT_SCHEMA_PREFIX = ''
        DEFAULT_SCHEMA_SUFFIX = 'Schema'

        attr_accessor :default_schema_prefix, :default_schema_suffix

        def initialize(default_schema_prefix: DEFAULT_SCHEMA_PREFIX, default_schema_suffix: DEFAULT_SCHEMA_SUFFIX)
          @default_schema_prefix = default_schema_prefix
          @default_schema_suffix = default_schema_suffix
        end
      end
    end
  end
end
