param(
    [string]$projectName = ""
)

if ($projectName -eq "") {
    Write-Host "Please provide a project name: CreateExpressApp.ps1 -projectName <project-name>"
    Exit
}

# Define project name and directory
$projectDir = Join-Path -Path (Get-Location) -ChildPath $projectName

# Create project directory
New-Item -Path $projectDir -ItemType Directory

# Change directory to project
Set-Location -Path $projectDir

# Initialize new Node.js project
npm init -y

# Install TypeScript, Express, dotenv, Prisma, and necessary TypeScript types
npm install express dotenv prisma @prisma/client
npm install --save-dev typescript @types/node @types/express ts-node

# Initialize TypeScript
npx tsc --init --rootDir src --outDir dist --esModuleInterop --resolveJsonModule --lib es6,dom --module commonjs

# Setup Prisma with MongoDB
npx prisma init
Set-Content -Path .\prisma\schema.prisma -Value @"
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mongodb"
  url      = env("DATABASE_URL")
}
"@

# Create necessary folders and files
New-Item -Path src -ItemType Directory
Set-Content -Path src\index.ts -Value @"
import express from 'express';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
"@

# Create .env file
Set-Content -Path .env -Value @"
PORT=3000
DATABASE_URL='your-mongodb-connection-string'
"@

# Create .gitignore file
Set-Content -Path .gitignore -Value @"
node_modules/
dist/
.env
"@

# Create README.md
Set-Content -Path README.md -Value @"
# $projectName

This project is set up with Express.js, TypeScript, dotenv, and Prisma configured for MongoDB.

## Installation

Run ``npm install`` to install dependencies.

## Running the project

Run ``npm start`` to start the server.
"@

# Create vercel.json
Set-Content -Path vercel.json -Value @"
{
  "version": 2,
  "builds": [
    {
      "src": "dist/index.js",
      "use": "@vercel/node"
    }
  ]
}
"@

# Add scripts to package.json
$packageJson = Get-Content -Path package.json -Raw | ConvertFrom-Json
$packageJson.scripts = @{
    "start" = "ts-node src/index.ts"
    "build" = "tsc"
}
$packageJson | ConvertTo-Json -Depth 100 | Set-Content -Path package.json

# Create docker-compose.yml for MongoDB, store in ./db folder
New-Item -Path db -ItemType Directory
Set-Content -Path db\docker-compose.yml -Value @"
version: '3.8'
services:
  mongodb:
    image: mongo:latest
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    ports:
      - '27017:27017'
    volumes:
      - mongodb_data:/data/db
volumes:
  mongodb_data:
"@

# Initialize git repository
git init

# Add all files to git
git add .

# Commit changes
git commit -m "Initial commit"

# Output completion message
Write-Host "Node.js project setup complete. MongoDB Docker container configured."
