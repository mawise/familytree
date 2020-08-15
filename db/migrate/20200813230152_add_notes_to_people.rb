class AddNotesToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :notes, :text
  end
end
