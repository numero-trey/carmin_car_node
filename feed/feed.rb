class Carmin
  class Feed
    FEED_CLASSES = ['Dummy']
    def initialize(config)
      if FEED_CLASSES.include?(config[:module])

        # Require feed module file
        require_relative config[:module].downcase

        @module = Carmin::Feed.const_get(config[:module]).new(config[:config])

      end # Valid module
    end

    def read
      @module.read
    end
  end
end