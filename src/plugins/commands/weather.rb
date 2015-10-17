module Plugins
  module Commands
    class Weather
      include Cinch::Plugin
      # include Cinch::Formatting

      match(/weather (.+)/i, method: :weather)
      match(/forecast (.+)/i, method: :forecast)

      def weather(msg, location)
        weather = LittleHelper.init_weather
        conditions = weather.conditions(location)
        alerts = weather.alerts(location)
        message = "#{conditions[:full_name]}: #{conditions[:weather]} | " \
                       "#{conditions[:formatted_temperature]} | Humidity: " \
                       "#{conditions[:humidity]}% | #{conditions[:updated]}"
        unless alerts.nil?
          alert_hash = {}
          alerts.each do |a|
            desc = Cinch::Formatting.format(:red, a[:description])
            message = message + " | #{desc} until #{a[:expires]}"
          end
        end
        msg.reply(message)
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
