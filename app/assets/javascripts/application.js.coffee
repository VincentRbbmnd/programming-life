# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require jquery_nested_form
#= require json2
#= require lodash.custom
#= require locache
#= require big.min
#= require jquery.svg.js
#= require jquery.svgdom.patched.js
#
#= require MVC
#
#= require_tree ./helpers
#= require_tree ./models
#= require_tree ./views
#= require_tree ./controllers
#
#= require bootstrap
#= require raphael.min
#= require g.raphael-min
#= require g.bar-min
#= require g.pie-min
#= require g.dot-min
#= require g.line-min
#= require raphael-triangle
#= require raphael-arrow
#= require raphael-animatevb
#
#= require chart
#= require md5.min
#= require numeric-1.2.6
#= require numeric.async
#
#= require_tree .
'use strict'
$( () ->
	$( window.applicationCache ).on( 'error', () ->
		console.error 'There was an error when loading the cache manifest.'
		console.warn arguments
	)
)