#!/usr/bin/env ruby

require "mail"

class MailTitmouse
  attr_reader :mail

  def initialize(maildata)
    @mail = Mail.new(maildata)
  end

  def find_config_path
    "#{__dir__}/config/#{@mail.to.first}"
  end

  def run
    p @mail.from
  end
end

if $0 == __FILE__
  MailTitmouse.new(STDIN.read).run
end
