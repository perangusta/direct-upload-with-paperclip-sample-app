Paperclip::Attachment.default_options.update(
  { hash_secret: 'my paperclip hash secret' }
)

Paperclip::Attachment.default_options.update(
  {
    storage: :s3,
    s3_permissions: 'private',
    s3_credentials: {
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
    },
    s3_region: ENV.fetch('AWS_REGION'),
    bucket: ENV.fetch('S3_BUCKET_NAME')
  }
)

Paperclip.interpolates :tenant_directory  do |attachment, _style|
  attachment.instance.tenant_directory
end

# required to support "styles" (Post Processing)
Paperclip::UriAdapter.register
