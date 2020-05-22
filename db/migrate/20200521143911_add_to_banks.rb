class AddToBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :banks, :monthly_fee, :integer
    add_column :banks, :interest_rate, :string
  end
end
