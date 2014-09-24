class Carmin::Feed::Dummy

  def initialize(opts)
    @step = 0
    @direction = 1
  end

  def read
    
    @step += @direction
    @direction *= -1 unless (1..99).cover?(@step)

    sleep 0.05
    {
      speed: 0 + (@step * 0.7).to_i,
      rpm: 750 + (@step * 60).to_i,
      engine_coolent_temperature: 170  + (@step * 0.3).to_i,
      throttle_position: 40 + (@step * 0.6).to_i,
      engine_oil_pressure: 82 + (@step * 0.2).to_i,
      engine_oil_temperature: 234 + (@step * 0.3).to_i,
      fuel_level_input: 10 + (@step * 0.8).to_i,
      voltage: 14.0 + (@step * 0.008).round(2)
    }
  end
end