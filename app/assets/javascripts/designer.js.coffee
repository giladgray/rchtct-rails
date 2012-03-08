#= require raphael-min
#= require raphael.graphpaper

width = 960
height = 500
grid = 20

dragSource = null

window.list = -> $("ul#log-list")

window.log =
	log: null   # DOM object to write log into
	tag: "li"   # tag to wrap log entries in
	doUpdate: false
	# gets the most recent log entry
	# current: @log.find("#{@tag}:first").text() if @log?
	# adds a new comment to the log
	comment: (msg) -> @doUpdate = false; @log.prepend($("<#{@tag}>").text(msg)) if @log?
	# appends text to the current comment
	append: (msg) -> @log.find("#{@tag}:first").append(msg) if @log?
	# updates the text of the current comment if update=true
	update: (msg, update = @doUpdate) ->
		if update then (@log.find("#{@tag}:first").text(msg) if @log?) else
			@comment(msg)
			@doUpdate = true
	# clears all entries from the log
	clear: -> @log.empty()
# jQuery plugin that sets the logger to be this div
$.fn.logger = (tag = "li") ->
	log.log = this
	log.tag = tag

# draws a square grid in the given color
Raphael.fn.drawGrid = (x, y, width, height, gridSize, color) ->
	color = color || "#000"
	# construct the path in SVG format into an array
	# original code from {google:"assembla os-sim raphael drawgrid.js"}, translated and improved by me
	path = ["M", Math.round(x) + 0.5, Math.round(y) + 0.5, "L", Math.round(x + width) + 0.5, Math.round(y) + 0.5, Math.round(x + width) + 0.5, Math.round(y + height) + 0.5, Math.round(x) + 0.5, Math.round(y + height) + 0.5, Math.round(x) + 0.5, Math.round(y) + 0.5]
	for i in [1..height / gridSize]
		path = path.concat(["M", Math.round(x) + 0.5, Math.round(y + i * gridSize) + 0.5, "H", Math.round(x + width) + 0.5])
	for i in [1..width / gridSize]
		path = path.concat(["M", Math.round(x + i * gridSize) + 0.5, Math.round(y) + 0.5, "V", Math.round(y + height) + 0.5])
	# create the path by joining all the little lines and give them some color.
	# also set the data ignore attribute so we can exclude it from JSON
	this.path(path.join(",")).attr({stroke: color}).data("ignore", "true")

# returns an array of the elements in this paper
Raphael.fn.listElements = (ignore = true) ->
	list = []
	`for(node = this.bottom; node != null; node = node.next) {
		if(!node.data("ignore") || !ignore)	list.push(node)
	};`
	list

# easy getter/setters for center coordinates of element
Raphael.el.cx = (val) -> this.attr("cx", val)
Raphael.el.cy = (val) -> this.attr("cy", val)
Raphael.el.pos = (x,y) -> this.cx(x).cy(y)
Raphael.el.eql = (obj) -> this.cx() == obj.cx() and this.cy() == obj.cy()

# a line! two connected points
class Line
	valid: false
	# constructor takes in coordinates of two endpoints
	constructor: (@paper, startX, startY, endX = startX, endY = startY) ->
		@start = @paper.circle(startX, startY, 4).attr("stroke", "#0f0")
		@end = @paper.circle(endX, endY, 5).attr("stroke", "#f00")
		@node = @paper.path()
		@valid = true
	# geometry methods
	setStart: (x, y) ->
		@start.cx(x).cy(y)
		@redraw()
	setEnd: (x, y) ->
		@end.cx(x).cy(y)
		@redraw()
	width: -> Math.abs(@end.cx() - @start.cx())
	height: -> Math.abs(@end.cy() - @start.cy())
	isPoint: -> @start.eql(@end)
	# update node attributes (do not create new object)
	redraw: -> @node.attr("path", "M#{@start.cx()} #{@start.cy()} L#{@end.cx()} #{@end.cy()}")
	# stuff for concluding tool use: remove node, remove start/end points
	erase: -> @node.remove(); @finish()
	finish: -> @start.remove(); @end.remove(); @valid = false

# a line that automatically snaps to a given grid size
class window.SnapLine extends Line
	# constructor takes in snapsize, snaps start and end points
	constructor: (paper, startX, startY, endX = startX, endY = startY, @snapSize = grid) ->
		super paper, @snap(startX), @snap(startY), @snap(endX), @snap(endY)
		log.comment "new SnapLine at (#{@start.cx()},#{@start.cy()}). snap=#{@snapSize}"
	# does the actual snapping! offset by snap/2 to center snap region on point
	snap: (p, snap = @snapSize) -> p + snap / 2 - (p - snap / 2) % snap
	# two setters that handle the snapping for each endpoint. subtract remainder to round to whole multiple, offset by grid/2.
	setStart: (x, y) ->	super @snap(x), @snap(y)
	setEnd:   (x, y) ->	super @snap(x), @snap(y)

