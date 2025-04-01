import os
import time
import logging
import matplotlib.pyplot as plt
from influxdb_client import InfluxDBClient
from flask import Flask, send_file, jsonify, request
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST, Histogram
import io
import threading
import pytz
import urllib3

# Suppress InsecureRequestWarning
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

INFLUXDB_URL = os.environ.get("INFLUX_URL")
TOKEN = os.environ.get("INFLUXDB_TOKEN")
ORG = os.environ.get("INFLUX_ORG")
BUCKET = os.environ.get("INFLUX_BUCKET")
SSL_VERIFY = os.environ.get("SSL_VERIFY")

SSL_VERIFY_BOOL = True
if SSL_VERIFY == "False":
    SSL_VERIFY_BOOL = False


QUERY = f"""
from(bucket: "{BUCKET}")
|> range(start: -30m)
|> filter(fn: (r) => r._measurement == "pill_production")
|> filter(fn: (r) => r._field == "temperature")
"""


logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


app = Flask(__name__)
img = None  # Initialize img as a global variable


@app.route("/ready", methods=["GET"])
def ready_route():
    try:
        return "ready", 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


def fetch_data():
    try:
        client = InfluxDBClient(
            url=INFLUXDB_URL, token=TOKEN, org=ORG, verify_ssl=SSL_VERIFY_BOOL
        )
        query_api = client.query_api()
        tables = query_api.query(QUERY)

        data = {}  # Dictionary to store data per machine_id
        local_tz = pytz.timezone("America/New_York")  # Change to your local timezone
        for table in tables:
            for record in table.records:
                machine_id = record.values.get("machine_id", "unknown")
                if machine_id not in data:
                    data[machine_id] = {"timestamps": [], "values": []}
                utc_time = record.get_time()
                local_time = utc_time.astimezone(local_tz)
                data[machine_id]["timestamps"].append(local_time)
                data[machine_id]["values"].append(record.get_value())

        client.close()
        return data
    except Exception as e:
        logging.warning(f"Failed to fetch data from InfluxDB: {e}")
        return {}


def plot_data(data):
    plt.figure(figsize=(10, 6))

    for machine_id, machine_data in data.items():
        plt.plot(
            machine_data["timestamps"],
            machine_data["values"],
            marker="o",
            linestyle="-",
            label=f"Machine {machine_id}",
        )

    plt.title("Machine Running Temperatures")
    plt.xlabel("Time")
    plt.ylabel("Temperature")
    plt.grid(True)
    plt.legend(loc="lower center", bbox_to_anchor=(0.5, -0.3), ncol=5)
    plt.tight_layout()

    img = io.BytesIO()
    plt.savefig(img, format="png")
    plt.close()
    img.seek(0)
    return img


# Prometheus metrics
REQUEST_COUNT = Counter('request_count', 'Total number of requests', ['method', 'endpoint', 'http_status'])
GRAPH_UPDATE_COUNT = Counter('graph_update_count', 'Total number of graph updates')

@app.before_request
def before_request():
    request.start_time = time.time()
    request.request_size = request.content_length if request.content_length else 0

@app.after_request
def after_request(response):
    REQUEST_COUNT.labels(request.method, request.path, response.status_code).inc()
    return response

@app.route('/metrics', methods=['GET'])
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


@app.route("/")
def index():
    global img
    if img:
        img.seek(0)  # Ensure the file pointer is at the start
        return send_file(io.BytesIO(img.read()), mimetype="image/png")
    else:
        return "No data found", 404


@app.before_request
def activate_job():
    if not hasattr(app, "update_thread"):

        def update_data():
            global img
            while True:
                data = fetch_data()
                GRAPH_UPDATE_COUNT.inc()
                if data:
                    img = plot_data(data)
                    logging.info("Graph Updated")
                else:
                    img = None
                time.sleep(60)  # Wait for 1 minute before updating again

        app.update_thread = threading.Thread(target=update_data)
        app.update_thread.daemon = True
        app.update_thread.start()


def main():
    global data, img
    # Fetch data and plot in the main thread initially
    data = fetch_data()
    if data:
        img = plot_data(data)
    else:
        img = None

    app.run(host="0.0.0.0", port=5000)


if __name__ == "__main__":
    main()
