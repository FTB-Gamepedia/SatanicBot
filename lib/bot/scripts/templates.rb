require 'mediawiki-butt'

def edit(old, new)
  backlinks = @mw.what_links_here("Template:#{old}")
  backlinks.each do |i|
    if @mw.get_text(i).nil?
      puts "#{i} couldn't be edited because its content is nil. Continuing...\n"
      next
    else
      text = @mw.get_text(i)
      text = text.gsub(/\{\{Tl\|#{old}/, "{{Tl|#{new}}}")
      text = text.gsub(/\{\{#{old}/, "{{#{new}}}")
      text = text.gsub(/\[\[Template:#{old}/, "[[Template:#{new}]]")
      text = text.gsub(/\{\{L\|Template:#{old}/, "{{L|Template:#{new}}}")
      @mw.edit(i, text, "Changing #{old} template calls to #{new} template calls.", true)
      puts "#{i} has been edited.\n"
    end
  end
end

puts "How many temlpate links would you like to change this session?\n"
num = gets.chomp.to_i
raise ArgumentError unless num.is_a?(Numeric)

@mw = MediaWiki::Butt.new(Variables::Constants::WIKI_URL)
username = Variables::Constants::WIKI_USERNAME
password = Variables::Constants::WIKI_PASSWORD
@mw.login(username, password)

initial = 0
while initial < num
  puts "Which template would you like to change?\n"
  template = gets.chomp
  puts "What would you like to replace the template with?\n"
  new_template = gets.chomp
  raise SecurityError if template == new_template
  edit(template, new_template)
  initial += 1
end
puts 'Successfully completed changing template links provided by user.'
