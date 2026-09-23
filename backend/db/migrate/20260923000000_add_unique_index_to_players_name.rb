# frozen_string_literal: true

class AddUniqueIndexToPlayersName < ActiveRecord::Migration[5.2]
  # A local model, so that the migration does not depend on the app model
  class MigrationPlayer < ActiveRecord::Base
    self.table_name = 'players'
  end

  def up
    merge_duplicate_names
    add_index :players, :name, unique: true
  end

  # The merge of duplicate players cannot be undone. This removes only the index.
  def down
    remove_index :players, :name
  end

  private

  # Keep the row with the lowest id for each name. It gets the sum of the counters.
  def merge_duplicate_names
    names = MigrationPlayer.where.not(name: nil).group(:name).having('COUNT(*) > 1').pluck(:name)
    names.each do |name|
      rows = MigrationPlayer.where(name: name).order(:id).to_a
      keep = rows.first
      keep.update_columns(
        wins: rows.sum { |row| row.wins.to_i },
        losses: rows.sum { |row| row.losses.to_i },
        draws: rows.sum { |row| row.draws.to_i }
      )
      MigrationPlayer.where(id: rows.drop(1).map(&:id)).delete_all
    end
  end
end
