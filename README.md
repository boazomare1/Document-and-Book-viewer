# Modern PDF Reader

A world-class Flutter PDF reader application with Material 3 design, advanced features, and comprehensive accessibility support.

## Features

### Core PDF Reading
- **High-performance PDF rendering** using Syncfusion Flutter PDF Viewer
- **Smooth page navigation** with gesture support (swipe, double-tap zoom)
- **Zoom controls** with pinch-to-zoom and double-tap functionality
- **Search functionality** with text highlighting and navigation
- **Page thumbnails** for quick navigation
- **Table of contents** sidebar for structured documents

### Accessibility Features
- **Screen reader support** with comprehensive Semantics
- **Text-to-Speech (TTS)** for reading aloud PDF content
- **Reading themes**: Light, Dark, Sepia, and High-Contrast
- **Adjustable font size** and text reflow for low-vision users
- **WCAG 2.1 compliance** for accessibility standards

### Annotation Tools
- **Highlighting** with customizable colors
- **Underlining** and strikethrough
- **Freehand drawing** with pressure sensitivity
- **Sticky notes** with text annotations
- **Annotation management** with search and filtering

### Smart Features
- **AI-powered document summarization** using OpenAI
- **Question & Answer** on selected text
- **Language translation** with multiple language support
- **Cloud synchronization** (Google Drive, Dropbox, OneDrive)
- **Local database** for persistent storage

### Advanced PDF Features
- **Form filling** (AcroForms) with validation
- **Digital signatures** with certificate management
- **Secure PDF handling** with malware scanning
- **Large file optimization** (>500MB) with lazy loading
- **Performance monitoring** and caching

### User Experience
- **Material 3 design** with dynamic theming
- **Smooth animations** and transitions
- **Responsive layout** for tablets and phones
- **Internationalization** (i18n) with 12+ languages
- **Gesture support** for intuitive navigation

## Architecture

The project follows a clean, scalable architecture:

```
lib/
├── models/           # Data models and entities
├── providers/        # State management with Provider
├── services/         # Business logic and external APIs
├── screens/          # UI screens and pages
├── widgets/          # Reusable UI components
└── utils/           # Utility functions and helpers
```

### Key Components

- **PdfProvider**: Manages PDF documents and reading state
- **AccessibilityProvider**: Handles accessibility settings and TTS
- **AnnotationProvider**: Manages annotations and drawing tools
- **AiProvider**: Handles AI features and OpenAI integration
- **DatabaseService**: SQLite database for persistent storage
- **CloudStorageService**: Cloud storage integration
- **SecurityService**: PDF validation and security features
- **PerformanceService**: Caching and optimization
- **LocalizationService**: Internationalization support

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- iOS development tools (for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/modern_pdf_reader.git
   cd modern_pdf_reader
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for JSON serialization)
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

#### AI Features
To enable AI features, configure your OpenAI API key:

