# EmployeeApi provides methods for interacting with a remote employee API.
# It includes functionality to fetch all employees, retrieve a specific
# employee by ID, create new employee records, and update existing records.
# All interactions are done via HTTP requests, and responses are parsed from JSON format.
module EmployeeApi
  extend ActiveSupport::Concern

  BASE_URL = "https://dummy-employees-api-8bad748cda19.herokuapp.com/employees".freeze

  def fetch_all_employees(page = nil)
    uri = page.present? ? URI("#{BASE_URL}?page=#{page}") : URI(BASE_URL)
    response = Net::HTTP.get(uri)
    response.present? ? JSON.parse(response) : response
  end

  def fetch_employee(id)
    uri = URI("#{BASE_URL}/#{id}")
    response = Net::HTTP.get(uri)
    response.present? ? JSON.parse(response) : response
  end

  def create_employee(employee_params)
    uri = URI(BASE_URL)

    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    parsed_employee_response(request, http_client(uri), employee_params)
  end

  def update_employee(id, employee_params)
    uri = URI("#{BASE_URL}/#{id}")

    request = Net::HTTP::Put.new(uri.path, { 'Content-Type' => 'application/json' })
    parsed_employee_response(request, http_client(uri), employee_params)
  end

  def http_client(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http
  end

  def parsed_employee_response(request, http, employee_params)
    request.body = employee_params.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end
end
