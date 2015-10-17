module Plugins
  module Commands
    class Weather
      include Cinch::Plugin

      match(/weather (.+)/i, method: :weather)
      match(/forecast (.+)/i, method: :forecast)

      def weather(msg, location)
        weather = LittleHelper.init_weather
        conditions = weather.conditions(location)
        msg.reply("#{conditions[:full_name]}: #{conditions[:weather]} | " \
                  "#{conditions[:formatted_temperature]} | Humidity: " \
                  "#{conditions[:humidity]}% | #{conditions[:updated]}")
      end

      def forecast(msg, location)
        weather = LittleHelper.init_weather
        forecast = weather.simple_forecast(location)
        forecast.each do |_, f|
          msg.reply("#{f[:weekday_name]}: #{f[:text]}")
        end
      end
    end
  end
end
