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

export { recognizeImage };