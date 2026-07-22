resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.1"

  values = [
    yamlencode({
      controller = {
        config = {
          "ssl-redirect" = "false"
        }
        service = {
          targetPorts = {
            https = "http"
          }
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"             = "external"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"  = "ip"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"           = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = var.certificate_arn
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
            "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "https"
          }
        }
      }
    })
  ]
}
