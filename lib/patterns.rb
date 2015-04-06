module Patterns

	WORDS = %w[
    	and def end in or unless begin
    	defined? ensure module redo super until
    	BEGIN break do next rescue then
    	when END case else for retry
    	while alias class elsif if not return
    	undef yield nil true false self
	    DATA ARGV ARGF ENV
	    FALSE TRUE NIL]

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
		@pattern_comment ||= /(\#[^\n]+)/
	end

	def pattern_single_quote_string
		@pattern_single_quote_string ||= /('){1}(.)+('){1}/
	end

	def pattern_double_quote_string
		@pattern_double_quote_string ||= /("){1}(.)+("){1}/
	end

	def pattern_operators
		@pattern_method_name_operator ||= METHOD_NAME_OPERATOR
	end

end