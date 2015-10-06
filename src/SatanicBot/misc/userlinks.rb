require 'mediawiki-butt'
require_relative '../generalutils'

def edit(old, new)
  backlinks = $mw.what_links_here(old)
  backlinks.each do |i|
    if $mw.get_text(i).nil?
      puts "#{i} couldn't be edited because its content is nil. Continuing...\n"
      next
    else
      text = $mw.get_text(i)
      text = text.gsub(/\{\{[Uu]\|#{old}/, "{{U|#{new}")
      text = text.gsub(/\[\[[Uu]ser\:#{old}/, "[[User:#{new}")
      text = text.gsub(/\[\[[Uu]ser talk\:#{old}/, "[[User talk:#{new}")
      text = text.gsub(/[Ss]pecial\:Contributions\/#{old}/,
                       "Special:Contributions/#{new}")
      $mw.edit(i, text, 'Fixing user links.', true)
      puts "#{i} has been edited.\n"
    end
  end
end

puts "Which Wiki would you like to edit?\n"
wiki = gets.chomp
puts "How many username links would you like to change this session?\n"
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
    puts "Which username would you like to change?\n"
    name = gets.chomp
    puts "What would you like to replace the username with?\n"
    new_name = gets.chomp

    edit(name, new_name)
    initial += 1
  end
  puts 'Successfully completed changing username links provided by user.' \
       ' Exiting with exit code 0.'
else
  puts 'SEVERE: NUMBER OF USERNAMES PROVIDED IS NOT A VALID NUMBER.' \
       ' EXITING WITH EXIT CODE 1'
  exit 1
end
exit 0
