module Wiki_Utils
  class Client
    def initialize(api_page)
      @api_page = api_page
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
        return false
      end
    end

    def get_backlinks(bltitle, *blnamespace)
      if defined?(blnamespace).nil?
        params = {
          action: 'query',
          list: 'backlinks',
          bltitle: bltitle,
          blnamespace: blnamespace,
          format: 'json',
          bllimit: 5000,
        }
      else
        params = {
          action: 'query',
          list: 'backlinks',
          bltitle: bltitle,
          format: 'json',
          bllimit: 5000
        }
      end

      request = URI(@api_page)
      request.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(request)
      if response.is_a? Net::HTTPSuccess
        return response.body
      else
        @debug ? response : nil
      end
    end

    def get_user_info(username, usprop)
      params = {
        action: 'query',
        list: 'users',
        ususers: username,
        usprop: usprop,
        format: 'json'
      }

      request = URI(@api_page)
      request.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(request)
      if response.is_a? Net::HTTPSuccess
        return response.body
      else
        return false
      end
    end
  end
end
