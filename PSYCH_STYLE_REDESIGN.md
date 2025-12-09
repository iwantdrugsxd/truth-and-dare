# Psych! Style Game Redesign - Implementation Plan

## Overview
Converting Reveal Me game to Psych! - The Truth Comes Out style:
- All players answer the same question simultaneously
- Answers revealed anonymously
- Players vote for best/funniest/spiciest answer
- Psych-style scoring (majority votes = points)

## Game Flow

1. **Lobby** → Players join with code
2. **Start Game** → Host starts, all players get same question
3. **Answering Phase** → All players type answers secretly (timer)
4. **Reveal Phase** → All answers shown anonymously in random order
5. **Voting Phase** → Players vote for best answer
6. **Round Results** → Show who got votes, update scores
7. **Next Round** → Repeat until all rounds done
8. **Final Leaderboard** → Winner with highest score

## Backend Changes Needed

1. Update game status flow: `lobby → answering → reveal → voting → results → (next round or finished)`
2. Change question distribution: One question per round for all players
3. Add anonymous answer reveal (shuffle answers, hide player names)
4. Change rating to voting (select one best answer)
5. Implement Psych-style scoring (votes = points)
6. Add round tracking

## Frontend Changes Needed

1. **Gameplay Screen**: Show same question to all, timer for all
2. **Reveal Screen**: NEW - Show all answers anonymously in cards
3. **Voting Screen**: NEW - Select best answer (not rate 1-10)
4. **Round Results Screen**: NEW - Show who got votes, points awarded
5. **Final Leaderboard**: Enhanced with best answers highlight

## Status

Starting implementation...


