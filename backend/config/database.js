const mysql = require('mysql2/promise');
require('dotenv').config();

// Support both custom DB_* vars and Railway's injected MYSQL* vars
const pool = mysql.createPool({
  host:     process.env.DB_HOST     || process.env.MYSQLHOST     || 'localhost',
  port:     process.env.DB_PORT     || process.env.MYSQLPORT     || 3306,
  user:     process.env.DB_USER     || process.env.MYSQLUSER     || 'root',
  password: process.env.DB_PASSWORD || process.env.MYSQLPASSWORD || '',
  database: process.env.DB_NAME     || process.env.MYSQLDATABASE || 'tournament_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: '+00:00',
});

module.exports = pool;
