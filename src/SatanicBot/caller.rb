require_relative 'ftbcommands'

$commands = Wiki::Commands.new(ARGV[0])
case ARGV[1]
when 'modlist'
  ret = $commands.edit_modlist(ARGV[2], ARGV[3])
  exit ret
when 'modmodule'
  ret = $commands.edit_modmodule(ARGV[2], ARGV[3])
  exit ret
when 'nav'
  ret = $commands.add_navbox(ARGV[2], ARGV[3])
  exit ret
when 'cat'
  ret = $commands.create_mod_cat(ARGV[2], ARGV[3])
  exit ret
when 'check'
  exit $commands.does_page_exist(ARGV[2])
when 'upload'
  if defined? ARGV[3]
    ret = $commands.upload(ARGV[2], ARGV[3])
    exit ret
  else
    ret = $commands.upload(ARGV[2])
    exit ret
  end
when 'contribs'
  ret = $commands.get_contribs(ARGV[2])
  exit ret
when 'registrationdate'
  ret = $commands.get_registration_date(ARGV[2])
  exit ret
when 'updateversion'
  ret = $commands.update_mod_version(ARGV[2], ARGV[3])
  exit ret
end
