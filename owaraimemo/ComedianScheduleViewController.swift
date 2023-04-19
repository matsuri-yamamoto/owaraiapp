//
//  ComedianScheduleViewController.swift
//  owaraimemo
//
//  Created by 山本梨野 on 2023/01/10.
//

import Foundation
import Firebase
import FirebaseAuth
import PINRemoteImage

class ComedianScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser

    var comedianId :String = ""
    
    var eventIdArray: [String] = []
    var eventDateArray: [String] = []

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
    
    // インジゲーターの設定
    var indicator = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //芸人さんのイベントのArrayを取得
        self.getSchedule()

        // 表示位置を設定（画面中央）
        self.indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        self.indicator.style = .large
        // インジケーターの色を設定（青色）
        self.indicator.color = UIColor.darkGray
        // インジケーターを View に追加
        view.addSubview(indicator)

        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let nib = UINib(nibName: "MyCalendarTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "MyCalendarCell")
        
        

    }
    
    
    func getSchedule() {
        
        self.indicator.startAnimating()

        
        self.eventIdArray = []
        self.eventDateArray = []
        self.eventNameArray = []
        self.eventAreaArray = []
        self.eventOnlineFlagArray = []
        self.eventStartArray = []
        self.eventPlaceArray = []
        self.eventCastArray = []
        self.eventUrlArray = []
        self.eventImageUrlArray = []
        self.eventReferenceArray = []
        
        print("schedule_comedianId:\(self.comedianId)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let date = Date()
        let pvDate = dateFormatter.string(from: date)

        
            
        self.db.collection("schedule").whereField("comedian_id", isEqualTo: self.comedianId).whereField("delete_flag", isEqualTo: "false").order(by: "event_date", descending: true).whereField("event_date", isGreaterThanOrEqualTo: pvDate).getDocuments() { [self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                return
                
            } else {
                
                for document in querySnapshot!.documents {
                    
                    self.eventIdArray.append(document.data()["event_id"] as! String)

                    
                }
                
                
                print("eventIdArray:\(self.eventIdArray)")
                
                self.getEvent()
            }
        }
        
    }
    
    func getEvent() {
        
        //対象eventIdのイベント名、エリア、配信有無、時間、会場を取得
        
        for eventId in self.eventIdArray {
            
            self.db.collection("event").whereField(FieldPath.documentID(), isEqualTo: eventId).whereField("delete_flag", isEqualTo: "false").getDocuments() { [self] (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                    
                } else {
                    for document in querySnapshot!.documents {
                        
                        self.eventNameArray.append(document.data()["event_name"] as! String)
                        self.eventAreaArray.append(document.data()["event_area"] as! String)
                        self.eventOnlineFlagArray.append(document.data()["online_flag"] as! String)
                        self.eventDateArray.append(document.data()["event_date"] as! String)
                        self.eventStartArray.append(document.data()["event_start"] as! String)
                        self.eventPlaceArray.append(document.data()["event_place"] as! String)
                        self.eventCastArray.append(document.data()["event_cast"] as! String)
                        self.eventUrlArray.append(document.data()["url"] as! String)
                        self.eventImageUrlArray.append(document.data()["image_url"] as! String)
                        self.eventReferenceArray.append(document.data()["event_reference"] as! String)


                    }
                    
                    print("eventNameArray:\(self.eventNameArray)")
                    print("eventDateArray:\(self.eventDateArray)")


                                        
                }
            }
            
        }
        
        self.tableView.reloadData()

        
    }
    
    
        
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 200

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("schedule_eventIdArray.count:\(self.eventIdArray.count)")
        return self.eventIdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCalendarCell", for: indexPath) as! MyCalendarTableViewCell
        
//        cell.dateLabel.layer.cornerRadius = 10
//        cell.dateLabel.clipsToBounds = true
//
//        cell.onlineFlagLabel.layer.cornerRadius = 10
//        cell.onlineFlagLabel.clipsToBounds = true
//
//        cell.areaLabel.layer.cornerRadius = 10
//        cell.areaLabel.clipsToBounds = true


        
        if self.eventNameArray == [] {
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                cell.dateLabelWidth.constant = CGFloat(self.view.frame.width*0.22)
                cell.dateLabel.text = self.eventDateArray[indexPath.row]
                
                cell.eventNameLabel.text = "　" + self.eventNameArray[indexPath.row]
                cell.areaLabel.text = self.eventAreaArray[indexPath.row]
                
                
//                let image :UIImage = UIImage(url: "\(self.eventImageUrlArray[indexPath.row])")
//                cell.eventImageView.image = image
            
                cell.eventImageView.pin_updateWithProgress = true
                cell.eventImageView.pin_setImage(from: URL(string: "\(self.eventImageUrlArray[indexPath.row])")!)

                

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
//                cell.onlineFlagLabel.layer.borderWidth = 1.0
//                cell.onlineFlagLabel.layer.borderColor = UIColor.black.cgColor

                
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
            
            self.indicator.stopAnimating()
            return cell
            
        } else {

            cell.dateLabelWidth.constant = CGFloat(self.view.frame.width*0.22)
            cell.dateLabel.text = self.eventDateArray[indexPath.row]


            cell.eventNameLabel.text = "　" + self.eventNameArray[indexPath.row]
            cell.areaLabel.text = self.eventAreaArray[indexPath.row]

//            let image :UIImage = UIImage(url: "\(self.eventImageUrlArray[indexPath.row])")
//            cell.eventImageView.image = image
            
            cell.eventImageView.pin_updateWithProgress = true
            cell.eventImageView.pin_setImage(from: URL(string: "\(self.eventImageUrlArray[indexPath.row])")!)


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
//            cell.onlineFlagLabel.layer.borderWidth = 1.0
//            cell.onlineFlagLabel.layer.borderColor = UIColor.black.cgColor


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

            self.indicator.stopAnimating()
            return cell

        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        print("eventUrlArray:\(self.eventUrlArray)")

        let urlString = self.eventUrlArray[indexPath.row]
        print("urlString:\(urlString)")
        let url = URL(string: "\(urlString)")
        print("url:\(url)")
        UIApplication.shared.open(url!)

        
//        let wkVC = storyboard?.instantiateViewController(withIdentifier: "WebView") as! WKWebViewController
//
//        wkVC.url = url
//
//        self.navigationController?.pushViewController(wkVC, animated: true)
        
        if self.currentUser?.uid != "Wsp1fLJUadXIZEiwvpuPWvhEjNW2"
            && self.currentUser?.uid != "AxW7CvvgzTh0djyeb7LceI1dCYF2"
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
                "page": "ComedianSchedule",
                "action_type": "tap_event",
                "tapped_comedian_id": "",
                "tapped_user_id": "",
                "tapped_date": "",
                "tapped_event_id": self.eventIdArray[indexPath.row],
                "create_datetime": FieldValue.serverTimestamp(),
                "update_datetime": FieldValue.serverTimestamp(),
                "delete_flag": false,
                "delete_datetime": nil,
            ] as [String : Any]
            logRef.setData(logDic)
            
        }
     
        
    }
    
    
}

