// Comprehensive migration script to create ALL required tables
const pool = require('./db');

async function createAllTables() {
  try {
    console.log('🚀 Creating all required database tables...\n');

    // 1. Create users table
    console.log('1. Creating users table...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        name VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('   ✅ Users table created');

    // 2. Create games table
    console.log('2. Creating games table...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS games (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        code VARCHAR(6) UNIQUE NOT NULL,
        host_name VARCHAR(100) NOT NULL,
        questions_per_player INTEGER DEFAULT 3,
        timer_seconds INTEGER DEFAULT 30,
        status VARCHAR(20) DEFAULT 'lobby',
        current_round INTEGER DEFAULT 0,
        current_question_id INTEGER,
        current_player_index INTEGER DEFAULT 0,
        current_question_index INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('   ✅ Games table created');

    // 3. Create players table
    console.log('3. Creating players table...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS players (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        game_id UUID REFERENCES games(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE SET NULL,
        name VARCHAR(100) NOT NULL,
        is_host BOOLEAN DEFAULT FALSE,
        player_order INTEGER,
        average_score DECIMAL(5,2) DEFAULT 0.0,
        questions_answered INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('   ✅ Players table created');

    // 4. Create game_questions table
    console.log('4. Creating game_questions table...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS game_questions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        game_id UUID REFERENCES games(id) ON DELETE CASCADE,
        question_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        category VARCHAR(50),
        round_number INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('   ✅ Game_questions table created');

    // 5. Create answers table (THIS IS THE MISSING ONE!)
    console.log('5. Creating answers table...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS answers (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        game_id UUID REFERENCES games(id) ON DELETE CASCADE,
        question_id UUID REFERENCES game_questions(id) ON DELETE CASCADE,
        player_id UUID REFERENCES players(id) ON DELETE CASCADE,
        round_number INTEGER NOT NULL,
        answer_text TEXT NOT NULL,
        votes_received INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(question_id, player_id)
      );
    `);
    console.log('   ✅ Answers table created');

    // 6. Create votes table
    console.log('6. Creating votes table...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS votes (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        game_id UUID REFERENCES games(id) ON DELETE CASCADE,
        round_number INTEGER NOT NULL,
        question_id UUID REFERENCES game_questions(id) ON DELETE CASCADE,
        answer_id UUID REFERENCES answers(id) ON DELETE CASCADE,
        voter_id UUID REFERENCES players(id) ON DELETE CASCADE,
        vote_type VARCHAR(20) DEFAULT 'best',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(round_number, question_id, voter_id)
      );
    `);
    console.log('   ✅ Votes table created');

    // 7. Create indexes for performance
    console.log('7. Creating indexes...');
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_games_code ON games(code);`);
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_players_game_id ON players(game_id);`);
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_game_questions_game_id ON game_questions(game_id);`);
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_answers_question_id ON answers(question_id);`);
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_answers_player_id ON answers(player_id);`);
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_answers_round_number ON answers(round_number);`);
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_votes_round_number ON votes(round_number);`);
    await pool.query(`CREATE INDEX IF NOT EXISTS idx_game_questions_round_number ON game_questions(round_number);`);
    console.log('   ✅ Indexes created');

    console.log('\n✅ All tables created successfully!');
    console.log('\n📊 Verifying tables...\n');

    // Verify all tables exist
    const tables = ['users', 'games', 'players', 'game_questions', 'answers', 'votes'];
    for (const table of tables) {
      const result = await pool.query(`
        SELECT EXISTS (
          SELECT FROM information_schema.tables 
          WHERE table_name = $1
        );
      `, [table]);
      
      if (result.rows[0].exists) {
        console.log(`   ✅ ${table} table exists`);
      } else {
        console.log(`   ❌ ${table} table MISSING!`);
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

createAllTables();

