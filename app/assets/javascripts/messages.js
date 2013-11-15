var app = {
  message_template: null,
  message_page: 1
};
var source;
var hour24 = true;


$(function() {
  scrollMessages(-1);

  Handlebars.registerHelper('dateFormat', function(text) {
    // text = Handlebars.Utils.escapeExpression(text);
    var date = new Date(text);
    var formatted = (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear();

    return new Handlebars.SafeString(formatted);
  });

  Handlebars.registerHelper('timeFormat', function(text) {
    // text = Handlebars.Utils.escapeExpression(text);
    var date = new Date(text);
    var hours = date.getHours();
    var minutes = date.getMinutes();
    var ampm = '';
    if(!hour24) {
      ampm = (hours > 12) ? " pm" : " am";
      if(hours > 12) {
        hours -= 12;
      }
    }
    if(minutes < 10) {
      minutes = "0" + minutes
    }
    var formatted = hours + ":" + minutes + ampm;
    return new Handlebars.SafeString(formatted);
  });

  app.message_template = Handlebars.compile($('#message-template').html());


  // $.get('/messages', {page: 1}, function(data) {
  //   app.message_page += 1;
  //   $.each(data, function(index, value) {
  //     $messages.prepend(app.message_template(value));
  //   });
  //   scrollMessages(-1);
  // });

  $messages.on('scroll', function() {
    var $this = $(this);
    var messages_height = $messages.children().length * 50;
    if($this.scrollTop() == 0) {
      $.get('/messages', {page: app.message_page}, function(data) {
        app.message_page += 1;
        $.each(data, function(index, value) {
          $messages.prepend(app.message_template(value));
        });
        var new_height = ($messages.children().length * 50) - messages_height;
        scrollMessages(new_height);
      });
    }
  });

  setTimeout(function() {
    $messages.trigger('scroll');
  }, 1);


  openStream();

  $window.on('beforeunload unload', function() {
    closeStream();
  });

});


function openStream() {
  source = new EventSource('/messages/events');
  source.onopen = function() {
    connectionStatus(true);
  }
  source.addEventListener('messages.create', function(e) {
    connectionStatus(true);
    data = JSON.parse(e.data);
    var message_data = {
      username: data.username,
      content: data.message.content,
      created_at: data.message.created_at
    }
    $messages.append(app.message_template(message_data));
    scrollMessages(-1);
    connectionStatus(true);
  });
  source.addEventListener('user.list', function(e) {
    console.log(e);
  })
  source.addEventListener('error', function(e) {
    connectionStatus(false);
  });
}
function closeStream() {
  source.close();
}

function connectionStatus(status) {
  $connection_status = $('#connection-status');
  if(status === true) {
    $connection_status.removeClass('bad');
    $connection_status.addClass('good');
    $connection_status.attr('title', 'Connected.')
  } else if(status === false) {
    $connection_status.removeClass('good');
    $connection_status.addClass('bad');
    $connection_status.attr('title', 'Not connected!')
  } else {
    return $connection_status.hasClass('good');
  }
}
