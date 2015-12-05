require 'cinch'

module Plugins
  module Commands
    class Log
      include Cinch::Plugin

      set(prefix: /(.*)/)
      match(/(.*)/)

      def execute(msg)
        time = Time.now
        file_name = "#{Dir.pwd}/#{msg.channel}-#{time.year}-#{time.month}-" \
                    "#{time.day}.log"
        if File.file?(file_name)
          open(file_name, 'a') do |f|
            f.puts("[#{time.hour}:#{time.min}:#{time.sec}]<#{msg.user.nick}> " \
                   "#{msg.message}\n")
          end
        else
          File.new(file_name, 'a') do |f|
            f.puts("## Logging start at #{time.hour}:#{time.min}:#{time.sec} " \
                   "#{time.zone}\n")
            f.puts("[#{time.hour}:#{time.min}:#{time.sec}]<#{msg.user.nick}> " \
                   "#{msg.message}\n")
          end
        end
      end
    end
  end
end
