# Reveal Me Game Redesign - Implementation Plan

## Overview
Complete redesign of the Reveal Me game to match the new specifications with:
- Text input for answers (not just verbal)
- Answer storage in database
- Turn-based system with proper question flow
- Rating screen showing all answers
- Host ability to remove players
- Better real-time synchronization

## Changes Required

### 1. Database Schema ✅
- [x] Add `answers` table to store player answers
- [x] Add indexes for performance

### 2. Backend API
- [ ] Add authentication to `/api/games/:gameId` endpoint
- [x] Add `/api/games/:gameId/answer` endpoint (submit answer)
- [x] Add `/api/games/:gameId/question/:questionId/answers` endpoint (get answers for rating)
- [x] Add `/api/games/:gameId/players/:playerId` DELETE endpoint (remove player)
- [ ] Update `/api/games/:gameId/question` to include answer if exists
- [ ] Update `/api/games/:gameId/next` to handle answer submission before moving

### 3. Flutter Frontend

#### Provider Updates
- [ ] Add answer storage in provider
- [ ] Add method to submit answer
- [ ] Add method to get answers for current question
- [ ] Update turn flow to require answer before moving

#### Gameplay Screen
- [ ] Add TextField for answer input
- [ ] Show existing answer if already submitted
- [ ] Disable "Next Question" until answer is submitted
- [ ] Auto-save answer on timer end
- [ ] Show "Submit Answer" button

#### Rating Screen
- [ ] Fetch and display all answers for the question
- [ ] Show answers in scrollable list
- [ ] Allow rating after viewing answers

#### Lobby Screen
- [ ] Add remove player button (host only)
- [ ] Show confirmation dialog before removing

## Implementation Status

Starting implementation now...


