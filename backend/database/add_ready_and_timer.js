// Migration: Add is_ready, total_score, and timer_start_time columns
const pool = require('./db');

async function runMigration() {
  try {
    console.log('Running migration: Adding ready system and timer sync...\n');
    
    // Add is_ready to players
    await pool.query(`
      ALTER TABLE players 
      ADD COLUMN IF NOT EXISTS is_ready BOOLEAN DEFAULT FALSE;
    `);
    console.log('✅ Added is_ready to players table');
    
    // Add total_score to players (if doesn't exist)
    await pool.query(`
      ALTER TABLE players 
      ADD COLUMN IF NOT EXISTS total_score INTEGER DEFAULT 0;
    `);
    console.log('✅ Added total_score to players table');
    
    // Add timer_start_time to games
    await pool.query(`
      ALTER TABLE games 
      ADD COLUMN IF NOT EXISTS timer_start_time TIMESTAMP;
    `);
    console.log('✅ Added timer_start_time to games table');
    
    // Migrate existing average_score * questions_answered to total_score if needed
    await pool.query(`
      UPDATE players 
      SET total_score = COALESCE(CAST(average_score * questions_answered AS INTEGER), 0)
      WHERE total_score = 0 AND questions_answered > 0;
    `);
    console.log('✅ Migrated existing scores to total_score');
    
    console.log('\n✅ Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

runMigration();

