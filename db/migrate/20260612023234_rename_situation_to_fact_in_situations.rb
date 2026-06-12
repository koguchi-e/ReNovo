class RenameSituationToFactInSituations < ActiveRecord::Migration[8.1]
  def change
    rename_column :situations, :situation, :fact
  end
end
