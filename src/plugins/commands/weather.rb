module Plugins
  module Commands
    class Weather
      include Cinch::Plugin

      match(/weather (.+)/i, method: :weather)
      match(/forecast (.+)/i, method: :forecast)

      def weather(msg, location)
        weather = LittleHelper.init_weather
        conditions = weather.conditions(location)
        failed = false

        if conditions.is_a?(String)
          failed = true
          message = "Error getting conditions: #{conditions}"
        end

        alerts = weather.alerts(location)

        if alerts.is_a?(String)
          failed = true
          message =
            if message.nil?
              "Error getting alerts: #{alerts}"
            else
              " | Error getting alerts: #{alerts}"
            end
        end


        if failed == false
          message = "#{conditions[:full_name]}: #{conditions[:weather]} | " \
                    "#{conditions[:formatted_temperature]} | Humidity: " \
                    "#{conditions[:humidity]}% | #{conditions[:updated]}"
        end
        
        unless alerts.nil?
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

        if forecast.is_a?(String)
          msg.reply("Error getting forecast: #{forecast}")
        else
          forecast.each do |_, f|
            msg.reply("#{f[:weekday_name]}: #{f[:text]}")
          end
        end
      end
    end
  end
end
