import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const apiKey = process.env.OPENAI_API_KEY;

if (!apiKey) {
  throw new Error("API key not configured properly.");
}

// Generate a recipe using the OpenAI API
const createRecipe = async (ingredients: string): Promise<string> => {
  try {
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: 'You are a helpful assistant that creates recipes.'
          },
          {
            role: 'user',
            content: `Create a recipe using the following ingredients: ${ingredients}`
          }
        ]
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        }
      }
    );

    if (response.data && response.data.choices && response.data.choices.length > 0) {
      return response.data.choices[0].message.content;
    } else {
      throw new Error('No recipe generated.');
    }
  } catch (error) {
    console.error('Error generating recipe:', error);
    throw new Error('Failed to generate recipe.');
  }
};

export { createRecipe };