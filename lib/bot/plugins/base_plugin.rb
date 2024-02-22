module Plugins
  class BasePlugin
  	def can_execute?(event)
      !event.user.ignored? && !disabled?
    end

  	def disabled?
      Variables::Constants::DISABLED_PLUGINS.include? self.class.name
    end

    # Wraps the provided string in angle brackets in order to prevent a link
    #   from being embedded in a message and clogging up chat space.
    # @param link [String] The link
    # @return [String]
    def no_embed(link)
      "<#{link}>"
    end
  end
end