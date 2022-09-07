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
    
    struct SetUserId: UserProperty {
        var value: String
        public let name = UserId
        
        init(userID: String) {
            self.value = userID
        }
        
    }
}
