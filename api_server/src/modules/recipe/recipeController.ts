import { Request, Response } from 'express';
import { createRecipe } from './recipeGeneration';

export const generateRecipe = async (req: Request, res: Response): Promise<void> => {
  const { ingredients } = req.body;

  if (!ingredients) {
    res.status(400).json({ error: 'Ingredients are required.' });
    return;
  }

  try {
    const recipe = await createRecipe(ingredients);
    res.json({ recipe });
  } catch (error) {
    console.error('Error generating recipe:', error);
    res.status(500).json({ error: (error as Error).message });
  }
};