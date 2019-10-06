
require_relative "helper.rb"

require_relative "../mailtitmouse.rb"

Mail.defaults do
  delivery_method :test
end

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

  it "reads the config file" do
    @mtm.read_config
    recipients = @mtm.config["recipients"]
    refute_empty recipients
    assert_includes recipients, "sender@example.com"
    assert_includes recipients, "participant@example.net"
  end

  it "can generate list-related addresses" do
    assert_equal "<titmouselist-foo@example.net>", @mtm.list("foo")
  end

  it "delivers mails to list recipients" do
    @mtm.run
    assert_equal 2, Mail::TestMailer.deliveries.length

    # get the mail sent back to the sender
    mail = Mail::TestMailer.deliveries.find {|m| m.smtp_envelope_to == ["sender@example.com"] }
    refute_nil mail

    assert_equal ["titmouselist@example.net"],  mail.to
    assert_equal "First post",                  mail.subject
    assert_equal @mtm.mail.date,                mail.date
    assert_equal ["sender@example.com"],        mail.from
    assert_equal @mtm.mail.body.raw_source,     mail.body.raw_source

    assert_equal "<titmouselist@example.net>",        mail.header["List"].value
    assert_equal "<titmouselist-errors@example.net>", mail.header["Errors-to"].value
    assert_equal "<titmouselist-bounce@example.net>", mail.header["Return-Path"].value
  end

end
