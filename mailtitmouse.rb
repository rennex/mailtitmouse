#!/usr/bin/env ruby

require "mail"
require "yaml"

class MailTitmouse
  attr_reader :mail
  attr_accessor :config_dir, :config

  def initialize(maildata)
    @mail = Mail.new(maildata)
    @config_dir = "#{__dir__}/config"
    @list = Array(@mail.to).first
  end

  def find_config_path(recipient = @list)
    # clean up any slashes from the address
    addr = recipient.gsub(/\//, "_")
    raise "Invalid recipient address" unless addr =~ /\A[^@]+@[^@]+\.[^@]+\z/

    File.join(@config_dir, "#{addr}.yml")
  end

  def read_config(path = find_config_path)
    @config = YAML.load_file(path)
  end

  # format sub-addresses like <list-owner@example.com>
  def list(x)
    "<" + @list.sub(/@/, "-#{x}@") + ">"
  end

  def run
    read_config

    @mail.header["List"]        = "<#{@list}>"
    @mail.header["List-Post"]   = "<mailto:#{@list}>"
    @mail.header["Sender"]      = list "owner"
    @mail.header["Errors-to"]   = list "errors"
    @mail.header["Return-Path"] = list "bounce"

    @config["recipients"].each do |recipient|
      mail = @mail.dup
      mail.smtp_envelope_to = recipient
      mail.deliver
    end
  end
end

if $0 == __FILE__
  MailTitmouse.new(STDIN.read).run
end
