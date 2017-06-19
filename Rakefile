
task default: :prepare_files do
  puts 'Hello!!'
end

task :prepare_files do
  puts 'Generating file for store session data...'
  File.open('session_store.yaml', 'w') {} unless File.exist?('session_store.yaml')
  puts 'Done!'
end


task :clear_data do
  puts 'Clear data in session_store.yaml file..'
  File.open('session_store.yaml', 'w') {}
  puts 'Done!'
end
