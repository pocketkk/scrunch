
require 'dispel'
require 'terminfo'

class Window

	include HasCursor
	include HasKeyboard
	include Patterns

	BLUE   = "#01C8EE"
	GREEN  = "#91D900"
	RED    = "#F92672"
	PURPLE = "#804FF5"
	BROWN  = "#272822"
	ORANGE = "#FF7C00"
	YELLOW = "#F7E907"
	BLACK  = "#000000"
	GREY   = "#7d7d7d"

	attr_accessor :width, :height, :mode, :cursor, :document, :buffer, :arguments, :command, :keywords,
				  :document_y_offset, :document_x_offset, :margin_left_width, :border_width, :decorations,
				  :time_refresh, :time_start, :time_count, :time_average, :message

	def self.test
		Window.new(Document.test_doc)
	end

	def initialize(document: Document.new, **args)
		@height = 0
		@width = 0
		@flash_max = 4
		@flash_period = 0
		@mode = :normal
		self.command = :edit
		@document_y_offset = 0
		@margin_left_width = 5
		@document_x_offset = @margin_left_width
		@border_width = 1
		@cursor = Cursor.new(self)
		@document = document
		@arguments = args
		get_window_size unless @arguments[:test]
		@decorations = Dispel::StyleMap.new(@height)
		initialize_time
		@buffer = render
	end

	def initialize_time
		@time_start = Time.now
		@time_average = Time.now
		@time_refresh = 0.0
		@time_count = 1
	end

	def average_time
		time_refresh / time_count
	end

	def header
		temp = align_right(show_cursor_pos, absolute: true) + "\n"
		temp[0..document.file_name.chars.count + 7] = "FILE: #{document.file_name}" unless document.file_name.empty?
		temp[document.file_name.chars.count + 7..document.file_name.chars.count + 18] = " AVG MS: #{average_time.round(4)}"
		temp
	end

	def add_line_numbers
		self.decorations = Dispel::StyleMap.new(height)
		text = ""
		document_text = self.document.text.lines
		(document_y_offset..body_height + document_y_offset - 1).each do |num|
			( margin_left_width - num.to_s.chars.count - border_width ).times { text += " " }
			text += num.to_s + " "
			if document_text[num].nil?
				text += "\n"
			else
				text += document_text[num]
				window_row = num - document_y_offset + header.lines.count
				add_decorations_for(text: document_text[num], row: window_row)
			end
		end
		text
	end

	def add_decorations_for(text:, row:)
		#all is .10	- none is .02
		#.035 before caching patterns (-keywords)

		add_decoration(pattern: pattern_keywords, text: text, color: RED, row: row)
		add_decoration(pattern: pattern_symbols, text: text, color: PURPLE, row: row)
		add_decoration(pattern: pattern_operators, text: text, color: RED, row: row)
		add_decoration(pattern: pattern_hash, text: text, color: PURPLE, row: row)
		add_decoration(pattern: pattern_numeric, text: text, color: ORANGE, row: row)
		add_decoration(pattern: pattern_method_names, text: text, color: GREEN, row: row)
		add_decoration(pattern: pattern_class, text: text, color: BLUE, row: row)
		add_decoration(pattern: pattern_double_quote_string, text: text, color: YELLOW, row: row)
		add_decoration(pattern: pattern_single_quote_string, text: text, color: YELLOW, row: row)
		#add_decoration(pattern: pattern_variable, text: text, color: ORANGE, row: row)
		add_decoration(pattern: pattern_comment, text: text, color: GREY, row: row)
	end

	def add_decoration(pattern:, text:, color:, row:)
		positions(pattern: pattern, string: text).each do |pair|
			decorations.add([color, '#000000'],row , pair[0] + margin_left_width..pair[1] + margin_left_width - 1)
		end
	end

	def body
		add_line_numbers
	end

	def process_messages
		if self.message then
			if @flash_period == @flash_max then
				@message = nil
				@flash_period = 0
			end
			@flash_period += 1
		end
	end

	def footer
		case self.mode
		when :command
			"#{mode.to_s.upcase}    #{"#### #{self.message} ####" if self.message}\n\n\n"
		else
			"#{mode.to_s.upcase}    #{"#### #{self.message} ####" if self.message}\n\n"
		end
	end

	def get_window_size
    	self.height = TermInfo.screen_size[0]
    	self.width = TermInfo.screen_size[1]
  	end

  	def render
  		buffer  = header
  		buffer += body
  		buffer += "\n" if add_lines(height - buffer.lines.count - footer.lines.count).length == 0 && body[-1] != "\n"
		buffer += add_lines(height - buffer.lines.count - footer.lines.count)
  		buffer += footer
  	end

  	def add_lines(num)
  		text = ""
  		num.times { text += "\n" }
  		text
  	end

  	def show_cursor_pos
  		"FLASH:  #{@flash_period} OFFSET: #{self.document_y_offset} X: #{self.cursor.x} Y: #{self.cursor.y} "
  	end

  	def align_right(text, absolute: false)
  		if absolute then
  			return text.prepend(add_padding(width - text.length))
  		else
  			return text.prepend(add_padding(limit_x - text.length))
  		end
  	end

  	def align_left(text:, absolute: true)
  		
  	end

  	def add_padding(num)
  		text = ""
  		num.times { text += " " }
  		text
  	end

  	def map
	    # add map for header
	    decorations.add(['#272822', GREEN ], 0, 0..width+1)
	    # add map for footer
	    decorations.add(['#272822', GREEN ], height - footer.lines.count, 0..width-1)
  		body_height.times do |num|
  			decorations.add(['#7d7d7d', '#000000'], num + header.lines.count, 0..margin_left_width - border_width - 1)
  		end
  		body_height.times do |num|
  			decorations.add(['#050505', '#050505'], num + header.lines.count, margin_left_width - border_width..margin_left_width - border_width)
  		end
	    decorations
	end

	def change_mode
		case mode
			when :command then self.mode = :normal
			when :normal  then self.mode = :command
		end
		set_cursor
	end

	def quit_program
		#Check to save document etc.
		exit
	end

  	def show
	    Dispel::Screen.open(:colors => true) do |screen|
	      set_cursor
	      buffer = render
	      screen.draw buffer, map, [cursor.y, cursor.x]
	      Dispel::Keyboard.output do |key|
	      	break if key == :"Ctrl+b"
	      	self.time_start = Time.now
	        if process_key(key: key) then
	        	buffer = render
	        end
	        process_messages
	        screen.draw buffer, map, [cursor.y, cursor.x]
	        self.time_refresh += Time.now - self.time_start
	        self.time_count += 1
	      end
	    end
	end
end









