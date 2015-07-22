require 'mediawiki_api'
require_relative 'wikiutils'
require_relative 'generalutils'

$mw = MediawikiApi::Client.new('http://ftb.gamepedia.com/api.php')
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new('http://ftb.gamepedia.com/api.php')

def edit(page_name)
  backlinkarray = []
  JSON.parse($other_mw.get_backlinks(page_name))["query"]["backlinks"].each do |title|
    backlinkarray.push(title["title"])
  end
  backlinkarray.each do |i|
    if $other_mw.get_wikitext(i) == false
      puts i + " could not be edited because it's content is nil. Continuing...\n"
      next
    else
      text = $other_mw.get_wikitext(i)
      text = text.gsub(/\{\{[Uu]\|SatanicSanta/, "{{U|TheSatanicSanta")
      text = text.gsub(/\[\[[Uu]ser\:SatanicSanta/, "[[User:TheSatanicSanta")
      text = text.gsub(/\[\[[Uu]ser talk\:SatanicSanta/, "[[User talk:TheSatanicSanta")
      text = text.gsub(/[Ss]pecial\:Contributions\/SatanicSanta/, "Special:Contributions/TheSatanicSanta")
      $mw.edit(title: i, text: text, bot: 1, summary: "Fixing my master's user links")
      puts i + " has been edited.\n"
    end
  end
end

edit("User:SatanicSanta")
edit("User talk:SatanicSanta")
exit
