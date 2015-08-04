require 'mediawiki_api'
require 'benchmark'
require_relative 'wikiutils'
require_relative 'generalutils'

module Wiki
  class Commands
    def initialize(wiki)
      $mw = MediawikiApi::Client.new("http://#{wiki}.gamepedia.com/api.php")
      $mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
      $other_mw = Wiki_Utils::Client.new("http://#{wiki}.gamepedia.com/api.php")
    end

    def edit_modlist(mod_name, page)
      if $other_mw.get_wikitext(page) == true
        text = $other_mw.get_wikitext(page)
        if /{{L|#{mod_name}}}/ =~ text
          return 0
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
          return 1
        end
      else
        return 0
      end
    end

    def edit_modmodule(abbrv, mod_name)
      page = "Module:Mods/list"
      text = $other_mw.get_wikitext(page)
      if /\s#{abbrv} = / =~ text || /\{\'#{mod_name}\'/ =~ text
        return 0
      else
        text = text.gsub(/local modsByAbbrv = \{/, "local modsByAbbrv = {\n    #{abbrv} = {#{mod_name}, [=[<translate>#{mod_name}</translate>]=]},")
        $mw.edit(title: page, text: text, bot: 1, summary: "Adding #{mod_name}")
        return 1
      end
    end

    def add_navbox(navbox, content)
      page = "Template:Navbox List"
      text = $other_mw.get_wikitext(page)
      if /\{\{Tl\|Navbox #{navbox}\}\}/ =~ text || /\{\{L\|#{content}\}\}/ =~ text
        return 0
      else
        text = text.gsub(/\|\}/, "|-\n| {{Tl|Navbox #{navbox}}} || {{L|#{content}}} ||\n|}")
        $mw.edit(title: page, text: text, bot: 1, summary: "Added the #{content} navbox (Navbox #{navbox})")
        return 1
      end
    end

    def create_mod_cat(name, type)
      if $other_mw.get_wikitext("Category:#{name}") == false
        if type == "major"
          $mw.create_page("Category:#{name}", "[[Category:Mod categories]]\n[[Category:Mods]]")
          return 1
        elsif type == "minor"
          $mw.create_page("Category:#{name}", "[[Category:Mod categories]]\n[[Category:Minor Mods]]")
          return 1
        else
          return 0
        end
      else
        return 0
      end
    end

    def does_page_exist(page)
      if $other_mw.get_wikitext(page) == true then return 1 else return 0 end
    end

    def upload(url, *filename)
      if defined? filename
        $mw.upload(filename: filename, url: url)
        return 1
      else
        filename = url.split('/')[-1]
        $mw.upload(filename: filename, url: url)
        return 1
      end
    end

    def get_contribs(username)
      if $other_mw.get_user_info(username, 'editcount') == true
        JSON.parse($other_mw.get_user_info(username, 'editcount'))["query"]["users"].each do |userid, data|
          $userid = userid
          break
        end
        count = JSON.parse($other_mw.get_user_info(username, 'editcount'))["query"]["users"][$userid]["name"]["editcount"]
        return count
      else
        return 'failed'
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
        return countarray[0]
      else
        return 0
      end
    end

    def update_mod_version(title, version)
      text = $other_mw.get_wikitext(title)
      if /version=/ =~ text || /version =/ =~ text
        if /version=#{version}/ !~ text and /version =#{version}/ !~ text
          text = text.gsub(/version=.*/, "version=#{version}")
          text = text.gsub(/version =.*/, "version=#{version}")
          $mw.edit(title: title, text: text, bot: 1, summary: 'Update vesion.')
          return 1
        else
          return 0
        end
      else
        return 0
      end
    end
  end
end
