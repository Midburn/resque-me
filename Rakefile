require "bundler/setup"
Bundler.require(:default)
require 'resque/tasks'

require './midburn_queue'
require './worker'
require "./rake_helper"

task "resque:setup" do
  ENV['QUEUE'] = '*'
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

desc "assets:precompile"
task "assets:precompile" do
  # nothing to precompile
end

desc "pry console into the system"
task "midburn:console" do
  require "pry"
  binding.pry
end

desc "Stress test an endpoint with enqueues"
task "midburn:stress_test" do

  host_url = "https://midburn-queue.herokuapp.com/enqueue"
  tester_name = ('a'..'z').to_a.shuffle[0,8].join

  threads = []
  10.times do |thread_index|
    threads << Thread.new(thread_index) do
      100.times do |index|
        time = Time.now
        email = "#{tester_name}_thread_#{thread_index}_index_#{index}@gariany.com"
        RestClient.post host_url, { "email" => email }.to_json, :content_type => :json, :accept => :json do |response, request, result, &block|
          puts "thread #{thread_index}: finished #{email}. Took: #{Time.now - time}"
        end
      end
    end
  end

  threads.each { |aThread|  aThread.join }
end

desc "enqueue 1000 random orders"
task "midburn:enqueue" do
  1000.times do
    order_json = %{{"ip":"12.#{rand(100)}.#{rand(100)}.#{rand(100)}","timestamp":"#{Time.now.to_i}","email":"#{(0...8).map { ('a'..'z').to_a[rand(26)] }.join}@gmail.com"}}
    puts "New: #{order_json}"
    Resque.enqueue(TicketsQueue, order_json)
  end
end

desc "Reset the queue completely"
task "midburn:reset" do
  STDOUT.puts "Reset the queue completely? (y/n)"
  input = STDIN.gets.chomp
  reset_queue! if input == "y"
end

desc "Get List in CSV format"
task "midburn:list" do
  data = collect_orders
  csv = generate_csv(data)
  
  filename = "#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.results.csv"
  upload_results_to_s3 filename, csv

  puts "Get results using:"
  puts "aws s3 cp s3://midburn-queue-results/#{filename} results.csv"
end

desc "open the queue"
task "midburn:open_queue" do
  Resque.redis.set ENV["QUEUE_IS_OPEN_REDIS_KEY"], "true"
  puts "done!"
end

desc "close the queue"
task "midburn:close_queue" do
  Resque.redis.set ENV["QUEUE_IS_OPEN_REDIS_KEY"], "false"
  puts "done!"
end


