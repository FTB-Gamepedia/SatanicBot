require 'simple_geolocator'
require 'weatheruby'

module Plugins
  module Commands
    class Weather
      include Cinch::Plugin

      match(/weather (.+)/i, method: :weather)
      match(/forecast (.+)/i, method: :forecast)
      match(/weather$/i, method: :weather_self)
      match(/forecast$/i, method: :forecast_self)

      WEATHER_DOC = 'Provides weather information for the given place. 1 ' \
                    'optional arg: $weather <place>, if not provided it will ' \
                    "use the user's IP address using simple_geolocator".freeze
      FORECAST_DOC = 'Provides forecast information for the enxt 3 days, ' \
                     'including nights. 1 optional arg: $forecast <place>, ' \
                     "if not provided it will use the user's IP address using simple_geolocator".freeze
      Variables::NonConstants.add_command('weather', WEATHER_DOC)
      Variables::NonConstants.add_command('forecast', FORECAST_DOC)

      # Gets the current weather conditions for the location.
      # @param msg [Cinch::Message]
      # @param location [String] The location to get the weather for.
      def weather(msg, location)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        begin
          conditions = LittleHelper::WEATHER.conditions(location)
        rescue Weatheruby::WeatherError => e
          msg.reply(e.message)
          return
        end

        alerts = LittleHelper::WEATHER.alerts(location)

        now = Time.now
        precip_chance = LittleHelper::WEATHER.chance_of_precipitation(now, now, location)

        name = conditions[:full_name]
        condition = conditions[:weather]
        temp = conditions[:formatted_temperature]
        feel = conditions[:formatted_feelslike]
        humidity = "#{conditions[:humidity]}%"
        date = conditions[:updated]
        message = "#{name}: #{condition} | "

        # Appending `message` based on temp_feel in any other way would make for terrible styling.
        # rubocop:disable Style/ConditionalAssignment
        if temp == feel
          message << "#{temp}, and feels like it!"
        else
          message << "#{temp}, but feels like #{feel}"
        end
        # rubocop:enable Style/ConditionalAssignment

        message << " | Humidity: #{humidity} | #{precip_chance}% chance of precipitation | #{date}"

        alerts.each do |a|
          desc = Cinch::Formatting.format(:red, a[:description])
          message << " | #{desc} until #{a[:expires]}"
        end
        msg.reply(message)
      end

      # Geolocates the IP to a given location, in City, Region syntax.
      # @param ip [String] The IP to geolocate
      def get_location_by_ip(ip)
        region = SimpleGeolocator.get(ip).region
        city = SimpleGeolocator.get(ip).city
        "#{city}, #{region.code}"
      end

      # Gets the weather conditions for the user's location by their IP.
      # @param msg [Cinch::Message]
      def weather_self(msg)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        ip = msg.user.host
        location = get_location_by_ip(ip)
        weather(msg, location)
      end

      # Gets the forecast information for the next 3 days (including nights) in
      #   the given location.
      # @param msg [Cinch::Message]
      # @param location [String] The location to get the information for.
      def forecast(msg, location)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        msg.reply("Getting forecast for #{location}...")
        forecast = LittleHelper::WEATHER.simple_forecast(location)

        forecast.each do |_, f|
          msg.reply("#{f[:weekday_name]}: #{f[:text]}")
        end
      end

      # Gets the forecast information for the next 3 days (including nights) in
      #   the users location, by first getting the location of their IP.
      # @param msg [Cinch::Message]
      def forecast_self(msg)
        return if Variables::Constants::IGNORED_USERS.include?(msg.user.nick)
        ip = msg.user.host
        location = get_location_by_ip(ip)
        forecast(msg, location)
      end
    end
  end
end
