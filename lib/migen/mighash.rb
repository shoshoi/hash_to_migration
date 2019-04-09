module Migen
  class Mighash < Hash
    def initialize(hash={}, top_model_name="top")
      @top_model_name = top_model_name
      self.merge!(hash)
    end

    def top_model_name
      @top_model_name
    end

    def get_models(hash=self, model_name=@top_model_name)
      hash = hash.to_h if hash.class != Hash
      return ModelList.new if hash.keys.count == 0

      model_name = model_name.singularize || model_name
      current_model = Model.new(model_name)
      later_eval_columns = []

      columns = hash.map do |key,value|
        if value.class == Hash || value.class == Array && value.first.class == Hash
          later_eval_columns.push key
          Column.new("#{key}_id", Integer)
        else
          klass = Migen::Validator.date_text?(value) ? Date : value.class
          Column.new(key, klass)
        end
      end
      current_model.columns.push columns
      current_model.columns.flatten!

      related_models = later_eval_columns.map do |key|
        if hash[key].class == Array
          value = hash[key][0]
        else
          value = hash[key]
        end
        self.get_models(value, key.to_s)
      end

      all_models = [current_model, related_models].flatten
      ModelList.new(all_models)
    end

    def inspect
      "top_model_name: #{@top_model_name}, hash: #{super}"
    end
  end
end

