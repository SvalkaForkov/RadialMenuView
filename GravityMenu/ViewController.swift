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
        let primaryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        primaryButton.layer.cornerRadius = 30
        primaryButton.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0.4, alpha: 1)
        
        var secondaryButtons = [UIButton]()
        for i in 1...9 {
            let secondaryButton = UIButton(type: UIButton.ButtonType.system)
            secondaryButton.translatesAutoresizingMaskIntoConstraints = false
            secondaryButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
            secondaryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            secondaryButton.layer.cornerRadius = 20
            secondaryButton.setTitle("\(i)", for: .normal)
            secondaryButton.tintColor = .white
            secondaryButton.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.8, alpha: 1)
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
    
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(radialMenuView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        view.addSubview(label)
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        radialMenuView.center = view.center
    }
    
    @objc func secondaryButtonPressed(sender: UIButton) {
        NSLog("Secondary \(sender.tag)")
        label.text = "\(sender.tag)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

