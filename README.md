# QR Analyzer Flutter App

This Flutter app lets users capture an image from the camera or pick one from the gallery, sends the image to OpenAI for an initial analysis, and then decodes any QR codes found in the image. Each QR code's text is further analyzed by OpenAI to determine what it does (e.g., URL, Wi-Fi credentials, etc.) and any potential security risks.

Read the Wiki on this project and QR codes [**Here**](https://github.com/VictoKu1/qr_analyzer/wiki)

## Features

1. **Camera Capture**: Opens device camera to take a photo.
2. **Gallery Import**: Allows selecting existing images (`.jpg`, `.jpeg`, `.png`).
3. **OpenAI Integration**:
   - Initial Image Analysis (conceptually using GPT-4o text completions; a production version might require a specialized vision model or a chat-completion API).
   - QR Text Analysis.
4. **QR Decoding** (using `qr_code_tools`).

## Requirements

- **Flutter SDK** (3.0 or above).  
- A **valid OpenAI API key** (placed in `openai_service.dart` for demo).

## Project Structure

```
qr_analyzer/
│ └─lib/
│   ├── main.dart
│   ├── screens/
│   │    ├── home_screen.dart
│   │    └── camera_screen.dart
│   ├── services/
│   │    └── openai_service.dart
│   └── utilities/
│       └── qr_utils.dart
└── README.md
```

## Getting Started

### 1. Install Flutter

Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) to set up Flutter on your machine.

### 2. Clone the Repository

```bash
git clone https://github.com/VictoKu1/qr_analyzer.git
cd qr_analyzer
```

### 3. Install Dependencies

```bash
flutter pub get
```
### 4. Add OpenAI API Key

Add your OpenAI API key to `openai_service.dart`:

```dart
static const _apiKey = 'YOUR_OPENAI_API_KEY';
```

### 4. Run the App
- Android/iOS:

```bash
flutter run
```

- Web:

```bash
flutter run -d web
```

## Contributing

Feel free to open issues or submit PRs. For bigger changes, open an issue to discuss first.

## License

[MIT License](LICENSE)


## Notes & Remarks

1. **Web Compatibility**:  
   - Some libraries (like `image_picker`) and `qr_code_tools` may have limited or no web support. If true cross-platform is desired, you might need a web-friendly alternative or fallback.  
2. **Multi-QR Support**:  
   - Currently, `qr_code_tools` typically decodes the *first* found QR code. For detecting multiple QR codes, consider using packages like [google_ml_kit](https://pub.dev/packages/google_ml_kit) or another specialized library.
3. **OpenAI Image Analysis**:  
   - The example uses GPT-3.5-Turbo’s `/chat/completions` for an “image analysis,” which isn’t truly supported in standard GPT endpoints. This is a **conceptual** approach. In production, you’d need a real vision model or to integrate with a specialized service.  
4. **Permissions**:  
   - On iOS, ensure you have the correct entries in `Info.plist` for camera and photo library.  
   - On Android, ensure `AndroidManifest.xml` includes `CAMERA`, `READ_EXTERNAL_STORAGE`, etc.

With this **step-by-step** setup, you have a basic Flutter app that:

- Runs on Android, iOS (and potentially web with some caveats).
- Lets users capture or pick images.
- Sends images to OpenAI for a first-phase analysis.
- Decodes any QR code(s) found.
- Sends the decoded text to OpenAI for a second-phase analysis.
- Displays the results in a straightforward UI.

Feel free to **customize** the design, add robust error handling, or integrate more advanced features like domain reputation checks or advanced vision models.








