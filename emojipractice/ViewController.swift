//
//  ViewController.swift
//  emojipractice
//
//  Created by Enrique Florencio on 1/23/20.
//  Copyright © 2020 Enrique Florencio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Private IBOutlets
    @IBOutlet private var emoji: UILabel!
    @IBOutlet private var highScoreLabel: UILabel!
    @IBOutlet private var input: UITextField!
    @IBOutlet private var timerLabel: UILabel!
    @IBOutlet private var lastEmoji: UILabel!
    // MARK: - Private Variables
    private var timer: DispatchSourceTimer?
    private var seconds = 60
    private var emojiStrings = [String]()
    private var currentIndex = 0
    private var cntr = 0
    private var correctCount = 0
    private var emojiText = "\u{200B}"
    // MARK: - Private Constants
    private let finishedshadow = NSShadow()
    private let defaults = UserDefaults.standard
    private let backupEmojis = ["😕","🐻","⚾️","😂","💛","🆒","👶","🚍","🚤","☮️","✈️","🔰","⬆️","⬇️","🌷","🏒","♐️","🛢","⤵️","♠️", "🗓", "🕢", "🔓", "3️⃣", "😅", "🚁", "😺", "💈" ,"☔️", "👼", "🔠", "🏂" ,"🔑", "🎖", "🏝", "👱", "🏚", "💘", "🔌", "⚡️", "🛄", "🕥", "😝", "🎦", "👖", "🐉", "📼", "🔀", "✖️", "⚽️", "⚱", "🔇", "🗜","🚘","🎥","💂","⌛️","🚑","🛁","🕒","👳","💽","🌚","🎲","🍅","🌛","1️⃣","🎱","🏘","⬅️","😡","🏺","🔶","📼","📸","🎯","⏺","🐹","🍪","💪","🏷","😘","🐭","🏊","👨‍👩‍👧‍👧","🌓","🔧","💳","📝","❤️","📤","📅","💻","🍳","🎥","🐮","⚗","🚻","🍴","🖖"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        //Define how the UI should appear when it loads up
        let highScore = defaults.integer(forKey: "highScore")
        highScoreLabel.text = "🔝Score: \(highScore) EPM"
        title = "\u{1f61b}EmotiThon\u{1f60b}"
        input.layer.borderColor = UIColor.gray.cgColor
        input.layer.borderWidth = 2.0
        emoji.layer.borderColor = UIColor.gray.cgColor
        emoji.layer.borderWidth = 3.0
        lastEmoji.text = "Last Emoji Entered: "
        updateTimer()
        input.delegate = self
        emoji.text = ""
        finishedshadow.shadowColor = UIColor.blue
        finishedshadow.shadowBlurRadius = 10
        
        //Access the API on the userinitiated thread so that it doesn't lock up the UI
        let urlString = "https://emojigenerator.herokuapp.com/emojis/api/v1?count=100"
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {fatalError()}
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    //Parse the data and put the emojis inside the array of emojis
                    self.parse(json: data)
                } else {
                    //There was an error accessing the API so now we have to use backup emojis
                    self.emojiStrings = self.backupEmojis
                    self.setup(emojiString: self.backupEmojis)
                }
            }
        }
        
    }

    // MARK: - Program Functions
    func updateTimer() {
        //This function updates the timer on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.timerLabel.text = "⏲️: \(self!.seconds)"
        }
    }
    
    func parse(json: Data) {
        //Parse the data using a JSONDecoder
        let decoder = JSONDecoder()
        if let jsonEmojis = try? decoder.decode(emojis.self, from: json) {
            emojiStrings = jsonEmojis.emojis
        } else {
            //The parsing did not go well so now we have to resort to our backup emojis
            emojiStrings = backupEmojis
        }
        
        //Add the array of emojis to our string
        setup(emojiString: emojiStrings)
        
    }
    
    func setup(emojiString: [String]) {
        for i in 0 ..< 10 {
            //String concatenation that will be displayed on the UI
            emojiText += emojiStrings[i]
            emojiText += "\u{200B}"
            cntr += 1
        }
        //This was the hardest part of the project in my opinion. This is supposed to highlight an individual emoji which indicares the current emoji the user has to type in
        //Make the emojiText an NSString
        let str = emojiText as NSString
        //Defining a set range to highlight an individual emoji
        //let firstRange = str.range(of: emojiStrings[0])
        //let secondRange = str.range(of: emojiStrings[0], options: .backwards)
        //let nsRange = NSMakeRange(firstRange.location, secondRange.location + secondRange.length - firstRange.location)
        let nsRange = NSMakeRange(0, str.length)
        //Finally creating an attributed string that will be displayed on the UI
        let attributedString = NSMutableAttributedString(string: emojiText)
        //print("hit")
        emojiText.enumerateSubstrings(in: emojiText.startIndex..<emojiText.endIndex) { [weak self] (substring, substringRange, _, _) in
            guard let self = self else {
                fatalError()
            }
            print("HIT")
            print(substringRange)
            var start = substring![1]
            var scalars = [String]()
            var scalars2 = [String]()

            for char in start {
                scalars2 = String(char).unicodeScalars.map({ String($0.value, radix: 16) })
            }
            print(scalars2)
            
            for char in self.emojiStrings[0]{
                scalars = String(char).unicodeScalars.map({ String($0.value, radix: 16) })
            }
            print(scalars)
            if(scalars == scalars2) {
                print("HIT 2")
                attributedString.addAttribute(.shadow, value: self.finishedshadow, range: NSRange(location: 1, length: 2))
            }
        }
        print(attributedString)
        //attributedString.addAttribute(.shadow, value: finishedshadow, range: nsRange)
        
        //UI work is only done on the main thread.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {fatalError()}
            //Set the label's attributed text to the attributed string we created earlier
            self.emoji.attributedText = attributedString
        }
    }
    
    func finishGame() {
        //Cancel the timer to refrain from a strong reference cycle
        timer?.cancel()
        timer = nil
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {fatalError()}
            //Define all UI work on the main thread
            let highScore = self.defaults.integer(forKey: "highScore")
            var ac: UIAlertController!
            if(self.correctCount > highScore) {
                self.defaults.set(self.correctCount, forKey: "highScore")
                ac = UIAlertController(title: "TIMES UP!!!", message: "NEW RECORD!!! Your Emojis Per Minute: \(self.correctCount)", preferredStyle: .actionSheet)
            } else {
                ac = UIAlertController(title: "TIMES UP!!!", message: "Your Emojis Per Minute: \(self.correctCount)", preferredStyle: .actionSheet)
            }
            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: self.updateScore))
            ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: self.restartGame))
            //ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: startGame))
            self.present(ac, animated: true)
            self.emojiText = "\u{200B}"
            self.emoji.text = ""
            
        }
        
    }
    
    func updateScore(action: UIAlertAction!) {
        //This updates the score at the end of the game
        let highScore = defaults.integer(forKey: "highScore")
        highScoreLabel.text = "🔝Score: \(highScore) EPM"
    }
    
    func restartGame(action: UIAlertAction!) {
        //This resets everything back to before the user started playing
        let highScore = defaults.integer(forKey: "highScore")
        highScoreLabel.text = "🔝Score: \(highScore) EPM"
        seconds = 60
        correctCount = 0
        currentIndex = 0
        cntr = 0
        emojiStrings.shuffle()
        
        setup(emojiString: emojiStrings)
        timerLabel.text = "⏲️: \(seconds)"
    }
    
    func reset() {
        //This resets the string on the UI after the user has typed in an entire set of emojis
        currentIndex += 1
        emojiText = "\u{200B}"
        
        for i in currentIndex ..< currentIndex+10 {
            emojiText += emojiStrings[i]
            cntr += 1
        }
    }
    
    func addAttributeToString(index: Int) {
        let str = emojiText as NSString
        let firstRange = str.range(of: emojiStrings[index])
        let secondRange = str.range(of: emojiStrings[index], options: .backwards)
        let nsRange = NSMakeRange(firstRange.location, secondRange.location + secondRange.length - firstRange.location)

        let attributedString = NSMutableAttributedString(string: emojiText)
        attributedString.addAttribute(.shadow, value: finishedshadow, range: nsRange)
        emoji.attributedText! = attributedString
    }
    
    // MARK: - Textfield Functions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string.isEmpty) {
            return false
        }
        return true
        
    }
    
    // MARK: - IBActions
    @IBAction func didChange(_ sender: UITextField) {
        
        guard let inputText = sender.text else {
                return
            }
            
            sender.text = ""
            lastEmoji.text = "Last Emoji Entered: \(inputText)"
            var scalars = [String]()
            var scalars2 = [String]()

            for char in inputText[0] {
                scalars2 = String(char).unicodeScalars.map({ String($0.value, radix: 16) })
            }
            print(scalars2)

            for char in emojiStrings[currentIndex] {
                print(char)

                scalars = String(char).unicodeScalars.map({ String($0.value, radix: 16) })
            }
            print(scalars)

            if(scalars == scalars2) {
                print("true")
            }
            //If it is correct then add a point to their correct count
            if(scalars == scalars2) {
                print("hit")
                correctCount += 1
                if(currentIndex == cntr - 1) {
                    reset()
                    addAttributeToString(index: currentIndex)
                } else {
                    addAttributeToString(index: currentIndex+1)
                    currentIndex += 1
                }
            }
            
            //This starts the timer as soon as the user types in an emoji
            if(timer == nil) {
                let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".timer")
                timer = DispatchSource.makeTimerSource(queue: queue)
                timer!.schedule(deadline: .now(), repeating: .seconds(1))
                timer!.setEventHandler { [weak self] in
                    if(self?.seconds == 0) {
                          self?.finishGame()
                    } else if(self!.seconds <= 60) {
                          self?.seconds -= 1
                          self?.updateTimer()
                    }
                }
                
                timer!.resume()
            }
        }
    
}

// MARK: - Extensions
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

