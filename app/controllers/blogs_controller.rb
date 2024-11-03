require 'csv'
class BlogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blog, only: %i[show edit update destroy]

  # GET /blogs or /blogs.json
  def index
    @pagy, @blogs = pagy(filtered_blogs)
  end

  # GET /blogs/1 or /blogs/1.json
  def show; end

  # GET /blogs/new
  def new
    @blog = current_user.blogs.new
  end

  # GET /blogs/1/edit
  def edit; end

  # POST /blogs or /blogs.json
  def create
    @blog = current_user.blogs.new(blog_params)

    respond_to do |format|
      if @blog.save
        format.html { redirect_to blog_url(@blog), notice: "Blog was successfully created." }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blogs/1 or /blogs/1.json
  def update
    respond_to do |format|
      if @blog.update(blog_params)
        format.html { redirect_to blog_url(@blog), notice: "Blog was successfully updated." }
        format.json { render :show, status: :ok, location: @blog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1 or /blogs/1.json
  def destroy
    respond_to do |format|
      if @blog.destroy
        format.html { redirect_to blogs_url, notice: "Blog was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to blogs_url, alert: "Failed to destroy the blog." }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    file = params[:attachment]
    blog_import = BlogImport.new(current_user, file)
    blog_import.call
    flash[blog_import.errors.present? ? :alert : :notice] = blog_import.errors.presence || 'Blogs imported successfully!'

    redirect_to blogs_path
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_blog
    @blog = current_user.blogs.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def blog_params
    params.require(:blog).permit(:title, :body, :user_id)
  end

  def filtered_blogs
    current_blogs = current_user.blogs
    current_blogs = current_blogs.where("title ILIKE :query OR body ILIKE :query", query: "%#{params[:search]}%") if params[:search].present?
    current_blogs
  end
end
