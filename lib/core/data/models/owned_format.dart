enum OwnedFormat {
  physical,
  ebook,
  audiobook,
  pdf;

  String get label => switch (this) {
    OwnedFormat.physical => 'Physical',
    OwnedFormat.ebook => 'E-Book',
    OwnedFormat.audiobook => 'Audiobook',
    OwnedFormat.pdf => 'PDF',
  };
}
