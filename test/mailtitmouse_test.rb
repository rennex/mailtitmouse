
require_relative "helper.rb"

require_relative "../mailtitmouse.rb"

describe MailTitmouse do
  INPUT_MAIL = File.read("#{__dir__}/fixtures/examplemail.txt").freeze

  before do
    @mtm = MailTitmouse.new(INPUT_MAIL)
    @mtm.config_dir = "#{__dir__}/fixtures"
  end

  it "parses the input email" do
    assert_equal ["titmouselist@example.net"], @mtm.mail.to
  end

  it "finds the config file path" do
    assert_match /\/titmouselist@example\.net\.yml$/, @mtm.find_config_path
  end

  it "accepts well-formed email addresses" do
    addr = "perfectly@formed.address"
    assert_includes @mtm.find_config_path(addr), addr
  end

  it "refuses non-global email addresses" do
    ["..", "../", "localuser", "almost@ok", "too@many@ats.foo"].each do |address|
      assert_raises {
        @mtm.find_config_path(address)
      }
    end
  end

  it "doesn't accept path traversal characters in addresses" do
    addr = "foo/bar@what.ever"
    refute_includes @mtm.find_config_path(addr), addr
  end

end
