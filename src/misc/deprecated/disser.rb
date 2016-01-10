require 'mediawiki/butt'
require 'string-utility'
require_relative '../variables'

# This script actually just fucked everything up, so I don't recommend using it for anything. That's why it is deprecated.
def replace(line)
  return line if line !~ /\{\{Gc/
  return line if line =~ /link=none/ || line =~ /dis=false/ || line =~ /dis=true/
  return line.gsub!(/\{\{[Gg]c|mod=(\S+)\|/, '{{Gc|mod=\1|dis=false|')
end

def go(page, summary)
  text = @mw.get_text(page)
  new_text = ''
  text.each_line do |l|
    new_text << replace(l)
  end
  edit = @mw.edit(page, new_text, true, true, summary)
  puts "Edited #{page}: #{edit}"
end

@mw = MediaWiki::Butt.new(Variables::Constants::WIKI_URL)
username = Variables::Constants::WIKI_USERNAME
password = Variables::Constants::WIKI_PASSWORD
@mw.login(username, password)

path = "#{Dir.pwd}/src/info/skits.txt"
file = File.open("#{Dir.pwd}/src//info/input.txt", 'r')
until file.eof?
  go(file.readline.chomp, StringUtility.random_line(path))
end

file.close

print 'Finished.'