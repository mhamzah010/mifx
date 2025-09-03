# SRE Technical Test — Step-by-step Solution Pack

This repository contains a working baseline for the test:

- Alpine-based **Nginx + PHP 8.1** image (non-root, hardened)
- **docker-compose** for web and PostgreSQL 16
- **Ansible** playbook to force-update the compose stack on a remote server via SSH key
- **GitLab CI** with *build* and *deploy* jobs depending on file changes
- **Security hardening** for Nginx/PHP
- **Log rotation** scripts in Bash and Python
- **Answer** of case scenario

## Quickstart

```bash
# Build and run locally (web only)
docker compose up -d --build

# Or with DB
docker compose -f docker-compose.db.yml up -d --build

# Visit http://localhost:8080