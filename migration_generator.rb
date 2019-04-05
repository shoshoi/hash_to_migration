require 'yaml'
require 'date'
require 'active_support'
require 'active_support/core_ext'

module MigrationGenerator
  @@yaml = YAML.load_file("./config/settings.yml")
  @@models = {}

  def self.generate_migration(hash,name)
    models = get_models(hash, name)
    generate_files(models)
  end

  def self.get_models(hash,name="top")
    name = name.singularize || name
    yaml = @@yaml
    model = {"name" => name, "attributes" => nil}
    later_eval = {}
    model["attributes"] = hash.map do |key,value|
      snake = key.underscore
      case value
      when Hash
        later_eval[key] = Hash
        "t.integer :#{snake.underscore}_id"
      when Array
        if value.first.class == Hash
          later_eval[key] = Array
          "t.integer :#{snake}_id"
        else
          "t.binary :#{snake}"
        end
      else
        if value.class.to_s == "String" && self.date_valid?(value)
          "t.datetime :#{snake}" 
        else
          attribute = yaml["attributes"].select do |attribute|
            value.class.to_s == attribute["rb_attr"]
          end.first
          "t.#{attribute["db_attr"]} :#{snake}"
        end 
      end
    end
    models = later_eval.map do |key,attr|
      if attr == Hash
        self.get_models(hash[key], key.to_s)
      else
        self.get_models(hash[key].first, key.to_s)
      end
    end
    models.push model
    models.flatten
  end

  def self.generate_files(models)
    migration_file = File.read('template.rb')
    models.each do |model|
      class_name = "Create#{model["name"].pluralize.capitalize}"
      table_name = model["name"].pluralize
      file_name = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}_create_#{table_name}.rb"

      new_mig = migration_file.clone
      new_mig.gsub!(/\$\{class_name\}/,class_name)
      new_mig.gsub!(/\$\{table_name\}/,table_name)

      model["attributes"].map! {|attribute| "      #{attribute}"}
      attributes = model["attributes"].join("\n")
      new_mig.gsub!(/\$\{attributes\}/,attributes)

      File.open("migrate/#{file_name}","w") do |file|
        file.puts new_mig
      end
    end
  end

  def self.date_valid?(str)
    !! Date.parse(str) rescue false
  end
end

