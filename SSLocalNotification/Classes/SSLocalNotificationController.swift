//
//  SSLocalNotificationController.swift
//  SSLocalNotification
//
//  Created by Nicholas Bellucci on 3/29/17.
//  Copyright © 2017 Nicholas Bellucci. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//    associated documentation files (the "Software"), to deal in the Software without restriction,
//    including without limitation the rights to use, copy, modify, merge, publish, distribute,
//    sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//    substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

public enum SSLocalNotificationStyle {
    case light
    case dark
}

open class SSLocalNotificationController: UIView, SSLocalNotificationActionDelegate {
    
    private let screenBounds = UIScreen.main.bounds
    
    // Contents that create the notification
    private var screenOverlay  = UIVisualEffectView()
    private var blurBackground = UIVisualEffectView()
    
    // Contents that make up the notification
    private let contentView    = UIView()
    private let imageView      = UIImageView()
    private let titleLabel     = UILabel()
    private let messageLabel   = UILabel()
    private let grabber        = UIView()
    private var expanded       = Bool()
    
    // Contents that make up the notification actions
    private var actionView     = UIView()
    private var actionsArray   = NSMutableArray()
    
    // Used as references for the pan gesture
    private var origin   = CGPoint()
    private var movement = CGFloat()
    
    
    // Timer for delayed dismissal of notification
    private var timer = Timer()
    
    
    // Type alias for the completion blocks
    private typealias completion = (_ success:Bool) -> Void
    
    
    // The time that the notification will sit on the screen before dismissing on its own
    open var dismissDelay = TimeInterval(3.0)
    
    
    // The blur style of the notification
    private var style = UIBlurEffectStyle.light
    
    
    // Determines whether or not the notification can expand
    open var expandable = Bool()
    
    
    // The image that is used in the imageView
    open var image = UIImage()
    
    
    // A block called when the user taps on the notification
    open var didTapLocalNotification: (() -> ())?
    
    
    // A block called when the user dismisses the notification
    open var didDismissLocalNotification: (() -> ())?
    
    // MARK: - Initializers
    
    // Required initializer of the class
    public required init(title: String, message: String, preferredStyle: SSLocalNotificationStyle) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        frame           = CGRect(x: 0, y: -95, width: screenBounds.size.width, height: 95)
        backgroundColor = .clear
        
        let view = UIView(frame: screenBounds)
        view.backgroundColor = .black
        view.alpha           = 0.3
        
