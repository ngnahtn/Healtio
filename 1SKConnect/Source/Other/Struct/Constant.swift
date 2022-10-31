//
//  Constant.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import UIKit

struct Constant {
    struct API {
        // https://static.1sk.vn:8403
        static let uploadURL = "https://upload-dev.1sk.vn:8403"
        static let version = "api/v1.2"
#if DEBUG
        static let baseURL =  RCValues.sharedInstance.baseUrl(forKey: .baseUrlDev)
#elseif RELEASE
        static let baseURL =  RCValues.sharedInstance.baseUrl(forKey: .baseUrl)
#endif
    }
    
    struct Number {
        static let animationTime = 0.25
        static let roundCornerRadius: CGFloat = 30
    }
    
    struct Screen {
        static var width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        static var height = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        static var safeAreaInset: UIEdgeInsets {
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows[0]
                return window.safeAreaInsets
            } else {
                let window = UIApplication.shared.keyWindow
                return window?.safeAreaInsets ?? .zero
            }
        }
    }
    
    struct Client {
        static var googleCilentID = "485295735872-u9i0jt5hut0c48pfig1lkgr9d78li9qn.apps.googleusercontent.com"
        static var facebookPermission = ["public_profile", "email"]
    }
}

// MARK: Smart Watch Constaints
let kScreenBounds = UIScreen.main.bounds
let kScreenScale = UIScreen.main.scale
let kScreenSize = kScreenBounds.size
let kScreenW = kScreenSize.width
let kScreenH = kScreenSize.height

let kNavBarItemMargin: CGFloat = kScreenW <= 375 ? 16 : 20

let kUserDefualt = UserDefaults.standard
let kNotificationCenter = NotificationCenter.default
let keyWindow = UIApplication.shared.keyWindow!

func keywindows() -> UIWindow? {
    var window: UIWindow? = nil
    if #available(iOS 13.0, *) {
        for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as?  Set<UIWindowScene>)!) {
            if windowScene.activationState == .foregroundActive {
                window = windowScene.windows.first
                break
            }
        }
        return window
    } else {
        return  UIApplication.shared.keyWindow
    }
}

let kUIDevice = UIDevice()
let kAppInfoDict = Bundle.main.infoDictionary
let kAppCurrentVersion = kAppInfoDict!["CFBundleShortVersionString"]
let kAppBuildVersion = kAppInfoDict!["CFBundleVersion"]
let kDeviceIosVersion = UIDevice.current.systemVersion
let kDeviceIdentifierNumber = UIDevice.current.identifierForVendor
let kDeviceSystemName = UIDevice.current.systemName
let kDeviceModel = UIDevice.current.model
let kDeviceLocalizedModel = UIDevice.current.localizedModel
let isIPhone = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? true : false)
let isIPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? true : false)
let isIPhone4 = (max(kScreenW, kScreenH) < 568.0 ? true : false)
let isIPhone5 = (max(kScreenW, kScreenH) == 568.0 ? true : false)
let isIPhone6 = (max(kScreenW, kScreenH) == 667.0 ? true : false)
let isIPhone6P = (max(kScreenW, kScreenH) == 736.0 ? true : false)
let isIPhoneX = (kScreenH >= 812.0 ? true : false)
let kNavibarH: CGFloat = isiPhoneX() ? 88.0 : 64.0
let kTabbarH: CGFloat = isiPhoneX() ? 49.0 + 34.0 : 49.0
let kStatusbarH: CGFloat = isiPhoneX() ? 44.0 : 20.0
let iPhoneXBottomH: CGFloat = 34.0
let iPhoneXTopH: CGFloat = 24.0
let kIOS8 = (kDeviceIosVersion as NSString).doubleValue >= 8.0
let kIOS9 = (kDeviceIosVersion as NSString).doubleValue >= 9.0
let kIOS10 = (kDeviceIosVersion as NSString).doubleValue >= 10.0
let kIOS11 = (kDeviceIosVersion as NSString).doubleValue >= 11.0
let kIOS12 = (kDeviceIosVersion as NSString).doubleValue >= 12.0
let kDevice = UIDevice.current
var today = DateClass.todayString()

func isiPhoneX() -> Bool {
    let screenHeight = UIScreen.main.nativeBounds.size.height
    if screenHeight == 2436 || screenHeight == 1792 || screenHeight == 2688 || screenHeight == 1624 {
        return true
    }
    return false
}
