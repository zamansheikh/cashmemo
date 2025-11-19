# CashMemo - Professional Grocery Shop Management App

A complete, production-ready Flutter application for grocery shop management with beautiful cash memo generation and printing capabilities. Built with Clean Architecture and BLoC pattern for maintainability and scalability.

## ✨ Features

### Core Features
- **Product Management**: Add, edit, delete, and search products with stock tracking
- **Customer Management**: Maintain customer database with contact details
- **Cash Memo Creation**: Create professional cash memos with multiple items
- **PDF Generation**: Generate beautiful, printable PDF cash memos
- **Shop Settings**: Configure shop information (name, address, GST, etc.)
- **Dashboard**: Overview of products, customers, and cash memos

### Technical Features
- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **BLoC Pattern**: Predictable state management with flutter_bloc
- **Local Database**: SQLite for data persistence
- **Responsive Design**: Works seamlessly on mobile and desktop
- **Cross-Platform**: Runs on Android and Windows (also supports iOS, macOS, Linux, Web)
- **Professional UI**: Material Design 3 with polished, intuitive interface

## 🚀 Getting Started

### Run the app:

For Android:
```bash
flutter run
```

For Windows:
```bash
flutter run -d windows
```

## 💡 Usage

### Creating Cash Memo
1. Tap "New Cash Memo" on dashboard
2. Optionally select a customer
3. Add items from product list
4. Adjust discount/tax if needed
5. Save or Save & Print to generate PDF

## 📊 Architecture

Built with Clean Architecture:
- **Domain Layer**: Entities and repository interfaces
- **Data Layer**: Models, data sources, and repository implementations
- **Presentation Layer**: BLoC state management and UI screens

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
