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
//= require jquery.turbolinks
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require bootstrap
//= require jquery.xcolor.min
//= require_tree .

$(function () {
    $('.label.fraction').each(function (i, label) {
        var obj = $(label);
        var n = parseInt(obj.find('.numerator').html());
        var d = parseInt(obj.find('.denominator').html());
        if(d == 0)
            d = 1;
        if(obj.hasClass('binary')) {
            if(n == d)
                obj.css('background-color', '#468847');
            else if(n != 0) {
                var color = $.xcolor.gradientlevel('#999', '#468847', 50, 100);
                obj.css('background-color', color.getColor());
            }
        } else {
            var color = $.xcolor.gradientlevel('#999', '#468847', n, d);
            obj.css('background-color', color.getColor());
        }
    });
});