# Fleet Manager - Infrastructure as Code (IaC)

Repozytorium zawiera pełną konfigurację infrastruktury chmurowej w AWS (zarządzanej przez Terraform) oraz manifesty wdrożeniowe Kubernetes dla aplikacji **Fleet Manager**. 

Projekt został zaprojektowany i zaimplementowany zgodnie z najlepszymi praktykami **Senior DevOps** (separacja środowisk, brak cyklicznych zależności, bezpieczne zarządzanie sekretami, konteneryzacja z mechanizmami self-healing).

---

## 📁 Struktura projektu

```text
├── environments/           # Środowiska infrastrukturalne
│   ├── dev/                # Środowisko deweloperskie (oszczędne, pojedynczy NAT, SPOT instancje)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   │   └── *.yaml          # Manifesty Kubernetes dla środowiska dev
│   └── prod/               # Środowisko produkcyjne (HA, Multi-AZ RDS, ON_DEMAND instancje)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       └── backend.tf
└── modules/                # Reużywalne moduły Terraform
    ├── vpc/                # Sieć (VPC, Subnety publiczne/prywatne, NAT, IGW, Route Tables)
    ├── rds/                # Baza danych PostgreSQL (zabezpieczona regułami SG, szyfrowana)
    ├── eks/                # Klaster EKS (wersja 1.35, node groupy, OIDC zintegrowane z IAM)
    ├── secrets/            # Integracja z AWS Secrets Manager
    ├── ecr/                # Repozytoria obrazów kontenerowych (IMMUTABLE, retencja obrazów)
    └── dns/                # Zarządzanie DNS w Route 53 oraz certyfikatami SSL w ACM
```

---

## 🚀 Wymagania wstępne (Prerequisites)

Przed rozpoczęciem upewnij się, że masz zainstalowane i skonfigurowane:
1. **AWS CLI** (zalogowane na odpowiednie konto z uprawnieniami Administratora).
2. **Terraform** (wersja >= 1.5).
3. **kubectl** (do zarządzania klastrem Kubernetes).

---

## ⚙️ Wdrożenie Infrastruktury (Terraform)

### 1. Inicjalizacja i wdrożenie środowiska (np. `dev`)

Przejdź do katalogu odpowiedniego środowiska:
```bash
cd environments/dev
```

Zainicjalizuj dostawców i moduły (stan jest przechowywany w zabezpieczonym kubełku S3 z blokadą stanu):
```bash
terraform init
```

Sprawdź planowane zmiany (dla bezpieczeństwa zweryfikuj, co zostanie utworzone):
```bash
terraform plan
```

Uruchom wdrożenie infrastruktury:
```bash
terraform apply
```

---

## 🌐 Podpięcie domeny z Namecheap do AWS Route 53

Moduł `dns` automatycznie tworzy publiczną strefę w Route 53 dla Twojej domeny (np. `chorogra.me`).

1. Po wykonaniu `terraform apply` odczytaj z konsoli adresy serwerów nazw w sekcji outputs:
   ```bash
   # Przykład outputu:
   route53_name_servers = [
     "ns-1024.awsdns-00.org",
     "ns-512.awsdns-00.net",
     ...
   ]
   ```
2. Zaloguj się do **Namecheap** -> **Domain List** -> **Manage** dla domeny `chorogra.me`.
3. W sekcji **Nameservers** zmień opcję na **Custom DNS** i wklej powyższe 4 adresy serwerów AWS.
4. Zapisz zmiany. Certyfikaty SSL w AWS ACM zostaną automatycznie zweryfikowane przez rekordy DNS.

---

## ☸️ Wdrożenie Aplikacji na EKS (Kubernetes)

Po utworzeniu klastra EKS, skonfiguruj dostęp lokalny (`kubectl`):
```bash
aws eks --region eu-central-1 update-kubeconfig --name dev-fleet-eks-cluster
```

### 1. Utworzenie Sekretu Kubernetes (Wymagane!)
Zgodnie z zasadami bezpieczeństwa, **sekrety nie są przechowywane w gicie**. Przed wdrożeniem manifestów musisz utworzyć sekret `fleet-backend-secrets` w klastrze:

```bash
kubectl create secret generic fleet-backend-secrets \
  --from-literal=DATABASE_URL="postgresql+psycopg://fleet_admin:HASLO_DB@dev-fleet-db-instance.cnuak8o40dpr.eu-central-1.rds.amazonaws.com:5432/fleet_db" \
  --from-literal=SECRET_KEY="twoj-losowy-klucz-jwt-tutaj" \
  --from-literal=DEFAULT_ADMIN_PASSWORD="super-bezpieczne-haslo-admina"
```
*(Uwaga: Hasło bazy `HASLO_DB` oraz dokładny endpoint bazy znajdziesz w AWS Secrets Managerze lub w outputach po zakończeniu `terraform apply`)*.

### 2. Wdrożenie manifestów aplikacji
Zastosuj pliki konfiguracyjne w klastrze:
```bash
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```

---

## 🔒 Bezpieczeństwo i Architektura (Best Practices)

* **Bezpieczeństwo Sieci (Firewall):** Baza danych RDS nie jest wystawiona publicznie. Dostęp do niej ma wyłącznie klaster EKS na porcie `5432` za pomocą dedykowanych reguł `aws_vpc_security_group_ingress_rule`.
* **Brak Plaintext Credentials w Git:** Wszystkie hasła i klucze w manifestach K8s są pobierane przez referencje z sekretów.
* **Auto-Healing w K8s:** Zastosowano testy `livenessProbe` oraz `readinessProbe` dla frontendu i backendu, gwarantujące automatyczną wymianę uszkodzonych podów.
* **ECR Immutability:** Tagowanie obrazów w ECR ustawione jest na `IMMUTABLE`, co zapobiega nadpisywaniu wersji obrazów i ułatwia rollbacki.
* **Rozdzielenie zależności w Terraform:** Generowanie haseł odbywa się w warstwie nadrzędnej (root), dzięki czemu uniknięto cyklicznych zależności modułowych (Circular Dependency).
* **Niezawodność w VPC:** Zapytania z prywatnych podsieci do NAT Gatewaya używają indeksowania modulo, co zapobiega błędom "index out of bounds" przy niesymetrycznych strefach dostępności.