# Leans Web Server
The backend server for Leans Website, contains everthing you need to make the leans website fully working.

Features
- Drive for storage files
- Protify project overview
- Larita interactive IA to chat

### Building
For building you will need any sql server, mariadb the recomendation from LeandroTheDev, after that consider creating a database for the server the following API's: 
- ``CREATE DATABASE leans_drive``

Also dont forget to add the permission:
- ``GRANT ALL PRIVILEGES ON leans_drive.* TO 'admin'@'DatabaseIP' IDENTIFIED BY 'secret-password' WITH GRANT OPTION; FLUSH PRIVILEGES``

You also will need the ollama enabled in your system for Larita

### Dependencies
- npm install cors
- npm install express
- npm install mariadb
- npm install sequelize
- npm install multer