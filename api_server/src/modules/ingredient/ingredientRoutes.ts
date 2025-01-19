import express from 'express';
import multer from 'multer';
import path from 'path';
import { handleRecognition } from './ingredientController';

const router = express.Router();

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

// Define routes
router.post('/recognize/photo', upload.single('file'), (req, res) => handleRecognition(req, res, 'photo'));
router.post('/recognize/receipt', upload.single('file'), (req, res) => handleRecognition(req, res, 'receipt'));
router.post('/recognize/barcode', upload.single('file'), (req, res) => handleRecognition(req, res, 'barcode'));

export default router;