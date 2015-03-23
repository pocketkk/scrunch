lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'ap'
require 'screen'

class GoogleNews

  @headlines = []
  @snippets = []
  @row = 0
  @indent = 0

  @buffer = ""
  @display = ""

  def process()
    s = Story.new
    s.headline = "test"
    s.snippet = ""
    200.times do |x|
      s.snippet += "#{x} "
    end
    @stories << s

    @data.css('.story').each do |snippet|
      story = Story.new
      story.headline = get(snippet, '.esc-lead-article-title')
      story.snippet = get(snippet, '.esc-lead-snippet-wrapper')
      @stories << story
    end
  end

  def initialize()
    @url = "https://news.google.com/news?q=apple"
    @data = Nokogiri::HTML(open(@url))
    @stories = Array.new
    @screen = Screen.new
    process
    show
  end

  def stories
    @stories
  end

  def get(snippet, css)
    value = ""
    value = snippet.at_css(css).text.strip unless snippet.at_css(css).nil?
    value
  end

  def wrap(text, indent=5,width=30)
    tab = ""
    indent.times {tab += " "}
    value = ""
    count = 0
    while count < text.length
      value += tab + text[count..count+width-indent-1] + "\n"
      count += width-indent
    end 
    value
  end

  def view
    value = ""
    @stories.each do |story|
      value += story.headline + "\n\n"
      value += wrap(story.snippet, 5, 70)
    end
    value
  end

  def view_story(story)
    value = story.headline + "\n\n"
    value += wrap(story.snippet, 5, 70)
  end

  def show()
    @stories.each do |story|
      @screen.display(view_story(story))
    end
  end

end

class Story
  attr_accessor :headline, :snippet, :link
end

