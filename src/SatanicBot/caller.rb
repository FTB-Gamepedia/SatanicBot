require_relative 'ftbcommands'

# Creates a new file in info named 'out.txt' with the content
# @param content [String] The content to add
def new_file(content)
  out = File.open('src/info/out.txt', 'w')
  out.puts("#{content}")
  out.close
end

$commands = Wiki::Commands.new(ARGV[0])
case ARGV[1]
when 'modlist'
  ret = $commands.edit_modlist(ARGV[2], ARGV[3])
  new_file([ret])
when 'modmodule'
  ret = $commands.edit_modmodule(ARGV[2], ARGV[3])
  new_file[ret]
when 'nav'
  ret = $commands.add_navbox(ARGV[2], ARGV[3])
  new_file[ret]
when 'cat'
  ret = $commands.create_mod_cat(ARGV[2], ARGV[3])
  new_file(ret)
when 'check'
  new_file($commands.page_exists?(ARGV[2]))
when 'upload'
  if defined? ARGV[3]
    ret = $commands.upload(ARGV[2], ARGV[3])
    new_file(ret)
  else
    ret = $commands.upload(ARGV[2])
    new_file(ret)
  end
when 'contribs'
  ret = $commands.get_contribs(ARGV[2])
  new_file(ret)
when 'registrationdate'
  ret = $commands.get_registration_date(ARGV[2])
  new_file(ret)
when 'updateversion'
  ret = $commands.update_mod_version(ARGV[2], ARGV[3])
  new_file(ret)
end

exit
