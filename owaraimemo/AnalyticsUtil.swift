//
//  AnalyticsUtil.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/08/12.
//

import Foundation
import FirebaseAnalytics
import FirebaseFirestore
import Firebase

final class AnalyticsUtil {
    
    //ログイベントを作る
    private class func logEvent(_ event: AnalyticsEvent) {
        //アナリティクスに飛ばしている
        Analytics.logEvent(event.name.rawValue, parameters: event.parameters)
        print("AnalyticsUtil logEvent type:\(event.name.rawValue), parameters:\(event.parameters)")
    }
    
    /// usage example
    /// Analytics.logEvent("screen_view2", parameters: ["screen_name": "00_ホーム画面"])
    ///
    public class func sendScreenName(_ event: ScreenEvent) {
        logEvent(event)
    }
    
    /// usage example
    /// Analytics.logEvent("action", parameters: [ "screen_name":"00_診断完了",    "action_type": "タップ",    "action_label": "診断完了_結果を見る" ])
    ///
    ///アクション定義
    public class func sendAction(_ event: ActionEvent) {
        logEvent(event)
    }
    
    
    /// usage example
    /// Analytics.setUserProperty("肌測定利用開始", forName: "skin_diag_start")
    ///
    public class func setUserProperty(_ propaty: UserProperty) {
        guard propaty.name == AnalyticsUserProperty.UserId else {
            Analytics.setUserProperty(propaty.value, forName: propaty.name)
            return
        }
        Analytics.setUserID(propaty.value)
    }
    
    
}

//イベントを定義
public enum EventName: String {
    case screenView2 = "screen_view2"
    case action
}

public protocol AnalyticsEvent {
    var name: EventName { get }
    var parameters: [String: Any] { get }
}

//スクリーンイベント(画面発生時)に付随
public struct ScreenEvent: AnalyticsEvent {
    public let name = EventName.screenView2
    public let parameters: [String: Any]
    init(screenName: ScreenName) {
        self.parameters = ["screen_name": "\(screenName.rawValue)", "uid": Auth.auth().currentUser?.uid ?? ""]
    }
}

//画面の名前を定義
public enum ScreenName: String {
    case startVC = "pv_StartVC"
    case recLoginVC = "pv_RecLoginVC"
    case loginVC = "pv_LoginVC"
    case createNewVC = "pv_CreateNewVC"
    case firstTabVC = "pv_FirstTabVC"
    case secondTabVC = "pv_SecondTabVC"
    case thirdTabVC = "pv_ThirdTabVC"
    case forthTabVC = "pv_ForthTabVC"
    case searchVC = "pv_SearchVC"
    case myReviewVC = "pv_MyReviewVC"
    case comedianDetailVC = "pv_ComedianDetailVC"
    case reviewVC = "pv_ReviewVC"
    case settingVC = "pv_SettingVC"
    
}

//アクション名を定義
public struct ActionEvent: AnalyticsEvent {
    public let name = EventName.action
    public let parameters: [String: Any]
    init(screenName: ScreenName, actionType: ActionType, actionLabel: ActionLabel) {
        self.parameters = ["screen_name": "\(screenName.rawValue)", "action_type": "\(actionType.rawValue)", "action_label": "\(actionLabel.value)", "uid": Auth.auth().currentUser?.uid ?? ""]
    }
}

//アクションタイプを定義(アクションの種類)
public enum ActionType: String {
    case tap = "タップ"
    case pushNotification = "push通知起動"
}

public enum ActionLabel {
    case pushNotification(String)
    case template(ActionLabelTemplate)
}


public enum ActionLabelTemplate: String {
    
    case cellTap = "セルタップ"
    case twitterLoginTap = "Twitterログイン導線タップ"
    case toMailLoginTap = "メアドログイン導線タップ"
    case toMailNewTap = "メアド新規導線タップ"
    case mailNewTap = "メアド新規作成タップ"
    case mailLoginTap = "メアドログインタップ"

    
}

//アクションラベルを定義(そのアクションで何が発生するか)
extension ActionLabel {
    public var value: String {
        if case let ActionLabel.pushNotification(message) = self {
            return message
        } else if case let ActionLabel.template(template) = self {
            return template.rawValue
        } else {
            return ""
        }
    }
}


