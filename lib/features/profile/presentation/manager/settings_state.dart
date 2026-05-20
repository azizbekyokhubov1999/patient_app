sealed class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Holds persisted notification preference for UI binding.
class SettingsLoaded extends SettingsState {
  const SettingsLoaded({required this.notificationsEnabled});

  final bool notificationsEnabled;
}

class SettingsActionSuccess extends SettingsState {
  const SettingsActionSuccess(this.message);

  final String message;
}

class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;
}
