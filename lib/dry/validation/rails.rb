# frozen_string_literal: true

require_relative 'rails/version'
require_relative 'rails/configuration'
require 'rails'
require 'dry-validation'
require 'active_support'
require 'active_record'
require 'active_model'

module Dry
  module Validation
    module Rails
      extend ActiveSupport::Autoload

      autoload :Validatable
      autoload :Validator
      autoload :Errors

      class << self
        def configuration
          @configuration ||= Configuration.new
        end

        def configure
          yield configuration
        end
      end

      class BaseError < StandardError; end
      class SchemaNotFound < BaseError; end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend Dry::Validation::Rails::Validatable
end
