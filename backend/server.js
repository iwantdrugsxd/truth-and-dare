const express = require('express');
const cors = require('cors');
const pool = require('./database/db');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;

// CORS configuration - allow all origins for ngrok/Vercel
app.use(cors({
  origin: '*', // Allow all origins (ngrok, Vercel, localhost)
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'ngrok-skip-browser-warning', 'X-Requested-With'],
  credentials: false,
  preflightContinue: false,
  optionsSuccessStatus: 204
}));

// Handle preflight requests explicitly
app.options('*', cors());

app.use(express.json());

// JWT Secret (in production, use environment variable)
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Load questions once at startup
let questionsData = { questions: [] };
try {
  questionsData = require('./data/questions.json');
  console.log(`Loaded ${questionsData.questions.length} questions`);
} catch (e) {
  console.warn('Could not load questions.json, using fallback');
}

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Generate random game code
function generateGameCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

// Create game (requires authentication)
app.post('/api/games/create', authenticateToken, async (req, res) => {
  try {
    const { questionsPerPlayer = 3, timerSeconds = 30 } = req.body;
    const userId = req.user.userId;
    
    // Get user name from database
    const userResult = await pool.query('SELECT name FROM users WHERE id = $1', [userId]);
    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    const hostName = userResult.rows[0].name;

    let code = generateGameCode();
    let codeExists = true;
    
    // Ensure unique code
    while (codeExists) {
      const result = await pool.query('SELECT id FROM games WHERE code = $1', [code]);
      if (result.rows.length === 0) {
        codeExists = false;
      } else {
        code = generateGameCode();
      }
    }

    const gameResult = await pool.query(
      'INSERT INTO games (code, host_name, questions_per_player, timer_seconds) VALUES ($1, $2, $3, $4) RETURNING *',
      [code, hostName, questionsPerPlayer, timerSeconds]
    );

    const game = gameResult.rows[0];

    // Create host player (link to user)
    const playerResult = await pool.query(
      'INSERT INTO players (game_id, name, is_host, player_order, user_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [game.id, hostName, true, 0, userId]
    );

    res.json({
      game: {
        id: game.id,
        code: game.code,
        hostName: game.host_name,
        questionsPerPlayer: game.questions_per_player,
        timerSeconds: game.timer_seconds,
        status: game.status,
      },
      player: playerResult.rows[0],
    });
  } catch (error) {
    console.error('Error creating game:', error);
    res.status(500).json({ error: 'Failed to create game' });
  }
});

// Join game (requires authentication)
app.post('/api/games/join', authenticateToken, async (req, res) => {
  try {
    const { code } = req.body;
    const userId = req.user.userId;

    if (!code) {
      return res.status(400).json({ error: 'Game code is required' });
    }
    const cleanCode = code.toString().trim().toUpperCase().replace(/\s+/g, '');
    
    console.log(`[JOIN] User ${userId} attempting to join with code: "${code}" -> cleaned: "${cleanCode}"`);
    
    // Get user name from database
    const userResult = await pool.query('SELECT name FROM users WHERE id = $1', [userId]);
    if (userResult.rows.length === 0) {
      console.log(`[JOIN] User ${userId} not found in database`);
      return res.status(404).json({ error: 'User not found' });
    }
    const playerName = userResult.rows[0].name;

    // Find game - try exact match first, then case-insensitive
    let gameResult = await pool.query('SELECT * FROM games WHERE code = $1', [cleanCode]);
    
    // If not found, try case-insensitive search
    if (gameResult.rows.length === 0) {
      gameResult = await pool.query('SELECT * FROM games WHERE UPPER(TRIM(code)) = $1', [cleanCode]);
    }
    
    // Log all active games for debugging
    if (gameResult.rows.length === 0) {
      const allGames = await pool.query('SELECT code, status FROM games WHERE status = $1 ORDER BY created_at DESC LIMIT 10', ['lobby']);
      console.log(`[JOIN] Game not found. Active lobby games:`, allGames.rows.map(g => g.code));
      return res.status(404).json({ error: `Game not found. Code "${cleanCode}" does not exist.` });
    }

    const game = gameResult.rows[0];

    if (game.status !== 'lobby') {
      return res.status(400).json({ error: 'Game has already started' });
    }

    // Check if user already joined this game
    const existingPlayer = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [game.id, userId]
    );

    if (existingPlayer.rows.length > 0) {
      return res.status(400).json({ error: 'You have already joined this game' });
    }

    // Get current player count for order
    const playerCountResult = await pool.query(
      'SELECT COUNT(*) as count FROM players WHERE game_id = $1',
      [game.id]
    );
    const playerOrder = parseInt(playerCountResult.rows[0].count);

    // Create player (link to user)
    const playerResult = await pool.query(
      'INSERT INTO players (game_id, user_id, name, is_host, player_order) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [game.id, userId, playerName, false, playerOrder]
    );

    res.json({
      game: {
        id: game.id,
        code: game.code,
        hostName: game.host_name,
        questionsPerPlayer: game.questions_per_player,
        timerSeconds: game.timer_seconds,
        status: game.status,
      },
      player: playerResult.rows[0],
    });
  } catch (error) {
    console.error('Error joining game:', error);
    res.status(500).json({ error: 'Failed to join game' });
  }
});

