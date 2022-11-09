# frozen_string_literal: true

require 'test_helper'

module Dry
  module Validation
    class TestRails < Minitest::Test
      def test_that_it_has_a_version_number
        refute_nil ::Dry::Validation::Rails::VERSION
      end
    end
  end
end
