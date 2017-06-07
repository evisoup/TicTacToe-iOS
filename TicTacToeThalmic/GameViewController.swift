//
//  GameViewController.swift
//  TicTacToeThalmic
//
//  Created by Hengyi Liu on 2017/6/3.
//  Copyright © 2017 Hengyi Liu. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    /// shold be changed based on game/UI
    private static let gridSize = 3
    
    @IBOutlet weak var playerAScore: UILabel!
    @IBOutlet weak var playerBScore: UILabel!
    
    private var brain = GameBrain(gridSize: gridSize)
    
    /// mapping from button's tag to a grid coordinate
    /// in a format of [tag: (x,y)]
    private lazy var mappingChart: [Int:(Int,Int)] = {
        var mapping = [Int:(Int,Int)]()
        var tagIndex = 1
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                mapping[tagIndex] = (x,y)
                tagIndex += 1
            }
        }
        return mapping
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "❌Tic Tac Toe⭕️"
    }
    
    
    /// called to update scores on UI
    private func updateScore() {
        let score = brain.getScore
        playerAScore.text = String(score.0)
        playerBScore.text = String(score.1)
    }
    
    /// alert called when current round is finished
    private func finishAlert() {
        let message: String
        let gameState = brain.getGameState
        if gameState == .finished {
            let player = brain.getCurrentPlayer.rawValue
            message = "\(player) has won!"
        }
        else {
            message = "it is a draw"
        }
        
        let alert = UIAlertController(title: "This Round Is Over", message: message, preferredStyle: .alert)
        present(alert, animated:  true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
    }
    
    /// alert called when user initiate new session
    private func resetAlert() {
        let alert = UIAlertController(title: "Are you sure?", message: "reset will erase current scores", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.clearGrid()
            self.brain.newSession()
            self.updateScore()
        }))
        present(alert, animated:  true)
    }
    
    /// alert called when user initiate a new game
    private func newGameAlert() {
        let alert = UIAlertController(title: "Are you sure?", message: "new game will clear existing marks", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.clearGrid()
            self.brain.newGame()
        }))
        present(alert, animated:  true)
    }
    
    /// clearing the grid by setting images source in nil
    private func clearGrid() {
        let size = GameViewController.gridSize
        for i in 1...(size * size) {
            if let cell = view.viewWithTag(i) as? UIButton {
                cell.setImage(nil, for: UIControlState())
            }
        }
    }
    
    
    // Mark:- IBActions setup
    
    /// placeMove called once user taps a cell in the grid
    @IBAction func placeMove(_ sender: UIButton) {
        
        //check if sender's tag is valid
        guard let coordinate = mappingChart[sender.tag] else {
            return
        }
        
        let mark = brain.getMarkofCurrentPlayer
        if brain.newMove(column: coordinate.0 , row: coordinate.1) {
            switch mark
            {
            case .cross:
                sender.setImage(UIImage(named: "Cross"), for: UIControlState())
            case .nought:
                sender.setImage(UIImage(named: "Nought"), for: UIControlState())
            default:
                break
            }
            
            let gameState = brain.getGameState
            switch gameState
            {
            case .finished:
                updateScore()
                finishAlert()
            case .draw:
                finishAlert()
            case .ongoing:
                break
            }
            
        }
    }
    
    /// resetGame called once user taps "Reset Game" button
    @IBAction func resetGame(_ sender: UIButton) {
        resetAlert()
    }
    
    /// newRound called once user taps "new Round" button
    @IBAction func newRound(_ sender: UIButton) {
        newGameAlert()
    }
}
