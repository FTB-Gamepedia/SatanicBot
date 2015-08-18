require 'mediawiki_api'
require_relative '../wikiutils'
require_relative '../generalutils'

def change_pages(category, new_category_name)
  pagearray = []
  JSON.parse($other_mw.get_pages_in_category(category))["query"]["categorymembers"].each do |i|
    #pagearray.push(i["title"])
    title = i["title"]
    text = $other_mw.get_wikitext(title)
    if text != false
      text = text.gsub(/#{category}/, new_category_name)
      $mw.edit(title: title, text: text, bot: 1, summary: "Changing #{category} to #{new_category_name}")
      puts "#{title} has been edited.\n"
    else
      puts "#{title} could not be edited. Content found as nil. Continuing without editing...\n"
      next
    end
  end
end

def change_backlinks(category, new_category_name)
  backlinkarray = []
  JSON.parse($other_mw.get_backlinks("Category:#{category}"))["query"]["backlinks"].each do |title|
    next if title != "Feed The Beast Wiki:Staff's Noticeboard"
    backlinkarray.push(title["title"])
  end
  backlinkarray.each do |i|
    if $other_mw.get_wikitext(i) == false
      puts i + " could not be edited because its content is nil. Continuing...\n"
      next
    else
      text = $other_mw.get_wikitext(i)
      text = text.gsub(/\{\{C\|#{category}/, "\{\{C\|#{new_category_name}")
      text = text.gsub(/\[\[\:#{category}/, "\[\[\:#{new_category_name}")
      $mw.edit(title: i, text: text, bot: 1, summary: "Changing #{category} to #{new_category_name}")
      puts "#{i} has been edited.\n"
    end
  end
end

puts "Which Wiki would you like to edit?\n"
wiki = gets.chomp
puts "How many categories would you like to change this session?\n"
num = gets.chomp.to_i
initial = 0

puts "Signing into #{wiki}..."
$mw = MediawikiApi::Client.new("http://#{wiki}.gamepedia.com/api.php")
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new("http://#{wiki}.gamepedia.com/api.php")
puts "Successfully signed into #{wiki}!"

if num.is_a? Numeric
  while initial < num
    puts "Which category would you like to change?\n"
    cat = gets.chomp
    puts "What would you like to replace the category with?\n"
    new_cat = gets.chomp

    change_pages("Category:#{cat}", "Category:#{new_cat}")
    change_backlinks(cat, new_cat)
    initial += 1
  end
  puts "Successfully completed changing categories provided by user. Exiting with exit code 0."
else
  puts "SEVERE: NUMBER OF CATEGORIES PROVIDED IS NOT A VALID NUMBER. EXITING WITH EXIT CODE 1"
  exit 1
end
exit 0
