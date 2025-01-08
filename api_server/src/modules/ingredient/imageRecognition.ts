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
async function recognizeImage(imagePath: string): Promise<{ ingredient: string; category: string }[]> {
  try {
    // Perform label detection
    const [result] = await client.labelDetection(imagePath);
    const labels = result.labelAnnotations;

    // Log the detected labels
    if (labels && labels.length > 0) {
      labels.forEach(label => {
        console.log(`Label: ${label.description}, Score: ${label.score}`);
      });
    }

    // Sort labels by confidence score in descending order and take the highest confidence label
    const sortedLabels = (labels || [])
      .filter(label => label.description)  // Only keep labels with descriptions
      .sort((a, b) => (b.score ?? 0) - (a.score ?? 0)); // Sort by confidence score in descending order

    // The best match is the first label after sorting
    const bestMatch = sortedLabels[0]?.description?.toLowerCase() ?? 'unknown';
 
    // Define category mapping
    const categoriesPath = process.env.CATEGORIES_PATH || path.join(__dirname, '../../modules/ingredient/ingredientCategories.json');
    const categoriesData: Categories = JSON.parse(await fs.promises.readFile(categoriesPath, 'utf-8'));

    // Find the best category for the ingredient
    let categoryMatch = 'Unknown';
    for (const category of categoriesData.categories) {
      // If the best match ingredient description contains any of the category keywords
      if (category.keywords.some(keyword => bestMatch.includes(keyword))) {
        categoryMatch = category.name;
        break;  // Exit as soon as a match is found
      }
    }
    
    // Log the recognized ingredient and category
    console.log('Recognized:', bestMatch, categoryMatch);

    return [{
      ingredient: bestMatch,
      category: categoryMatch
    }];       
  } catch (error) {
    console.error('Error recognizing image:', error);
    throw new Error(`Error recognizing image: ${(error as Error).message}`);
  }
}

export { recognizeImage };