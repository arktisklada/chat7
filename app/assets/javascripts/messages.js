$(document).ready(function() {
  var source = new EventSource('/messages/events');
  var message;

  source.addEventListener('messages.create', function (e) {
    data = JSON.parse(e.data);
    console.log(data);
    $("#messages").append($('<li>').text(data.username + ': ' + data.message.content));
  });
});