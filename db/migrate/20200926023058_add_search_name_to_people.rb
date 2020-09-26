
class AddSearchNameToPeople < ActiveRecord::Migration[5.2]
  class Person < ActiveRecord::Base
  end

  def up
    add_column :people, :search_name, :string
    Person.find_each do |p|
      p.search_name = ActiveSupport::Inflector.transliterate(p.name)
      p.save!
    end
  end

  def down
    remove_column :people, :search_name
  end
end
