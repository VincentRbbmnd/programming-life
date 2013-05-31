# The controller for the Undo view
#
class Controller.Undo extends Controller.Base

	# Creates a new instance of Undo
	#
	#
	#
	#
	constructor: ( @model, view ) ->
		super view ? new View.Undo( @model )
		
	setTimemachine: ( timemachine ) ->
		@view.setTree timemachine
		return this
	