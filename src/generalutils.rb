module GeneralUtils
  module Files
    extend self
    def get_secure(line_num)
      read = IO.readlines(File.expand_path('../SatanicBot/src/info/secure.txt',
                                           Dir.pwd))
      line = read[line_num]
      line.chomp
    end
  end
end
