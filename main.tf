resource "aws_s3_bucket" "static_site_bucket" {
  bucket = var.bucket_name
  acl    = "public-read"

  website {
    error_document = "error.html"
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_website_configuration" "static_site_bucket_website_config" {
  bucket = aws_s3_bucket.static_site_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_object" "static_site_bucket_files" {
  for_each = fileset(var.dir_to_upload_path, "**")

  acl          = "public-read"
  bucket       = aws_s3_bucket.static_site_bucket.bucket
  key          = each.value
  source       = "${var.dir_to_upload_path}/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[0-9a-z]+$", basename(each.value)), null)
  # etag makes the file update when it changes; see https://stackoverflow.com/questions/56107258/terraform-upload-file-to-s3-on-every-apply
  etag = filemd5("${var.dir_to_upload_path}/${each.value}")
}
