class ChangeColumnTypesTransaction < ActiveRecord::Migration
  def change
	change_column :transactions, :cost, :float
  end
end
