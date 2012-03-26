require 'rails'
require 'yui/rails/version'
require 'yui/rails/engine'
require 'yui/rails/configuration'
require 'yui/rails/combo_handler'

module YUI
  module Rails
    extend Configuration

    def self.configure
      yield self
      true
    end

  end
end
