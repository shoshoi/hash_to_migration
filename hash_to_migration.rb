require 'yaml'
require 'date'
require 'time'
require 'active_support'
require 'active_support/core_ext'

module HashToMigration
  @@yaml = YAML.load_file("./config/settings.yml")

  def self.generate(hash,name)
    models = get_models(hash, name)
    generate_files(models)
  end

  private
  def self.get_models(hash,name="top")
    name = name.singularize || name
    model = {"name" => name, "columns" => nil}
    later_eval = {}

    model["columns"] = hash.map do |key,value|
      if value.class == Hash || value.class == Array && value.first.class == Hash
        later_eval[key] = value.class
        build_column_string(Integer, "#{key}_id")
      else
        klass = self.date_text?(value) ? Date : value.class
        build_column_string(klass, key)
      end
    end

    models = later_eval.map do |key,attr|
      child = hash[key]
      child = child.first if attr == Array
      self.get_models(child, key.to_s)
    end

    models.push model
    models.flatten
  end

  def self.build_column_string(klass, column_name)
    attribute = @@yaml["attributes"].select do |attribute|
      klass.to_s == attribute["rb_attr"]
    end.first
    "t.#{attribute["db_attr"]} :#{column_name.to_s.underscore}"
  end

  def self.date_text?(str)
    return false unless str.class.to_s == "String"
    !! Date.parse(str) rescue false
  end

  def self.generate_files(models)
    template_file = File.read('template.rb')

    models.each do |model|
      class_name = "Create#{model["name"].pluralize.capitalize}"
      table_name = model["name"].pluralize
      file_name = "#{get_timestamp}_create_#{table_name}.rb"

      if table_duplicate?(table_name)
        puts "error: duplicate table #{table_name}"
        next
      end

      migration_file = template_file.clone
      migration_file.gsub!(/\$\{class_name\}/, class_name)
      migration_file.gsub!(/\$\{table_name\}/, table_name)

      columns = model["columns"].map {|columns| "      #{columns}"}.join("\n")
      migration_file.gsub!(/\$\{columns\}/, columns)

      File.open("migrate/#{file_name}","w") do |file|
        file.puts migration_file
      end
    end
  end

  def self.get_timestamp
    start_time = Time.now
    time = start_time
    timestamp = time.strftime("%Y%m%d%H%M%S")

    while timestamp_duplicate?(timestamp)
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
end

