require 'simple_geolocator'
require 'openweathermap'
require_relative 'base_command'

module Plugins
  module Commands
    class Weather < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Provides weather information for the given place. 1 optional arg: $weather [place], if not provided' \
                ' it will use the location of the command sender using IP geolocation.',
          plugin_name: 'weather')
      set(help: 'Provides forecast information for the next 3 days including nights. 1 optional arg: $forecast ' \
                '[place], if not provided it will use the locaiton of the command sender using IP geolocation.',
          plugin_name: 'forecast')
      match(/weather (.+)/i, method: :weather)
      match(/forecast (.+)/i, method: :forecast)
      match(/weather$/i, method: :weather_self)
      match(/forecast$/i, method: :forecast_self)

      FORMAT = '%B %e %Y %H:%M:%S %z'.freeze

      # Gets the current weather conditions for the location.
      # @param msg [Cinch::Message]
      # @param location [String] The location to get the weather for.
      def weather(msg, location)
        begin
          current = LittleHelper::WEATHER.current(location)
        rescue OpenWeatherMap::Exceptions::UnknownLocation => e
          msg.reply(e.message)
          return
        rescue
          msg.reply("Error occurred trying to get weather information for #{location}, please try again.")
          return
        end

        # TODO: Alerts. OpenWeatherMap-Ruby does not have support for alerts at the moment.
        # alerts = LittleHelper::WEATHER.alerts(location)

        name = "#{current.city.name}, #{current.city.country}"
        description = "#{current.weather_conditions.emoji} #{current.weather_conditions.description}"
        # As per the WEATHER initialization, we use C. This has to be converted to F.
        temp_max_c = current.weather_conditions.temp_max.round(2)
        temp_min_c = current.weather_conditions.temp_min.round(2)
        temp_c = current.weather_conditions.temperature.round(2)
        temp_max_f = to_f(temp_max_c).round(2)
        temp_min_f = to_f(temp_min_c).round(2)
        temp_f =  to_f(temp_c).round(2)
        temp = "#{temp_c}°C (#{temp_f}°F) (#{temp_min_c}°C — #{temp_max_c}°C) (#{temp_min_f}°F — #{temp_max_f}°F)"

        humidity = "#{current.weather_conditions.humidity.round(2)}%"
        date = current.weather_conditions.time
        message = "#{name}: #{description} | #{temp} | Humidity: #{humidity} | #{date.strftime(FORMAT)}"

        # TODO: See above.
        # alerts.each do |a|
        #   desc = Cinch::Formatting.format(:red, a[:description])
        #   message << " | #{desc} until #{a[:expires].strftime(FORMAT)}"
        # end
        msg.reply(message)
      end

      # Geolocates the IP to a given location, in City, Region, Country syntax.
      # @param ip [String] The IP to geolocate
      def get_location_by_ip(ip)
        location = SimpleGeolocator.get(ip)
        "#{location.city}, #{location.region.code}, #{location.country.code}"
      end

      # Gets the weather conditions for the user's location by their IP.
      # @param msg [Cinch::Message]
      def weather_self(msg)
        ip = msg.user.host
        location = get_location_by_ip(ip)
        weather(msg, location)
      end

      # Gets the forecast information for the next 3 days (including nights) in
      #   the given location.
      # @param msg [Cinch::Message]
      # @param location [String] The location to get the information for.
      def forecast(msg, location)
        msg.reply("Getting forecast for #{location}...")

        begin
          forecast = LittleHelper::WEATHER.forecast(location)
        rescue OpenWeatherMap::Exceptions::UnknownLocation => e
          msg.reply(e.message)
          return
        rescue
          msg.reply("Error occurred trying to get forecast information for #{location}, please try again.")
          return
        end

        amalgamated_forecast = {}
        forecast.forecast.each do |conditions|
          weekday = conditions.time.strftime('%A')
          amalgamated_forecast[weekday] = [] unless amalgamated_forecast.keys.include?(weekday)
          str = "#{conditions.emoji} #{conditions.description} #{conditions.temperature.round(2)}°C (#{to_f(conditions.temperature).round(2)}°F)"
          amalgamated_forecast[weekday] << str unless amalgamated_forecast[weekday].include?(str)
        end

        amalgamated_forecast.each do |weekday, strs|
          msg.reply("#{weekday}: #{strs.join(' → ')}")
        end
      end

      # Gets the forecast information for the next 3 days (including nights) in
      #   the users location, by first getting the location of their IP.
      # @param msg [Cinch::Message]
      def forecast_self(msg)
        ip = msg.user.host
        location = get_location_by_ip(ip)
        forecast(msg, location)
      end

      # Converts c to fahrenheit
      # @param c [Number] celsius
      def to_f(c)
        (1.8 * c) + 32
      end
    end
  end
end
