module HasKeyboard

	attr_accessor :ctrl, :letter

	def process_key(mode:, key:)
		case key
			when :down 			then down
			when :up 			then up
			when :right 		then 
				cursor.right
				return false
			when :left 			then 
				cursor.left
				return false
			when :page_down		then page_down
			when :page_up		then page_up
			when :backspace     then
				if cursor.x > margin_left_width
					cursor.left
					document.remove(x: document_x, y: document_y)
				elsif document_y - document_y_offset > 0
					char_count_line_above = self.document.lines(from: document_y - 1, to: document_y - 1).join('').chars.count
					document.remove(x: char_count_line_above - 1, y: document_y - 1)
					cursor.up
					cursor.right(char_count_line_above)
				elsif cursor.x == 0 && cursor.y == 1
					char_count_line_above = document.lines(from: document_y - 1, to: document_y - 1).join('').chars.count
					document.remove(x: char_count_line_above - 1, y: document_y - 1)
					document_y_offset -= 1
					cursor.right(char_count_line_above)
				end
			when :delete		then document.remove(x: document_x, y: document_y)
			when :tab 			then 4.times { process_key(mode: mode, key: :space) } 
			when :"Shift+tab" 	then cursor.left(4)
			when :escape		then change_mode
			when :"Ctrl+q"	    then quit_program
			when :"Ctrl+s"		then document.save
			else add_key_to_document(key)
		end
		true
	end

	def process_key_command(key:)

	end

	def process_key_normal(key:)
		case key
			when :j			then 
				cursor.left
				return false 
			when :k			then 
				cursor.right
				return false
			when :i			then up
			when :n			then down
			when :"Ctrl+q"	    then quit_program
		end
		return true
	end

	def process_key(key:)
		case key
			when :down 			then down
			when :up 			then up
			when :right 		then 
				cursor.right
				return false
			when :left 			then 
				cursor.left
				return false
			when :page_down		then page_down
			when :page_up		then page_up
			when :backspace     then
				if cursor.x > margin_left_width
					cursor.left
					document.remove(x: document_x, y: document_y)
				elsif document_y - document_y_offset > 0
					char_count_line_above = self.document.lines(from: document_y - 1, to: document_y - 1).join('').chars.count
					document.remove(x: char_count_line_above - 1, y: document_y - 1)
					cursor.up
					cursor.right(char_count_line_above)
				elsif cursor.x == 0 && cursor.y == 1
					char_count_line_above = document.lines(from: document_y - 1, to: document_y - 1).join('').chars.count
					document.remove(x: char_count_line_above - 1, y: document_y - 1)
					document_y_offset -= 1
					cursor.right(char_count_line_above)
				end
			when :delete		then document.remove(x: document_x, y: document_y)
			when :tab 			then 2.times { process_key(key: :space) } 
			when :"Shift+tab" 	then cursor.left(4)
			when :escape		then change_mode
			when :"Ctrl+q"	    then quit_program
			when :"Ctrl+s"		then document.save
			else add_key_to_document(key)
		end
		true
	end

	def ctrl_keys(key)
		keys = key.to_s.split("+")
		ctrl = true
		letter = key[1]
	end

	def key_to_string(key)
		case key
			when :enter     then return "\n"
			when :space     then return " "
			else                 return key.to_s
		end
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
					self.cursor.x = margin_left_width
				else
					self.cursor.down
					self.cursor.x = margin_left_width
					process_unindent_line(line: document_y - 1)
					return_tabs(line: document_y - 1).times { process_key(key: :space) }
				end
			else self.cursor.right
		end
	end

	def add_key_to_document(key)
		self.document.insert(key: key_to_string(key), x: document_x, y: document_y)
		move_cursor_for(key: key)
	end

end