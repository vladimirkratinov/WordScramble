//
//  ViewController.swift
//  Project5
//
//  Created by Vladimir Kratinov on 2022/1/4.
//

import RAMAnimatedTabBarController
import UIKit

class SecondViewController: UITableViewController {
    @IBOutlet var wordLabel2: UILabel!
    @IBOutlet var descriptionLabel2: UILabel!
    
    var allWords2 = [String]()
    var usedWords2 = [String]()
    
    var errorTitle: String = ""
    var errorMessage: String = ""
    
    var counter2: Int = 0
    var score2: Int = 0
    
    var wordsUsed2: Int = 0
    var wordsCreated2: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Player 2"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords2 = startWords.components(separatedBy: "\n")
            }
        }
        
        startGame()
        
        if allWords2.isEmpty {
            allWords2 = ["silkworm"]
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        let customColor = UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = customColor
        tabBarController?.tabBar.barTintColor = customColor
        tableView.backgroundColor = customColor
    }
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords2.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords2[indexPath.row]
        cell.detailTextLabel?.text = String(counter2)
        counter2 += 1
        return cell
    }
    
    //MARK: - @Objc methods
    
    func descriptionUpdate() {
        DispatchQueue.main.async {
            self.descriptionLabel2.text = " Rules: make new words from selected one. Must be 3 characters at least. \n Pass a move to another player after you found all possible combinations. \n Press \"Refresh\" button to change the word. Get 20 points to win! \n Total words scrambled: \(self.wordsUsed2). New words created: \(self.wordsCreated2)"
        }
    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        print("loadList2 NotificationCenter is worked")
        self.counter2 = 1
        self.score2 = 0
        self.wordsUsed2 = 0
        self.wordsCreated2 = 0
        self.usedWords2.removeAll(keepingCapacity: true)
        self.wordLabel2.text = allWords2.randomElement()
        self.tableView.reloadData()
        
        descriptionUpdate()
    }
    
    @objc func startGame() {
        counter2 = 1
        wordsUsed2 += 1
        
        descriptionUpdate()
        
        wordLabel2.text = allWords2.randomElement()
        usedWords2.removeAll(keepingCapacity: true)
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
        if score2 == 20 {
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
                        usedWords2.insert(answer, at: 0)
                        score2 += 1
                        wordsCreated2 += 1
                        
                        descriptionUpdate()
                        
                        guard let items = tabBarController?.tabBar.items else { return }
                        items[1].badgeValue = String(score2)
                        let indexParth = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexParth], with: .bottom)
                        
                        if isWin() {
                            let ac = UIAlertController(title: "Congratulations!", message: "Player 2 Won", preferredStyle: .alert)
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
                showErrorMessage(Title: "Word not possible", Message: "You can't spell that word from \(wordLabel2.text!.lowercased()).")
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
        guard var tempWord = wordLabel2.text?.lowercased() else { return false }
        
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
        return !usedWords2.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
}
