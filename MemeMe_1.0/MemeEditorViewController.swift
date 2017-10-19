//
//  MemeEditorViewController.swift
//  MemeMe_1.0
//
//  Created by Luciano Schillagi on 4/10/16.
//  Copyright © 2016 Luko. All rights reserved.
//

import UIKit


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
	
    // Outlets
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem! //va esto?
	
    var memedImage: UIImage!
    
    // DidLoad, WillAppear, WillDissappear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextAttribute(bottomText, str : " BOTTOM ")
        setTextAttribute(topText, str: " TOP ")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        shareButton.isEnabled = imagePickerView.image != nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Keyboard Subscriptions
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Keyboard Will Show/Hide
    func keyboardWillShow(_ notification: Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    // Keyboard Height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Actions

    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        
        if (sender == cameraButton) {
            presentPickerController(sourceType: .camera)
        }
        else {
            presentPickerController(sourceType: .photoLibrary)
        }
    }
    
    func presentPickerController(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
			
    }

    // Text Fields
    
    // Texts Attributes
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "Impact", size: 45)!,
        NSStrokeWidthAttributeName : NSNumber(value: -3.0 as Float)
    ]
    
    // Default Text Settings
    
    func setTextAttribute(_ textField : UITextField, str : String) {
        textField.delegate = self
        textField.text = str
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.autocapitalizationType = .allCharacters
        
    }
    
    // Text Editing
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == topText && topText.text == " TOP ") {
            topText.text = ""
        } else if (textField == bottomText && bottomText.text == " BOTTOM ") {
            bottomText.text = ""
        }
    }
    
    // Return To Escape
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Generate meme + save
    
    
    @IBAction func shareButton(_ sender: AnyObject) {
        
        let memeToShare = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memeToShare], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.safelySaveMeme(memeToShare)
            }
        }
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    func generateMemedImage() -> UIImage {
        
        toolBarVisible(false)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBarVisible(true)
        
        return memedImage
    }
    
    
    func safelySaveMeme(_ memedImage: UIImage) {
        // safely unwrap optionals
        if imagePickerView.image != nil && topText.text != nil && bottomText.text != nil
        {
            let top = self.topText.text!
            let bottom = self.bottomText.text!
            let image = self.imagePickerView.image!
            
            let meme = MemeObject (topText: top, bottomText: bottom, originalImage: image, memedImage: memedImage)
            (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        }
    }
    
    // Toolbar functions
    func toolBarVisible(_ visible: Bool){
        if !visible {
            navBar.isHidden = true    // removed self
            toolBar.isHidden = true // typo on var for toolbar // removed self
        } else {
            navBar.isHidden = false   // removed self
            toolBar.isHidden = false  // removed self
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true     // status bar should be hidden
    }
    
    
    // Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Did Cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
        
}










