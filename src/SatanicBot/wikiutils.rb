require 'net/http'
require 'json'

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
        JSON.parse(response.body)["query"]["pages"].each do |revid, data|
          $revid = revid
        end
        return JSON.parse(response.body)["query"]["pages"][$revid]["revisions"][0]["*"]
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
        return false
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

    def get_rev_data(page)
      params = {
        action: 'query',
        prop: 'revisions',
        titles: page,
        rvprop: 'user|comment|ids',
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

    def get_pages_in_category(category)
      params = {
        action: 'query',
        list: 'categorymembers',
        cmtitle: category,
        cmprop: 'title',
        cmlimit: 5000,
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

    def delete_page(page)
      params = {
        action: 'delete',
        title: page,
        reason: '[[wikipedia:WP:CSD#C2|C2]]: Speedy renaming or merging',
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
