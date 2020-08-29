class Person < ApplicationRecord
  has_many :parent_links, :class_name => 'Relationship', :foreign_key => 'parent_id'
  has_many :children, :through => :parent_links
  has_many :child_links, :class_name => 'Relationship', :foreign_key => 'child_id'
  has_many :parents, :through => :child_links

  has_many_attached :images
end
