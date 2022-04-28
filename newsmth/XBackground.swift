//
//  XBackground.swift
//  newsmth
//
//  Created by Max on 2022/4/28.
//  Copyright © 2022 nju. All rights reserved.
//

import Foundation
import UserNotifications
import Combine

class XBackground: NSObject {
    var keep: AnyCancellable?;
    
    @objc init(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    @objc func start() {
        debugPrint("start bg fetch")
        self.keepLogin()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.showNotification(notice: "jaja")
//        }
    }
    
    func keepLogin() {
        self.keep = SMSession.shared.loadUrl(
            "util_notice,notice",
            convertible: URL(string: "https://m.mysmth.net/user/query/")!)
        .sink { _ in
        } receiveValue: { data in
            print(data)
        }
    }
    
    func showNotification(notice: String) {
        debugPrint("notice", notice)
        let content = UNMutableNotificationContent()
        content.body = notice
        content.sound = UNNotificationSound.default

        guard let nextTriggerDate = Calendar.current.date(
            byAdding: .second,
            value: 4,
            to: Date()) else { return }

          let comps = Calendar.current.dateComponents(
            [.calendar, .year, .month, .day, .hour, .minute, .second, .timeZone],
            from: nextTriggerDate
          )

          let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

          let request = UNNotificationRequest(
            identifier: "xsmth.local",
            content: content,
            trigger: trigger
          )

          UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
              print(error.localizedDescription)
            }
          }
    }
}
