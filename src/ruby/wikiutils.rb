module Wiki_Utils
  class Client
    def initialize(api_page, debug = false)
      @api_page = api_page
      @debug = debug
    end

    def get_wikitext(page_name)
      params = {
        action: 'query',
        prop: 'revisions',
        rvprop: 'content',
        format: 'json',
        titles: page_name
      }

      request = URI(@api_page)
      request.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(request)
      if response.is_a? Net::HTTPSuccess
        return response.body
      else
        @debug ? response : nil
      end
    end
    
    def get_backlinks(bltitle, blnamespace)
      params = {
        action: 'query',
        list: 'backlinks',
        bltitle: bltitle,
        blnamespace: blnamespace
        bllimit: 5000,
      }
      
      request = URI(@api_page)
      request.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(request)
      if response.is_a? Net::HTTPSuccess
        return response.body
      else
        @debug ? response : nil
      end
    end
  end
end
