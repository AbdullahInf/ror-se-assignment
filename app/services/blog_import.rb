# Service to import blogs from a CSV file in batches. Inserts blogs in batches of 1000 rows for efficiency.
# Rolls back the transaction and logs errors if any issues occur.

class BlogImport < ApplicationService
  attr_accessor :file, :user
  BATCH_SIZE = 1000

  def initialize(user, file)
    @file = file
    @user = user
    @errors = @blogs_batch = []
  end

  def call
    raise 'Please upload a CSV file' unless file && file.content_type == 'text/csv'

    ActiveRecord::Base.transaction do
      CSV.foreach(@file.path, headers: true, encoding: 'utf8') do |row|
        # Ensure we only select valid attributes: title, body, and user_id
        sanitized_row = sanitize_attributes(row.to_h.merge(user_id: @user.id))
        @blogs_batch << sanitized_row
        insert_batch! if @blogs_batch.size >= BATCH_SIZE
      end
      insert_batch! unless @blogs_batch.empty?
    end

  rescue => e
    @errors << "Failed to import blogs: #{e.message}"
  end

  def errors
    @errors.join(' ,')
  end

  private

  # This method filters out any attributes not present in the Blog model
  def sanitize_attributes(row)
    row.slice('title', 'body', :user_id)
  end

  def insert_batch!
    Blog.insert_all!(@blogs_batch)
    @blogs_batch.clear
  end
end
