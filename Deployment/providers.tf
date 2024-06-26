terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.2"
    }
  }

  backend "s3" {
    bucket         = "olatest-logger-lambda"
    key            = "terraform/aws/deployment.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-s3-backend-locking"
    encrypt        = true
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "Dev"
    }
  }
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name, "--region", var.aws_region]
    }
  }
}