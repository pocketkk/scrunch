class Document
	attr_accessor :text, :file_name, :scrunch

	def self.test_doc
		temp = ""
		40.times { |x| temp += "#{x}\n" }
		temp
		Document.new(temp)
	end

	def initialize(scrunch:, text: "", file_name: "")
		self.text = text
		self.file_name = file_name
		self.scrunch = scrunch
	end

	def save
		self.scrunch.save(document: self)
	end

	def save_as(file_name:)
		self.file_name = file_name
		self.scrunch.save(document: self)
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

	def remove(x:, y:)
		temp = ""
		count = 0
		lines = self.text.lines
		lines.each do |line|
			if count == y then
				line[x] = ""
				temp += line
			else
				temp += line
			end
			count += 1
		end
		self.text = temp
	end

	def lines(from:, to:)
		self.text.lines[from..to]
	end

end