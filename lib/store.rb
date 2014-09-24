require 'sqlite3'

class Carmin
  class Store

    # Open data file
    def self.init(opts = {})
      opts = {
        filename: Time.now.strftime("carmin_data_%F.sqlite")
      }
      @@filename = opts[:filename]
      @@new_file = !File.exists?(@@filename)
      
      @@db = SQLite3::Database.new(@@filename)
      @@db.type_translation = true

      if @@new_file
        self.init_db
      else
        # read time offset
        timebase = db.get_first_value <<-SQL
          SELECT val FROM readings WHERE read_at = 0 AND name = 'timebase';
        SQL
        
        raise "Error reading timebase" unless timebase
        timebase = timebase.to_f / 1000.0

        puts "Setting timebase to #{timebase}"
        Carmin::Reading.timebase = Time.at(timebase)
      end
    end

    def self.db
      @@db
    end

    def self.init_db
      @@db.execute_batch <<-SQL
        CREATE TABLE readings (
          read_at integer,
          name varchar(30),
          val varchar(16)
        );
        INSERT INTO readings(read_at, name, val) 
          VALUES (0, 'timebase', '#{Carmin::Reading.timebase.to_ms}');
      SQL
    end

  end # Store
end