//
//  Copyright © 2017 Tyler White. All rights reserved.
//

import UIKit

class RadialMenuController {
    let model: RadialMenuModel
    
    //MARK: - Setup & Teardown
    
    init(withModel model: RadialMenuModel) {
        self.model = model
        setupPrimaryButton()
        setupSecondaryButtons()
    }
    
    //MARK: - Private
    
    private func setupPrimaryButton() {
        model.primaryButton.addTarget(self, action: #selector(primaryButtonTouchUpInside), for: .touchUpInside)
        model.primaryButton.addTarget(self, action: #selector(primaryButtonTouchDragEnter), for: .touchDragEnter)
        model.primaryButton.addTarget(self, action: #selector(primaryButtonTouchDragExit), for: .touchDragExit)
        model.primaryButton.addTarget(self, action: #selector(primaryButtonTouchDown), for: .touchDown)
    }
    
    private func setupSecondaryButtons() {
        for secondaryButton in model.secondaryButtons {
            secondaryButton.alpha = 0
            secondaryButton.isUserInteractionEnabled = false
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTouchUpInside), for: .touchUpInside)
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTouchDragEnter), for: .touchDragEnter)
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTouchDragExit), for: .touchDragExit)
        }
    }
    
    //MARK: - Actions
    
    @objc func primaryButtonTouchDown(button: UIButton) {
        NSLog(#function)
    }
    
    @objc func primaryButtonTouchUpInside(button: UIButton) {
        NSLog(#function)
    }
    
    @objc func primaryButtonTouchDragEnter(button: UIButton) {
        NSLog(#function)
    }
    
    @objc func primaryButtonTouchDragExit(button: UIButton) {
        NSLog(#function)
    }
    
    @objc func secondaryButtonTouchUpInside(button: UIButton) {
        if let secondaryButtonIndex = model.secondaryButtons.index(of: button) {
            NSLog(#function + " - \(secondaryButtonIndex)")
        }
    }
    
    @objc func secondaryButtonTouchDragEnter(button: UIButton) {
        if let secondaryButtonIndex = model.secondaryButtons.index(of: button) {
            NSLog(#function + " - \(secondaryButtonIndex)")
        }
    }
    
    @objc func secondaryButtonTouchDragExit(button: UIButton) {
        if let secondaryButtonIndex = model.secondaryButtons.index(of: button) {
            NSLog(#function + " - \(secondaryButtonIndex)")
        }
    }
}
