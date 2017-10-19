require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'csv'
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

  def scrape(name:, title:, location:)
    set_up_agent
    retrieve_job_results(name, title, location)
    export_matches(name)
  end

  private

  def set_up_agent
    agent.history_added = Proc.new { sleep 0.5 }
    agent.user_agent_alias = 'Mac Safari'
  end

  def retrieve_job_results(name, title, location)
    agent.get(@base_url) do |page|
      result = page.form_with(:id => 'search-form') do |form|
        job_title = form.field_with(:id => 'search-field-keyword')
        job_title.value = title

        job_location = form.field_with(:id => 'search-field-location')
        job_location = location
      end.submit

      go_to_job_page(result, name)
    end #agent
  end #retrieve_job_results

  def go_to_job_page(result, name)
    puts "Finding results for #{name}"
    result.links_with(:href => /jobs\/detail/).each do |link|
      job = Job.new
      job.title = link.text.strip

      job_page = link.click
      build_job(job_page, job)
    end
  end

  def build_job(job_page, job)
    puts "Building job #{job.title}..."
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
  end

  def export_matches(name)
    puts "Exporting matches for #{name}..."
    CSV.open("exports/#{name}-jobs-#{Time.now}.csv", "wb") do |csv|
      csv << [ "title",
              "company",
              "location",
              "description",
              "date_posted",
              "date_scraped",
              "salary",
              "skills",
              "remote" ]
      @matches.each do |job|
        csv << [ job.title,
                job.company,
                job.location,
                job.description,
                job.date_posted,
                job.date_scraped,
                job.salary,
                job.skills,
                job.remote ]
      end #matches
    end #CSV
  end

end #scraper

scraper = Scraper.new('https://www.dice.com')
scraper.scrape(title: 'Ruby on Rails Engineer', location: 'New Orleans, LA', name: 'anne')
# scraper.scrape(title: 'Data Analyst Business Analyst', location: 'New Orleans, LA', name: 'josh')

# scraper.export_matches

#@params_url = "https://www.dice.com/jobs?q=Ruby+on+Rails+Engineer&l=New+Orleans%2C+LA&searchid=3113708184159&stst="