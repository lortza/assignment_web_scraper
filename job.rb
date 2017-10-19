class Job
  attr_accessor :title, :job_id, :description_url, :company, :company_id, :location, :description, :date_posted, :salary, :skills, :remote
  def initialize
    @title = ''
    @job_id = ''
    @description_url = ''
    @company = ''
    @company_id =''
    @location = ''
    @description = ''
    @date_posted = ''
    @salary = ''
    @skills = ''
    @remote = ''
  end

end