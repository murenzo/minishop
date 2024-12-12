class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.references :product
      t.references :buyer, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
