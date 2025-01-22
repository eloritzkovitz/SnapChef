import path from 'path';
import fs from 'fs';

interface Category {
  name: string;
  ingredients: string[];
  keywords: string[];
}

interface Categories {
  categories: Category[];
}

let categoriesData: Categories | null = null;

export async function loadIngredientData(): Promise<Categories> {
  if (!categoriesData) {
    // Determine the correct path based on the current directory
    const categoriesPath = path.resolve(__dirname, '../data/ingredientData.json');
    const data = await fs.promises.readFile(categoriesPath, 'utf-8');
    categoriesData = JSON.parse(data);
  }
  return categoriesData as Categories;
}