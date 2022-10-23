
resource "aws_s3_bucket" "this" {
  bucket = var.name

  tags = {
    Name        = var.name
  }
}

resource "aws_s3_bucket_public_access_block" "ablk" {
  count                   = 1 
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "object1" {
    for_each = fileset("${var.dir}/", "*")
    bucket = aws_s3_bucket.this.id
    key = each.value
    source = "${var.dir}/${each.value}"
    etag = filemd5("${var.dir}/${each.value}")
}

# resource "aws_s3_object" "object2" {
#     for_each = fileset("${var.dir}/", "*")
#     bucket = aws_s3_bucket.this.id
#     key = each.value
#     source = "${var.dir}/${each.value}"
#     etag = filemd5("${var.dir}/${each.value}")
# }