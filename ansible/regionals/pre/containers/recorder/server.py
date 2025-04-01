import json, logging, time, os
from flask import Flask, request, jsonify
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import urllib3
from job import create_k8s_job

# Suppress InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

app = Flask(__name__)

log_level = os.environ.get("LOG_LEVEL", "DEBUG").upper()
logging.basicConfig(level=getattr(logging, log_level, logging.DEBUG))
logger = logging.getLogger(__name__)

# InfluxDB configuration
url = os.environ.get("INFLUX_URL")
token = os.environ.get("INFLUXDB_TOKEN")
org = os.environ.get("INFLUX_ORG")
bucket = os.environ.get("INFLUX_BUCKET")

client = InfluxDBClient(url=url, token=token, org=org, verify_ssl=False)
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


@app.route("/trial", methods=["GET"])
def trial_get():
    try:
        return "", 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/trial", methods=["POST"])
def clinical_trial():
    try:
        data = request.json

        logger.debug("Received payload: %s", json.dumps(data))

        if not data:
            return jsonify({"success": "false", "error": "Invalid JSON payload"}), 400

        # Convert payload to InfluxDB Point
        point = (
            Point("clinical_trial")
            .tag("id", data.get("id", "none"))  # Globally unique patient identifier
            .tag("trial_id", data.get("trial_id", "none"))  # The ID of the trial
            .tag("location", data.get("location", "none"))  # Location of the trial
            .field("dosage", data.get("dosage"))  # Integer, between 0 and 100
            .field("response", data.get("response"))  # String, positive or negative
            .field("side_effects", data.get("side_effects"))  # String
            .field("subject_age", data.get("subject_age"))  # Integer, between 0 and 100
            .field("subject_weight", data.get("subject_weight"))  # Integers, KG of patient
            .time(data.get("time", None))
        )

        try:
            write_api.write(bucket=bucket, org=org, record=point)
            logger.info("Successfully wrote data to InfluxDB")

            create_k8s_job(
                timestamp = str(time.time()),
                trial_id = data.get("trial_id", "none"),
                location = data.get("location", "none")
            )

        except Exception as write_error:
            logger.error(f"Failed to write to InfluxDB: {str(write_error)}")


        return jsonify({"success": "true", "error": ""}), 200

    except Exception as e:
        return jsonify({"success": "false", "error": str(e)}), 500


if __name__ == "__main__":
    port = os.environ.get("PORT", 5000)
    app.run(debug=True, host="0.0.0.0", port=port)
