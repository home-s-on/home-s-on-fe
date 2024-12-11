import SwiftUI

public enum LoginType {
    case kakao
    case naver
    case google
    case apple
    case email
    
    var textColor: Color {
        switch self {
        case .kakao, .google:
            return .black
        case .naver, .apple, .email:
            return .white
        }
    }
    
    var backGroundColor: Color {
        switch self {
        case .kakao:
            return Color(red: 1.00, green: 0.90, blue: 0.0)
        case .naver:
            return Color(red: 0.03, green: 0.80, blue: 0.36)
        case .google:
            return .white
        case .apple:
            return .black
        case .email:
            return .mainColor
        }
    }
    
    var logoImage: Image {
        switch self {
        case .kakao:
            return Image(systemName: "message.fill")
        case .naver:
            return Image(systemName: "n.square.fill")
        case .google:
            return Image(systemName: "g.circle")
        case .apple:
            return Image(systemName: "applelogo")
        case .email:
            return Image(systemName: "at")
        }
    }
}
