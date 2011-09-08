require 'minitest/autorun'
require 'fullstop'
require 'fileutils'
require 'mocha'

class TestCLI < MiniTest::Unit::TestCase
  class Tester
    include Fullstop::CLI
  end

  def setup
    @tester = Tester.new
    @tester.stubs(:mkdir_p)
    @tester.stubs(:chdir)
    @tester.stubs(:ln)
    @tester.stubs(:system).returns(true)
    @tester.stubs(:dotfiles_in).yields('.bashrc')
    @home = ENV['HOME']
    @repo = File.join(@home,'dotfiles.git')
  end

  def test_that_inability_to_make_checkout_dir_causes_exception
    @tester.stubs(:mkdir_p).throws(RuntimeError)
    ex = assert_raises RuntimeError do
      @tester.main(@repo,nil)
    end
    assert_equal "Problem creating directory #{@home}", ex.message
  end

  def test_that_inability_to_cd_to_checkout_dir_causes_exception
    @tester.stubs(:chdir).throws(RuntimeError)
    ex = assert_raises RuntimeError do
      @tester.main(@repo,nil)
    end
    assert_equal "Problem changing to directory #{@home}", ex.message
  end

  def test_that_inability_to_checkout_causes_exception
    @tester.stubs(:system).returns(false)
    ex = assert_raises RuntimeError do
      @tester.main(@repo,nil)
    end
    assert_equal "Problem checking out #{@repo} into #{@home}/dotfiles", ex.message
  end

  def test_that_inability_to_symlink_causes_exception
    @tester.stubs(:ln).throws(RuntimeError)
    ex = assert_raises RuntimeError do
      @tester.main(@repo,nil)
    end
    assert_equal "Problem symlinking .bashrc into #{@home}", ex.message
  end

end
