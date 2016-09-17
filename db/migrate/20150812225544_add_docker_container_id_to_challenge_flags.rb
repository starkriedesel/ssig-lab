class AddDockerContainerIdToChallengeFlags < ActiveRecord::Migration
  def change
    add_column :challenge_flags, :docker_container_id, :string
    add_column :challenge_flags, :docker_host_name, :string
  end
end
