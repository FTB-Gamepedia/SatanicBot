require 'cinch'

module Plugins
  module Commands
    class Version
      include Cinch::Plugin

      match(/updatevers ([^\|\[\]<>%\+\?]+) \| (.+)/i, method: :update)
      match(/checkvers (.+)/i, method: :check)

      UPDATE_DOC = 'Updates a mod version on the wiki. Op-only command. ' \
                   '2 args: $updatevers <page> | <version> Args must be separated with a pipe in this command.'.freeze
      CHECK_DOC = 'Gets the current version on the page. 1 arg: $checkvers <page>'.freeze
      Variables::NonConstants.add_command('updatevers', UPDATE_DOC)
      Variables::NonConstants.add_command('checkvers', CHECK_DOC)

      # Gets the current 'version' value for the page.
      # @param page [String] The page to check.
      # @return [Nil] If there is no version parameter.
      # @return [String] The version number.
      def get_current_verison(page)
        butt = LittleHelper.init_wiki
        text = butt.get_text(page)
        if text =~ /version=(.*)/ || text =~ /version =(.*)/
          return Regexp.last_match[1]
        end

        nil
      end

      # Adds the version parameter to the infobox in the page.
      # @param page [String] The page to add the version to.
      # @param version [String] The version to add.
      # @return [Boolean] True if successful, false if there is no infobox.
      # @return [String] The error code if any.
      def add_new_param(page, version)
        butt = LittleHelper.init_wiki
        text = butt.get_text(page)
        return false unless /{{[Ii]nfobox mod}}/ =~ text
        text.sub!(/{{[Ii]nfobox mod\n/, "{{Infobox mod\n|version=#{version}")
        begin
          edit = butt.edit(page, text, true, true, 'Add version parameter'.freeze)
        rescue EditError => e
          msg.reply("Failed! Error code: #{e.message}")
        end

        edit
      end

      # Updates the version parameter in the infobox.
      # @param page [String] The page to update.
      # @param version [String] The new version.
      # @return [Boolean] See #add_new_param
      # @return [String] See #add_new_param
      def update_param(page, version)
        butt = LittleHelper.init_wiki
        text = butt.get_text(page)
        return false if /version=#{version}/ =~ text || /version =#{version}/ =~ text
        text.gsub!(/version=.*/, "version=#{version}")
        text.gsub!(/version =.*/, "version=#{version}")
        begin
          edit = butt.edit(page, text, true, true, 'Update vesion.'.freeze)
        rescue EditError => e
          msg.reply("Failed! Error code: #{e.message}")
        end

        edit
      end

      NOT_FOUND = 'Could not find Infobox/param in the page. ' \
                  'Please be sure that you entered the page name correctly.'.freeze

      # Replies according to the return value.
      # @param return_value [Any] The return value of the edit.
      # @param mod [String] The mod name.
      # @param version [String] The new version.
      # @param new_p [Boolean] Whether the parameter is being created or not.
      def get_reply(return_value, mod, version, old, new_p = false)
        return unless return_value
        success = new_p ? "Added version parameter to #{mod} as #{version}" : "Updated #{mod} from #{old} to #{version}!"
        failed = "Failed! Error code: #{return_value}"
        return success if return_value
        return NOT_FOUND unless return_value
        return failed if return_value.is_a?(String)
      end

      # Updates the mod version for the given mod on the wiki.
      # @param msg [Cinch::Message]
      # @param mod [String] The mod to update on the wiki.
      # @param version [String] The new mod version.
      def update(msg, mod, version)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        authedusers = Variables::NonConstants.get_authenticated_users
        if authedusers.include?(msg.user.authname)
          current = get_current_verison(mod)
          if current == version
            msg.reply("#{version} is already the current version")
          elsif current.nil?
            msg.reply('That page does not have the param, trying to make one.'.freeze)
            add = add_new_param(mod, version)
            msg.reply(get_reply(add, mod, version, current, true))
          else
            update = update_param(mod, version)
            msg.reply(get_reply(update, mod, version, current))
          end
        else
          msg.reply(Variables::Constants::LOGGED_IN)
        end
      end

      # Gets the current version on the page, if possible.
      # @param msg [Cinch::Message]
      # @param page [String] The mod page.
      def check(msg, page)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        version = get_current_verison(page)
        if version.nil?
          msg.reply('No version found on that page.'.freeze)
        else
          msg.reply("The current version on the wiki for #{page} is #{version}")
        end
      end
    end
  end
end
