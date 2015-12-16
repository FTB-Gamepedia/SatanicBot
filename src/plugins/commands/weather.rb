require 'simple_geolocator'

module Plugins
  module Commands
    class Weather
      include Cinch::Plugin

      match(/weather (.+)/i, method: :weather)
      match(/forecast (.+)/i, method: :forecast)
      match(/weather$/i, method: :weather_self)
      match(/forecast$/i, method: :forecast_self)

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

        now = Time.now
        precip_chance = weather.chance_of_precipitation(now, now, location)

        unless failed
          name = conditions[:full_name]
          condition = conditions[:weather]
          temp = conditions[:formatted_temperature]
          feel = conditions[:formatted_feelslike]
          humidity = "#{conditions[:humidity]}%"
          date = conditions[:updated]
          message = "#{name}: #{condition} | "
          if temp == feel
            message << "#{temp}, and feels like it! "
          else
            message << "#{temp}, but feels like #{feel}"
          end

          message << "Humidity: #{humidity} | #{precip_chance}% chance of " \
                     "precipitation | #{date}"
        end

        unless alerts.nil?
          alerts.each do |a|
            desc = Cinch::Formatting.format(:red, a[:description])
            message << " | #{desc} until #{a[:expires]}"
          end
        end
        msg.reply(message)
      end

      def get_location_by_ip(ip)
        region_hash = SimpleGeolocator.region(ip)
        region = region_hash[:code]
        city = SimpleGeolocator.city(ip)
        location = "#{city}, #{region}"
        return location
      end

      def weather_self(msg)
        ip = msg.user.host
        location = get_location_by_ip(ip)
        weather(msg, location)
      end

      def forecast(msg, location)
        msg.reply("Getting forecast for #{location}...")
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

      def forecast_self(msg)
        ip = msg.user.host
        location = get_location_by_ip(ip)
        forecast(msg, location)
      end
    end
  end
end
