require 'mediawiki/butt'
require_relative '../variables'

# setup parameters.
start = [
  '#inputtitle',
  '#input',
  '#usetitle',
  '#use',
  '#storagetitle',
  '#storage',
  '#outputtitle',
  '#output',
  '#productiontitle',
  '#production'
]

terrible_parameters = []

time = 0
5.times do
  time += 1
  start.each do |param|
    terrible_parameters << param.sub('#', time.to_s)
  end
end

puts 'Finished setting up the array of horrible parameters.'

@mw = MediaWiki::Butt.new(Variables::Constants::WIKI_URL)
username = Variables::Constants::WIKI_USERNAME
password = Variables::Constants::WIKI_PASSWORD
@mw.login(username, password)

puts "Logged in as #{username}"

backlinks = @mw.get_all_transcluders('Template:Infobox', 5000)
puts "#{backlinks.size} backlinks to Template:Infobox were received."

backlinks.each do |i|
  text = @mw.get_text(i)
  terrible_parameters.each do |param|
    if text.include?(param)
      puts "#{i} contains the #{param} parameter."
    end
  end
end

puts 'Finished.'