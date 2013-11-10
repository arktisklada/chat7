require 'streamer/sse'

class MessagesController < ApplicationController
  include ActionController::Live


  def index
    @messages = Message.desc(:created_at).limit(20)
    if request.xhr?
      offset = (params[:page].to_i - 1) * 20 || 0
      @messages = Message.desc(:created_at).limit(20).offset(offset)
      render :json => @messages
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
    sse = Streamer::SSE.new(response.stream)
    redis = Redis.new
    redis.subscribe('messages.create') do |on|
      on.message do |event, data|
        sse.write(data, event: 'messages.create')
      end
    end
    render nothing: true
  rescue IOError
    puts "IO Error"
    # Client disconnected
  ensure
    puts "Quit"
    redis.quit
    sse.close
  end
end
