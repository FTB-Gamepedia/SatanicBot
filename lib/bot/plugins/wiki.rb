require 'mediawiki/exceptions'
require_relative '../variables'

module Plugins
  # A mixin for handling MediaWiki actions without redundant code
  module Wiki
    # @return [MediaWiki::Butt] Use this to obtain the current MW instance and log in if necessary
    def wiki
      LittleHelper.init_wiki
    end

    # @param title [String] see MediaWiki::Butt#edit
    # @param msg [Cinch::Message] The message that prompted this edit
    # @param opts [Hash<Symbol, Any>] see MediaWiki::Butt#edit
    # @yield [text] The text of the page being edited
    # @yield [opts] The options to be passed to edit, as passed to this function's opts parameter. This can be used
    #   to modify the summary based on data from the content, for example.
    # @yieldreturn [Hash<Symbol, String/Proc>] An options hash containing the relevant info for the edit, keys :text,
    #   :success, :fail, and :error. Additionally, this will be merged with the opts parameter passed to the function,
    #   so the edit options can be modified based on the content of the page.
    #   The :success and :fail keys are Procs that takes no parameters, while :error passes an EditError
    #   Setting the :terminate key will prevent the edit from being performed. None of the other options need to be set
    #   if this one is set. This should be set to a Proc that returns the string to be sent as a reply to the message.
    #   The Procs can also be nil (or return nil) if no message should be sent at all.
    #   The :text key contains the text to replace the page contents with (see {MediaWiki::Butt#edit})
    # @return [void]
    def edit(title, msg, opts = {})
      mw = wiki
      content = mw.get_text(title)
      yield_return = yield(content)
      if yield_return.key?(:terminate)
        reply_from_proc(msg, yield_return[:terminate])
        return
      end
      begin
        edit_resp = mw.edit(title, yield_return[:text], opts.merge(yield_return))
        if edit_resp
          reply_from_proc(msg, yield_return[:success])
        else
          reply_from_proc(msg, yield_return[:fail])
        end
      rescue MediaWiki::Butt::EditError => e
        reply_from_proc(msg, yield_return[:error], e)
      end
    end

    private

    # Helper function that replies from a provided Proc, if it is not nil nor is its return value.
    # @param msg [Cinch::Message] The message to reply to
    # @param proc [Proc] The Proc that returns the message. Nilable.
    # @param params [Any] The params to pass to the Proc if it is not nil.
    # @return [void]
    def reply_from_proc(msg, proc, params = nil)
      to_send = proc&.call(params)
      msg.reply(to_send) if to_send
    end
  end
end
