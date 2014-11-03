require "pry"

module RSpec
  module Matchers
    module Sequel
      # TODO: refactor with Sequel API
      # http://www.rubydoc.info/gems/sequel/4.13.0/Sequel/Postgres/EnumDatabaseMethods
      class HaveEnum
        def matches?(db)
           @db = db
           enum_exists? &&  with_valid_types?
        end
        
        def failure_message_when_negated
          "expected database not to #{@description} #{@error}"
        end
        
        def failure_message
          "expected database to #{description} #{@error}"
        end
        
        def with_types(types)
          raise ArgumentError, 'Types must be an array' unless types.is_a? Array 
          @enum_types = types
          self
        end

        private

        def description
          text = [%(have enum named "#{@enum_name}")]
          text << %(with types "#{@enum_types.join(', ')}") unless @enum_types.empty?
          text.join(' ')
        end

        def enum_exists?
            query = @db.fetch("SELECT '#{@enum_name}'::regtype;").first
            query[:regtype] == @enum_name
          rescue ::Sequel::DatabaseError => e
            return false if e.message[0..18] == 'PG::UndefinedObject'
            raise e
        end

        def with_valid_types?
          return true if @enum_types.empty?
          sql = "SELECT e.enumlabel FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid WHERE t.typname = '#{@enum_name}';"
          types = @db.fetch(sql).reduce([]) { |memo, enum| memo << enum[:enumlabel]}
          if @enum_types.sort == types.sort
            true
          else
            @error = "but got #{types}"
            false
          end
        end

        def initialize(enum_name)
          @enum_types = []
          @enum_name = enum_name
        end
      end
      
      def have_enum(enum_name)
        HaveEnum.new(enum_name)
      end
    end
  end
end
