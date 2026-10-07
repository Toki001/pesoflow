enum Appearance {
  system('System', 'Follow your device appearance'),
  light('Light', 'Always use light appearance'),
  dark('Dark', 'Always use dark appearance');

  const Appearance(this.label, this.description);
  final String label;
  final String description;
}
