
require 'dispel'
require 'terminfo'
require 'cursor'

class Window

	include HasCursor
	include HasKeyboard

	attr_accessor :width, :height, :mode, :cursor, :document, :buffer, :arguments, :command,
				  :document_y_offset, :document_x_offset, :margin_left_width, :border_width

	def self.test
		Window.new(Document.test_doc)
	end

	def initialize(document=Document.new, **args)
		height = 0
		self.width = 0
		self.mode = :normal
		self.command = :edit
		self.document_y_offset = 0
		self.margin_left_width = 5
		self.document_x_offset = self.margin_left_width
		self.border_width = 1
		self.cursor = Cursor.new(self)
		self.document = document
		self.arguments = args
		get_window_size unless self.arguments[:test]
		self.buffer = render
	end

	def header
		temp = align_right(show_cursor_pos, absolute: true) + "\n"
	end

	def margin_left

	end

	def add_line_numbers
		text = ""
		document_text = self.document.text.lines
		(document_y_offset..body_height + document_y_offset - 1).each do |num|
			( margin_left_width - num.to_s.chars.count - border_width ).times { text += " " }
			text += num.to_s + " "
			if document_text[num].nil?
				text += "\n"
			else
				text += document_text[num]
			end
		end
		text
	end

	def body
		#self.document.lines(from: document_y_offset, to: body_height + document_y_offset - 1).join('')
		add_line_numbers
	end

	def footer
		case self.mode
		when :command
			"#{mode.to_s}\n\n\n"
		else
			"#{mode.to_s}\n\n"
		end
	end

	def get_window_size
    	self.height = TermInfo.screen_size[0]
    	self.width = TermInfo.screen_size[1]
  	end

  	def render
  		buffer  = header
  		buffer += body
  		buffer += "\n" if add_lines(height - buffer.lines.count - footer.lines.count).length == 
  																			0 && body[-1] != "\n"
		buffer += add_lines(height - buffer.lines.count - footer.lines.count)
  		buffer += footer
  	end

  	def add_lines(num)
  		text = ""
  		num.times { text += "\n" }
  		text
  	end

  	def show_cursor_pos
  		"offset: #{self.document_y_offset} x: #{self.cursor.x} y: #{self.cursor.y} "
  	end

  	def align_right(text, absolute: false)
  		if absolute then
  			return text.prepend(add_padding(width - text.length))
  		else
  			return text.prepend(add_padding(limit_x - text.length))
  		end
  	end

  	def add_padding(num)
  		text = ""
  		num.times { text += " " }
  		text
  	end

  	def map_for_margin_left(m)

  		m
  	end

  	def map
	    m = Dispel::StyleMap.new(height)
	    # add map for header
	    m.add(['#272822','#a6e22e'], 0, 0..width+1)
	    # add map for footer
	    m.add(['#272822','#a6e22e'], height - footer.lines.count, 0..width-1)
  		body_height.times do |num|
  			m.add(['#7d7d7d', '#000000',], num + header.lines.count, 0..margin_left_width - border_width - 1)
  		end
  		body_height.times do |num|
  			m.add(['#050505', '#050505',], num + header.lines.count, margin_left_width - border_width..margin_left_width - border_width)
  		end
	    m
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

  	#Window show is essentially the loop
  	def show
	    Dispel::Screen.open(:colors => true) do |screen|
	      set_cursor
	      screen.draw render, map, [cursor.y, cursor.x]
	      Dispel::Keyboard.output do |key|
	      	break if key == :"Ctrl+b" 
	        process_key(key)
	        screen.draw render, map, [cursor.y, cursor.x]
	      end
	    end
	end
end


w = Window.test.show