// Get game state (requires authentication)
app.get('/api/games/:gameId', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    // Ensure user is part of this game
    const userId = req.user.userId;
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    // Get players ordered by player_order (or created_at if no order set yet)
    const playersResult = await pool.query(
      'SELECT * FROM players WHERE game_id = $1 ORDER BY COALESCE(player_order, 999), created_at',
      [gameId]
    );

    // Get current ratings if in rating phase
    let ratings = [];
    if (game.status === 'rating') {
      const currentQuestionResult = await pool.query(
        'SELECT id FROM game_questions WHERE game_id = $1 AND player_id = $2 AND question_number = $3',
        [gameId, playersResult.rows[game.current_player_index]?.id, game.current_question_index + 1]
      );
      if (currentQuestionResult.rows.length > 0) {
        const currentQuestionId = currentQuestionResult.rows[0].id;
        const ratingsResult = await pool.query(
          'SELECT rater_id, rating FROM ratings WHERE question_id = $1',
          [currentQuestionId]
        );
        ratings = ratingsResult.rows;
      }
    }

    res.json({
      game: {
        id: game.id,
        code: game.code,
        hostName: game.host_name,
        questionsPerPlayer: game.questions_per_player,
        timerSeconds: game.timer_seconds,
        status: game.status,
        currentRound: game.current_round ?? 0,
        currentPlayerIndex: game.current_player_index ?? 0, // Keep for backward compatibility
        currentQuestionIndex: game.current_question_index ?? 0, // Keep for backward compatibility
      },
      players: playersResult.rows,
      ratings: ratings,
    });
  } catch (error) {
    console.error('Error getting game:', error);
    res.status(500).json({ error: 'Failed to get game' });
  }
});

