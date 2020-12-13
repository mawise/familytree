class AddDateRangesToPeople < ActiveRecord::Migration[5.2]
  class Person < ActiveRecord::Base
  end

  def up
    add_column :people, :born_after, :date
    add_column :people, :born_before, :date
    add_column :people, :died_after, :date
    add_column :people, :died_before, :date
    Person.find_each do |p|
      p.born_after = p.birth
      p.born_before = p.birth
      p.died_after = p.death
      p.died_before = p.death
      p.save!
    end
  end
  def down
    remove_column :people, :born_after
    remove_column :people, :born_before
    remove_column :people, :died_after
    remove_column :people, :died_before
  end
end
