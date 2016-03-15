require 'mediawiki-butt'

def edit(old, new)
  backlinks = @mw.what_links_here(old)
  backlinks.each do |i|
    if @mw.get_text(i).nil?
      puts "#{i} couldn't be edited because its content is nil. Continuing...\n"
      next
    else
      text = @mw.get_text(i)
      text = text.gsub(/\{\{[Uu]\|#{old}/, "{{U|#{new}")
      text = text.gsub(/\[\[[Uu]ser\:#{old}/, "[[User:#{new}")
      text = text.gsub(/\[\[[Uu]ser talk\:#{old}/, "[[User talk:#{new}")
      text = text.gsub(/[Ss]pecial\:Contributions\/#{old}/, "Special:Contributions/#{new}")
      @mw.edit(i, text, 'Fixing user links.', true)
      puts "#{i} has been edited.\n"
    end
  end
end

puts "How many username links would you like to change this session?\n"
num = gets.chomp.to_i
raise ArgumentError unless num.is_a?(Numeric)
@mw = MediaWiki::Butt.new(Variables::Constants::WIKI_URL)
username = Variables::Constants::WIKI_USERNAME
password = Variables::Constants::WIKI_PASSWORD
@mw.login(username, password)

initial = 0
while initial < num
  puts "Which username would you like to change?\n"
  name = gets.chomp
  puts "What would you like to replace the username with?\n"
  new_name = gets.chomp
  raise SecurityError if name == new_name
  edit(name, new_name)
  initial += 1
end
puts 'Successfully completed changing username links provided by user.'
