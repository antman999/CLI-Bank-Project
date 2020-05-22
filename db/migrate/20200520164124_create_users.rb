class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.integer :id_number
      t.string :username
      t.string :password
      t.string :occupation
      t.string :salary
      t.string :phone_number
    end
  end
end
