module Migen
  module Generator
    def self.generate_migration_file(models)
      case models
      when Migen::Mighash
        models = models.get_models
      when Migen::Model
        models = [models]
      when Hash
        models = Migen::Mighash.new(models).get_models
      end
      models.each do |model|
        file_name = "#{get_timestamp}_create_#{model.table_name}.rb"

        if Migen::Validator.table_duplicate?(model.table_name)
          puts "error: duplicate table #{model.table_name}"
          next
        end 

        File.open("migrate/#{file_name}","w") do |file|
          file.puts model.mig
        end
      end
    end

    private
    def self.get_timestamp
      start_time = Time.now
      time = start_time
      timestamp = time.strftime("%Y%m%d%H%M%S")

      while Migen::Validator.timestamp_duplicate?(timestamp)
        if time - start_time >= 10
          puts "fatal: The timestamp has been duplicated 10 times."
          raise Exception.new("fatal: The timestamp has been duplicated 10 times.")
        else
          puts "error: duplicate timestamp #{timestamp}"
        end
        time += 1
        timestamp = time.strftime("%Y%m%d%H%M%S")
      end

      timestamp
    end
  end
end

