To apply the **Terraform** configuration with the **namespace** `develop`, you need to ensure that:

1. **The namespace exists** before deploying resources.
2. Each resource explicitly specifies `namespace = "develop"`.

---

### **1️⃣ Create the Namespace (`namespace.tf`)**
```hcl
resource "kubernetes_namespace" "develop" {
  metadata {
    name = "develop"
  }
}
```

---

### **2️⃣ Update Deployment (`deployment.tf`)**
Modify the `metadata` block to include the namespace.

```hcl
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "deploy-nginx"
    namespace = kubernetes_namespace.develop.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "public.ecr.aws/nginx/nginx:1.27.0"

          port {
            container_port = 8080
            name           = "http-port"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}
```

---

### **3️⃣ Update Service (`service.tf`)**
```hcl
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.develop.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 8080
      name        = "http-port"
    }

    type = "ClusterIP"
  }
}
```

---

### **4️⃣ Update Ingress (`ingress.tf`)**
```hcl
resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "ingress-service"
    namespace = kubernetes_namespace.develop.metadata[0].name
    annotations = {
      "kubernetes.io/tls-acme" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = ["test.127-0-0-1.nip.io"]
      secret_name = "tls-dbadmin"
    }

    rule {
      host = "test.127-0-0-1.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.nginx.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
```

---

### **5️⃣ Apply Terraform**
Run the following commands:

```sh
terraform init
terraform apply -auto-approve
```

✅ **This ensures all resources are created inside the `develop` namespace.** 🚀
