require "yaml"

def load_config(path)
  $config ||= Hash.new
  begin
    $config.merge! YAML.load(File.read(path))
  rescue Errno::ENOENT => e
    warn "WARNING: #{e}"
  end
end
