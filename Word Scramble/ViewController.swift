//
//  ViewController.swift
//  Word Scramble
//
//  Created by Aasem Hany on 05/11/2022.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    var randomWord:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onRefreshPressed))
        populateAllWords()
        title = getSavedWord() ?? getNewRandomWord()
        getSavedUsedWordsList()
    }
    
    private func getNewRandomWord()->String? {
        let randomElement = allWords.randomElement()
        if let randomElement {
            let defaults = UserDefaults.standard
            defaults.set(randomElement, forKey: "randomSavedWord")
        }
        return randomElement
    }
    
    func getSavedWord()->String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "randomSavedWord")
    }
    
    @objc func onRefreshPressed(){ restartGame() }
    
    @objc func onAddPressed(){
        let ac = UIAlertController(title: "Add a word", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    private func populateAllWords(){
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileData = try? String(contentsOf: url){
                allWords = fileData.components(separatedBy: "\n")
                print(allWords.count)
            }
        }
        if allWords.isEmpty { print("Nil") }
    }
    
    private func restartGame(){
        title = getNewRandomWord()
        usedWords.removeAll(keepingCapacity: true)
        saveUsedWordsList()
        tableView.reloadData()
    }
    
    private func getSavedUsedWordsList() {
        let defaults = UserDefaults.standard
        if let usedWords = defaults.array(forKey: "usedWords") as? [String]{
            self.usedWords = usedWords
        }
    }
    
    private func saveUsedWordsList() {
        let defaults = UserDefaults.standard
        defaults.set(usedWords, forKey: "usedWords")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "word",for: indexPath)
        var cellContentConfig = currentCell.defaultContentConfiguration()
        cellContentConfig.text = usedWords[indexPath.row]
        currentCell.contentConfiguration = cellContentConfig
        return currentCell
    }
    
    
    private func submit(_ answer:String){
        let lowerCasedAnswer = answer.lowercased()
        if isPossible(word: lowerCasedAnswer) {
            if isOriginal(word: lowerCasedAnswer) {
                if isReal(word: lowerCasedAnswer) {
                    usedWords.insert(answer, at: 0)
                    saveUsedWordsList()
                    let indexPath = IndexPath(row: 0, section: 0 )
                    tableView.insertRows(at: [indexPath], with: .fade)
                    return
                }
                else{
                    showErrorMessage(title: "Word not recognized", msg: "You can't just make them up, you know!")
                }
            }
            else{
                showErrorMessage(title: "Word already used", msg: "Be more original")
            }
        }
        else{
            showErrorMessage(title: "Word not possible", msg: "You can't spell that word from \(title!.lowercased())")
        }
       
    }

    private func isPossible(word:String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            }
            else{
                return false
            }
        }
        return true
    }
    
    private func isOriginal(word:String) -> Bool {
        if word == title?.lowercased() {return false}
        return !usedWords.contains{$0.lowercased() == word.lowercased()}
    }
    
    private func isReal(word:String) -> Bool {
        if (word.count < 3) { return false }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspellRange.location == NSNotFound
    }
    
    private func showErrorMessage(title:String, msg:String){
        let errorTitle:String = title
        let errorMsg:String = msg
        let ac = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
