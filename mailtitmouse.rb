#!/usr/bin/env ruby

require "mail"
require "yaml"

class MailTitmouse
  attr_reader :mail
  attr_accessor :config_dir, :config

  def initialize(maildata)
    @mail = Mail.new(maildata)
    @config_dir = "#{__dir__}/config"
  end

  def find_config_path(recipient = Array(@mail.to).first)
    # clean up slashes and ".." from the address
    addr = recipient.gsub(/\//, "_")
    raise "Invalid recipient address" unless addr =~ /\A[^@]+@[^@]+\.[^@]+\z/

    File.join(@config_dir, "#{addr}.yml")
  end

  def read_config(path = find_config_path)
    @config = YAML.load_file(path)
  end

  def run
    p @mail.from
  end
end

if $0 == __FILE__
  MailTitmouse.new(STDIN.read).run
end
