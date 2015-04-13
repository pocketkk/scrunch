module HasCursor

	def set_cursor
		case self.mode
		when :command then 
			self.cursor.x = 0
			self.cursor.y = self.height - 1
		when :normal, :master then 
			self.cursor.x = self.margin_left_width
			self.cursor.y = header.lines.count
		end
	end

	def body_height
		self.height - self.footer.lines.count - self.header.lines.count
	end

	def body_y
		self.cursor.y - self.header.lines.count
	end

	def limit_max_x
		case self.mode
			when :normal, :master  then self.margin_left_width + self.document.width(self.cursor.y - header.lines.count + self.document_y_offset)
			when :command then self.width - 1
		end
	end

	def limit_max_y
		case self.mode
			when :normal, :master  then 
				if self.document.height > body_height then
					body_height + self.header.lines.count - 1
				else
					self.document.height 
				end
			when :command then self.height - 1
		end
	end

	def limit_min_y
		case mode
			when :normal, :master then header.lines.count
			when :command then height - 1
		end
	end

	def limit_min_x
		self.margin_left_width
	end

	# Translate cursor coordinates into document coordinates
	def document_x
		cursor.x - self.margin_left_width
	end

	def document_y
		cursor.y - header.lines.count + document_y_offset
	end

	def document_cursor_y
		cursor.y - header.lines.count
	end

	def cursor_at_bottom?
		cursor.y == height - footer.lines.count - 1
	end

	def cursor_at_top?
		cursor.y == header.lines.count
	end

	def lines_below?
		cursor.y < document.text.lines.count - document_y_offset
	end

	def lines_above?
		document_y_offset != 0
	end

end
