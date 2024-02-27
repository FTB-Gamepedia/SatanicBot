require 'mediawiki/butt'
require 'mediawiki/exceptions'
require_relative 'variables'

class ExtendedButt < MediaWiki::Butt
  def post(params)
    begin
      super(params)
    rescue MediaWiki::Butt::NotBotError => e
      login(Variables::Constants::WIKI_AUTHNAME, Variables::Constants::WIKI_PASSWORD)
      retry
    end
  end

  # TODO: Implement better history stuff in MediaWiki-Butt
  # @param page [String] The page name to get the first edit timestamp for
  # @return [Time] The date and time for this page's first edit converted for UTC
  def first_edit_timestamp(page)
    params = {
    action: 'query',
    prop: 'revisions',
    titles: page,
    rvprop: 'timestamp',
    rvlimit: @query_limit_default
    }
    query(params) do |return_val, query|
      pageid = query['pages'].keys.find(MediaWiki::Constants::MISSING_PAGEID_PROC) { |id| id != '-1' }
      return [] if query['pages'][pageid].key?('missing')
      return_val.concat(query['pages'][pageid].fetch('revisions', []).collect { |h| Time.parse(h['timestamp']).utc })
    end.min
  end
end
