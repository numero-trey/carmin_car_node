class Gauges
  class FontRef
    FONT_STYLES = {
      mono: 'gauges/FreeMono.ttf',
      sans_serif: 'Arial',
      serif: ''
    }

    @@font_cache = {}

    def self.get(face, size)
      @@font_cache["#{face}_#{size}"] ||= SDL::TTF.open(FONT_STYLES[face.to_sym], size, 0)
    end

  end
end