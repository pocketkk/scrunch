lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Dir["./lib/*.rb"].each { |f| require(f) }

class Scrunch
  attr_accessor :file_name, :window, :footer, :documents

  def initialize
    new_file = false
    self.documents = []
  end

  def add_document(doc:)
    documents << doc
  end

  def create(file_name="")
    document = Document.new(scrunch: self, file_name: file_name, text: " \n")
    self.window = Window.new(document: document)
    save(document: document)
  end
  
  def open(file_name)
    #clear the contents of the document
    document = Document.new(scrunch: self, file_name: file_name, text: "")
    File.open(file_name, "r") { |file| file.each_line { |line| document.text += line } }
    document.file_name = file_name
    self.window = Window.new(document: document)
    self.window.show
  end

  def save(document:)
    File.open(document.file_name,"w") { |file| file.write(document.text) }
    self.window.message = "SAVED: #{document.file_name}"
  end

  def document
    @document
  end

  def document=(text)
    @document = text
  end

end

# s = Scrunch.new
# s.open('scrunch.rb')

# class GoogleNews

#   @headlines = []
#   @snippets = []
#   @row = 0
#   @indent = 0

#   @buffer = ""
#   @display = ""

#   def process()
#     s = Story.new
#     s.headline = "test"
#     s.snippet = ""
#     200.times do |x|
#       s.snippet += "#{x} "
#     end
#     @stories << s

#     @data.css('.story').each do |snippet|
#       story = Story.new
#       story.headline = get(snippet, '.esc-lead-article-title')
#       story.snippet = get(snippet, '.esc-lead-snippet-wrapper')
#       @stories << story
#     end
#   end

#   def initialize()
#     @url = "https://news.google.com/news?q=apple"
#     @data = Nokogiri::HTML(open(@url))
#     @stories = Array.new
#     @screen = Screen.new
#     process
#     show
#   end

#   def stories
#     @stories
#   end

#   def get(snippet, css)
#     value = ""
#     value = snippet.at_css(css).text.strip unless snippet.at_css(css).nil?
#     value
#   end

#   def wrap(text, indent=5,width=30)
#     tab = ""
#     indent.times {tab += " "}
#     value = ""
#     count = 0
#     while count < text.length
#       value += tab + text[count..count+width-indent-1] + "\n"
#       count += width-indent
#     end 
#     value
#   end

#   def view
#     value = ""
#     @stories.each do |story|
#       value += story.headline + "\n\n"
#       value += wrap(story.snippet, 5, 70)
#     end
#     value
#   end

#   def view_story(story)
#     value = story.headline + "\n\n"
#     value += wrap(story.snippet, 5, 70)
#   end

#   def show()
#     @stories.each do |story|
#       @screen.display(view_story(story))
#     end
#   end

# end

# class Story
#   attr_accessor :headline, :snippet, :link
# end

