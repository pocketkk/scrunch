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
			val = self.text.lines[num-1].sub("\n","").length
		else
			return 0
		end
	end

end