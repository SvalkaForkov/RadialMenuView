//
//  Copyright © 2017 Tyler White. All rights reserved.
//

import UIKit

enum RadialMenuState {
    case open, closed
}

enum RadialMenuExpansionMode {
    case full, half
}

class RadialMenuController {
    let model: RadialMenuModel
    weak var view: RadialMenuView?
    var dynamicAnimator: UIDynamicAnimator?
    var dynamicBehaviors = [UIDynamicBehavior]()
    var state: RadialMenuState = .closed {
        didSet {
            updateBehaviors()
        }
    }
    var radius: CGFloat = 100 {
        didSet {
            updateBehaviors()
        }
    }
    var expansionMode: RadialMenuExpansionMode = .full {
        didSet {
            updateBehaviors()
        }
    }
    
    //MARK: - Setup & Teardown
    
    init(withModel model: RadialMenuModel, view: RadialMenuView) {
        self.model = model
        self.view = view
        configurePrimaryButton()
        configureSecondaryButtons()
    }
    
    //MARK: - Public
    
    func viewLayoutSubviews() {
        let needsToSetupDynamicBehaviors = (dynamicBehaviors.count == 0)
        if needsToSetupDynamicBehaviors {
            centerSecondaryButtonsToView()
            setupDynamicBehaviors()
        }
        updateBehaviors()
    }
    
    func viewDidMoveToSuperview() {
        guard let view = view, let viewSuperview = view.superview else {
            return
        }
        dynamicAnimator = UIDynamicAnimator(referenceView: view.superview!)
        if (model.primaryButton.superview == nil) {
            addPrimaryButtonToView()
        }
        addSecondaryButtonsToViewSuperview()
        viewSuperview.bringSubview(toFront: view)
    }
    
    func viewWillRemoveFromSuperview() {
        if let dynamicAnimator = dynamicAnimator {
            dynamicAnimator.removeAllBehaviors()
        }
        dynamicAnimator = nil
    }
    
    func centerSecondaryButtonsToView() {
        if let view = view {
            for secondaryButton in model.secondaryButtons {
                secondaryButton.center = view.center
            }
        }
    }
    
    //MARK: - Private
    
    private func updateBehaviors() {
        guard let view = view else {
            return
        }
        
        for (i, behavior) in dynamicBehaviors.enumerated() {
            guard let snapBehavior = behavior as? UISnapBehavior else {
                continue
            }
            
            var point = view.center
            if state == .open {
                point = calculatePointForIndex(i, totalCount: dynamicBehaviors.count, origin: view.center, radius: radius, fullAngle: 360, centeredOnAngle: 90)
            }
            snapBehavior.snapPoint = point
        }
    }
    
    private func calculatePointForIndex(_ index: Int, totalCount: Int, origin: CGPoint, radius: CGFloat, fullAngle: CGFloat = 360, centeredOnAngle: CGFloat = 90) -> CGPoint {
        
        let currentSegmentIndex: CGFloat = CGFloat(index) + CGFloat(fullAngle < 360 ? 1 : 0)
        let segmentCount: CGFloat = CGFloat(totalCount) + CGFloat(fullAngle < 360 ? 1 : 0)
        let centeredAdjustment: CGFloat = centeredOnAngle - ((fullAngle / 2.0))
        let segmentAngle: CGFloat = fullAngle / segmentCount
        
        var destinationAngle = (currentSegmentIndex * segmentAngle)
        destinationAngle = destinationAngle + centeredAdjustment
        let destinationRadians = destinationAngle * CGFloat(.pi / 180.0)

        let x: CGFloat = radius * cos(destinationRadians) + origin.x
        let y: CGFloat = radius * sin(destinationRadians) + origin.y
        
        return CGPoint(x: x, y: y)
    }
    
    private func normalizedAngle(_ angle: CGFloat) -> CGFloat {
        let remainder = angle.truncatingRemainder(dividingBy: 360.0)
        var normalized: CGFloat = remainder
        if (normalized < 0.0) {
            normalized = normalized + 360.0
        }
        return normalized
    }
    
    private func setupDynamicBehaviors() {
        for secondaryButton in model.secondaryButtons {
            if let view = view {
                let point = view.center
                let snapBehavior = UISnapBehavior(item: secondaryButton, snapTo: point)
                dynamicAnimator?.addBehavior(snapBehavior)
                dynamicBehaviors.append(snapBehavior)
            }
        }
    }
    
    private func configurePrimaryButton() {
        model.primaryButton.addTarget(self, action: #selector(primaryButtonTouchDragEnter), for: .touchDragEnter)
        model.primaryButton.addTarget(self, action: #selector(primaryButtonTouchDragExit), for: .touchDragExit)
        model.primaryButton.addTarget(self, action: #selector(primaryButtonTouchDown), for: .touchDown)
    }
    
    private func configureSecondaryButtons() {
        for secondaryButton in model.secondaryButtons {
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTouchUpInside), for: .touchUpInside)
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTouchDragEnter), for: .touchDragEnter)
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTouchDragExit), for: .touchDragExit)
        }
    }
    
    private func addPrimaryButtonToView() {
        if let view = view {
            view.addSubview(model.primaryButton)
            model.primaryButton.center = CGPoint(x: view.bounds.size.width / 2.0, y: view.bounds.size.height / 2.0)
        }
    }
    
    private func addSecondaryButtonsToViewSuperview() {
        if let superview = view?.superview {
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
    
    //MARK: - Actions
    
    @objc func primaryButtonTouchDown(button: UIButton) {
        NSLog(#function)
        let newState: RadialMenuState = (state == .closed) ? .open : .closed
        state = newState
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
        state = .closed
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
