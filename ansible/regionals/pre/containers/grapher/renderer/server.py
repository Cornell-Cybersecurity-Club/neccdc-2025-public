import os
import time
import logging
import matplotlib.pyplot as plt
from influxdb_client import InfluxDBClient
import io
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

OUTPUT_DIR = os.environ.get("OUTPUT_DIR", "/tmp/graphs")
os.makedirs(OUTPUT_DIR, exist_ok=True)

QUERY = f"""
from(bucket: "{BUCKET}")
|> range(start: -30m)
|> filter(fn: (r) => r._measurement == "pill_production")
|> filter(fn: (r) => r._field == "temperature")
"""


logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def fetch_data():
    try:
        client = InfluxDBClient(
            url=INFLUXDB_URL,
            token=TOKEN,
            org=ORG,
            verify_ssl=SSL_VERIFY_BOOL,
            timeout=30_000,  # Timeout in milliseconds (30 seconds)
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

        # Check if any data points were found
        total_points = sum(len(machine_data["values"]) for machine_data in data.values())
        if total_points == 0:
            logging.warning("No data points found in the response from InfluxDB")
            return {}

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

    filename = os.path.join(OUTPUT_DIR, "image.png")
    plt.savefig(filename, format="png")
    plt.close()
    return filename


def main():
    failed_attempts = 0
    image_path = os.path.join(OUTPUT_DIR, "image.png")

    while True:
        try:
            data = fetch_data()
            if data == {}:
                raise Exception("No data fetched from InfluxDB")
            plot_data(data)
            logging.info("Graph rendered")
            failed_attempts = 0
        except Exception as _:
            failed_attempts += 1
            logging.info(
                f"Error fetching data from InfluxDB (attempt {failed_attempts})"
            )

            # Delete the image only on the second consecutive failed attempt
            if failed_attempts >= 3 and os.path.exists(image_path):
                try:
                    os.remove(image_path)
                    logging.info(f"Deleted outdated graph at {image_path}")
                except Exception as e:
                    logging.debug(f"Failed to delete image: {e}")

        time.sleep(60)  # Wait for 1 minute before updating again


if __name__ == "__main__":
    main()
