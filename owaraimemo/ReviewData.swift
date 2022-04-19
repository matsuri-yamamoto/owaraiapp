//
//  ReviewData.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/04/04.
//

import UIKit
import Firebase

class ReviewData: NSObject {
    var id: String
    var comedianId: String?
    var userId: String?
    var score: Double?
    var privateFlag: Bool?
    var comment: String?
    var createDateTime: Timestamp?
    var updateDatetime: Timestamp?
    var deleteFlag: Bool?
    var deleteDateTime: Timestamp?
    var myreview: Bool = false
    
    init(document: QueryDocumentSnapshot) {
        
        self.id = document.documentID
        let reviewDic = document.data()
        comedianId = reviewDic["comedian_id"] as? String
        userId = reviewDic["user_id"] as? String
        score = reviewDic["score"] as? Double
        privateFlag = reviewDic["private_flag"] as? Bool
        comment = reviewDic["comment"] as? String
        let timestamp = reviewDic["date"] as? Timestamp
        createDateTime = reviewDic["create_datetime"] as? Timestamp
        updateDatetime = reviewDic["update_datetime"] as? Timestamp
        deleteDateTime = reviewDic["delete_datetime"] as? Timestamp

    }
}