        screenOverlay.frame    = screenBounds
        screenOverlay.alpha    = 0
        screenOverlay.isHidden = true
        screenOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(sender:))))
        
        titleLabel.text = title
        messageLabel.text = message
        preferredStyle == .light ? (style = .light)
            : (style = .dark)
        
        actionView.frame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: 50)
        actionView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.8, alpha: 1)
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:))))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(sender:))))
        
        didTapLocalNotification = {}
        didDismissLocalNotification = {}
        
        screenOverlay.contentView.addSubview(view)
        UIApplication.shared.keyWindow?.addSubview(screenOverlay)
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Builds all of the subviews that make up the notification
    // Make sure to run the public setters in order to set the necessary information
    private func initializeSubviews() {
        
        // The blurBackground is the height of the UIScreen plus the height of the notification
        // This is so that while panning the notification appears to enlongate
        // If accessibility prevents the blur then the background color is just white
        let blurEffect = UIBlurEffect(style: style)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            // Add blur effect to the screen overlay
            screenOverlay.effect = blurEffect
            
            // Add the blur effect to the notification background and add the background to self
            blurBackground = UIVisualEffectView(effect: blurEffect)
        }
        else {
            // Runs if user has accessibility enabled that prevents blur
            blurBackground.backgroundColor  = .white
        }
        
        // Add the blur effect to the notification background and add the background to self
        blurBackground.frame            = CGRect(x: 0, y: -screenBounds.size.height, width: frame.size.width, height: screenBounds.size.height + 95)
        blurBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurBackground.layer.addBorder()
        
        // Content view contains the image, title, and message
        contentView.frame           = CGRect(x: 0, y: 20, width: frame.size.width, height: 75)
        contentView.backgroundColor = .clear
        
        // Imageview setup and placement
        imageView.frame               = CGRect(x: 15, y: 5, width: 50, height: 50)
        imageView.image               = image
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius  = 25
        imageView.backgroundColor     = .darkGray
        
        // Title label frame
        titleLabel.frame = CGRect(x: 75, y: 10, width: frame.size.width - 90, height: 20)
        
        // Message label frame
        messageLabel.frame = CGRect(x: 75, y: 30, width: frame.size.width - 90, height: 20)
        
        // Imageview setup and placement
        grabber.frame               = CGRect(x: frame.size.width/2 - 20, y: contentView.frame.size.height - 10, width: 40, height: 5)
        grabber.backgroundColor     = UIColor(hue: 0, saturation: 0, brightness: 0.85, alpha: 1)
        grabber.layer.masksToBounds = true
        grabber.layer.cornerRadius  = 2.5
        
        // Adds content view to self and then adds subviews to the content view
        addSubview(blurBackground)
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(grabber)
    }
    
    
    // MARK: - Setters
    
    // Setter for the title of the notification
    // All values default to nil if not provided
    open func setTitleFont(fontName: String? = nil, color: UIColor? = nil) {
        titleLabel.font      = UIFont(name: fontName!, size: 16)
        titleLabel.textColor = color
    }
    
    // Setter for the message of the notification
    // All values default to nil if not provided
    open func setMessageFont(fontName: String? = nil, color: UIColor? = nil) {
        messageLabel.font      = UIFont(name: fontName!, size: 14)
        messageLabel.textColor = color
    }
    
    
    // Adds an action button to the local notification
    // Multiple actions can be added
    open func addAction(action: SSLocalNotificationAction) {
        action.delegate = self
        addActionToView(action: action)
        UIApplication.shared.keyWindow?.addSubview(actionView)
    }
    
    
    // Calculates the number of actions added to the local notification
    // Determines how large the action view needs to be
    private func addActionToView(action: SSLocalNotificationAction) {
        actionsArray.add(action)
        
        let newHeight     = CGFloat(50 * actionsArray.count)
        let separatorLine = CGFloat(0.5 * Double(actionsArray.count - 1))
        
        action.frame.origin = CGPoint(x: 0, y: newHeight - 50 + separatorLine)
        actionView.frame    = CGRect(x: 0, y: screenBounds.height + newHeight, width: screenBounds.width, height: newHeight + separatorLine)
        
        actionView.addSubview(action)
    }
    
    
    // Function called to present the local notification
    open func presentLocalNotification() {
        initializeSubviews()
        originate(time: 0.5) { (completion) in
            self.origin = self.center
            self.startTimer()
        }
    }
    
    // MARK: - SSLocalNotificationActionDelegate
    
    
    // Delegate function that is called when user selects an action to perform
    // This will dismiss the notification
    internal func notificationActionSelected() {
        dismiss(time: 0.3)
    }
    
    
    // MARK: - Animators
    
    
    // Private function to set notification back to original positioning
    private func originate(time: TimeInterval) {
        UIView.animate(withDuration: time, animations: {
            self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        })
    }
    
    
    // Private function to set notification back to original positioning
    // Completion block used to restart timer
    private func originate(time: TimeInterval, completion: @escaping completion) {
        UIView.animate(withDuration: time, animations: {
            self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }, completion: { (dismissed) in
            completion(true)
        })
    }
    
    
    // Private function to expand the notification when pulled on
    // Extension only runs if the user pulls the notification with some speed
    private func expand() {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else {
            // Fallback on earlier versions
        }
        
        let height = (self.messageLabel.text?.height(withConstrainedWidth: self.messageLabel.frame.size.width, font: self.messageLabel.font))! - 5
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        
        screenOverlay.isHidden = false
        
        self.blurBackground.layer.sublayers?.remove(at: 2)
        self.blurBackground.backgroundColor = .white
        
        self.layer.shadowOpacity = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.frame                   = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 75 + height)
            self.messageLabel.frame.size = CGSize(width: self.messageLabel.frame.size.width, height: height + 5)
            self.contentView.frame.size  = CGSize(width: self.contentView.frame.size.width, height: self.contentView.frame.size.height + height - 20)
            self.grabber.frame.origin    = CGPoint(x: self.frame.size.width/2 - 20, y: self.contentView.frame.size.height - 10)
            self.actionView.frame.origin = CGPoint(x: 0, y: self.screenBounds.height - CGFloat(50 * self.actionsArray.count))
            self.blurBackground.frame    = CGRect(x: 0, y: -self.screenBounds.size.height + height - 20, width: self.frame.size.width, height: self.screenBounds.size.height + 95)
            self.screenOverlay.alpha = 1
        }, completion: { (dismissed) in
            self.origin = self.center
        })
    }
    
    
    // Private function to dismiss the notification in a certain time
    // Self is removed after completion
    @objc private func dismiss(time: TimeInterval) {        
        UIView.animate(withDuration: time, animations: {
            self.frame                   = CGRect(x: 0, y: -self.frame.size.height, width: self.screenBounds.size.width, height: self.frame.size.height)
            self.actionView.frame.origin = CGPoint(x: 0, y: self.screenBounds.height)
            self.screenOverlay.alpha = 0
        }, completion: { (dismissed) in
            self.didDismissLocalNotification!()
            self.removeFromSuperview()
            self.screenOverlay.removeFromSuperview()
            self.actionView.removeFromSuperview()
        })
    }
    
    
    // MARK: - Timer Functions
    
    // Private function that starts the dismissal timer
    // Timer duration can be set with the dismissDelay property
    private func startTimer() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: self.dismissDelay, target: self, selector: #selector(self.timerDismiss(timer:)), userInfo: 0.5, repeats: true)
        }
    }
    
    
    // Private function to dismiss notification with the time interval set by the userInfo of the timer
    @objc private func timerDismiss(timer: Timer) {
        UIView.animate(withDuration: timer.userInfo as! TimeInterval, animations: {
            self.frame = CGRect(x: 0, y: -95, width: self.screenBounds.size.width, height: 95)
        })
    }
    
    
    // MARK: - Gesture Functions
    
    // Private function that handles the pan gesture added to self
    // This function will handle the dismissal and expansion based on users pull direction
    @objc private func didPan(sender: UIPanGestureRecognizer!) {
        let translation = sender.translation(in: self)
        sender.setTranslation(CGPoint(x: 0, y: 0) , in: self)
        movement = origin.y + center.y
        
        if center.y > origin.y {
            let time = getTime(sender: sender)
            center   = CGPoint(x: center.x, y: center.y + translation.y/(movement * 0.1))
            
            if time <= 1.0 { timer.invalidate() }
        }
        else if center.y <= origin.y {
            center = CGPoint(x: center.x, y: center.y + translation.y)
        }
        
        switch sender.state {
        case .began:
            timer.invalidate()
        case .ended:
            let time = getTime(sender: sender)
            
            if center.y > origin.y && time > 1.0 && !expanded {
                originate(time: 0.2)
                startTimer()
            }
            else if center.y <= origin.y {
                time <= 1.0 ? dismiss(time: time)
                    : dismiss(time: 0.3)
            }
            else if !expanded && expandable {
                expand()
                expanded = true
            }
            else {
                originate(time: 0.2)
                if !expandable { startTimer() }
            }
        default:
            break
        }
    }
    
    
    // Private function that handles the tap gesture added to self
    // A custom function can be set using by assigning a function to the tapActionBlock property
    @objc private func didTap(sender: UITapGestureRecognizer!) {
        sender == screenOverlay.gestureRecognizers?[0] ? dismiss(time: 0.3) : didTapLocalNotification!()
    }
    
    
    // Returns the speed of a swipe based on the pan velocity
    // The time is used:
    // To determine how fast the notification should animate out
    // To determine if the user swipes fast enough to expand the notification
    private func getTime(sender: UIPanGestureRecognizer) -> TimeInterval {
        let yPoints   = frame.size.height
        let velocityY = sender.velocity(in: self).y
        var time      = TimeInterval()
        time          = Double(yPoints)/Double(velocityY)
        
        return time
    }
    
}


// MARK: - Extensions

// Calculates the height of the message label
// Once the height is calculated and returned the notification can expand to the right height
private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox    = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}


// Creates bottom border for the notification
// This is removed when the notification is expanded
private extension CALayer {
    func addBorder() {
        let border             = CALayer()
        let thickness          = CGFloat(0.6)
        let color              = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.15)
        border.frame           = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}
