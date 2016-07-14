require 'open3'

class DockerLauncher
  attr_accessor :host_name, :api_url, :certs_dir, :options, :public_ip, :responding, :last_verify_time

  def server_info
    return @server_info if ! @server_info.nil? or (! last_verify_time.nil? and (Time.now - last_verify_time) < 30.seconds)
    @last_verify_time = Time.now
    @server_info = Docker.version(connection).merge Docker.info(connection)
  rescue
    nil
  end

  def running_containers
    return [] unless responding
    Docker::Container.all({}, connection).map(&:id)
  end

  def launch_challenge(challenge, flag, user)
    return nil unless responding
    repo, tag = parse_repo_tag challenge.docker_image_name
    image = get_local_images[repo]
    image = (image || {})[tag] unless tag.blank?
    raise "Could not find docker image named #{challenge.docker_image_name}" if image.nil?
    env = {CHALLENGE_FLAG: flag.value}
    launch_container(challenge.docker_image_name, env).id
  end

  def status_challenge(challenge, flag, user)
    return {status: :unknown, ports: []} unless responding
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
        {internal: internal, external: info[0]['HostPort'], type: type, ip: public_ip}
      end
    else
      ports = nil
    end
    {status: status, ports: ports}
  end

  def kill_challenge(challenge, flag, user)
    return false unless responding
    container = Docker::Container.get(flag.docker_container_id, {}, connection)
    return true if container.nil?
    container.kill.delete
    true
  end

  def running_challenges
    return [] unless responding
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

  def get_image_names
    return [] unless responding
    images = []
    get_local_images.each {|repo, x| x.each {|tag, _| images << (tag.blank? or tag == 'latest' ? repo : "#{repo}:#{tag}") }}
    images
  end

  def self.from_docker_machine
    return @docker_machine_instance if @docker_machine_instance
    output, status = Open3.capture2e('docker-machine env')
    return nil unless status == 0
    api_url = output =~ /DOCKER_HOST=(.+)$/ ? $1 : (raise 'Cannot determine docker-machine API Url')
    certs_dir = output =~ /DOCKER_CERT_PATH=(.+)$/ ? $1 : ''
    ip = api_url =~ /:\/\/(\d+\.\d+\.\d+\.\d+):(\d+)/ ? $1 : (raise 'Cannot determine docker-machine IP')
    port = api_url =~ /:\/\/(\d+\.\d+\.\d+\.\d+):(\d+)/ ? $2 : (raise 'Cannot determine docker-machine Port')
    @docker_machine_instance = DockerLauncher.new 'docker-machine', ip, ip, port, certs_dir
  end

  def self.get_all_instances
    return @instances if @instances
    @instances = []
    @host_config = YAML.load_file Rails.root.join('config').join('docker_hosts.yml')
    @instances << from_docker_machine if @host_config['docker_machine']['enabled'] && from_docker_machine
    (@host_config['hosts'] || {}).each do |name, conf|
      if conf['enabled']
        @instances << DockerLauncher.new(name, conf['public_ip'], conf['private_ip'], conf['api_port'], conf['cert_dir'])
      end
    end
    @instances
  end

  def self.get_instance(host_name=nil)
    if host_name.nil?
      get_all_instances.select(&:responding).sample
    else
      get_all_instances.select{|i| i.host_name == host_name}.first
    end
  end

  # Split name into repo:tag components
  def self.parse_repo_tag(tag)
    Docker::Util.parse_repo_tag tag
  end

  def parse_repo_tag(tag)
    self.class.parse_repo_tag tag
  end

  #protected
  def initialize(host_name, public_ip, private_ip, api_port, cert_dir, options={})
    @host_name = host_name
    @api_url = "tcp://#{private_ip}:#{api_port}"
    @public_ip = public_ip
    @certs_dir = cert_dir || nil
    @options = generate_options options
    @connection = nil
    @last_verify_time = nil
    @responding = ! server_info.nil?
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
         scheme: 'https',
         connect_timeout: 5
       })
    end
  end

  def get_local_images
    return [] unless responding
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
    return nil unless responding
    env = env.map {|k,v| "#{k}=#{v}"}
    container = Docker::Container.create({'Image' => image_name, 'HostConfig' => {'PublishAllPorts' => true}, 'Env' => env}, connection)
    raise 'Could not create container' if container.nil?
    container.start
  end
end