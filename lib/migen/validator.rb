module Migen
  module Validator
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
  end
end

