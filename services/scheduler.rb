require 'rufus-scheduler'

module Scheduler
  def self.create
      Rufus::Scheduler.new
  end
end