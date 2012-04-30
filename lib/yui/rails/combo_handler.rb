module YUI 
  module Rails
    class ComboHandler

      class << self

        # Collection of routes that the combo handler will serve.
        # Each route in the array should be a hash of the form
        # <url_prefix> => <fully_qualified_asset_directory>
        attr_accessor :routes

        def routes
          @routes ||= []
        end

        # Add a single route to the collection
        def add_route(prefix, asset_path)
          routes << {prefix => asset_path}
        end

        def configure
          yield self
          true
        end
      end

      attr_reader :routes

      def initialize(app, routes=[])
        @app = app

        # Coerce routes into an array
        routes = [routes] unless routes.kind_of? Array 

        # Merge with routes configured at class-level
        @routes = routes | self.class.routes
      end

      def call(env)

        # This middleware will only handle a request if the
        # requested URL starts with one of the prefixes specified
        # in the routes collection.
        if (asset_path = map_request_url(env['PATH_INFO']))
          combine_resources(asset_path, env['QUERY_STRING'])
        else
          @app.call(env)
        end
      end


      protected

      def combine_resources(base_path, query_string)
        file_list = query_string.split('&')
        contents = combine_files(base_path, file_list)

        headers = { 
          'Content-Type' => lookup_content_type(file_list.first).to_s,
          'Cache-Control' => "public,max-age=#{1.year.to_i.to_s}",
          'Expires' => 1.year.from_now.httpdate
        }

        [200, headers, [contents]]
      rescue Errno::ENOENT # File not found
        [404, {}, ['Not Found']]
      rescue Exception
        [403, {}, ['Unauthorized']]
      end

      def combine_files(base_path, file_list)
        file_list.map do |param|
          relative_file_path = URI.unescape(param)
          absolute_file_path =
            File.expand_path(File.join(base_path, relative_file_path))
          verify_path_is_safe(base_path, absolute_file_path)
          IO.read(absolute_file_path)
        end.join('').to_s
      end

      def verify_path_is_safe(base_path, path)
        unless path.start_with?(base_path)
          throw 'Invalid path'
        end
      end

      def lookup_content_type(filename)
        extname = File.extname(filename)[1..-1]
        Mime::Type.lookup_by_extension(extname)
      end

      def map_request_url(path)
        route = routes.find do |route|
          path.start_with?(route.keys.first)
        end

        route ? route.values.first : nil
      end

    end
  end
end
