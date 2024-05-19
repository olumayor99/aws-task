resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.dev.id
  }

  spec {
    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        service_account_name = "default"

        security_context {
          fs_group        = 1000
          run_as_group    = 1000
          run_as_non_root = true
          run_as_user     = 1000
        }

        container {
          name = "server"

          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
            privileged                = false
            read_only_root_filesystem = true
          }

          image = "olumayor99/doyenify-devops"

          port {
            container_port = 80
          }

          readiness_probe {
            initial_delay_seconds = 10

            http_get {
              path = "/"
              port = 80
            }
          }

          liveness_probe {
            initial_delay_seconds = 10

            http_get {
              path = "/"
              port = 80
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}
