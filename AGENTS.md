# Gemini Code Assistant Context

## Project Overview

This project is a Flutter-based mobile application called "Infinite Scrolling Meal Planner". It's a demo app designed to showcase a highly interactive and intuitive calendar interface for planning weekly meals. The application is intended to be cross-platform, targeting both **Web** and **iOS**.

The core features of the application include:

- An infinitely scrolling weekly calendar.
- Horizontally scrolling carousels of "meal cards" for each day.
- Drag-and-drop functionality to move meal cards between days and reorder them within a day.
- A state management system with "Save" and "Reset" functionality to manage a working state and a persistent state of the meal plan.
- A modal bottom sheet for adding new meals from a predefined list of templates.

The project uses the Riverpod package for state management and follows a feature-based architecture, with a clear separation of concerns between UI, controllers, data, and models.

## Building and Running

### Prerequisites

- Flutter SDK (3.35+)

### Project Setup

1.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Analyze the code:**
    ```bash
    flutter analyze
    ```

### Running the Application

-   **Mobile (iOS/Android):**
    ```bash
    flutter run
    ```

-   **Web (Chrome):**
    ```bash
    flutter config --enable-web # One-time setup
    flutter run -d chrome
    ```

### Running Tests

-   **Run all tests:**
    ```bash
    flutter test
    ```

-   **Run web tests:**
    ```bash
    flutter test --platform=chrome
    ```

## Development Conventions

-   **State Management:** The project uses `flutter_riverpod` for state management. The main application logic is centralized in `lib/controllers/calendar_controller.dart`.
-   **Architecture:** The project follows a feature-based architecture, with widgets, controllers, data, and models organized into separate directories.
-   **Data Model:** The application uses a `MealInstance` model to represent meals on the calendar, which are created from `MealTemplate` blueprints. The full data model and mock data are defined in `SPEC.md`.
-   **Immutability:** The state management approach relies on immutable data structures. When the state is modified, a new state object is created.
-   **Testing:** The project includes unit and widget tests. Tests for the controller and widgets can be found in the `test/` directory.
