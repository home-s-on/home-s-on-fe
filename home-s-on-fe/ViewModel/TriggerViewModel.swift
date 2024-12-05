//
//  TriggerViewModel.swift
//  home-s-on-fe
//
//  Created by 박미정 on 12/4/24.
//

import SwiftUI
import UserNotifications


class TriggerViewModel: ObservableObject {
    
    func intervalTrigger() {
        print("intervalTrigger")
        let content = UNMutableNotificationContent()
        content.title = "HOME'S ON"
        content.subtitle = "서브 타이틀"
        content.body = "설정하신 인터벌 노티피케이션을 알려드립니다."
        content.userInfo = ["name":"정년이"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //알림이 여러개 있을 거니까 추가해준다
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("알림설정에 실패했습니다.")
            }
            print("알림설정에 성공했습니다.")
        }
    }
    
    
    func calenderTrigger() {
        let content = UNMutableNotificationContent()
        content.title = "Calender Notification Trigger"
        content.subtitle = "서브 타이틀"
        content.body = "설정하신 캘린더 노티피케이션을 알려드립니다."
        content.userInfo = ["name":"정년이"]
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()//등록되어 있는거 다 날림
        
        var dateComponents = DateComponents()
        dateComponents.weekday // 0이 sunday?
        dateComponents.hour = 14
        dateComponents.minute = 46
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)//repeat true이면 매일 2:46분에 알람
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        //알림이 여러개 있을 거니까 추가해준다
        UNUserNotificationCenter.current().add(request)
    }
    
}

