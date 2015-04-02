
require 'dispel'
require 'terminfo'
require 'cursor'

class Window

	attr_accessor :width, :height, :mode, :cursor, :document, :buffer, :arguments, :command,
				  :document_y_offset, :document_x_offset

	def self.test
		Window.new(Document.test_doc)
	end

	def initialize(document=Document.new, **args)
		self.height = 0
		self.width = 0
		self.mode = :normal
		self.command = :edit
		self.document_x_offset = 0
		self.document_y_offset = 0
		self.cursor = Cursor.new(self)
		self.document = document
		self.arguments = args
		get_window_size unless self.arguments[:test]
		self.buffer = render
	end

	def body_height
		self.height - self.footer.lines.count - self.header.lines.count
	end

	def body_y
		self.cursor.y - self.header.lines.count
	end

	def limit_max_x
		case self.mode
			when :normal  then self.document.width(self.cursor.y - header.lines.count + self.document_y_offset)
			when :command then self.width - 1
		end
	end

	def limit_max_y
		case self.mode
			when :normal  then 
				if self.document.height > body_height then
					body_height + self.header.lines.count - 1
				else
					self.document.height 
				end
			when :command then self.height - 1
		end
	end

	def limit_min_y
		case self.mode
			when :normal then header.lines.count
			when :command then self.height - 1
		end
	end

	def limit_min_x
		0
	end

	# Translate cursor coordinates into document coordinates
	def document_x
		self.cursor.x
	end

	def document_y
		self.cursor.y - self.header.lines.count + document_y_offset
	end

	def document_cursor_y
		self.cursor.y - self.header.lines.count
	end

	def header
		temp = align_right(show_cursor_pos, absolute: true) + "\n"
	end

	def body
		self.document.lines(from: document_y_offset, to: body_height + document_y_offset - 1)
	end

	def footer
		case self.mode
		when :command
			"#{self.mode.to_s}\n\n\n"
		else
			"#{self.mode.to_s}\n\n"
		end
	end

	def get_window_size
    	self.height = TermInfo.screen_size[0]
    	self.width = TermInfo.screen_size[1]
  	end

  	def render
  		self.buffer  = header
  		self.buffer += body
  		self.buffer += "\n" if add_lines(self.height - self.buffer.lines.count - self.footer.lines.count).length == 0 && body[-1] != "\n"
		self.buffer += add_lines(self.height - self.buffer.lines.count - self.footer.lines.count)
  		self.buffer += footer
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
  			return text.prepend(add_padding(self.width - text.length))
  		else
  			return text.prepend(add_padding(limit_x - text.length))
  		end
  	end

  	def add_padding(num)
  		text = ""
  		num.times { text += " " }
  		text
  	end

  	def map
	    m = Dispel::StyleMap.new(self.height)
	    # add map for header
	    m.add(['#272822','#a6e22e'], 0, 0..width+1)
	    # add map for footer
	    m.add(['#272822','#a6e22e'], self.height - self.footer.lines.count, 0..width-1)
	    m
	end

	def change_mode
		case self.mode
			when :command then self.mode = :normal
			when :normal  then self.mode = :command
		end
		set_cursor
	end

	def set_cursor
		case self.mode
		when :command then 
			self.cursor.x = 0
			self.cursor.y = self.height - 1
		when :normal then 
			self.cursor.x = 0
			self.cursor.y = header.lines.count
		end
	end

	def key_to_string(key)
		case key
			when :enter     then return "\n"
			when :space     then return " "
			else                 return key.to_s
		end
	end

	def cursor_at_bottom?
		self.cursor.y == self.height - self.footer.lines.count - 1
	end

	def cursor_at_top?
		self.cursor.y == self.header.lines.count
	end

	def lines_below?
		self.cursor.y < document.text.lines.count - document_y_offset
	end

	def lines_above?
		document_y_offset != 0
	end

	def up
		if cursor_at_top? && lines_above? then
			self.document_y_offset -= 1
		else
			self.cursor.up
		end
	end

	def page_up
		body_height.times {self.up}
	end

	def down
		if cursor_at_bottom? && lines_below? then
			self.document_y_offset += 1
		else
			self.cursor.down
		end
	end

	def page_down 
		body_height.times {self.down}
	end

	def move_cursor_for(key:)
		case key
			when :enter then
				if cursor_at_bottom? then
					self.document_y_offset += 1
					self.cursor.x = 0
				else
					self.cursor.down
					self.cursor.x = 0
				end
			else self.cursor.right
		end
	end

	def add_key_to_document(key)
		self.document.insert(key: key_to_string(key), x: self.cursor.x, y: document_y)
		move_cursor_for(key: key)
		#find the location of the cursor
		#move to that point in the document
		#add that key
		#move cursor right or left or down as needed
	end

  	#Window show is essentially the loop
  	def show
	    Dispel::Screen.open(:colors => true) do |screen|
	      set_cursor
	      screen.draw render, map, [self.cursor.y, self.cursor.x]
	      Dispel::Keyboard.output do |key|
	        case key
	        	when :down 			then self.down
	        	when :up 			then self.up
	        	when :right 		then self.cursor.right
	        	when :left 			then self.cursor.left
	        	when :page_down		then self.page_down
	        	when :page_up		then self.page_up
	        	when :backspace     then
	        		if self.cursor.x > 0
	        			self.cursor.left
	        			self.document.remove(x: document_x, y: document_y)
	        		elsif document_y - document_y_offset > 0
	        			char_count_line_above = self.document.lines(from: document_y - 1, to: document_y - 1).chars.count
	        			self.document.remove(x: char_count_line_above - 1, y: document_y - 1)
	        			self.cursor.up
	        			self.cursor.right(char_count_line_above)
	        		elsif self.cursor.x == 0 && self.cursor.y == 1
	        			char_count_line_above = self.document.lines(from: document_y - 1, to: document_y - 1).chars.count
	        			self.document.remove(x: char_count_line_above - 1, y: document_y - 1)
	        			self.document_y_offset -= 1
	        			self.cursor.right(char_count_line_above)
	        		end
	        	when :delete		then self.document.remove(x: document_x, y: document_y)
	        	when :tab 			then self.cursor.right(4)
	        	when :"Shift+tab" 	then self.cursor.left(4)
	        	when :escape		then self.change_mode
	        	when :"Ctrl+q"	    then break
	        	else add_key_to_document(key)
	        end
	        screen.draw render, map, [self.cursor.y, self.cursor.x]
	      end
	    end
	end
end