require_relative '../base_plugin'

module Plugins
  module MessageEventHandlers
    class BaseMEH < BasePlugin
      attr_reader :attributes
      
      def initialize(attributes = {})
        @attributes = attributes
      end
    end
  end
end