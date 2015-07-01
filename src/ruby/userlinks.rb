require 'mediawiki_api'
require_relative 'wikiutils'
require_relative 'generalutils'

$mw = MediawikiApi::Client.new('http://ftb.gamepedia.com/api.php')
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new('http://ftb.gamepedia.com/api.php')

# This has not yet been tested.
def edit(page_name)
  decoded_json = JSON.decode($other_mw.get_backlinks(page_name))
  backlinks = decoded_json["query"]["backlinks"] do |title|
    title["title"]
  end
  
  backlinks.each do |wlh|
    JSON.parse($other_mw.get_wikitext(wlh))["query"]["pages"].each do |revid, data |
      $revid = revid
      break
    end
    text = JSON.parse($other_mw.get_wikitext(wlh))["query"]["pages"][$revid]["revisions"][0]["*"]
    text = text.gsub(/\{\{U|SatanicSanta/, "{{U|TheSatanicSanta")
    text = text.gsub(/\[\[[Uu]ser:SatanicSanta/, "[[User:TheSatanicSanta")
    text = text.gsub(/\[\[[Uu]ser talk:SatanicSanta/, "[[User talk:TheSatanicSanta")
    $mw.edit(title: wlh, text: text, bot: 1, summary: "Fixing my master's user links")
    puts wlh + " has been edited.\n"
  end
end

edit("User:SatanicSanta")
edit("User talk:SatanicSanta")
exit
