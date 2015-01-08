require './plugins/pygments_code'

module BacktickCodeBlock
  include HighlightCode
  AllOptions = /([^\s]+)\s+(.+?)\s+(https?:\/\/\S+|\/\S+)\s*(.+)?/i
  LangCaption = /([^\s]+)\s*(.+)?/i
  def render_code_block(input)
    @options = nil
    @caption = nil
    @lang = nil
    @url = nil
    @title = nil
    input.gsub(/^`{3} *([^\n]+)?\n(.+?)\n`{3}/m) do
      @options = $1 || ''
      str = $2

      if @options =~ AllOptions
        @lang = $1
        @caption = "<figcaption><span>#{$2}</span><a href='#{$3}'>#{$4 || 'link'}</a></figcaption>"
        # @caption = "<div><span>#{$2}</span><a href='#{$3}'>#{$4 || 'link'}</a></div>"
      elsif @options =~ LangCaption
        @lang = $1
        @caption = "<figcaption><span>#{$2}</span></figcaption>"
		# @caption = "<div><span>#{$2}</span></div>"
      end

      if str.match(/\A( {4}|\t)/)
        str = str.gsub(/^( {4}|\t)/, '')
      end
      if @lang.nil? || @lang == 'plain'
        code = tableize_code(str.gsub('<','&lt;').gsub('>','&gt;'))
        "<figure class='code'>#{@caption}#{code}</figure>"
		# "<div class='code'>#{@caption}#{code}</div>"  
      else
        if @lang.include? "-raw"
          raw = "``` #{@options.sub('-raw', '')}\n"
          raw += str
          raw += "\n```\n"
        else
          code = highlight(str, @lang)
          "<figure class='code'>#{@caption}#{code}</figure>"
		  #"<div class='code'>#{@caption}#{code}</div>"  
        end
      end
    end
  end
end
