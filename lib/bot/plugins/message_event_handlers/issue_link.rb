require 'octokit'
require 'isgd'
require 'active_support'
require 'active_support/core_ext/array/conversions'
require_relative 'base_meh'

module Plugins
  module MessageEventHandlers
    class IssueLink < BaseMEH
      def initialize
        super(contains: /[A-Za-z0-9\-]+\/[A-Za-z0-9\-_\.]+#[\d]+/)
      end

      # @param repo [String] The full repository in user/repo syntax.
      # @param issue_num [Integer] The issue number.
      # @return [String, nil] The info message to send to the channel, nil if it does not exist.
      def form_reply(repo, issue_num)
        issue = Octokit.issue(repo, issue_num)
        state = issue[:state]
        title = issue[:title]
        labels = issue&.[](:labels)&.map { |l| l[:name] }
        milestone = issue&.[](:milestone)&.[](:title)
        assignees = issue&.[](:assignees)&.map { |a| a[:login] }
        message = "\"#{title}\" ##{issue_num}, is #{state}"
        message << ", labeled #{labels.to_sentence}" unless labels.empty?
        message << ", on the #{milestone} milestone" unless milestone.nil?
        message << ", assigned to #{assignees.to_sentence}" unless assignees.empty?
        message << '.'
        return message
      rescue Octokit::NotFound
        return nil
      end

      # Gets some information for an issue stated in the channel using user/repo#XX syntax.
      # @param event [Discordrb::Events::MessageEvent]
      def execute(event)
        repo_message = event.message.content.scan(/([A-Za-z0-9\-]+\/[A-Za-z0-9\-_\.]+)#(\d+)/)
        message = []
        unless repo_message.empty?
          repo_message.each do |msg_data|
            reply = form_reply(msg_data[0], msg_data[1])
            if reply
              url = no_embed(ISGD.shorten("https://github.com/#{msg_data[0]}/issues/#{msg_data[1]}"))
              message << "#{msg_data[0]}##{msg_data[1]}: #{url}"
              message << form_reply(msg_data[0], msg_data[1])
            else
              message << "Issue ##{msg_data[1]} cannot be found."
            end
          end
          return message.join("\n")
        end

        return nil
      end
    end
  end
end
