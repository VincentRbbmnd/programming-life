# Simulates substrates/products/metabolites in the cell
#
# Parameters
# --------------------------------------------------------
# 
# - supply
#    - The supply per time unit
#
# Equations
# --------------------------------------------------------
#
# - this / dt
#    - supply
#
class Model.Metabolite extends Model.Module

	# Placement of the Metabolite in the cell
	@Inside = 2
	
	# Placement of the Metabolite outside the cell
	@Outside = 1
	
	# Metabolite substrate type
	@Substrate = 1
	
	# Metabolite product type
	@Product = -1

	# Constructor for Metabolite
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of metabolite, defaults to 1
	# @param name [String] the name to use
	# @param placement [Integer] placement of this metabolite, defaults to Model.Metabolite.Outside
	# @param type [Boolean] type of this metabolite, defaults to Model.Metabolite.Substrate
	# @option params [Integer] start the start amount of this metabolite
	# @option params [Integer] placement the placement
	# @option params [Integer] type the type
	#
	constructor: ( params = {}, start = 1, name, placement = Model.Metabolite.Outside , type = Model.Metabolite.Substrate ) ->
					
		# Define differential equations here
		step = ( t, compounds, mu ) ->		
			
			results = {}
			
			# Only if the components are available
			if ( @_test( compounds, @name ) )
				
				# A metabolite can be supplied to. Normally this is only true for external
				# substrates. The other metabolites have a value of 0.
				# 
				results[ @name ] = @supply
				
			return results

		# Default parameters set here
		defaults = { 
		
			# Parameters
			supply: if placement is Model.Metabolite.Outside and type is Model.Metabolite.Substrate then 1 else 0
			
			# Meta-Parameters
			placement : placement
			type : type
			
			# Start values
			starts : { name: start }
		}
		
		Object.defineProperty( @ , "_name",
			value: if params.name? then params.name else name ? undefined
			configurable: false
			enumerable: false
			writable: true
		)

		Object.defineProperty( @ , "name",
			set: ( param ) ->
				Model.EventManager.trigger( 'module.set.property', @, [ "_name", @["_name"], param ] )
				@["_name"] = param
			get: ->
				return @["_name"] + "#int" if @placement is Model.Metabolite.Inside
				return @["_name"] + "#ext" if @placement is Model.Metabolite.Outside
				return @["_name"] 
			enumerable: true
			configurable: false
		)
				
		params = _( _( params ).defaults( defaults ) ).omit( 'name' ) 
		super params, step
		
	# Constructor for External Substrates
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of metabolite, defaults to 1
	# @param name [String] the name to use
	# @option params [Integer] start the start amount of this metabolite
	# @option params [Integer] placement the placement
	# @option params [Integer] type the type
	#
	@sext: ( params = { }, supply = 1, start = 1, name = "s" ) -> 
		return new Model.Metabolite( _( params ).extend( { supply: supply } ), start, name,  Model.Metabolite.Outside, Metabolite.Substrate )
		
	# Constructor for Internal Substrates
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of metabolite, defaults to 0
	# @param name [String] the name to use
	# @option params [Integer] start the start amount of this metabolite
	# @option params [Integer] placement the placement
	# @option params [Integer] type the type
	#
	@sint: ( params = {}, start = 0, name = "s" ) -> 
		return new Model.Metabolite( params, start, name,  Model.Metabolite.Inside, Metabolite.Substrate )
	
	# Constructor for Internal Products
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of metabolite, defaults to 0
	# @param name [String] the name to use
	# @option params [Integer] start the start amount of this metabolite
	# @option params [Integer] placement the placement
	# @option params [Integer] type the type
	#
	@pint: ( params = {}, start = 0, name = "p" ) -> 
		return new Model.Metabolite( params, start, name,  Model.Metabolite.Inside, Metabolite.Product )
		
	# Constructor for External Products
	#
	# @param params [Object] parameters for this module
	# @param start [Integer] the initial value of metabolite, defaults to 0
	# @param name [String] the name to use
	# @option params [Integer] start the start amount of this metabolite
	# @option params [Integer] placement the placement
	# @option params [Integer] type the type
	#
	@pext: ( params = {}, start = 0, name = "p" ) -> 
		return new Model.Metabolite( params, start, name,  Model.Metabolite.Outside, Metabolite.Product )

(exports ? this).Model.Metabolite = Model.Metabolite