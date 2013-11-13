class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def write_stream(object, options={})
    options.each do |key, value|
      response.stream.write("#{key}: #{value}\n")
    end
    response.stream.write("data: #{object}\n\n")
  end

  def close_stream(redis)
    redis.quit
    response.stream.close
  end

end
