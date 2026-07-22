variable "environment" {
  type        = string
  description = "Środowisko, np. dev lub prod"
}

variable "github_repos" {
  type        = list(string)
  description = "Lista repozytoriów GitHub uprawnionych do uwierzytelniania przez OIDC, np. [\"fearly231/fleet-manager-infra\", \"fearly231/fleet-manager\"]"
}
