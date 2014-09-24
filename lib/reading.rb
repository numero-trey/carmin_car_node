class Carmin
  class Reading
    attr_accessor :read_at, :name, :value

    @@timebase = Time.now

    def initialize(options)
      opts = {
        read_at: Time.now,
        persist: true
      }.merge(options)

      @read_at = opts[:read_at]
      @name = opts[:name].to_s
      @value = [opts[:value].to_s, opts[:unit]].compact.join('|')

      store if opts[:persist]
    end

    def store
      Carmin::Store.db.execute(
        "INSERT INTO readings(read_at, name, val) VALUES (?, ?, ?)", [
        timestamp,
        @name,
        @value
      ])
    end

    def timestamp
      @read_at.to_ms - @@timebase.to_ms
    end

    def to_m
      [
        timestamp,
        @name,
        @value
      ].join('|')
    end

    def self.timebase
      @@timebase
    end

    def self.timebase=(time)
      @@timebase = time
    end

  end # Reading
end