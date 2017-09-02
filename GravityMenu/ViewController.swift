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
        for i in 1...8 {
            let secondaryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            secondaryButton.backgroundColor = .blue
            secondaryButton.tag = i
            secondaryButton.addTarget(self, action: #selector(secondaryButtonPressed), for: .touchUpInside)
            secondaryButtons.append(secondaryButton)
        }
        
        let radialMenuView = RadialMenuView(withPrimaryButton: primaryButton, secondaryButtons: secondaryButtons)
        
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

