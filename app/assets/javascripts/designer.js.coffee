#= require raphael-min
#= require raphael.serialize
width = 960
height = 500
grid = 20

dragSource = null
;
window.list = -> $("ul#log-list")

window.log =
	log: null
	doUpdate: false
	# gets the most recent log entry
	current: @log.find("li:first").text() if @log?
	# adds a new comment to the log
	comment: (msg) -> @doUpdate = false; @log.prepend($("<li>").text(msg)) if @log?
	# appends text to the current comment
	append: (msg) -> @log.find("li:first").append(msg) if @log?
	# updates the text of the current comment if update=true
	update: (msg, update = @doUpdate) ->
		if update then (@log.find("li:first").text(msg) if @log?) else
			@comment(msg)
			;
			@doUpdate = true
	# clears all entries from the log
	clear: -> @log.empty()
# initialize the log when the document is ready
$(document).ready -> log.log = $("ul#log-list")

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

# a line! two connected points
class Line
# constructor takes in coordinates of two endpoints
	constructor: (paper, @startX, @startY, @endX, @endY) ->
		@node = paper.path(@getPath())
	getPath: -> "M" + @startX + " " + @startY + " L" + @endX + " " + @endY
	redraw: -> @node.attr("path", @getPath())
	setStart: (x, y) ->
		@startX = x
		@startY = y
		@redraw()
	setEnd: (x, y) ->
		@endX = x
		@endY = y
		@redraw()
	erase: -> @node.remove()
	isPoint: -> @startX == @endX and @startY == @endY

# a line that automatically snaps to a given grid size
class SnapLine extends Line
# constructor takes in snapsize, snaps start and end points
	constructor: (paper, startX, startY, endX, endY, @snapSize) ->
		super paper
		@snapStart startX, startY
		@snapEnd endX, endY
		log.comment "new SnapLine at (#{@startX},#{@startY}). snap=#{@snapSize}"
	# two setters that handle the snapping for each endpoint. subtract remainder to round to whole multiple.
	snapStart: (x, y) ->
		@setStart x - x % @snapSize, y - y % @snapSize
	snapEnd: (x, y) ->
		@setEnd x - x % @snapSize, y - y % @snapSize

######################################
###   BOOM     DESIGNER     BOOM   ###
######################################
class Designer
	selection: null
	tool: null
	constructor: (selector, @name, @id, @width, @height, @grid) ->
		@paper = Raphael(selector, @width, @height)
		@clear(true)
		@selection = @paper.set()
		log.comment "#{selector} initialized. #{@width}x#{@height}"

	# implement mouse dragging to draw lines
	mousedown: (mouse) =>
		switch mouse.which
			when 1
				x = mouse.offsetX
				y = mouse.offsetY
				@tool = new SnapLine(@paper, x, y, x, y, grid)
				# when drag is initiated, register a mouse handler to move the end of the line
				$("#designer").mousemove(@mousemove)
	mousemove: (mouse) =>
		if @tool?
			@tool.snapEnd(mouse.offsetX, mouse.offsetY)
			log.update "  SnapLine dragged to (#{@tool.endX},#{@tool.endY})"
	# releasing the mouse unbinds the move listener (the line is already drawn to the paper)
	mouseup: (mouse) =>
		switch mouse.which
			when 1  # LEFT click
				if @tool.isPoint()
					@tool.erase()
					elem = @paper.getElementByPoint(mouse.offsetX, mouse.offsetY)
					if elem?
						elem.attr("stroke", "red")
						@selection.push(elem)
						log.comment "#{elem.type} added to selection"
				else
					log.append(" added.")
				$("#designer").unbind('mousemove')
			# when 2  # MIDDLE click
			# when 3  # RIGHT click
		@tool = null
	keydown: (keys) ->
		switch keys.which
			when 32 then alert "spacebar!"  # spacebar
			when 27 then @line = null       # esc
	clear: (force = false) ->
		if force or confirm "Clear design?"
			@paper.clear()
		@paper.drawGrid(0, 0, @width, @height, @grid, "#eee")
	save: ->
		json_content = Raphael.fn.serialize.json(@paper)
		alert json_content
		$.ajax
				type: "PUT"
				url: "/designs/#{@id}"
				data: {design: {content: json_content}}
				success: (msg) -> log.comment "Save success. #{msg}"
				error: (msg) -> log.comment "Save error. #{msg}"

# the jquery plugin function! creates a designer object and attaches all the event listeners.
# the designer object is stored in window.designer for easy access anywhere.
$.fn.designer = (width, height, gridSize = 20, designName = null, designId = 1) ->
	des = new Designer(@attr("id"), designName, designId, width, height, gridSize)
	window.designer = des
	this.mousedown(des.mousedown).mouseup(des.mouseup).keydown(des.keydown)
	this
