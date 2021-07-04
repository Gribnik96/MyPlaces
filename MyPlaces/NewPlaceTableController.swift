//
//  NewPlaceTableController.swift
//  MyPlaces
//
//  Created by Nikita Gribin on 01.07.2021.
//

import UIKit

class NewPlaceTableController: UITableViewController {
    
    var currentPlace: Place?
   
    var imageIsChanged = false
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        tableView.tableFooterView = UIView()
        
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                         message: nil,
                                         preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera",
                                             style: .default) { _ in
                self.chooseImagePicker(source: .camera)
                
            }
            cameraAction.setValue(cameraIcon, forKey: "image")
            
            let photoAction = UIAlertAction(title: "Photo", style: .default) { _ in self.chooseImagePicker(source: .photoLibrary)
                
            }
            photoAction.setValue(photoIcon, forKey: "image")
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(photoAction)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            view.endEditing(true)
        }
    }
    
    private func setupEditScreen() {
        
        if currentPlace !== nil {
            imageIsChanged = true
            setupNavigationBar()
            guard  let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
        }
        
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
        
    }
    
    
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


extension NewPlaceTableController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @objc private func textFieldChanged() {
      
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func savePlace() {
        
       
        
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
       
        
        if currentPlace !== nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
            }
            } else {
                StorageManager.saveObject(newPlace)
            }
        }
        
    
    
    
    
    
    
    
    
}
extension NewPlaceTableController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker (source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true, completion: nil)
    }
}
