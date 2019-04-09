module Migen
  class Column
    @@settings = YAML.load_file(File.expand_path('../settings.yml', __FILE__))

    def initialize(name, klass)
      @name = name
      @attribute = @@settings["attr_mapping"][klass.to_s]
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
      valid_options = @options.select{|key,value| value.present? }
      formatted_option = valid_options.map {|key,value| ", #{key.to_s}: #{value}" }.join
      "t.#{@attribute} :#{@name.to_s.underscore} #{formatted_option}"
    end
  end
end

