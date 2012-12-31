// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require prettify
//= require jquery_nested_form
//= require_tree .

// Use prettyprint for code blocks
$(function() { prettyPrint(); });

// Show Bootstrap style tooltips for any thing with rel="tooltip"
$(function() { $('[rel=tooltip]').tooltip(); });

// NestForms - Boostrap compatability
$(function() {
  window.NestedFormEvents.prototype.insertFields = function(content, assoc, link) {
    var $location = $(link).closest('div.control-group');
    return $(content).insertBefore($location);
  };
});
