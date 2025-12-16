class ApiConstants {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String todosEndpoint = '/todos';
}

class AppStrings {
  static const String appName = 'Todo Sync';
  static const String loginTitle = 'Login';
  static const String welcomeBack = 'Welcome Back';
  static const String emailLabel = 'Email';
  static const String emailHint = 'Enter your email';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String loginButton = 'Login';
  static const String invalidCredentials = 'Invalid credentials';
  
  static const String searchHint = 'Search tasks...';
  static const String noTasksTitle = 'No tasks yet!';
  static const String noTasksSubtitle = 'Start by adding a task.';
  static const String newTask = 'New Task';
  static const String editTask = 'Edit Task';
  static const String whatNeedsToBeDone = 'What needs to be done?';
  static const String taskHint = 'e.g., Buy groceries';
  static const String addTaskButton = 'Add Task';
  static const String saveChangesButton = 'Save Changes';
  
  static const String settingsTitle = 'Settings';
  static const String logout = 'Logout';
  static const String loggedOutMessage = 'Logged out successfully';
  
  static const String offlineMessage = 'You are offline. Changes will be synced when you are back online.';
  static const String lastSyncedPrefix = 'Last synced: ';
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
}

class ErrorMessages {
  static const String loadTasks = 'Unable to load tasks';
  static const String addTask = 'Unable to add task';
  static const String updateTask = 'Unable to update task';
  static const String deleteTask = 'Unable to delete task';
  static const String syncTasks = 'Unable to sync tasks';
}

class HiveBoxes {
  static const String todos = 'todos';
  static const String deletedTodos = 'deleted_todos';
}

class AppAssets {
  static const String logo = 'assets/images/todoapp_logo.png';
}
