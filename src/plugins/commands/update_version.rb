require 'cinch'
require_relative '../../variables'
require_relative '../../generalutils'

module Plugins
  module Commands
    class UpdateVersion
      include Cinch::Plugin

      match(/updatevers ([^\|\[\]\<\>\%\+\?]+) \| (.+)/i)

      def execute(msg, mod, version)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          mod = mod.chomp
          version = version.chomp
          butt = LittleHelper.init_wiki
          text = butt.get_text(mod)
          if /version=/ =~ text || /version =/ =~ text
            if /version=#{version}/ !~ text && /version =#{version}/ !~ text
              text = text.gsub(/version=.*/, "version=#{version}")
              text = text.gsub(/version =.*/, "version=#{version}")
              butt.edit(mod, text, true, true, 'Update vesion.')
              msg.reply("Sucessfully updated #{mod} to #{version}!")
            else
              msg.reply("#{version} is the current version on the page.")
            end
          else
            msg.reply('That page does not have the param, trying to make one.')
            if /{{[Ii]nfobox mod}}/ =~ text
              text = text.sub(/}}/, "version=#{version}\n}}")
              edit = butt.edit(mod, text, true, true, 'Add version parameter')
              if edit.is_a?(Fixnum)
                msg.reply("Successfully updated #{mod} to #{version}!")
              else
                msg.reply("Failed! Error code: #{edit}")
              end
            else
              msg.reply('Could not find Infobox in the page. Please be sure ' \
                        'that you entered the page name correctly.')
            end
          end
        else
          msg.reply('You must be logged in for this command.')
        end
      end
    end
  end
end
