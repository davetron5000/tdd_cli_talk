require 'minitest/autorun'
require 'fullstop'
require 'fileutils'
require 'mocha'

class TestCLI < MiniTest::Unit::TestCase
  class Tester
    include Fullstop::CLI
  end

  def test_that_inability_to_make_checkout_dir_causes_exception
    tester = Tester.new
    repo = File.join(ENV['HOME'],'dotfiles.git')
    tester.stubs(:mkdir_p).throws(RuntimeError)
    ex = assert_raises RuntimeError do
      tester.main(repo,nil)
    end
    assert_equal "Problem creating directory #{ENV['HOME']}", ex.message
  end
end
