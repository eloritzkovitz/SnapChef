# Data Models

This document describes the core data objects (models) used throughout the SnapChef application.  
Models represent the structure of data exchanged between the app, backend, and local storage.


## User

| Field           | Type           | Description                                   |
|-----------------|----------------|-----------------------------------------------|
| `id`            | String         | Unique identifier for the user                |
| `firstName`     | String         | User's first name                             |
| `lastName`      | String         | User's last name                              |
| `email`         | String         | User's email address                          |
| `password`      | String?        | User's password (optional, usually not stored)|
| `profilePicture`| String?        | URL or path to the user's profile picture     |
| `joinDate`      | String?        | Date the user joined                          |
| `fridgeId`      | String         | ID of the user's fridge                       |
| `cookbookId`    | String         | ID of the user's cookbook                     |
| `preferences`   | Preferences?   | Dietary preferences, restrictions, allergies  |
| `friends`       | List<User>     | List of user's friends                        |
| `fcmToken`      | String?        | Firebase Cloud Messaging token                |


## Ingredient

| Field           | Type      | Description                                   |
|-----------------|-----------|-----------------------------------------------|
| `id`            | String    | Unique identifier for the ingredient          |
| `name`          | String    | Name of the ingredient                        |
| `category`      | String    | Ingredient category                           |
| `imageURL`      | String    | URL or asset path to the ingredient image     |
| `count`         | int       | Quantity/count of the ingredient              |


## Recipe

| Field           | Type               | Description                                 |
|-----------------|--------------------|---------------------------------------------|
| `id`            | String             | Unique identifier for the recipe            |
| `title`         | String             | Name of the recipe                          |
| `description`   | String             | Recipe description                          |
| `mealType`      | String             | Meal category (e.g., breakfast, dinner)     |
| `cuisineType`   | String             | Cuisine type (e.g., Italian, Asian)         |
| `difficulty`    | String             | Difficulty level                            |
| `prepTime`      | int                | Preparation time in minutes                 |
| `cookingTime`   | int                | Cooking time in minutes                     |
| `ingredients`   | List<Ingredient>   | List of ingredients required                |
| `instructions`  | List<String>       | Step-by-step cooking instructions           |
| `imageURL`      | String?            | URL to the recipe image                     |
| `rating`        | double?            | Average rating                              |
| `isFavorite`    | bool               | Whether the recipe is favorited             |
| `source`        | RecipeSource       | Source of the recipe (ai, user, shared)     |


## SharedRecipe

| Field           | Type      | Description                                   |
|-----------------|-----------|-----------------------------------------------|
| `id`            | String    | Unique identifier for the shared recipe       |
| `recipe`        | Recipe    | The shared recipe object                      |
| `fromUser`      | String    | User ID of the sender                         |
| `toUser`        | String    | User ID of the recipient                      |
| `sharedAt`      | DateTime  | Date the recipe was shared                    |
| `status`        | String    | Status (e.g., pending, accepted)              |


## FriendRequest

| Field           | Type      | Description                                   |
|-----------------|-----------|-----------------------------------------------|
| `id`            | String    | Unique identifier for the friend request      |
| `from`          | User      | User who sent the request                     |
| `to`            | String    | User ID of the recipient                      |
| `status`        | String    | Status (e.g., pending, accepted, rejected)    |
| `createdAt`     | DateTime  | Date the request was created                  |


## Notifications

### AppNotification (abstract)

| Field           | Type      | Description                                   |
|-----------------|-----------|-----------------------------------------------|
| `id`            | String    | Unique identifier for the notification        |
| `title`         | String    | Notification title                            |
| `body`          | String    | Notification message                          |
| `type`          | String    | Notification type (see below)                 |
| `scheduledTime` | DateTime  | When the notification should be shown         |


#### Subtypes:

- **IngredientReminder**
  - `ingredientName`: String — Name of the ingredient
  - `typeEnum`: ReminderType — expiry, grocery, or notice
  - `recipientId`: String — User ID of the recipient
  > Has three subtypes - Expiry alert, grocery reminder and notice.

- **FriendNotification**
  - `friendName`: String — Name of the friend involved
  - `senderId`: String — User ID of the sender
  - `recipientId`: String — User ID of the recipient

- **ShareNotification**
  - `friendName`: String? — Name of the friend (optional)
  - `recipeName`: String? — Name of the recipe (optional)
  - `senderId`: String — User ID of the sender
  - `recipientId`: String — User ID of the recipient


## Other Models

- **Fridge:** Stores two lists of ingredients - one for fridge items and one for grocery items.
- **Cookbook:** Stores a list of recipes.
- **Preferences:** Stores dietary preferences, restrictions, and allergies for a user.
- **Stats:** Aggregated statistics for user profiles (e.g., recipe count, friend count).

  
---

> **Note:**  
> This is a high-level overview. For detailed model definitions, see the code in [`lib/models/`](../lib/models/).