import json, logging, time, os
from flask import Flask, request, jsonify
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
import urllib3
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

# Suppress InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

app = Flask(__name__)

log_level = os.environ.get("LOG_LEVEL", "DEBUG").upper()
logging.basicConfig(level=getattr(logging, log_level, logging.DEBUG))
logger = logging.getLogger(__name__)

# InfluxDB configuration
influxdb_url = os.environ.get("INFLUX_URL")
token = os.environ.get("INFLUXDB_TOKEN")
org = os.environ.get("INFLUX_ORG")
bucket = os.environ.get("INFLUX_BUCKET")

# Initialize InfluxDB client
client = InfluxDBClient(url=influxdb_url, token=token, verify_ssl=False)
write_api = client.write_api(write_options=SYNCHRONOUS)

# Prometheus metrics
REQUEST_COUNT = Counter('request_count', 'Total number of requests', ['method', 'endpoint', 'http_status'])

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    REQUEST_COUNT.labels(request.method, request.path, response.status_code).inc()
    return response

@app.route('/metrics', methods=['GET'])
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route("/ready", methods=["GET"])
def ready_route():
    try:
        return "ready", 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/production", methods=["GET"])
def production_get():
    try:
        return "", 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Pill Production
@app.route("/production", methods=["POST"])
def pill_production():
    try:
        # Parse JSON payload
        data = request.json

        logger.debug("Received payload: %s", json.dumps(data))

        if not data:
            return jsonify({"success": "false", "error": "Invalid JSON payload"}), 400

        # Convert payload to InfluxDB Point
        point = (
            Point("pill_production")
            .tag(
                "machine_id", data.get("machine_id", "none")
            )  # Globally unique machine identifier
            .tag(
                "location", data.get("location", "none")
            )  # Location where the pills are being produced
            .field(
                "production_rate", data.get("production_rate")
            )  # Integer, between 0 and 1000
            .field(
                "temperature", data.get("temperature")
            )  # Float in Celsius, between 0 and 200
            .field("humidity", data.get("humidity"))  # Float between 0 and 100
            .field(
                "machine_status", data.get("machine_status")
            )  # running, stopped, error, idle
            .field("error_code", data.get("error_code"))  # Integers
            .time(data.get("time", None))
        )

        write_api.write(bucket=bucket, org=org, record=point)

        return jsonify({"success": "true", "error": ""}), 200

    except Exception as e:
        return jsonify({"success": "false", "error": str(e)}), 500


if __name__ == "__main__":
    port = os.environ.get("port", 5000)
    app.run(debug=True, host="0.0.0.0", port=port)
