module Plugins
  class BasePlugin
  	def can_execute?(event)
      !event.user.ignored? && !disabled?
    end

  	def disabled?
      Variables::Constants::DISABLED_PLUGINS.include? self.class.name
    end
  end
end