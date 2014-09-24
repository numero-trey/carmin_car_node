class Gauges
  class Screen

    def initialize(screen, buffer)
      @screen = screen
      @buff = buffer
      @draw_stack = []
      @curr_font = nil

      yield self if block_given?

      # Draw labels
      @screen.put @buff, 0, 0
      @screen.update_rect 0, 0, 896, 448

      self
    end

    # Set the font for UI elements
    def set_font(face, size)
      @curr_font = Gauges::FontRef.get(face, size)
    end

    # Add a static label to the screen
    def label(text, options = {})
      opts = {
        rgb: [255, 255, 255],
        loc: [0,0]
      }.merge(options)

      @curr_font.draw_blended_utf8(
        @buff, 
        text, 
        opts[:loc][0], opts[:loc][1], 
        opts[:rgb][0], opts[:rgb][1], opts[:rgb][2]
      )
    end

    # Add a dynamic value to the screen
    def value(options = {})
      @draw_stack << Displays::Value.new(options.merge(font: @curr_font))
    end

    # Add a dynamic bar gauge to the screen
    def bar_gauge(options = {})
      @draw_stack << Displays::BarGauge.new(options)
    end

    def refresh(data)
      @screen.put @buff, 0, 0
      @draw_stack.each { |d| d.draw(@screen, data) }
      @screen.update_rect 0, 0, 896, 448
    end
  end

  class Displays
    class Value
      def initialize(options)
        @opts = {
          rgb: [255, 255, 255]
        }.merge(options)
        self
      end

      # Draw on surface plucking value from data and formatting
      def draw(surface, data)
        value = @opts[:val].call(data) rescue nil
        return unless value

        @opts[:font].draw_blended_utf8(
          surface,
          value,
          @opts[:loc][0], @opts[:loc][1], 
          @opts[:rgb][0], @opts[:rgb][1], @opts[:rgb][2]
        )
      end
    end #Value

    class BarGauge
      def initialize(options)
        @opts = {
          loc: [0, 0],
          size: [100, 10],
          range: (0..100),
          segments: [
            {max: 49, acolor: [0,255,0], dcolor: [0,128,0]},
            {max: 74, acolor: [255,255,0], dcolor: [128,128,0]},
            {max: 100, acolor: [255,0,0], dcolor: [128,0,0]}
          ]
        }.merge(options)
        self
      end

      def draw(surface, data)
        value = @opts[:val].call(data) rescue nil
        return unless value

        unit_range = @opts[:range].max - @opts[:range].min
        px_unit = @opts[:size][0].to_f / unit_range

        rects = []

        curr_x = @opts[:loc][0]
        seg_min = @opts[:range].min

        @opts[:segments].each do |seg|
          
          max = [seg[:max], @opts[:range].max].min
          seg_width = ((max - seg_min) * px_unit).floor
          clamped_value = [value, @opts[:range].max].min

          if (seg_min..seg[:max]).cover? clamped_value
            # Value is mid-rect
            # Lit portion
            width = ((clamped_value - seg_min) * px_unit).floor
            do_rect surface, x: curr_x, width: width, color: seg[:acolor]
            curr_x += width
            seg_min = clamped_value

            # Dim portion
            width = seg_width - width
            do_rect surface, x: curr_x, width: width, color: seg[:dcolor]
            curr_x += width
            seg_min = seg[:max]

          else 
            # Solid rect
            c = (value >= seg[:max]) ? seg[:acolor] : seg[:dcolor]
            do_rect surface, x: curr_x, width: seg_width, color: c
            curr_x += seg_width
            seg_min = seg[:max]
          end
          
        end

      end

      def do_rect(surface, rect)
        #puts rect.inspect
        surface.fill_rect(
          rect[:x], @opts[:loc][1],
          rect[:width], @opts[:size][1],
          surface.format.map_rgb(*rect[:color])
        )
      end
    end #BarGauge
  end #Displays
end