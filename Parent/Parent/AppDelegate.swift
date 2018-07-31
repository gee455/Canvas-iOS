//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
import UIKit
import CanvasCore
import Fabric
import Crashlytics

class AppDelegate: UIResponder, AppDelegateProtocol {

    var window: UIWindow?

    var topViewController: UIViewController {
        var topViewControler = window!.rootViewController!
        while topViewControler.presentedViewController != nil {
            topViewControler = topViewControler.presentedViewController!
        }
        return topViewControler
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Fabric.with([Crashlytics.self])
        BuddyBuildSDK.setup()
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)

        if RegionPicker.shared.pickedRegion == nil {
            if let _ = Keymaster.sharedInstance.mostRecentSession() { // Currently already signed in, without a region. They are already in the original default region
                RegionPicker.shared.pickedRegion = .default
            } else {
                RegionPicker.shared.pickBestRegion()
            }
        }

        WhizzyWigView.setOpenURLHandler { url in
            let webBrowser = WebBrowserViewController(useAPISafeLinks: false)
            webBrowser.url = url
            let nav = UINavigationController(rootViewController: webBrowser)
            self.topViewController.present(nav, animated: true, completion: nil)
        }
        
        Router.sharedInstance.addRoutes()

        Keymaster.sharedInstance.useSharedCredentials = false
        if let session = Keymaster.sharedInstance.mostRecentSession() {
            Keymaster.sharedInstance.currentSession = session
            Router.sharedInstance.session = session
            Router.sharedInstance.routeToLoggedInViewController()
        } else {
            Router.sharedInstance.routeToLoggedOutViewController()
        }

        window!.makeKeyAndVisible()

        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            routeToRemindable(from: notification)
        }

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppStoreReview.requestReview()

        if let session = Keymaster.sharedInstance.currentSession {
            AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return route(url)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        // On, iOS 10.0b1 application:didReceiveLocalNotification is not being called when opening the app from a local notification and making it transistion from the background. Instead, this is being called. Not
        // sure if this is a bug or some change in API behavior.
        // 
        // This api exists as of 9.0, but the odd behavior only exists as of 10.0, so...
        if #available(iOS 10.0, *) {
            routeToRemindable(from: notification)
        }
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if application.applicationState == .active {
            let alert = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("View", comment: ""), style: .cancel, handler: { [unowned self] _ in
                self.routeToRemindable(from: notification)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in }))
            topViewController.present(alert, animated: true, completion: nil)
        } else if application.applicationState == .inactive {
            routeToRemindable(from: notification)
        }
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return route(url)
    }

    func route(_ url: URL) -> Bool {
        if url.scheme == "canvas-parent" {
            if let _ = Keymaster.sharedInstance.currentSession {
                Router.sharedInstance.route(self.topViewController, toURL: url, modal: false)
            } else if let window = self.window, let vc = Router.sharedInstance.viewControllerForURL(url) {
                Router.sharedInstance.route(window, toRootViewController: vc)
            } else {
                // should never get here... should either have a session or a window!
            }
            
            return true
        }
        
        return false
    }
    
    fileprivate func routeToRemindable(from notification: UILocalNotification) {
        if let urlString = notification.userInfo?[RemindableActionURLKey] as? String, let url = URL(string: urlString) {
            Router.sharedInstance.route(topViewController, toURL: url, modal: true)
        }
    }

}

