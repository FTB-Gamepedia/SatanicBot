require 'mediawiki_api'
require_relative 'wikiutils'
require_relative 'generalutils'

def edit(page_name, nav_type)
  JSON.parse($other_mw.get_wikitext(page_name))["query"]["pages"].each do |revid, data |
    $revid = revid
    break
  end
  text = JSON.parse($other_mw.get_wikitext(page_name))["query"]["pages"][$revid]["revisions"][0]["*"]
  case nav_type
    when "Races"
      @text = text.gsub(/\{\{[Rr]aces\}\}/, "{{Navbox Races}}")
    when "Skills"
      @text = text.gsub(/\{\{[Ss]kills\}\}/, "{{Navbox Skills}}")
    when "Cities"
      @text = text.gsub(/\{\{[Cc]ity nav\}\}/, "{{Navbox Cities}}")
    when "Houses"
      @text = text.gsub(/\{\{[Hh]ouses\}\}/, "{{Navbox Houses}}")
    $mw.edit(title: page_name, text: text)
  end
end

$mw = MediawikiApi::Client.new('http://skyrim.gamepedia.com/api.php')
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new('http://skyrim.gamepedia.com/api.php')

puts "Which type of navbox would you like to change?\n"
nav_type = gets
edit('User:TheSatanicSanta/Sandbox/BotTesting', nav_type) # Change this eventually.

def get_file(nav_type)
  case nav_type
    when "Races"
      File.open('../info/races.txt', 'r') do |file_handle|
        file_handle.each_line do |line|
          edit(line, "Races")
        end
      end
    when "Skills"
      File.open('../info/skills.txt', 'r') do |file_handle|
        file_handle.each_line do |line|
          edit(line, "Skills")
        end
      end
    when "Cities"
      File.open('../info/cities.txt', 'r') do |file_handle|
        file_handle.each_line do |line|
          edit(line, "Cities")
        end
      end
    when "Houses"
      File.open('../info/houses.txt', 'r') do |file_handle|
        file_handle.each_line do |line|
          edit(line, "Houses")
        end
      end
    else
      abort('What the hell?')
  end
end
