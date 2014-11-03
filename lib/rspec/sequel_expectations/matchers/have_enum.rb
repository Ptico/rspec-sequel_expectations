
module RSpec
  module Matchers
    module Sequel
      # TODO: refactor with Sequel API
      # http://www.rubydoc.info/gems/sequel/4.13.0/Sequel/Postgres/EnumDatabaseMethods
      class HaveEnum
        def matches?(db)
           @db = db
           enum_exists? &&  with_valid_values?
        end
        
        def failure_message_when_negated
          "expected database not to #{@description} #{@error}"
        end
        
        def failure_message
          "expected database to #{description} #{@error}"
        end
        
        def with_values(values)
          raise ArgumentError, 'values must be an array' unless values.is_a? Array 
          @enum_values = values
          self
        end

        private

        def description
          text = [%(have enum named "#{@enum_name}")]
          text << %(with values "#{@enum_values}") unless @enum_values.empty?
          text.join(' ')
        end

        def enum_exists?
            query = @db.fetch("SELECT '#{@enum_name}'::regtype;").first
            query[:regtype] == @enum_name
          rescue ::Sequel::DatabaseError => e
            return false if e.message[0..18] == 'PG::UndefinedObject'
            raise e
        end

        def with_valid_values?
          return true if @enum_values.empty?
          sql = "SELECT e.enumlabel FROM pg_enum e JOIN pg_type t ON t.oid = e.enumtypid WHERE t.typname = '#{@enum_name}';"
          values = @db.fetch(sql).reduce([]) { |memo, enum| memo << enum[:enumlabel]}
          if @enum_values.sort == values.sort
            true
          else
            @error = "but got #{values}"
            false
          end
        end

        def initialize(enum_name)
          @enum_values = []
          @enum_name = enum_name
        end
      end
      
      def have_enum(enum_name)
        HaveEnum.new(enum_name)
      end
    end
  end
end
