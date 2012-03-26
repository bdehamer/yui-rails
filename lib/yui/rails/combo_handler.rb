module YUI 
  module Rails
    class ComboHandler

      def initialize(app)
        @app = app
      end

      def call(env)
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
          'Content-Length' => contents.size.to_s
        }

        [200, headers, [contents]]
      rescue Errno::ENOENT # File not found
        [404, {}, []]
      rescue Exception
        [403, {}, []]
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
        route = YUI::Rails.routes.find do |route|
          path.start_with?(route.keys.first)
        end

        route ? route.values.first : nil
      end

    end
  end
end
