//
//  ViewController.swift
//  MemeMe_1.0
//
//  Created by Luko on 26/9/16.
//  Copyright © 2016 imac. All rights reserved.
//

/*import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    

    // Salidas
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem! //va esto?
 
 
    
     var memedImage: UIImage!
    
    // VC Ciclo de vida
    
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

    // Subscripciones del TECLADO
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    // End
    
    // Keyboard Will Show/Hide
    func keyboardWillShow(_ notification: Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    // End
    
    // Keyboard Height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // interACCIONES
    
    //ir a Photo Gallery
    @IBAction func pickAnImage(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }

    
    //ir a Camera
    @IBAction func pickAnImageFromCamera(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
        
    }


    //One Function To Rule Them Both
    func simplify(_ fromCamera: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if fromCamera {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
 //
    
    

    // CAMPOS DE TEXTO (TOP y BOTTOM)
    
    // Atributos del texto
    
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
        //textField.autocapitalizationType = .allCharacters
        
    }
    
    // Edición del texto
    
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
    

    // MARK: generate meme + save // SACADO DEL CODIGO DE WARREN HANSEN
    

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

    // MARK: toolbar functions
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

 // HASTA ACÁ
    
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

*/







