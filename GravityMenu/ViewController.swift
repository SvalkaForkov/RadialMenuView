//
//  ViewController.swift
//  GravityMenu
//
//  Created by Tyler White on 9/1/17.
//  Copyright © 2017 Tyler White. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let radialMenuView: RadialMenuView = {
        let primaryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        primaryButton.backgroundColor = .purple
        
        var secondaryButtons = [UIButton]()
        for i in 1...3 {
            let secondaryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            secondaryButton.backgroundColor = .blue
            secondaryButton.tag = i
            secondaryButton.addTarget(self, action: #selector(secondaryButtonPressed), for: .touchUpInside)
            secondaryButtons.append(secondaryButton)
        }
        
        let radialMenuView = RadialMenuView(withPrimaryButton: primaryButton, secondaryButtons: secondaryButtons)
        radialMenuView.radius = 100
        radialMenuView.delay = 0.01
        radialMenuView.progressClosure = { button, progress in
            let invisibleUntil: CGFloat = 0.4
            var alpha: CGFloat = 0
            if CGFloat(progress) > invisibleUntil {
                alpha = (CGFloat(progress) - invisibleUntil) * 1.0 / invisibleUntil
            }
            button.alpha = CGFloat(alpha)
            button.transform = CGAffineTransform(scaleX: CGFloat(progress), y: CGFloat(progress))
            radialMenuView.transform = CGAffineTransform(scaleX: 1.0 - CGFloat(progress) / 4.0, y: 1.0 - CGFloat(progress) / 4.0)
        }
        
        return radialMenuView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(radialMenuView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        radialMenuView.center = view.center
    }
    
    @objc func secondaryButtonPressed(sender: UIButton) {
        NSLog("Secondary \(sender.tag)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

