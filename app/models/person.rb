class Person < ApplicationRecord
  has_many :parent_links, :class_name => 'Relationship', :foreign_key => 'parent_id'
  has_many :children, :through => :parent_links
  has_many :child_links, :class_name => 'Relationship', :foreign_key => 'child_id'
  has_many :parents, :through => :child_links

  has_many_attached :images

  enum gender: {male: 0, female: 1, non_binary: 2}


  default_scope { order(birth: :asc)}

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
  before_save :set_dates
  private
  def set_search_name
    self.search_name = ActiveSupport::Inflector.transliterate(name)
  end
  def pick_date_from_range(start_date, end_date)
    if (start_date.nil? and end_date.nil?)
      return nil
    elsif (start_date.nil?)
      return end_date
    elsif (end_date.nil?)
      return start_date
    else # could do averge date if start and end not the same
      return start_date
    end
  end
  def set_dates
    self.birth = pick_date_from_range(born_after, born_before)
    self.death = pick_date_from_range(died_after, died_before)
  end
end
