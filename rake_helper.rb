def duplicate_email?(data, email)    
  data.each { |e| return true if e[3] == email }
  false
end

def reset_queue!
  puts "========== PERFORMING BIG RESET =========="
  puts "Performing big reset. Removing all tasks from all queues!"
  queues = Resque.queues
  queues.each do |queue_name|
    puts "Clearing #{queue_name}..."
    Resque.remove_queue "#{queue_name}"
    Resque.redis.del "queue:#{queue_name}"
  end
  
  puts "Clearing delayed..." # in case of scheduler - doesn't break if no scheduler module is installed
  Resque.redis.keys("delayed:*").each do |key|
    Resque.redis.del "#{key}"
  end
  Resque.redis.del "delayed_queue_schedule"
  
  puts "Clearing stats..."
  Resque.redis.set "stat:failed", 0 
  Resque.redis.set "stat:processed", 0
  puts "Done."
  puts "=========================================="  
end

def collect_orders
  data = []
  Resque.redis.lrange("queue:tickets_queue", 0, -1).each do |job|
    args = JSON.parse(JSON.parse(job)["args"][0])
    ip, timestamp, email = args["ip"], args["timestamp"], args["email"]
    ip_appearance = data.count { |e| e[1] == ip }
    data << [ "TicketsQueue", ip, timestamp, email, ip_appearance ] unless duplicate_email? data, email
  end
  data
end

def generate_csv(data)
  require "csv"
  CSV.generate do |csv|
    data.each { |r| csv << r }
  end
end

def upload_results_to_s3(key, data)
  require 'aws-sdk'
  s3 = Aws::S3::Resource.new(region:ENV["AWS_REGION"])
  obj = s3.bucket(ENV["AWS_RESULTS_BUCKET"]).object(key)
  obj.put(body: data)
end