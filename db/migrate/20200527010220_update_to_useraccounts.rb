class UpdateToUseraccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :useraccounts, :closed?, :boolean, default: false
  end
end
