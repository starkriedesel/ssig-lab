class AddDockerImageNameToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :docker_image_name, :string
  end
end
