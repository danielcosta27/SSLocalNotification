//
//  SSLocalNotificationAction.swift
//  SSLocalNotification
//
//  Created by Nicholas Bellucci on 4/3/17.
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

protocol SSLocalNotificationActionDelegate {
    func notificationActionSelected()
}

open class SSLocalNotificationAction: UIButton {
    var delegate: SSLocalNotificationActionDelegate?
    
    private let screenBounds = UIScreen.main.bounds
    private var action: (() -> ())
    
    public init(title: String, fontName: String, tint: UIColor, handler: @escaping (() -> ())) {
        self.action = handler
        
        super.init(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: 50))
        setTitle(title, for: .normal)
        setTitleColor(tint, for: .normal)
        setTitleColor(tint.withAlphaComponent(0.5), for: .highlighted)
        titleLabel?.font = UIFont(name: fontName, size: 16)
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        backgroundColor = .white
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapButton() {
        delegate?.notificationActionSelected()
        action()
    }

}
