require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'pry'

require_relative 'job'

class Scraper
  attr_reader :agent

  def initialize(url)
    @base_url = url
    @sleep_time = 0.5
    @agent = Mechanize.new
    @matches = []
  end

  def scrape(title:, location:, distance:)
    set_up_agent
    retrieve_job_results(title, location)
    # export matches to csv
  end

  private

  def set_up_agent
    agent.history_added = Proc.new { sleep 0.5 }
    agent.user_agent_alias = 'Mac Safari'
  end

  def retrieve_job_results(title, location)
    agent.get(@base_url) do |page|
      result = page.form_with(:id => 'search-form') do |form|
        job_title = form.field_with(:id => 'search-field-keyword')
        job_title.value = title

        job_location = form.field_with(:id => 'search-field-location')
        job_location = location
      end.submit

      go_to_job_page(result)
    end #agent
  end #retrieve_job_results

  def go_to_job_page(result)
    result.links_with(:href => /jobs\/detail/).each do |link|
      job = Job.new
      job.title = link.text.strip

      job_page = link.click
      build_job(job_page, job)
    end
  end

  def build_job(job_page, job)
    job.company = job_page.root.css('li.employer a span').text.strip
    job.description = job_page.root.css('#jobdescSec[itemprop="description"]').text.strip
    job.location = job_page.root.css('li.location span').text.strip
    job.date_posted = job_page.root.css('li.posted').text.strip
    job.date_scraped = Time.now
    job.salary = job_page.root.css('.iconsiblings[itemprop="baseSalary"]').text.strip
    job.skills = job_page.root.css('.iconsiblings[itemprop="skills"]').text.strip
    job.remote = job_page.root.css('.iconsiblings span.mL20').text.strip

    add_job_to_matches(job)
  end #build_job

  def add_job_to_matches(job)
    @matches << job
    p job
  end

end #scraper

scraper = Scraper.new('https://www.dice.com')
scraper.scrape(title: 'Ruby on Rails Engineer', location: 'New Orleans, LA', distance: 0)

#@params_url = "https://www.dice.com/jobs?q=Ruby+on+Rails+Engineer&l=New+Orleans%2C+LA&searchid=3113708184159&stst="