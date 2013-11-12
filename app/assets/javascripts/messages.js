var source;
var message_page = 1;

$(function() {
  scrollMessages(-1);

  Handlebars.registerHelper('dateFormat', function(text) {
    // text = Handlebars.Utils.escapeExpression(text);
    var date = new Date(text);
    var formatted = (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear();

    return new Handlebars.SafeString(formatted);
  });

  var message_template = Handlebars.compile($('#message-template').html());


  source = new EventSource('/messages/events');
  var message;

  source.addEventListener('messages.create', function(e) {
    data = JSON.parse(e.data);
    var message_data = {
      username: data.username,
      content: data.message.content,
      created_at: data.message.created_at
    }
    $messages.append(message_template(message_data));
    scrollMessages(-1);
  });


  $.get('/messages', {page: 1}, function(data) {
    message_page += 1;
    $.each(data, function(index, value) {
      $messages.append(message_template(value));
    });
    scrollMessages(-1);
  });

  $messages.on('scroll', function() {
    var $this = $(this);
    var messages_height = $messages.children().length * 50;
    if($this.scrollTop() == 0) {
      $.get('/messages', {page: message_page}, function(data) {
        message_page += 1;
        $.each(data, function(index, value) {
          $messages.prepend(message_template(value));
        });
        var new_height = ($messages.children().length * 50) - messages_height;
        console.log(new_height);
        scrollMessages(new_height);
      });
    }
  });

  $window.on('beforeunload unload', function() {
    source.close();
  });
});