// MARK: ReadFormat
//
// The format a user is actively reading a book in.
//
// Intentionally separate from OwnedFormat — you can own a physical copy
// but be listening to the audiobook from the library. The two concepts
// are independent and should never be conflated.
//
// Lives on ReadInstances (long-term) and on Books as a nullable
// MVP placeholder until ReadInstances is active.

enum ReadFormat {
  physical,
  ebook,
  audiobook;
  // pdf;

  String get label => switch (this) {
    ReadFormat.physical => 'Physical',
    ReadFormat.ebook => 'E-Book',
    ReadFormat.audiobook => 'Audiobook',
    // ReadFormat.pdf => 'PDF',
  };
}
