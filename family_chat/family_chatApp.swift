//
//  family_chatApp.swift
//  family_chat
//
//  Created by Joel Tesfaye on 22/07/2023.
//

import SwiftUI
import Firebase


@main
struct family_chatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor(Color.shared.mainTextColor)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(Color.shared.mainTextColor)]
        //UINavigationBar.appearance().tintColor = UIColor(Color.shared.secondaryColor)
            //UITableView.appearance().backgroundColor = UIColor.clear
//        UINavigationBar.appearance().backgroundColor = UIColor(Color("tabView"))
        UITabBar.appearance().backgroundColor = UIColor(Color("tabView"))
        
        }
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
