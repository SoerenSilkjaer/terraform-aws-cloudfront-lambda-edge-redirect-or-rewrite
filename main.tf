module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  providers = {
    aws = aws.us-east-1
  }

  domain_name  = var.domain
  zone_id      = var.domain_zone_id

  subject_alternative_names = var.subject_alternative_names
  wait_for_validation = true
}

resource "aws_cloudfront_distribution" "distribution" {
  provider = aws.us-east-1
  origin {
    domain_name = var.destination_domain
    origin_id = "main"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 60
      origin_keepalive_timeout = 5
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.description

  aliases = concat([var.domain],var.subject_alternative_names)

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "main"
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" // ID for Managed-CachingDisabled policy
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" // ID for Managed-AllViewer policy
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn = aws_lambda_function.lambda.qualified_arn
      include_body = false
    }
  }

  price_class = "PriceClass_100"
  http_version = "http2and3"

  viewer_certificate {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    iam_certificate_id       = ""
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource local_file config {
  content  = local.config_json
  filename = "${path.module}/lambda/config.json"
}

data archive_file lambdazip {
  depends_on  = [local_file.config]
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source_dir  = "${path.module}/lambda"
}

resource aws_lambda_function lambda {
  provider = aws.us-east-1
  function_name = local.project_name
  role          = aws_iam_role.lambda.arn
  publish       = true
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  memory_size   = 128
  timeout       = 5

  filename         = data.archive_file.lambdazip.output_path
  source_code_hash = data.archive_file.lambdazip.output_base64sha256
}
