#!/bin/bash
# ============================================================
#  Quick Docker Demo — τρέξε αυτό live στην τάξη
#  chmod +x demos/quick-docker-demo.sh && ./demos/quick-docker-demo.sh
# ============================================================

set -e  # σταμάτα αν οποιαδήποτε εντολή αποτύχει

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     DOCKER LIVE DEMO — Mellon Group      ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── 1. Pull ──────────────────────────────────────────────
echo "▶ STEP 1: Pulling nginx:alpine from DockerHub..."
docker pull nginx:alpine --quiet
echo "✓ Image downloaded!"
echo ""

# ─── 2. Images ────────────────────────────────────────────
echo "▶ STEP 2: Images στο σύστημά μας:"
docker images --filter reference="nginx*"
echo ""

# ─── 3. Run ───────────────────────────────────────────────
echo "▶ STEP 3: Σηκώνω container στο port 8080..."
docker run -d \
  -p 8080:80 \
  -e DEMO_VAR="Hello from env!" \
  --name demo-nginx \
  nginx:alpine
echo "✓ Container running!"
echo ""

# ─── 4. docker ps ─────────────────────────────────────────
echo "▶ STEP 4: Τι τρέχει;"
docker ps --filter name=demo-nginx
echo ""

# ─── 5. Test ──────────────────────────────────────────────
echo "▶ STEP 5: Test με curl..."
sleep 1
echo "Response από http://localhost:8080:"
curl -s http://localhost:8080 | head -3
echo ""

# ─── 6. Logs ──────────────────────────────────────────────
echo "▶ STEP 6: Container logs:"
docker logs demo-nginx
echo ""

# ─── 7. Exec ──────────────────────────────────────────────
echo "▶ STEP 7: Τρέχω εντολή ΜΕΣΑ στο container:"
docker exec demo-nginx ls /usr/share/nginx/html/
echo ""
docker exec demo-nginx sh -c 'echo "I am inside the container!"'
echo ""

# ─── 8. Stop ──────────────────────────────────────────────
echo "▶ STEP 8: Σταματάω τον container..."
docker stop demo-nginx
echo "✓ Stopped."
echo ""

echo "▶ STEP 9: Τι βλέπω τώρα (stopped containers):"
docker ps -a --filter name=demo-nginx
echo ""

# ─── 9. Remove ────────────────────────────────────────────
echo "▶ STEP 10: Διαγράφω τον container..."
docker rm demo-nginx
echo "✓ Removed."
echo ""

echo "╔══════════════════════════════════════════╗"
echo "║              DEMO COMPLETE!              ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Εντολές που είδαμε:"
echo "  docker pull <image>          → κατέβασμα image"
echo "  docker images                → λίστα images"
echo "  docker run -d -p 8080:80     → εκκίνηση (background + port)"
echo "  docker ps                    → running containers"
echo "  docker logs <name>           → logs"
echo "  docker exec -it <name> sh    → μπαίνεις μέσα"
echo "  docker stop <name>           → σταμάτημα"
echo "  docker rm <name>             → διαγραφή"
