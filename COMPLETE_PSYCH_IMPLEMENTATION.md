# Complete Psych! Game Implementation Guide

## Status: In Progress

This document tracks the complete end-to-end implementation of the Psych! game with:
- ✅ Synchronized timer (backend done, frontend in progress)
- ✅ Staggered card reveals (reveal screen needs grid layout)
- ✅ Tap-to-vote (voting screen needs update)
- ✅ Votes × 10 scoring (backend done)
- ✅ Round results with vote details + scoreboard + ready button (needs complete rewrite)

## Backend Status: ✅ Complete

1. **Synchronized Timer**: `timer_start_time` column added to `games` table
2. **Ready System**: `is_ready` column added to `players` table, `/api/games/:gameId/ready` endpoint
3. **Scoring**: Points = votes × 10, stored in `total_score`
4. **Vote Details**: `/api/games/:gameId/results` returns `voteDetails` (who voted for what)
5. **Scoreboard**: Results endpoint returns `scoreboard` with ranks

## Frontend Status: 🚧 In Progress

### Next Steps:
1. Update reveal screen to show cards in 2-column grid with staggered reveals
2. Update voting screen with tap-to-vote (radio buttons → tap cards)
3. Complete rewrite of round results screen:
   - Show winning answer with player name
   - Show who voted for each answer (avatars)
   - Show scoreboard with ranks
   - Show ready button (only enabled when all ready)
   - Auto-advance when all ready

