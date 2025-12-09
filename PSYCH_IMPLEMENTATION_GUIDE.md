# Psych! Style Game - Complete Implementation Guide

## Overview
Converting from turn-based to Psych! style (all players answer same question, anonymous reveal, voting)

## Database Changes ✅
- Updated schema.sql with:
  - Round-based questions (one per round)
  - Votes table (Psych-style voting)
  - Updated answers table with round_number

## Backend API Changes Needed

### 1. Start Game
- Change status to 'answering' (not 'playing')
- Set current_round = 1
- Remove player_order shuffling (not needed for Psych)

### 2. Get Question (NEW - Psych Style)
- Return same question for all players
- Based on current_round, not current_player_index
- Check if all players submitted answers before moving to reveal

### 3. Submit Answer (UPDATE)
- Store with round_number
- Check if all players answered → auto-move to reveal phase

### 4. Get Answers for Reveal (NEW)
- Return all answers for current round
- SHUFFLED and ANONYMOUS (no player names)
- Only return answer_text and answer_id

### 5. Submit Vote (NEW - Psych Style)
- Vote for best answer (answer_id)
- One vote per player per round
- Prevent self-voting

### 6. Get Round Results (NEW)
- Calculate votes per answer
- Award points (Psych-style: votes = points)
- Update player scores
- Return round winner and points

### 7. Next Round (NEW)
- Move to next round
- Or end game if all rounds done

## Frontend Changes Needed

### New Screens:
1. **Reveal Screen** - Show all answers anonymously in cards
2. **Voting Screen** - Tap to vote for best answer
3. **Round Results Screen** - Show who got votes, points awarded

### Updated Screens:
1. **Gameplay Screen** - Show "Round X" instead of "Player X's turn"
2. **Rating Screen** - Change to voting (select best answer)
3. **Results Screen** - Enhanced with round-by-round highlights

## Implementation Priority

1. ✅ Database schema
2. 🔄 Backend endpoints (in progress)
3. ⏳ Frontend screens
4. ⏳ Provider updates
5. ⏳ Testing

## Status: Starting backend implementation...


