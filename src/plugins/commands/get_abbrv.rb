require 'cinch'

module Plugins
  module Commands
    class GetAbbreviation
      include Cinch::Plugin

      match(/getabbrv (.+)/)

      doc = 'Gets either the abbreviation for the given mod, or the mod ' \
            'for the given abbreviation. 1 arg: $getabbrv <thing>'
      Variables::NonConstants.add_command('getabbrv', doc)

      # Gets either the abbreviation of a mod, or the mod using an abbreviation.
      # @param msg [Cinch::Message]
      # @param thing [String] The abbreviation OR mod.
      def execute(msg, thing)
        page = 'Module:Mods/list'
        butt = LittleHelper.init_wiki
        module_text = butt.get_text(page)
        thing.gsub!(/'/) { "\\'" }
        if module_text.include?(thing)
          if module_text.include?("#{thing} = {'")
            match_data = module_text.scan(/#{thing} = {'(.+)',/)
            mod_name = match_data[0][0]
            msg.reply("#{thing} is the abbreviation for #{mod_name}")
          elsif module_text.include?("= {'#{thing}',")
            thing.gsub!(/\'/) { "\\'" }
            match_data = module_text.scan(/([A-Z0-9\-]+) = {'#{thing}',/)
            msg.reply("#{thing} is abbreviated as #{match_data[0][0]}")
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
