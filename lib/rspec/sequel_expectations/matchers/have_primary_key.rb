module RSpec
  module Matchers
    module Sequel

      class HavePrimaryKey

        def matches?(subject)
          @table = subject

          get_keys

          includes_all?
        end

        def description
          %(have #{wording(@names)})
        end

        def failure_message
          %(expected #{@table} to #{description} but #{@table} have #{wording(@keys)})
        end

        def failure_message_when_negated
          %(did not expect #{@table} to #{description})
        end

      private

        def initialize(*names)
          opts = names.last.is_a?(::Hash) ? names.pop : {}
          @db = opts.fetch(:db) { ::Sequel::Model.db }
          @names = names
          @keys  = []
        end

        def get_keys
          @keys = @db.schema(@table).reject { |tuple| !tuple.last[:primary_key] }.map(&:first)
        end

        def includes_all?
          @names.reject { |k| @keys.include?(k) }.empty?
        end

        def wording(arr)
          case arr.length
          when 0
            %(no primary keys)
          when 1
            %(primary key "#{arr.first}")
          else
            %(primary keys #{arr.inspect})
          end
        end

      end

      def have_primary_key(*names)
        HavePrimaryKey.new(*names, db: defined?(db) ? db : ::Sequel::Model.db)
      end
      alias :have_primary_keys :have_primary_key

    end
  end
end
