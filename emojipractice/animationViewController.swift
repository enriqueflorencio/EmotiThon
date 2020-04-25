//
//  animationViewController.swift
//  emojipractice
//
//  Created by Enrique Florencio on 1/27/20.
//  Copyright © 2020 Enrique Florencio. All rights reserved.
//

import UIKit
import Lottie

final class animationViewController: UIViewController {
    //MARK: - IBOUTLETS
    @IBOutlet private var animationView: UIView!
    @IBOutlet private var tapButton: UIButton!
    // MARK: - Private Constants
    private let newAnimationView = AnimationView(name: "emoji")
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "\u{1f61b}EmotiThon\u{1f60b}"
        tapButton.layer.borderWidth = 2
        tapButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNewAnimationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNewAnimationView()
    }
    
    func setupNewAnimationView() {
        newAnimationView.contentMode = .scaleAspectFit
        newAnimationView.backgroundBehavior = .pauseAndRestore
        newAnimationView.backgroundColor = .clear
        newAnimationView.loopMode = .loop
        newAnimationView.frame = animationView.bounds
        animationView.addSubview(newAnimationView)
        newAnimationView.play()
    }
    // MARK: - IBActions
    @IBAction func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            sender.transform = .identity
        })
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "emojiGame") as? ViewController else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
   
}
