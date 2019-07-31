# -----------------------------------------------------------------------------
# Resources: S3
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  tags   = { Name = "${var.tags_name}" }
  bucket = "${var.site_name}-site-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "_" {
  tags   = { Name = "${var.tags_name}" }
  bucket = "${var.site_name}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "${var.site_name}/"
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# -----------------------------------------------------------------------------
# Resources: Cloudfront
# -----------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_identity" "_" {
  tags    = { Name = "${var.tags_name}" }
  comment = "cloudfront origin access identity"
}

resource "aws_cloudfront_distribution" "_" {
  tags         = { Name = "${var.tags_name}" }
  enabled      = true
  default_root_object = "index.html"
  price_class  = "PriceClass_100"
  http_version = "http1.1"
  aliases      = ["${var.site_name}"]

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket._.id}"
    domain_name = "${aws_s3_bucket._.website_endpoint}"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  custom_error_response {
    error_caching_min_ttl = "300"
    error_code            = "404"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-bucket-${aws_s3_bucket._.id}"
    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "1200"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.tls_cert_arn}"
    ssl_support_method  = "sni-only"
  }
}

# -----------------------------------------------------------------------------
# Resources: Route53
# -----------------------------------------------------------------------------

data "aws_route53_zone" "_" {
  tags = { Name = "${var.tags_name}" }
  name = "${var.domain_name}."
}

resource "aws_route53_record" "_" {
  tags    = { Name = "${var.tags_name}" }
  zone_id = "${data.aws_route53_zone._.zone_id}"
  name    = "${var.site_name}"
  type    = "A"

  alias {
    name    = "${aws_cloudfront_distribution._.domain_name}"
    zone_id = "${aws_cloudfront_distribution._.hosted_zone_id}"
    evaluate_target_health = false
  }
}
