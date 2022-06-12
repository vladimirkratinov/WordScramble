//
//  ViewController.swift
//  Project5
//
//  Created by Vladimir Kratinov on 2022/1/4.
//

import RAMAnimatedTabBarController
import UIKit

class FirstViewController: UITableViewController {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var allWords = [String]()
    var usedWords = [String]()
    
    var errorTitle: String = ""
    var errorMessage: String = ""
    
    var counter: Int = 0
    var score: Int = 0
    
    var wordsUsed: Int = 0
    var wordsCreated: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Player 1"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        startGame()
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        let customColor = UIColor(red: 0.01, green: 0.99, blue: 0.65, alpha: 1.00)
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = customColor
        tabBarController?.tabBar.barTintColor = customColor
        tableView.backgroundColor = customColor
    }
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        cell.detailTextLabel?.text = String(counter)
        counter += 1
        return cell
    }
    
    //MARK: - @Objc methods
    
    func descriptionUpdate() {
        DispatchQueue.main.async {
            self.descriptionLabel.text = " Rules: make new words from selected one. Must be 3 characters at least. \n Pass a move to another player after you found all possible combinations. \n Press \"Refresh\" button to change the word. Get 20 points to win! \n Total words scrambled: \(self.wordsUsed). New words created: \(self.wordsCreated)"
        }
    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        print("loadList1 NotificationCenter is worked")
        self.counter = 1
        self.score = 0
        self.wordsUsed = 0
        self.wordsCreated = 0
        self.usedWords.removeAll(keepingCapacity: true)
        self.wordLabel.text = allWords.randomElement()
        
        self.tableView.reloadData()
        
        descriptionUpdate()
    }
    
    @objc func startGame() {
        counter = 1
        wordsUsed += 1
        
        descriptionUpdate()
        
        wordLabel.text = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Word:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer.lowercased())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    //MARK: - Win Condition
    
    func playAgain(alert: UIAlertAction!) {
        
        guard let items = tabBarController?.tabBar.items else { return }
        items[0].badgeValue = nil
        items[1].badgeValue = nil
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
    func isWin() -> Bool {
        if score == 20 {
            return true
        } else {
            return false
        }
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isLong(word: lowerAnswer) {
            if isPossible(word: lowerAnswer) {
                if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        usedWords.insert(answer, at: 0)
                        score += 1
                        wordsCreated += 1
                        
                        descriptionUpdate()
                        
                        guard let items = tabBarController?.tabBar.items else { return }
                        items[0].badgeValue = String(score)
                        let indexParth = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexParth], with: .bottom)
                        
                        if isWin() {
                            let ac = UIAlertController(title: "Congratulations!", message: "Player 1 Won", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "Play Again", style: .destructive, handler: playAgain))
                            present(ac, animated: true)
                        }
                        
                        return
                    } else {
                        showErrorMessage(Title: "Word not recognized", Message: "It doesn't work")
                    }
                } else {
                    showErrorMessage(Title: "Word already used", Message: "Be more original!")
                }
            } else {
                showErrorMessage(Title: "Word not possible", Message: "You can't spell that word from \(wordLabel.text!.lowercased()).")
            }
        } else {
            showErrorMessage(Title: "Word is too short", Message: "Use 3 and more charachers")
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
    }
    
    func showErrorMessage(Title: String, Message: String) {
        errorTitle = Title
        errorMessage = Message
    }
    
    //MARK: - Logic
    
    func isLong(word: String) -> Bool {
        if word.count >= 3 {
            return true
        } else {
            return false
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = wordLabel.text?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
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
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
}
