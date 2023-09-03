//
//  Utilities.swift
//  family_chat
//
//  Created by Joel Tesfaye on 07/08/2023.
//

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
        
}

final class KeyboardNotification: ObservableObject {
    func noti(viewHeight: CGFloat) -> CGFloat {
        var _height: CGFloat = 0
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let value2 = viewHeight - value.height
            _height = value2 > 0 ? 0: value2
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            _height = 0
        }
        return _height
    }
}
