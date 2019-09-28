#!/usr/bin/env ruby

CONFIG_DIR = __dir__


require "mail"

class MailTitmouse
  attr_reader :mail

  def initialize(maildata)
    @mail = Mail.new(maildata)
  end

  def run
    p @mail.from
  end
end

if $0 == __FILE__
  MailTitmouse.new(STDIN.read).run
end
