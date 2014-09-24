class Looper
  def self.ms(period_ms, opts={}, &block)
    next_loop = Time.now.to_ms
    puts "Period: #{period_ms}" if opts[:debug]

    while true
      puts "start: #{Time.now.to_ms}" if opts[:debug]
      block.call
      next_loop += period_ms

      puts "\nsched: #{next_loop}" if opts[:debug]
      
      # Skip missed frames
      while next_loop <= Time.now.to_ms
        next_loop += period_ms
        warn 'missed frame' if opts[:debug]
      end

      self.pause_until(next_loop)
    end
  end

  def self.hz(loop_rate, opts={}, &block)
    self.ms(1000 / loop_rate, opts) { block.call }
  end

  def self.pause_until(timestamp_ms)
    ms_delay = timestamp_ms - Time.now.to_ms
    if ms_delay > 0
      sleep ms_delay / 1000.0
    else
      warn "Timer underrun"
    end
  end
end