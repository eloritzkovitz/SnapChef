# SnapChef Backend

The SnapChef Backend is a Node.js application that provides API endpoints for image recognition and ingredient categorization. It uses the Google Cloud Vision API to process images and recognize ingredients.

## Features

- Recognize ingredients from photos of food items.
- Extract and recognize ingredients from scanned receipts.
- Identify food items and their categories from barcodes.

## Getting Started

### Prerequisites

- Node.js: [Install Node.js](https://nodejs.org/)
- Google Cloud Vision API: [Set up Google Cloud Vision API](https://cloud.google.com/vision/docs/setup)
<<<<<<< HEAD
- OpenAI: [Set up OpenAI API](https://platform.openai.com/docs/quickstart)

### Installation

1. **Clone the repository:**
```sh
   git clone https://github.com/Elor-Itz/SnapChef.git
   cd SnapChef/api_server
   ```

2. **Install dependencies:**
```sh
   npm install
   ```

3. **Set up environment variables:**
   Create a `.env` file in the `SnapChef/api_server` folder and add your API keys:
```sh
   GOOGLE_APPLICATION_CREDENTIALS=path/to/your/service-account-file.json
   OPENAI_API_KEY=<YOUR_API_KEY>
   ```

4. **Run the server:**
```sh
   tsc
   node dist/server.js     
   ``` 
   Make sure you are inside the `/api_server` folder.

## Usage

1. Start the backend server.

2. Use the provided API endpoints according to your needs.

## API Endpoints

* `POST /recognize/photo:` Recognize ingredients from a photo.
* `POST /recognize/receipt:` Extract and recognize ingredients from a scanned receipt.
* `POST /recognize/barcode:` Identify food items and their categories from a barcode.

## Project Structure

* `src/:` Contains the main application code.
  * `server.ts:` Entry point of the application.
  * `modules/:` Contains API modules.
    * `ingredient/:` Handles ingredient recognition, creation and maintenance.
    * `recipe/:` Handles recipe generation.
* `tsconfig.json:` Contains configuration files.
* `package.json:` Defines the dependencies and scripts for the Node.js project.
