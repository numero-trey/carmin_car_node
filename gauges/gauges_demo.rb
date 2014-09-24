require 'sdl'
require './font_ref'
require './screen'

# Init stuff AND things
SDL.init SDL::INIT_VIDEO
SDL::TTF.init

# Open screen and blank
screen = SDL::Screen.open 896, 448, 0, SDL::HWSURFACE
buff = SDL::Screen.new SDL::HWSURFACE, 896, 448, screen.format

buff.fill_rect 0, 0, 896, 448, 0

SDL::WM::setCaption('Carmin','')

gscreen = Gauges::Screen.new(screen, buff) do |gs|
  gs.set_font :mono, 180
  gs.value loc: [10, 0], val: lambda { |data| '%03d' % data[:speed] }

  gs.set_font :mono, 130
  gs.value loc: [16, 145], val: lambda { |data| '%04d' % data[:rpm] }

  # Add labels
  gs.set_font :mono, 60
  gs.label 'mph', loc: [330, 20]
  gs.label 'rpm', loc: [330, 150]

  # Water temp display
  gs.set_font :mono, 20
  gs.label 'Water Temp', loc: [24, 280]
  gs.value loc: [154, 280], val: lambda { |data| "%03d\xC2\xB0C" % data[:engine_coolent_temperature] }

  # Oil Press
  gs.label 'Oil Press', loc: [24, 330]
  gs.value loc: [154, 330], val: lambda { |data| "%03d Psi" % data[:engine_oil_pressure] }

  # Oil Temp
  gs.label 'Oil Temp', loc: [24, 380]
  gs.value loc: [154, 380], val: lambda { |data| "%03d\xC2\xB0C" % data[:engine_oil_temperature] }

  # Fuel Level
  gs.label 'Fuel', loc: [284, 280]
  gs.value loc: [428, 280], val: lambda { |data| "%03d\%" % data[:fuel_level] }

  # Throttle Position
  gs.label 'Throttle', loc: [284, 330]
  gs.value loc: [428, 330], val: lambda { |data| "%03d\%" % data[:throttle_position] }

  # Water temp gauge
  gs.bar_gauge(
    loc: [24, 300],
    size: [230, 20],
    range: (80..260),
    val: lambda { |data| data[:engine_coolent_temperature] },
    segments: [
      {max: 200, acolor: Gauges::COLOR_GREEN, dcolor: Gauges::COLOR_DARK_GREEN},
      {max: 240, acolor: Gauges::COLOR_YELLOW, dcolor: Gauges::COLOR_DARK_YELLOW},
      {max: 300, acolor: Gauges::COLOR_RED, dcolor: Gauges::COLOR_DARK_RED}
    ]
  )

  # Oil Pressure Gauge
  gs.bar_gauge(
    loc: [24, 350],
    size: [230, 20],
    range: (0..120),
    val: lambda { |data| data[:engine_oil_pressure] },
    segments: [
      {max: 50, acolor: Gauges::COLOR_RED, dcolor: Gauges::COLOR_DARK_RED},
      {max: 65, acolor: Gauges::COLOR_YELLOW, dcolor: Gauges::COLOR_DARK_YELLOW},
      {max: 85, acolor: Gauges::COLOR_GREEN, dcolor: Gauges::COLOR_DARK_GREEN},
      {max: 95, acolor: Gauges::COLOR_YELLOW, dcolor: Gauges::COLOR_DARK_YELLOW},
      {max: 200, acolor: Gauges::COLOR_RED, dcolor: Gauges::COLOR_DARK_RED}
    ]
  )

  # Oil temp gauge
  gs.bar_gauge(
    loc: [24, 400],
    size: [230, 20],
    range: (80..260),
    val: lambda { |data| data[:engine_oil_temperature] },
    segments: [
      {max: 200, acolor: Gauges::COLOR_RED, dcolor: Gauges::COLOR_DARK_RED},
      {max: 240, acolor: Gauges::COLOR_YELLOW, dcolor: Gauges::COLOR_DARK_YELLOW},
      {max: 300, acolor: Gauges::COLOR_GREEN, dcolor: Gauges::COLOR_DARK_GREEN}
    ]
  )

  # Fuel
  gs.bar_gauge(
    loc: [284, 300],
    size: [230, 20],
    range: (0..100),
    val: lambda { |data| data[:fuel_level] },
    segments: [
      {max: 20, acolor: Gauges::COLOR_RED, dcolor: Gauges::COLOR_DARK_RED},
      {max: 40, acolor: Gauges::COLOR_YELLOW, dcolor: Gauges::COLOR_DARK_YELLOW},
      {max: 100, acolor: Gauges::COLOR_GREEN, dcolor: Gauges::COLOR_DARK_GREEN}
    ]
  )

  # Throttle
  gs.bar_gauge(
    loc: [284, 350],
    size: [230, 20],
    range: (0..100),
    val: lambda { |data| data[:throttle_position] },
    segments: [
      {max: 100, acolor: Gauges::COLOR_GREEN, dcolor: Gauges::COLOR_DARK_GREEN}
    ]
  )
end


gauge_data = {
  speed: 0,
  rpm: 750,
  engine_coolent_temperature: 165,
  throttle_position: 35,
  fuel_level: 0,
  engine_oil_pressure: 80,
  engine_oil_temperature: 220,
  fuel_level_input: 75
}

gscreen.refresh gauge_data

change = 2
counter = 0

while true
  gauge_data[:speed] += 0.65 * change
  gauge_data[:rpm] += 45 * change
  gauge_data[:engine_coolent_temperature] += change

  counter += change

  change *= -1 if [100,0].include? counter
  
  gscreen.refresh gauge_data

  while event = SDL::Event.poll # Loop until there are no events left on the queue
    case event # Process the appropiate event type
    when SDL::Event::Quit
      exit
    end
  end
end
