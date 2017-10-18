require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'pry'

require_relative 'job'

class Scraper
  def initialize(url)
    @url = url
    @sleep_time = 0.5
    @agent = Mechanize.new
    @matches = []
  end

  def scrape(title:, location:, distance:)
    set_up_agent
    search_for_jobs(title, location, distance)
    # go to results page
    # click on each job link
    # build a Job object
    # populate Job with details
    # push job into matches
    # export matches to csv
  end

  private

  def set_up_agent
    @agent.history_added = Proc.new { sleep 0.5 }
    @agent.user_agent_alias = 'Mac Chrome'
  end

  def search_for_jobs(title, location, distance)
  end

end

scraper = Scraper.new('https://www.dice.com')
scraper.scrape(title: 'Ruby Rails Engineer', location: 'New Orleans, LA', distance: 0)

