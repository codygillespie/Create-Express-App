# Node.js Project Setup with Express, TypeScript, Prisma, and MySQL

This README outlines the usage of a PowerShell script designed to automate the setup of a Node.js project with Express, TypeScript, Prisma, dotenv, and a Dockerized MySQL database. The project includes necessary configurations for development, including a `.gitignore` file, `vercel.json`, and a basic `docker-compose.yml` for MySQL.

## Prerequisites

Before running the script, make sure you have the following installed on your system:
- Node.js (v14 or higher)
- npm (comes with Node.js)
- Docker Desktop (for MySQL containerization)
- PowerShell

## Quick Start

**Run the Script**: Execute the script by typing `./CreateExpressApp.ps1 -projectName <project-name>` in your terminal. Replace `<project-name>` with the name of your project.

## What Does the Script Do?

Upon execution, the script will:
- Create a new directory for your Node.js project.
- Initialize a new npm project and install necessary dependencies, including Express, dotenv, and Prisma.
- Set up TypeScript for development.
- Configure Prisma to connect to MySQL.
- Create initial files such as `index.ts` for a basic Express server, `.env` for environment variables, and `.gitignore` to exclude node modules and other non-essential files.
- Add a `README.md` file to your project directory with basic project information and setup instructions.
- Create a `vercel.json` for deploying with Vercel if needed.
- Set up a `docker-compose.yml` file to run a MySQL database locally in a Docker container. This will use a simple username and password for authentication **DO NOT USE IN PRODUCTION**.
- Create a `tools` directory with powershell scripts to start the server and MySQL container and to wipe the database.

## Running Your Project

After setup:
- Run `docker-compose up -d` to start your MySQL database.
- Navigate to your project directory and run `npm install` to install all dependencies.
- Use `npm start` to run your Express server.

## Stopping the MySQL Container

To stop and remove the MySQL container, you can use:
```bash
docker-compose down
