# SRE Technical Test — Step-by-step Solution Pack

This repository contains a working baseline for the test:

- Alpine-based **Nginx + PHP 8.1** image (non-root, hardened)
- **docker-compose** for web and PostgreSQL 16
- **Ansible** playbook to force-update the compose stack on a remote server via SSH key
- **GitLab CI** with *build* and *deploy* jobs depending on file changes
- **Security hardening** for Nginx/PHP
- **Log rotation** scripts in Bash and Python
- **Answer** of case scenario

Details Techincal Test summary

A. Web Server Hardening (Nginx + PHP-FPM)

Nginx:

1. Disabled autoindex → no directory listing without index.php/html.
2. Blocked access to hidden folders like .git/.
3. Removed user root; directive → container runs as non-root web user.
4. Changed Server header to secure using headers-more → no Nginx version leakage.

PHP-FPM:

1. Disabled dangerous functions: exec, shell_exec, system, passthru, proc_open, popen.
2. PHP-FPM runs as non-root (web user).
3. Logs redirected to /var/www/logs/php-fpm-error.log.

App:
index.php outputs Hello World, test message, current time, and PHP version → proves app is working.

B. PostgreSQL Setup

Two users created:
- appuser → full access, owner of sre database.
- readonly → can only SELECT data.

Database sre created with appuser as owner.
Init script (db/init/init.sql) mounted via docker-entrypoint-initdb.d/ → automatic on container bootstrap.

Postgres tuned:
- Increased max_connections=300 via Compose command override.
Verified using SHOW max_connections; query.

C. Docker & Docker Compose

Dockerfile:
1. Based on Alpine Linux.
2. Installs Nginx, PHP 8.1 + extensions.
3. Copies hardened configs (nginx.conf, default.conf, zz-security.ini, www.conf, logging.conf).
4. Runs as non-root web user.
5. Entrypoint script runs both PHP-FPM and Nginx.

docker-compose.yml:
1. web service → builds/pulls hardened image.
2. db service → Postgres with init script + increased connections.
3. Persistent volume dbdata.
4. Environment variables wired through .env (ignored in git, handled in GitLab CI).

D. Ansible Deployment

Inventory (hosts.ini):
Holds host IP, SSH key, Docker Hub username, and password.

Playbook:
1. Copies docker-compose.yml to /opt/sre on target server.
2. Logs in to Docker Hub using credentials.
3. Runs docker compose pull && docker compose up -d.

E. CI/CD – GitLab Pipeline

Jobs defined:
- build → triggered when Dockerfile, docker/**, or app/** changes. Builds, tags, pushes Docker image.
- deploy → triggered when docker-compose.yml, docker-compose.db.yml, or ansible/** changes. Runs on server via SSH.

security_scan → runs trivy repo on every commit (when: always).

Rules optimized:
- Dockerfile changes → build + deploy.
- docker-compose changes → deploy only.

Secrets management:
- .env ignored in git.
- GitLab CI/CD Variables hold sensitive values (DOCKERHUB_USERNAME, DOCKERHUB_PASSWORD, APPUSER_PASSWORD, etc.).

F. Log Rotation Scripts

Bash script (scripts/logrotate.sh):
Loops over *.log in given dir.
If size > 5 MB → archive with gzip timestamp, truncate original, log action with timestamp.

Python script (scripts/logrotate.py):
Same logic as Bash version.


## Quickstart
```bash
# Build and run locally (web only)
docker compose up -d --build

# Or with DB
docker compose -f docker-compose-db.yml up -d --build

# Visit http://localhost:8080

# Run Script logrotate
./scripts/logrotate.sh /path/to/logs ./logrotate.log
python3 scripts/logrotate.py /path/to/logs ./logrotate.log 5
