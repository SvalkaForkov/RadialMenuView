//
//  Copyright © 2017 Tyler White. All rights reserved.
//

import UIKit

enum RadialMenuState {
    case open, closed
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
    var delay: Double = 0.1
    var touchIsInsideView: Bool = false
    var touchDidExitView: Bool = false
    
    //MARK: - Setup & Teardown
    
    init(withModel model: RadialMenuModel, view: RadialMenuView) {
        self.model = model
        self.view = view
        configureView()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(i), execute: {
                snapBehavior.snapPoint = point
            })
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
    
    private func configureView() {
        if let view = view {
            view.isOpaque = false
        }
    }
    
    private func configurePrimaryButton() {
        model.primaryButton.isUserInteractionEnabled = false
    }
    
    private func configureSecondaryButtons() {
        for secondaryButton in model.secondaryButtons {
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTouchUpInside), for: .touchUpInside)
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
    
    @objc func secondaryButtonTouchUpInside(button: UIButton) {
        state = .closed
    }
    
    //MARK: - Touches
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .closed {
            state = .open
        } else {
            state = .closed
        }
        touchIsInsideView = true
        touchDidExitView = false
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state == .open else {
            return
        }
        
        for (_, touch) in touches.enumerated() {
            var point = touch.location(in: view)
            let viewContainsTouch = view!.point(inside: point, with: event)
            if viewContainsTouch {
                if !touchIsInsideView {
                    model.primaryButton.sendActions(for: .touchDragEnter)
                    touchIsInsideView = true
                }
                return
            } else {
                if touchIsInsideView {
                    model.primaryButton.sendActions(for: .touchDragExit)
                    touchIsInsideView = false
                    touchDidExitView = true
                }
            }
            for button in model.secondaryButtons {
                let intersects = view!.frame.intersects(button.frame)
                if !intersects {
                    point = touch.location(in: button)
                    if button.point(inside: point, with: event) {
                        button.sendActions(for: .touchUpInside)
                        return
                    }
                }
            }
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for (_, touch) in touches.enumerated() {
            let point = touch.location(in: view)
            let viewContainsTouch = view!.point(inside: point, with: event)
            if viewContainsTouch && touchDidExitView {
                state = .closed
            }
        }
        touchIsInsideView = false
        touchDidExitView = true
    }
    
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .closed
        touchIsInsideView = false
        touchDidExitView = true
    }
}
