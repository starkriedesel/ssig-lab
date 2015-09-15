require 'open3'

class DockerLauncher
  attr_accessor :server_name, :api_url, :certs_dir, :options, :ip, :access_ip

  def server_info
    Docker.version(connection).merge Docker.info(connection)
  end

  def running_containers
    Docker::Container.all({}, connection).map(&:id)
  end

  def launch_challenge(challenge, flag, user)
    repo, tag = parse_repo_tag challenge.docker_image_name
    image = get_local_images[repo]
    image = (image || {})[tag] unless tag.blank?
    raise "Could not find docker image named #{challenge.docker_image_name}" if image.nil?
    env = {CHALLENGE_FLAG: flag.value}
    launch_container(challenge.docker_image_name, env).id
  end

  def status_challenge(challenge, flag, user)
    container = Docker::Container.get(flag.docker_container_id, {}, connection)
    status = if container.nil?
               :missing
             elsif container.info['State']['Running']
                :running
             else
                :dead
             end
    if container.info['NetworkSettings']['Ports']
      ports = container.info['NetworkSettings']['Ports'].map do |internal, info|
        if internal =~ /^(.+)\/tcp/
          type = 'tcp'
          internal = $1
        elsif internal =~ /^(.+)\/udp/
          type = 'udp'
          internal = $1
        else
          type = ''
        end
        {internal: internal, external: info[0]['HostPort'], type: type, ip: access_ip}
      end
    else
      ports = nil
    end
    {status: status, ports: ports}
  end

  def kill_challenge(challenge, flag, user)
    container = Docker::Container.get(flag.docker_container_id, {}, connection)
    return true if container.nil?
    container.kill.delete
    true
  end

  def running_challenges
    Docker::Container.all({}, connection).map do |container|
      flag = ChallengeFlag.where(docker_container_id: container.id).first
      info = {
          Image: container.info['Image'],
          Ports: container.info['Ports'].map {|p| "#{p['PrivatePort']}/#{p['Type']} => #{p['PublicPort']}/#{p['Type']}"},
          Status: container.info['Status']
      }
      if flag
        [container.id[0..10], {
             User: flag.user.username,
             Challenge: flag.challenge.name,
             Created: flag.created_at,
             Info: info,
             _flag_id: flag.id,
             _no_challenge: 0
        }]
      else
        [container.id[0..10], {_no_challenge: 1, Info: info}]
      end
    end.to_h
  end

  def self.from_boot2docker
    output, status = Open3.capture2e('boot2docker shellinit')
    return nil unless status == 0
    api_url = output =~ /DOCKER_HOST=(.+)$/ ? $1 : (raise 'Cannot determine boot2docker API Url')
    certs_dir = output =~ /DOCKER_CERT_PATH=(.+)$/ ? $1 : ''
    ip = api_url =~ /:\/\/(\d+\.\d+\.\d+\.\d+):/ ? $1 : (raise 'Cannot determine boot2docker IP')
    DockerLauncher.new ip, 'boot2docker', api_url, certs_dir
  end

  def self.get_instance
    from_boot2docker
  end

  # Split name into repo:tag components
  def self.parse_repo_tag(tag)
    Docker::Util.parse_repo_tag tag
  end

  def parse_repo_tag(tag)
    self.class.parse_repo_tag tag
  end

  #protected
  def initialize(access_ip, server_name, api_url, certs_dir, options={})
    @server_name = server_name
    @api_url = api_url
    @certs_dir = certs_dir || nil
    @access_ip = access_ip
    @options = generate_options options
    @connection = nil
  end

  def connection
    @connection ||= Docker::Connection.new api_url, options
  end

  def generate_options(opts)
    if certs_dir.nil?
      opts
    else
      opts.merge!({
         client_cert: File.join(certs_dir, 'cert.pem'),
         client_key: File.join(certs_dir, 'key.pem'),
         ssl_ca_file: File.join(certs_dir, 'ca.pem'),
         scheme: 'https'
       })
    end
  end

  def get_local_images
    images = {}
    Docker::Image.all({}, connection).each do |image|
      repo, tag = parse_repo_tag image.info['RepoTags'][0]
      next if repo == '<none>'
      images[repo] ||= {}
      images[repo][tag] = image
    end
    images
  end

  def launch_container(image_name, env)
    env = env.map {|k,v| "#{k}=#{v}"}
    container = Docker::Container.create({'Image' => image_name, 'HostConfig' => {'PublishAllPorts' => true}, 'Env' => env}, connection)
    raise 'Could not create container' if container.nil?
    container.start
  end
end