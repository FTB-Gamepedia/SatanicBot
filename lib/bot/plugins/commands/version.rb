require 'cinch'
require_relative 'base_command'
require_relative '../wiki'

module Plugins
  module Commands
    module Version
      # Gets the current 'version' value for the page.
      # @param page [String] The page to check.
      # @return [Nil] If there is no version parameter.
      # @return [String] The version number.
      def get_current_version(page)
        text = wiki.get_text(page)
        if text =~ /\|version=(.*)/ || text =~ /\|version =(.*)/
          return Regexp.last_match[1]
        end

        nil
      end

      class CheckVersion < BaseCommand
        include Cinch::Plugin
        include Plugins::Wiki
        include Version
        ignore_ignored_users

        set(help: 'Gets the current mod version on the page. 1 arg: $checkvers <page>', plugin_name: 'checkvers')
        match(/checkvers (.+)/i, method: :check)

        # Gets the current version on the page, if possible.
        # @param msg [Cinch::Message]
        # @param page [String] The mod page.
        def check(msg, page)
          version = get_current_version(page)
          if version.nil?
            msg.reply('No version found on that page.'.freeze)
          else
            msg.reply("The current version on the wiki for #{page} is #{version}")
          end
        end
      end

      class UpdateVersion < AuthorizedCommand
        include Cinch::Plugin
        include Plugins::Wiki
        include Version
        ignore_ignored_users

        set(help: 'Updates a mod version on the wiki. Op-only command. 2 args: $updatevers <page> | <version>',
            plugin_name: 'updatevers')
        match(/updatevers ([^\|\[\]<>%\+\?]+) \| (.+)/i, method: :update)

        NOT_FOUND = 'Could not find Infobox/param in the page. ' \
                    'Please be sure that you entered the page name correctly.'.freeze

        # Adds the version parameter to the infobox in the page.
        # @param page [String] The page to add the version to.
        # @param msg [Cinch::Message] The message that prompted the edit.
        # @param version [String] The version to add.
        # @return [Boolean] True if successful, false if there is no infobox.
        # @return [String] The error code if any.
        def add_new_param(page, msg, version)
          edit(page, msg, minor: true, summary: 'Add version parameter'.freeze) do |text|
            return { terminate: Proc.new { NOT_FOUND } } if /{{[Ii]nfobox mod/ !~ text
            text.sub!(/{{[Ii]nfobox mod\n/, "{{Infobox mod\n|version=#{version}")
            {
              text: text,
              success: Proc.new { "Added version parameter to #{page} as #{version}" },
              fail: Proc.new { "Failed to edit #{page}" },
              error: Proc.new { |e| "Failed! Error code: #{e.message}" }
            }
          end
        end

        # Updates the version parameter in the infobox.
        # @param page [String] The page to update.
        # @param msg [Cinch::Message] The message that prompted this edit.
        # @param cur_version [String] The current version on the page.
        # @param version [String] The new version.
        # @return [Boolean] See #add_new_param
        # @return [String] See #add_new_param
        def update_param(page, msg, cur_version, version)
          edit(page, msg, minor: true, summary: 'Update version.'.freeze) do |text|
            return { terminate: Proc.new { NOT_FOUND } } if /\|\s*version\s*=\s*#{version}/ =~ text
            text.gsub!(/\|version=.*/, "|version=#{version}")
            text.gsub!(/\|version =.*/, "|version=#{version}")
            {
              text: text,
              success: Proc.new { "Updated #{page} from #{cur_version} to #{version}!" },
              fail: Proc.new { "Failed to edit #{page}" },
              error: Proc.new { |e| "Failed! Error code: #{e.message}" }
            }
          end
        end

        # Updates the mod version for the given mod on the wiki.
        # @param msg [Cinch::Message]
        # @param mod [String] The mod to update on the wiki.
        # @param version [String] The new mod version.
        def update(msg, mod, version)
          current = get_current_version(mod)
          if current == version
            msg.reply("#{version} is already the current version")
          elsif current.nil?
            msg.reply('That page does not have the param, trying to make one.'.freeze)
            add_new_param(mod, msg, version)
          else
            update_param(mod, msg, current, version)
          end
        end
      end
    end
  end
end
