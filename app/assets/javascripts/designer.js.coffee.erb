#= require raphael-min
#= require raphael.serialize
width = 960
height = 500
grid = 20

dragSource = null;
window.list = -> $("ul#log-list")

window.log =
	doUpdate: false
	current: $("ul#log-list").find("li:last").text()
	comment: (msg) -> @doUpdate = false; $("ul#log-list").append($("<li>").text(msg))
	append: (msg) -> $("ul#log-list").find("li:last").append(msg)
	update: (msg, update = @doUpdate) ->
		if update then $("ul#log-list").find("li:last").text(msg) else
			@comment(msg); @doUpdate = true
	clear: -> $("ul#log-list").empty()

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
	tool: null
	constructor: (selector, @name, @id, @width, @height, @grid) ->
		@paper = Raphael(selector, @width, @height)
		@clear(true)
		log.comment "#{selector} initialized. #{@width}x#{@height}"

	# implement mouse dragging to draw lines
	mousedown: (mouse) =>
		x = mouse.offsetX
		y = mouse.offsetY
		@tool = new SnapLine(@paper, x, y, x, y, grid)
		# when drag is initiated, register a mouse handler to move the end of the line
		$("#designer").mousemove(@mousemove)
	mousemove: (mouse) =>
		@tool.snapEnd(mouse.offsetX, mouse.offsetY) if @tool?
		log.update "  SnapLine dragged to (#{@tool.endX},#{@tool.endY})"
	# releasing the mouse unbinds the move listener (the line is already drawn to the paper)
	mouseup: (mouse) =>
		if @tool is Line and @tool.isPoint()
			@tool.erase()
		log.comment "  SnapLine finished."
		$("#designer").unbind('mousemove')
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

$.fn.designer = (width, height, gridSize = 20, designName = null, designId = 1) ->
	des = new Designer(@attr("id"), designName, designId, width, height, gridSize)
	window.designer = des
	this.mousedown(des.mousedown).mouseup(des.mouseup).keydown(des.keydown)
	this

window.saveDesign = ->
	@design.save()
