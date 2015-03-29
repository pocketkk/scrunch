
require 'dispel'
require 'terminfo'
require 'cursor'

class Window

	attr_accessor :width, :height, :mode, :cursor, :document, :text

	def initialize(document=Document.new)
		self.height = 0
		self.width = 0
		self.mode = :normal
		self.cursor = Cursor.new(self)
		self.document = document
		get_window_size
	end

	def limit_x
		case self.mode
			when :normal  then self.document.width(self.cursor.y)
			when :command then self.width - 1
		end
	end

	def limit_y
		case self.mode
			when :normal  then self.document.height
			when :command then self.height - 1
		end
	end

	def footer
		""
	end

	def header
		t = align_right(show_cursor_pos, {:absolute => true})
  		t += add_lines(self.height - t.lines.count)
  		t
	end

	def get_window_size
    	self.height = TermInfo.screen_size[0]
    	self.width = TermInfo.screen_size[1]
  	end

  	def render
  		text = ""
  		text +=
  	end

  	def add_lines(num)
  		text = ""
  		num.times { text += "\n" }
  		text
  	end

  	def show_cursor_pos
  		"x: #{self.cursor.x} y: #{self.cursor.y} "
  	end

  	def align_right(text, opts={})
  		if opts[:absolute] then
  			text.prepend(add_padding(self.width - text.length))
  		else
  			text.prepend(add_padding(limit_x - text.length))
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
	    m.add(['#272822','#a6e22e'], self.height - 1, 0..width-1)
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
			self.cursor.y = 0
		when :normal then 
			self.cursor.x = 0
			self.cursor.y = 0
		end
	end

  	#Window show is essentially the loop
  	def show
	    Dispel::Screen.open(:colors => true) do |screen|
	      screen.draw show_text, map, [self.cursor.y, self.cursor.x]
	      Dispel::Keyboard.output do |key|
	        case key
	        	when :down 			then self.cursor.down
	        	when :up 			then self.cursor.up
	        	when :right 		then self.cursor.right
	        	when :left 			then self.cursor.left
	        	when :tab 			then self.cursor.right(4)
	        	when :"Shift+tab" 	then self.cursor.left(4)
	        	when :escape		then self.change_mode
	        	when :enter 		then break
	        end
	        screen.draw show_text, map, [self.cursor.y, self.cursor.x]
	      end
	    end
	end
end