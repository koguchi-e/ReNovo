class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :situation, null: false, foreign_key: true
      t.string :content
      t.integer :position

      t.timestamps
    end
  end
end
