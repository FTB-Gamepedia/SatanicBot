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

def change_backlinks(category, new_category_name)
  backlinkarray = []
  JSON.parse($other_mw.get_backlinks("Category:#{category}"))["query"]["backlinks"].each do |title|
    backlinkarray.push(title["title"])
  end
  backlinkarray.each do |i|
    if $other_mw.get_wikitext(i) == false
      puts i + " could not be edited because its content is nil. Continuing...\n"
      next
    else
      text = $other_mw.get_wikitext(i)
      text = text.gsub(/\{\{C\|#{category}/, "\{\{C\|#{new_category_name}")
      text = text.gsub(/#{category}/, "#{new_category_name}")
      $mw.edit(title: i, text: text, bot: 1, summary: "Changing #{category} to #{new_category_name}")
      puts "#{i} has been edited.\n"
    end
  end
end

change_pages("Category:Passive Animals", "Category:Passive Creatures")
change_pages("Category:Angry Monsters", "Category:Hostile Creatures")
change_pages("Category:Neutral Animals", "Category:Neutral Creatures")
change_backlinks("Passive Animals", "Passive Creatures")
change_backlinks("Angry Monsters", "Hostile Creatures")
change_backlinks("Neutral Animals", "Neutral Creatures")
exit
