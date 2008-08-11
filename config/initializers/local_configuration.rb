if Rails.env == "development"
  local_configuration = File.expand_path(Rails.root + "/.local_configuration")
  eval(File.read(local_configuration), binding) if File.exist?(local_configuration)
end