// Start game (host only, requires authentication)
app.post('/api/games/:gameId/start', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    console.log(`[START GAME] User ${userId} attempting to start game ${gameId}`);

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    
    if (gameResult.rows.length === 0) {
      console.log(`[START GAME] Game ${gameId} not found`);
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    // Verify user is the host
    const hostCheck = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2 AND is_host = true',
      [gameId, userId]
    );
    
    if (hostCheck.rows.length === 0) {
      console.log(`[START GAME] User ${userId} is not the host of game ${gameId}`);
      return res.status(403).json({ error: 'Only the host can start the game' });
    }

    if (game.status !== 'lobby') {
      console.log(`[START GAME] Game ${gameId} already started, status: ${game.status}`);
      return res.status(400).json({ error: 'Game has already started' });
    }

    // Get players and shuffle order
    const playersResult = await pool.query(
      'SELECT * FROM players WHERE game_id = $1 ORDER BY COALESCE(player_order, 999), created_at',
      [gameId]
    );

    if (playersResult.rows.length < 2) {
      console.log(`[START GAME] Not enough players: ${playersResult.rows.length}`);
      return res.status(400).json({ error: 'Need at least 2 players to start' });
    }

    console.log(`[START GAME] Shuffling ${playersResult.rows.length} players`);

    // Shuffle player order
    const players = [...playersResult.rows];
    for (let i = players.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [players[i], players[j]] = [players[j], players[i]];
    }

    // Update player orders
    for (let i = 0; i < players.length; i++) {
      await pool.query(
        'UPDATE players SET player_order = $1 WHERE id = $2',
        [i, players[i].id]
      );
    }

    console.log(`[START GAME] Updating game status to answering`);

    // Update game status to answering (Psych-style: all players answer same question)
    await pool.query(
      'UPDATE games SET status = $1, current_round = 1, current_question_id = NULL WHERE id = $2',
      ['answering', gameId]
    );

    console.log(`[START GAME] Game ${gameId} started successfully`);

    res.json({ success: true });
  } catch (error) {
    console.error('[START GAME] Error starting game:', error);
    console.error('[START GAME] Stack:', error.stack);
    res.status(500).json({ error: `Failed to start game: ${error.message}` });
  }
});

// Get current question (requires authentication)
app.get('/api/games/:gameId/question', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    // Ensure user is part of this game
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    // Psych-style: Check if game is finished
    if (game.current_round > game.questions_per_player) {
      return res.json({ gameFinished: true });
    }

    // Get or create question for current round (Psych-style: one question per round for all)
    let question;
    const existingQuestion = await pool.query(
      'SELECT * FROM game_questions WHERE game_id = $1 AND round_number = $2',
      [gameId, game.current_round]
    );

    if (existingQuestion.rows.length > 0) {
      question = existingQuestion.rows[0];
    } else {
      // Get random question from questions data
      const allQuestions = questionsData.questions || [];
      
      if (allQuestions.length === 0) {
        return res.status(500).json({ error: 'No questions available' });
      }

      // Get random question
      const randomIndex = Math.floor(Math.random() * allQuestions.length);
      const selectedQuestion = allQuestions[randomIndex];
      
      const questionResult = await pool.query(
        'INSERT INTO game_questions (game_id, question_id, question_text, category, round_number) VALUES ($1, $2, $3, $4, $5) RETURNING *',
        [gameId, selectedQuestion.id, selectedQuestion.question, selectedQuestion.category, game.current_round]
      );
      question = questionResult.rows[0];
    }

    const playerId = playerInGame.rows[0].id;

    // Get player's answer if exists
    let existingAnswer = null;
    const answerResult = await pool.query(
      'SELECT answer_text FROM answers WHERE question_id = $1 AND player_id = $2',
      [question.id, playerId]
    );
    if (answerResult.rows.length > 0) {
      existingAnswer = answerResult.rows[0].answer_text;
    }

    res.json({
      question: {
        id: question.id,
        questionId: question.question_id,
        question: question.question_text,
        category: question.category,
      },
      roundNumber: game.current_round,
      totalRounds: game.questions_per_player,
      existingAnswer: existingAnswer,
    });
  } catch (error) {
    console.error('Error getting question:', error);
    res.status(500).json({ error: 'Failed to get question' });
  }
});

