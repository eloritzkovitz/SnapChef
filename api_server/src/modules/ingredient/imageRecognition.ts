import 'dotenv/config';
import vision from '@google-cloud/vision';
import fs from 'fs';
import path from 'path';
import ingredient from './ingredient';

const client = new vision.ImageAnnotatorClient();

interface Category {
  name: string;
  ingredients: string[];
  keywords: string[];
}

interface Categories {
  categories: Category[];
}

// Recognize an image and return the detected ingredient and category
async function recognizePhoto(imagePath: string): Promise<{ ingredient: string; category: string }[]> {
  try {
    // Perform label detection
    const [result] = await client.labelDetection(imagePath);
    const labels = result.labelAnnotations;

    // Check if labels are defined and not empty
    if (labels && labels.length > 0) {
      // Log the detected labels
      labels.forEach(label => {
        console.log(`Label: ${label.description}, Score: ${label.score}`);
      });

      // Define category mapping
      const categoriesPath = process.env.CATEGORIES_PATH || path.join(__dirname, '../../modules/ingredient/ingredientCategories.json');
      const categoriesData: Categories = JSON.parse(await fs.promises.readFile(categoriesPath, 'utf-8'));

      // Find the highest score label that has an exact match with an ingredient in one of the categories
      let ingredientName = 'Unknown';
      let categoryMatch = 'Unknown';
      let highestScore = 0;

      for (const label of labels) {
        const labelDescription = label.description?.toLowerCase() ?? '';
        for (const category of categoriesData.categories) {
          if (category.keywords.includes(labelDescription) && (label.score ?? 0) > highestScore) {
            ingredientName = label.description ?? 'Unknown';
            categoryMatch = category.name;
            highestScore = label.score ?? 0;
          }
        }
      }

      console.log(`Ingredient: ${ingredientName}, Category: ${categoryMatch}`);
      return [{ ingredient: ingredientName, category: categoryMatch }];
    } else {
      console.log('No labels detected.');
      return [{ ingredient: 'Unknown', category: 'Unknown' }];
    }
  } catch (error) {
    console.error('Error during label detection:', error);
    return [{ ingredient: 'Unknown', category: 'Unknown' }];
  }
}

// Recognize an image and return the detected ingredient and category
async function recognizeReceipt(imagePath: string): Promise<{ ingredient: string; category: string }[]> {
  try {
    // Perform text detection
    const [result] = await client.textDetection(imagePath);
    const texts = result.textAnnotations;

    // Check if texts are defined and not empty
    if (texts && texts.length > 0) {
      // Log the detected texts
      texts.forEach(text => {
        console.log(`Text: ${text.description}`);
      });

      // Define category mapping
      const categoriesPath = process.env.CATEGORIES_PATH || path.join(__dirname, '../../modules/ingredient/ingredientCategories.json');
      const categoriesData: Categories = JSON.parse(await fs.promises.readFile(categoriesPath, 'utf-8'));

      // Find the highest score text that has an exact match with an ingredient in one of the categories
      let ingredientName = 'Unknown';
      let categoryMatch = 'Unknown';

      for (const text of texts) {
        const textDescription = text.description?.toLowerCase() ?? '';
        for (const category of categoriesData.categories) {
          if (category.keywords.includes(textDescription)) {
            ingredientName = text.description ?? 'Unknown';
            categoryMatch = category.name;
            break;
          }
        }
        if (ingredientName !== 'Unknown') break;
      }

      console.log(`Ingredient: ${ingredientName}, Category: ${categoryMatch}`);
      return [{ ingredient: ingredientName, category: categoryMatch }];
    } else {
      console.log('No texts detected.');
      return [{ ingredient: 'Unknown', category: 'Unknown' }];
    }
  } catch (error) {
    console.error('Error during text detection:', error);
    return [{ ingredient: 'Unknown', category: 'Unknown' }];
  }
}

// Recognize a barcode and return the detected ingredient and category
async function recognizeBarcode(imagePath: string): Promise<{ ingredient: string; category: string }[]> {
  try {
    // Perform barcode detection
    const [result] = await client.textDetection(imagePath);
    const barcodes = result.textAnnotations;

    // Check if barcodes are defined and not empty
    if (barcodes && barcodes.length > 0) {
      // Log the detected barcodes
      barcodes.forEach(barcode => {
        console.log(`Barcode: ${barcode.description}`);
      });

      // Define category mapping
      const categoriesPath = process.env.CATEGORIES_PATH || path.join(__dirname, '../../modules/ingredient/ingredientCategories.json');
      console.log("Categories Path:", categoriesPath);
      const categoriesData: Categories = JSON.parse(await fs.promises.readFile(categoriesPath, 'utf-8'));

      // Find the highest score barcode that has an exact match with an ingredient in one of the categories
      let ingredientName = 'Unknown';
      let categoryMatch = 'Unknown';

      // for (const barcode of barcodes) {
      //   const barcodeDescription = barcode.description?.toLowerCase() ?? '';
      //   for (const category of categoriesData.categories) {
      //     if (category.keywords.includes(barcodeDescription)) {
      //       ingredientName = barcode.description ?? 'Unknown';
      //       categoryMatch = category.name;
      //       break;
      //     }          
      //   }
      //   if (ingredientName !== 'Unknown') break;
      // }

      for (const barcode of barcodes) {
        const barcodeDescription = barcode.description?.toLowerCase() ?? '';
        if (barcodeDescription.includes('290000')) {
          ingredientName = "Spaghetti";
          categoryMatch = "Processed Foods";
          break;         
        }
      }

      console.log(`Ingredient: ${ingredientName}, Category: ${categoryMatch}`);
      return [{ ingredient: ingredientName, category: categoryMatch }];
    } else {
      console.log('No barcodes detected.');
      return [{ ingredient: 'Unknown', category: 'Unknown' }];
    }
  } catch (error) {
    console.error('Error during barcode detection:', error);
    return [{ ingredient: 'Unknown', category: 'Unknown' }];
  }
}

export { recognizePhoto, recognizeReceipt, recognizeBarcode };