//
//  MainVC.swift
//  WordScramble
//
//  Created by Mike Sabens on 3/22/17.
//  Copyright © 2017 TheNewThirty. All rights reserved.
//

import UIKit
import GameplayKit

class MainVC: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Answer button for user input
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))

        //Find our file with all the words for the game, seperate them into strings in the array.
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["failure"]
        }
        
        startGame()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)

        cell.textLabel?.text = usedWords[indexPath.row]

        return cell
    }
    
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { // this is a closure, instead of a handler calling a method in the class, we're going to write the method between the curly braces. This is infact trailing closure syntax.
            [unowned self, ac] //Important to have these be weak so self doesn't own the objects
            _ in // verything before "in" described the closure, everything after this is the actual closure
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
            
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "What?"
                    errorMessage = "Look at a dictionary sometime!"
                }
            } else {
                errorTitle = "Nice Try Buddy!"
                errorMessage = "Thought you could replay a word? Think again"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }


    func isPossible(word: String) -> Bool {
        //simple algorithm to loop through every letter in the answer and seeing if that letter exists in the original word. If it does, we remove the letter from the original word then continue the loop. 
        
        var tempWord = title!.lowercased()
        
        for letter in word.characters {
            if let position = tempWord.range(of: String(letter)) {
                tempWord.remove(at: position.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }

}
