# AhwaOrder - Cafe Order Management
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/Abowaly26/AhwaOrder-)

AhwaOrder is a cross-platform application built with Flutter for managing drink orders in a cafe setting. It provides a clean interface for creating, tracking, and viewing orders, complete with a dashboard for quick operational insights.

## Features

- **Order Management**: Create, view, update status (Pending, In Progress, Completed, Cancelled), and delete orders.
- **Dashboard Overview**: At-a-glance summary of today's orders, today's revenue, and total historical orders.
- **Detailed Order View**: Each order card displays customer name, status, summary of items, total price, and creation time.
- **Order Types**: Supports both dine-in (with table numbers) and take-away orders.
- **Drink Modeling**: Utilizes an abstract `Drink` class with concrete implementations for `Coffee`, `Tea`, and `Juice`, showcasing a flexible and extensible data model.
- **State Management**: Uses the `provider` package for efficient and scalable state management.
- **Layered Architecture**: The app is structured with a clear separation of concerns, dividing code into UI (features), state management (providers), business logic (services), and data handling (repositories).
- **Data Persistence**: Includes an `InMemoryOrderRepository` for session-based data and a `LocalStorageOrderRepository` for persisting data on the device.

## Architecture

The project follows a clean architecture pattern to ensure maintainability and scalability. The core logic is organized into distinct layers:

-   **Language**: Dart
-   **Framework**: Flutter
-   **State Management**: `provider`

### Core Components

-   `lib/features`: Contains the UI Layer, including all screens, widgets, and view-specific logic.
-   `lib/core/providers`: The State Management Layer, connecting the UI to the business logic.
-   `lib/core/services`: The Business Logic Layer, orchestrating data and operations.
-   `lib/core/repositories`: The Data Access Layer, abstracting the data source (e.g., in-memory, local storage).
-   `lib/core/models`: The Domain Layer, defining the core data structures like `Order` and `Drink`.

## Project Structure

The `lib` directory is organized as follows:

```
lib/
├── core/                  # Core application logic
│   ├── models/            # Data models (Drink, Order)
│   ├── providers/         # State management (Provider pattern)
│   ├── repositories/      # Data abstraction (in-memory, local storage)
│   └── services/          # Business logic
├── features/              # UI-related features and screens
│   ├── home/              # Main navigation and layout
│   └── order/             # Order-related screens
└── main.dart              # Application entry point
```

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/Abowaly26/AhwaOrder-.git
    ```
2.  **Navigate to the project directory:**
    ```sh
    cd AhwaOrder-
    ```
3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

### Running the Application

1.  Ensure you have a device connected or an emulator running.
2.  Run the app using the Flutter CLI:
    ```sh
    flutter run
