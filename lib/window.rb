
require 'dispel'
require 'terminfo'
require 'cursor'

class Window

	attr_accessor :width, :height, :mode, :cursor, :document

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
			when :normal  then self.document.width(self.cursor.y).width
			when :command then self.width
		end
	end

	def limit_y
		case self.mode
			when :normal  then self.document.height
			when :command then self.height
		end
	end

	def get_window_size
    	self.height = TermInfo.screen_size[0]
    	self.width = TermInfo.screen_size[1]
  	end

  	def map
	    m = Dispel::StyleMap.new(self.height)
	    # add map for header
	    height_for_footer = self.height > 3 ? self.height - 1 : 0
	    m.add(['#272822','#a6e22e'], 0, 0..width+1)
	    # add map for footer
	    m.add(['#272822','#a6e22e'], height_for_footer, 0..width+1)
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
	      screen.draw "", map, [self.cursor.y, self.cursor.x]
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
	        screen.draw "", map, [self.cursor.y, self.cursor.x]
	      end
	    end
	end
end