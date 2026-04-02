enum BookStatus {
  toRead,
  reading,
  finished,
  dnf;

  // Convenience for display — used by UI and export, never by the DB layer.
  String get label => switch (this) {
    BookStatus.toRead => 'To Read',
    BookStatus.reading => 'Reading',
    BookStatus.finished => 'Finished',
    BookStatus.dnf => 'DNF',
  };
}
