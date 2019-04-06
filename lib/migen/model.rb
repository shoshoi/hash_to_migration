module Migen
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
      return "" if columns.count == 0
      template_file = Templates.migration_file
      migration_file = template_file.clone
      migration_file.gsub!(/\$\{class_name\}/, class_name)
      migration_file.gsub!(/\$\{table_name\}/, table_name)
      col = columns.map {|column| "      #{column.mig}"}.join("\n")
      migration_file.gsub(/\$\{columns\}/, col)
    end
  end
end

