class PagesController < ApplicationController
  def home
  end

  def admin_docker
    authorize! :manage, Challenge

    @docker_servers = DockerLauncher.get_all_instances
  end
end
