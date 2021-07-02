//
//  NewPlaceTableController.swift
//  MyPlaces
//
//  Created by Nikita Gribin on 01.07.2021.
//

import UIKit

class NewPlaceTableController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let actionSheet = UIAlertController(title: nil,
                                         message: nil,
                                         preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "Camera",
                                             style: .default) { _ in
                self.chooseImagePicker(source: .camera)            }
            let photoAction = UIAlertAction(title: "Photo", style: .default) { _ in self.chooseImagePicker(source: .photoLibrary)
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(photoAction)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            view.endEditing(true)
        }
    }

}


extension NewPlaceTableController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension NewPlaceTableController {
    func chooseImagePicker (source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
}
