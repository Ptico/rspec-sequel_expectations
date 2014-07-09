module RSpec
  module Matchers
    module Sequel

      class ReferTo
      end

      def refer_to(table)
        ReferTo.new(table)
      end
    end
  end
end