1. Get an API key from [OpenAI](https://platform.openai.com/)
2. Add it to the AI settings in the app
3. Enable the features you want to use

#### Cloud Storage
Configure cloud storage providers:

- **Google Drive**: Set up OAuth 2.0 credentials
- **Dropbox**: Configure API keys
- **OneDrive**: Set up Microsoft Graph API

#### Security Settings
Customize security preferences:

- File validation
- Malware scanning
- Encryption settings
- Maximum file size limits

## Usage

### Basic PDF Reading
1. **Open a PDF**: Tap the "+" button to select a local file or import from cloud
2. **Navigate**: Swipe left/right or use page controls
3. **Zoom**: Pinch to zoom or double-tap for quick zoom
4. **Search**: Use the search icon to find text in the document

### Accessibility Features
1. **Enable TTS**: Tap the speaker icon to start text-to-speech
2. **Change theme**: Use the theme selector for better visibility
3. **Adjust font size**: Use accessibility settings for larger text
4. **Screen reader**: The app is fully compatible with TalkBack/VoiceOver

### Annotations
1. **Highlight text**: Select text and choose highlight color
2. **Draw**: Use the drawing tool for freehand annotations
3. **Add notes**: Create sticky notes with your thoughts
4. **Manage**: View all annotations in the annotations panel

### AI Features
1. **Summarize**: Get AI-generated document summaries
2. **Ask questions**: Select text and ask questions about the content
3. **Translate**: Translate selected text to different languages

### Forms and Signatures
1. **Fill forms**: Complete PDF forms with validation
2. **Digital signatures**: Add and verify digital signatures
3. **Export**: Save filled forms and signed documents

## Development

### Project Structure

```
modern_pdf_reader/
├── lib/
│   ├── models/              # Data models
│   │   ├── pdf_document.dart
│   │   ├── annotation.dart
│   │   ├── ai_features.dart
│   │   ├── pdf_forms.dart
│   │   └── digital_signatures.dart
│   ├── providers/           # State management
│   │   ├── pdf_provider.dart
│   │   ├── accessibility_provider.dart
│   │   ├── annotation_provider.dart
│   │   └── ai_provider.dart
│   ├── services/            # Business logic
│   │   ├── database_service.dart
│   │   ├── cloud_storage_service.dart
│   │   ├── ai_service.dart
│   │   ├── form_service.dart
│   │   ├── signature_service.dart
│   │   ├── security_service.dart
│   │   ├── performance_service.dart
│   │   └── localization_service.dart
│   ├── screens/             # UI screens
│   │   ├── home_screen.dart
│   │   ├── reader_screen.dart
│   │   ├── settings_screen.dart
│   │   └── ai_settings_screen.dart
│   └── widgets/             # Reusable components
│       ├── pdf_viewer.dart
│       ├── annotation_toolbar.dart
│       └── accessibility_controls.dart
├── test/                    # Unit and widget tests
├── assets/                  # Images, fonts, translations
└── pubspec.yaml            # Dependencies and configuration
```

### Testing

Run the test suite:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Generate test coverage
flutter test --coverage
```

### Code Generation

Generate code for JSON serialization:

```bash
flutter packages pub run build_runner build
```

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## Dependencies

### Core Dependencies
- `syncfusion_flutter_pdfviewer`: PDF rendering and viewing
- `syncfusion_flutter_pdf`: Advanced PDF manipulation
- `provider`: State management
- `sqflite`: Local database
- `http`: Network requests
- `file_picker`: File selection
- `path_provider`: File system access

### Accessibility
- `flutter_tts`: Text-to-speech
- `shared_preferences`: Settings storage

### AI and Cloud
- `crypto`: Cryptographic operations
- `json_annotation`: JSON serialization
- `uuid`: Unique identifiers

### Performance and Security
- `flutter_cache_manager`: Caching
- `flutter_secure_storage`: Secure storage
- `pointycastle`: Cryptography
- `asn1lib`: ASN.1 encoding

### UI and UX
- `flutter_staggered_animations`: Smooth animations
- `flutter_localizations`: Internationalization
- `cached_network_image`: Image caching

### Testing
- `mockito`: Mocking for tests
- `test`: Unit testing framework
- `integration_test`: Integration testing

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter best practices and conventions
- Write comprehensive tests for new features
- Ensure accessibility compliance
- Update documentation for API changes
- Use meaningful commit messages

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Syncfusion for the excellent PDF libraries
- OpenAI for AI capabilities
- Flutter team for the amazing framework
- Material Design team for design guidelines

## Support

For support and questions:

- Create an issue on GitHub
- Check the documentation
- Review the FAQ section

## Roadmap

### Upcoming Features
- [ ] Advanced OCR capabilities
- [ ] Collaborative annotations
- [ ] Offline AI processing
- [ ] Advanced security features
- [ ] Performance optimizations
- [ ] Additional cloud providers
- [ ] Plugin system for extensions

### Version History

#### v1.0.0 (Current)
- Core PDF reading functionality
- Accessibility features
- Annotation tools
- AI integration
- Cloud storage
- Form filling and digital signatures
- Security features
- Internationalization
- Performance optimization
- Comprehensive testing

## Performance

The app is optimized for:

- **Large PDFs**: Efficient memory management for files >500MB
- **Smooth scrolling**: Lazy page loading and caching
- **Fast startup**: Optimized initialization and loading
- **Battery efficiency**: Smart caching and background processing
- **Memory usage**: Automatic cleanup and garbage collection

## Security

Security features include:

- **File validation**: PDF header and format verification
- **Malware scanning**: Basic security checks
- **Encryption**: Optional PDF encryption
- **Secure storage**: Encrypted local storage
- **Certificate validation**: Digital signature verification
- **Access control**: Permission-based file access

## Accessibility

Full accessibility support:

- **Screen readers**: Complete TalkBack/VoiceOver support
- **High contrast**: Multiple high-contrast themes
- **Text scaling**: Adjustable font sizes
- **Keyboard navigation**: Full keyboard support
- **Voice control**: Voice commands for navigation
- **Color blindness**: Color-blind friendly themes 