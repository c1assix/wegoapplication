//
//  AddEventViewController.swift
//  AccountKitTest
//
//  Created by Лев Купчинов on 25.11.17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddEventViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private let ref: DatabaseReference = Database.database().reference()
    private let storage = Storage.storage().reference()
    let metaData = StorageMetadata()
    var eventName = ""
    var eventAddress = ""
    var eventDecription = ""
    var eventPrice = ""
    var latitude = ""
    var longitude = ""
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureReconizer:)))
        gestureRecognizer.delegate = self
        mapKitView.addGestureRecognizer(gestureRecognizer)

        print(count)
        self.nameTextField.delegate = self
        self.descriptionTextField.delegate = self
        self.addressTextField.delegate = self
        self.priceTextField.delegate = self
        self.infoTextField.delegate = self
        viewCard.layer.cornerRadius = 10
        viewCard.layer.shadowColor = UIColor(red: 60.0/255.0, green: 108.0/255.0, blue: 222.0/255.0, alpha: 0.25).cgColor
        viewCard.layer.shadowOpacity = 1
        viewCard.layer.shadowOffset = CGSize.zero
        viewCard.layer.shadowRadius = 15
        infoView.layer.cornerRadius = 10
        infoView.layer.shadowColor = UIColor(red: 60.0/255.0, green: 108.0/255.0, blue: 222.0/255.0, alpha: 0.25).cgColor
        infoView.layer.shadowOpacity = 1
        infoView.layer.shadowOffset = CGSize.zero
        infoView.layer.shadowRadius = 15
        submitButton.layer.cornerRadius = submitButton.bounds.height * 0.5
        submitButton.layer.shadowColor = UIColor(red: 60.0/255.0, green: 108.0/255.0, blue: 222.0/255.0, alpha: 0.25).cgColor
        submitButton.layer.shadowOpacity = 1
        submitButton.layer.shadowOffset = CGSize.zero

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTap(gestureReconizer: UITapGestureRecognizer) {
        let location = gestureReconizer.location(in: mapKitView)
        let ceo: CLGeocoder = CLGeocoder()
        let coordinate = mapKitView.convert(location, toCoordinateFrom: mapKitView)
        
        DispatchQueue.main.async {
            if !self.mapKitView.annotations.isEmpty {
                self.mapKitView.removeAnnotations(self.mapKitView.annotations)
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = String(format: "(%.6f, %.6f)", coordinate.latitude, coordinate.longitude)
            self.latitude = String(coordinate.latitude)
            self.longitude = String(coordinate.longitude)
            self.mapKitView.addAnnotation(annotation)
            let loc: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            ceo.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in
                if error != nil{
                    print("Fail")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0{
                    let pm = placemarks![0]
                    if let locality = pm.locality, let thoroughfare = pm.thoroughfare{
                    self.addressTextField.text = "\(locality), \(thoroughfare)"
                    }
                }
            })
            
            
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        
        
        if Double(priceTextField.text!)! == 0.0{
            budgetIndexAdding = "Free"
        } else if Double(priceTextField.text!)! > 0.0 && Double(priceTextField.text!)! <= 10.0 {
            budgetIndexAdding = "510"
        }else if Double(priceTextField.text!)! >= 10.0{
            budgetIndexAdding = "10more"
        }
        
        if let name = nameTextField.text {
            ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/name").setValue(name)
        }
        if let description = descriptionTextField.text {
            ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/description").setValue(description)
        }
        switch budgetIndexAdding {
        case "Free":
            ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/price").setValue("\(budgetIndexAdding)")
        default:
            if let price = priceTextField.text{
                ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/price").setValue("\(price) BYN")
            }
        }
        if let address = addressTextField.text{
            ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/address").setValue(address)
        }
        ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/longitude").setValue(longitude)
        ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/latitude").setValue(latitude)
        ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/longitude").setValue(longitude)
        ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/rating").setValue("0")
        ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/organisator").setValue(accountIDGlobal)
        if let info = infoTextField.text{
            ref.child("places/\(budgetIndexAdding)/\(dateIndex)/\(count)/url").setValue("\(info)")
        }
        metaData.contentType = "image/jpeg"
        if let nameImage = nameTextField.text {
        let tempImageRef = storage.child("Places/\(String(describing: nameImage)).jpg")
        let image = imageView.image
        tempImageRef.putData(UIImageJPEGRepresentation(image!, 0.2)!, metadata: metaData) { (data, error) in
            if error == nil{
                print("Good")
            }else{
                print("Error")
            }
        }
        
        self.ref.child("places/\(budgetIndexAdding)/\(dateIndex)/counter").setValue(count+1)
        dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func setImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("Camera not available")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @IBAction func dismissSwipe(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
