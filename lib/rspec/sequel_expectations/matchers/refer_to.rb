module RSpec
  module Matchers
    module Sequel
      class ReferTo
        def matches?(subject)
          get_reference_for(subject)

          refer_to? && correct_fk? && correct_pk? && correct_update? && correct_delete?
        end

        def from_fk(key)
          @foreign_key = key
          self
        end

        def to_pk(key)
          @primary_key = key
          self
        end

        def on_update(action)
          @on_update = action
          self
        end

        def on_delete(action)
          @on_delete = action
          self
        end

        def description
          text = [%(have reference to "#{@table}")]
          text << %(with column "#{@foreign_key}") if @foreign_key
          text << %(with primary key column "#{@primary_key}") if @primary_key
          text << %(with "#{@on_update}" action on update) if @on_update
          text << %(with "#{@on_delete}" action on delete) if @on_delete

          text.join(' ')
        end

        def failure_message
          %(expected "#{@relation}" to #{description} but #{@error})
        end

        def failure_message_when_negated
          %(did not expect "#{@relation}" to #{description})
        end

      private

        def initialize(table)
          @table       = table
          @foreign_key = nil
          @primary_key = nil
          @on_update   = nil
          @on_delete   = nil
        end

        def refer_to?
          if @reference
            true
          else
            @error = %("#{@relation}" does not have a reference to "#{@table}")
            false
          end
        end

        def correct_fk?
          return true unless @foreign_key

          if @reference[:columns].include?(@foreign_key)
            true
          else
            @error = %("#{@relation}" does not have a foreign key column "#{@foreign_key}")
            false
          end
        end

        def correct_pk?
          return true unless @primary_key

          if @reference[:key].first == @primary_key
            true
          else
            @error = %("#{@table}" does not have a primary key column "#{@primary_key}")
            false
          end
        end

        def correct_update?
          return true unless @on_update

          if @reference[:on_update] == @on_update
            true
          else
            @error = %(reference does not have action "#{@on_update}" on update)
            false
          end
        end

        def correct_delete?
          return true unless @on_delete

          if @reference[:on_delete] == @on_delete
            true
          else
            @error = %(reference does not have action "#{@on_delete}" on delete)
            false
          end
        end

        def get_reference_for(relation)
          @relation  = relation
          @reference = DB.foreign_key_list(relation).select { |fk| fk[:table] == @table }.first
        end
      end

      def refer_to(table)
        ReferTo.new(table)
      end
    end
  end
end