# rectangle that automatically snaps to the grid
class SnapRectangle extends SnapLine
	constructor: (paper, x, y, width = 0, height = 0, snapSize = grid) ->
		# construct start and end points via base classes
		super paper, x, y, x + width, y + height, snapSize
		# change the node object to be a rectangle
		@node.remove()
		@node = paper.rect(@start.cx(), @start.cy(), @width(), @height())
	redraw: ->
		# put x,y in top left corner of shape
		x = Math.min(@start.cx(), @end.cx())
		y = Math.min(@start.cy(), @end.cy())
		# update attributes on node object
		@node.attr("x", x).attr("y", y).attr("width", @width()).attr("height", @height())

class Label extends Line
	constructor: (paper, x, y, @snapSize = grid) ->
		super paper, x, y
		@start.remove()
		@node.remove()
		@text = prompt "Enter Label Text"
		if @text?
			@node = paper.text x, y, @text.toUpperCase()
		else @finish()
	redraw: -> @node.attr("x", @end.cx()).attr("y", @end.cy() - 5)
	finish: -> @end.remove()

######################################
###   WHAT   GRAPHPAPER     WHAT   ###
######################################
class GraphPaper
	constructor: (selector, @width, @height, @gridSize) ->
		@paper = Raphael(selector, @width, @height)
		@clear(true)
	addJSON: (json) -> @paper.add json
	# erase all elements from the designer's paper (user confirm first)
	clear: (force = false) ->
		if force or confirm "Clear design?"
			@paper.clear()
			@paper.drawGrid(0, 0, @width, @height, @gridSize, "#eee")
$.fn.graphpaper = (width, height, gridSize, json) ->
	paper = new GraphPaper(@attr("id"), width, height, gridSize)
	#paper.addJSON(json) if json?
	Raphael.fn.serialize.load_json(paper.paper, json, true) if json?
	this.addClass("designer")

######################################
###   BOOM     DESIGNER     BOOM   ###
######################################
class Designer extends GraphPaper
	selection: null
	tool: null
	constructor: (selector, @name, @id, @width, @height, @grid) ->
		super selector, @width, @height, @grid
		@selection = @paper.set()
		log.comment "#{selector} initialized. #{@width}x#{@height}"

	# implement mouse dragging to draw lines
	mousedown: (mouse) =>
		switch mouse.which
			when 1
				if @tool? then @tool.finish(); @tool = null else
					x = mouse.offsetX
					y = mouse.offsetY
					if mouse.shiftKey then @tool = new SnapRectangle(@paper, x, y) else
						if mouse.altKey then @tool = new Label(@paper, x, y) else
							@tool = new SnapLine(@paper, x, y)
					# when drag is initiated, register a mouse handler to move the end of the line
					$("#designer").mousemove(@mousemove)
	mousemove: (mouse) =>
		if @tool? and @tool.valid
			@tool.setEnd(mouse.offsetX, mouse.offsetY)
			log.update "  SnapLine dragged to (#{@tool.end.cx()},#{@tool.end.cy()})"
		log.append "[CTRL]" if mouse.ctrlKey
		log.append "[ALT]" if mouse.altKey
		log.append "[SHIFT]" if mouse.shiftKey
	# releasing the mouse unbinds the move listener (the line is already drawn to the paper)
	mouseup: (mouse) =>
		switch mouse.which
			when 1  # LEFT click
				if @tool.isPoint()
					@tool.erase()
					x = SnapLine.prototype.snap(mouse.offsetX, grid)
					y = SnapLine.prototype.snap(mouse.offsetY, grid)
					elem = @paper.getElementByPoint(x, y)
					log.comment "select at (#{x},#{y}) -> #{elem}"
					if elem? and not elem.data("ignore")
						elem.attr("stroke", "red")
						@selection.push(elem)
						log.comment "#{elem.type} added to selection"
				else
					@tool.finish()
					log.append(" added.")
				$("#designer").unbind('mousemove')
		# when 2  # MIDDLE click
		# when 3  # RIGHT click
		@tool = null
	# key presses in a switch statement!
	keydown: (keys) ->
		switch keys.which
			when 32 then alert "spacebar!"  # spacebar
			when 27 then @line = null       # esc
	# serialize the design and save it to the DB
	save: ->
		json_content = Raphael.fn.serialize.json(@paper, true)
		alert json_content
		$("#save-btn").button('loading')
		$.post "/designs/#{@id}/save", {design: {id: @id, name: @name, content: json_content}}, (data, msg) ->
			log.comment "Save #{msg}!"
			$("#save-btn").button('reset')
	load: (contents) ->
		log.comment("loading #{contents}")
		Raphael.fn.serialize.load_json(@paper, contents, true)

# the jquery plugin function! creates a designer object and attaches all the event listeners.
# the designer object is stored in window.designer for easy access anywhere.
$.fn.designer = (width, height, gridSize = 20, designName = null, designId = 1) ->
	des = new Designer(@attr("id"), designName, designId, width, height, gridSize)
	window.designer = des
	this.mousedown(des.mousedown).mouseup(des.mouseup).keydown(des.keydown)
	# TODO: touch input
	this.addClass("designer")


# initialize the log when the document is ready
$(document).ready -> $("ul#log-list").logger()