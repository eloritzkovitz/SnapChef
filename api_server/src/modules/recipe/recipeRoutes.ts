import express from 'express';
import { generateRecipe } from './recipeController';

const router = express.Router();

router.post('/generate', generateRecipe);

export default router;