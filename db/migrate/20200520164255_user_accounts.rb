class UserAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :userAccounts do |t|
      t.integer :user_id
      t.integer :bank_id
      t.integer :funds
      t.boolean :gold_rewards, default: false
      t.boolean :silver_rewards, default: false
      t.boolean :diamond_rewards, default: false
    end
  end
end
