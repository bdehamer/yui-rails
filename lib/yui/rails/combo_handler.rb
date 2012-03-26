module YUI
  module Rails
    class ComboHandler

      def initialize(app)
        @app = app
      end

      def call(env)

        puts 'YUI-Rails pre-filter'
        if true
          status, headers, response = @app.call(env)
        end
        puts 'YUI-Rails post-filter'

        [status, headers, response]
      end
    end
  end
end
