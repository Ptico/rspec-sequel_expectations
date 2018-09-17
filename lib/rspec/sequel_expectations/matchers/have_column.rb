module RSpec
  module Matchers
    module Sequel

      class HaveColumn

        def matches?(subject)
          get_column_from(subject)

          have_column? && correct_type? && correct_default? && correct_null? && correct_size?
        end

        def of_type(type)
          @type = type
          self
        end

        def with_default(val)
          @default = val
          self
        end

        def allow_null
          @null = true
          self
        end

        def not_null
          @null = false
          self
        end

        def size(val)
          @size = val
          self
        end

        def description
          text = [%(have column named "#{@name}")]
          text << "of type #{@type}" if @type
          text << "size #{@size}" if @size
          text << %(with default value "#{@default}") unless @default == false
          text << 'allowing null' if @null == true
          text << 'not allowing null' if @null == false
          text.join(' ')
        end

        def failure_message
          %(expected #{@table} to #{description} but #{@error})
        end

        def failure_message_when_negated
          %(did not expect #{@table} to #{description})
        end

      private

        def initialize(column_name, opts = {})
          @db = opts.fetch(:db) { ::Sequel::Model.db }
          @name    = column_name
          @type    = nil
          @null    = nil
          @default = false
          @table   = nil
          @error   = nil
          @size = nil
        end

        def get_column_from(table)
          column = @db.schema(table.to_sym).detect { |tuple| tuple.first == @name }

          @table  = table
          @column = column ? column.last : nil
        end

        def have_column?
          if @column.nil?
            @error = %(#{@table} does not have a column named "#{@name}")
            false
          else
            true
          end
        end

        def correct_type?
          return true unless @type

          expected = @db.send(:type_literal, type: @type).to_s
          actual   = [@column[:type].to_s, @column[:db_type].to_s]

          if actual.include?(expected)
            true
          else
            @error = %(it have type [#{actual.join(', ')}])
            false
          end
        end

        def correct_null?
          return true if @null.nil?

          if @column[:allow_null] == @null
            true
          else
            @error = @null ? 'it does not allow null' : 'it allows null'
            false
          end
        end

        def correct_default?
          return true if @default == false

          if [@column[:default], @column[:ruby_default]].include?(@default)
            true
          else
            @error = %(it has default value "#{@column[:ruby_default] || @column[:default]}")
            false
          end
        end

        def correct_size?
          return true unless @size

          if @column[:max_length] && @column[:max_length] == @size
            true
          else
            @error = %(it has size "#{@column[:max_length] || 'not specified'}")
            false
          end
        end
      end

      def have_column(name)
        HaveColumn.new(name, db: defined?(db) ? db : ::Sequel::Model.db)
      end

    end
  end
end
