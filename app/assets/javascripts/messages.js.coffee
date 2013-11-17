app = 
  message_template: null
  message_page: 1


$ ->

  # Register Handlebars dateFormat helper
  Handlebars.registerHelper 'dateFormat', (text) ->
    # text = Handlebars.Utils.escapeExpression(text)
    date = new Date(text)
    formatted = (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear()
    return new Handlebars.SafeString(formatted)


  # Register Handlebars timeFormat helper
  Handlebars.registerHelper 'timeFormat', (text) ->
    # text = Handlebars.Utils.escapeExpression(text)
    date = new Date(text)
    hours = date.getHours()
    minutes = date.getMinutes()
    ampm = ''
    if !hour24
      ampm = (hours > 12) ? " pm" : " am"
      if hours > 12
        hours -= 12
    if minutes < 10
      minutes = "0" + minutes
    formatted = hours + ":" + minutes + ampm
    return new Handlebars.SafeString(formatted)


  # compile and cache message template
  app.message_template = Handlebars.compile($('#message-template').html())


  # add scroll event handler for infinite history scroll
  $messages.on 'scroll', ->
    $this = $(this)
    messages_height = $messages.children().length * 50
    if $this.scrollTop() == 0
      $.get '/messages', {page: app.message_page}, (data) ->
        app.message_page += 1
        $.each data, (index, value) ->
          $messages.prepend(app.message_template(value))
        new_height = ($messages.children().length * 50) - messages_height
        scrollMessages(new_height)

  # populate the history with first page
  setTimeout ->
    $messages.trigger('scroll')
  , 1


  # initiate the event stream
  openStream()

  # before we leave the page, close the stream and leave the room
  $window.on 'beforeunload unload', ->
    closeStream()




openStream = ->
  # create the HTML5 EventSource for incoming events
  source = new EventSource('/messages/events')
  # when the connection is established:
  source.onopen = ->
    # connection status is good
    connectionStatus(true)
    # join the room (add username to published user list)
    $.ajax
      url: '/messages/join'
      async: false
      method: 'GET'

  # when we receive a message:
  source.addEventListener 'messages.create', (e) ->
    # connection status is good
    connectionStatus(true)
    data = JSON.parse(e.data)
    message_data =
      username: data.username
      content: data.message.content
      created_at: data.message.created_at

    $messages.append(app.message_template(message_data))
    scrollMessages(-1)
    # connection status is good
    connectionStatus(true)

  # cache the member list ul selector
  $list = $('#member-list-ul')
  # when we receive a new user list:
  source.addEventListener 'user.list', (e) ->
    data = JSON.parse(e.data)
    $list.html('')
    $.each data, (i, user) ->
      $list.append('<li><a href="">' + user + '</a></li>')

    $list.append('<li class="divider">')
    $list.find('a').on 'click', (e) ->
      e.preventDefault()


  # when we have an error:
  source.addEventListener 'error', (e) ->
    # connection status is bad
    connectionStatus(false)



closeStream = ->
  source.close()
  $.ajax
    url: '/messages/leave'
    async: false
    method: 'GET'



connectionStatus = (status) ->
  $connection_status = $('#connection-status')
  if status == true
    $connection_status.removeClass('bad')
      .addClass('good')
      .attr('title', 'Connected.')
  else if status == false
    $connection_status.removeClass('good')
      .addClass('bad')
      .attr('title', 'Not connected!')
  else
    return $connection_status.hasClass('good')
