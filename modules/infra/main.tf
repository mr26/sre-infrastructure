data "aws_caller_identity" "current" {}

resource "aws_eks_cluster" "api_cluster_1" {
  name = "api-cluster-1"

  access_config {
    authentication_mode = "API"
  }

  role_arn = var.cluster_role_arn
  version  = "1.32"


  vpc_config {
    subnet_ids = [var.private_subnet1, var.private_subnet2, var.private_subnet3]
    endpoint_private_access = true
    endpoint_public_access = true
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.api_cluster_1.name
  addon_name               = "vpc-cni"
  depends_on = [ aws_eks_node_group.ng1 ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name             = aws_eks_cluster.api_cluster_1.name
  addon_name               = "coredns"
  depends_on = [ aws_eks_node_group.ng1 ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = aws_eks_cluster.api_cluster_1.name
  addon_name               = "kube-proxy"
  depends_on = [ aws_eks_node_group.ng1 ]
}

resource "aws_eks_addon" "cloudwatch_agent" {
  cluster_name      = aws_eks_cluster.api_cluster_1.name
  addon_name        = "amazon-cloudwatch-observability"
  depends_on = [ aws_eks_node_group.ng1 ]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.api_cluster_1.name
  addon_name               = "aws-ebs-csi-driver"
  depends_on = [ aws_eks_node_group.ng1 ]
}

resource "aws_eks_node_group" "ng1" {
  cluster_name    = aws_eks_cluster.api_cluster_1.name
  node_group_name = "ng-api-cluster-1"
  node_role_arn   = var.node_role_arn
  subnet_ids      = [var.private_subnet1, var.private_subnet2, var.private_subnet3]
  ami_type        = "AL2_ARM_64"
  instance_types = ["t4g.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}

resource "aws_eks_cluster" "api_cluster_2" {
  name = "api-cluster-2"

  access_config {
    authentication_mode = "API"
  }

  role_arn = var.cluster_role_arn
  version  = "1.32"

  vpc_config {
    subnet_ids = [var.private_subnet1, var.private_subnet2, var.private_subnet3]
    endpoint_private_access = true
    endpoint_public_access = true
    security_group_ids = [var.api_cluster2_sec_grp]
  }
}

resource "aws_eks_addon" "vpc_cni2" {
  cluster_name             = aws_eks_cluster.api_cluster_2.name
  addon_name               = "vpc-cni"
  depends_on = [ aws_eks_node_group.ng2 ]
}

resource "aws_eks_addon" "coredns2" {
  cluster_name             = aws_eks_cluster.api_cluster_2.name
  addon_name               = "coredns"
  depends_on = [ aws_eks_node_group.ng2 ]
}

resource "aws_eks_addon" "kube_proxy2" {
  cluster_name             = aws_eks_cluster.api_cluster_2.name
  addon_name               = "kube-proxy"
  depends_on = [ aws_eks_node_group.ng2 ]
}

resource "aws_eks_addon" "cloudwatch_agent2" {
  cluster_name      = aws_eks_cluster.api_cluster_2.name
  addon_name        = "amazon-cloudwatch-observability"
  depends_on = [ aws_eks_node_group.ng2 ]
}

resource "aws_eks_addon" "ebs_csi2" {
  cluster_name             = aws_eks_cluster.api_cluster_2.name
  addon_name               = "aws-ebs-csi-driver"
  depends_on = [ aws_eks_node_group.ng2 ]
}

resource "aws_eks_node_group" "ng2" {
  cluster_name    = aws_eks_cluster.api_cluster_2.name
  node_group_name = "ng-api-cluster-2"
  node_role_arn   = var.node_role_arn
  subnet_ids      = [var.private_subnet1, var.private_subnet2, var.private_subnet3]
  ami_type        = "AL2_ARM_64"
  instance_types = ["t4g.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "sreproj-alb-access-logs"

}


resource "aws_s3_bucket_policy" "lb_logs_bucket_policy" {
  bucket = aws_s3_bucket.lb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AWSLoadBalancerLoggingPolicy"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.lb_logs.arn}/alb/alb-prod/AWSLogs/*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "api_table" {
  name           = "APIUsage"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "APIEndpoint"
  range_key      = "Date"

  attribute {
    name = "APIEndpoint"
    type = "S"
  }

  attribute {
    name = "Date"
    type = "S"
  }
}

resource "aws_ecr_repository" "sre_ecr_repo" {
  name                 = "sre_ecr_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lb_trust_store" "alb_trust_store" {
  name = "alb-trust-store"

  ca_certificates_bundle_s3_bucket = "sreproj-trust-store"
  ca_certificates_bundle_s3_key    = "rootCA.crt"

} 

resource "aws_eks_access_entry" "admin_access_entry1" {
  cluster_name  = aws_eks_cluster.api_cluster_1.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/infra_user" # Or use a role
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_policy1" {
  cluster_name  = aws_eks_access_entry.admin_access_entry1.cluster_name
  principal_arn = aws_eks_access_entry.admin_access_entry1.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "admin_access_entry2" {
  cluster_name  = aws_eks_cluster.api_cluster_2.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/infra_user" # Or use a role
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_policy2" {
  cluster_name  = aws_eks_access_entry.admin_access_entry2.cluster_name
  principal_arn = aws_eks_access_entry.admin_access_entry2.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}