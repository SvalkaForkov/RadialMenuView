//
//  Copyright © 2017 Tyler White. All rights reserved.
//

import UIKit

class RadialMenuView: UIView {
    private let model: RadialMenuModel
    private let controller: RadialMenuController
    
    //MARK: - Setup & Teardown
    
    init(withPrimaryButton primaryButton: UIButton = UIButton(), secondaryButtons: [UIButton] = [UIButton]()) {
        self.model = RadialMenuModel(primaryButton: primaryButton, secondaryButtons: secondaryButtons)
        self.controller = RadialMenuController(withModel: self.model)
        super.init(frame: primaryButton.bounds)
        clipsToBounds = false
        isOpaque = false
        setupPrimaryButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSecondaryButtonsToSuperview()
        centerSecondaryButtons()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        removeSecondaryButtonsFromSuperview()
    }
    
    //MARK: - Public
    
    private func centerSecondaryButtons() {
        for secondaryButton in model.secondaryButtons {
            secondaryButton.center = center
        }
    }
    
    //MARK: - Private
    
    private func setupPrimaryButton() {
        addSubview(model.primaryButton)
        model.primaryButton.center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
    }
    
    private func addSecondaryButtonsToSuperview() {
        if let superview = superview {
            for secondaryButton in model.secondaryButtons {
                superview.addSubview(secondaryButton)
            }
        }
    }
    
    private func removeSecondaryButtonsFromSuperview() {
        for secondaryButton in model.secondaryButtons {
            secondaryButton.removeFromSuperview()
        }
    }
}
