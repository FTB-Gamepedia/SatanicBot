require 'mediawiki_api'
require_relative 'wikiutils'
require_relative 'generalutils'

$mw = MediawikiApi::Client.new('http://ftb.gamepedia.com/api.php')
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new('http://ftb.gamepedia.com/api.php')

def change_pages(category, new_category_name)
  pagearray = []
  JSON.parse($other_mw.get_pages_in_category(category))["query"]["categorymembers"].each do |i|
    #pagearray.push(i["title"])
    title = i["title"]
    text = $other_mw.get_wikitext(title)
    text = text.gsub(/#{category}/, new_category_name)
    $mw.edit(title: title, text: text, bot: 1, summary: "Changing #{category} to #{new_category_name}")
    puts "#{title} has been edited.\n"
  end
end

change_pages("Category:Passive Animals", "Category:Passive Creatures")
change_pages("Category:Angry Monsters", "Category:Hostile Creatures")
change_pages("Category:Neutral Animals", "Category:Neutral Creatures")
exit
