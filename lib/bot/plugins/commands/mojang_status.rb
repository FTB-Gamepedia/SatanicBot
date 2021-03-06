require 'cinch'
require 'mojang'
require_relative 'base_command'

module Plugins
  module Commands
    class MojangStatus < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Gets the status of the various Mojang servers. No args.', plugin_name: 'mcstatus')
      match(/mcstatus/i)

      def execute(msg)
        statuses = Mojang.status
        messages = []
        statuses.each do |site, status|
          type = case site
                 when 'minecraft.net' then 'Minecraft'
                 when 'session.minecraft.net' then 'Minecraft Sessions'
                 when 'account.mojang.com' then 'Mojang Account'
                 when 'auth.mojang.com' then 'Mojang Auth'
                 when 'skins.minecraft.net' then 'Minecraft Skins'
                 when 'authserver.mojang.com' then 'Mojang Auth Server'
                 when 'sessionserver.mojang.com' then 'Mojang Sessions'
                 when 'api.mojang.com' then 'Mojang API'
                 when 'textures.minecraft.net' then 'Minecraft Textures'
                 when 'mojang.com' then 'Mojang'
                 else ''
                 end
          resp = case status
                 when 'green' then Cinch::Formatting.format(:green, '✓')
                 when 'yellow' then Cinch::Formatting.format(:yellow, '~')
                 when 'red' then Cinch::Formatting.format(:red, '✗')
                 else ''
                 end

          messages << "#{type}: #{resp}"
        end
        msg.reply(messages.join(' | '))
      end
    end
  end
end
