# Add new alerts

To add a new alert, update the spreadsheet 'AlertsToSimulate.xlsx' and run the script 'update_alerts.py'

In the spreadsheet, make sure to populate the id column with a unique number. For a new aircraft start with the next rounded number so that it leaves a some numbers for the previous aircraft for extension.

While not strictly necessary, it is nice to keep the id column sorted.

The id column can be a formula, but if possible convert it to a value so that we can sort and preserve the order. 

The id is used to keep track of the alerts that have been sent, so changing the id will change the history of the alerts that have been sent.

# Columns explanation

## Alert Definition Format

The alerts is the excel files will be converted to `AlertsToSimulate.json`. Each alert has the following fields that map to the `SimulatedAlert` structure:

| JSON Field      | Type     | Description                                                                                   | Possible Values                                |
|----------------|----------|-----------------------------------------------------------------------------------------------|-----------------------------------------------|
| uid            | Int      | Unique identifier for the alert                                                               | Any integer                                    |
| category       | String   | Severity level of the alert                                                                   | "abnormal", "emergency", "normal"              |
| alertType      | String   | Type of the alert message                                                                     | "cas" (Crew Alert System), "situation"         |
| action         | String   | Required action for this alert                                                                | "simulate", "ignore", "review"                 |
| priority       | String   | Priority level of the alert                                                                   | "high", "medium", "low", "none"                |
| aircraftName   | String   | Aircraft model identifier                                                                     | e.g., "S22TG6", "S22TG7"                      |
| message        | String   | Main alert message text                                                                       | Text describing the alert                      |
| submessage     | String?  | Additional details about the alert (optional)                                                 | Detailed explanation or empty                  |

### Field Details:

- **category**: Determines the severity level and color coding
  - `abnormal`: Yellow alerts requiring attention
  - `emergency`: Red alerts requiring immediate action
  - `normal`: White/advisory alerts

- **alertType**: 
  - `cas`: Crew Alert System messages (typically system warnings)
  - `situation`: Broader situational alerts

- **action**:
  - `simulate`: Alert should be simulated during flight and task may require an action in the plane, for example locate a circuit breaker or a switch.
  - `ignore`: Alert should be skipped
  - `review`: Alert is just information you need to review, not an action required in the plane.

The ignore action lets you define the alerts without simulating it, for example to paste a list from a reference document and keep it for future reference.

- **priority**:
  - `high`: Critical alerts requiring immediate attention, highest probability of being sent
  - `medium`: Important but not critical alerts, medium probability of being sent
  - `low`: Advisory alerts, low probability of being sent
  - `none`: this will not be sent, typically for ignored alerts

The priority will be used to determine the probability of the alert being sent. 

