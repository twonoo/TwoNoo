class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :transaction_type_id
      t.integer :amount
      t.integer :cost
      t.integer :balance

      t.timestamps
    end
  end
end
