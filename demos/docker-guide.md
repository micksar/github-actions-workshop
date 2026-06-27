# Docker — Πρακτικός Οδηγός για την Τάξη

Τρέξε αυτές τις εντολές **στο terminal σου** — δεν χρειάζεσαι τίποτα άλλο εκτός από Docker Desktop.

---

## Μέρος 1 — Βασικές Εννοιες

```
DockerHub (Registry)
     │
     │  docker pull
     ▼
Image  ←── "το φωτοτυπικό", read-only, αμετάβλητο
     │
     │  docker run
     ▼
Container  ←── "η φωτοτυπία που τρέχει", μπορείς να σταματήσεις/διαγράψεις
```

**Image** = ένα snapshot του περιβάλλοντος (OS + code + dependencies)
**Container** = ένα running instance αυτού του image

---

## Μέρος 2 — Τραβάμε Images από το DockerHub

```bash
# Δες τι images έχεις ήδη locally
docker images

# Τράβηξε το επίσημο nginx image (web server)
docker pull nginx

# Τράβηξε συγκεκριμένη έκδοση (tag)
docker pull python:3.11-slim

# Τράβηξε το latest (default αν δεν βάλεις tag)
docker pull alpine

# Δες τα images ξανά — τώρα βλέπεις τα καινούρια
docker images
```

**Παρατήρηση:** Κάθε image έχει `REPOSITORY`, `TAG`, `IMAGE ID`, `SIZE`.  
Το `python:3.11-slim` είναι πολύ μικρότερο από το `python:3.11` — το `-slim` δεν έχει extra tools.

---

## Μέρος 3 — Σηκώνουμε Containers

### 3.1 Ο πιο απλός τρόπος

```bash
# Τρέχει nginx και βγαίνει αμέσως (foreground mode — κλείνει με Ctrl+C)
docker run nginx

# Ctrl+C για να σταματήσεις
```

### 3.2 Detached mode (background) — αυτό χρησιμοποιούμε πάντα

```bash
# -d = detached (τρέχει στο background)
docker run -d nginx

# Επιστρέφει το Container ID, π.χ.: a3f2b1c9d4e5...
```

### 3.3 Δες τι τρέχει

```bash
# Δες τα running containers
docker ps

# Δες ΟΛΑ τα containers (running + stopped)
docker ps -a
```

Θα δεις:
```
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES
a3f2b1c9d4e5   nginx   ...       2s ago    Up 1s    80/tcp  funny_newton
```

### 3.4 Σταμάτα και διέγραψε

```bash
# Σταμάτα container (με ID ή name)
docker stop a3f2b1c9d4e5
# ή
docker stop funny_newton

# Διέγραψε container (πρέπει να είναι stopped)
docker rm a3f2b1c9d4e5

# Ή σταμάτα + διέγραψε μαζί
docker rm -f funny_newton
```

---

## Μέρος 4 — Ports: Πώς Μπαίνουμε στο Container

Το nginx τρέχει στο port 80 **ΜΕΣΑ** στο container.  
Αλλά αν δεν το "εκθέσουμε", δεν μπορείς να μπεις από τον browser!

```
Laptop (port 8080)  ←──  -p 8080:80  ──►  Container (port 80)
```

```bash
# -p HOST_PORT:CONTAINER_PORT
docker run -d -p 8080:80 nginx

# Άνοιξε τον browser: http://localhost:8080
# Θα δεις "Welcome to nginx!"
```

### Παράδειγμα με διαφορετικά ports

```bash
# 3 nginx containers σε διαφορετικά ports
docker run -d -p 8081:80 --name nginx-1 nginx
docker run -d -p 8082:80 --name nginx-2 nginx
docker run -d -p 8083:80 --name nginx-3 nginx

# Δες ότι τρέχουν όλα
docker ps

# Δοκίμασε και τα 3
curl http://localhost:8081
curl http://localhost:8082
curl http://localhost:8083

# Καθάρισε τα
docker rm -f nginx-1 nginx-2 nginx-3
```

---

## Μέρος 5 — Environment Variables

```bash
# -e KEY=VALUE περνάει env variable στο container
docker run -d \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=mysecret \
  -e POSTGRES_USER=admin \
  -e POSTGRES_DB=mydb \
  --name my-postgres \
  postgres:15

# Δες τα logs
docker logs my-postgres

# Σταμάτα και διέγραψε
docker rm -f my-postgres
```

---

## Μέρος 6 — Πρακτικά Παραδείγματα (Run & Stop)

### Παράδειγμα A: Nginx Web Server

```bash
# 1. Σήκωσε
docker run -d -p 8080:80 --name my-web nginx

# 2. Δοκίμασε
curl http://localhost:8080
# ή άνοιξε browser: http://localhost:8080

# 3. Δες logs (live)
docker logs -f my-web    # Ctrl+C για να βγεις

# 4. Σταμάτα
docker stop my-web

# 5. Δες ότι σταμάτησε (STATUS = Exited)
docker ps -a

# 6. Διέγραψε
docker rm my-web
```

---

### Παράδειγμα B: Python Interactive Shell

