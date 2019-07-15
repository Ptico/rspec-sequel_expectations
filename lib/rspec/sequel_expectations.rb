require 'rspec/sequel_expectations/version'

require 'rspec/sequel_expectations/matchers/have_primary_key'
require 'rspec/sequel_expectations/matchers/have_column'
require 'rspec/sequel_expectations/matchers/have_index_on'
require 'rspec/sequel_expectations/matchers/refer_to'
require 'rspec/sequel_expectations/matchers/have_enum'

module Rspec
  module SequelExpectations
    def self.db
      defined?(DB) ? DB : ::Sequel::Model.db
    end
  end
end
