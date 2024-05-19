resource "kubernetes_service_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.dev.id
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.frontend.spec.0.template.0.metadata.0.labels.app
    }
    port {
      name        = "grpc"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "LoadBalancer"
  }
}