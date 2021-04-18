# Direct File Upload With Paperclip and S3-compatible Object Storage

### Context
- An application with multi-tenancy strategy (not actually implemented here) on which we want to isolate client files stored on S3 in separated directories
- Paths of attachments are obfuscated as follows:
  - path: `:tenant_directory/:class/:attachment/:hash/:style/:filename`
  - hash_data: `:id/:extension/:fingerprint/:updated_at`
  - hash_digest: algorithm is the default `Digest::MD5` and S3 encryption is `SSE-S3` or `plaintext` (not `SSE-C` or `SSE-KMS`)

### Requirements
- Rails 5.2+ (Rails 6.2 introduces a breaking change with `ActiveRecord::Base.connection_config` but the workaround is indeed easy to implement)
- Ruby 2.6+
- `kt-paperclip`
- `aws-s3-sdk`
- `fog-aws`
- jQuery, jQuery-UI and jQuery-File-Upload
- Production database is PostgreSQL
- S3-compatible Object Storage
- AWS credentials stored in the environment

### Main elements of the application
- `Attachment` refers to an ActiveRecord model to which are attached uploaded files using Paperclip
- `Contract` refers to an ActiveRecord model having many attachments through polymorphic association 

```
app/
├── controllers/
│   ├── attachments_controller.rb
│   └── direct_file_uploads_controller.rb
├── javascript/
│   └── packs/
│       └── direct_file_upload.js
├── models/
│   └── attachment.rb
├── services/
│   └── services/
│       └── direct_file_upload.rb
└── views/
    └── attachments/
        └── _form_for_attachable.html.erb
config/
└── initializers/
    └── paperclip.rb
```

### S3 CORS settings

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
            "http://127.0.0.1:3000",
            "https://your-domain.com",
            "https://*.your-domain.com"
        ],
        "ExposeHeaders": []
    }
]
```
