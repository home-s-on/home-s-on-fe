//
//  TriggerViewModel.swift
//  home-s-on-fe
//
//  Created by 박미정 on 12/4/24.
//

import SwiftUI
import UserNotifications

struct FeatureFlags {
    static let TEST = true
}

class TriggerViewModel: ObservableObject {
    
    func intervalTrigger(subtitle: String, body: String, timeinterval: Double = 5, isRepeat: Bool = false) {
        
        let content = makeContent(subtitle: subtitle, body: body)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeinterval, repeats: isRepeat)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //알림이 여러개 있을 거니까 추가해준다
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("알림설정에 실패했습니다.")
            }
            print("알림설정에 성공했습니다.")
        }
    }
    
    
    func calenderTrigger(subtitle: String, body: String, timeinterval: Double = 5, isRepeat: Bool = false) {
        print("calenderTrigger")
        
        let content = makeContent(subtitle: subtitle, body: body)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()//등록되어 있는거 다 날림....?
        
        var currentHour = 12
        var currentMinute = 25
        //테스트 용
        if FeatureFlags.TEST {
            let now = Date()
            let calendar = Calendar.current
            currentHour = calendar.component(.hour, from: now)
            currentMinute = calendar.component(.minute, from: now)
        }
        
        print("currentMinute \(currentMinute)")
        
        var dateComponents = DateComponents()
        dateComponents.weekday // 나중에 반복에서 가져오기
        dateComponents.hour = currentHour
        dateComponents.minute = currentMinute+1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isRepeat)//repeat true이면 매일, hour:minute에 알람
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //알림이 여러개 있을 거니까 추가해준다
        UNUserNotificationCenter.current().add(request)
    }
    
    func makeContent(subtitle: String, body: String)-> UNNotificationContent{
        let content = UNMutableNotificationContent()
        content.title = "HOME'S ON"
        content.subtitle = subtitle
        content.body = body
        content.userInfo = ["name": UserDefaults.standard.string(forKey: "nickname") ?? ""]
        return content
    }
    
}

