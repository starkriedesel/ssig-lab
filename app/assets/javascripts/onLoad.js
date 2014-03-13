$.fn.onLoad = function(func) {
    $(func);
    $(document).on('page:load', func);
}