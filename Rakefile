require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*test*.rb"
  # suppress irrelevant warnings
  t.ruby_opts << "-r ./test/suppress_warnings.rb"
end

task default: :test
