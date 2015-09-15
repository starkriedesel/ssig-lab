class AddDockerContainerIdToChallengeFlags < ActiveRecord::Migration
  def change
    add_column :challenge_flags, :docker_container_id, :string
  end
end
