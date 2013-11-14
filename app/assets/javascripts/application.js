// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require handlebars
// require turbolinks
// require_self
// require_tree .

$(document).foundation();


var $window;
var $messages;

$(function() {
  $window = $(window);
  $messages = $('#messages');

  $window.resize(function() {
    adjustFullHeight();
  });
  adjustFullHeight();

  // $('form#new_message').on('ajax:success', function(e, data, status, xhr) {
  //   connectionStatus(true);
  // });
});


function adjustFullHeight() {
  var $sticky_footer = $('.sticky-footer');
  $('.full-height').each(function() {
    $this = $(this);
    var height = $window.height() - $this.offset().top - 80;
    if($sticky_footer.length > 0) {
      height - $sticky_footer.height() - 20;
    }
    $this.css('height', height);
  });
}

function scrollMessages(value) {
  if(value < 0) {
    $children = $messages.children();
    value = ($children.height() * $children.length) + $messages.height();
  }
  $messages.scrollTop(value);
}