// Submit answer (requires authentication)
app.post('/api/games/:gameId/answer', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { questionId, answerText } = req.body;
    const userId = req.user.userId;

    if (!questionId || !answerText || !answerText.trim()) {
      return res.status(400).json({ error: 'Question ID and answer text are required' });
    }

    // Ensure user is part of this game
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    const playerId = playerInGame.rows[0].id;

    // Get game and question info
    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }
    const game = gameResult.rows[0];

    const questionResult = await pool.query('SELECT * FROM game_questions WHERE id = $1', [questionId]);
    if (questionResult.rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }
    const question = questionResult.rows[0];

    // Check if answer already exists
    const existing = await pool.query(
      'SELECT id FROM answers WHERE question_id = $1 AND player_id = $2',
      [questionId, playerId]
    );

    if (existing.rows.length > 0) {
      // Update existing answer
      await pool.query(
        'UPDATE answers SET answer_text = $1 WHERE question_id = $2 AND player_id = $3',
        [answerText.trim(), questionId, playerId]
      );
    } else {
      // Insert new answer (Psych-style: include round_number)
      await pool.query(
        'INSERT INTO answers (game_id, question_id, player_id, round_number, answer_text) VALUES ($1, $2, $3, $4, $5)',
        [gameId, questionId, playerId, game.current_round, answerText.trim()]
      );
    }

    // Check if all players have answered (Psych-style: move to reveal when all done)
    const playersResult = await pool.query(
      'SELECT COUNT(*) as total FROM players WHERE game_id = $1',
      [gameId]
    );
    const totalPlayers = parseInt(playersResult.rows[0].total);

    const answersResult = await pool.query(
      'SELECT COUNT(DISTINCT player_id) as answered FROM answers WHERE question_id = $1',
      [questionId]
    );
    const answeredCount = parseInt(answersResult.rows[0].answered);

    // Auto-move to reveal phase when all players answered
    if (answeredCount >= totalPlayers && game.status === 'answering') {
      await pool.query(
        'UPDATE games SET status = $1 WHERE id = $2',
        ['reveal', gameId]
      );
    }

    res.json({ success: true, allAnswered: answeredCount >= totalPlayers });
  } catch (error) {
    console.error('Error submitting answer:', error);
    res.status(500).json({ error: 'Failed to submit answer' });
  }
});

// Get answers for reveal (Psych-style: anonymous, shuffled) (requires authentication)
app.get('/api/games/:gameId/reveal', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    // Ensure user is part of this game
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }
    const game = gameResult.rows[0];

    // Get question for current round
    const questionResult = await pool.query(
      'SELECT * FROM game_questions WHERE game_id = $1 AND round_number = $2',
      [gameId, game.current_round]
    );
    if (questionResult.rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }
    const question = questionResult.rows[0];

    // Get all answers for this round (ANONYMOUS - no player names)
    // Shuffle for anonymity
    const answersResult = await pool.query(
      `SELECT a.id, a.answer_text
       FROM answers a
       WHERE a.question_id = $1
       ORDER BY RANDOM()`,
      [question.id]
    );

    // Status stays as 'reveal' - frontend will manually transition to voting when ready

    res.json({
      question: {
        id: question.id,
        question: question.question_text,
        category: question.category,
      },
      answers: answersResult.rows, // Anonymous answers
    });
  } catch (error) {
    console.error('Error getting reveal answers:', error);
    res.status(500).json({ error: 'Failed to get reveal answers' });
  }
});

// Get answers for a question (for rating screen) - DEPRECATED, use /reveal instead
app.get('/api/games/:gameId/question/:questionId/answers', authenticateToken, async (req, res) => {
  try {
    const { gameId, questionId } = req.params;
    const userId = req.user.userId;

    // Ensure user is part of this game
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    // Get all answers for this question
    const answersResult = await pool.query(
      `SELECT a.id, a.answer_text, a.player_id, p.name as player_name
       FROM answers a
       JOIN players p ON a.player_id = p.id
       WHERE a.question_id = $1
       ORDER BY a.created_at`,
      [questionId]
    );

    res.json({ answers: answersResult.rows });
  } catch (error) {
    console.error('Error getting answers:', error);
    res.status(500).json({ error: 'Failed to get answers' });
  }
});

