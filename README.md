# GitHub Actions Workshop
### Mellon Group · FinTech DevOps Bootcamp · Module 8

Σε αυτό το workshop θα χτίσεις από το μηδέν ένα **CI/CD pipeline** χρησιμοποιώντας GitHub Actions. Θα δουλέψεις με πραγματικό cloud infrastructure, secrets, Docker, και branch-based deployments.

**Δυσκολία:** ⭐⭐⭐  
**Προαπαιτούμενα:** GitHub account, DockerHub account

---

## Τι θα χτίσεις

```
push σε οποιοδήποτε branch
        │
        ▼
┌───────────────┐
│  Exercise 1   │  Lint → Tests → Summary
│   CI Pipeline │  (runs on GitHub cloud runners)
└───────┬───────┘
        │
        │ push σε develop / main
        ▼
┌───────────────┐
│  Exercise 2   │  develop → staging
│  Deploy by    │  main    → production
│  Branch       │  (με secrets & environments)
└───────┬───────┘
        │
        ▼
┌───────────────┐
│  Exercise 3   │  Build Docker image
│  Docker       │  Push → DockerHub
│               │  Pull → Run → Health Check
└───────────────┘
```

---

## Setup

### 1. Clone το repository

```bash
git clone git@github.com:micksar/github-actions-workshop.git
cd github-actions-workshop
```

Δημιούργησε τα branches που θα χρειαστείς:

```bash
git checkout -b develop
git push origin develop
git checkout main
```

### 2. Πρόσθεσε Secrets στο GitHub

Πήγαινε στο GitHub repo σου → **Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Value |
|---|---|
| `STAGING_DEPLOY_TOKEN` | `staging-secret-123` |
| `PROD_DEPLOY_TOKEN` | `prod-secret-456` |
| `NOTIFY_WEBHOOK` | `https://example.com/notify` |
| `DOCKERHUB_USERNAME` | το DockerHub username σου |
| `DOCKERHUB_TOKEN` | DockerHub Access Token* |

*DockerHub → Account Settings → Security → New Access Token

### 3. Δημιούργησε GitHub Environments

Settings → **Environments** → New environment

- Δημιούργησε: `staging`
- Δημιούργησε: `production`
  - Για το production, μπορείς να προσθέσεις **Required reviewers** (Protection rules)

### 4. Τρέξε την εφαρμογή locally (optional)

```bash
cd app
pip install -r requirements.txt
ENVIRONMENT=local TEAM_NAME="My Team" python app.py
# Άνοιξε: http://localhost:5000
```

---

## Exercise 1 — CI Pipeline (35 min)

**Αρχείο:** `.github/workflows/01-ci.yml`

Άνοιξε το αρχείο και βρες όλα τα σχόλια `TODO`. Πρέπει να συμπληρώσεις:

1. **TODO 1** — Triggers: πότε να τρέχει το workflow
2. **TODO 2** — Env variables για το test job
3. **TODO 3** — Step: setup Python
4. **TODO 4** — Step: install dependencies
5. **TODO 5** — Step: run pytest

**Πώς να δοκιμάσεις:**
```bash
git add .github/workflows/01-ci.yml
git commit -m "feat: add CI pipeline"
git push origin main
```
Πήγαινε στο GitHub → **Actions** tab → βλέπεις το workflow να τρέχει!

**Ερώτηση:** Τι γίνεται αν σκόπιμα σπάσεις ένα test; Δοκίμασε το!

---

## Exercise 2 — Branch-Based Deployments (45 min)

**Αρχείο:** `.github/workflows/02-deploy.yml`

Αυτό το workflow κάνει **διαφορετικό deploy ανάλογα με το branch**:

```
push σε develop  →  deploy STAGING  (χρησιμοποιεί STAGING_DEPLOY_TOKEN)
push σε main     →  deploy PRODUCTION (χρησιμοποιεί PROD_DEPLOY_TOKEN)
```

Συμπλήρωσε τα TODOs 1–7:

1. **TODO 1** — Branches trigger
2. **TODO 2** — Global APP_VERSION
3. **TODO 3** — Condition για staging job
4. **TODO 4** — Secret για staging token
5. **TODO 5** — Condition για production job
6. **TODO 6** — Pre-deployment check step
7. **TODO 7** — Secret για webhook

**Πώς να δοκιμάσεις:**
```bash
# Test staging deploy
git checkout develop
git commit --allow-empty -m "test: trigger staging deploy"
git push origin develop

# Test production deploy
git checkout main
git merge develop
git push origin main
```

