require 'mediawiki-butt'
require_relative '../generalutils'

def change_pages(category, new_category_name)
  $mw.get_category_members(category).each do |i|
    text = $mw.get_text(i)
    if !text.nil?
      text = text.gsub(/#{category}/, new_category_name)
      $mw.edit(title, text, "Changing #{category} to #{new_category_name}",
               true)
      puts "#{title} has been edited.\n"
    else
      puts "#{title} could not be edited. Content found as nil." \
           " Continuing without editing...\n"
      next
    end
  end
end

def change_backlinks(category, new_category_name)
  backlinks = $mw.what_links_here("Category:#{category}")
  backlinks.delete('Feed The Beast Wiki:Staff\'s Notceboard')
  backlinks.each do |i|
    if $mw.get_text(i).nil?
      puts "#{i} couldn't be edited because its content is nil. Continuing...\n"
      next
    else
      text = $mw.get_text(i)
      text = text.gsub(/\{\{C\|#{category}/,
                       "\{\{C\|#{new_category_name}")
      text = text.gsub(/\[\[\:#{category}/,
                       "\[\[\:Category\:#{new_category_name}")
      $mw.edit(i, text, "Changing #{category} to #{new_category_name}", true)
      puts "#{i} has been edited.\n"
    end
  end
end

puts "Which Wiki would you like to edit?\n"
wiki = gets.chomp
puts "Signing into #{wiki}..."
$mw = MediaWiki::Butt.new("http://#{wiki}.gamepedia.com/api.php")
username = GeneralUtils::Files.get_secure(0).chomp
password = GeneralUtils::Files.get_secure(1).chomp
$mw.login(username, password)
puts "Successfully signed into #{wiki}.gamepedia.com!\n"
puts "How many categories would you like to change this session?\n"
num = gets.chomp.to_i
initial = 0

if num.is_a? Numeric
  while initial < num
    puts "Which category would you like to change?\n"
    cat = gets.chomp
    puts "What would you like to replace the category with?\n"
    new_cat = gets.chomp
    if cat != new_cat
      change_pages("Category:#{cat}", "Category:#{new_cat}")
      change_backlinks(cat, new_cat)
      initial += 1
    else
      puts 'SEVERE: THE TWO CATEGORIES CANNOT BE THE SAME.' \
           ' EXITIING WITH EXIT CODE 1'
      exit 1
    end
  end
  puts 'Successfully completed changing categories provided by user.' \
       ' Exiting with exit code 0.'
else
  puts 'SEVERE: NUMBER OF CATEGORIES PROVIDED IS NOT A VALID NUMBER.' \
       'EXITING WITH EXIT CODE 1'
  exit 1
end
exit 0
