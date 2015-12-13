require 'cinch'
require 'octokit'
require_relative '../../variables'

module Plugins
  module Commands
    class IssueLink
      include Cinch::Plugin

      match(/([\d]+)/, method: :default_repo, prefix: /\#/)

      def form_message(state, title, labels, number, is_pull)
        start = is_pull ? 'The pull request' : 'The issue'
        if labels.empty?
          "#{start}, \"#{title}\" ##{number}, is #{state}."
        else
          "#{start}, \"#{title}\" ##{number}, is #{state}, with the " \
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
          is_pull = issue.key?(:pull_request)
          state = issue['state']
          title = issue['title']
          labels = []
          issue['labels'].each do |l|
            labels << l['name']
          end
          url_type = is_pull ? 'pull' : 'issues'
          msg.reply("https://github.com/#{repo}/#{url_type}/#{issue_num}")
          msg.reply(form_message(state, title, labels, issue_num, is_pull))
        rescue Octokit::NotFound
          msg.reply("Issue ##{issue_num} cannot be found.")
        end
      end

      def repo_syntax(msg, user, repo, num)
        issue = Octokit.issue("#{user}/#{repo}", num)
        is_pull = issue.key?(:pull_request)
        labels = []
        issue['labels'].each do |label|
          labels << label['name']
        end
        url_type = is_pull ? 'pull' : 'issues'
        msg.reply("https://github.com/#{user}/#{repo}/#{url_type}/#{num}")
        msg.reply(form_message(issue['state'], issue['title'], labels, num,
                               is_pull))
      rescue Octokit::NotFound
        msg.relpy("Issue ##{issue} cannot be found.")
      end
    end
  end
end
