
import SwiftUI
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate



class KakaoShareViewModel: ObservableObject {

    func sendKakaoMessage(text: String) {
//      let text = "카카오톡 공유는 카카오 플랫폼 서비스의 대표 기능으로써 사용자의 모바일 기기에 설치된 카카오 플랫폼과 연동하여 다양한 기능을 실행할 수 있습니다."
        let link = Link(webUrl: URL(string: "https://developers.kakao.com"),
                        mobileWebUrl: URL(string: "https://developers.kakao.com"))
        let template = TextTemplate(text: text, link: link)
        guard let templateObj = template.toJsonObject() else { return }
        
        do {
            
            if ShareApi.isKakaoTalkSharingAvailable() {
                ShareApi.shared.shareDefault(templateObject: templateObj) { (sharingResult, error) in
                    if let error = error {
                        print("Error : \(error)")
                    } else if let sharingResult = sharingResult {
                        UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                    }
                }
            } else {
                if let url = ShareApi.shared.makeDefaultUrl(templateObject: templateObj) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        } catch {
            print("Error converting to dictionary or decoding JSON: \(error.localizedDescription)")
        }
    }
    
    
    func kakao() {
        
        // 웹 링크입니다. 카카오톡 인앱 브라우저에서 열립니다.
        let link = Link(webUrl: URL(string: "https://developers.kakao.com"),
                        mobileWebUrl: URL(string: "https://developers.kakao.com"))

        // 앱 링크입니다. 파라미터를 함께 전달하여 앱으로 들어왔을 때 특정 페이지로 이동할 수 있는 역할을 합니다.
        let appLink = Link(androidExecutionParams: ["key1": "value1", "key2": "value2"],
                           iosExecutionParams: ["key1": "value1", "key2": "value2"])
        
        // 버튼들 입니다.
        let webButton = Button(title: "웹으로 보기", link: link)
        let appButton = Button(title: "앱으로 보기", link: appLink)
        
        // 메인이 되는 사진, 이미지 URL, 클릭 시 이동하는 링크를 설정합니다.
        let content = Content(title: "딸기 치즈 케익",
                              imageUrl: URL(string: "https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png")!,
                              link: link)
            
        let template = FeedTemplate(content: content, buttons: [webButton, appButton])
        // 생성한 메시지 템플릿 객체를 jsonObject로 변환
        guard let templateObj = template.toJsonObject() else {return }
        
        // 카카오톡 앱이 있는지 체크합니다.
        if ShareApi.isKakaoTalkSharingAvailable() {
          
            ShareApi.shared.shareDefault(templateObject:templateObj) {(linkResult, error) in
                
                if let error = error {
                    print("error : \(error)")
                }
                else {
                    print("defaultLink(templateObject:templateJsonObject) success.")
                    guard let linkResult = linkResult else { return }
                    UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                }
            }
        } else {
            print("카카오앱이 없습니다")
            // 없을 경우 카카오톡 앱스토어로 이동합니다. (이거 하려면 URL Scheme에 itms-apps 추가 해야함)
            let url = "itms-apps://itunes.apple.com/app/362057947"
            if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
      
    }
}


