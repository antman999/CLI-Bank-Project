class CreateBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :banks do |t|
      t.string :accounts
      t.string :preferred_accounts
    end
  end
end
