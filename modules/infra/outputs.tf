output "lb_access_logs" {
    value = aws_s3_bucket.lb_logs.id
}

output "alb_trust_store" {
    value = aws_lb_trust_store.alb_trust_store.arn
}