```bash
# -it = interactive + tty (δηλ. μπαίνεις μέσα)
# --rm = αυτοδιαγραφή όταν τελειώσεις
docker run -it --rm python:3.11-slim python

# Τώρα είσαι ΜΕΣΑ στο container, σε Python REPL:
>>> print("Hello from Docker!")
>>> import sys; print(sys.version)
>>> exit()
# Το container σβήνει αυτόματα (--rm)
```

---

### Παράδειγμα C: Alpine Linux Shell

```bash
# Alpine = ελάχιστο Linux (5MB!)
docker run -it --rm alpine sh

# Τώρα είσαι σε Linux shell μέσα στο container:
# ls /
# cat /etc/os-release
# apk add curl   ← install package
# exit
```


---

### Παράδειγμα E: Redis (In-Memory Database)

```bash
# Σήκωσε Redis
docker run -d -p 6379:6379 --name my-redis redis:7-alpine

# Μπες μέσα και τρέξε εντολές
docker exec -it my-redis redis-cli

# Μέσα στο redis-cli:
# SET name "Mellon Group"
# GET name
# INCR counter
# GET counter
# EXIT

# Σταμάτα
docker rm -f my-redis
```

---

## Μέρος 7 — Χρήσιμες Εντολές Cheatsheet

```bash
# ─── Images ────────────────────────────────────────
docker pull <image>          # Κατέβασε image
docker images                # Λίστα local images
docker rmi <image>           # Διέγραψε image
docker image prune           # Διέγραψε unused images

# ─── Containers ────────────────────────────────────
docker run -d <image>        # Τρέξε στο background
docker run -it <image> sh    # Τρέξε interactive
docker run --rm <image>      # Auto-delete μετά
docker run -p 8080:80        # Port mapping
docker run -e KEY=VALUE      # Env variable
docker run --name myname     # Δώσε όνομα

docker ps                    # Δες running
docker ps -a                 # Δες όλα
docker stop <id/name>        # Σταμάτα
docker start <id/name>       # Ξεκίνα πάλι
docker rm <id/name>          # Διέγραψε
docker rm -f <id/name>       # Force διέγραψε (ακόμα κι αν τρέχει)

# ─── Debugging ─────────────────────────────────────
docker logs <id/name>        # Δες logs
docker logs -f <id/name>     # Live logs (follow)
docker exec -it <id> sh      # Μπες μέσα (shell)
docker inspect <id/name>     # Πλήρεις πληροφορίες
docker stats                 # CPU/Memory usage live

# ─── Cleanup ───────────────────────────────────────
docker rm -f $(docker ps -aq)   # Διέγραψε ΟΛΑ τα containers
docker system prune             # Καθάρισε τα πάντα
```

---

## Μέρος 8 — Τι Κάνει το Dockerfile μας

```dockerfile
# Τι σημαίνει κάθε γραμμή:

FROM python:3.11-slim
# ↑ Ξεκίνα από αυτό το base image (από DockerHub)
# "slim" = μικρή έκδοση χωρίς extra tools

WORKDIR /app
# ↑ Δημιούργησε και μπες στον φάκελο /app
# Όλες οι επόμενες εντολές τρέχουν ΑΠΟ εδώ

COPY requirements.txt .
# ↑ Αντίγραψε το requirements.txt στο /app/
# (κάνουμε αυτό ΠΡΩΤΑ για caching — αν δεν αλλάξει το requirements.txt,
#  το Docker δεν ξανατρέχει το pip install)

RUN pip install --no-cache-dir -r requirements.txt
# ↑ Εκτέλεσε εντολή κατά το BUILD (όχι κατά το run)
# Αυτό γίνεται μία φορά και αποθηκεύεται στο image

COPY . .
# ↑ Αντίγραψε ΟΛΑ τα αρχεία του φακέλου στο /app/

EXPOSE 5000
# ↑ Documentation — λέει "αυτό το container ακούει στο port 5000"
# ΔΕΝ ανοίγει το port — αυτό γίνεται με -p κατά το docker run

CMD ["python", "app.py"]
# ↑ Η εντολή που τρέχει όταν κάνεις docker run
# Μόνο ΜΙΑ CMD ανά Dockerfile
```

**Build το image locally:**
```bash
cd app/
docker build -t my-app:local .
docker run -d -p 8080:5000 -e ENVIRONMENT=local my-app:local
curl http://localhost:8080/health
docker rm -f $(docker ps -q --filter name=my-app) 2>/dev/null || true
```

---

## Quick Demo Script (αντίγραψε-τρέξε)

```bash
#!/bin/bash
# Τρέξε αυτό για να δεις όλα σε δράση

echo "=== 1. Pulling nginx image ==="
docker pull nginx:alpine

echo ""
echo "=== 2. Starting container ==="
docker run -d -p 8080:80 --name demo-nginx nginx:alpine
echo "Container started!"

echo ""
echo "=== 3. Testing ==="
sleep 1
curl -s http://localhost:8080 | head -5

echo ""
echo "=== 4. Container info ==="
docker ps --filter name=demo-nginx

echo ""
echo "=== 5. Stopping & removing ==="
docker rm -f demo-nginx
echo "Done! Container removed."
```
