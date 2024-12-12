class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price, scale: 2, precision: 6, default: 0
      t.references :seller, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
