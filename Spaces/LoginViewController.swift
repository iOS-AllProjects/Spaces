//
//  ViewController.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/13/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var inputContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var authenticationToggle: CustomSegmentedControl!
    
    @IBOutlet weak var authenticationButton: RoundedButton!
    
    var messagesController: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
    }
    
    @IBAction func uploadPhoto(_ sender: UITapGestureRecognizer) {
        callActionSheet()
    }
    

    @IBAction func authenticationControlTapped(_ sender: Any) {
        //Logic goes here and is based on index selection
        if authenticationToggle.selectedIndex == 0{
            authenticationButton.setTitle("Sign Up", for: .normal)
            inputContainerHeight.constant += 40
            nameTextFieldHeight.constant = 30
            lineHeight.constant = 1
        } else if authenticationToggle.selectedIndex == 1{
            authenticationButton.setTitle("Sign In", for: .normal)
            inputContainerHeight.constant -= 40
            nameTextFieldHeight.constant = 0
            lineHeight.constant = 0
        }
    }

    @IBAction func authenticationButtonPressed(_ sender: UIButton) {
        // Validate the textfields
        if sender.title(for: .normal) == "Sign Up" {
            signUp()
        } else {
            signIn()
        }
    }
    
    
    func signUp(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Invalid form")
            return
        }
        // Create a new user
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            
            if error != nil{
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            let imageName = UUID().uuidString
            // Create a reference to the storage
            let storageRef = Storage.storage().reference().child("profileImages").child("\(imageName).png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print(error!)
                    return
                }
                
                if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                    // Create the values that are to be displayed in the database
                    let values = ["name": name, "email": email, "profileImageURL": profileImageURL as String] as [String: Any]
                    self.registerUser(uid: uid, values: values)
                }
                print(metadata!)
            })
            }
        })
    }
    
    func registerUser(uid: String, values: [String: Any]){
        // Create a reference to the realtime database
        let ref = Database.database().reference()
        // Create a child reference for users to be saved with their uid
        let userRef = ref.child("users").child(uid)
        // Pass the values
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil{
                print(err!)
                return
            }
            let person = Person()
            person.setValuesForKeys(values)
            self.messagesController?.setupNavBar(user: person)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func signIn(){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Invalid form")
            return
        }
        
        // Check credentials 
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user: User?, error) in
            if error != nil{
                print(error!)
                return
            }
            self.messagesController?.fetchCurrentUser()
            self.dismiss(animated: true, completion: nil)
    })
    }
}

extension LoginViewController: UIGestureRecognizerDelegate{
    func callActionSheet(){
        let actionSheet = UIAlertController(title: "Add a Photo", message: "Upload from the following", preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default){ action in
            self.fromSource(source: .photoLibrary)
        }
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default){ action in
            self.fromSource(source: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageView.image = originalImage.circleMasked
        }
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = editedImage.circleMasked
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func fromSource(source: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Not Available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { alertAction in
                alert.dismiss(animated: true, completion: nil)
            })
            present(alert, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
