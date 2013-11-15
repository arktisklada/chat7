$redis = Redis.new
$redis.set('users', [].to_json)

redis_heartbeat = Thread.new do
  while true do
    $redis.publish("heart", "beat")
    sleep 5.seconds
  end
end

at_exit do
  redis_heartbeat.kill
  $redis.quit
end