require 'mediawiki_api'
require_relative '../wikiutils'
require_relative '../generalutils'

def edit(old, new)
  backlinkarray = []
  JSON.parse($other_mw.get_backlinks("Template:#{old}"))["query"]["backlinks"].each do |title|
    backlinkarray.push(title["title"])
  end
  backlinkarray.each do |i|
    if $other_mw.get_wikitext(i) == false
      puts "#{i} could not be edited because its content is nil. Continuing...\n"
      next
    else
      text = $other_mw.get_wikitext(i)
      text = text.gsub(/\{\{Tl\|#{old}/, "{{Tl|#{new}}}")
      text = text.gsub(/\{\{#{old}/, "{{#{new}}}")
      text = text.gsub(/\[\[Template:#{old}/, "[[Template:#{new}]]")
      text = text.gsub(/\{\{L\|Template:#{old}/, "{{L|Template:#{new}}}")
      $mw.edit(title: i, text: text, bot: 1, summary: "Fixing user links.")
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
$mw = MediawikiApi::Client.new("http://#{wiki}.gamepedia.com/api.php")
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new("http://#{wiki}.gamepedia.com/api.php")
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
  puts "Successfully completed changing template links provided by user. Exiting with exit code 0."
else
  puts "SEVERE: NUMBER OF TEMPLATES PROVIDED IS NOT A VALID NUMBER. EXITING WITH EXIT CODE 1"
  exit 1
end
exit 0
