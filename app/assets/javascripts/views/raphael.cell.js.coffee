# Class to generate a view for a cell model
#
# @concern Mixin.EventBindings
#
class View.Cell extends View.RaphaelBase

	@concern Mixin.EventBindings
	@concern Mixin.DynamicProperties

	# Constructor for this view
	# 
	# @param paper [Raphael] paper parent
	# @param parent [View.RaphaelBase] base view
	# @param cell [Model.Cell] cell to view
	# @param interaction [Boolean] the interaction flag
	# 	
	constructor: ( paper, parent, cell, @_interaction = on ) ->
		super paper, parent
		
		@viewsByType = {}
		@_splines = []

		@_width = @paper.width
		@_height = @paper.height
		
		@_allowEventBindings()
		@_defineAccessors()
		@model = cell

		
	# Defines the accessors for this view
	#
	_defineAccessors: () ->

		@property
			_model:
				value: undefined
				configurable: false
				enumerable: false
				writable: true

		@getter
			model: ( ) ->
				return @_model
			_views: ( ) ->
				return (_.flatten(_.map(@viewsByType, _.values))).concat(@_splines)

		@setter
			model: @setCell
		
	# Adds interaction to the cell
	#
	_addInteraction: () ->
		@_notificationsView = new View.CellNotification( @, @model )

	# Sets the displayed cell to value
	#
	# @param value [Model.Cell] the cell to display
	#
	setCell: ( value ) ->
			
		@kill()
		
		@_model = value
		@_addInteraction() if @_interaction
			
		@_trigger( 'view.cell.set', @, [ @model ] )

		@redraw() if @x? and @y?
		return this
	
	# Kills the cell view by resetting itself and its children
	#
	kill: () ->
		super()
		
		@_notificationsView?.kill()
		@viewsByType = {}
		
	# Returns the bounding box of this view
	#
	# @return [Object] a bounding box object with coordinates
	#
	getBBox: ( ) -> 
		return @_shape?.getBBox() ? { x:0, y:0, x2:0, y2:0, width:0, height:0 }

	# Returns the coordinates of either the entrance or exit of this view
	#
	# @param location [View.Module.Location] the location (entrance or exit)
	# @return [<float, float>] a tuple of the x and y coordinates
	#
	getPoint: ( location ) ->
		box = @getBBox()

		switch location
			when View.Module.Location.Left
				return [box.x ,@y]
			when View.Module.Location.Right
				return [box.x2 ,@y]
			when View.Module.Location.Top
				return [@x, box.y]
			when View.Module.Location.Bottom
				return [@x, box.y2]
			when View.Module.Location.Center
				return [@x, @y]

	#
	#
	getAbsolutePoint: ( location ) ->
		[x, y] = @getPoint(location)
		return @getAbsoluteCoords(x, y)

	# Add a view to draw in the container
	#
	# @param view [View.Base] The view to add
	#
	add: ( view ) ->
		type = view.model.getFullType()

		unless @viewsByType[ type ]?
			@viewsByType[ type ] = []

		@viewsByType[ type ].push view unless view instanceof View.DummyModule
		view.draw()
		@_notificationsView?.hide()
		return this
		
	# Add a preview
	#
	addPreview: ( view ) ->
		@add view
		unless @viewsByType[ '__previews' ]?
			@viewsByType[ '__previews' ] = []
		@viewsByType[ '__previews' ].push view
		
	# Removes a view from the container
	#
	# @param [View.Base] The view to remove
	#
	remove: ( view, kill = on ) ->
		type = view.model.getFullType()
		@viewsByType[type] = _( @viewsByType[type] ? [] ).without view
		view.kill() if kill
		@_notificationsView?.hide()
		return this
		
	# Remove all preview
	#
	removePreviews: () ->
		return this unless @viewsByType[ '__previews' ]?
		@remove view.kill() for view in @viewsByType[ '__previews' ]
		@viewsByType[ '__previews' ] = []
		return this

	# Get module view for the given module
	#
	# @param module [Module] the module for which to return the view
	# @return [Module.View] the view which represents the given module
	#
	getView: ( module ) ->
		for type, views of @viewsByType
			view = _( views ).find( (view) -> view.model is module )
			return view if view?
		return null

	# Get module view by name
	#
	# @param name [String ] the module name for which to return the view
	# @return [Module.View] the view which represents the given module
	#
	getViewByName: ( name ) ->
		for type, views of @viewsByType
			view = _( views ).find( (view) -> view.model?.name is name )
			return view if view?
		return null
	 	
	# Gets number of views by type
	#
	# @param type [String] the type
	# @return [Integer] the number of views
	#
	numberOf: ( type ) ->
		return 0 unless @viewsByType[ type ]?
		return @viewsByType[ type ].length

	# Draws the cell
	#
	# @param x [Integer] x location
	# @param y [Integer] y location
	#
	draw: (  x = 0, y = 0, @_radius = 400 ) ->
		super(x, y)

		@_drawCell()
		
	# Redraws the cell
	# 		
	redraw: () ->
		@draw( @x, @y )	
		
	# Draws the cell on coordinates
	# 
	# @param x [Integer] the center x position
	# @param y [Integer] the center y position
	# @param radius [Integer] radius of the cell
	# @return [Raphael] the cell shape
	#
	_drawCell: ( ) ->
		@_shape = @paper.circle( @x, @y, @_radius )
		@_shape.insertBefore(@paper.bottom)
		$(@_shape.node).addClass('cell' )

		@_contents.push @_shape
		return @_shape

	# Returns the location for a module view
	#
	# @return [<float, float>] a type of the x and y coordinates
	#
	getViewPlacement: ( view ) ->
		type = view.model.getFullType()
		views = @viewsByType[type] ? []

		index = views.indexOf view
		if view instanceof View.DummyModule
			index = views.length
		
		switch type
		
			when "CellGrowth"
				alpha = -3 * Math.PI / 4 + ( index * Math.PI / 12 )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )
			
			when "Lipid"
				alpha = -2 * Math.PI / 3 + ( index * Math.PI / 12 )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )

			when "Transporter-inward"
				dx = 65 * (index - 2)
				alpha = Math.PI - Math.asin( dx / @_radius )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )

			when "Transporter-outward"
				dx = 65 * (index - 2)
				alpha = Math.asin( dx / @_radius )
				x = @x + @_radius * Math.cos( alpha )
				y = @y + @_radius * Math.sin( alpha )

			when "DNA"
				x = @x 
				y = @y - @_radius + 100

			when "Metabolism"
				x = @x
				y = @y + 65 * index

			when "Protein"
				x = @x + @_radius - 200 - (100 * index)
				y = @y - @_radius + 195
				
			when "Metabolite-substrate-inside"
				radius = @_radius
				angle = Math.PI - (Math.PI / 17) * (index - 1) + (Math.PI * .02)

				x = radius * Math.cos(angle) + 200
				y = radius * Math.sin(angle)

			when "Metabolite-product-inside"
				radius = @_radius
				angle = (Math.PI / 17) * (index - 1) - (Math.PI * .02)

				x = radius * Math.cos(angle) - 200
				y = radius * Math.sin(angle)

			when "Metabolite-substrate-outside"
				radius = @_radius + 150
				angle = Math.PI - (Math.PI / 22) * (index - 2)

				x = radius * Math.cos(angle)
				y = radius * Math.sin(angle)

			when "Metabolite-product-outside"
				radius = @_radius + 150
				angle = (Math.PI / 22) * (index - 2)

				x = radius * Math.cos(angle)
				y = radius * Math.sin(angle)

		return [x, y]
	