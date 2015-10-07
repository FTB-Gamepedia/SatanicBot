require 'mediawiki-butt'
require 'benchmark'
require_relative 'generalutils'

module Wiki
  class Commands
    # Note that things must return 1 or 0, or strings because Perl does not
    #   have standard boolean values. Strings are easiest to work with in Perl.
    #   1 = true, 0 = false.

    # Creates a new Wiki::Commands object.
    # @param wiki [String] The Gamepedia wiki name, e.g., ftb, skyrim, minecraft
    def initialize(wiki)
      $mw = MediaWiki::Butt.new("http://#{wiki}.gamepedia.com/api.php")
      username = GeneralUtils::Files.get_secure(0).chomp
      password = GeneralUtils::Files.get_secure(1).chomp
      $mw.login(username, password)
    end

    # Adds the mod to the page
    # @param mod_name [String] The mod to add.
    # @param page [String] The page to add. i.e., 'Template:Mods' or
    #   'Template:Minor Mods'.
    # @return [Int] 1 if successful, 0 if not.
    def edit_modlist(mod_name, page)
      if $mw.get_text(page) == true
        text = $mw.get_text(page)
        if /{{L|#{mod_name}}}/ =~ text
          return 0
        else
          firstline = '<noinclude><translate><!--T:1-->'
          secondline = '</noinclude>'
          thirdline = '<noinclude></translate></noinclude>'
          lowertext = text.downcase
          pagelines = lowertext.split("\n")
          pagelines.push("{{L|#{mod_name}}}{{*}}")
          pagelines.sort
          pagelines.delete('<noinclude><translate><!--T:1-->')
          pagelines.delete('</noinclude>')
          pagelines.delete('<noinclude></translate></noinclude>')

          if pagelines.at(pagelines.length) == "{{L|#{mod_name}}}{{*}}"
            pagelines[pagelines.length].gsub('}}{{*}}', '}}')
          end

          newpage = pagelines.join("\n")
          newpage.prepend("#{firstline}\n#{secondline}\n")
          newpage += "\n#{thirdline}"
          $mw.edit(page, newpage, "Adding #{mod_name}", true)
          return 1
        end
      else
        return 0
      end
    end

    # Edits the Mods/list module by adding a new mod and abbreviation.
    # @param abbrv [String] The abbreviation for the mod.
    # @param mod_name [String] The mod's name.
    # @return [Int] 1 if successful, 0 if not.
    def edit_modmodule(abbrv, mod_name)
      page = 'Module:Mods/list'
      text = $mw.get_text(page)
      if /\s#{abbrv} = / =~ text || /\{\'#{mod_name}\'/ =~ text
        return 'present'
      else
        text = text.gsub(/local modsByAbbrv = \{/,
                         "local modsByAbbrv = {\n    #{abbrv} = {#{mod_name},' \
                         ' [=[<translate>#{mod_name}</translate>]=]},")
        $mw.edit(page, text, "Adding #{mod_name}", true)
        return 'added'
      end
    end

    # Adds a navbox to the navbox list template
    # @param navbox [String] The navbox's name (excluding the Navbox prefix)
    # @param content [String] What the navbox is of.
    #   e.g., 'Flaxbeard's Steam Power'. Basically the title link.
    # @return [Int] 1 if successful, 0 if not.
    def add_navbox(navbox, content)
      page = 'Template:Navbox List'
      text = $mw.get_text(page)
      if /\{\{[Tt]l\|Navbox #{navbox}\}\}/ =~ text ||
         /\{\{[Ll]\|#{content}\}\}/ =~ text
        return 'present'
      else
        addition = "|-\n {{Tl|Navbox #{navbox}}} || {{L|#{content}}} || \n|}"
        text = text.gsub(/\|\}/, addition)
        summary = "Add the #{content} navbox (Navbox #{navbox})"
        $mw.edit(page, text, summary, true)
        return 'success'
      end
    end

    def create_mod_cat(name, type)
      if $other_mw.get_wikitext("Category:#{name}") == false
        if type == 'major'
          text = "[[Category:Mod categories]]\n[[Category:Mods]"
          $mw.create_page("Category:#{name}", text, 'New mod category.')
          return 'success'
        elsif type == 'minor'
          text = "[[Category:Mod categories]]\n[[Category:Minor Mods]"
          $mw.create_page("Category:#{name}", text, 'New minor mod category.')
          return 'success'
        else
          return 'fail'
        end
      else
        return 'fail'
      end
    end

    # Checks if the page exists
    # @param page [String] The page title.
    # @return [String] 'yes' if it exists, 'no' if not.
    def page_exists?(page)
      if $mw.get_text(page).nil?
        return 'no'
      else
        return 'yes'
      end
    end

    # Uploads the file
    # @param url [String] The file to upload.
    # @param filename [String] The desired file name.
    # @return [Int/String] Returns 1 if successful, or the warning if not.
    def upload(url, *filename)
      if defined? filename
        up = $mw.upload(url, filename)
      else
        up = $mw.upload(url)
      end
      if up == true
        return 'success'
      else
        return up
      end
    end

    # Consider getting rid of this and simply doing it via caller.rb for
    #   slightly better performance.
    # Gets the amount of contributions a user has made.
    # @param username [String] The user.
    # @return [String] The return value of get_contrib_count.
    def get_contribs(username)
      $mw.get_contrib_count(username)
    end

    # Gets the date the user registered on.
    # @param username [String] The user.
    # @return [DateTime] The return value of get_registration_time.
    def get_registration_date(username)
      $mw.get_registration_time(username)
    end

    # Updates the mod version on the page.
    # @param title [String] The page name.
    # @param version [String] The new version.
    # @return [String] 'success' if successful, 'fail' if not.
    def update_mod_version(title, version)
      text = $mw.get_text(title)
      if /version=/ =~ text || /version =/ =~ text
        if /version=#{version}/ !~ text && /version =#{version}/ !~ text
          text = text.gsub(/version=.*/, "version=#{version}")
          text = text.gsub(/version =.*/, "version=#{version}")
          $mw.edit(title, text, 'Update vesion.', true)
          return 'success'
        else
          return 'fail'
        end
      else
        return 'fail'
      end
    end
  end
end
