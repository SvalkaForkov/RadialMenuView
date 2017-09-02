//
//  Copyright © 2017 Tyler White. All rights reserved.
//

import UIKit

class RadialMenuView: UIView {
    private let model: RadialMenuModel
    private var controller: RadialMenuController?
    var radius: CGFloat {
        get {
            if let controller = controller {
                return controller.radius
            }
            return 0
        }
        set {
            if let controller = controller {
                controller.radius = newValue
            }
        }
    }

    
    //MARK: - Setup & Teardown
    
    init(withPrimaryButton primaryButton: UIButton = UIButton(), secondaryButtons: [UIButton]) {
        guard secondaryButtons.count > 0 else {
            fatalError("RadialMenuView needs at least one secondary button to work.")
        }
        self.model = RadialMenuModel(primaryButton: primaryButton, secondaryButtons: secondaryButtons)
        super.init(frame: primaryButton.bounds)
        self.controller = RadialMenuController(withModel: self.model, view: self)
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let controller = controller {
            controller.viewLayoutSubviews()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let controller = controller {
            controller.viewDidMoveToSuperview()
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if let controller = controller {
            controller.viewWillRemoveFromSuperview()
        }
    }
    
    //MARK: - Public
    
    //MARK: - Private
}
