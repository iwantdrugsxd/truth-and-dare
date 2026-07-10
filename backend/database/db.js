const { Pool } = require('pg');
require('dotenv').config();

const url = process.env.DATABASE_URL || '';
const needsSsl = process.env.NODE_ENV === 'production' || /sslmode=require|neon\.tech/.test(url);

const pool = new Pool({
  connectionString: url,
  ssl: needsSsl ? { rejectUnauthorized: false } : false,
  max: process.env.VERCEL ? 1 : 10, // serverless: one connection per warm instance, not a big pool
});

pool.on('error', (err) => {
  // Don't crash the process on an idle client error — in serverless the
  // process is reused across invocations, so exiting here would take down
  // unrelated in-flight requests for no reason.
  console.error('Unexpected error on idle client', err);
});

module.exports = pool;


