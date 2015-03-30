class Document
	attr_accessor :text

	def initialize(text = "")
		self.text = text
	end

	def height
		self.text.lines.count
	end

	def width(num)
		val = 0
		if self.text.lines.count > num then
			val = self.text.lines[num].sub("\n","").length
		else
			return 0
		end
	end
	
	def insert(key:, x:, y:)
		y = y #header line needs to be deducted before calling method
		temp = ""
		count = 0
		lines = self.text.lines
		lines.each do |line|
			if count == y then
				line.insert(x, key)
				temp += line
			else
				temp += line
			end
			count += 1
		end
		self.text = temp
	end

	def lines(from, to)
		temp = ""
		count = 0
		self.text.lines.each do |line|
			if count >= from && count <= to then
				temp += line
			end
			count += 1
		end
		temp
	end

end