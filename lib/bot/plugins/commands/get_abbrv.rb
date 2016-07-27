require 'cinch'

module Plugins
  module Commands
    class GetAbbreviation
      include Cinch::Plugin

      match(/getabbrv (.+)/)

      DOC = 'Gets either the abbreviation for the given mod, or the mod for the given abbreviation. ' \
            '1 arg: $getabbrv <thing>'.freeze
      Variables::NonConstants.add_command('getabbrv', DOC)

      PAGE = 'Module:Mods/list'.freeze

      # Gets either the abbreviation of a mod, or the mod using an abbreviation.
      # @param msg [Cinch::Message]
      # @param thing [String] The abbreviation OR mod.
      def execute(msg, thing)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        butt = LittleHelper.init_wiki
        module_text = butt.get_text(PAGE)
        thing.gsub!(/'/) { "\\'" }
        if module_text.include?(thing)
          if module_text =~ /[\s+]#{thing} = \{\'/
            match_data = module_text.scan(/\s{1,}#{thing} = {'(.+)',/)
            mod_name = match_data[0][0]
            msg.reply("#{thing} is the abbreviation for #{mod_name}")
          elsif module_text.include?("= {'#{thing}',")
            thing.gsub!(/'/) { "\\'" }
            match_data = module_text.scan(/([A-Z0-9\-]+) = {'#{thing}',/)
            msg.reply("#{thing.gsub(/\\'/) { "'" }} is abbreviated as #{match_data[0][0]}")
          else
            msg.reply("#{thing} does not appear to be in the abbreviation " \
                      'list, but there were similar non-exact results. ' \
                      'Try something similar.')
          end
        else
          msg.reply("#{thing} does not appear to be in the abbreviation list.")
        end
      end
    end
  end
end
