import sqlite3

DB_FILE = "data.sql"


INSERT_SQL = """
    INSERT INTO machine_data (
        id, machine_event, machine_id, location,
        production_rate, temperature, humidity,
        machine_status, error_code, sleep
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"""


def init_db(db_path: str) -> None:
    """Initialize SQLite database and create table if not exists."""
    with sqlite3.connect(db_path) as conn:
        conn.execute(
            """CREATE TABLE IF NOT EXISTS machine_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                machine_event INTEGER,
                machine_id TEXT,
                location TEXT,
                production_rate INTEGER,
                temperature REAL,
                humidity REAL,
                machine_status TEXT,
                error_code INTEGER,
                skip INTEGER DEFAULT 0,
                sleep INTEGER DEFAULT 7
            )
        """
        )
        conn.execute(
            """CREATE TABLE IF NOT EXISTS clinical_trial (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                subject_id TEXT,
                trial_id INTEGER,
                location TEXT,
                dosage REAL,
                response TEXT,
                side_effects TEXT,
                subject_age INTEGER,
                subject_weight REAL
            )
        """
        )


# Always works fine and just has slightly changing values
def machine_1(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            production_rate = 100
            temperature = 70.0 + (minute % 7)
            humidity = 45.0 + ((minute % 7) * 0.5)

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "Bristol",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    "running",
                    0,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Works fine 2.5 hour until jam and is fixed after 30 minutes
def machine_2(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            match minute:
                case minute if 130 < minute <= 150:
                    production_rate = 60 + (minute % 7) - 3
                    temperature = 80.0 + ((minute - 130) * 1.7)
                    humidity = 10.0 + (minute % 4)
                    machine_status = "running"
                    error_code = 0
                case minute if 150 < minute <= 170:
                    production_rate = 0
                    temperature = 80.0 + (minute * 0.3)
                    humidity = 10.0 + (minute % 4)
                    machine_status = "error"
                    error_code = 107
                case minute if 170 < minute < 180:
                    production_rate = 0
                    temperature = 124.0 - ((minute - 170) * 4.4)
                    humidity = 10.0 - (minute % 4)
                    machine_status = "idle"
                    error_code = 107
                case _:
                    production_rate = 60 + (minute % 7) - 3
                    temperature = 80.0 + (minute % 9)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "running"
                    error_code = 0

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "Bristol",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    machine_status,
                    error_code,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Just works, high production rate
def machine_3(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            production_rate = 120 + (minute % 20) - 10
            temperature = 70.0 + (minute % 3)
            humidity = 30.0 + ((minute % 4) * 0.5)

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "Bristol",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    "running",
                    0,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Works at the start then starts to overheat until it stops
## Works for 1.5 hour slowly increasing temp
## Goes into overheat warning
## Stops working after that
def machine_4(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            match minute:
                case minute if 0 <= minute <= 90:
                    production_rate = 80 - (minute // 2)
                    temperature = 70.0 + (minute * 0.5)
                    humidity = 45.0 + ((minute % 4) * 0.5)
                    machine_status = "running"
                    error_code = 0
                case minute if 90 < minute < 215:
                    production_rate = max(125 - minute, 0)
                    temperature = 25.0 + float(minute)
                    humidity = 45.0 + ((minute % 4) * 0.5)
                    machine_status = "warn"
                    error_code = 100
                case 215:
                    production_rate = 0
                    temperature = 70.0 + float(minute)
                    humidity = 0
                    machine_status = "error"
                    error_code = 105
                case _:
                    production_rate = 0
                    temperature = 0
                    humidity = 0
                    machine_status = "error"
                    error_code = 109

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "Bristol",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    machine_status,
                    error_code,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Constant sensor malfunction
def machine_5(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            temperature = 30.0 + (minute % 3)
            humidity = 30.0 + ((minute % 4) * 0.5)

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "New York",
                    0,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    "error",
                    104,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Works fine for 1.5 hour then low temperature, stops production to heat up and then start again, loop this a few times
def machine_6(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            match minute:
                case minute if 90 < minute <= 110:
                    production_rate = 50 + (minute % 10) - 3
                    temperature = 80.0 - (minute - 90)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "running"
                    error_code = 0
                case minute if 110 < minute <= 120:
                    production_rate = 50 + (minute % 10) - 3
                    temperature = 60.0 + ((minute - 110) * 2)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "idle"
                    error_code = 0

                case minute if 160 < minute <= 180:
                    production_rate = 50 + (minute % 10) - 3
                    temperature = 80.0 - (minute - 160)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "running"
                    error_code = 0
                case minute if 180 < minute <= 190:
                    production_rate = 50 + (minute % 10) - 3
                    temperature = 60.0 + ((minute - 180) * 2)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "idle"
                    error_code = 0

                case minute if 230 < minute <= 250:
                    production_rate = 50 + (minute % 10) - 3
                    temperature = 80.0 - (minute - 230)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "running"
                    error_code = 0
                case minute if 250 < minute <= 260:
                    production_rate = 50 + (minute % 10) - 3
                    temperature = 60.0 + ((minute - 250) * 2)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "idle"
                    error_code = 0
                case _:
                    production_rate = 50 + (minute % 10) - 2
                    temperature = 80.0 + (minute % 9)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "running"
                    error_code = 0

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "New York",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    machine_status,
                    error_code,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Machine data stops after 3 hours
def machine_7(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            match minute:
                case minute if minute > 210:
                    skip = 1
                    production_rate = 0
                    temperature = 0
                    humidity = 0
                    machine_status = "idle"
                    error_code = 0
                case _:
                    skip = 0
                    production_rate = 90 + (minute % 5) - 2
                    temperature = 80.0 + (minute % 20)
                    humidity = 10.0 + ((minute % 4) * 0.5)
                    machine_status = "running"
                    error_code = 0

            cursor.execute(
                """INSERT INTO machine_data (
                        id, machine_event, machine_id, location,
                        production_rate, temperature, humidity,
                        machine_status, error_code, skip, sleep
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    index,
                    minute,
                    machine_id,
                    "New York",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    machine_status,
                    error_code,
                    skip,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Always works fine and just has slightly changing temp & humidity
def machine_8(db_path: str, index: int, minute: int, machine_id: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            production_rate = 30
            temperature = 30.0 + (minute % 3)
            humidity = 20.0 + ((minute % 4) * 0.5)

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "Lowell",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    "running",
                    0,
                    7,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


# Always works fine and just has slightly changing temp & humidity
def machine_9(
    db_path: str, index: int, minute: int, machine_id: int, sleep: int
) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            production_rate = 60
            temperature = 25.0 + (minute % 12)
            humidity = 18.0 + ((minute % 4) * 0.5)

            cursor.execute(
                INSERT_SQL,
                (
                    index,
                    minute,
                    machine_id,
                    "Lowell",
                    production_rate,
                    "%.1f" % temperature,
                    "%.1f" % humidity,
                    "running",
                    0,
                    sleep,
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


def custom_machine_data(db_path: str, index: int, sleep: int) -> int:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            locations = [
                "Boston",
                "Rochester",
                "Syracuse",
                "Burlington",
                "Orono",
                "Amherst",
                "New Haven",
                "Alfred",
                "Queens",
                "Albany",
                "Buffalo",
                "Kingston",
                "West Point"
            ]

            for location in locations:
                cursor.execute(
                    INSERT_SQL,
                    (
                        index,
                        999,
                        26,
                        location,
                        26,
                        26.0,
                        26.0,
                        "running",
                        109,
                        sleep,
                    ),
                )
                index += 1
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")
    return index


def phi(db_path: str, minute: int) -> None:
    try:
        with sqlite3.connect(db_path) as conn:
            cursor = conn.cursor()

            if (minute % 10) != 0:
                return

            subject_ssn = {
                0: {
                    "ssn": "111-40-4132",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 46,
                    "subject_weight": 82,
                },
                1: {
                    "ssn": "111-54-5234",
                    "dosage": 0,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 51,
                    "subject_weight": 72,
                },
                2: {
                    "ssn": "111-60-6345",
                    "dosage": 30,
                    "response": "negative",
                    "side_effects": "headache",
                    "subject_age": 18,
                    "subject_weight": 55,
                },
                3: {
                    "ssn": "111-71-7456",
                    "dosage": 10,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 65,
                    "subject_weight": 150,
                },
                4: {
                    "ssn": "111-80-8567",
                    "dosage": 10,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 30,
                    "subject_weight": 73,
                },
                5: {
                    "ssn": "111-20-9678",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 22,
                    "subject_weight": 64,
                },
                6: {
                    "ssn": "111-10-0789",
                    "dosage": 0,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 30,
                    "subject_weight": 74,
                },
                7: {
                    "ssn": "111-03-1890",
                    "dosage": 10,
                    "response": "negative",
                    "side_effects": "headache",
                    "subject_age": 32,
                    "subject_weight": 60,
                },
                8: {
                    "ssn": "111-10-2901",
                    "dosage": 40,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 28,
                    "subject_weight": 70,
                },
                9: {
                    "ssn": "111-00-3012",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 43,
                    "subject_weight": 90,
                },
                10: {
                    "ssn": "111-11-4123",
                    "dosage": 15,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 35,
                    "subject_weight": 68,
                },
                11: {
                    "ssn": "111-22-5234",
                    "dosage": 25,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 29,
                    "subject_weight": 75,
                },
                12: {
                    "ssn": "111-33-6345",
                    "dosage": 10,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 40,
                    "subject_weight": 80,
                },
                13: {
                    "ssn": "111-44-7456",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 50,
                    "subject_weight": 85,
                },
                14: {
                    "ssn": "111-55-8567",
                    "dosage": 30,
                    "response": "negative",
                    "side_effects": "headache",
                    "subject_age": 60,
                    "subject_weight": 90,
                },
                15: {
                    "ssn": "111-66-9678",
                    "dosage": 5,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 25,
                    "subject_weight": 65,
                },
                16: {
                    "ssn": "111-77-0789",
                    "dosage": 35,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 55,
                    "subject_weight": 95,
                },
                17: {
                    "ssn": "111-88-1890",
                    "dosage": 40,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 45,
                    "subject_weight": 85,
                },
                18: {
                    "ssn": "111-99-2901",
                    "dosage": 10,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 35,
                    "subject_weight": 70,
                },
                19: {
                    "ssn": "111-00-3012",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 43,
                    "subject_weight": 90,
                },
                20: {
                    "ssn": "111-34-3012",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 43,
                    "subject_weight": 90,
                },
                21: {
                    "ssn": "111-45-4123",
                    "dosage": 25,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 36,
                    "subject_weight": 69,
                },
                22: {
                    "ssn": "111-56-5234",
                    "dosage": 30,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 30,
                    "subject_weight": 76,
                },
                23: {
                    "ssn": "111-67-6345",
                    "dosage": 15,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 41,
                    "subject_weight": 81,
                },
                24: {
                    "ssn": "111-78-7456",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 51,
                    "subject_weight": 86,
                },
                25: {
                    "ssn": "111-89-8567",
                    "dosage": 35,
                    "response": "negative",
                    "side_effects": "headache",
                    "subject_age": 61,
                    "subject_weight": 91,
                },
                26: {
                    "ssn": "111-90-9678",
                    "dosage": 10,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 26,
                    "subject_weight": 66,
                },
                27: {
                    "ssn": "111-01-0789",
                    "dosage": 40,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 56,
                    "subject_weight": 96,
                },
                28: {
                    "ssn": "111-12-1890",
                    "dosage": 45,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 46,
                    "subject_weight": 86,
                },
                29: {
                    "ssn": "111-23-2901",
                    "dosage": 15,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 36,
                    "subject_weight": 71,
                },
                30: {
                    "ssn": "111-34-3012",
                    "dosage": 25,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 44,
                    "subject_weight": 91,
                },
                31: {
                    "ssn": "111-45-4123",
                    "dosage": 20,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 37,
                    "subject_weight": 70,
                },
                32: {
                    "ssn": "111-56-5234",
                    "dosage": 30,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 31,
                    "subject_weight": 77,
                },
                33: {
                    "ssn": "111-67-6345",
                    "dosage": 15,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 42,
                    "subject_weight": 82,
                },
                34: {
                    "ssn": "111-78-7456",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 52,
                    "subject_weight": 87,
                },
                35: {
                    "ssn": "111-89-8567",
                    "dosage": 35,
                    "response": "negative",
                    "side_effects": "headache",
                    "subject_age": 62,
                    "subject_weight": 92,
                },
                36: {
                    "ssn": "111-90-9678",
                    "dosage": 10,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 27,
                    "subject_weight": 67,
                },
                37: {
                    "ssn": "111-01-0789",
                    "dosage": 40,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 57,
                    "subject_weight": 97,
                },
                38: {
                    "ssn": "111-12-1890",
                    "dosage": 45,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 47,
                    "subject_weight": 87,
                },
                39: {
                    "ssn": "111-23-2901",
                    "dosage": 15,
                    "response": "negative",
                    "side_effects": "death",
                    "subject_age": 37,
                    "subject_weight": 72,
                },
                40: {
                    "ssn": "111-34-3012",
                    "dosage": 25,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 45,
                    "subject_weight": 92,
                },
                41: {
                    "ssn": "111-45-4123",
                    "dosage": 20,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 38,
                    "subject_weight": 71,
                },
                42: {
                    "ssn": "111-56-5234",
                    "dosage": 30,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 32,
                    "subject_weight": 78,
                },
                43: {
                    "ssn": "111-67-6345",
                    "dosage": 15,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 43,
                    "subject_weight": 83,
                },
                44: {
                    "ssn": "111-78-7456",
                    "dosage": 20,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 53,
                    "subject_weight": 88,
                },
                45: {
                    "ssn": "111-89-8567",
                    "dosage": 35,
                    "response": "negative",
                    "side_effects": "headache",
                    "subject_age": 63,
                    "subject_weight": 93,
                },
                46: {
                    "ssn": "111-90-9678",
                    "dosage": 10,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 28,
                    "subject_weight": 68,
                },
                47: {
                    "ssn": "111-01-0789",
                    "dosage": 40,
                    "response": "negative",
                    "side_effects": "dizziness",
                    "subject_age": 58,
                    "subject_weight": 98,
                },
                48: {
                    "ssn": "111-12-1890",
                    "dosage": 45,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 48,
                    "subject_weight": 88,
                },
                49: {
                    "ssn": "111-23-2901",
                    "dosage": 15,
                    "response": "negative",
                    "side_effects": "nausea",
                    "subject_age": 38,
                    "subject_weight": 73,
                },
                50: {
                    "ssn": "111-34-3012",
                    "dosage": 25,
                    "response": "positive",
                    "side_effects": "none",
                    "subject_age": 46,
                    "subject_weight": 93,
                },
            }

            trials = {
                0: {"name": "Alpha", "location": "Bristol"},
                1: {"name": "Beta", "location": "New York"},
                2: {"name": "Gamma", "location": "Bristol"},
                3: {"name": "Delta", "location": "Lowell"},
                4: {"name": "Epsilon", "location": "New York"},
            }

            subject_id = int((minute % 100) / 10)

            cursor.execute(
                """INSERT INTO clinical_trial (
                        id, subject_id, trial_id, location,
                        dosage, response, side_effects,
                        subject_age, subject_weight
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    (minute / 10),
                    subject_ssn[subject_id]["ssn"],
                    trials[((minute % 50) / 10)]["name"],
                    trials[((minute % 50) / 10)]["location"],
                    subject_ssn[subject_id]["dosage"],
                    subject_ssn[subject_id]["response"],
                    subject_ssn[subject_id]["side_effects"],
                    subject_ssn[subject_id]["subject_age"],
                    subject_ssn[subject_id]["subject_weight"],
                ),
            )
        conn.commit()
    except Exception as e:
        print(f"Error processing data: {e}")


if __name__ == "__main__":
    DB_PATH = DB_FILE
    init_db(DB_PATH)
    index = 1
    for minute in range(0, 290):
        print("Percent Complete: %.1f" % ((minute / 290) * 100), end="\r")

        phi(DB_PATH, minute)

        machine_1(DB_PATH, index, minute, 1)
        index += 1
        machine_2(DB_PATH, index, minute, 2)
        index += 1
        machine_3(DB_PATH, index, minute, 3)
        index += 1
        machine_4(DB_PATH, index, minute, 4)
        index += 1
        machine_5(DB_PATH, index, minute, 5)
        index += 1
        machine_6(DB_PATH, index, minute, 6)
        index += 1
        machine_7(DB_PATH, index, minute, 7)
        index += 1
        machine_8(DB_PATH, index, minute, 8)
        index += 1
        machine_9(DB_PATH, index, minute, 9, 4)
        index += 1

    print(custom_machine_data(DB_PATH, index, 20))
