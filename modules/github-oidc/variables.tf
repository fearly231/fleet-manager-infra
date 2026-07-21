variable "environment" {
  type        = string
  description = "Środowisko, np. dev lub prod"
}

variable "github_repo" {
  type        = string
  description = "Nazwa repozytorium na GitHubie, np. fearly231/fleet-manager-infra"
}
