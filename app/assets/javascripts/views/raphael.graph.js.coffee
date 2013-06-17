# Class to generate graphs from a set of data points
#
class View.Graph extends View.RaphaelBase

	# Maximum number of simultaneously displayed data sets
	@MAX_DATASETS : 3
	
	# The default options for this graph
	@DEFAULTS : 
		smooth: true
		axis: '0 0 1 1'
		#axisxstep: @_dt
		shade : on
		colors: [ "rgba(140, 137, 132, 0.3)",  "rgba(1, 145, 200, 0.5)", "rgba(0, 91, 154, 0.85)" ]
		
	@AXISPADDING : 20
	
	# Construct a new Graph object
	#
	# @param title [String] The title of the graph	
	# @param parent [View.Collection] The view this graph belongs to
	# @param width [Integer] The width of the graph
	# @param height [Integer] The height of the graph
	#
	constructor: ( id , @_titletext, parent, @_width = 240, @_height = 175 ) ->
		
		unless ( @_container = $( "##{id}" ) ).length
			$( parent.container[0] ).append( @_container = $('<div id="' + id + '" class="graph"></div>') )
		
		super Raphael( id, @_width + Graph.AXISPADDING, @_height + Graph.AXISPADDING), parent

		@options = _( Graph.DEFAULTS ).clone( true )
		
		Object.defineProperty( @, 'id', 
			get: () -> return id 
		)
		
	# Clears the view
	#
	clear: () ->
		@_chart?.remove()
		@_title?.remove()
		
		@_line?.remove()
		@_line = null
		
		@_columnText?.remove()
		@_columnText = null;
		super()
		
	# Kills the view
	#
	kill: () ->
		@_container.remove()
		super()
	
	# Draws the graph
	#
	# @param x [Integer] The x coordinate
	# @param y [Integer] The y coordinate
	# @param scale [Integer] The scale
	#
	draw: ( datasets ) ->
		@clear()
		@drawTitle()
		@drawChart( datasets )

	# Draws the chart
	#
	# @param x [Integer] the x position
	# @param y [Integer] the y position
	# @param scale [Float] the scale
	# @retun [Raphael] The chart object
	#
	drawChart:( datasets ) ->
	
		xValues = []
		yValues = []

		for i, dataset of _( datasets ).first( Graph.MAX_DATASETS )
			xValues.unshift dataset.xValues
			yValues.unshift dataset.yValues
		
		options = _( @options ).clone( true )
		options.colors = _( options.colors ).last( xValues.length )
		
		@_chart = @paper.linechart( Graph.AXISPADDING, 0, 
			@_width, @_height,
			_( xValues ).clone( true ), _( yValues ).clone( true ), options )
		
		requestLine = (x) =>
			xFactor = (x - Graph.AXISPADDING - 10) / (@_width - Graph.AXISPADDING)
			@_trigger "view.graph.hover", @, [xFactor]

		@_chart.hoverColumn () ->
			requestLine( @x )

		return this

	# Move the viewbox of the chart
	#
	# @param x [Integer] The amount of pixels to move the viewbox to the right
	#
	moveViewBox: ( x ) ->
		play(x, 10)
	
	# Plays the graphs forward over a timespan
	#
	# @param x [Integer] The x to move to
	# @param time [Integer] The timespan to animate over
	play: ( x = @_width, time = 500 ) ->
		@paper.animateViewBox(x, 0, @_width, @_height, time)

	# Draws the title
	#
	# @return [JQuery] the text object
	#
	drawTitle: ( ) ->
		@_title = $('<h2>'+ @_titletext + '</h2>')
		@_container.prepend @_title
		return @_title
	
	# Draws a red line over the chart
	#
	# @param x [Integer] The x of the data to draw the line at
	#
	_drawRedLine: ( x ) ->
		unless @_line?	
			@_line = @paper
				.path( [ 'M', 0 ,0, 'V', @_height ] )
				.attr
					stroke : '#F00'
				.toFront()

		@_line.transform( "T#{x}, 0" )
		@_line.toFront()
	
	_drawColumnText: (text ) ->
		unless @_columnText? 
			@_columnText = $("<div></div>")
			@_container.append @_columnText
		@_columnText.empty()

		for i,s of text
			node = $("<p>#{s}</p>")
			@_columnText.append node
	
	# Shows a column
	#
	# @param xFactor [Float] The relative location of the column to the width of the graph
	# @param text [String] The text to show for the column
	#
	showColumn: ( xFactor , text ) ->
		x = (@_width - Graph.AXISPADDING) * xFactor + Graph.AXISPADDING

		# Add 10 magically for the axis
		x += 10 

		@_drawRedLine(x)
		@_drawColumnText(text )
