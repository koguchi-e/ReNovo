class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address
      t.string :provider
      t.string :uid
      t.string :name

      t.timestamps
    end

    add_index :users, [ :provider, :uid ], unique: true
    add_index :users, :email_address, unique: true
  end
end
