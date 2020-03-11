//
//  Copyright © 2017 Tyler White. All rights reserved.
//

import UIKit

enum RadialMenuState {
    case open, closed
}

typealias RadialMenuButtonProgressClosure = ((UIButton, Double) -> ())?

class RadialMenuController {
    let model: RadialMenuModel
    weak var view: RadialMenuView?
    var dynamicAnimator: UIDynamicAnimator?
    var dynamicBehaviors = [UIDynamicBehavior]()
    var state: RadialMenuState = .closed {
        didSet {
            setSecondaryButtonsEnabled(state == .open)
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
    var progressClosure: RadialMenuButtonProgressClosure?
    var selectedButton: UIButton?
    
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
        viewSuperview.bringSubviewToFront(view)
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
        var selectedButtonBehavior: UISnapBehavior?
        if let selectedButton = selectedButton {
            if let index = model.secondaryButtons.firstIndex(of: selectedButton) {
                selectedButtonBehavior = dynamicBehaviors[index] as? UISnapBehavior
            }
            self.selectedButton = nil
        }
        for (i, behavior) in dynamicBehaviors.enumerated() {
            guard let behavior = behavior as? UISnapBehavior else {
                continue
            }
            var selectedButtonDelay: Double = 0.0
            if selectedButtonBehavior == behavior {
                selectedButtonDelay = 0.1
            }
            var point = CGPoint.zero
            if state == .open {
                behavior.damping = 0.0
                point = calculatePointForIndex(i, totalCount: dynamicBehaviors.count, origin: view.center, radius: radius, fullAngle: 360, centeredOnAngle: 90)
            } else {
                behavior.damping = 1.0
                point = view.center
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + ((delay * Double(i)) + selectedButtonDelay), execute: {
                behavior.snapPoint = point
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
                let behavior = UISnapBehavior(item: secondaryButton, snapTo: point)
                behavior.action = {
                    guard let progressClosure = self.progressClosure else {
                        return
                    }
                    
                    let point1 = self.view!.center
                    let point2 = secondaryButton.center
                    let fullDistance = self.radius
                    let partialDistance = self.distanceBetweenPoints(point1, point2)
                    let progress = min(partialDistance / fullDistance, 1.0)
                    progressClosure!(secondaryButton, Double(progress))
                }
                dynamicAnimator?.addBehavior(behavior)
                dynamicBehaviors.append(behavior)
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
    
    private func setSecondaryButtonsEnabled(_ enabled: Bool) {
        for secondaryButton in model.secondaryButtons {
            secondaryButton.isUserInteractionEnabled = enabled
        }
    }
    
    func distanceBetweenPoints(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    //MARK: - Actions
    
    @objc func secondaryButtonTouchUpInside(button: UIButton) {
        selectedButton = button
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
                let buttonIntersectsView = view!.frame.intersects(button.frame)
                if !buttonIntersectsView && button.isUserInteractionEnabled {
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
