-- PARTIZO Database Schema

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Games table
CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(6) UNIQUE NOT NULL,
    host_name VARCHAR(100) NOT NULL,
    questions_per_player INTEGER DEFAULT 3,
    timer_seconds INTEGER DEFAULT 30,
    status VARCHAR(20) DEFAULT 'lobby', -- lobby, answering, reveal, voting, results, finished
    current_round INTEGER DEFAULT 0,
    current_question_id INTEGER, -- Question ID from JSON
    current_player_index INTEGER DEFAULT 0, -- Keep for backward compatibility
    current_question_index INTEGER DEFAULT 0, -- Keep for backward compatibility
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Players table
CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    is_host BOOLEAN DEFAULT FALSE,
    player_order INTEGER,
    total_score INTEGER DEFAULT 0, -- Total score (votes × 10)
    average_score DECIMAL(5,2) DEFAULT 0.0,
    questions_answered INTEGER DEFAULT 0,
    is_ready BOOLEAN DEFAULT FALSE, -- Ready for next round
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Questions table (store used questions per round)
CREATE TABLE IF NOT EXISTS game_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    category VARCHAR(50),
    round_number INTEGER NOT NULL, -- Round 1, 2, 3, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Votes table (Psych-style: vote for best answer)
CREATE TABLE IF NOT EXISTS votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL,
    question_id UUID REFERENCES game_questions(id) ON DELETE CASCADE,
    answer_id UUID REFERENCES answers(id) ON DELETE CASCADE, -- Answer being voted for
    voter_id UUID REFERENCES players(id) ON DELETE CASCADE, -- Player who voted
    vote_type VARCHAR(20) DEFAULT 'best', -- best, funniest, spiciest
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(round_number, question_id, voter_id) -- One vote per player per round
);

-- Answers table (store player answers per round - Psych style)
CREATE TABLE IF NOT EXISTS answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    question_id UUID REFERENCES game_questions(id) ON DELETE CASCADE,
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL,
    answer_text TEXT NOT NULL,
    votes_received INTEGER DEFAULT 0, -- Number of votes this answer got
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(question_id, player_id) -- One answer per question per player
);

-- Keep ratings table for backward compatibility, but we'll use votes primarily

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_games_code ON games(code);
CREATE INDEX IF NOT EXISTS idx_players_game_id ON players(game_id);
CREATE INDEX IF NOT EXISTS idx_game_questions_game_id ON game_questions(game_id);
CREATE INDEX IF NOT EXISTS idx_ratings_question_id ON ratings(question_id);
CREATE INDEX IF NOT EXISTS idx_answers_question_id ON answers(question_id);
CREATE INDEX IF NOT EXISTS idx_answers_player_id ON answers(player_id);
CREATE INDEX IF NOT EXISTS idx_answers_round_number ON answers(round_number);
CREATE INDEX IF NOT EXISTS idx_votes_round_number ON votes(round_number);
CREATE INDEX IF NOT EXISTS idx_game_questions_round_number ON game_questions(round_number);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to auto-update updated_at
CREATE TRIGGER update_games_updated_at BEFORE UPDATE ON games
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

