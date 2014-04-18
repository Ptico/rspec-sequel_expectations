module RSpec
  module Matchers
    module Sequel

      class HaveColumn
        OPT_MAPPING = {
          null: :allow_null
        }.freeze

        def matches?(subject)
          get_column_from(subject)

          have_column? && correct_type? && correct_options?
        end

        def of_type(type)
          @type = type
          self
        end

        def with_options(opts = {})
          @options = opts
          self
        end

        def description
          text = [%(have column named "#{@name}")]
          text << "of type #{@type}" if @type
          text << "with options #{@options.inspect}" unless @options.empty?
          text.join(' ')
        end

        def failure_message
          %(expected #{@table} to #{description} but #{@error})
        end

        def negative_failure_message
          %(did not expect #{@table} to #{description})
        end

      private

        def initialize(column_name)
          @name    = column_name
          @type    = nil
          @table   = nil
          @error   = nil
          @options = {}
        end

        def get_column_from(table)
          column  = DB.schema(table.to_sym).detect { |tuple| tuple.first == @name }

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

          expected = DB.send(:type_literal, { type: @type }).to_s
          actual   = [@column[:type].to_s, @column[:db_type].to_s]

          if actual.include?(expected)
            true
          else
            @error = %(column #{@name} have type [#{actual.join(', ')}])
            false
          end
        end

        def correct_options?
          return true if @options.empty?

          @options.each_pair do |opt, val|
            orig_option = opt
            opt = OPT_MAPPING[opt] if OPT_MAPPING.has_key?(opt)

            if @column.has_key?(opt)
              if opt == :default
                test = test_default(val)
                curr = @column[:ruby_default] || @column[:default]
              else
                curr = @column[opt]
                test = curr == val
              end

              unless test
                @error = %(column #{@name} has option "#{orig_option}" with value #{curr})
                return false
              end
            else
              @error = %(column #{@name} does not have option "#{orig_option}")
              return false
            end
          end

          true
        end

        def test_default(val)
          [@column[:default], @column[:ruby_default]].include?(val)
        end

      end

      def have_column(name)
        HaveColumn.new(name)
      end

    end
  end
end
