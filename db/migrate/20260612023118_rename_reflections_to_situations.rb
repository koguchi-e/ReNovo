class RenameReflectionsToSituations < ActiveRecord::Migration[8.1]
  def change
    rename_table :reflections, :situations
  end
end
