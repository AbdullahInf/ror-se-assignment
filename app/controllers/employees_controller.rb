class EmployeesController < ApplicationController
  before_action :authenticate_user!
  include EmployeeApi

  def index
    @employees = fetch_all_employees(params[:page])
  end

  def show
    @employee = fetch_employee(params[:id])
    redirect_to employees_path if @employee.blank?
  end

  def edit
    @employee = fetch_employee(params[:id])
    redirect_to employees_path if @employee.blank?
  end

  def create
    @employee = create_employee(employee_params)
    redirect_to employee_path(@employee['id'])
  end

  def update
    @employee = update_employee(params[:id], employee_params)
    redirect_to edit_employee_path(@employee['id'])
  end

  private

  def employee_params
    params.permit(:name, :position, :date_of_birth, :salary)
  end
end
