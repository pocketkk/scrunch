# VIM COMMANDS
# 0   move to beginning of line
# $   move to end of line
# ^   move to first non-blank char of the line
# _   same as above, but can take a count to go to a different line
# g_  move to last non-blank char of the line (can also take a count as above)

# gg  move to first line
# G   move to last line
# nG  move to n'th line of file (where n is a number)

# H   move to top of screen
# M   move to middle of screen
# L   move to bottom of screen

# z.  put the line with the cursor at the center
# zt  put the line with the cursor at the top
# zb  put the line with the cursor at the bottom of the screen

# Ctrl-D  move half-page down
# Ctrl-U  move half-page up
# Ctrl-B  page up
# Ctrl-F  page down
# Ctrl-o  jump to last cursor position
# Ctrl-i  jump to next cursor position

# n   next matching search pattern
# N   previous matching search pattern
# *   next word under cursor
# #   previous word under cursor
# g*  next matching search pattern under cursor
# g#  previous matching search pattern under cursor

# %   jump to matching bracket { } [ ] ( )

module HasKeyboard

	attr_accessor :ctrl, :letter, :keystack

	def initialize
		super
	end


	def process_key_command(key:)
		common_keys(key: key)	
	end

	EXECUTE_KEYS = %w[h i j k i]
	COMMAND_KEYS = %w[d]

	DELETE 					= /((?<=^)dd(?=$))/
	DELETE_X_LINES_DOWN 	= /((?<=^)d([1-9])k(?=$))/
	DELETE_X_LINES_UP 		= /((?<=^)d([1-9])j(?=$))/
	DELETE_X_CHARS_RIGHT 	= /((?<=^)d([1-9])l(?=$))/
	DELETE_X_CHARS_LEFT 	= /((?<=^)d([1-9])h(?=$))/

	def process_key_master(key:)
		self.keystack ||= Array.new
		if self.keystack.count > 3 then
			self.keystack = Array.new
		end

		common_keys(key: key)
		add_key(key: key)

		if keystack.join('').match(DELETE)
			delete_lines(num: 1, y: document_y)
			self.keystack = []
		end
		if match = keystack.join('').match(DELETE_X_LINES_DOWN)
			delete_lines(num: match.to_a[2].to_i, y: document_y)
			self.keystack = []
		end
		return true
		# case key
		# 	when "h", :left		then
		# 		cursor.left(keystack_pop)
		# 		return false
		# 	when "l", :right	then 
		# 		cursor.right(keystack_pop)
		# 		return false
		# 	when "j", :up		then
		# 		if self.keystack.count == 0
		# 			up
		# 		else
		# 			add_key(key: key)
		# 			if keystack && keystack.count > 1 then
		# 				keystack_process
		# 			end
		# 		end
		# 	when "k", :down		then
		# 		self.keystack ||= Array.new
		# 		if self.keystack.count == 0
		# 			down
		# 		else
		# 			add_key(key: key)
		# 			if keystack && keystack.count > 1 then
		# 				keystack_process
		# 			end
		# 		end
		# 	when "i" 			then self.mode = :normal
		# 	when "d"			then 
		# 		 add_key(key: key)
		# 		 if keystack && keystack.count > 1 then
		# 		 	keystack_process
		# 		end
		# 	else add_key(key: key)
		# end
		# return true
	end



	def delete_lines(num:, y:)
		num.times {	|n| document.remove_line(y: y + n) }
	end

	def keystack_pop
		self.keystack ||= Array.new
		num = self.keystack.pop.to_i if self.keystack.count > 0
		self.keystack = []
		num ? num : 1
	end

	def process_keys
		key = keystack.pop
	end

	def integer?(key:)
		begin
			Integer(key, 10)
		rescue ArgumentError
			return false
		end
		return true
	end

	def add_key(key:)
		self.keystack ||= Array.new
		self.keystack << key
	end

	def common_keys(key:)
		case key
			when :escape		then change_mode
			when :"Ctrl+q"	    then quit_program
			when :"Ctrl+s"		then document.save
		end
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