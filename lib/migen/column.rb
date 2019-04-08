module Migen
  class Column
    @@yaml = YAML.load_file(File.expand_path('../settings.yml', __FILE__))

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
        @klass.to_s == attribute["rb_attr"].to_s
      end.first
      options = @options.select{|key,value| value}.map {|key,value| ", #{key.to_s}: #{value}"}.join
      "t.#{attribute["db_attr"]} :#{@name.to_s.underscore} #{options}"
    end
  end
end

