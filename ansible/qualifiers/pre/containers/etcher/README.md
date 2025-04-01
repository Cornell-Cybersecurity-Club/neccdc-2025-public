> These are some of my initial working notes (ramblings)

```
curl -X POST http://127.0.0.1:5000/write \
  -H "Content-Type: application/json" \
  -d '{"experiment_id": "abcdefg", "subject_id": "123456789", "value": 42}'
```


curl -X GET "http://127.0.0.1:5000/read?measurement=measurement_name&field_key=field_key&start=-1h"



Placebo Pharma manufactures placebo pills and performs test on patients to validate them.


## Pill Production
Measure: pill_production
Tags:
- machine_id: 1-20
- location: have at least 3
Fields:
- production_rate: 100
- temperature: 22.5
- humidity: 45.0
- machine_status: "running"
- error_code: 0

## Test Result
Measure: clinical_trial
Tags:
- id: SSN
- trial_id: ID
- location:
Fields:
- dosage: grams
- response: positive/negative
- side_effects: symptom
- subject_age:
- subject_weight: kg


curl -X POST http://localhost:5000/production \
     -H "Content-Type: application/json" \
     -d '{
           "machine_id": "your_machine_id",
           "location": "your_location",
           "production_rate": 500,
           "temperature": 75.5,
           "humidity": 45.0,
           "machine_status": "running",
           "error_code": 0
         }'

https://sqliteonline.com/


from(bucket: "ClinicalTrials")
  |> range(start: -30d)
  |> filter(fn: (r) => r._measurement == "patient3")
  |> pivot(rowKey:["id"], columnKey: ["_field"], valueColumn: "_value")

## Build

```bash
docker build . --platform=linux/amd64 \
  --label maintainer=PlaceboPharma \
  --tag etcher
```
