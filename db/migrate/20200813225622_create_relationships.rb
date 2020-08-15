class CreateRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :relationships do |t|
      t.integer :parent_id
      t.integer :child_id

      t.timestamps
    end
  end
end
