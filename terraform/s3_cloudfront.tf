resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.environment}-web-one-page"
}

resource "null_resource" "clone_and_upload_website" {
  provisioner "local-exec" {
    command = <<EOT
      # Clone the GitHub repository
      git clone https://github.com/designmodo/html-website-templates.git /tmp/website
      cp -r /tmp/website/'One Page Portfolio Website Template' /tmp/website/one_page

      # Modify the index.html file to include the visitor counter with API Gateway URL
      sed -i '/<body class="slides chain simplifiedMobile animated">/a \
      <div id="visitorCount">Loading...</div>\
      <script>\
        async function getVisitorCount() {\
          try {\
            const apiUrl = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/visitor-count";\
            const response = await fetch(apiUrl);\
            if (!response.ok) {\
              throw new Error("Network response was not ok");\
            }\
            const data = await response.json();\
            document.getElementById("visitorCount").textContent = `Visitors: $${data.visitor_count}`;\
          } catch (error) {\
            console.error("Error fetching visitor count:", error);\
            document.getElementById("visitorCount").textContent = "Failed to load visitor count.";\
          }\
        }\
        window.onload = getVisitorCount;\
      </script>' /tmp/website/one_page/index.html

      # Copy the HTML website template files to the S3 bucket
      aws s3 sync /tmp/website/one_page s3://${aws_s3_bucket.s3_bucket.bucket}
    EOT
  }

  # Ensure the bucket is created before uploading
  depends_on = [aws_s3_bucket.s3_bucket, aws_apigatewayv2_api.lambda_api]
}

output "s3_website_url" {
  value       = aws_s3_bucket.s3_bucket.bucket
  description = "The website URL in S3"
}

# CloudFront distribution for the S3 website
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.s3_bucket.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront distribution for ${aws_s3_bucket.s3_bucket.bucket}"
  default_root_object = "index.html"

  # Default cache behavior (forward headers, methods, and caching settings)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.s3_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Price class for global distribution (reduce the cost by limiting distribution areas)
  price_class = "PriceClass_100" # Limits distribution to North America and Europe


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# CloudFront origin access identity for secure access to the S3 bucket
resource "aws_cloudfront_origin_access_identity" "origin_identity" {
  comment = "OAI for ${aws_s3_bucket.s3_bucket.bucket}"
}

# Attach bucket policy to allow CloudFront to access the S3 bucket
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_identity.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

output "cloudfront_url" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "The CloudFront distribution URL"
}
