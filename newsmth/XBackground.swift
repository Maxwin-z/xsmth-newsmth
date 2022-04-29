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
import BackgroundTasks
import StoreKit

class XBackground: NSObject {
    var keep: AnyCancellable?;
    let bgTaskID: String = "me.maxwin.xsmth.keeplogin"
    var count = 0

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
        self.setupBgTasks()
    }
    
    @objc func setupBackgroundTask() {
        print("[BGTASK] setupBackgroundTask")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: self.bgTaskID, using: nil) { task in
            print("[BGTASK] execute bg task")
            self.count += 1
            self.showNotification(body: "", badge: NSNumber(value: self.count))
            task.setTaskCompleted(success: true)
            URLSession.shared.dataTask(with: URL(string: "https://m.mysmth.net/user/query/")!) { data, rsp, error in
                if (SMAccountManager.instance().isLogin) {
                    self.scheduleBackgroundTask()
                }
            }
        }
    }
    
    @objc func scheduleBackgroundTask() {
        print("[BGTASK] scheduleBackgroundTask")
        let request = BGProcessingTaskRequest(identifier: self.bgTaskID)
        request.requiresNetworkConnectivity = true

        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
        do {
           try BGTaskScheduler.shared.submit(request)
            print("[BGTASK] scheduleBackgroundTask success")
        } catch {
           print("[BGTASK] Could not schedule bg task", error)
        }
    }
    
    
    func setupBgTasks() {
//        debugPrint("start bg fetch")
//        self.keepLogin()
    }
    
    func keepLogin() {
        self.keep = SMSession.shared.loadUrl(
            "util_notice,notice",
            convertible: URL(string: "https://m.mysmth.net/user/query/")!)
        .sink { _ in
        } receiveValue: { data in
            if let notice = data as? SMNotice {
                let badge = notice.mail + notice.at + notice.reply
                let body = "新的消息(\(badge))"
                if (badge > 0) {
                    self.showNotification(body: body, badge: NSNumber(value: badge))
                }
            }
        }
    }
    
    func showNotification(body: String, badge: NSNumber) {
        debugPrint("notice", body)
        let content = UNMutableNotificationContent()
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = badge

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
