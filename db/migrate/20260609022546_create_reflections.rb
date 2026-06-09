class CreateReflections < ActiveRecord::Migration[8.1]
  def change
    create_table :reflections do |t|
      t.references :user, null: false, foreign_key: true
      t.text :situation
      t.text :problem
      t.text :goal
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
