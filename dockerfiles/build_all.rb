require 'yaml'
require 'pathname'
require 'open3'

def from_docker_machine
  output, status = Open3.capture2e('docker-machine env')
  return {'enabled' => false} unless status == 0
  api_url = output =~ /DOCKER_HOST=(.+)$/ ? $1 : (raise 'Cannot determine docker-machine API Url')
  cert_dir = output =~ /DOCKER_CERT_PATH=(.+)$/ ? $1 : ''
  ip = api_url =~ /:\/\/(\d+\.\d+\.\d+\.\d+):(\d+)/ ? $1 : (raise 'Cannot determine docker-machine IP')
  port = api_url =~ /:\/\/(\d+\.\d+\.\d+\.\d+):(\d+)/ ? $2 : (raise 'Cannot determine docker-machine Port')
  {
      'enabled' => true,
      'private_ip' => ip,
      'api_port' => port,
      'cert_dir' => cert_dir
  }
end

host_config = YAML.load_file Pathname.pwd.join('..').join('config').join('docker_hosts.yml')
hosts = host_config['hosts']
if host_config['docker_machine']['enabled']
  hosts['docker-machine'] = from_docker_machine
end

any_enabled = false
hosts.each do |name, conf|
  next unless conf['enabled']
  any_enabled = true
  puts "Building images for #{name}"
  cert_dir = conf['cert_dir']
  ip = conf['private_ip']
  port = conf['api_port']
  cmd = "docker --tlsverify --tlscacert=#{cert_dir}/ca.pem --tlscert=#{cert_dir}/cert.pem --tlskey=#{cert_dir}/key.pem -H tcp://#{ip}:#{port}"
  Dir['{base_images,challenges}/*/'].each do |dir|
    if dir =~ /\/(.+)\/$/
      image_name = $1
      puts "\tBuilding #{image_name}"
      `#{cmd} build -t #{image_name} #{dir}`
    end
  end
end

puts 'No dockers enabled' unless any_enabled