class AddGenderToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :gender, :integer
  end
end
