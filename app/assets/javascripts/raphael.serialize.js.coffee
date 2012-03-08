# !
#  raphaeljs.serialize
#
#  Copyright (c) 2010 Jonathan Spies
#  Licensed under the MIT license:
#  (http://www.opensource.org/licenses/mit-license.php)
#

Raphael.fn.serialize =
	paper: this

	json: (paper, minify = false) ->
		svgdata = []

		# function to serialize a node to a minified form
		serialize_min = (node) ->
			switch node.type
				when "image"
					object = "#{node.type}:#{node.attrs['src']}|#{node.attrs['x']}|#{node.attrs['y']}|#{node.attrs['width']}|#{node.attrs['height']}"
				when "ellipse"
					object = "#{node.type}:#{node.attrs['cx']}|#{node.attrs['cy']}|#{node.attrs['rx']}|#{node.attrs['ry']}"
				when "rect"
					object = "#{node.type}:#{node.attrs['x']}|#{node.attrs['y']}|#{node.attrs['width']}|#{node.attrs['height']}"
				when "text"
					object = "#{node.type}:#{node.attrs['x']}|#{node.attrs['y']}|#{node.attrs['text-anchor']}|#{node.attrs['text']}"
				when "path"
					path = ""
					if node.attrs['path'].constructor != Array
						path += node.attrs['path']
					else
						$.each node.attrs['path'], (i, group) ->
							$.each group, (index, value) ->
								if index < 1 then path += value else
									if index == (group.length - 1)
										path += value
									else path += value + ','
					object = "#{node.type}:#{path}"

		# function to serialize a single node
		serialize = (node) ->
			switch node.type
				when "image"
					object =
						type: node.type
						width: node.attrs['width']
						height: node.attrs['height']
						x: node.attrs['x']
						y: node.attrs['y']
						src: node.attrs['src']
						transform: if node.transformations then node.transformations.join(' ') else ''
				when "ellipse"
					object =
						type: node.type
						rx: node.attrs['rx']
						ry: node.attrs['ry']
						cx: node.attrs['cx']
						cy: node.attrs['cy']
						stroke: node.attrs['stroke'] if node.attrs['stroke']
						'stroke-width': node.attrs['stroke-width']
						fill: node.attrs['fill']
				when "rect"
					object =
						type: node.type
						x: node.attrs['x']
						y: node.attrs['y']
						width: node.attrs['width']
						height: node.attrs['height']
						stroke: node.attrs['stroke'] if node.attrs['stroke']
						'stroke-width': node.attrs['stroke-width']
						fill: node.attrs['fill']
				when "text"
					object =
						type: node.type
						font: node.attrs['font']
						'font-family': node.attrs['font-family']
						'font-size': node.attrs['font-size']
						stroke: node.attrs['stroke'] if node.attrs['stroke']
						fill: node.attrs['fill'] if node.attrs['fill']
						'stroke-width': node.attrs['stroke-width']
						x: node.attrs['x']
						y: node.attrs['y']
						text: node.attrs['text']
						'text-anchor': node.attrs['text-anchor']
				when "path"
					path = ""
					if node.attrs['path'].constructor != Array
						path += node.attrs['path']
					else
						$.each node.attrs['path'], (i, group) ->
							$.each group, (index, value) ->
								if index < 1 then path += value else
									if index == (group.length - 1)
										path += value
									else path += value + ','

					object =
						type: node.type
						fill: node.attrs['fill']
						opacity: node.attrs['opacity']
						translation: node.attrs['translation']
						scale: node.attrs['scale']
						path: path
						stroke: node.attrs['stroke'] if node.attrs['stroke']
						'stroke-width': node.attrs['stroke-width']
						transform: if node.transformations then node.transformations.join(' ') else ''

		# iterate through all nodes, serialize, add to array
		for node in paper.listElements()
			if node and node.type and !node.data("ignore")
				object = if minify then serialize_min node else serialize node
				log.comment "serialized #{node.type} into #{object.toString()}"
				if object
					svgdata.push object

		JSON.stringify(svgdata)

	json_min: (paper) ->
		svgdata = []

		# function to serialize a node to a minified form
		serialize = (node) ->
			switch node.type
				when "image"
					object = "#{node.type}:#{node.attrs['src']}|#{node.attrs['x']}|#{node.attrs['y']}|#{node.attrs['width']}|#{node.attrs['height']}"
				when "ellipse"
					object = "#{node.type}:#{node.attrs['cx']}|#{node.attrs['cy']}|#{node.attrs['rx']}|#{node.attrs['ry']}"
				when "rect"
					object = "#{node.type}:#{node.attrs['x']}|#{node.attrs['y']}|#{node.attrs['width']}|#{node.attrs['height']}"
				when "text"
					object = "#{node.type}:#{node.attrs['x']}|#{node.attrs['y']}|#{node.attrs['text-anchor']}|#{node.attrs['text']}"
				when "path"
					path = ""
					if node.attrs['path'].constructor != Array
						path += node.attrs['path']
					else
						$.each node.attrs['path'], (i, group) ->
							$.each group, (index, value) ->
								if index < 1 then path += value else
									if index == (group.length - 1)
										path += value
									else path += value + ','
					object = "#{node.type}:#{path}"

		# iterate through all nodes, serialize, add to array
		for node in paper.listElements()
			if node and node.type and !node.data("ignore")
				object = serialize node
				log.comment "serialized #{node.type} into #{object.toString()}"
				if object
					svgdata.push object

		JSON.stringify(svgdata)

	load_json: (paper, json, minified = false) ->
		if typeof(json) == "string" then json = JSON.parse(json)
		# allow stringified or object input
		if minified then @load_json_min(paper, json) else
			set = paper.set()
			for node in json
				try
					el = paper[node.type]().attr(node)
					set.push el
				catch e
					log.comment "Parser error: #{e}"
			set

	load_json_min: (paper, json) ->
		if typeof(json) == "string" then json = JSON.parse(json)
		log.comment("loading minimized json")
		set = paper.set()
		for node in json
			bits = node.split(":")
			geo = bits[1].split("|")
			log.comment "deserialize #{bits[0]}: #{geo}"
			switch bits[0]
				when "ellipse"
					el = paper.ellipse(geo...)
				when "rect"
					el = paper.rect(geo...)
				when "path"
					el = paper.path(geo...)
				when "text"
					el = paper.text(geo[0], geo[1], geo[3])
					el.attr("text-anchor", geo[2])
				when "image"
					el = paper.image(geo...)
			if el then set.push el
		set
