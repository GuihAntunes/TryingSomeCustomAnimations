//
//  ViewController.swift
//  TryingSomeStackedMenu
//
//  Created by Guilherme Antunes Ferreira on 08/11/17.
//  Copyright © 2017 Guihsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    let data = ["Trying Some Animations", "Trying Some Stacked Menu", "Trying Storyboard Id"]
    
    var views = [UIView]()
    var animator:UIDynamicAnimator!
    var gravity:UIGravityBehavior!
    var snap:UISnapBehavior!
    var previousTouchPoint:CGPoint!
    var viewDragging = false
    var viewPinned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.animator = UIDynamicAnimator(referenceView: self.view)
        self.gravity = UIGravityBehavior()
        self.animator.addBehavior(self.gravity)
        self.gravity.magnitude = 4
        
        var offset:CGFloat = 250
        
        for i in 0...data.count - 1 {
            if let view = self.addViewController(atOffset: offset, dataForVC: self.data[i] as AnyObject) {
                self.views.append(view)
                offset -= 50
            }
        }
        
    }
    
    func addViewController(atOffset:CGFloat, dataForVC data:AnyObject?) -> UIView? {
        
        let frame = self.view.bounds.offsetBy(dx: 0, dy: self.view.bounds.size.height - atOffset)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let stackElementVC = storyboard.instantiateViewController(withIdentifier: "StackElement") as! StackElementViewController
        
        if let view = stackElementVC.view {
            view.frame = frame
            view.layer.cornerRadius = 5
            view.layer.shadowOffset = CGSize(width: 2, height: 2)
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 0.5
            
            if let headerString = data as? String {
                stackElementVC.headerString = headerString
            }
            self.addChildViewController(stackElementVC)
            self.view.addSubview(view)
            stackElementVC.didMove(toParentViewController: self)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(gestureRecognizer:)))
            view.addGestureRecognizer(panGestureRecognizer)
            
            let collision = UICollisionBehavior(items: [view])
            collision.collisionDelegate = self
            self.animator.addBehavior(collision)
            
            let boundary = view.frame.origin.y + view.frame.size.height
            
            // Lower Boundary
            var boundaryStart = CGPoint(x: 0, y: boundary)
            var boundaryEnd = CGPoint(x: self.view.bounds.size.width, y: boundary)
            collision.addBoundary(withIdentifier: 1 as NSCopying, from: boundaryStart, to: boundaryEnd)
            
            // Upper Boundary
            boundaryStart = CGPoint(x: 0, y: 0)
            boundaryEnd = CGPoint(x: self.view.bounds.size.width, y: 0)
            collision.addBoundary(withIdentifier: 2 as NSCopying, from: boundaryStart, to: boundaryEnd)
            
            self.gravity.addItem(view)
            
            let itemBehavior = UIDynamicItemBehavior(items: [view])
            self.animator.addBehavior(itemBehavior)
            
            return view
            
        }
        
        return nil
        
    }
    
    func handlePan(gestureRecognizer : UIPanGestureRecognizer) {
        
        
        let touchPoint = gestureRecognizer.location(in: self.view)
        let draggedView = gestureRecognizer.view!
        
        if gestureRecognizer.state == .began {
            let dragStartPoint = gestureRecognizer.location(in: draggedView)
            
            if dragStartPoint.y < 200 {
                self.viewDragging = true
                self.previousTouchPoint = touchPoint
            }
        } else if gestureRecognizer.state == .changed && self.viewDragging {
            let yOffset = self.previousTouchPoint.y - touchPoint.y
            
            draggedView.center = CGPoint(x: draggedView.center.x, y: draggedView.center.y - yOffset)
            self.previousTouchPoint = touchPoint
        } else if gestureRecognizer.state == .ended && self.viewDragging {
            
            self.pin(view: draggedView)
            
            // Add view velocity
            self.addVelocity(toView: draggedView, fromGestureRecognizer: gestureRecognizer)
            
            self.animator.updateItem(usingCurrentState: draggedView)
            self.viewDragging = false
        }
        
        
    }
    
    func pin(view:UIView) {
        
        let viewHasReachedPinLocation = view.frame.origin.y < 100
        
        if viewHasReachedPinLocation {
            if !self.viewPinned {
                var snapPosition = self.view.center
                snapPosition.y += 30
                
                self.snap = UISnapBehavior(item: view, snapTo: snapPosition)
                self.animator.addBehavior(self.snap)

                self.setVisibility(view: view, alpha: 0)
                
                self.viewPinned = true
            }
        } else {
            if self.viewPinned {
                self.animator.removeBehavior(self.snap)
                
                self.setVisibility(view: view, alpha: 1)
                
                self.viewPinned = false
            }
        }
        
    }
    
    func setVisibility(view:UIView, alpha:CGFloat) {
        for aView in self.views {
            if aView != view {
                aView.alpha = alpha
            }
        }
    }
    
    func addVelocity(toView view:UIView, fromGestureRecognizer panGesture:UIPanGestureRecognizer) {
        var velocity = panGesture.velocity(in: self.view)
        velocity.x = 0
        
        
    }
    
    func itemBehavior(forView view:UIView) -> UIDynamicItemBehavior? {
        for behavior in self.animator.behaviors {
            if let itemBehavior = behavior as? UIDynamicItemBehavior {
                if let possibleView = itemBehavior.items.first as? UIView, possibleView == view {
                    return itemBehavior
                }
            }
        }
        
        return nil
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        
        guard identifier != nil else {
            return
        }
        
        let wantedIdentifier = 2 as NSCopying
        
        if wantedIdentifier as! _OptionalNilComparisonType == identifier {
            let view = item as! UIView
            self.pin(view: view)
        }
        
    }
    

}

