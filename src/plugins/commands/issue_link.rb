require 'cinch'
require 'octokit'
require_relative '../../variables'

module Plugins
  module Commands
    class IssueLink
      include Cinch::Plugin

      match(/([\d]+)/, method: :default_repo, prefix: /\#/)

      # Creates a message based on the information given about the issue.
      # @param state [String] The state of the issue (open/closed)
      # @param title [String] The issue's title.
      # @param number [String] The issue number.
      # @param is_pull [Boolean] Whether the issue is a pull request, and not a
      #   normal issue.
      # @return [String] The formatted message.
      def form_message(state, title, labels, number, is_pull)
        start = is_pull ? 'The pull request' : 'The issue'
        if labels.empty?
          "#{start}, \"#{title}\" ##{number}, is #{state}."
        else
          "#{start}, \"#{title}\" ##{number}, is #{state}, with the " \
          "following labels: #{labels.join(', ')}"
        end
      end

      # Gets some information for an issue stated in the channel using #XX
      #   syntax. This will check if the syntax is just plain #XX or
      #   user/repo#XX.
      # @param msg [Cinch::Message]
      # @param issue_num [String] The GitHub issue number.
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

      # Gets some information for an issue stated in the channel using user/repo
      #   syntax.
      # @param msg [Cinch::Message]
      # @param user [String] The user who owns the repository.
      # @param repo [String] The repository's name.
      # @param num [String] The issue number.
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
