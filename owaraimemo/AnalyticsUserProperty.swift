//
//  AnalyticsUserProperty.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/08/12.
//

import Foundation


public protocol UserProperty {
    var value: String { get }
    var name: String { get }
}

struct AnalyticsUserProperty {
    
    public static let UserId = "UserId"
    
    struct SkinDiagnosisStart: UserProperty {
        public let value = "肌測定利用開始"
        public let name = "skin_diag_start"
    }
    
    struct SkinDiagnosisEnd: UserProperty {
        public let value = "肌測定利用完了"
        public let name = "skin_diag_end"
    }
    
    
    struct ProductProposalClick: UserProperty {
        public let value = "商品案内クリック"
        public let name = "product_rec_click"
    }
    
    struct TopInvitationButtonClick: UserProperty {
        public let value = "招待状ボタンクリック_下部"
        public let name = "ticket_btn_click_btm"
    }
    
    struct MenuInvitationButtonClick: UserProperty {
        public let value = "招待状ボタンクリック_メニュー"
        public let name = "ticket_btn_click_menu"
    }
    
    
    struct LunchFronPushNotification: UserProperty {
        var value: String
        public let name = "push_msg_access"
        init(message: String) {
            self.value = message
        }
    }
    
    struct SetUserId: UserProperty {
        var value: String
        public let name = UserId
        
        init(userID: String) {
            self.value = userID
        }
        
    }
}
