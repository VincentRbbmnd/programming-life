class View.Module
	
	# Creates a new module view
	# 
	# @param module [Model.Module] the module to show
	#
	constructor: ( module ) ->
		@_paper = Main.view.paper

		@module = module		
		@type = module.constructor.name
		@name = module.name
		
		@_x = 0
		@_y = 0
		@_scale = 0

		@_selected = false		

		$(document).on('moduleInvalidated', @onModuleInvalidated)
		
	# Generates a hashcode based on the module name
	#
	# @param hashee [String] the name to use as hash
	# @returns [Integer] the hashcode
	#
	hashCode : ( hashee = @name ) ->
		hash = 0
		return hash if ( hashee.length is 0 )
		for i in [ 0...hashee.length ]
			char = hashee.charCodeAt i
			hash = ( (hash << 5) - hash ) + char;
			hash = hash & hash # cast to 32 bit int
		return hash
	
	# Generates a colour based on the module name
	#
	# @param hashee [String] the name to use as hash
	# @returns [String] the CSS color
	#
	hashColor : ( hashee = @name ) ->
		return '#' + md5( hashee ).slice(0, 6) #@numToColor @hashCode hashee
		

	# Generates a colour based on a numer
	#
	# @param num [Integer] the seed for the colour
	# @param alpha [Boolean] if on, uses rgba, else rgb defaults to off
	# @param minalpha [Integer] the minimum alpha if on, defaults to 127
	# @returns [String] the CSS color
	#
	numToColor : ( num, alpha = off, minalpha = 127 ) ->
		num >>>= 0
		# TODO use higher order bytes too when no alpha
		b = ( num & 0xFF )
		g = ( num & 0xFF00 ) >>> 8
		r = ( num & 0xFF0000 ) >>> 16
		a = ( minalpha ) / 255 + ( ( ( num & 0xFF000000 ) >>> 24 ) / 255 * ( 255 - minalpha ) )
		a = 1 unless alpha
		# (0.2126*R) + (0.7152*G) + (0.0722*B) << luminance
		return "rgba(#{[r, g, b, a].join ','})"
		
	# Runs if module is invalidated
	# 
	# @param event [Object] the event raised
	# @param module [Model.Module] the module invalidated
	#
	moduleInvalidated: ( event, module ) =>
		if module is @module
			@draw(@_x, @_y, @_scale)

	# Draws this view and thus the model
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Integer] the scale
	#
	draw: ( x, y, scale ) ->
		@_x = x
		@_y = y
		@_scale = scale
		@_color = @hashColor()

		padding = 8 * scale

		if @_selected
			padding = 20 * scale

		@_contents?.remove()
		@_paper.setStart()
		
		switch @type
		
			when 'Transporter'
			
				# This path constructs the arrow we are showing as a transporter
				arrow = @_paper.path("m #{x},#{y} 0,4.06536 85.154735,0 -4.01409,12.19606 27.12222,-16.26142 -27.12222,-16.26141 4.01409,12.19606 -85.154735,0 z")
				arrow.node.setAttribute('class', 'transporter-arrow')
					
				rect = arrow.getBBox()
				dx = rect.x - x
				dy = rect.y - y
				arrow.translate(-dx - rect.width / 2, 0)
				arrow.scale(scale, scale)

				# This is the circle in which we show the substrate
				substrate = @module.orig ? "..."
				substrate_text = _.escape _( substrate ).first()
				substrateCircle = @_paper.circle(x, y, 20 * scale)
				substrateCircle.node.setAttribute('class', 'transporter-substrate-circle')
				substrateCircle.attr
					'fill': @hashColor substrate_text
				substrateText = @_paper.text( x, y, substrate_text )
				substrateText.node.setAttribute('class', 'transporter-substrate-text')
				substrateText.attr
					'font-size': 18 * scale
					
				if @_selected
				
					# Add transporter text
					text = @_paper.text(x, y - 60 * scale, _.escape @type)
					text.attr
						'font-size': 20 * scale

					objRect = arrow.getBBox()
					textRect = text.getBBox()

					# Add title line
					line = @_paper.path("M #{Math.min(objRect.x, textRect.x) - padding},#{objRect.y - padding} L #{Math.max(objRect.x + objRect.width, textRect.x + textRect.width) + padding},#{objRect.y - padding} z")
					line.node.setAttribute('class', 'module-seperator')

					text = @_paper.text(x, y - 60 * scale, _.escape @type)
					text.attr
						'font-size': 20 * scale
			
			when "Substrate"			
				substrate = @module.name ? "..."
				substrate_text = _.escape _( substrate ).first()
				substrateCircle = @_paper.circle(x, y, 20 * scale)
				substrateCircle.node.setAttribute('class', 'transporter-substrate-circle')
				substrateCircle.attr
					'fill': @hashColor substrate_text
				substrateText = @_paper.text( x, y, substrate_text )
				substrateText.node.setAttribute('class', 'transporter-substrate-text')
				substrateText.attr
					'font-size': 18 * scale
					
				if @_selected
				
					# Add transporter text
					text = @_paper.text(x, y - 60 * scale, _.escape @type)
					text.attr
						'font-size': 20 * scale

					textRect = text.getBBox()
					objRect = substrateCircle.getBBox()

					# Add title line
					line = @_paper.path("M #{Math.min(objRect.x, textRect.x) - padding},#{objRect.y - padding} L #{Math.max(objRect.x + objRect.width, textRect.x + textRect.width) + padding},#{objRect.y - padding} z")
					line.node.setAttribute('class', 'module-seperator')

					text = @_paper.text(x, y - 60 * scale, _.escape @type)
					text.attr
						'font-size': 20 * scale
			
			else
				text = @_paper.text(x, y, _.escape @type)
				text.attr
					'font-size': 20 * scale

		@_contents = @_paper.setFinish()

		# Draw a box around all contents
		@_box?.remove()
		if @_contents?.length > 0
			rect = @_contents.getBBox()
			if rect
				@_box = @_paper.rect(rect.x - padding, rect.y - padding, rect.width + 2 * padding, rect.height + 2 * padding)
				@_box.node.setAttribute('class', 'module-box')
				@_box.attr
					r: 10 * scale
				@_box.insertBefore(@_contents)

		# Draw close button in the top right corner
		@_close?.remove()
		if @_selected
			rect = @_box?.getBBox()
			if rect
				@_close = @_paper.circle(rect.x + rect.width, rect.y, 15 * scale)
				@_close.node.setAttribute('class', 'module-close')
				@_close.click =>
					@_selected = false
					@draw(@_x, @_y, @_scale)
				#@_close.insertBefore(@_contents)

		# Draw shadow around module view
		@_shadow?.remove()
		@_shadow = @_box?.glow
			width: 35
			opacity: .125
		@_shadow?.scale(.8, .8)

		# Draw hitbox in front of module view to detect mouseclicks
		@_hitBox?.remove()
		if not @_selected
			rect = @_box?.getBBox()
			if rect
				@_hitBox = @_paper.rect(rect.x, rect.y, rect.width, rect.height)
				@_hitBox.node.setAttribute('class', 'module-hitbox')
				@_hitBox.click => 
					@_selected = true
					@draw(@_x, @_y, @_scale)

(exports ? this).View.Module = View.Module