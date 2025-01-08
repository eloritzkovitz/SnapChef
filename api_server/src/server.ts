import express from 'express';
import multer from 'multer';
import { recognizeImage } from './modules/ingredient/imageRecognition';
import path from 'path';

const app = express();

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'dist/uploads'); // Adjust the upload folder as needed
  },
  filename: (req, file, cb) => {
    // Extract the original file extension
    const extension = path.extname(file.originalname);
    // Save the file with a timestamp and its original extension
    cb(null, `${Date.now()}${extension}`);
  },
});

// Initialize Multer
const upload = multer({ storage: storage });

// Image recognition endpoint
app.post('/recognize', upload.single('file'), (req, res) => {  
  // Log the received request
  console.log('Received POST request at /recognize');
  if (!req.file) {
    res.status(400).send({ message: 'No file uploaded' });
    return;
  }  
  console.log('File uploaded successfully');
  
  // Get the image path
  const imagePath = req.file.path;

  try {
    // Call the recognizeImage function
    const results = recognizeImage(imagePath);
    res.status(200).json({ results });
  } catch (error) {
    console.error('Error processing /recognize request:', error);
    res.status(500).json({ message: 'Failed to process the image' });
  }  
}); 

// Start the Express server on the specified port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});