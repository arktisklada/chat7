$(function() {
  scrollMessages(-1);

  Handlebars.registerHelper('dateFormat', function(text) {
    // text = Handlebars.Utils.escapeExpression(text);
    var date = new Date(text);
    var formatted = (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear();

    return new Handlebars.SafeString(formatted);
  });

  var message_template = Handlebars.compile($('#message-template').html());


  var source = new EventSource('/messages/events');
  var message;

  source.addEventListener('messages.create', function (e) {
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
    $.each(data, function(index, value) {
      $messages.append(message_template(value));
    });
    scrollMessages(-1);
  });
});