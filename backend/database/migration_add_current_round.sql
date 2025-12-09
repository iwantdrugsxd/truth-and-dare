-- Migration: Add current_round column to games table
-- Run this if you get "column current_round does not exist" error

ALTER TABLE games ADD COLUMN IF NOT EXISTS current_round INTEGER DEFAULT 0;
ALTER TABLE games ADD COLUMN IF NOT EXISTS current_player_index INTEGER DEFAULT 0;
ALTER TABLE games ADD COLUMN IF NOT EXISTS current_question_index INTEGER DEFAULT 0;

-- Verify the columns exist
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'games' 
AND column_name IN ('current_round', 'current_player_index', 'current_question_index');

