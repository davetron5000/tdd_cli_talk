require 'minitest/autorun'
require 'fullstop'
require 'mocha'

class TestSomething < MiniTest::Unit::TestCase
  include Fullstop
  def test_git_failure_causes_exception
    CLI.stubs(:chdir)
    CLI.stubs(:system).returns(false)
    CLI.stubs(:ln_s).raises("Should not have been called")
    ex = assert_raises RuntimeError do
      CLI.main('foo','foo')
    end
    assert_equal "'git clone foo dotfiles' failed",ex.message
  end
end
