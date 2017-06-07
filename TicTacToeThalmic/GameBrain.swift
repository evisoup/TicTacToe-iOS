//
//  GameBrain.swift
//  TicTacToeThalmic
//
//  Created by Hengyi Liu on 2017/6/2.
//  Copyright © 2017 Hengyi Liu. All rights reserved.
//

import Foundation

/// Mark represent the mark in the cell of grid
enum Mark {
    case cross
    case nought
    case empty
}

/// GameState represent the state of current game
enum GameState {
    case finished
    case draw
    case ongoing
}

/// Player represent the player in current game
enum Player: String {
    case playerA = "Player1"
    case playerB = "Player2"
}


// MARK: - GameBrain acts as the model in the MVC pattern used for this game.
//         It handles all the game logic, such as determing game state, score record, etc.

class GameBrain {
    
    private let gridSize: Int
    private let maxMoves: Int
    
    private var currentState: GameState
    private var currentPlayer: Player
    private var currentMoveCount: Int
    private var score: [Player:Int] = [.playerA:0, .playerB:0]
    private lazy var grid: [[Mark]] = { [size = self.gridSize] in
        return self.getEmptyGrid(gridSize: size)
    }()
    
    
    /// Initialize a grid of gridSize * gridSize for this game
    init(gridSize: Int) {
        self.gridSize = gridSize
        self.currentPlayer = .playerA
        self.currentState = .ongoing
        self.currentMoveCount = 0
        self.maxMoves = gridSize * gridSize
    }
    
    
    // Mark:- class private methods 
    
    /// getEmptyGrid returns a emplty grid, size of girdSize * gridSize
    private func getEmptyGrid(gridSize: Int) -> [[Mark]] {
        return Array(repeating: Array(repeating: .empty, count: gridSize), count: gridSize)
    }
    
    /// checkGameState checks grid & update game state
    /// called after a move have been successfully made
    private func checkGameState(column: Int, row: Int) -> GameState {
        let mark = getMarkofCurrentPlayer
        let size = gridSize - 1
        
        //check same row number
        for i in 0...size {
            if grid[row][i] != mark { break }
            if i == size { return .finished }
        }
        
        //check same column number
        for i in 0...size {
            if grid[i][column] != mark { break }
            if i == size { return .finished }
        }
        
        //check diagonal
        if row == column {
            for i in 0...size {
                if grid[i][i] != mark { break }
                if i == size { return .finished }
            }
        }
        
        //checking the opposite diagonal
        if row + column == size {
            for i in 0...size {
                if grid[i][size - i] != mark { break }
                if i == size { return .finished }
            }
        }
        
        if currentMoveCount == maxMoves {
            return .draw
        }
        
        currentPlayer = (currentPlayer == .playerA ? .playerB : .playerA)
        return .ongoing
    }
    
    /// updateScore updates score for player
    private func updateScore(player: Player, gameState: GameState) {
        if gameState == .finished, let val = score[player] {
            score.updateValue(val + 1, forKey: player)
        }
    }

    
    // Mark:- GameBrain APIs
    
    /// read-only mark ofcurrent player, can be used by ViewController
    public var getMarkofCurrentPlayer: Mark {
        get {
            switch currentPlayer
            {
            case .playerA:
                return .cross
            case .playerB:
                return .nought
            }
        }
    }
    
    /// read-only mark ofcurrent player, can be used by ViewController
    public var getCurrentPlayer: Player {
        get {
            return currentPlayer
        }
    }
    
    /// read-only game state, can be used by ViewController
    public var getGameState: GameState {
        get {
            return currentState
        }
    }
    
    /// read-only game score, can be used by ViewController
    /// returns player A & B's score in a tuple
    public var getScore: (Int, Int) {
        get {
            //since score dictionary cannot be empty, hence force unwrapping can be used
            return (score[.playerA]!,score[.playerB]!)
        }
    }
    
    /// newMove is the API used by ViewController to place a new move
    /// it returns true if it's a valid move, false otherwise
    public func newMove(column: Int, row: Int) -> Bool {
        guard currentState == .ongoing else {
            return false
        }
        
        guard column <= gridSize && row <= gridSize else {
            //input out of bound
            return false
        }
        
        let cell = grid[row][column]
        switch cell
        {
        case .empty:
            grid[row][column] = getMarkofCurrentPlayer
        default:
            //this cell has already been used, hence invalid move
            return false
        }
        
        //new move is valid, update game accordingly
        currentMoveCount += 1
        currentState = checkGameState(column: column, row: row)
        updateScore(player: currentPlayer, gameState: currentState)
        
        return true
    }
    
    /// newGame is the API used by ViewController to start a new game
    /// while preserving scores for each player
    public func newGame() {
        grid.removeAll()
        grid = getEmptyGrid(gridSize: gridSize)
        currentPlayer = .playerA
        currentState = .ongoing
        currentMoveCount = 0
    }
    
    /// newSession is the API used by ViewController to start a new session
    /// scores for each player will be reset to 0
    public func newSession() {
        newGame()
        score = [.playerA:0, .playerB:0]
    }
}
