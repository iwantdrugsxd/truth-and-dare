// Quick migration script to add missing columns to games table
const { Pool } = require('pg');
const pool = require('./db');

async function runMigration() {
  try {
    console.log('Running migration: Adding current_round column to games table...');
    
    // Add current_round column if it doesn't exist
    await pool.query(`
      ALTER TABLE games 
      ADD COLUMN IF NOT EXISTS current_round INTEGER DEFAULT 0;
    `);
    
    // Add current_player_index column if it doesn't exist (for backward compatibility)
    await pool.query(`
      ALTER TABLE games 
      ADD COLUMN IF NOT EXISTS current_player_index INTEGER DEFAULT 0;
    `);
    
    // Add current_question_index column if it doesn't exist (for backward compatibility)
    await pool.query(`
      ALTER TABLE games 
      ADD COLUMN IF NOT EXISTS current_question_index INTEGER DEFAULT 0;
    `);
    
    // Add current_question_id column if it doesn't exist
    await pool.query(`
      ALTER TABLE games 
      ADD COLUMN IF NOT EXISTS current_question_id INTEGER;
    `);
    
    console.log('✅ Migration completed successfully!');
    console.log('Columns added: current_round, current_player_index, current_question_index, current_question_id');
    
    // Verify
    const result = await pool.query(`
      SELECT column_name, data_type, column_default 
      FROM information_schema.columns 
      WHERE table_name = 'games' 
      AND column_name IN ('current_round', 'current_player_index', 'current_question_index', 'current_question_id')
      ORDER BY column_name;
    `);
    
    console.log('\n✅ Verified columns:');
    result.rows.forEach(row => {
      console.log(`  - ${row.column_name}: ${row.data_type} (default: ${row.column_default})`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

runMigration();

