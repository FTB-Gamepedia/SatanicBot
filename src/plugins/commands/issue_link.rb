require 'cinch'
require 'octokit'
require_relative '../../variables'

module Plugins
  module Commands
    class IssueLink
      include Cinch::Plugin

      set(:prefix, /\#/)
      match(/([\d]+)/)

      def form_message(state, title, labels, number)
        if labels.empty?
          "The issue, \"#{title}\" ##{number}, is #{state}."
        else
          "The issue, \"#{title}\" ##{number}, is #{state}, with the " \
          "following labels: #{labels.join(', ')}"
        end
      end

      def execute(msg, issue_num)
        if Variables::Constants::ISSUE_TRACKING.include? msg.channel
          repo = Variables::Constants::ISSUE_TRACKING[msg.channel]
          begin
            issue = Octokit.issue(repo, issue_num)
            state = issue['state']
            title = issue['title']
            labels = []
            issue['labels'].each do |l|
              labels << l['name']
            end
            msg.reply("https://github.com/#{repo}/issues/#{issue_num}")
            msg.reply(form_message(state, title, labels, issue_num))
          rescue Octokit::NotFound
            msg.reply("Issue ##{issue_num} cannot be found.")
          end
        end
      end
    end
  end
end
