require 'yaml'
require 'date'
require 'time'
require 'active_support'
require 'active_support/core_ext'

module Migen
  def self.date_text?(str)
    return false unless str.class.to_s == "String"
    !! Date.parse(str) rescue false
  end

  def self.timestamp_duplicate?(timestamp)
    path = "./migrate/*"
    time_stamps = Pathname.glob(path).map {|path| path.basename.to_s[0,14]}
    time_stamps.include?(timestamp)
  end

  def self.table_duplicate?(table_name)
    path = "./migrate/*"
    tables = Pathname.glob(path).map {|path| path.basename.to_s[22..-1].gsub(/\.rb/, "")}
    tables.include?(table_name)
  end

  class Mighash < Hash
    def initialize(hash, hash_name="parent")
      @hash_name = hash_name
      self.merge!(hash)
    end

    def get_models(hash=self, name=@hash_name)
      hash = hash.to_h if hash.class != Hash
      name = name.singularize || name
      model = Model.new(name)
      later_eval = {}

      columns = hash.map do |key,value|
        if value.class == Hash || value.class == Array && value.first.class == Hash
          later_eval[key] = value.class
          Column.new("#{key}_id", Integer)
        else
          klass = Migen.date_text?(value) ? Date : value.class
          Column.new(key, klass)
        end
      end
      model.columns.push columns
      model.columns.flatten!

      models = later_eval.map do |key,attr|
        child = hash[key]
        child = child.first if attr == Array
        self.get_models(child, key.to_s)
      end

      models.push model
      models.flatten
    end

    def mig
      get_models.map {|model| model.mig }
    end
  end

  class Model
    def initialize(name)
      @name = name
      @columns = []
    end

    def columns
      @columns
    end

    def class_name
      @name.pluralize.capitalize
    end

    def table_name
      @name.pluralize
    end

    def mig 
      template_file = File.read('template.rb')
      migration_file = template_file.clone
      migration_file.gsub!(/\$\{class_name\}/, class_name)
      migration_file.gsub!(/\$\{table_name\}/, table_name)
      col = columns.map {|column| "      #{column.mig}"}.join("\n")
      migration_file.gsub(/\$\{columns\}/, col)
    end
  end

  class Column
    @@yaml = YAML.load_file("./config/settings.yml")

    def initialize(name, klass)
      @name = name
      @klass = klass
      @options = {
        limit: nil,
        default: nil,
        null: nil,
        precision: nil,
        scale: nil
      }
    end

    def set_options(options)
      @options.merge!(options)
    end

    def mig
      attribute = @@yaml["attributes"].select do |attribute|
        @klass.to_s == attribute["rb_attr"]
      end.first
      options = @options.select{|key,value| value}.map {|key,value| ", #{key.to_s}: #{value}"}.join
      "t.#{attribute["db_attr"]} :#{@name.to_s.underscore} #{options}"
    end
  end

  module Generator
    @@yaml = YAML.load_file("./config/settings.yml")

    def self.generate_migration_file(models)
      case models
      when Migen::Mighash
        models = models.get_models
      when Migen::Model
        models = [models]
      when Hash
        models = Migen::MigHash.new(models).get_models
      end
      models.each do |model|
        file_name = "#{get_timestamp}_create_#{model.table_name}.rb"

        if Migen.table_duplicate?(model.table_name)
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

      while Migen.timestamp_duplicate?(timestamp)
        if time - start_time >= 10
          puts "fatal: The timestamp has been duplicated 10 times"
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

