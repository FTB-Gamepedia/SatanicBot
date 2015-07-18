require 'mediawiki_api'
require_relative 'wikiutils'
require_relative 'generalutils'

$mw = MediawikiApi::Client.new('http://ftb.gamepedia.com/api.php')
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new('http://ftb.gamepedia.com/api.php')

def do_stuff(page, username, comment)
  JSON.parse($other_mw.get_rev_data(page))["query"]["pages"].each do |pageid, data|
    $pageid = pageid
    break
  end
  user = JSON.parse($other_mw.get_rev_data(page))["query"]["pages"][$pageid]["revisions"][0]["user"]
  summary = JSON.parse($other_mw.get_rev_data(page))["query"]["pages"][$pageid]["revisions"][0]["comment"]
  revid = JSON.parse($other_mw.get_rev_data(page))["query"]["pages"][$pageid]["revisions"][0]["revid"]
  if (user == username && summary == comment)
    params = {
      title: page,
      user: username,
      markbot: true,
      summary: "Undoing CBlair91Bot",
      bot: true,
      undo: revid
    }
    if ($mw.edit(params) == false)
      puts "#{page} was not rolled back.\n"
      return
    else
      puts "#{page} was rolled back.\n"
      return
    end
  else
    puts "#{page} was not able to be rolled back. Wrong username or summary for latest revision.\n"
    return
  end
end

File.open('../info/gcrollback.txt', 'r') do |file_handle|
  file_handle.each_line do |line|
    do_stuff(line.chomp, "Cblair91Bot", "dis param is now deprecated")
  end
end
exit
