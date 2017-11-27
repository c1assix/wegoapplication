//
//  MainViewController.swift
//  AccountKitTest
//
//  Created by Лев Купчинов on 12.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import Firebase

var budgetIndex = ""
var eventIndex = ""
var nameLabelGlobal = ""
var count = 0


class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var ref: DatabaseReference?
    var latitude: String?
    var longitude: String?
    var rating: String?
    var urlInfo: String?

    
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
    @IBOutlet weak var viewWithButtons: UIView!
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var tapMeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        //filePath = Bundle.main.path(forResource: "places", ofType: "plist")
        //items = NSArray(contentsOfFile: filePath!) as! [[String : AnyObject]]
        
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
        mapKitView.showsCompass = false
        
        inviteButton.isHidden = true
        
        // Do any additional setup after loading the view.
        ref?.observe(.value, with: { (snapshot: DataSnapshot!) in
            count = count + Int(snapshot.childrenCount)
        })
        //-------------------------
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

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
        viewWithButtons.layer.cornerRadius = 0
        viewWithButtons.layer.shadowColor = blueShadow.cgColor
        viewWithButtons.layer.shadowOpacity = 1
        viewWithButtons.layer.shadowOffset = CGSize.zero
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
        nameLabel.text = ""
        nameLabel.layer.backgroundColor = grayColor.cgColor
        addressLabel.text = ""
        addressLabel.layer.backgroundColor = grayColor.cgColor
        labelPrice.text = ""
        descriptionLabel.text = ""
        descriptionLabel.layer.backgroundColor = grayColor.cgColor
        labelPrice.layer.backgroundColor = grayColor.cgColor
        addressLabel.layer.backgroundColor = grayColor.cgColor

    }
    
    func setCardInfo(index: Int){
        settingAnnotation()
        settingInfo(key: "name", label: nameLabel)
        settingInfo(key: "description", label: descriptionLabel)
        settingInfo(key: "address", label: addressLabel)
        settingInfo(key: "price", label: labelPrice)
        settingInfoUrl(key: "url")
        loadImage()
        nameLabel.layer.backgroundColor = UIColor.white.cgColor
        addressLabel.layer.backgroundColor = UIColor.white.cgColor
        addressLabel.layer.backgroundColor = UIColor.white.cgColor
        descriptionLabel.layer.backgroundColor = UIColor.white.cgColor
        labelPrice.layer.backgroundColor = UIColor.white.cgColor
        addressLabel.layer.backgroundColor = UIColor.white.cgColor
        tapMeLabel.isHidden = true
        nameLabelGlobal = nameLabel.text!
    }
    
    //Invite Friends Action
    
    @IBAction func inviteAction(_ sender: UIButton) {
        let activityVC = UIActivityViewController(activityItems: ["Hi! Let's go to \(nameLabelGlobal)!\nAddress: \(addressLabel.text!)\nDate: \(dateIndex)\nPrice: \(labelPrice.text!)\n\nSended from WeGo! App"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
        ref?.child("places").child("\(randomedIndex)").child("rating").observeSingleEvent(of: .value, with: { (snapshot) in
            if let currentRating = snapshot.value as? String{
                self.rating = currentRating
                self.run(after: 1){
                self.ref?.child("places").child("\(self.randomedIndex)").child("rating").setValue("\(Int(self.rating!)! + 1)")
                }
            }
        })
    }
    //Invite Friends Action
    
    //Download Image
    func loadImage(){
        ref?.child("places").child("\(randomedIndex)").child("image").observeSingleEvent(of: .value, with: { (snapshot) in
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
        //Download Image
    
    //Setting annotation
    func settingAnnotation(){
        ref?.child("places").child("\(randomedIndex)").child("latitude").observeSingleEvent(of: .value, with: { (snapshot) in
            if let latitudeConst = snapshot.value{
                self.latitude = latitudeConst as? String
            }
        })
        ref?.child("places").child("\(randomedIndex)").child("longitude").observeSingleEvent(of: .value, with: { (snapshot) in
            if let longitudeConst = snapshot.value as? String{
                self.longitude = longitudeConst
            }
        })
       run(after: 1){
            if self.latitude != nil && self.longitude != nil{
                let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(self.latitude!)!, Double(self.longitude!)!)
                let region : MKCoordinateRegion = MKCoordinateRegionMake(location, self.span)
                self.mapKitView.setRegion(region, animated: true)
                self.mapKitView.removeAnnotation(self.annotation)
                self.annotation.coordinate = location
                self.mapKitView.addAnnotation(self.annotation)
            }
        }
    }
    
    func settingInfo(key: String, label: UILabel){
        ref?.child("places").child("\(randomedIndex)").child("\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                label.text = item
            }
        })
    }
    
    func settingInfoUrl(key: String){
        ref?.child("places").child("\(randomedIndex)").child("\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                self.urlInfo = item
            }
        })
    }
    
    func run(after seconds: Int, completion: @escaping () -> Void) {
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
    @IBAction func infoButton(_ sender: UIButton) {
        UIApplication.shared.openURL(NSURL(string: urlInfo!)! as URL)
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
