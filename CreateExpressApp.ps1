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
npx tsc --init --rootDir api --outDir dist --esModuleInterop --resolveJsonModule --lib es6,dom --module commonjs

# Setup Prisma with MySQL
npx prisma init
Set-Content -Path .\prisma\schema.prisma -Value @"
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}
"@

# Create necessary folders and files
New-Item -Path api -ItemType Directory
Set-Content -Path api\index.ts -Value @"
import express from 'express';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(PORT, () => {
  console.log(``Server running on port `${PORT}``);
});
"@

# Create .env file
Set-Content -Path .env -Value @"
PORT=3000
DATABASE_URL='mysql://admin:password@localhost:3306/db'
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

This project is set up with Express.js, TypeScript, dotenv, and Prisma configured for MySQL.

## Installation

Run ``npm install`` to install dependencies.

## Running the project

Run ``npm start`` to start the server.
"@

# Create vercel.json
Set-Content -Path vercel.json -Value @"
{
  "version": 2,
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/api"
    }
  ]
}
"@

# Add scripts to package.json
$packageJson = Get-Content -Path package.json -Raw | ConvertFrom-Json
$packageJson.scripts = @{
    "start" = "ts-node api/index.ts"
    "prisma:push" = "npx prisma db push"
}
$packageJson | ConvertTo-Json -Depth 100 | Set-Content -Path package.json

# Create a tools folder
New-Item -Path tools -ItemType Directory

# Create a Start.ps1 script to start the server and database
Set-Content -Path tools\Start.ps1 -Value @"
# Start MySQL Docker container
docker-compose -f .\db\docker-compose.yml up -d

# Start the server
npm start
"@

# Create a WipeDatabase.ps1 script to drop all tables in the database
Set-Content -Path tools\WipeDatabase.ps1 -Value @"
# Drop all tables in the database
npx prisma migrate reset --force
"@

# Create docker-compose.yml for MongoDB, store in ./db folder
New-Item -Path db -ItemType Directory
Set-Content -Path db\docker-compose.yml -Value @"
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: db
      MYSQL_USER: admin
      MYSQL_PASSWORD: password
    ports:
      - 3306:3306
"@

# Initialize git repository
git init

# Add all files to git
git add .

# Commit changes
git commit -m "Initial commit"

# Output completion message
Write-Host "Node.js project setup complete. MySQL Docker container configured."
