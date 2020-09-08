class AddDataToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :birth_place, :string
    add_column :people, :death, :date
    add_column :people, :death_place, :string
  end
end
