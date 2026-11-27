# Suffixe aléatoire : les noms de bucket sont uniques au niveau mondial
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "shared" {
  bucket = "${replace(local.prefix, "_", "-")}-lab7-${random_id.bucket_suffix.hex}"

  # Le bucket est versionné : sans ça, terraform destroy échoue tant qu'il reste des versions
  force_destroy = true

  tags = {
    Name = "${local.prefix}_lab7"
    Pair = local.prefix
    Lab  = "lab7"
  }
}

resource "aws_s3_bucket_public_access_block" "shared" {
  bucket = aws_s3_bucket.shared.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "shared" {
  bucket = aws_s3_bucket.shared.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "shared" {
  bucket = aws_s3_bucket.shared.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "shared" {
  bucket = aws_s3_bucket.shared.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "shared" {
  bucket = aws_s3_bucket.shared.id

  # Les règles sur les versions noncurrent n'ont de sens qu'une fois le versioning actif
  depends_on = [aws_s3_bucket_versioning.shared]

  rule {
    id     = "cleanup-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    expiration {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
