# Todo Sync App

A modern, offline-first Flutter application demonstrating Clean Architecture, BLoC pattern, and seamless data synchronization with a RESTful API.

## 🎥 Demo
https://github.com/user-attachments/assets/7591b455-3e21-4eee-9efa-f00dd3e1e291

## 📱 Features

-   **Offline-First Capability**: Create, edit, and delete tasks anywhere. Data is persisted locally using **Hive** and syncs automatically when the internet connection is restored.
-   **Robust State Management**: Powered by the **BLoC** (Business Logic Component) pattern for predictable state transitions.
-   **Clean Architecture**: distinct separation of concerns into Presentation, Domain, and Data layers, ensuring scalability and testability.
-   **Smart Syncing**:
    -   Auto-syncs unsynced changes when connectivity returns.
    -   Displays a "Last synced" timestamp with smart formatting (e.g., "Today 10:00 AM").
    -   Visual indicators for unsynced items.
-   **Modern UI/UX**:
    -   **Custom Design System**: Reusable `AppButton`, `AppTextField`, and standard `AppTheme`.
    -   **Interactive Elements**: Swipe-to-refresh, search filtering, and dismissal animations.
    -   **Platform Native Feel**: Uses `CupertinoActivityIndicator` for iOS-style loading.
-   **User Management**: Mock Login screen with custom logo and a Settings page for logout functionality.

## 🛠️ Tech Stack

-   **Flutter & Dart**: Core framework.
-   **flutter_bloc**: State management.
-   **dio**: Network requests (REST API).
-   **hive**: Fast key-value database for local storage.
-   **get_it**: Dependency injection.
-   **connectivity_plus**: Network connectivity detection.
-   **intl**: Date formatting.
-   **equatable**: Value equality comparison.
-   **dartz**: Functional programming (Either type for error handling).

## 🏗️ Architecture & Design Decisions

### Clean Architecture Layers
1.  **Presentation**:
    -   **Pages**: `LoginPage`, `TodoListPage`, `SettingsPage`.
    -   **Widgets**: Reusable components like `TodoItem`, `SearchBarWidget`, `SyncStatusBar`, `EmptyTodoView`.
    -   **BLoC**: `TodoBloc` handles events (`Load`, `Add`, `Toggle`, `Delete`, `Sync`, `Search`) and emits states.
2.  **Domain**:
    -   **Entities**: Pure Dart classes (`Todo`).
    -   **Use Cases**: Single-responsibility classes encapsulating business rules (`GetTodos`, `AddTodo`, etc.).
    -   **Repositories**: Abstract interfaces defining data contracts.
3.  **Data**:
    -   **Models**: DTOs transforming JSON/Hive data to Domain entities (`TodoModel`).
    -   **Data Sources**: `TodoRemoteDataSource` (Dio) and `TodoLocalDataSource` (Hive).
    -   **Repository Implementation**: Coordinates data flow and sync logic.

### Design Decisions
*   **Local-First Merge Strategy**: Since the backend ([JSONPlaceholder](https://jsonplaceholder.typicode.com/)) is stateless and does not persist data, the app adopts a strict local-first approach. When fetching data, if an item exists locally, the remote version is ignored to prevent overwriting user changes with stale server data.
*   **Separation of Concerns**: UI components like the Search Bar and Empty View were extracted into separate widgets to keep the main `TodoListPage` clean and readable.

## 🚧 Challenges & Solutions

### 1. Syncing with a Stateless API
**Challenge**: JSONPlaceholder accepts POST/PATCH/DELETE requests but returns success without saving the data. A subsequent GET request returns the original dataset, which would normally revert the user's local edits.
**Solution**: In `TodoRepositoryImpl`, a logic check was added: `if (localMatch == null) { ... }`. This ensures that we only accept *new* items from the server and never overwrite existing local items that might have pending changes or correct offline states.

### 2. Preventing "Resurrection" of Deleted Items
**Challenge**: If an item is deleted offline, it is removed from the local DB. On the next sync, the server sends the item back (since it wasn't really deleted on the backend).
**Solution**: The logic prioritizes local state. By managing the merge strategy carefully, we ensure that the app relies on its local source of truth for existing sessions, mitigating the limitations of the mock API.

## 📡 Offline Support Strategy

1.  **Persistence**: Every action (Add, Update, Delete) is immediately executed against the **Hive** local database.
2.  **Queueing**: Items modified offline are marked with `isSynced: false`.
3.  **Auto-Sync**: A `Connectivity` listener triggers the `SyncOfflineTodos` event when the device goes online.
    -   It iterates through unsynced items and pushes them to the server.
    -   On success, it updates the local record to `isSynced: true`.
    -   It then updates the global "Last synced" timestamp.

## 🚀 Setup Instructions

1.  **Clone the repo**:
    ```bash
    git clone <repository_url>
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```
    *Note: The app uses a mock login. You can use any email/password (e.g., `test@example.com` / `password123`) or just click Login.*
