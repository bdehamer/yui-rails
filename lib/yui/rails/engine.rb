module YUI
  module Rails

    # This engine class adds the gem's vendored assets to sprockets' load path
    class Engine < ::Rails::Engine
      initializer 'YUI combo handler' do |app|
        app.config.middleware.insert_after ::ActionDispatch::Static,
          ::YUI::Rails::ComboHandler
      end
    end

  end
end
