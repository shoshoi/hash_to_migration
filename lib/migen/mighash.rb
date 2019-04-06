module Migen
  class Mighash < Hash
    def initialize(hash={}, name="parent")
      @name = name
      self.merge!(hash)
    end

    def name
      @name
    end

    def get_models(hash=self, name=@name)
      hash = hash.to_h if hash.class != Hash
      return ModelList.new if hash.keys.count == 0

      name = name.singularize || name
      model = Model.new(name)
      later_eval = {}

      columns = hash.map do |key,value|
        if value.class == Hash || value.class == Array && value.first.class == Hash
          later_eval[key] = value.class
          Column.new("#{key}_id", Integer)
        else
          klass = Migen::Validator.date_text?(value) ? Date : value.class
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
      models.flatten!
      ModelList.new(models)
    end

    def inspect
      "name: #{@name}, hash: #{super}"
    end
  end
end

