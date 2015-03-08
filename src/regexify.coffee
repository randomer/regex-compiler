escapeSpecialChars = (str) ->
	return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")

isEmpty = (obj) ->
	#! Doesn't check for inherited properties
	if obj == null then return true
	
	if obj.length > 0 then return false
	if obj.length == 0 then return true

	for key of obj
		return false
	
	return true

applyRules = (rulesObj) ->
	result = ''

	if rulesObj.constructor == Array
		return '(?:' + rulesObj.join('|') + ')'
	else if rulesObj.constructor == RegExp
		# [compatibility] https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/source#Example.3A_Empty_regular_expressions_and_escaping
		return '(?:' + rulesObj.source + ')'

	rule = rulesObj.chars
	if rule
		if typeof rule == 'string' || rule instanceof String
			# A..z -> A-z:
			chars = rule.split /\s+/
			if chars[0] == '' then chars.splice 0, 1
			if chars[chars.length-1] == '' then chars.splice chars.length-1, 1
			for c, i in chars
				rangeRegex = /^(\w)\.\.(\w)$/
				if rangeRegex.test c
					chars[i] = c.replace rangeRegex, '$1-$2' # ? Check whether the order is correct (e.g. 4..9 is incorrect)
				else if c == '\\s'
					chars[i] = ' '
				else if c.length > 1
					throw Error "#{c} is not a single character"
				else if c=='\\' || c=='-' || c==']'
					chars[i] = '\\' + c
			result += '[' + chars.join('') + ']'
		else # Error
			throw TypeError "The \"chars\" property is not a string"
	else
		throw Error 'The \"chars\" property is not defined'
	
	rule = rulesObj.length
	if rule
		# Format: 1-20
		if /^\d+-\d+$/.test rule
			# rule[rule.indexOf '-'] = ','
			length = rule.replace '-', ','
		else if /^\d+\+$/.test rule
			length = rule.replace '+', ','
		else if /^\d$/.test rule
			length = rule
		else
			throw Error 'The length property has incorrect format'
		result = "(?:#{result}){#{length}}"

	return result

class Pattern
	constructor: (@obj) ->
		if !@obj.pattern?
			e = new Error('The "pattern" property is not defined')
			e.id = 1
			throw e
		if @obj.pattern == ''
			e = new Error('The "pattern" property is an empty string')
			e.id = 2
			throw e
	getKeys: -> return @obj.pattern.split /(\W+)/
	checkKeys: -> # throws an error if something is not right
		keys = for k in @getKeys()
			# [performance] Would it be faster to use .char() ?
			if k.search(/\w/) != -1
				k
			else
				continue

		for k in keys
			v = @obj[k]
			# Check if 'v' is an object:
			if v != null && typeof v == 'object' # && !(v instanceof Array)
				continue
			else if v == undefined
				e = new Error "'#{k}' is not described"
				e.id = 4
				throw e
			else
				e = new Error "'#{k}' is not an object"
				e.id = 5
				throw e
	getRegex: ->
		@checkKeys()
		regex = []
		for k in @getKeys()
			if k.search(/\w/) != -1
				if !isEmpty(@obj[k]) || @obj[k].constructor == RegExp # Pattern
					regex.push applyRules @obj[k]
				else # Literal word
					regex.push k
			else # Symbols
				regex.push escapeSpecialChars k
		result = RegExp('\\b' + regex.join('') + '\\b')
		# result = new RegExp(regex.join(''))
		console.log '\t' + result
		return result

regexify = (patternObj) ->
	if !patternObj.pattern
		'test'
		# .pattern is empty/doesn't exist
	
	# Extract the keys
	keys = patternObj.pattern.split /(\W+)/

	# Check whether the pattern starts with a symbol
	# if !keys
		# keys[1] is a symbol
		
root = exports ? window
root.Pattern = Pattern