class ChangeBanks < ActiveRecord::Migration[5.2]
  def change
    remove_column :banks, :preferred_accounts, :string
  end
end
