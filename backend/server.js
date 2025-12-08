const express = require('express');
const cors = require('cors');
const pool = require('./database/db');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Generate random game code
function generateGameCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

// Create game
app.post('/api/games/create', async (req, res) => {
  try {
    const { hostName, questionsPerPlayer = 3, timerSeconds = 30 } = req.body;
    
    if (!hostName) {
      return res.status(400).json({ error: 'Host name is required' });
    }

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

    // Create host player
    const playerResult = await pool.query(
      'INSERT INTO players (game_id, name, is_host, player_order) VALUES ($1, $2, $3, $4) RETURNING *',
      [game.id, hostName, true, 0]
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

// Join game
app.post('/api/games/join', async (req, res) => {
  try {
    const { code, playerName } = req.body;

    if (!code || !playerName) {
      return res.status(400).json({ error: 'Code and player name are required' });
    }

    // Find game
    const gameResult = await pool.query('SELECT * FROM games WHERE code = $1', [code.toUpperCase()]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    if (game.status !== 'lobby') {
      return res.status(400).json({ error: 'Game has already started' });
    }

    // Check if name already exists
    const existingPlayer = await pool.query(
      'SELECT id FROM players WHERE game_id = $1 AND LOWER(name) = LOWER($2)',
      [game.id, playerName]
    );

    if (existingPlayer.rows.length > 0) {
      return res.status(400).json({ error: 'Name already taken in this game' });
    }

    // Get current player count for order
    const playerCountResult = await pool.query(
      'SELECT COUNT(*) as count FROM players WHERE game_id = $1',
      [game.id]
    );
    const playerOrder = parseInt(playerCountResult.rows[0].count);

    // Create player
    const playerResult = await pool.query(
      'INSERT INTO players (game_id, name, is_host, player_order) VALUES ($1, $2, $3, $4) RETURNING *',
      [game.id, playerName, false, playerOrder]
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

// Get game state
app.get('/api/games/:gameId', async (req, res) => {
  try {
    const { gameId } = req.params;

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    const playersResult = await pool.query(
      'SELECT * FROM players WHERE game_id = $1 ORDER BY player_order',
      [gameId]
    );

    res.json({
      game: {
        id: game.id,
        code: game.code,
        hostName: game.host_name,
        questionsPerPlayer: game.questions_per_player,
        timerSeconds: game.timer_seconds,
        status: game.status,
        currentPlayerIndex: game.current_player_index,
        currentQuestionIndex: game.current_question_index,
      },
      players: playersResult.rows,
    });
  } catch (error) {
    console.error('Error getting game:', error);
    res.status(500).json({ error: 'Failed to get game' });
  }
});

// Start game
app.post('/api/games/:gameId/start', async (req, res) => {
  try {
    const { gameId } = req.params;

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    if (game.status !== 'lobby') {
      return res.status(400).json({ error: 'Game has already started' });
    }

    // Get players and shuffle order
    const playersResult = await pool.query(
      'SELECT * FROM players WHERE game_id = $1 ORDER BY player_order',
      [gameId]
    );

    if (playersResult.rows.length < 2) {
      return res.status(400).json({ error: 'Need at least 2 players to start' });
    }

    // Shuffle player order
    const players = playersResult.rows;
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

    // Update game status
    await pool.query(
      'UPDATE games SET status = $1, current_player_index = 0, current_question_index = 0 WHERE id = $2',
      ['playing', gameId]
    );

    res.json({ success: true });
  } catch (error) {
    console.error('Error starting game:', error);
    res.status(500).json({ error: 'Failed to start game' });
  }
});

// Get current question
app.get('/api/games/:gameId/question', async (req, res) => {
  try {
    const { gameId } = req.params;

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    // Get current player
    const playersResult = await pool.query(
      'SELECT * FROM players WHERE game_id = $1 ORDER BY player_order',
      [gameId]
    );

    if (game.current_player_index >= playersResult.rows.length) {
      return res.json({ gameFinished: true });
    }

    const currentPlayer = playersResult.rows[game.current_player_index];

    // Check if question already exists for this player/question number
    const existingQuestion = await pool.query(
      'SELECT * FROM game_questions WHERE game_id = $1 AND player_id = $2 AND question_number = $3',
      [gameId, currentPlayer.id, game.current_question_index + 1]
    );

    let question;
    if (existingQuestion.rows.length > 0) {
      question = existingQuestion.rows[0];
    } else {
      // Get random question from questions data (loaded at startup)
      const allQuestions = questionsData.questions || [];
      
      if (allQuestions.length === 0) {
        // Fallback if questions file not found
        const questionId = Math.floor(Math.random() * 200) + 1;
        const questionText = `Question ${questionId}`;
        const category = 'Spicy';
        
        const questionResult = await pool.query(
          'INSERT INTO game_questions (game_id, player_id, question_id, question_text, category, question_number) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
          [gameId, currentPlayer.id, questionId, questionText, category, game.current_question_index + 1]
        );
        question = questionResult.rows[0];
      } else {
        // Get random question
        const randomIndex = Math.floor(Math.random() * allQuestions.length);
        const selectedQuestion = allQuestions[randomIndex];
        
        const questionResult = await pool.query(
          'INSERT INTO game_questions (game_id, player_id, question_id, question_text, category, question_number) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
          [gameId, currentPlayer.id, selectedQuestion.id, selectedQuestion.question, selectedQuestion.category, game.current_question_index + 1]
        );
        question = questionResult.rows[0];
      }
    }

    res.json({
      question: {
        id: question.id,
        questionId: question.question_id,
        question: question.question_text,
        category: question.category,
      },
      currentPlayer: {
        id: currentPlayer.id,
        name: currentPlayer.name,
      },
      questionNumber: game.current_question_index + 1,
      totalQuestions: game.questions_per_player,
    });
  } catch (error) {
    console.error('Error getting question:', error);
    res.status(500).json({ error: 'Failed to get question' });
  }
});

// Submit rating
app.post('/api/games/:gameId/rate', async (req, res) => {
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

// Finish question (move to next)
app.post('/api/games/:gameId/next', async (req, res) => {
  try {
    const { gameId } = req.params;

    const gameResult = await pool.query('SELECT * FROM games WHERE id = $1', [gameId]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = gameResult.rows[0];

    // Get current player
    const playersResult = await pool.query(
      'SELECT * FROM players WHERE game_id = $1 ORDER BY player_order',
      [gameId]
    );

    const currentPlayer = playersResult.rows[game.current_player_index];

    // Get current question
    const questionResult = await pool.query(
      'SELECT * FROM game_questions WHERE game_id = $1 AND player_id = $2 AND question_number = $3',
      [gameId, currentPlayer.id, game.current_question_index + 1]
    );

    if (questionResult.rows.length > 0) {
      const question = questionResult.rows[0];

      // Calculate average rating for this question
      const ratingsResult = await pool.query(
        'SELECT AVG(rating) as avg_rating FROM ratings WHERE question_id = $1',
        [question.id]
      );

      const avgRating = parseFloat(ratingsResult.rows[0].avg_rating || 0);

      // Update player's average score
      const playerRatingsResult = await pool.query(
        'SELECT AVG(rating) as avg_rating FROM ratings r JOIN game_questions gq ON r.question_id = gq.id WHERE gq.player_id = $1',
        [currentPlayer.id]
      );

      const newAvgScore = parseFloat(playerRatingsResult.rows[0].avg_rating || 0);
      const questionsAnswered = game.current_question_index + 1;

      await pool.query(
        'UPDATE players SET average_score = $1, questions_answered = $2 WHERE id = $3',
        [newAvgScore, questionsAnswered, currentPlayer.id]
      );
    }

    // Move to next question or player
    let newQuestionIndex = game.current_question_index + 1;
    let newPlayerIndex = game.current_player_index;

    if (newQuestionIndex >= game.questions_per_player) {
      newQuestionIndex = 0;
      newPlayerIndex = game.current_player_index + 1;
    }

    // Check if game is finished
    if (newPlayerIndex >= playersResult.rows.length) {
      await pool.query(
        'UPDATE games SET status = $1 WHERE id = $2',
        ['finished', gameId]
      );
      res.json({ gameFinished: true });
    } else {
      await pool.query(
        'UPDATE games SET current_player_index = $1, current_question_index = $2 WHERE id = $3',
        [newPlayerIndex, newQuestionIndex, gameId]
      );
      res.json({ success: true, nextPlayerIndex: newPlayerIndex, nextQuestionIndex: newQuestionIndex });
    }
  } catch (error) {
    console.error('Error moving to next:', error);
    res.status(500).json({ error: 'Failed to move to next' });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

