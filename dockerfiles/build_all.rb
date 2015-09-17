require 'yaml'
require 'pathname'

host_config = YAML.load_file Pathname.pwd.join('..').join('config').join('docker_hosts.yml')

host_config['hosts'].each do |name, conf|
  puts "Building images for #{name}"
  cert_dir = conf['cert_dir']
  cmd = "docker --tlsverify --tlscacert=#{cert_dir}/ca.pem --tlscert=#{cert_dir}/cert.pem --tlskey=#{cert_dir}/key.pem -H tcp://#{conf['private_ip']}:#{conf['api_port']}"
  Dir['{base_images,challenges}/*/'].each do |dir|
    if dir =~ /\/(.+)\/$/
      image_name = $1
      puts "\tBuilding #{image_name}"
      `#{cmd} build -t #{image_name} #{dir}`
    end
  end
end