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
    
    let df = DateFormatter()

    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    //画像のパス
    let storage = Storage.storage(url:"gs://owaraiapp-f80fd.appspot.com").reference()

    
    
    var followComedianIdArray: [String] = []

    var eventDate :String = ""
    
    var allEventDateArray: [String] = []
    var uniqueAllEventDateArray: [String] = []

    
    var eventIdArray: [String] = []
    var eventDateArray: [String] = []
    var uniqueEventIdArray: [String] = []
    var uniqueEventDateArray: [String] = []

    
    //表示させるeventIdのイベント名、エリア、配信有無、時間、会場を格納
    var eventNameArray: [String] = []
    var eventAreaArray: [String] = []
    var eventOnlineFlagArray: [String] = []
    var eventStartArray: [String] = []
    var eventPlaceArray: [String] = []
    var eventCastArray: [String] = []
    var eventUrlArray: [String] = []
    var eventImageUrlArray: [String] = []
    var eventReferenceArray: [String] = []

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MyCalendarTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MyCalendarCell")
        
        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        self.calendar.setScope(.week, animated: false)

        
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
        
        self.calendar.locale = Locale(identifier: "ja")
        self.calendar.appearance.calendar.firstWeekday = 2 //月曜からに変更
        self.calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 15)
        self.calendar.appearance.headerDateFormat = "yyyy年MM月"
        self.calendar.appearance.headerTitleColor = UIColor.black
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //フォロー中の芸人さんとそのイベントのArrayを取得
        self.getFollowComedian()
        
        if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
            && self.currentUser?.uid != "QWQcWLgi9AV21qtZRE6cIpgfaVp2"
            && self.currentUser?.uid != "BvNA6PJte0cj2u3FISymhnrBxCf2"
            && self.currentUser?.uid != "uHOTLNXbk8QyFPIoqAapj4wQUwF2"
            && self.currentUser?.uid != "z9fKAXmScrMTolTApapJyHyCfEg2"
            && self.currentUser?.uid != "jjF5m3lbU4bU0LKBgOTf0Hzs5RI3"
            && self.currentUser?.uid != "bjOQykO7RxPO8j1SdN88Z3Q8ELM2"
            && self.currentUser?.uid != "0GA1hPehpXdE2KKcKj0tPnCiQxA3"
            && self.currentUser?.uid != "i7KQ5WLDt3Q9pw9pSdGG6tCqZoL2"
            && self.currentUser?.uid != "wWgPk67GoIP9aBXrA7SWEccwStx1" {
            
            //pvログを取得
            let logRef = Firestore.firestore().collection("logs").document()
            let logDic = [
                "action_user_id": self.currentUser?.uid,
                "page": "MyCalendar",
                "action_type": "pv",
                "tapped_comedian_id": "",
                "tapped_user_id": "",
                "tapped_date": "",
                "tapped_event_id": "",
                "action_date": "",
                "create_datetime": FieldValue.serverTimestamp(),
                "update_datetime": FieldValue.serverTimestamp(),
                "delete_flag": false,
                "delete_datetime": nil,
            ] as [String : Any]
            logRef.setData(logDic)
            
        }
        
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
        
        self.followComedianIdArray = []
        self.allEventDateArray = []
        
        self.eventIdArray = []
        self.eventDateArray = []
        self.uniqueEventIdArray = []
        self.uniqueEventDateArray = []
        self.eventNameArray = []
        self.eventAreaArray = []
        self.eventOnlineFlagArray = []
        self.eventStartArray = []
        self.eventPlaceArray = []
        self.eventCastArray = []
        self.eventUrlArray = []
        self.eventImageUrlArray = []
        self.eventReferenceArray = []
        
        
        self.db.collection("follow_comedian").whereField("user_id", isEqualTo: self.currentUser?.uid).whereField("valid_flag", isEqualTo: true).whereField("delete_flag", isEqualTo: false).getDocuments() { [self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                for document in querySnapshot!.documents {
                    
                    self.followComedianIdArray.append(document.data()["comedian_id"] as! String)
                    
                }
                
                print("followComedianIdArray:\(self.followComedianIdArray)")
        

                print("getSchedule_followComedianIdArray:\(self.followComedianIdArray)")
                
                for comedianId in self.followComedianIdArray {
                    
                    //フォロー芸人さんのすべてのイベントを取得する
                    self.db.collection("schedule").whereField("comedian_id", isEqualTo: comedianId).whereField("delete_flag", isEqualTo: "false").getDocuments() { [self] (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                            return
                            
                        } else {
                            
                            for document in querySnapshot!.documents {
                                
                                self.allEventDateArray.append(document.data()["event_date"] as! String)

                                print("load_self.allEventDateArray:\(self.allEventDateArray)")

                                
                            }
                        }
                    }
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    //aleventDateArrayをユニークにする
                    var eventDate = Set<String>()
                    self.uniqueAllEventDateArray = self.allEventDateArray.filter { eventDate.insert($0).inserted }
                    
                    print("uniqueEventDateArray:\(self.uniqueAllEventDateArray)")
                    
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
        
        if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
            && self.currentUser?.uid != "QWQcWLgi9AV21qtZRE6cIpgfaVp2"
            && self.currentUser?.uid != "BvNA6PJte0cj2u3FISymhnrBxCf2"
            && self.currentUser?.uid != "uHOTLNXbk8QyFPIoqAapj4wQUwF2"
            && self.currentUser?.uid != "z9fKAXmScrMTolTApapJyHyCfEg2"
            && self.currentUser?.uid != "jjF5m3lbU4bU0LKBgOTf0Hzs5RI3"
            && self.currentUser?.uid != "bjOQykO7RxPO8j1SdN88Z3Q8ELM2"
            && self.currentUser?.uid != "0GA1hPehpXdE2KKcKj0tPnCiQxA3"
            && self.currentUser?.uid != "i7KQ5WLDt3Q9pw9pSdGG6tCqZoL2"
            && self.currentUser?.uid != "wWgPk67GoIP9aBXrA7SWEccwStx1" {
            
            //ログを取得
            let logRef = Firestore.firestore().collection("logs").document()
            let logDic = [
                "action_user_id": self.currentUser?.uid,
                "page": "MyCalendar",
                "action_type": "tap_date",
                "tapped_comedian_id": "",
                "tapped_user_id": "",
                "tapped_date": self.eventDate,
                "create_datetime": FieldValue.serverTimestamp(),
                "update_datetime": FieldValue.serverTimestamp(),
                "delete_flag": false,
                "delete_datetime": nil,
            ] as [String : Any]
            logRef.setData(logDic)
            
        }
        
        
    }
    
    func getSchedule() {
        
        self.eventIdArray = []
        self.eventDateArray = []
        self.uniqueEventIdArray = []
        self.uniqueEventDateArray = []
        self.eventNameArray = []
        self.eventAreaArray = []
        self.eventOnlineFlagArray = []
        self.eventStartArray = []
        self.eventPlaceArray = []
        self.eventCastArray = []
        self.eventUrlArray = []
        self.eventImageUrlArray = []
        self.eventReferenceArray = []

        print("getSchedule_followComedianIdArray:\(self.followComedianIdArray)")
        
        for comedianId in self.followComedianIdArray {
            
            self.db.collection("schedule").whereField("event_date", isEqualTo: self.eventDate).whereField("comedian_id", isEqualTo: comedianId).whereField("delete_flag", isEqualTo: "false").order(by: "create_date", descending: true).getDocuments() { [self] (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        self.eventIdArray.append(document.data()["event_id"] as! String)
                        self.eventDateArray.append(document.data()["event_date"] as! String)

                        
                    }
                }
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            print("getschedule_eventIdArray:\(self.eventIdArray)")
            //eventIdArrayをユニークにする
            var eventId = Set<String>()
            self.uniqueEventIdArray = self.eventIdArray.filter { eventId.insert($0).inserted }
            
            var eventDate = Set<String>()
            self.uniqueEventDateArray = self.eventDateArray.filter { eventDate.insert($0).inserted }
            
            print("getschedule_eventIdArray:\(self.eventIdArray)")

            //ユニークのeventIdのevent_name、event_start、event_placeを取得
            print("getEvent")
            self.getEvent()

            
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
                        self.eventCastArray.append(document.data()["event_cast"] as! String)
                        self.eventUrlArray.append(document.data()["url"] as! String)
                        self.eventImageUrlArray.append(document.data()["image_url"] as! String)
                        self.eventReferenceArray.append(document.data()["event_reference"] as! String)


                    }
                    
                    print("tapped_eventNameArray:\(self.eventNameArray)")
                    print("tapped_eventAreaArray:\(self.eventAreaArray)")
                    print("tapped_eventOnlineFlagArray:\(self.eventOnlineFlagArray)")
                    print("tapped_eventStartArray:\(self.eventStartArray)")
                    print("tapped_eventPlaceArray:\(self.eventPlaceArray)")
                    print("tapped_eventCastArray:\(self.eventCastArray)")
                    print("tapped_eventUrlArray:\(self.eventUrlArray)")
                    
                }
            }
            
        }
        
        self.tableView.reloadData()
        
    }
    
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        df.dateFormat = "yyyy/MM/dd"
        if uniqueAllEventDateArray.first(where: { $0 == df.string(from: date) }) != nil {
                return 1
        }
        return 0
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

        
        print("imageTitle:\(self.uniqueEventIdArray[indexPath.row])")
        

        cell.onlineFlagLabel.layer.cornerRadius = 10
        cell.onlineFlagLabel.clipsToBounds = true
        
        cell.areaLabel.layer.cornerRadius = 10
        cell.areaLabel.clipsToBounds = true


        
        if self.eventNameArray == [] {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                
                cell.eventNameLabel.text = "　" + self.eventNameArray[indexPath.row]
                cell.areaLabel.text = self.eventAreaArray[indexPath.row]
                
                
                let image :UIImage = UIImage(url: "\(self.eventImageUrlArray[indexPath.row])")
                cell.eventImageView.image = image
                
//                let imageRef = self.storage.child("event_image/\(self.uniqueEventIdArray[indexPath.row]).jpg")
//                cell.eventImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))

                if self.eventAreaArray[indexPath.row] == "東京" {
                    
                    cell.areaLabel.backgroundColor = #colorLiteral(red: 0.1848421342, green: 0.2122759584, blue: 0.7568627596, alpha: 1)
                    cell.areaLabel.tintColor = UIColor.white
//                    cell.areaLabel.layer.borderWidth = 2.0
//                    cell.areaLabel.layer.borderColor = UIColor.darkGray.cgColor
                    
                } else if self.eventAreaArray[indexPath.row] == "大阪" {
                    
                    cell.areaLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                    cell.areaLabel.tintColor = UIColor.white
//                    cell.areaLabel.layer.borderWidth = 2.0
//                    cell.areaLabel.layer.borderColor = UIColor.darkGray.cgColor
                    
                } else {
                    
                    cell.areaLabel.backgroundColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
                    cell.areaLabel.tintColor = UIColor.white
                    
                    
                }
                
                cell.onlineFlagLabel.backgroundColor = #colorLiteral(red: 0.9294985734, green: 0.9294985734, blue: 0.9294985734, alpha: 1)
                cell.onlineFlagLabel.textColor = UIColor.black
                cell.onlineFlagLabel.layer.borderWidth = 1.0
                cell.onlineFlagLabel.layer.borderColor = UIColor.black.cgColor

                
                if self.eventOnlineFlagArray[indexPath.row] == "true" {
                    
                    cell.onlineFlagLabel.text = "配信あり"
                    
                }
                
                if self.eventOnlineFlagArray[indexPath.row] == "false" {
                    
                    cell.onlineFlagLabel.text = "配信なし"
                    
                }
                
                if self.eventOnlineFlagArray[indexPath.row] == "" {
                    
                    cell.onlineFlagLabel.isHidden = true
                }
                
                cell.eventStartLabel.text = "開演：" + self.eventStartArray[indexPath.row]
                cell.placeLabel.text = "会場：" + self.eventPlaceArray[indexPath.row]
                
                cell.castLabel.text = self.eventCastArray[indexPath.row]
                
                cell.eventReferenceLabel.text = self.eventReferenceArray[indexPath.row]

                                
            }
            
            return cell
            
        } else {
            

            cell.eventNameLabel.text = "　" + self.eventNameArray[indexPath.row]
            cell.areaLabel.text = self.eventAreaArray[indexPath.row]
            
            let image :UIImage = UIImage(url: "\(self.eventImageUrlArray[indexPath.row])")
            cell.eventImageView.image = image

            
//            let imageRef = self.storage.child("event_image/\(self.uniqueEventIdArray[indexPath.row]).jpg")
//            cell.eventImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "noImage"))

            
            if self.eventAreaArray[indexPath.row] == "東京" {
                
                cell.areaLabel.backgroundColor = #colorLiteral(red: 0.1848421342, green: 0.2122759584, blue: 0.7568627596, alpha: 1)
                cell.areaLabel.tintColor = UIColor.white
//                    cell.areaLabel.layer.borderWidth = 2.0
//                    cell.areaLabel.layer.borderColor = UIColor.darkGray.cgColor
                
            } else if self.eventAreaArray[indexPath.row] == "大阪" {
                
                cell.areaLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                cell.areaLabel.tintColor = UIColor.white
//                    cell.areaLabel.layer.borderWidth = 2.0
//                    cell.areaLabel.layer.borderColor = UIColor.darkGray.cgColor
                
            } else {
                
                cell.areaLabel.backgroundColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
                cell.areaLabel.tintColor = UIColor.white
                
                
            }
            
            cell.onlineFlagLabel.backgroundColor = #colorLiteral(red: 0.9294985734, green: 0.9294985734, blue: 0.9294985734, alpha: 1)
            cell.onlineFlagLabel.textColor = UIColor.black
            cell.onlineFlagLabel.layer.borderWidth = 1.0
            cell.onlineFlagLabel.layer.borderColor = UIColor.black.cgColor

            
            if self.eventOnlineFlagArray[indexPath.row] == "true" {
                
                cell.onlineFlagLabel.text = "配信あり"
                
            }
            
            if self.eventOnlineFlagArray[indexPath.row] == "false" {
                
                cell.onlineFlagLabel.text = "配信なし"

            }
            
            if self.eventOnlineFlagArray[indexPath.row] == "" {
                
                cell.onlineFlagLabel.isHidden = true
            }

            
            
            cell.eventStartLabel.text = "開演：" + self.eventStartArray[indexPath.row]
            cell.placeLabel.text = "会場：" + self.eventPlaceArray[indexPath.row]
            
            cell.castLabel.text = self.eventCastArray[indexPath.row]
            
            cell.eventReferenceLabel.text = self.eventReferenceArray[indexPath.row]

            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)

        let urlString = self.eventUrlArray[indexPath.row]
        let url = URL(string: "\(urlString)")
        
        
        let wkVC = storyboard?.instantiateViewController(withIdentifier: "WebView") as! WKWebViewController
        
        wkVC.url = url
        
        self.navigationController?.pushViewController(wkVC, animated: true)
        
        if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
            && self.currentUser?.uid != "QWQcWLgi9AV21qtZRE6cIpgfaVp2"
            && self.currentUser?.uid != "BvNA6PJte0cj2u3FISymhnrBxCf2"
            && self.currentUser?.uid != "uHOTLNXbk8QyFPIoqAapj4wQUwF2"
            && self.currentUser?.uid != "z9fKAXmScrMTolTApapJyHyCfEg2"
            && self.currentUser?.uid != "jjF5m3lbU4bU0LKBgOTf0Hzs5RI3"
            && self.currentUser?.uid != "bjOQykO7RxPO8j1SdN88Z3Q8ELM2"
            && self.currentUser?.uid != "0GA1hPehpXdE2KKcKj0tPnCiQxA3"
            && self.currentUser?.uid != "i7KQ5WLDt3Q9pw9pSdGG6tCqZoL2"
            && self.currentUser?.uid != "wWgPk67GoIP9aBXrA7SWEccwStx1" {
            
            //pvログを取得
            let logRef = Firestore.firestore().collection("logs").document()
            let logDic = [
                "action_user_id": self.currentUser?.uid,
                "page": "MyCalendar",
                "action_type": "tap_event",
                "tapped_comedian_id": "",
                "tapped_user_id": "",
                "tapped_date": "",
                "tapped_event_id": self.uniqueEventIdArray[indexPath.row],
                "create_datetime": FieldValue.serverTimestamp(),
                "update_datetime": FieldValue.serverTimestamp(),
                "delete_flag": false,
                "delete_datetime": nil,
            ] as [String : Any]
            logRef.setData(logDic)
            
        }
     
        
    }
    
    
    
}

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
