class ApplicationRecord < ActiveRecord::Base
  include ClassyEnum::ActiveRecord
  
  self.abstract_class = true
end
