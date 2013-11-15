class MessagesController < ApplicationController
  include ActionController::Live


  def index
    puts user_signed_in?
    page = params[:page].to_i || 1
    puts params
    if request.xhr?
      messages = Message.desc(:created_at).paginate(page: page, limit: 20)
      render :json => messages.to_a
    end
  end

  def create
    response.headers['Content-Type'] = 'text/javascript'
    message_params = params.require(:message).permit(:content)
    message_params[:username] = current_user.username
    message = Message.create(message_params)
    current_user.messages << @message

    $redis.publish('messages.create', {message: message.attributes, username: current_user.username}.to_json)

    if request.xhr?
      render js: '$("#message_content").val("")'
    else
      render nothing: true
    end
  end

  def events
    response.headers['Content-Type'] = 'text/event-stream'

    redis ||= Redis.new
    redis.subscribe(['heart', 'messages.create', 'user.join', 'user.leave', 'user.list']) do |on|
      on.message do |event, data|
        puts event
        if event == 'heart'
          response.stream.write("event: heart\ndata: beat\n\n")
        else
          write_stream(data, event: event)
        end
      end
    end
    publish_user_join
    render nothing: true

  rescue IOError
    # Client disconnected
    puts "IO Error"
    close_stream(redis)
  ensure
    puts "Quit"
    close_stream(redis)
  end

end
