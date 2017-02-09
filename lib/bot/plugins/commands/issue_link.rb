require 'cinch'
require 'octokit'
require 'isgd'
require_relative 'base_command'

module Plugins
  module Commands
    class IssueLink < BaseCommand
      include Cinch::Plugin
      ignore_ignored_users

      match(/([\d]+)/, method: :default_repo, prefix: /\#/)

      # TODO: Help/doc info.

      # Creates a message based on the information given about the issue.
      # @param state [String] The state of the issue (open/closed)
      # @param title [String] The issue's title.
      # @param number [String] The issue number.
      # @return [String] The formatted message.
      def form_message(state, title, labels, number)
        if labels.empty?
          "\"#{title}\" ##{number}, is #{state}."
        else
          "\"#{title}\" ##{number}, is #{state}, with the following labels: #{labels.join(', ')}"
        end
      end

      # Replies to the message with the formatted full issue message.
      # @param msg [Cinch::Message]
      # @param repo [String] The full repository.
      # @param issue_num [Integer] The issue number.
      def reply(msg, repo, issue_num)
        begin
          issue = Octokit.issue(repo, issue_num)
          state = issue[:state]
          title = issue[:title]
          labels = []
          issue[:labels].each do |l|
            labels << l[:name]
          end
          milestone = issue&.[](:milestone)&.[](:title)
          message = "\"#{title}\" ##{issue_num}, is #{state}"
          unless labels.empty?
            message << ", with the following labels: #{labels.join(', ')}"
          end
          unless milestone.nil?
            message << ", on the #{milestone} milestone"
          end
          message << '.'
          msg.reply(message)
        rescue Octokit::NotFound
          msg.reply("Issue ##{issue_num} cannot be found.")
        end
      end

      # Gets some information for an issue stated in the channel using #XX
      #   syntax. This will check if the syntax is just plain #XX or
      #   user/repo#XX.
      # @param msg [Cinch::Message]
      # @param issue_num [String] The GitHub issue number.
      def default_repo(msg, issue_num)
        multiple_match = msg.message.scan(/(?:[\W]+|^)(#[\d]+)/)
        repo_message = msg.message.scan(/[A-Za-z0-9\-]+\/[A-Za-z0-9\-_\.]+#\d+/)
        channel_valid = Variables::Constants::ISSUE_TRACKING.include?(msg.channel)
        message = []
        if !multiple_match.empty? && channel_valid
          repo = Variables::Constants::ISSUE_TRACKING[msg.channel]
          multiple_match.each do |i|
            num = i[0].split(/[#]/)[1]
            url = ISGD.shorten("https://github.com/#{repo}/issues/#{num}")
            message << "#{repo}#{i[0]}: #{url}"
          end
        end

        unless repo_message.empty?
          repo_message.each do |i|
            msg_data = i.split(/[#]/)
            url = ISGD.shorten("https://github.com/#{msg_data[0]}/issues/#{msg_data[1]}")
            message << "#{msg_data[0]}##{msg_data[1]}: #{url}"
          end
        end

        if message.any?
          msg.reply(message.join(', '))
          return if message.size > 1
        end

        unless repo_message.nil? || repo_message.size < 1
          msg_data = repo_message[0].to_s.split(/[#\/]/)
          repo_syntax(msg, msg_data[0], msg_data[1], msg_data[2])
          return
        end

        return unless channel_valid
        repo = Variables::Constants::ISSUE_TRACKING[msg.channel]
        reply(msg, repo, issue_num)
      end

      # Gets some information for an issue stated in the channel using user/repo
      #   syntax.
      # @param msg [Cinch::Message]
      # @param user [String] The user who owns the repository.
      # @param repo [String] The repository's name.
      # @param num [String] The issue number.
      def repo_syntax(msg, user, repo, num)
        reply(msg, "#{user}/#{repo}", num)
      end
    end
  end
end
