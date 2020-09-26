class Person < ApplicationRecord
  has_many :parent_links, :class_name => 'Relationship', :foreign_key => 'parent_id'
  has_many :children, :through => :parent_links
  has_many :child_links, :class_name => 'Relationship', :foreign_key => 'child_id'
  has_many :parents, :through => :child_links

  has_many_attached :images

  # people this person has had children with
  def partners
    p = Set.new
    children.each do |child|
      child.parents.each do |child_parent|
        p.add(child_parent) unless child_parent == self
      end
    end
    p
  end

  # people this person shares at least one parent with
  def siblings
    sibs = Set.new
    parents.each do |parent|
      parent.children.each do |parent_child|
        sibs.add(parent_child) unless parent_child == self
      end
    end
    sibs
  end

  before_save :set_search_name 
  private
  def set_search_name
    self.search_name = ActiveSupport::Inflector.transliterate(name)
  end
end