**Παρατήρηση:** Στο GitHub Actions UI, βλέπεις ότι τρέχει ΜΟΝΟ το αντίστοιχο deploy job;

---

## Exercise 3 — Docker Build & DockerHub (50 min)

**Αρχείο:** `.github/workflows/03-docker.yml`

Αυτό το workflow:
1. Χτίζει Docker image από τον κώδικα στο `./app`
2. Ανεβάζει στο DockerHub με tag ανάλογα με branch
3. Κατεβάζει το image και τρέχει container
4. Κάνει health check στο running container

Συμπλήρωσε τα TODOs 1–6:

1. **TODO 1** — Set image tag (main→latest, develop→develop)
2. **TODO 2** — DockerHub login
3. **TODO 3** — Build & Push
4. **TODO 4** — Pull image
5. **TODO 5** — Run container
6. **TODO 6** — Health check

**Πώς να δοκιμάσεις:**
```bash
git add .github/workflows/03-docker.yml
git commit -m "feat: add Docker pipeline"
git push origin develop
```

Μετά πήγαινε στο DockerHub → βλέπεις το image `<username>/workshop-app:develop`!

**Bonus:** Uncomment το `security-scan` job στο τέλος του αρχείου!

---

## Bonus — Matrix Builds (20 min)

**Αρχείο:** `.github/workflows/04-bonus-matrix.yml`

Τρέξε τα tests παράλληλα σε Python 3.10, 3.11, 3.12 — ταυτόχρονα, χωρίς να γράψεις 3 ξεχωριστά jobs.

1. **TODO 1** — Πρόσθεσε τις Python versions στο matrix
2. **TODO 2** — Πρόσθεσε δεύτερο dimension (OS matrix)

---

## Δομή Repository

```
github-actions-workshop/
├── app/
│   ├── app.py              ← Flask API (3 endpoints)
│   ├── requirements.txt
│   ├── Dockerfile          ← pulls python:3.11-slim from DockerHub
│   └── tests/
│       └── test_app.py     ← pytest tests
│
├── .github/
│   └── workflows/
│       ├── 01-ci.yml       ← Exercise 1: CI pipeline
│       ├── 02-deploy.yml   ← Exercise 2: Branch deployments
│       ├── 03-docker.yml   ← Exercise 3: Docker
│       └── 04-bonus-matrix.yml
│
├── solutions/              ← μην κοιτάς πριν προσπαθήσεις!
│   ├── 01-ci-solution.yml
│   ├── 02-deploy-solution.yml
│   └── 03-docker-solution.yml
│
└── README.md
```

---

## Endpoints της εφαρμογής

| Endpoint | Περιγραφή |
|---|---|
| `GET /` | Επιστρέφει environment info |
| `GET /health` | Health check (χρησιμοποιείται από το pipeline) |
| `GET /info` | Λεπτομέρειες για Python version κλπ |

---

## Key Concepts Cheatsheet

```yaml
# Triggers
on:
  push:
    branches: ['**']        # όλα τα branches
  pull_request:
    branches: [main]

# Environment variables
env:
  MY_VAR: "value"           # global
jobs:
  my-job:
    env:
      JOB_VAR: "value"      # job-level

# Secrets
env:
  TOKEN: ${{ secrets.MY_SECRET }}

# Conditional jobs
if: github.ref_name == 'main'

# Job outputs
outputs:
  my_output: ${{ steps.my-step.outputs.value }}
# στο step:
run: echo "value=hello" >> $GITHUB_OUTPUT

# Matrix builds
strategy:
  matrix:
    python-version: ["3.10", "3.11", "3.12"]

# Docker login
uses: docker/login-action@v3
with:
  username: ${{ secrets.DOCKERHUB_USERNAME }}
  password: ${{ secrets.DOCKERHUB_TOKEN }}
```

---

## Troubleshooting

**"Secret not found" error:**  
→ Βεβαιώσου ότι το secret name είναι ΑΚΡΙΒΩΣ ίδιο (case-sensitive)

**Docker push 403 error:**  
→ Το DOCKERHUB_TOKEN πρέπει να έχει **Read/Write** permissions

**Tests fail locally αλλά όχι στο CI (ή αντίστροφα):**  
→ Έλεγξε τα env variables — το CI έχει `ENVIRONMENT=testing`

**Workflow δεν τρέχει:**  
→ Βεβαιώσου ότι το αρχείο είναι στο `.github/workflows/` και το YAML είναι valid  
→ Χρησιμοποίησε https://yaml-lint.com/ για validation
