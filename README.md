# Inktome

**A privacy-first, offline book tracking app for readers who just want to organise their books.**

Built with Flutter. No accounts. No Inktome cloud. Just your library, on your phone.

---

## About

Inktome is a mobile app that lets you catalogue your personal book collection without giving your reading habits to a corporation. Search online or scan a barcode, get the book's details, and save everything locally on your device.

It was built as a direct response to the reality that every major book tracking platform either requires an account, stores your data on their servers, or layers social features on top of something that should be simple and personal.

Inktome uses Flutter and SQLite for local-first storage, with the Google Books API handling metadata lookups. If you want to back your data up, you can export it and store it wherever you like — your own Google Drive, Dropbox, wherever. That's your infrastructure, not ours.

> Currently under active development as a final-year IT project at Middlesex University (CST3395).

---

## Features

- **Online Search** - search online for your book of choice to add to your personal library
- **Barcode scanning** — point your camera at an ISBN to fetch title, author, cover, and metadata automatically
- **Manual entry** — add books that aren't in any database
- **Reading status** — track what you're reading, what's waiting, what you've finished, and what you abandoned
- **Decimal ratings** — because 4.5 stars is meaningfully different from 4
- **Custom tags** — organise books however makes sense to you
- **Markdown notes** — write notes per book in a format you can take anywhere
- **NFC integration** — optionally link a cheap NFC sticker to a physical book for instant tap-to-open access
- **Full data export** — CSV, Markdown, and JSON. Your data, portable, always

---

## Design Principles

- **Offline by default** — internet is needed only for the initial metadata lookup
- **No Inktome accounts** — zero sign-up friction, zero tracking
- **Data portability** — full export in open formats, no lock-in
- **NFC as enhancement** — the app works perfectly without it

---

## Getting Started

> Full setup instructions will be added as the project progresses.

**Requirements:**

- Flutter SDK (3.x or later)
- Android or iOS device / emulator
- A physical Android device with NFC for NFC features

```bash
git clone https://github.com/your-username/inktome.git
cd inktome
flutter pub get
flutter run
```

---

## Licence

To be confirmed upon project completion.
