from flask import Flask, jsonify
import os

app = Flask(__name__)

ENVIRONMENT = os.environ.get("ENVIRONMENT", "local")
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
TEAM_NAME   = os.environ.get("TEAM_NAME", "unknown")


@app.route("/")
def index():
    return jsonify({
        "message": f"Hello from {ENVIRONMENT}!",
        "version": APP_VERSION,
        "team":    TEAM_NAME,
        "status":  "running",
    })


@app.route("/health")
def health():
    return jsonify({"status": "healthy", "environment": ENVIRONMENT})


@app.route("/info")
def info():
    return jsonify({
        "environment": ENVIRONMENT,
        "version":     APP_VERSION,
        "team":        TEAM_NAME,
        "python":      os.popen("python --version").read().strip(),
    })


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=(ENVIRONMENT == "local"))
