require 'aruba/cucumber'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

FAKE_HOME = '/tmp/fakehome'

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @real_home = ENV['HOME']
  ENV['HOME'] = '/tmp/fakehome'
  rm_rf FAKE_HOME, :secure => true, :verbose => false
  mkdir FAKE_HOME, :verbose => false
end

After do
  ENV['HOME'] = @real_home
end
