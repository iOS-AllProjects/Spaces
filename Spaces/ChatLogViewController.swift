//
//  ChatLogViewController.swift
//  Spaces
//
//  Created by Etjen Ymeraj on 6/15/17.
//  Copyright © 2017 Etjen Ymeraj. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var chatCollectionView: UICollectionView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inputBottom: NSLayoutConstraint!
    var person: Person?
    var messages = [Message]()
    var startingFrame : CGRect?
    var blackBackgroundView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupKeyboardObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func tapOnScreen(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    func setupUI(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        chatCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
        chatCollectionView.scrollIndicatorInsets  = UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
        
        if let person = person{
            self.title = person.name
            observeMessages()
        }
    }
    
    private func scrollToBottom() {
        if messages.count > 0 {
        let lastSectionIndex = (chatCollectionView?.numberOfSections)! - 1
        let lastItemIndex = (chatCollectionView?.numberOfItems(inSection: lastSectionIndex))! - 1
        let indexPath = IndexPath(item: lastItemIndex, section: lastSectionIndex)
        chatCollectionView!.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
        }
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardDidShow(notification: Notification){
        scrollToBottom()
    }
    
    func handleKeyboardWillShow(notification: Notification){
            inputBottom.constant += getKeyboardHeight(notification: notification)
            UIView.animate(withDuration: keyboardDuration(notification: notification)) { 
                self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: Notification){
        inputBottom.constant = 0
        UIView.animate(withDuration: keyboardDuration(notification: notification)) {
            self.view.layoutIfNeeded()
        }
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        guard let info = notification.userInfo else { return .leastNormalMagnitude }
        guard let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return .leastNormalMagnitude }
        let keyboardSize = value.cgRectValue.size
        return keyboardSize.height
    }
    
    func keyboardDuration(notification: Notification) -> Double {
        guard let info = notification.userInfo else { return .leastNormalMagnitude }
        guard let value = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return .leastNormalMagnitude }
        let keyboardDuration = value.doubleValue
        return keyboardDuration
    }
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toID = person?.id else{
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toID)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {
                return
                }
                
                let message = Message(dictionary: dictionary)
                
                if message.chatPartnerId() == self.person?.id{
                    self.messages.append(message)
                    performUIUpdatesOnMain {
                        self.chatCollectionView.reloadData()
                        self.scrollToBottom()
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func sendButtonTapped(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text != "" {
        let properties = ["text": text] as [String : Any]
        sendMessageWithProperties(properties: properties)
            }
        }
    }
    @IBAction func cameraButtonTapped(_ sender: Any) {
        callActionSheet()
    }
}

extension ChatLogViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //To do
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! chatCell
        let message = messages[indexPath.item]
        setupCell(cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidth.constant = estimatedFrameForText(text: text).width + 12
            cell.messageImageView.isHidden = true
            cell.chatTextView.isHidden = false
        } else if message.imageURL != nil {
            cell.bubbleWidth.constant = 200
            cell.messageImageView.isHidden = false
            cell.chatTextView.isHidden = true
        }
        
        if message.fromID == Auth.auth().currentUser?.uid{
            cell.bubbleView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            cell.profileImageView.isHidden = true
            cell.bubbleTrailing.constant = 0
        } else {
            cell.bubbleView.backgroundColor = UIColor.white
            cell.profileImageView.isHidden = false
            cell.bubbleTrailing.constant = view.frame.width - cell.bubbleWidth.constant - cell.profileImageView.frame.width - 24
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    fileprivate func setupCell(_ cell: chatCell, message: Message) {
        cell.message = message
        
        cell.messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        if let profileImageURL = self.person?.profileImageURL{
            let url = URL(string: profileImageURL)
            self.getDataFromUrl(url: url!) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                performUIUpdatesOnMain {
                    cell.profileImageView.image = UIImage(data: data)
                }
            }
        }
        if let messageImageURL = message.imageURL {
            let url = URL(string: messageImageURL)
            self.getDataFromUrl(url: url!) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                performUIUpdatesOnMain {
                    cell.messageImageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
        performZoomForImageView(imageView: imageView)
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
            })
        }
    }
    
    func performZoomForImageView(imageView: UIImageView){
        
            startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
            let zoomingImageView = UIImageView(frame: startingFrame!)
            zoomingImageView.image = imageView.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            if let keyWindow = UIApplication.shared.keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.black
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                keyWindow.addSubview(zoomingImageView)
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.blackBackgroundView?.alpha = 1
                    let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    zoomingImageView.center = keyWindow.center
                }, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        chatCollectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 18
        } else if let imageWidth = message.imageWidth?.floatValue , let imageHeight = message.imageHeight?.floatValue {
            // Calculate height
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width - 10, height: height)
    }
    
    func estimatedFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
}

extension ChatLogViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

extension ChatLogViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
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
    
    func uploadToFirebaseStorageUsingImage(image: UIImage){
        let imageName = UUID().uuidString
        // Create a reference to the storage
        let storageRef = Storage.storage().reference().child("messageImages").child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(image){
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print(error!)
                    return
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageURL(imageURL: imageURL, image: image)
                }
                print(metadata!)
            })
        }
    }
    
    func sendMessageWithProperties(properties: [String: Any]){
        if let person = person {
            let ref = Database.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            let toID = person.id!
            let fromID = Auth.auth().currentUser!.uid
            let timestamp = NSDate().timeIntervalSince1970
            var values = ["toID": toID, "fromID": fromID, "timestamp": timestamp] as [String : Any]
            
            properties.forEach({ values[$0] = $1 })
            
            childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if error != nil{
                    print(error!)
                    return
                }
                self.inputTextField.text = nil
                
                
                let userMessagesRef = Database.database().reference().child("user-messages").child(fromID).child(toID)
                let messageId = childRef.key
                userMessagesRef.updateChildValues([messageId: 1])
                
                let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toID).child(fromID)
                recipientUserMessageRef.updateChildValues([messageId: 1])
                
            })
        }
    }

    func sendMessageWithImageURL(imageURL: String, image: UIImage){
        let properties = ["imageURL": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : Any]
        sendMessageWithProperties(properties: properties)
    }
}
