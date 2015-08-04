require_relative 'ftbcommands'

Wiki::Commands.new(ARGV[1])
case ARGV[0]
when 'modlist'
  ret = Wiki::Commands.edit_modlist(ARGV[2], ARGV[3])
  exit ret
when 'modmodule'
  ret = Wiki::Commands.edit_modmodule(ARGV[2], ARGV[3])
  exit ret
when 'nav'
  ret = Wiki::Commands.add_navbox(ARGV[2], ARGV[3])
  exit ret
when 'cat'
  ret = Wiki::Commands.create_mod_cat(ARGV[2], ARGV[3])
  exit ret
when 'check'
  ret = Wiki::Commands.does_page_exist(ARGV[3])
  exit ret
when 'upload'
  if defined? ARGV[3]
    ret = Wiki::Commands.upload(ARGV[2], ARGV[3])
    exit ret
  else
    ret = Wiki::Commands.upload(ARGV[2])
    exit ret
  end
when 'contribs'
  ret = Wiki::Commands.get_contribs(ARGV[2])
  exit ret
when 'registrationdate'
  ret = Wiki::Commands.get_registration_date(ARGV[2])
  exit ret
when 'updateversion'
  ret = Wiki::Commands.update_mod_version(ARGV[2], ARGV[3])
  exit ret
end
