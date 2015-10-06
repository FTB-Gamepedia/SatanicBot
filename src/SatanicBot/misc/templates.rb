require 'mediawiki-butt'
require_relative '../generalutils'

def edit(old, new)
  backlinks = $mw.what_links_here("Template:#{old}")
  backlinks.each do |i|
    if $mw.get_text(i).nil?
      puts "#{i} couldn't be edited because its content is nil. Continuing...\n"
      next
    else
      text = $mw.get_text(i)
      text = text.gsub(/\{\{Tl\|#{old}/, "{{Tl|#{new}}}")
      text = text.gsub(/\{\{#{old}/, "{{#{new}}}")
      text = text.gsub(/\[\[Template:#{old}/, "[[Template:#{new}]]")
      text = text.gsub(/\{\{L\|Template:#{old}/, "{{L|Template:#{new}}}")
      $mw.edit(i, text,
               "Changing #{old} template calls to #{new} template calls.", true)
      puts "#{i} has been edited.\n"
    end
  end
end

puts "Which Wiki would you like to edit?\n"
wiki = gets.chomp
puts "How many temlpate links would you like to change this session?\n"
num = gets.chomp.to_i
initial = 0
puts "Signing into #{wiki}..."
$mw = MediaWiki::Butt.new("http://#{wiki}.gamepedia.com/api.php")
username = GeneralUtils::Files.get_secure(0).chomp
password = GeneralUtils::Files.get_secure(1).chomp
$mw.login(username, password)
puts "Successfully signed into #{wiki}!"

if num.is_a? Numeric
  while initial < num
    puts "Which template would you like to change?\n"
    template = gets.chomp
    puts "What would you like to replace the template with?\n"
    new_template = gets.chomp

    edit(template, new_template)
    initial += 1
  end
  puts 'Successfully completed changing template links provided by user.' \
       ' Exiting with exit code 0.'
else
  puts 'SEVERE: NUMBER OF TEMPLATES PROVIDED IS NOT A VALID NUMBER.' \
       ' EXITING WITH EXIT CODE 1'
  exit 1
end
exit 0
