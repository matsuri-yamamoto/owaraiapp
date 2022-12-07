//
//  MycalendarController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2022/12/02.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorageUI
import FSCalendar

class MyCalendarViewController: UIViewController ,FSCalendarDataSource ,FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    
    var followComedianIdArray: [String] = []
    var followComedianIdArray1: [String] = []
    var followComedianIdArray2: [String] = []
    var followComedianIdArray3: [String] = []
    var followComedianIdArray4: [String] = []
    var followComedianIdArray5: [String] = []
    var followComedianIdArray6: [String] = []
    var followComedianIdArray7: [String] = []
    var followComedianIdArray8: [String] = []
    var followComedianIdArray9: [String] = []
    var followComedianIdArray10: [String] = []
    
    var eventDate :String = ""
    
    var eventIdArray: [String] = []
    var uniqueEventIdArray: [String] = []
    
    //表示させるeventIdのイベント名、エリア、配信有無、時間、会場を格納
    var eventNameArray: [String] = []
    var eventAreaArray: [String] = []
    var eventOnlineFlagArray: [String] = []
    var eventStartArray: [String] = []
    var eventPlaceArray: [String] = []
    var eventCastArray: [String] = []
    var eventUrlArray: [String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MyCalendarTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MyCalendarCell")
        
        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        
        // gesture settings
        let swipUpGesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(MyCalendarViewController.swipUp))
        swipUpGesture.direction = .up
        let swipDownGesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(MyCalendarViewController.swipDown))
        swipDownGesture.direction = .down
        self.calendar.addGestureRecognizer(swipUpGesture)
        self.calendar.addGestureRecognizer(swipDownGesture)
        
        
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //フォロー中の芸人さんのArrayを取得
        self.getFollowComedian()
        
        
    }
    
    @objc func swipUp() {
        print("swiped up")
        self.calendar.setScope(.week, animated: true)
    }
    
    @objc func swipDown() {
        print("swiped down")
        self.calendar.setScope(.month, animated: true)
    }
    
    func getFollowComedian() {
        
        
        
        self.db.collection("follow_comedian").whereField("user_id", isEqualTo: self.currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.followComedianIdArray.append(document.data()["comedian_id"] as! String)
                    
                }
                
                let documentCount = querySnapshot?.documents.count
                
                self.followComedianIdArray1 = Array(self.followComedianIdArray[0..<documentCount!])
                
                print("followComedianIdArray1:\(self.followComedianIdArray1)")
                
                
                if (querySnapshot?.documents.count)! > 10 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[10..<20])
                    
                }
                if (querySnapshot?.documents.count)! > 20 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[20..<30])
                    
                }
                if (querySnapshot?.documents.count)! > 30 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[30..<40])
                    
                }
                if (querySnapshot?.documents.count)! > 40 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[40..<50])
                    
                }
                
                if (querySnapshot?.documents.count)! > 50 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[50..<60])
                    
                }
                
                if (querySnapshot?.documents.count)! > 60 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[60..<70])
                    
                }
                
                if (querySnapshot?.documents.count)! > 70 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[70..<80])
                    
                }
                
                if (querySnapshot?.documents.count)! > 80 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[80..<90])
                    
                }
                
                if (querySnapshot?.documents.count)! > 90 {
                    
                    self.followComedianIdArray1 = Array(self.followComedianIdArray[90..<100])
                    
                }
                
                
            }
        }
    }
    
    //カレンダーのheightにスワイプによる表示切り替えを反映させる
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        print(bounds)
        self.calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    //日付がタップされたときの処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 処理
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        
        self.eventDate = "\(year)" + "/" + "\(month)" + "/" + "\(day)"
        
        print("tappedDate:\(self.eventDate)")
        
        //フォロー中の芸人さんかつ日付=タップされた日付のscheduleのeventIdを取得しユニークにする（フォロー芸人さんが複数出演するeventが重複するため）
        
        getSchedule()
        
        
    }
    
    func getSchedule() {
        
        
        
        self.eventIdArray = []
        self.uniqueEventIdArray = []
        self.eventNameArray = []
        self.eventAreaArray = []
        self.eventOnlineFlagArray = []
        self.eventStartArray = []
        self.eventPlaceArray = []
        self.eventCastArray = []
        self.eventUrlArray = []
        
        
        
        self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray1).whereField("delete_flag", isEqualTo: "false").getDocuments() { [self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                for document in querySnapshot!.documents {
                    
                    self.eventIdArray.append(document.data()["event_id"] as! String)
                    print("getschedule_eventIdArray:\(self.eventIdArray)")
                    
                }
                
                if self.followComedianIdArray2 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray2).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                            
                            
                        }
                    }
                    
                }
                
                if self.followComedianIdArray3 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray3).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                if self.followComedianIdArray4 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray4).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                if self.followComedianIdArray5 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray5).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                if self.followComedianIdArray6 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray6).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                if self.followComedianIdArray7 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray7).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                if self.followComedianIdArray8 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray8).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                if self.followComedianIdArray9 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray9).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                if self.followComedianIdArray10 != [] {
                    
                    
                    self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", in: self.followComedianIdArray10).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            for document in querySnapshot!.documents {
                                
                                self.eventIdArray.append(document.data()["event_id"] as! String)
                                
                            }
                        }
                    }
                    
                }
                
                //eventIdArrayをユニークにする
                var eventId = Set<String>()
                self.uniqueEventIdArray = self.eventIdArray.filter { eventId.insert($0).inserted }
                print("self.uniqueEventIdArray:\(self.uniqueEventIdArray)")
                
                
                //ユニークのeventIdのevent_name、event_start、event_placeを取得
                getEvent()
                
                
                
            }
            
        }
    }
    
    func getEvent() {
        
        //対象eventIdのイベント名、エリア、配信有無、時間、会場を取得
        
        for eventId in self.uniqueEventIdArray {
            
            self.db.collection("event").whereField(FieldPath.documentID(), isEqualTo: eventId).whereField("delete_flag", isEqualTo: "false").getDocuments() { [self] (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.eventNameArray.append(document.data()["event_name"] as! String)
                        self.eventAreaArray.append(document.data()["event_area"] as! String)
                        self.eventOnlineFlagArray.append(document.data()["online_flag"] as! String)
                        self.eventStartArray.append(document.data()["event_start"] as! String)
                        self.eventPlaceArray.append(document.data()["event_place"] as! String)
                        self.eventUrlArray.append(document.data()["url"] as! String)
                        
                    }
                    
                    print("self.eventNameArray:\(self.eventNameArray)")
                    
                }
            }
            
        }
        
        self.tableView.reloadData()
        
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 200
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        print("self.uniqueEventIdArray.count:\(self.uniqueEventIdArray.count)")
        
        return self.uniqueEventIdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCalendarCell", for: indexPath) as! MyCalendarTableViewCell
        
        if self.eventNameArray == [] {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                cell.eventNameLabel.text = self.eventNameArray[indexPath.row]
                cell.areaLabel.text = self.eventAreaArray[indexPath.row]
                
                if self.eventOnlineFlagArray[indexPath.row] == "true" {
                    
                    cell.onlineFlagLabel.text = "配信あり"
                    
                }
                
                if self.eventOnlineFlagArray[indexPath.row] == "false" {
                    
                    cell.onlineFlagLabel.text = "配信なし"
                    
                }
                
                cell.eventStartLabel.text = self.eventStartArray[indexPath.row]
                cell.placeLabel.text = self.eventPlaceArray[indexPath.row]
                
                
                self.db.collection("schedule").whereField("event_id", isEqualTo: self.uniqueEventIdArray[indexPath.row]).whereField("delete_flag", isEqualTo: "false").getDocuments() { [self] (querySnapshot, err) in
                    
                    if let err = err {
                        print("Error getting documents: \(err)")
                        return
                        
                    } else {
                        for document in querySnapshot!.documents {
                            
                            self.eventCastArray.append(document.data()["comedian_name"] as! String)
                            
                        }
                        
                        cell.castLabel.text = self.eventCastArray.joined(separator: "、")
                        
                        print("cell.castLabel.text:\(cell.castLabel.text)")
                        
                    }
                    
                }
                
            }
            
            return cell
            
        } else {
            
            
            cell.eventNameLabel.text = self.eventNameArray[indexPath.row]
            cell.areaLabel.text = self.eventAreaArray[indexPath.row]
            
            if self.eventOnlineFlagArray[indexPath.row] == "true" {
                
                cell.onlineFlagLabel.text = "配信あり"
                
            }
            
            if self.eventOnlineFlagArray[indexPath.row] == "false" {
                
                cell.onlineFlagLabel.text = "配信なし"
                
            }
            
            cell.eventStartLabel.text = self.eventStartArray[indexPath.row]
            cell.placeLabel.text = self.eventPlaceArray[indexPath.row]
            
            
            self.db.collection("schedule").whereField("event_id", isEqualTo: uniqueEventIdArray[indexPath.row]).whereField("delete_flag", isEqualTo: "false").getDocuments() { [self] (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.eventCastArray.append(document.data()["comedian_name"] as! String)
                        
                    }
                    
                    cell.castLabel.text = self.eventCastArray.joined(separator: "、")
                    
                    print("cell.castLabel.text:\(cell.castLabel.text)")
                    
                }
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let urlString = self.eventUrlArray[indexPath.row]
        let url = URL(string: "\(urlString)")
        
        
        let wkVC = storyboard?.instantiateViewController(withIdentifier: "WebView") as! WKWebViewController

        wkVC.url = url
        
        self.navigationController?.pushViewController(wkVC, animated: true)

        
        
    }
    
    
    
}
