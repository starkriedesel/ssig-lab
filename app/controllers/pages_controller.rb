class PagesController < ApplicationController
  def home
  end

  def admin_docker
    authorize! :manage, Challenge

    @docker_servers = []
    if local_boot2docker = DockerLauncher.from_boot2docker
      @docker_servers << local_boot2docker
    end
  end
end
