class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def publish_user_join
    users = JSON.parse($redis.get('users')) rescue []
    users.push(current_user.username).uniq!
    $redis.set('users', users.to_json)
    $redis.publish('user.list', {users: users}.to_json)
  end

  def publish_user_leave
    users = JSON.parse($redis.get('users')) rescue []
    users.delete(current_user.username)
    $redis.set('users', users.to_json)
    $redis.publish('user.list', {users: users}.to_json)
  end


  def write_stream(object, options={})
    options.each do |key, value|
      response.stream.write("#{key}: #{value}\n")
    end
    response.stream.write("data: #{object}\n\n")
  end

  def close_stream(redis)
    redis.quit
    response.stream.close
    publish_user_leave
  end

end
