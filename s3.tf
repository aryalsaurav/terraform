resource "aws_s3_bucket" "env_files" {
  bucket = "${local.prefix}-env-files"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-env-files"
    }
  )
}

resource "aws_s3_bucket_ownership_controls" "env_files" {
  bucket = aws_s3_bucket.env_files.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

}


resource "aws_s3_bucket_acl" "env_files" {
  depends_on = [aws_s3_bucket_ownership_controls.env_files]

  bucket = aws_s3_bucket.env_files.id
  acl    = "private"

}

resource "aws_s3_bucket" "app_storage" {
  bucket = "${local.prefix}-app-storage"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-app-storage"
    }
  )
}

resource "aws_s3_bucket_ownership_controls" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

}


resource "aws_s3_bucket_acl" "app_storage" {
  depends_on = [aws_s3_bucket_ownership_controls.app_storage]

  bucket = aws_s3_bucket.app_storage.id
  acl    = "private"

}


