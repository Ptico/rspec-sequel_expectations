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

          index_present? && correct_name? && unique?
        end

        def description
          text = %w[have]
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

        def initialize(column, opts = {})
          @db = opts.fetch(:db) { ::Sequel::Model.db }
          @columns = Array(column)
          @unique = opts.fetch(:unique, false)
        end

        def get_required_index
          @index = @db.indexes(@table).each_pair.detect { |index, opts|
            index.to_s.split('_').last != 'key' && opts[:columns] == @columns
          }
        end

        # PostgreSQL adapter returns index and constraints as separate objects,
        # each with an appropriate postfix.
        # Other case is when constaint name is defined manually and
        # following method must take that in account too.
        def get_required_key
          key = @db.indexes(@table).each_pair.detect do |key, opts|
            if @name
              key == @name
            else
              key.to_s.split('_').last == 'key' && opts[:columns] == @columns
            end
          end
          @key = key.nil? ? {} : key.last
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
          get_required_key
          if @index.last[:unique] == @unique || @key.fetch(:unique, false) == @unique
            true
          else
            @error = 'index is non-unique'
            false
          end
        end

      end

      def have_index_on(column)
        HaveIndexOn.new(column, db: defined?(db) ? db : ::Sequel::Model.db)
      end

      def have_unique_index_on(column)
        HaveIndexOn.new(column, unique: true, db: defined?(db) ? db : ::Sequel::Model.db)
      end
      alias :have_uniq_index_on :have_unique_index_on

    end
  end
end
