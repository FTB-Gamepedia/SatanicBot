require 'mediawiki_api'
require_relative 'wikiutils'
require_relative 'generalutils'

$mw = MediawikiApi::Client.new('http://skyrim.gamepedia.com/api.php')
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new('http://skyrim.gamepedia.com/api.php')

def get_file_lines(filename, nav_type)
  File.open(filename, 'r') do |file_handle|
    file_handle.each_line do |line|
      edit(line.chomp, nav_type)
    end
  end
end

def determine_file(nav_type)
  case nav_type
    when "Races"
      get_file_lines('../info/races.txt', nav_type)
    when "Skills"
      get_file_lines('../info/skills.txt', nav_type)
    when "Cities"
      get_file_lines('../info/cities.txt', nav_type)
    when "Houses"
      get_file_lines('../info/houses.txt', nav_type)
    else
      abort('What the hell?')
  end
end

def edit(page_name, nav_type)
  JSON.parse($other_mw.get_wikitext(page_name))["query"]["pages"].each do |revid, data |
    $revid = revid
    break
  end
  text = JSON.parse($other_mw.get_wikitext(page_name))["query"]["pages"][$revid]["revisions"][0]["*"]
  case nav_type
    when "Races"
      text = text.gsub(/\{\{[Rr]aces\}\}/, "{{Navbox Races}}")
      $mw.edit(title: page_name, text: text, bot: 1, summary: "Preparing pages for Navbox move.")
    when "Skills"
      text = text.gsub(/\{\{[Ss]kills\}\}/, "{{Navbox Skills}}")
      $mw.edit(title: page_name, text: text, bot: 1, summary: "Preparing pages for Navbox move.")
    when "Cities"
      text = text.gsub(/\{\{[Cc]ity nav\}\}/, "{{Navbox Cities}}")
      $mw.edit(title: page_name, text: text, bot: 1, summary: "Preparing pages for Navbox move.")
    when "Houses"
      text = text.gsub(/\{\{[Hh]ouses\}\}/, "{{Navbox Houses}}")
      $mw.edit(title: page_name, text: text, bot: 1, summary: "Preparing pages for Navbox move.")
  end
  puts page_name + " has been edited.\n"
end

puts "Which type of navbox would you like to change?\n"
nav_type = gets.chomp
determine_file(nav_type)
exit
