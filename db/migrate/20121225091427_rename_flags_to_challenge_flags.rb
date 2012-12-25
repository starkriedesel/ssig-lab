class RenameFlagsToChallengeFlags < ActiveRecord::Migration
  def up
    rename_table :flags, :challenge_flags
  end

  def down
    rename_table :challenge_flags, :flags
  end
end
