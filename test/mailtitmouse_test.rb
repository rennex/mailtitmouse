
require_relative "helper.rb"

require_relative "../mailtitmouse.rb"

describe MailTitmouse do
  MAILDATA = File.read("#{__dir__}/fixtures/examplemail.txt").freeze

  before do
    @mtm = MailTitmouse.new(MAILDATA)
  end

  it "parses the input email" do
    assert_equal ["titmouselist@example.net"], @mtm.mail.to
  end

  it "finds the config file path" do
    assert_match /\/titmouselist@example\.net$/, @mtm.find_config_path
  end

end
