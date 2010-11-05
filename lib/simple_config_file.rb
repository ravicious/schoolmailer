require "yaml"

module SimpleConfigFile

  def load_config(path)
    $config ||= Hash.new
    begin
      $config.merge! YAML.load(File.read(path))
    rescue Errno::ENOENT => e
      warn "WARNING: #{e}"
    end
  end

  def datamapper_database_config(database_config_hash, environment, pwd)
    raise ArgumentError if database_config_hash.class != Hash

    case database_config_hash[:name].downcase
    when "sqlite"
      "sqlite3://#{pwd}/db/schoolmailer_#{environment}.sqlite3"
    when "postgres"
      "postgres://#{database_config_hash[:login]}:#{database_config_hash[:password]}@localhost/schoolmailer_#{environment}"
    else
      raise ArgumentError, "This type of database is not supported."
    end

  end

end
