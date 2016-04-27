class TicketsQueue
  @queue = :tickets_queue
  def self.perform(json)
  end
end

def process_order(order)
  # process order
  puts "got: #{order}"
end