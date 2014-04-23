module RSpec
  module Matchers
    module Sequel

      class HaveIndexOn

        def named(name)
          @name = name.to_sym
          self
        end

        def matches?(table)
          @table = table

          get_required_index

          index_present? && unique? && correct_name?
        end

        def description
          text = %w(have)
          text << 'unique' if @unique
          text << %(index on #{@columns.inspect})
          text << %(named "#{@name}") if @name
          text.join(' ')
        end

        def failure_message
          %(expected #{@table} to #{description} but #{@error})
        end

        def failure_message_when_negated
          %(did not expect #{@table} to #{description})
        end

      private

        def initialize(column, unique=false)
          @columns = Array(column)
          @unique = unique
        end

        def get_required_index
          @index = DB.indexes(@table).each_pair.detect { |_, opts|
            opts[:columns] == @columns
          }
        end

        def index_present?
          if @index.nil?
            @error = 'none exists'
            false
          else
            true
          end
        end

        def correct_name?
          if @name && @index.first != @name
            @error = %(index have name "#{@index.first}")
            false
          else
            true
          end
        end

        def unique?
          if @index.last[:unique] == @unique
            true
          else
            @error = 'index is non-unique'
            false
          end
        end

      end

      def have_index_on(column)
        HaveIndexOn.new(column)
      end

      def have_unique_index_on(column)
        HaveIndexOn.new(column, true)
      end
      alias :have_uniq_index_on :have_unique_index_on

    end
  end
end
