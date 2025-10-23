# AI RAG Product Checker (Mobile Frontend)

AI RAG Product Checker is a FastAPI-based service designed to verify FDA Philippines-regulated products using both database lookups and AI-powered image analysis. The application supports verification of food products, drug products, medical devices, cosmetics, and establishments.

This is the Repository exclusively for the mobile frontend portion of this project.

## Features

- **ID-based Verification**: Check products by registration numbers, license numbers, or tracking numbers
- **AI Image Verification**: Upload product images for AI-powered extraction and verification using Google's Gemini
- **Fuzzy Matching**: Intelligent matching with multiple scoring algorithms
- **Multi-category Support**: Handles drugs, food, medical devices, cosmetics, and establishments
- **RESTful API**: Clean API endpoints with proper error handling and documentation
  
## Prerequisites

- Flutter
- Git

## Installation

1. Clone the repository & navigate to proper directory:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   cd <project-folder>
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run project:
   ```bash
   flutter run
   ```
4. Run tests:
   ```bash
   flutter test
   ```
## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Add tests if applicable
5. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
6. Push to the branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request
