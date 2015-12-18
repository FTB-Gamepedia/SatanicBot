require 'cinch'

module Plugins
  class Logger
    include Cinch::Plugin

    listen_to(:connect, method: :setup)
    listen_to(:disconnect, method: :cleanup)
    listen_to(:channel, method: :log_public_message)
    listen_to(:private, method: :log_private_message)
    listen_to(:action, method: :log_action)
    listen_to(:notice, method: :log_notice)
    timer(60, method: :check_time)

    # Prepares for logging. Creates all the format strings. Creates/opens all
    #   the channel files. User files will be created when necessary. Unsure
    #   about the parameters.
    def setup(*)
      @file_format = "#{Dir.pwd}/logs/%{channel}-%{year}-%{month}-%{day}.log"
      @time_format = '%H:%M:%S'
      @log_format = "[%{time}] <%{nick}>: %{msg}\n"
      @action_format = "[%{time}] %{nick} %{action}\n"
      @notice_format = "[%{time}] *%{nick}* %{notice}\n"
      @last_time_check = Time.now
      @log_files = {}
      LittleHelper::CHANNELS.each do |channel|
        name = format(@file_format,
                      channel: channel,
                      year: @last_time_check.year,
                      month: @last_time_check.month,
                      day: @last_time_check.day)
        file = File.file?(name) ? File.open(name, 'a') : File.new(name, 'a')
        @log_files[channel] = file
      end
    end

    # Clears up all the stuff. Closes all the files and clears the array. Unsure
    #   about the parameters.
    def cleanup(*)
      @log_files.each do |_, file|
        file.close
      end
      @log_files.clear
    end

    # Checks whether the current day is the same as the time when it was last
    #   set. It is set in #check_time as well as #setup. Called every 60 seconds
    def check_time
      time = Time.now
      cleanup if time.day != @last_time_check.day
      @last_time_check = time
      setup
    end

    # Logs a public message that is not an ACTION or a NOTICE.
    # @param msg [Cinch::Message] The message object sent by the event.
    def log_public_message(msg)
      return if msg.action?
      return if msg.command == 'NOTICE'
      hash = {
        nick: msg.user.name,
        msg: msg.message
      }
      log_general(msg.channel, hash)
    end

    # Logs a private message that is not an action or sent by the network.
    # @param msg [Cinch::Message] See #log_public_message
    def log_private_message(msg)
      return if msg.action?
      return if msg.user.nil?
      hash = {
        nick: msg.user.name,
        msg: msg.message
      }
      log_general(msg.user.authname, hash)
    end

    # Logs an ACTION or /me.
    # @param msg [Cinch::Message] See #log_public_message
    def log_action(msg)
      prefix = msg.channel.nil? ? msg.user.authname : msg.channel
      hash = {
        nick: msg.user.name,
        action: msg.action_message
      }
      log_general(prefix, hash, @action_format)
    end

    # Logs a NOTICE created by a user.
    # @param msg [Cinch::Message] See #log_public_message
    def log_notice(msg)
      return if msg.user.nil?
      prefix = msg.channel.nil? ? msg.user.authname : msg.channel
      hash = {
        nick: msg.user.name,
        notice: msg.message
      }
      log_general(prefix, hash, @notice_format)
    end

    private

    # Logs to a file based on the parameters passed.
    # @param prefix [String] The prefix to the file name. This is typically
    #   either the channel name or username.
    # @param format_hash [Hash] The hash used to format the string. The time
    #   key will never need to be set manually, as it is done first thing in the
    #   method. Just set all the other options needed by the format.
    # @param format_str [String] The string to format. Use one of the values in
    #   #setup.
    def log_general(prefix, format_hash, format_str = @log_format)
      format_hash[:time] = Time.now.strftime(@time_format)
      name = format(@file_format,
                    channel: prefix,
                    year: @last_time_check.year,
                    month: @last_time_check.month,
                    day: @last_time_check.day)
      file = File.file?(name) ? File.open(name, 'a') : File.new(name, 'a')
      @log_files[prefix] = file
      @log_files[prefix].puts(format(format_str, format_hash))
    end
  end
end
