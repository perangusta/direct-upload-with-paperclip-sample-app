Paperclip::Attachment.default_options.update(
  { hash_secret: 'my paperclip hash secret' }
)

Paperclip.interpolates :tenant_directory  do |attachment, _style|
  attachment.instance.tenant_directory
end
