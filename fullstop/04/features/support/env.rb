require 'aruba/cucumber'
require 'fileutils'

include FileUtils

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @real_home = ENV['HOME']
  fake_home = File.join('/tmp','fakehome')
  rm_rf fake_home if File.exists? fake_home
  mkdir_p fake_home
  ENV['HOME'] = fake_home
end

After do
  ENV['HOME'] = @real_home
end
