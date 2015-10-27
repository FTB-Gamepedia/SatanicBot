require 'cinch'
require_relative '../../variables'
require_relative '../../generalutils'

module Plugins
  module Commands
    class Version
      include Cinch::Plugin

      match(/updatevers ([^\|\[\]\<\>\%\+\?]+) \| (.+)/i, method: :update)
      match(/checkvers (.+)/i, method: :check)

      # Gets the current 'version' value for the page.
      # @param page [String] The page to check.
      # @return [Nil] If there is no version parameter.
      # @return [String] The version number.
      def get_current_verison(page)
        butt = LittleHelper.init_wiki
        text = butt.get_text(page)
        if text =~ /version=(.*)/ || text =~ /version =(.*)/
          return Regexp.last_match[1]
        else
          return nil
        end
      end

      # Adds the version parameter to the infobox in the page.
      # @param page [String] The page to add the version to.
      # @param version [String] The version to add.
      # @return [Boolean] True if successful, false if there is no infobox.
      # @return [String] The error code if any.
      def add_new_param(page, version)
        butt = LittleHelper.init_wiki
        text = butt.get_text(page)
        if /{{[Ii]nfobox mod/ =~ text
          text = text.sub(/{{[Ii]nfobox mod\n/, "{{Infobox mod\n|version=" \
                                                "#{version}")
          edit = butt.edit(page, text, true, true, 'Add version parameter')
          if edit.is_a?(Fixnum)
            return true
          else
            return edit
          end
        else
          return false
        end
      end

      # Updates the version parameter in the infobox.
      # @param page [String] The page to update.
      # @param version [String] The new version.
      # @return [Boolean] See #add_new_param
      # @return [String] See #add_new_param
      def update_param(page, version)
        butt = LittleHelper.init_wiki
        text = butt.get_text(page)
        if /version=#{version}/ !~ text && /version =#{version}/ !~ text
          text = text.gsub(/version=.*/, "version=#{version}")
          text = text.gsub(/version =.*/, "version=#{version}")
          edit = butt.edit(page, text, true, true, 'Update vesion.')
          if edit.is_a?(Fixnum)
            return true
          else
            return edit
          end
        else
          return false
        end
      end

      # Replies according to the return value.
      # @param return_value [Any] The return value of the edit.
      # @param mod [String] The mod name.
      # @param version [String] The new version.
      # @param new_p [Boolean] Whether the parameter is being created or not.
      def get_reply(return_value, mod, version, old, new_p = false)
        success "Added version parameter to #{mod} as #{version}" if new_p
        success = "Updated #{mod} from #{old} to #{version}!" unless new_p
        not_found = 'Could not find Infobox/param in the page. Please be ' \
                    'sure that you entered the page name correctly.'
        failed = "Failed! Error code: #{return_value}"
        success if return_value
        not_found unless return_value
        failed if return_value.is_a?(String)
      end

      def update(msg, mod, version)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          current = get_current_verison(mod)
          if current == version
            msg.reply("#{version} is already the current version")
          elsif current.nil?
            msg.reply('That page does not have the param, trying to make one.')
            add = add_new_param(mod, version)
            msg.reply(get_reply(add, mod, version, current, true))
          else
            update = update_param(mod, version)
            msg.reply(get_reply(update, mod, version, current))
          end
        else
          msg.reply('You must be logged in for this command.')
        end
      end

      def check(msg, page)
        version = get_current_verison(page)
        if version.nil?
          msg.reply('No version found on that page.')
        else
          msg.reply("The current version on the wiki for #{page} is #{version}")
        end
      end
    end
  end
end
