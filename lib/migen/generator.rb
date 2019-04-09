module Migen
  module Generator
    def self.generate_migration_file(object)
      case object
      when Migen::Mighash
        models = object.get_models
      when Migen::Model
        models = [object]
      when Hash
        models = Migen::Mighash.new(object).get_models
      else
        raise Exception.new("fatal: Other than  Migen::Mighash, Migen::Model, Hash can not be specifie.")
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
      current_time = start_time
      timestamp = current_time.strftime("%Y%m%d%H%M%S")

      while Migen::Validator.timestamp_duplicate?(timestamp)
        if current_time - start_time >= 10
          puts "fatal: The timestamp has been duplicated 10 times."
          raise Exception.new("fatal: The timestamp has been duplicated 10 times.")
        else
          puts "error: duplicate timestamp #{timestamp}"
        end
        current_time += 1
        timestamp = current_time.strftime("%Y%m%d%H%M%S")
      end

      timestamp
    end
  end
end

