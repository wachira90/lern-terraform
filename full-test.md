### **Terraform Configuration**
You'll need to use the **Kubernetes Provider** in Terraform. If you haven't configured your Kubernetes provider yet, ensure you set it up correctly.

---

### **1️⃣ Provider Configuration (`main.tf`)**
```hcl
provider "kubernetes" {
  config_path = "~/.kube/config" # Adjust based on your setup
}
```

---

### **2️⃣ Deployment (`deployment.tf`)**
```hcl
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "deploy-nginx"
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
            container_port = 80
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

### **3️⃣ Service (`service.tf`)**
```hcl
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
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
      target_port = 80
      name        = "http-port"
    }

    type = "ClusterIP"
  }
}
```

---

### **4️⃣ Ingress (`ingress.tf`)**
```hcl
resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name = "ingress-service"
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
#### **Initialize Terraform and Apply**
```sh
terraform init
terraform apply -auto-approve
```

---

### **Breakdown of Terraform Code**
1. **`kubernetes_deployment`**: Defines the **Nginx Deployment** with CPU/memory requests and limits.
2. **`kubernetes_service`**: Creates a **ClusterIP service** exposing the Nginx deployment.
3. **`kubernetes_ingress_v1`**: Configures the **Ingress** to expose the service externally.

✅ **Now, your Kubernetes resources are fully managed via Terraform!** 🚀 Let me know if you need further customizations.
