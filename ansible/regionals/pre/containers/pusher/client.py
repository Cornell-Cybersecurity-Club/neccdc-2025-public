import logging, os, time, requests, sqlite3
import threading
import urllib3

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

log_level = os.environ.get("LOG_LEVEL", "DEBUG").upper()
logging.basicConfig(level=getattr(logging, log_level, logging.DEBUG))
logger = logging.getLogger(__name__)

CHECKPOINT_FILE = "checkpoint.txt"

"""
Machine IDs:
  1: "Fette"
    # Bristol
    # Always works fine and just has slightly changing values
  2: "Korsch"
    # Bristol
    # Works fine 2 hour until jam and is fixed after 30 minutes
  3: "Stokes"
    # Bristol
    # Just works, high production rate
  4: "Natoli"
    # Bristol
    # Works at the start then starts to overheat until it stops
        # Works for 1 hour slowly increasing temp
        # Stops working after that
  5: "Natoli"
    # New York
    # Always in Error
  6: "Natoli"
    # New York
    # Works fine for 1 hour then low temperature, stops production to heat up and then start again, loop this a few times
  7: "Korsch"
    # New York
    # Machine data stops after 3 hours
  8: "Korsch"
    # Lowell
    # Always works fine and just has slightly changing temp & humidity
  9: "Korsch"
    # Lowell
    # Always works fine and just has slightly changing temp & humidity
  26: "Stokes"
    # Starts in the last 10 minutes

Locations:
  "Bristol"
  "Lowell"
  "New York"

Error Codes:
  0: "None"
  100: "Machine Overheating"
  101: "Low Production Rate"
  102: "High Humidity"
  103: "Low Temperature"
  104: "Sensor Malfunction"
  105: "Power Failure"
  106: "Network Disconnected"
  107: "Mechanical Jam"
  108: "Calibration Error"
  109: "Unknown Error"
"""


def send_production_data(
    endpoint: str,
    machine_id: str,
    location: str,
    production_rate: int,
    temperature: float,
    humidity: float,
    machine_status: str,
    error_code: int,
):

    data = {
        "machine_id": machine_id,
        "location": location,
        "production_rate": production_rate,
        "temperature": temperature,
        "humidity": humidity,
        "machine_status": machine_status,
        "error_code": error_code,
    }

    try:
        response = requests.post(f"{endpoint}/production", json=data, verify=False)  # Added verify=False
        response.raise_for_status()
        logger.debug(f"Production data sent successfully: {response.status_code}")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Error sending production data: {e}")
        return None


def get_production_records(start_id: int = 1):
    db_path = os.environ.get("DB_PATH", "data.sql")
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute(
            """
            SELECT id, machine_id, location, production_rate,
                   temperature, humidity, machine_status,
                   error_code, skip, sleep
              FROM machine_data
              WHERE id >= ?
              ORDER BY id
          """,
            (str(start_id),),
        )
        records = cursor.fetchall()
        conn.close()
        return records
    except sqlite3.Error as e:
        logger.error(f"Database error: {e}")
        return []


def send_phi_data(
    endpoint: str,
    subject_id: str,
    trial_id: str,
    location: str,
    dosage: int,
    response: str,
    side_effects: str,
    subject_age: int,
    subject_weight: int,
):

    data = {
        "id": subject_id,
        "trial_id": trial_id,
        "location": location,
        "dosage": dosage,
        "response": response,
        "side_effects": side_effects,
        "subject_age": subject_age,
        "subject_weight": subject_weight,
    }

    try:
        response = requests.post(f"{endpoint}/trial", json=data, verify=False)  # Added verify=False
        response.raise_for_status()
        logger.info(f"PHI data sent successfully: {response.status_code}")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Error sending production data: {e}")
        return None


def get_phi_records():
    db_path = os.environ.get("DB_PATH", "data.sql")
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute(
            """
            SELECT subject_id, trial_id, location, dosage, 
                   response, side_effects, subject_age, subject_weight
            FROM clinical_trial
            ORDER BY id
        """
        )
        records = cursor.fetchall()
        conn.close()
        return records
    except sqlite3.Error as e:
        logger.error(f"Database error: {e}")
        return []


def save_checkpoint(index):
    with open(CHECKPOINT_FILE, "w") as f:
        f.write(str(index))


def load_checkpoint():
    if os.path.exists(CHECKPOINT_FILE):
        with open(CHECKPOINT_FILE, "r") as f:
            try:
                return int(f.read())
            except ValueError:
                print("Checkpoint file is probably empty")
    return 0


def data_loop(endpoint: str):
    starting_index = load_checkpoint()
    records = get_production_records(starting_index)
    phi_records = get_phi_records()
    phi_index = 0
    phi_loop = 0
    for record in records:
        logger.info(record)
        # Skip records with skip flag
        if record[8] != 1:
            send_production_data(
                endpoint=endpoint,
                machine_id=record[1],
                location=record[2],
                production_rate=record[3],
                temperature=record[4],
                humidity=record[5],
                machine_status=record[6],
                error_code=record[7],
            )

        save_checkpoint(record[0])
        time.sleep(record[9])
        phi_loop += record[9]

        # Trigger on 10 minute increments
        if phi_loop % 600 == 0:
            phi_loop = 0

            phi_record = phi_records[phi_index]
            phi_index += 1

            send_phi_data(
                endpoint=endpoint,
                subject_id=phi_record[0],
                trial_id=phi_record[1],
                location=phi_record[2],
                dosage=phi_record[3],
                response=phi_record[4],
                side_effects=phi_record[5],
                subject_age=phi_record[6],
                subject_weight=phi_record[7],
            )


if __name__ == "__main__":
    urls = os.environ.get("SERVER_URL", "http://localhost:5000").split(",")

    threads = []
    for url in urls:
        thread = threading.Thread(target=data_loop, args=(url,))
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()
