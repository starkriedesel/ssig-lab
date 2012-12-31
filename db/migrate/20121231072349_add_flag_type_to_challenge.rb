class AddFlagTypeToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :flag_type, :integer
    Challenge.update_all :flag_type => 1
  end
end
