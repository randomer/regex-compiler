chai = require 'chai'
chai.should()
expect = chai.expect

{Pattern} = require('../src/regexify.coffee')

getExampleObject = ->
	pattern: 'protocol://www.subdomain.domain.tld/address/'
	protocol: {}
	www: {}
	subdomain: {}
	domain: {}
	tld: {}
	address: {}

fullMatch = (str, r) ->
	match = str.match r
	if match == null
		console.log "#{str} -> null"
		return false
	else
		return match[0] == str

describe 'Pattern', ->
	ptn = null
	# Error tests:
	it 'should throw an error if no "pattern" property', ->
		(-> new Pattern {}).should.throw 'The "pattern" property is not defined'
	it 'should throw an error if empty string', ->
		result = (-> new Pattern {pattern: ''})
		result.should.throw 'The "pattern" property is an empty string'
		# TODO: Check the error's ID
	it 'should return a set of correct keys', ->
		ptn = new Pattern getExampleObject()
		expect(ptn.getKeys()).to.eql [ # Deep equal
			'protocol'
			'://'
			'www'
			'.'
			'subdomain'
			'.'
			'domain'
			'.'
			'tld'
			'/'
			'address'
			'/'
			''
		]
	it 'should check whether every key is described', ->
		keysObject = getExampleObject()
		delete keysObject.www
		ptn = new Pattern keysObject
		(-> ptn.checkKeys()).should.throw "'www' is not described"
	it 'should check whether every key is an object', ->
		keysObject = getExampleObject()
		keysObject.protocol = null
		ptn = new Pattern keysObject
		(-> ptn.checkKeys()).should.throw "'protocol' is not an object"
		keysObject = getExampleObject()
		keysObject.subdomain = []
		ptn = new Pattern keysObject
		(-> ptn.checkKeys()).should.throw "'subdomain' is not an object"
		keysObject = getExampleObject()
		keysObject.domain = -> retrun 0
		ptn = new Pattern keysObject
		(-> ptn.checkKeys()).should.throw "'domain' is not an object"
	# Regex tests:
	it 'should escape special characters', ->
		r = new Pattern
			pattern:	'filename.ext'
			filename: {}
			ext: {}
		.getRegex()
		expect(r.test('filenameXext')).to.be.false
	it 'should match a string literally if there\'s no "key(s)" property specified', ->
		keysObject = getExampleObject()
		ptn = new Pattern keysObject
		r = ptn.getRegex()
		expect(fullMatch 'protocol://www.subdomain.domain.tld/address/', r).to.be.true
		# r.test(keysObject.pattern).should.be.true
		# keysObject.pattern.test(r).should.be.true
	it 'should check for the chars property', ->
		keysObj =
			pattern: 'filename.ext'
			filename:
				chars: 'A..z 0..9 -'
			ext:
				chars: 'A..z 0..9'
		r = new Pattern(keysObj).getRegex()
		# [todo] Test for full match
		str = 'a.b'
		expect(str.match(r)[0]).to.equal str
		str = 'ab'
		expect(str.match(r)).to.be.null

	it 'should check for given length', ->
		r = new Pattern
			pattern: 'filename.ext'
			filename:
				chars: 'A..z 0..9 -'
				length:	'1+'
			ext:
				chars: 'A..z 0..9'
				length:	'1-3'
		.getRegex()
		expect(fullMatch 'longfilename.rar', r).to.be.true
		# expect(fullMatch 'hello-world.js', r).to.be.false
		r.test('file.extension').should.be.false

		expect(fullMatch 'file.exe', r).to.be.true
		
		r = new Pattern # Phone number
			pattern: 'nnn-nnnn'
			nnn:
				chars: '0..9'
				length: '3'
			nnnn:
				chars: '0..9'
				length: '4'
		.getRegex()
		expect(fullMatch '555-5555', r).to.be.true
