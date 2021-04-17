module Services
  class DirectFileUpload
    class Error < StandardError; end

    # maximum time allowed to upload files
    EXPIRES = 60.minutes

    def self.create_presigned_url(file_params:)
      upload_key  = "#{Time.current.to_formatted_s(:iso8601)}-#{SecureRandom.hex(32)}/#{file_params[:name]}"
      upload_path = "#{prefix}/#{upload_key}"
      headers     = { 'Content-Type' => file_params[:type] }
      expires     = Time.current + EXPIRES

      {
        upload_url: storage_connection.put_object_url(bucket, upload_path, expires, headers),
        upload_key: upload_key
      }
    end

    def self.prepare_attachment(paperclip_attachment:, upload_key:)
      upload_path       = "#{prefix}/#{upload_key}"
      requires_download = paperclip_attachment.options[:styles].present? || paperclip_attachment.options[:adapter_options][:hash_digest] != Digest::MD5

      assign_attributes_to_record(paperclip_attachment, upload_path, requires_download)
      move_uploaded_file_to_final_path(paperclip_attachment, upload_path, requires_download)
      remove_temporary_uploaded_file(upload_path)
    end

    def self.assign_attributes_to_record(paperclip_attachment, upload_path, requires_download)
      record = paperclip_attachment.instance

      if requires_download
        record.public_send("#{paperclip_attachment.name}=", URI(storage_connection.directories.new(key: bucket).files.new(key: upload_path).url(Time.current + 10.seconds)))
      else
        headers = storage_connection.head_object(bucket, upload_path)[:headers]
        record.public_send("#{paperclip_attachment.name}_file_name=",    upload_path.split('/').last)
        record.public_send("#{paperclip_attachment.name}_content_type=", headers['Content-Type'])
        record.public_send("#{paperclip_attachment.name}_file_size=",    headers['Content-Length'])
        record.public_send("#{paperclip_attachment.name}_updated_at=",   Time.current)

        # optional column "fingerprint"
        record.public_send("#{paperclip_attachment.name}_fingerprint=",  headers['ETag'].gsub(/"/, ''))
      end

      # manually assign a value to the primary key (usually "id")
      # while assuming that it is required and part of "path"
      assign_primary_key_nextval(paperclip_attachment)
    end

    def self.assign_primary_key_nextval(paperclip_attachment)
      record      = paperclip_attachment.instance
      primary_key = record.class.primary_key

      # leave if primary key is already present OR if it is not part of the path
      return if record.public_send(primary_key).present?
      return if !paperclip_attachment.options[:path].match(/:#{primary_key}/) &&
        !(paperclip_attachment.options[:path].match(/:hash/) && paperclip_attachment.options[:hash_data].match(/:#{primary_key}/))

      primary_key_sequence =
        case ActiveRecord::Base.connection_config[:adapter]
          when 'sqlite3'
            # FOR DEVELOPMENT PURPOSE ONLY: obtaining nextval is not thread-safe
            ActiveRecord::Base.connection.execute("SELECT seq + 1 AS nextval FROM main.sqlite_sequence WHERE name = '#{record.class.table_name}'")
          when 'postgresql'
            ActiveRecord::Base.connection.execute("SELECT nextval(pg_get_serial_sequence('#{record.class.table_name}', '#{primary_key}'))")
        end

      record.public_send("#{primary_key}=", primary_key_sequence.first['nextval'])
    end

    def self.move_uploaded_file_to_final_path(paperclip_attachment, upload_path, requires_download)
      return if requires_download

      storage_connection.copy_object(bucket, upload_path, bucket, paperclip_attachment.path)
    rescue Fog::Errors::Error, Excon::Error => e
      raise Error, e.message
    end

    # choose whether to permanently delete uploaded file temporary location in case versioning is enabled
    PERMANENT_DELETE = true

    def self.remove_temporary_uploaded_file(upload_path)
      options = nil
      if PERMANENT_DELETE
        # to handle permanent deletion, we need to retrieve "VersionId"
        bucket_object_versions = storage_connection.get_bucket_object_versions(bucket, prefix: upload_path)
        version_id = bucket_object_versions.body['Versions'].first['Version']['VersionId']
        options = { 'versionId' => version_id }
      end
      storage_connection.delete_object(bucket, upload_path, options)
    rescue Fog::Errors::Error, Excon::Error => e
      raise Error, e.message
    end

    DIRECT_FILE_UPLOAD_DIRECTORY = 'direct_file_uploads'

    def self.prefix
      "#{tenant_directory}/#{DIRECT_FILE_UPLOAD_DIRECTORY}"
    end

    def self.tenant_directory
      'tenant_identifier' # customize with your own multi-tenancy strategy
    end

    def self.bucket
      @bucket ||= ENV.fetch('S3_BUCKET_NAME')
    end

    def self.storage_connection
      @storage_connection ||= Fog::Storage.new(
        provider:              'AWS',
        region:                ENV['AWS_REGION'],
        aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
    end
  end
end