// Submit rating
app.post('/api/games/:gameId/rate', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { questionId, playerId, raterId, rating } = req.body;

    if (!questionId || !playerId || !raterId || !rating) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (rating < 1 || rating > 10) {
      return res.status(400).json({ error: 'Rating must be between 1 and 10' });
    }

    // Check if already rated
    const existing = await pool.query(
      'SELECT id FROM ratings WHERE question_id = $1 AND rater_id = $2',
      [questionId, raterId]
    );

    if (existing.rows.length > 0) {
      await pool.query(
        'UPDATE ratings SET rating = $1 WHERE question_id = $2 AND rater_id = $3',
        [rating, questionId, raterId]
      );
    } else {
      await pool.query(
        'INSERT INTO ratings (game_id, question_id, player_id, rater_id, rating) VALUES ($1, $2, $3, $4, $5)',
        [gameId, questionId, playerId, raterId, rating]
      );
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error submitting rating:', error);
    res.status(500).json({ error: 'Failed to submit rating' });
  }
});

// Advance to voting phase (requires authentication)
app.post('/api/games/:gameId/voting', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    // Ensure user is part of this game
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }
    const game = gameResult.rows[0];

    // Only advance if currently in reveal phase
    if (game.status === 'reveal') {
      await pool.query(
        'UPDATE games SET status = $1 WHERE id = $2',
        ['voting', gameId]
      );
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error advancing to voting:', error);
    res.status(500).json({ error: 'Failed to advance to voting' });
  }
});

// Submit vote (Psych-style: vote for best answer) (requires authentication)
app.post('/api/games/:gameId/vote', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;
    const { answerId } = req.body;

    if (!answerId) {
      return res.status(400).json({ error: 'Answer ID is required' });
    }

    // Ensure user is part of this game
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    const voterId = playerInGame.rows[0].id;

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }
    const game = gameResult.rows[0];

    // Verify answer exists and belongs to this game/round
    const answerResult = await pool.query(
      'SELECT * FROM answers WHERE id = $1 AND game_id = $2',
      [answerId, gameId]
    );
    if (answerResult.rows.length === 0) {
      return res.status(404).json({ error: 'Answer not found' });
    }
    const answer = answerResult.rows[0];

    // Check if player already voted this round
    const existingVote = await pool.query(
      'SELECT id FROM votes WHERE game_id = $1 AND round_number = $2 AND voter_id = $3',
      [gameId, game.current_round, voterId]
    );

    if (existingVote.rows.length > 0) {
      // Update existing vote
      await pool.query(
        'UPDATE votes SET answer_id = $1 WHERE id = $2',
        [answerId, existingVote.rows[0].id]
      );
    } else {
      // Insert new vote
      await pool.query(
        'INSERT INTO votes (game_id, round_number, question_id, answer_id, voter_id, vote_type) VALUES ($1, $2, $3, $4, $5, $6)',
        [gameId, game.current_round, answer.question_id, answerId, voterId, 'best']
      );
    }

    // Check if all players have voted (move to results phase)
    const playersResult = await pool.query(
      'SELECT COUNT(*) as total FROM players WHERE game_id = $1',
      [gameId]
    );
    const totalPlayers = parseInt(playersResult.rows[0].total);

    const votesResult = await pool.query(
      'SELECT COUNT(DISTINCT voter_id) as voted FROM votes WHERE game_id = $1 AND round_number = $2',
      [gameId, game.current_round]
    );
    const votedCount = parseInt(votesResult.rows[0].voted);

    // Auto-move to results phase when all players voted
    if (votedCount >= totalPlayers && game.status === 'voting') {
      await pool.query(
        'UPDATE games SET status = $1 WHERE id = $2',
        ['results', gameId]
      );
    }

    res.json({ success: true, allVoted: votedCount >= totalPlayers });
  } catch (error) {
    console.error('Error submitting vote:', error);
    res.status(500).json({ error: 'Failed to submit vote' });
  }
});

