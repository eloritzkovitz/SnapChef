import { Request, Response } from 'express';
import { recognizePhoto, recognizeReceipt, recognizeBarcode } from './imageRecognition';

export const handleRecognition = async (req: Request, res: Response, type: string): Promise<void> => {
  console.log(`Received POST request at /recognize/${type}`);
  try {
    const file = req.file;
    if (!file) {
      res.status(400).json({ error: 'No file uploaded.' });
      return;
    }

    let result;
    switch (type) {
      case 'photo':
        result = await recognizePhoto(file.path);
        break;
      case 'receipt':
        result = await recognizeReceipt(file.path);
        break;
      case 'barcode':
        result = await recognizeBarcode(file.path);
        break;
      default:
        res.status(400).json({ error: 'Invalid recognition type.' });
        return;
    }

    res.json(result);
  } catch (error) {
    console.error(`Error recognizing ${type}:`, error);
    res.status(500).json({ error: 'Failed to recognize image.' });
  }
};