class Relationship < ApplicationRecord
  belongs_to :parent, :class_name => 'Person'
  belongs_to :child, :class_name => 'Person'
end
