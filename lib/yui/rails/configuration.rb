module YUI
  module Rails
    module Configuration

      attr_accessor :routes

      def self.extended(base)
        base.reset
      end

      def reset
        self.routes = []
      end
    end
  end
end
