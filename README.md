# Direct File Upload With Paperclip and S3-compatible Object Storage

### Context
- Application with jQuery, jQuery-UI and jQuery-File-Upload
- Production database is PostgreSQL
- S3-compatible Object Storage
- AWS credentials stored in the environment
- An application with multi-tenancy strategy
- Attachments are stored in separate directories per tenant
- Attachments paths are obfuscated like so:
  - path: `:tenant_directory/:class/:attachment/:hash/:style/:filename`
  - hash_data: `:id/:extension/:fingerprint/:updated_at`
  - hash_digest: algorithm is the default `Digest::MD5` and S3 encryption is `SSE-S3` or `plaintext` (not `SSE-C` or `SSE-KMS`)

### Requirements
- Rails 5.2, 6.0, 6.1  
  Rails 6.2 introduces a breaking with `ActiveRecord::Base.connection_config` (the workaround is indeed easy)
- Ruby 2.6+, 3.0, 3.1
- `kt-paperclip`
- `aws-s3-sdk`
- `fog-aws`

### Models
- `Attachment` refers to an ActiveRecord model to which are attached uploaded files using Paperclip
- `Contract` refers to an ActiveRecord model having many attachments through polymorphic association 

### CORS

Object storage must includes adapted CORS settings, for instance:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "PUT"
        ],
        "AllowedOrigins": [
            "http://127.0.0.1:3000",  // development
            "https://your-domain.com" // production
        ],
        "ExposeHeaders": []
    }
]
```
