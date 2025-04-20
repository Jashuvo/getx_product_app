# GetX Product App 🚀

## Overview
A Flutter e-commerce product catalogue demonstrating clean architecture and GetX state management.

## Features
- 📱 Product listing with card views
- 🔍 Real-time product search
- 🏷️ Category-based filtering
- 📖 Detailed product pages
- 🎨 Modern responsive UI

## Tech Stack
- Flutter
- GetX
- DummyJSON API

## Project Structure
```
lib/
├── controllers/    # GetX controllers
├── models/         # Data models
├── views/         # UI screens
├── services/      # API services
└── utils/         # Helper functions
```

## Setup & Installation
1. Clone the repository
```bash
git clone https://github.com/Jashuvo/getx_product_app.git
```

2. Get dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## API Integration
Using [DummyJSON](https://dummyjson.com/):
- Products List: `/products?limit=100`
- Search: `/products/search?q={query}`
- Categories: `/products/categories`

