import mongoose, { Schema, Document } from 'mongoose';

interface Ingredient extends Document {
  name: string;
  category: string;
  imageURL: string;
}

const IngredientSchema: Schema = new Schema(
  {
    name: { type: String, required: true },
    category: { type: String, required: true },
    imageURL: { type: String, required: true },
  },
  { timestamps: true } // Generate timestamp when creating and updating
);

export default mongoose.model<Ingredient>('Ingredient', IngredientSchema);