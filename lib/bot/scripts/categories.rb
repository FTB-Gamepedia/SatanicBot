require 'mediawiki-butt'
require_relative '../variables'

def change_pages(category, new_category_name)
  @mw.get_category_members(category, 5000, 'page|subcat|file').each do |i|
    text = @mw.get_text(i)
    if !text.nil?
      text = text.gsub(/#{category}/, new_category_name)
      @mw.edit(i, text, "Changing #{category} to #{new_category_name}",
               true)
      puts "#{i} has been edited.\n"
    else
      puts "#{i} could not be edited. Content found as nil." \
           " Continuing without editing...\n"
      next
    end
  end
end

def change_backlinks(category, new_category_name)
  backlinks = @mw.what_links_here("Category:#{category}")
  # Remove these when the Category Overhaul is done.
  backlinks.delete('Feed The Beast Wiki:Staff\'s Notceboard')
  backlinks.delete('Template:Category hierarchy')
  backlinks.delete('Template:Category hierarchy/doc')
  backlinks.each do |i|
    if @mw.get_text(i).nil?
      puts "#{i} couldn't be edited because its content is nil. Continuing...\n"
      next
    else
      text = @mw.get_text(i)
      text = text.gsub(/\{\{C\|#{category}/,
                       "{{C|#{new_category_name}")
      text = text.gsub(/\[\[\:#{category}/,
                       "[[:Category:#{new_category_name}")
      @mw.edit(i, text, "Changing #{category} to #{new_category_name}", true)
      puts "#{i} has been edited.\n"
    end
  end
end
@mw = MediaWiki::Butt.new(Variables::Constants::WIKI_URL)
username = Variables::Constants::WIKI_USERNAME
password = Variables::Constants::WIKI_PASSWORD
@mw.login(username, password)
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
