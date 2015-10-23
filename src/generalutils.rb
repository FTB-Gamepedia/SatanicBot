module GeneralUtils
  module Files
    extend self

    def get_secure(line_num)
      read = File.readlines("#{Dir.pwd}/src/info/secure.txt")
      line = read[line_num]
      line.chomp
    end
  end
end
