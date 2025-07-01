# lib/

This folder contains all the main source code for the SnapChef application. Below is an overview of each subfolder and its purpose:

## Folder Overview

- [`constants/`](./constants/)  
  Contains app-wide constant values such as strings, keys, and configuration variables.

- [`core/`](./core/)  
  Contains foundational classes and app-wide architecture components.

- [`database/`](./database/)    
  Local persistence logic, including Drift entities, DAOs, and the database class.

- [`models/`](./models/)   
  Data models representing core objects (e.g., User, Recipe, Ingredient) used throughout the app.

- [`providers/`](./providers/)   
  Providers that handle global state management (e.g. connectivity) used throughhout the app.

- [`repositories/`](./repositories/)  
  Repositories act as an abstraction layer between the data sources (local database and remote APIs) and the rest of the app. 

- [`services/`](./services/)    
  Classes for handling business logic, API communication, authentication, and other external services.

- [`theme/`](./theme/)    
  App theming resources, including color schemes, text styles, and theme data.

- [`utils/`](./utils/)    
  Utility functions and helper classes for formatting, validation, and other reusable logic.

- [`viewmodels/`](./viewmodels/)    
  State management classes (e.g., using Provider) that connect the UI to business logic and data sources.

- [`views/`](./views/)    
  UI screens and pages that make up the app’s navigation and user experience.

- [`widgets/`](./widgets/)    
  Reusable UI components and custom widgets used across multiple views.

## Notes

- This structure follows best practices for a scalable MVVM architecture, separating concerns for maintainability and clarity.
