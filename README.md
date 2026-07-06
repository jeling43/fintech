# Fintech Investigator

A Flutter application that imports bank and financial record PDFs and converts the information into a more usable format for investigation review.

## Purpose

This app extracts information from difficult-to-review PDF financial records and organizes it so an investigator can search, filter, compare, and review the records more efficiently.

**The app does NOT:**
- Make accusations or investigative conclusions
- Decide whether a transaction is criminal
- Automatically identify suspects
- Generate legal documents
- Alter original evidence
- Guarantee extracted data accuracy

All extracted information is treated as a working copy that requires investigator review.

## Features

- **PDF Import**: Select and import one or more bank statement PDFs
- **Text Extraction**: Extract text from text-based PDFs using Syncfusion PDF
- **OCR Support**: Process scanned PDF pages using Google ML Kit
- **Transaction Parsing**: Automatically identify individual transactions
- **Data Review**: Edit, add, remove, and verify extracted records
- **Search & Filter**: Search by description, name, merchant, date range, amount
- **Data Integrity**: SHA-256 hashing, source tracking, edit history
- **CSV Export**: Export organized records with configurable columns
- **Local Processing**: All data stays on device — no external uploads

## Security & Privacy

- All files processed locally on device
- No external server uploads
- No advertising or analytics
- Account numbers masked in the interface
- Temporary OCR images deleted after processing
- Original PDFs never modified
- Confirmation required before deleting case data

## Getting Started

### Prerequisites

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- For Android: Android Studio with NDK
- For iOS: Xcode 15+
- For macOS: Xcode 15+

### Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd fintech
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate database code:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Platform-specific setup

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS/macOS

Add to `ios/Runner/Info.plist` (or `macos/Runner/Info.plist`):
```xml
<key>NSDocumentsFolderUsageDescription</key>
<string>Access documents to import PDF files</string>
```

For macOS, enable the file access entitlements in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── database/
│   ├── database.dart            # Drift database definition
│   ├── database.g.dart          # Generated database code
│   └── tables.dart              # Table definitions
├── models/
│   ├── models.dart              # Barrel export
│   ├── financial_record.dart    # Transaction record model
│   ├── import_metadata.dart     # PDF import metadata model
│   └── parsed_financial_record.dart  # Parser output model
├── parsers/
│   ├── parsers.dart             # Barrel export
│   ├── financial_record_parser.dart  # Parser interface
│   ├── generic_transaction_parser.dart  # Generic fallback parser
│   ├── chase_statement_parser.dart      # Chase-specific parser
│   └── parser_registry.dart     # Parser selection registry
├── providers/
│   ├── providers.dart           # Barrel export
│   ├── service_providers.dart   # Riverpod service providers
│   └── records_provider.dart    # Records state & filtering
├── screens/
│   ├── screens.dart             # Barrel export
│   ├── import_screen.dart       # PDF file selection
│   ├── processing_screen.dart   # Extraction progress
│   ├── review_screen.dart       # Record review & editing
│   ├── records_screen.dart      # Search, filter, sort
│   └── export_screen.dart       # CSV export
├── services/
│   ├── services.dart            # Barrel export
│   ├── pdf_extraction_service.dart   # PDF text extraction
│   ├── ocr_service.dart         # OCR processing
│   ├── hash_service.dart        # SHA-256 hashing
│   ├── csv_export_service.dart  # CSV file generation
│   └── import_service.dart      # Import orchestration
└── widgets/
    ├── widgets.dart             # Barrel export
    └── record_edit_dialog.dart  # Record editing dialog
```

## Adding Parsers for Additional Financial Institutions

The app uses a parser interface pattern that makes it easy to add support for new banks.

### Step 1: Create a parser class

Create a new file in `lib/parsers/` that implements `FinancialRecordParser`:

```dart
import '../models/financial_record.dart';
import '../models/parsed_financial_record.dart';
import 'financial_record_parser.dart';

class MyBankParser implements FinancialRecordParser {
  @override
  String get parserName => 'My Bank Statement Parser';

  @override
  bool canParse(String text) {
    // Return true if the text contains identifiers specific to your bank
    return text.toUpperCase().contains('MY BANK NAME');
  }

  @override
  ParsedFinancialRecord parse({
    required String text,
    required String sourceFile,
    required int pageNumber,
    required String importId,
  }) {
    // Parse the text and return structured records
    // Look for institution-specific patterns in dates, amounts, descriptions
    // ...
  }
}
```

### Step 2: Register the parser

Add your parser to `lib/parsers/parser_registry.dart`:

```dart
ParserRegistry() {
  _parsers.add(ChaseStatementParser());
  _parsers.add(MyBankParser());  // Add your parser here
}
```

### Step 3: Export it

Add the export to `lib/parsers/parsers.dart`:

```dart
export 'my_bank_parser.dart';
```

### Parser guidelines

- Return `canParse: true` only when you're confident the text is from your target institution
- Extract only information that is clearly present — never guess
- Set `isUncertain: true` on any record where parsing confidence is low
- Preserve the original text in every record for investigator review
- Use the `Uuid` package to generate unique IDs for each record

## Data Model

Each extracted record tracks:

| Field | Description |
|-------|-------------|
| Transaction Date | Date of the transaction (YYYY-MM-DD) |
| Posting Date | Date posted to account |
| Description | Transaction description |
| Merchant or Recipient | Who received or sent the payment |
| Debit | Amount debited |
| Credit | Amount credited |
| Amount | Net amount (negative for debits) |
| Balance | Running balance after transaction |
| Check Number | Check number if applicable |
| Reference Number | Bank reference number |
| Institution | Financial institution name |
| Account Holder | Name on the account |
| Masked Account Number | Partially masked account number |
| Source PDF | Filename of the source PDF |
| Source Page | Page number in the PDF |
| Original Text | Exact text extracted from the PDF |
| Reviewed | Whether an investigator has reviewed this record |
| Manually Edited | Whether this record was manually modified |

## Technology Stack

- **Framework**: Flutter with Material 3
- **State Management**: Riverpod
- **Database**: Drift with SQLite
- **PDF Extraction**: Syncfusion Flutter PDF
- **OCR**: Google ML Kit Text Recognition
- **File Selection**: file_selector
- **CSV Export**: csv package
- **Hashing**: crypto (SHA-256)
- **File Paths**: path_provider
- **Sharing**: share_plus

## Limitations

- OCR accuracy depends on scan quality
- Generic parser may not extract all fields from all bank formats
- Statement formats vary significantly between institutions
- Extracted data should always be verified by an investigator
- PDF rendering for OCR requires platform-specific implementation

## License

This project is for investigative use. Handle all imported financial records according to applicable laws and regulations regarding evidence handling and data privacy.