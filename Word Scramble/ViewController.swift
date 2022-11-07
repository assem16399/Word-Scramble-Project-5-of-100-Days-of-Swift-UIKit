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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        populateAllWords()
        startGame()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddPressed))
    }

    @objc func onAddPressed(){
        let ac = UIAlertController(title: "Add a word", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) {[weak self, weak ac] (_) in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    private func submit(_ answer:String){}

    private func populateAllWords(){
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileData = try? String(contentsOf: url){
                allWords = fileData.components(separatedBy: "\n")
                print(allWords.count)
            }
        }

        if allWords.isEmpty {
            print("Nil")
        }
    }
    
    private func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
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
}

