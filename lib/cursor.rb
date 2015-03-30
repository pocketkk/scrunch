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
		num.times { self.y -= 1 unless self.y <= self.window.limit_min_y }
		check_limits_on_x_and_y
	end

	def down(num = 1)
		num.times { self.y += 1 unless self.y >= self.window.limit_max_y }
		check_limits_on_x_and_y
	end

	def right(num = 1)
		num.times { self.x += 1 unless self.x >= self.window.limit_max_x }
		check_limits_on_x_and_y
	end

	def left(num = 1)
		num.times { self.x -=1 unless self.x <= self.window.limit_min_x }
		check_limits_on_x_and_y
	end

	#If x and y get out of whack set them to max or min as needed
	def check_limits_on_x_and_y
		self.x = self.window.limit_max_x if x > self.window.limit_max_x 
		self.y = self.window.limit_min_y if y > self.window.limit_max_y 
	end

end