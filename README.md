# Alert Simulator

An iOS application designed to simulate random in-cockpit alerts for flight training purposes. This tool helps pilots familiarize themselves with handling various alert scenarios in a controlled environment.

## Features

- Simulates realistic cockpit alerts and warnings
- Customizable timer-based alert generation

## Project Structure

```
alertsimulator/
├── Source/
│   ├── App/           # Application configuration and settings
│   ├── Model/         # Core business logic and data models
│   └── UserInterface/ # UI components and ViewModels
│       ├── ViewModels/
│       └── Views/
├── data/              # Static data and resources
├── alertsimulatorTests/
└── alertsimulatorUITests/
```

## Key Components

### Models
- `SimulatedAlert`: Defines the structure and behavior of simulated cockpit alerts
- `Flight`: Handles flight-related operations and state management
- `NotificationManager`: Manages the delivery and lifecycle of alert notifications

### Views
- `ContentView`: Main application view coordinator
- `FlightControlView`: Interface for flight control operations
- `TimerPickerView`: Controls for alert timing configuration
- `NotificationsView`: Displays active and historical alerts

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/alertsimulator.git
```

2. Open the project in Xcode:
```bash
cd alertsimulator
open alertsimulator.xcodeproj
```

3. Build and run the application using Xcode's simulator or a physical device.

## Usage

1. Launch the application
2. Configure alert timing preferences
3. Start the simulation
4. Respond to alerts as they appear
5. Review performance and alert history

## Testing

The project includes both unit tests (`alertsimulatorTests`) and UI tests (`alertsimulatorUITests`) to ensure reliability and functionality.

To run the tests:
1. Open the project in Xcode
2. Select Product > Test (⌘U)


