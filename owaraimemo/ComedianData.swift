//
//  ComedianData.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/04/04.
//

import Foundation
import Firebase

class ComedianData: NSObject {
    var id: String?
    var comedianName: String?
    
    init(document: QueryDocumentSnapshot) {
        let comedianDic = document.data()
        self.id = document.documentID
        self.comedianName = comedianDic["comedian_name"] as? String
    }
}
