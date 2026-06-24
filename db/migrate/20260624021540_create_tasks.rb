class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :situation, null: false, foreign_key: true
      t.string :content, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
