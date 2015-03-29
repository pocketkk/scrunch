lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

class Cursor

	attr_accessor :x, :y, :window

	def initialize(window)
		self.x = 0
		self.y = 0
		self.window = window
	end

	def up(num = 1)
		num.times { self.y -= 1 unless self.y == 0 }
	end

	def down(num = 1)
		num.times { self.y += 1 unless self.y == self.window.limit_y-1 }
	end

	def right(num = 1)
		num.times { self.x += 1 unless self.x == self.window.limit_x-1 }
	end

	def left(num = 1)
		num.times { self.x -=1 unless self. x == 0 }
	end

end