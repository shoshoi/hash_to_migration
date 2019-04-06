module Migen
  class ModelList < Array
    def mig 
      self.map {|model| model.mig }
    end    
  end
end

