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




resource "aws_s3_bucket" "tf_state" {
  bucket = "${local.prefix}-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-terraform-state"
    }
  )

}

resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}