// Get round results (Psych-style: votes and points) (requires authentication)
app.get('/api/games/:gameId/results', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    // Ensure user is part of this game
    const playerInGame = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }
    const game = gameResult.rows[0];

    // Get question for current round
    const questionResult = await pool.query(
      'SELECT * FROM game_questions WHERE game_id = $1 AND round_number = $2',
      [gameId, game.current_round]
    );
    if (questionResult.rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }
    const question = questionResult.rows[0];

    // Get all answers with vote counts
    const answersResult = await pool.query(
      `SELECT a.id, a.answer_text, a.player_id, p.name as player_name,
              COUNT(v.id) as votes
       FROM answers a
       JOIN players p ON a.player_id = p.id
       LEFT JOIN votes v ON a.id = v.answer_id AND v.round_number = $2
       WHERE a.question_id = $1
       GROUP BY a.id, a.answer_text, a.player_id, p.name
       ORDER BY votes DESC`,
      [question.id, game.current_round]
    );

    // Award points: Psych-style (1 point per vote)
    for (const answer of answersResult.rows) {
      const votes = parseInt(answer.votes) || 0;
      if (votes > 0) {
        // Update player's total score (add votes as points)
        await pool.query(
          `UPDATE players 
           SET average_score = average_score + $1,
               questions_answered = questions_answered + 1
           WHERE id = $2`,
          [votes, answer.player_id]
        );
      }
    }

    // Get updated player scores
    const playersResult = await pool.query(
      'SELECT id, name, average_score, questions_answered FROM players WHERE game_id = $1 ORDER BY average_score DESC',
      [gameId]
    );

    res.json({
      question: {
        id: question.id,
        question: question.question_text,
        category: question.category,
      },
      roundNumber: game.current_round,
      results: answersResult.rows.map(a => ({
        answerId: a.id,
        answerText: a.answer_text,
        playerName: a.player_name,
        votes: parseInt(a.votes) || 0,
      })),
      players: playersResult.rows.map(p => ({
        id: p.id,
        name: p.name,
        score: parseFloat(p.average_score) || 0,
        questionsAnswered: p.questions_answered || 0,
      })),
    });
  } catch (error) {
    console.error('Error getting round results:', error);
    res.status(500).json({ error: 'Failed to get round results' });
  }
});

// Next round (Psych-style: move to next round or end game) (requires authentication)
app.post('/api/games/:gameId/next', authenticateToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    // Ensure user is part of this game and is host
    const playerInGame = await pool.query(
      'SELECT id, is_host FROM players WHERE game_id = $1 AND user_id = $2',
      [gameId, userId]
    );
    if (playerInGame.rows.length === 0) {
      return res.status(403).json({ error: 'You are not part of this game' });
    }
    if (!playerInGame.rows[0].is_host) {
      return res.status(403).json({ error: 'Only the host can advance rounds' });
    }

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    // Psych-style: Move to next round
    const nextRound = game.current_round + 1;

    // Check if game is finished
    if (nextRound > game.questions_per_player) {
      await pool.query(
        'UPDATE games SET status = $1 WHERE id = $2',
        ['finished', gameId]
      );
      res.json({ gameFinished: true });
    } else {
      // Move to next round (answering phase)
      await pool.query(
        'UPDATE games SET status = $1, current_round = $2 WHERE id = $3',
        ['answering', nextRound, gameId]
      );
      res.json({ success: true, nextRound: nextRound });
    }
  } catch (error) {
    console.error('Error moving to next round:', error);
    res.status(500).json({ error: 'Failed to move to next round' });
  }
});

// ==================== AUTHENTICATION ENDPOINTS ====================

// Sign up
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Email, password, and name are required' });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    // Check if user already exists
    const existingUser = await pool.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const result = await pool.query(
      'INSERT INTO users (email, password_hash, name) VALUES ($1, $2, $3) RETURNING id, email, name, created_at',
      [email.toLowerCase(), passwordHash, name]
    );

    const user = result.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error('Error signing up:', error);
    res.status(500).json({ error: 'Failed to create account' });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user
    const result = await pool.query(
      'SELECT id, email, password_hash, name FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = result.rows[0];

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error('Error logging in:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

// Verify token / Get current user
app.get('/api/auth/me', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, name, created_at FROM users WHERE id = $1',
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      user: result.rows[0],
    });
  } catch (error) {
    console.error('Error getting user:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

