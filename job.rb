class Job
  attr_accessor :title, :company, :location, :description, :date_posted, :date_scraped, :salary, :skills, :remote
  def initialize
    @title = ''
    @company = ''
    @location = ''
    @description = ''
    @date_posted = ''
    @date_scraped = ''
    @salary = ''
    @skills = ''
    @remote = ''
  end

end