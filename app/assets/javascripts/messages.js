var app = {
  message_template: null,
  message_page: 1
};
var source;
var hour24 = true;


$(function() {

  // Register Handlebars dateFormat helper
  Handlebars.registerHelper('dateFormat', function(text) {
    // text = Handlebars.Utils.escapeExpression(text);
    var date = new Date(text);
    var formatted = (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear();

    return new Handlebars.SafeString(formatted);
  });

  // Register Handlebars timeFormat helper
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

  // compile and cache message template
  app.message_template = Handlebars.compile($('#message-template').html());


  // add scroll event handler for infinite history scroll
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

  // populate the history with first page
  setTimeout(function() {
    $messages.trigger('scroll');
  }, 1);


  // initiate the event stream
  openStream();

  // before we leave the page, close the stream and leave the room
  $window.on('beforeunload unload', function() {
    closeStream();
  });

});


function openStream() {
  // create the HTML5 EventSource for incoming events
  source = new EventSource('/messages/events');
  // when the connection is established:
  source.onopen = function() {
    // connection status is good
    connectionStatus(true);
    // join the room (add username to published user list)
    $.ajax({
      url: '/messages/join',
      async: false,
      method: 'GET'
    });
  }
  // when we receive a message:
  source.addEventListener('messages.create', function(e) {
    // connection status is good
    connectionStatus(true);
    data = JSON.parse(e.data);
    var message_data = {
      username: data.username,
      content: data.message.content,
      created_at: data.message.created_at
    }
    $messages.append(app.message_template(message_data));
    scrollMessages(-1);
    // connection status is good
    connectionStatus(true);
  });

  // cache the member list ul selector
  $list = $('#member-list-ul');
  // when we receive a new user list:
  source.addEventListener('user.list', function(e) {
    data = JSON.parse(e.data);
    $list.html('');
    $.each(data, function(i, user) {
      $list.append('<li><a href="">' + user + '</a></li>')
    });
    $list.append('<li class="divider">')
    $list.find('a').on('click', function(e) {
      e.preventDefault();
    });
  })
  // when we have an error:
  source.addEventListener('error', function(e) {
    // connection status is bad
    connectionStatus(false);
  });
}
function closeStream() {
  source.close();
  $.ajax({
    url: '/messages/leave',
    async: false,
    method: 'GET'
  });
}

function connectionStatus(status) {
  $connection_status = $('#connection-status');
  if(status === true) {
    $connection_status.removeClass('bad')
      .addClass('good')
      .attr('title', 'Connected.');
  } else if(status === false) {
    $connection_status.removeClass('good')
      .addClass('bad')
      .attr('title', 'Not connected!');
  } else {
    return $connection_status.hasClass('good');
  }
}
