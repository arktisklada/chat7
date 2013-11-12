class MessagesController < ApplicationController
  include ActionController::Live

  def index
    page = params[:page].to_i || 1
    puts params
    if request.xhr?
      @messages = Message.desc(:created_at).paginate(page: page, limit: 20)
      render :json => @messages.to_a.reverse
    end
  end

  def create
    response.headers['Content-Type'] = 'text/javascript'
    message_params = params.require(:message).permit(:content)
    message_params[:username] = current_user.username
    @message = Message.create(message_params)
    current_user.messages << @message

    $redis.publish('messages.create', {message: @message.attributes, username: current_user.username}.to_json)

    if request.xhr?
      render js: '$("#message_content").val("")'
    else
      render nothing: true
    end
  end

  def events
    response.headers['Content-Type'] = 'text/event-stream'

    redis ||= Redis.new
    redis.subscribe(['messages.create', 'heart']) do |on|
      on.message do |event, data|
        if event == 'messages.create'
          write_stream(data, event: event)
        elsif event == 'heart'
          response.stream.write("event: heart\ndata: beat\n\n")
        end
      end
    end
    # render nothing: true

  rescue IOError
    # Client disconnected
    puts "IO Error"
    close_stream(redis)
  ensure
    puts "Quit"
    close_stream(redis)
  end
end
