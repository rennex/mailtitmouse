#!/usr/bin/env ruby

require "mail"
require "yaml"

class MailTitmouse
  attr_reader :mail
  attr_accessor :config_dir, :config
  attr_writer :list

  def initialize(maildata)
    @mail = Mail.new(maildata)
    @config_dir = "#{__dir__}/config"
  end

  def config_path_for(recipient)
    # clean up any slashes from the address
    addr = recipient.gsub(/\//, "_")
    raise "Invalid recipient address" unless addr =~ /\A[^@]+@[^@]+\.[^@]+\z/

    File.join(@config_dir, "#{addr}.yml")
  end

  # find the config file for the list
  def find_config_path
    # What list was this message sent to? Try to find the
    # envelope recipient that was used in SMTP "RCPT TO".
    # Otherwise, "To: list1@ourdomain, list2@ourdomain" would
    # fail to deliver to list2.
    delivered_to =  @mail.header["Delivered-To"] ||
                    @mail.header["X-Delivered-To"] ||
                    @mail.header["Original-To"] ||
                    @mail.header["X-Original-To"] ||
                    @mail.header["Envelope-To"] ||
                    @mail.header["X-Envelope-To"]
    candidates =
      if delivered_to
        [delivered_to.value]
      else
        # if all else fails, look at the To: addresses
        @mail.to
      end

    candidates.each do |list|
      path = config_path_for(list)
      if File.exist?(path)
        @list = list
        return path
      end
    end
    raise Errno::ENOENT
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
