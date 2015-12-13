require 'cinch'
require 'octokit'
require_relative '../../variables'

module Plugins
  module Commands
    class IssueLink
      include Cinch::Plugin

      match(/([\d]+)/, method: :default_repo, prefix: /\#/)

      def form_message(state, title, labels, number)
        if labels.empty?
          "The issue, \"#{title}\" ##{number}, is #{state}."
        else
          "The issue, \"#{title}\" ##{number}, is #{state}, with the " \
          "following labels: #{labels.join(', ')}"
        end
      end

      def default_repo(msg, issue_num)
        match = msg.message.match(/(\S+)\/(\S+)##{issue_num}/)
        unless match.nil?
          msg_data = match.to_s.split(/[\#\/]/)
          repo_syntax(msg, msg_data[0], msg_data[1], msg_data[2])
          return
        end
        return unless Variables::Constants::ISSUE_TRACKING.include?(msg.channel)
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

      def repo_syntax(msg, user, repo, num)
        issue = Octokit.issue("#{user}/#{repo}", num)
        labels = []
        issue['labels'].each do |label|
          labels << label['name']
        end
        msg.reply("https://github.com/#{user}/#{repo}/#{num}")
        msg.reply(form_message(issue['state'], issue['title'], labels, num))
      rescue Octokit::NotFound
        msg.relpy("Issue ##{issue} cannot be found.")
      end
    end
  end
end
