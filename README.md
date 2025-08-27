# Assignment 2 Efe Guven

This project deploys a containerized dashboard on AWS Fargate with HTTPS-only access, Basic Auth via Nginx, automated CI/CD using GitHub Actions, and CloudWatch alerts on high CPU.

Architecture

Flow:
Internet → ALB (HTTPS) → Nginx proxy (Basic Auth) → Backend container (3000/tcp) on ECS Fargate → CloudWatch metrics & alarms → SNS email.

Network: VPC with public subnet + IGW.

Security: ALB SG allows 80/443 (80 redirects to 443). Service SG only allows 3000 from ALB SG.

TLS: ACM certificate for domain_name (DNS validation).

Observability: CloudWatch metrics for ECS service; alarm on CPU > 70% for 5 min → SNS email.

CI/CD: GitHub Actions builds/pushes images to ECR and updates the ECS service on pushes to main.

# Structure
```
├─ infrastructure/          # Terraform IaC (AWS)
│  ├─ main.tf               # provider + backend (local by default)
│  ├─ network.tf            # VPC, subnet, routes, security groups
│  ├─ compute.tf            # ECS cluster, ALB, target group
│  ├─ ecr_ecs.tf            # ECR repos, IAM roles, task def, service
│  ├─ https.tf              # ACM cert + ALB listeners (80→443 redirect)
│  ├─ cloudwatch.tf         # CloudWatch alarm + SNS topic/subscription
│  ├─ storage.tf            # S3 bucket for artifacts/logs
│  ├─ variables.tf          # domain_name, alert_email, etc.
│  └─ main.sh               # helper script (init/apply)
├─ httpauth/                # Nginx reverse proxy with Basic Auth
│  ├─ Dockerfile
│  ├─ nginx.conf
│  └─ .htpasswd
├─ cicd/
│  └─ .github/workflows/deploy.yml  # GitHub Actions pipeline
└─ docs/                    # diagrams & screenshots
```

# Configuration
Key variables (see infrastructure/variables.tf), change them to your own:

| Variable      | Default                  | Description                          |
| ------------- | ------------------------ | ------------------------------------ |
| `domain_name` | `example.com`            | FQDN covered by ACM cert / ALB HTTPS |
| `alert_email` | `your.email@example.com` | SNS subscription target for alerts   |

# Deploy
1. Start main.sh file inside infrastructure folder
2. GitHub Actions. Push to main → pipeline builds/pushes images to ECR → updates ECS service.

# Basic Auth
httpauth/Dockerfile builds Nginx proxy with .htpasswd + nginx.conf.
ECS task runs two containers: backend (3000) + proxy (80/443).
ALB targets proxy, enforcing Basic Auth.
All traffic is redirected to HTTPS.
Certificates come from AWS ACM (free, managed).

# Monitoring
CloudWatch alarm: CPU > 70% for 5 min.
Sends email via SNS (cpu-alerts-topic). Confirm subscription.
