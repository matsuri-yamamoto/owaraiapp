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
import UIKit

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
    
//    public class func sendActionForFirstTabCellTap(_ event: ActionEventForFirstTabCellTap) {
//        logEvent(event)
//    }

    
    
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
    case pageView = "pv"
    case action
}

public protocol AnalyticsEvent {
    var name: EventName { get }
    var parameters: [String: Any] { get }
}

//スクリーンイベント(画面発生時)に付随
public struct ScreenEvent: AnalyticsEvent {
    public let name = EventName.pageView
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

public struct ActionEventForFirstTabCellTap: AnalyticsEvent {
    public let name = EventName.action
    public let parameters: [String: Any]
    
    var firstTabVC = FirstTabViewController()
    
    init(screenName: ScreenName, actionType: ActionType, actionLabel: ActionLabel) {
        self.parameters = ["screen_name": "\(screenName.rawValue)", "action_type": "\(actionType.rawValue)", "action_label": "\(actionLabel.value)", "uid": Auth.auth().currentUser?.uid ?? "", "comedian_id": firstTabVC.comedianId]
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
    
    case twitterLoginPassTap = "Twitterログインタップ"
    case MailLoginPassTap = "メアドログイン導線タップ"
    case MailNewPassTap = "メアド新規導線タップ"
    case mailNewTap = "メアド新規作成タップ"
    case mailLoginTap = "メアドログインタップ"
    case cellTap = "セルタップ"
    case searchBarTap = "検索バータップ"
    case searchWordInput = "検索文字入力"
    case searchedCellTap = "検索結果セルタップ"
    case myPageRecLoginPush = "マイページ経由RecLogin起動"
    case myPageCellTap = "マイページセルタップ"
    case myPageStockButtonTap = "マイページストックボタンタップ"
    case myPageReviewButtonTap = "マイページレビューボタンタップ"
    case comedianReviewRecLoginPush = "芸人詳細レビューボタン経由RecLogin起動"
    case comedianStockRecLoginPush = "芸人詳細ストックボタン経由RecLogin起動"
    case reviewButtonTap = "芸人詳細レビューボタンタップ"
    case stockButtonTap = "芸人詳細ストックボタンタップ"
    case comedianLikeReviewReLoginPush = "いいねボタン経由RecLogin起動"
    case comedianLikeReviewTap = "いいねボタンタップ"
    case reviewSaveButtonTap_noTwitter = "レビュー保存ボタンタップ(Twitterシェアなし)"
    case reviewSaveButtonTap_shareTwitter = "レビュー保存ボタンタップ(Twitterシェアあり)"
    case reviewPrivateSaveButtonTap = "レビュー非公開保存ボタンタップ"
    
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


