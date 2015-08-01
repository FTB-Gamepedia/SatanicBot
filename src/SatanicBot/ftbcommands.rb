require 'mediawiki_api'
require 'benchmark'
require_relative 'wikiutils'
require_relative 'generalutils'

$mw = MediawikiApi::Client.new('http://ftb.gamepedia.com/api.php')
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new('http://ftb.gamepedia.com/api.php')

def edit_modlist(mod_name, page)
  if $other_mw.get_wikitext(page) == true
    text = $other_mw.get_wikitext(page)
    if /{{L|#{mod_name}}}/ =~ text
      exit 0
    else
      firstline = "<noinclude><translate><!--T:1-->"
      secondline = "</noinclude>"
      thirdline = "<noinclude></translate></noinclude>"
      lowertext = text.downcase
      pagelines = lowertext.split("\n")
      pagelines.push("{{L|#{mod_name}}}{{*}}")
      pagelines.sort
      pagelines.delete("<noinclude><translate><!--T:1-->")
      pagelines.delete("</noinclude>")
      pagelines.delete("<noinclude></translate></noinclude>")
      if pagelines.at(pagelines.length) == "{{L|#{mod_name}}}{{*}}"
        pagelines[pagelines.length].gsub("}}{{*}}", "}}")
      end
      newpage = pagelines.join("\n")
      newpage.prepend("#{firstline}\n#{secondline}\n")
      newpage += "\n#{thirdline}"
      $mw.edit(title: page, text: newpage, bot: 1, summary: "Adding #{mod_name}")
      exit 1
    end
  else
    exit 0
  end
end

def edit_modmodule(abbrv, mod_name)
  page = "Module:Mods/list"
  text = $other_mw.get_wikitext(page)
  if /\s#{abbrv} = / =~ text || /\{\'#{mod_name}\'/ =~ text
    exit 0
  else
    text = text.gsub(/local modsByAbbrv = \{/, "local modsByAbbrv = {\n    #{abbrv} = {#{mod_name}, [=[<translate>#{mod_name}</translate>]=]},")
    $mw.edit(title: page, text: text, bot: 1, summary: "Adding #{mod_name}")
    exit 1
  end
end

def add_navbox(navbox, content)
  page = "Template:Navbox List"
  text = $other_mw.get_wikitext(page)
  if /\{\{Tl\|Navbox #{navbox}\}\}/ =~ text || /\{\{L\|#{content}\}\}/ =~ text
    exit 0
  else
    text = text.gsub(/\|\}/, "|-\n| {{Tl|Navbox #{navbox}}} || {{L|#{content}}} ||\n|}")
    $mw.edit(title: page, text: text, bot: 1, summary: "Added the #{content} navbox (Navbox #{navbox})")
    exit 1
  end
end

def create_mod_cat(name, type)
  if $other_mw.get_wikitext("Category:#{name}") == false
    if type == "major"
      $mw.create_page("Category:#{name}", "[[Category:Mod categories]]\n[[Category:Mods]]")
      exit 1
    elsif type == "minor"
      $mw.create_page("Category:#{name}", "[[Category:Mod categories]]\n[[Category:Minor Mods]]")
      exit 1
    else
      exit 0
    end
  else
    exit 0
  end
end

def does_page_exit(page)
  if $other_mw.get_wikitext(page) == true then exit 1 else exit 0 end
end

def upload(url, *filename)
  if defined? filename
    $mw.upload(filename: filename, url: url)
    exit 1
  else
    filename = url.split('/')[-1]
    $mw.upload(filename: filename, url: url)
    exit 1
  end
end

def get_contribs(username)
  if $other_mw.get_user_info(username, 'editcount') == true
    JSON.parse($other_mw.get_user_info(username, 'editcount'))["query"]["users"].each do |userid, data|
      $userid = userid
      break
    end
    count = JSON.parse($other_mw.get_user_info(username, 'editcount'))["query"]["users"][$userid]["name"]["editcount"]
    exit count
  else
    exit 'nouser'
  end
end

def get_registration_date(username)
  if $other_mw.get_user_info(username, 'registration') == true
    JSON.parse($other_mw.get_user_info(username, 'registration'))["query"]["users"].each do |userid, data|
      $userid = userid
      break
    end
    count = JSON.parse($other_mw.get_user_info(username, 'registration'))["query"]["users"][$userid]["name"]["registration"]
    countarray = count.split("T")
    exit countarray[0]
  else
    exit 0
  end
end

def update_mod_version(title, version)
  text = $other_mw.get_wikitext(title)
  if /version=/ =~ text || /version =/ =~ text
    if /version=#{version}/ !~ text and /version =#{version}/ !~ text
      text = text.gsub(/version=.*/, "version=#{version}")
      text = text.gsub(/version =.*/, "version=#{version}")
      $mw.edit(title: title, text: text, bot: 1, summary: 'Update vesion.')
      exit 1
    else
      exit 0
    end
  else
    exit 0
  end
end

case ARGV[0]
when 'modlist'
  edit_modlist(ARGV[1], ARGV[2])
when 'modmodule'
  edit_modmodule(ARGV[1], ARGV[2])
when 'nav'
  add_navbox(ARGV[1], ARGV[2])
when 'cat'
  create_mod_cat(ARGV[1], ARGV[2])
when 'check'
  does_page_exist(ARGV[1])
when 'upload'
  if defined? ARGV[2]
    upload(ARGV[1], ARGV[2])
  else
    upload(ARGV[1])
  end
when 'contribs'
  get_contribs(ARGV[1])
when 'registrationdate'
  get_registration_date(ARGV[1])
when 'updateversion'
  update_mod_version(ARGV[1], ARGV[2])
end
exit
