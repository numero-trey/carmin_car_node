require 'sdl'

class Carmin
  class Display

    def initialize
      # Init stuff AND things
      SDL.init SDL::INIT_VIDEO
      SDL::TTF.init

      # Open screen and blank
      @screen = SDL::Screen.open 896, 448, 0, SDL::HWSURFACE
      @buff = SDL::Screen.new SDL::HWSURFACE, 896, 448, @screen.format

      @buff.fill_rect 0, 0, 896, 448, 0

      SDL::WM::setCaption('Carmin','')

      # Pull in layout from file
      proc = Proc.new {}
      @gscreen = eval(File.read('layout.rb'), proc.binding, 'layout.rb')
    end

    def update(data)
      @gscreen.refresh data
    end
  end
end