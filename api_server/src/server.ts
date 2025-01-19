import express from 'express';
import path from 'path';
import ingredientRoutes from './modules/ingredient/ingredientRoutes';
import recipeRoutes from './modules/recipe/recipeRoutes';

const app = express();

// Middleware to parse JSON bodies
app.use(express.json());

// Use the ingredient routes
app.use('/api', ingredientRoutes);

// Use the recipe routes
app.use('/api', recipeRoutes);

const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});