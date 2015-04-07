module Patterns

	WORDS = %w[
    	and def end in or unless begin
    	defined? ensure module redo super until
    	BEGIN break do next rescue then
    	when END case else for retry attr_accessor
    	attr_reader attr_writer
    	while alias class elsif if not return
    	undef yield nil true false self
	    DATA ARGV ARGF ENV
	    FALSE TRUE NIL]

	TABBED_ON_NEWLINE = %w[
		def class if else elsif BEGIN do 
		while when case for	
	]

	UNTABBED_ON_NEWLINE = %w[
	    end
	]

	DECIMAL = /\d+(?:_\d+)*/
  	OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
  	HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
  	BINARY = /0b[01]+(?:_[01]+)*/

  	METHOD_NAME_OPERATOR = /
	    \*\*?           # multiplication and power
	    | [-+~]@?       # plus, minus, tilde with and without at sign
	    | [\/%&|^`]     # division, modulo or format strings, and, or, xor, system
	    | \[\]=?        # array getter and setter
	    | << | >>       # append or shift left, shift right
	    | <=?>? | >=?   # comparison, rocket operator
	    | ===? | =~     # simple equality, case equality, match
	    | ![~=@]?       # negation with and without at sign, not-equal and not-match
	    | [+=]?
	/ox
  
  	EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
  	FLOAT_SUFFIX = / #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? /ox
  	FLOAT_OR_INT = / #{DECIMAL} (?: #{FLOAT_SUFFIX} () )? /ox
  	NUMERIC = / (?: (?=0) (?: #{OCTAL} | #{HEXADECIMAL} | #{BINARY} ) | #{FLOAT_OR_INT} ) /ox
  
	KEYWORDS = /(?<=^|\s)(#{WORDS.join('|')})(?![a-zA-Z])/
	INDENT = /(?<=^|\s)(#{TABBED_ON_NEWLINE.join('|')})(?![a-zA-Z])/
	UNINDENT = /(?<=^|\s)(#{UNTABBED_ON_NEWLINE.join('|')})(?![a-zA-Z])/

	def positions(pattern:, string:)
		string.enum_for(:scan, pattern).map { $~.offset(0) }
	end

	def pattern_keywords
		@pattern_keywords ||= KEYWORDS
	end

	def pattern_method_names
		@pattern_method_names ||= /(?<=def )[a-zA-Z_\?]+(?=\s|\(|\=)/
	end

	def pattern_numeric
		@pattern_numeric ||= NUMERIC
	end

	def pattern_symbols
		@pattern_symbols ||= /(?<=\s)(:[a-zA-Z_]+)/
	end

	def pattern_hash
		@pattern_hash ||= /(?<=\s|^|\()([a-zA-Z_]+:)/
	end

	def pattern_variable
		@pattern_variable ||= /(?<=\s|^|\()(@[a-zA-Z_]+)/
	end

	def pattern_class
		@pattern_class ||= /(?<=\s)(self|[A-Z][A-Za-z_\?\!\=]+)(?=\s|.)/
	end

	def pattern_comment
		@pattern_comment ||= /(#(?!{)[^\n]+)/
	end

	def pattern_quote_string
		@pattern_single_quote_string ||= /((?<![\\])['"])((?:.(?!(?<![\\])\1))*.?)\1/
	end

	def pattern_operators
		@pattern_method_name_operator ||= METHOD_NAME_OPERATOR
	end

	def pattern_indent_on_newline
		@pattern_indent_on_new_line ||= INDENT
	end

	def pattern_unindent_on_newline
		@pattern_unindent_on_newline ||= UNINDENT
	end

	def pattern_current_indent
		/([  ][ ]+)./
	end

	def pattern_blank_line
		/(([ ]+\n)|(\^\n))/
	end

	def blank?(string:)
		!string.match(pattern_blank_line).nil?
	end

	def space_count(string:)
		string.chars.count
	end

	def last_line_with_text(num:)
		if num >= 0
			text = document.line(num: num)
			if !blank?(string: text)
				return num
			else
				return last_line_with_text(num: num - 1)
			end
		else
			0
		end
	end

	def process_indent(string:)
		string.match(pattern_indent_on_newline) ? 2 : 0
	end

	def process_unindent(string:)
		string.match(pattern_unindent_on_newline) ? -2 : 0
	end

	def process_unindent_line(line:)
		text = document.line(num: line)
		match = text.match(pattern_unindent_on_newline)
		if match 
			2.times { document.remove(x: 0, y: line) } if text.match(pattern_current_indent)
		end
	end

	def return_tabs(line:)
		text = document.line(num: last_line_with_text(num: line))
		match = text.match(pattern_current_indent)
		match ? space_count(string: match[1]) + process_indent(string: text) : process_indent(string: text)
	end

end