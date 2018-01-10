//
//  MainViewController.swift
//  AccountKitTest
//
//  Created by Лев Купчинов on 12.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UserNotifications
import AccountKit

var budgetIndex = ""
var eventIndex = ""
var nameLabelGlobal = ""
var count = 0
var budgetIndexFinish = "Free"
var budgetIndexAdding = ""
var dateIndex = "Monday"
var urlForRating = ""
var accountType = ""

class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    private let ref: DatabaseReference = Database.database().reference()
    private let storage = Storage.storage().reference()
    var latitude: String?
    var longitude: String?
    var rating = 0
    var urlInfo: String?
    var mapItem = MKMapItem()
    
    var randomedIndex = 0

    let yellowColor = UIColor(red: 231.0/255.0, green: 129.0/255.0, blue: 49.0/255.0, alpha: 1)
    let grayColor =   UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 0.5)
    let blueShadow =  UIColor(red: 60.0/255.0, green: 108.0/255.0, blue: 222.0/255.0, alpha: 0.25)
    let redShadow =   UIColor(red: 255.0/255.0, green: 27.0/255.0, blue: 62.0/255.0, alpha: 0.7)
    
    let locationManager = CLLocationManager()
    var annotation = MKPointAnnotation()
    let span : MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
    
    let dispatchGroupForFunc = DispatchGroup()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var eventTypeOutlet: UIButton!
    @IBOutlet weak var budgetOutlet: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var infoLabel: UIButton!
    @IBOutlet weak var dateOutlet: UIButton!
    @IBOutlet weak var addEventOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleCardDefault()
        styleController(outlet: eventTypeOutlet)
        styleController(outlet: budgetOutlet)
        view.backgroundColor = UIColor(red: 244.0/255.0, green: 245.0/255.0, blue: 250.0/255.0, alpha: 1)
        cardStyle()
        
        mapKitView.delegate = self
        mapKitView.showsScale = true
        mapKitView.showsUserLocation = true
        mapKitView.showsPointsOfInterest = true
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow, error) in
        }
        UNUserNotificationCenter.current().delegate = self
        mapKitView.showsCompass = false
        infoLabel.isHidden = true
        inviteButton.isHidden = true
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func randomButton(_ sender: UIButton) {
        UIView.transition(with: self.cardView, duration: 0.5, options: .transitionFlipFromTop, animations: nil, completion: nil)
        randomedIndex = Int(arc4random_uniform(UInt32(count)))
        setCardInfo(index: randomedIndex)
        inviteButton.isHidden = false
    }
    
    func styleController(outlet: UIButton) {
        buttonSetStyle(outlet: dateOutlet)
        buttonSetStyle(outlet: budgetOutlet)
        buttonSetStyle(outlet: eventTypeOutlet)
        inviteButton.layer.cornerRadius = 0.5 * inviteButton.bounds.height
        inviteButton.layer.shadowColor = redShadow.cgColor
        inviteButton.layer.shadowOpacity = 1
        inviteButton.layer.shadowOffset = CGSize.zero
    }
    
    func cardStyle(){
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = blueShadow.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 15
    }
    
    func styleCardDefault(){
        cardView.isHidden = true
    }
    
    func setCardInfo(index: Int){
        cardView.isHidden = false
        infoLabel.isHidden = false
        settingAnnotation()
        
        settingInfo(key: "name", label: nameLabel)
        settingInfo(key: "description", label: descriptionLabel)
        settingInfo(key: "address", label: addressLabel)
        settingInfo(key: "price", label: labelPrice)
        settingInfoUrl(key: "url")
        
        newLoadImage()
        
        nameLabelGlobal = nameLabel.text!
    }
    
    //Invite Friends Action
    
    @IBAction func inviteAction(_ sender: UIButton) {
        
        let activityVC = UIActivityViewController(activityItems: ["Hi! Let's go to \(nameLabel.text!)!\nAddress: \(addressLabel.text!)\nDate: \(dateIndex)\nPrice: \(labelPrice.text!)\n\nSent from WeGo! App"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        

        urlForRating = "places/\(budgetIndexFinish)/\(dateIndex)/\(randomedIndex)/rating"
        callNotification()
        
    }
    //Invite Friends Action
    
    //Download Image
    func loadImage(){
        ref.child("places").child("\(budgetIndexFinish)").child("\(randomedIndex)").child("image").observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                let imageUrlString = item
                let imageUrl:URL = URL(string: imageUrlString )!
                
                // Start background thread so that image loading does not make app unresponsive
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let imageData:NSData = NSData(contentsOf: imageUrl)!
                    let imageView = UIImageView(frame: CGRect(x:0, y:0, width:200, height:200))
                    imageView.center = self.view.center
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        self.imageLabel.image = image
                        self.view.addSubview(imageView)
                    }
                }
            }
        })
    }
    
    func newLoadImage(){
       // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let tempImageRef = self.storage.child("Places/\(self.nameLabel.text!).jpg")
                tempImageRef.getData(maxSize: 1 * 1000 * 1000) { (data, error) in
                       if error == nil{
                        DispatchQueue.main.async {
                            self.imageLabel.image = UIImage(data: data!)
                        }
                        }else{
                          print("Error")
                       }
                    }
          //  }
        }
        //Download Image
    
    //Setting annotation
    func settingAnnotation() {
        let dispatchGroup = DispatchGroup() // Создаем группу
        
        dispatchGroup.enter() // Закидываем таск
        ref.child("places/\(budgetIndexFinish)/\(dateIndex)/\(randomedIndex)/latitude").observeSingleEvent(of: .value, with: { (snapshot) in
            if let latitudeConst = snapshot.value as? String {
                self.latitude = latitudeConst
            }
            dispatchGroup.leave() // Ливаем из группы после выполнения
        })
        
        dispatchGroup.enter() // Закидываем второй таск
        ref.child("places/\(budgetIndexFinish)/\(dateIndex)/\(randomedIndex)/longitude").observeSingleEvent(of: .value, with: { (snapshot) in
            if let longitudeConst = snapshot.value as? String {
                self.longitude = longitudeConst
            }
            dispatchGroup.leave() // Ливаем после выполнения
        })
        
        dispatchGroup.notify(queue: .main) { // Говорим, что группа пустая и моэно выполнять дальше
            if let latitude = self.latitude, let longitude = self.longitude {
                let location = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
                let region = MKCoordinateRegionMake(location, self.span)
                self.mapKitView.setRegion(region, animated: true)
                self.mapKitView.removeAnnotation(self.annotation)
                self.annotation.coordinate = location
                self.mapKitView.addAnnotation(self.annotation)
                print(latitude)
            }
        }
    }
    
    func settingInfo(key: String, label: UILabel){
        ref.child("places").child("\(budgetIndexFinish)").child("\(dateIndex)").child("\(randomedIndex)").child("\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                label.text = item
            }
        })
    }
    
    func settingInfoUrl(key: String){
        ref.child("places").child("\(budgetIndexFinish)").child("\(dateIndex)").child("\(randomedIndex)").child("\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                self.urlInfo = item
            }
        })
    }
    
    func accountCheck(){
        ref.child("Phone Number/\(accountIDGlobal)/Pro").observeSingleEvent(of: .value, with: { (snapshot) in
            if let status = snapshot.value as? String{
                accountType = status
            }
        })
        if accountType == "true"{
            addEventOutlet.isHidden = false
        }
    }
    
    
    func run(after seconds: Int, completion: @escaping () -> Void) {
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
    @IBAction func infoButton(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: urlInfo!)!, options: [:], completionHandler: nil)
    }
    
    func buttonSetStyle(outlet: UIButton){
        outlet.layer.cornerRadius = 0.5 * eventTypeOutlet.bounds.height
        outlet.layer.shadowColor = blueShadow.cgColor
        outlet.layer.shadowOpacity = 1
        outlet.layer.shadowOffset = CGSize.zero
        outlet.layer.shadowRadius = 10
    }
    
    func callNotification(){
        
        let like = UNNotificationAction(identifier: "like", title: "Like 👍", options: UNNotificationActionOptions.foreground)
        let dislike = UNNotificationAction(identifier: "dislike", title: "Dislike 👎", options: UNNotificationActionOptions.foreground)
        let fake = UNNotificationAction(identifier: "fake", title: "Fake event", options: UNNotificationActionOptions.foreground)
        
        let category = UNNotificationCategory(identifier: "directCategory", actions: [like, dislike, fake], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let content = UNMutableNotificationContent()
        content.title = "Rate event!"
        content.subtitle = "Recently you were at the event."
        content.body = "Event: \(nameLabel.text!)"
        content.categoryIdentifier = "directCategory"
        content.badge = 1
        
        let triggerNotify = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let requestNotify = UNNotificationRequest(identifier: "Notify", content: content, trigger: triggerNotify)
        
        UNUserNotificationCenter.current().add(requestNotify, withCompletionHandler: nil)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "like" {
            ref.child("\(urlForRating)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let rating = snapshot.value as? String {
                    self.ref.child("\(urlForRating)").setValue("\(Int(rating)! + 1)")
                }
            })
        } else if response.actionIdentifier == "dislike" {
            if response.actionIdentifier == "like" {
                ref.child("\(urlForRating)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let rating = snapshot.value as? String {
                        self.ref.child("\(urlForRating)").setValue("\(Int(rating)! - 1)")
                    }
                })
            }
        }
        
    }
    
    
    
    
    //Setting annotation
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

