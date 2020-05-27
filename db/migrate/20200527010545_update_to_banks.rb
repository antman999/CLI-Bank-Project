class UpdateToBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :banks, :withdrawable, :boolean, default: false
  end
end
