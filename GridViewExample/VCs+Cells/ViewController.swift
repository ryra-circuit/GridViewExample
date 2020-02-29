//
//  ViewController.swift
//  GridExample
//
//  Created by Dushan Saputhanthri on 3/10/19.
//  Copyright © 2019 Elegant Media Pvt Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
    @IBOutlet weak var collectionView: UICollectionView! { didSet {
        collectionView.dataSource = self
        collectionView.delegate = self
    }}
    
    let imagePicker = UIImagePickerController()
    
    var imageItems: [ImageItem] = []
    var imageURLs: [URL] = []
    var imageUUIDs: [String] = []
    
    var activeIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        setDefaultData()
    }
}

extension ViewController {
    
    func setDefaultData() {
        let itemWithCamera = ImageItem(isActive: true, image: nil, url: nil)
        let itemPlaceholder = ImageItem(isActive: false, image: nil, url: nil)
        
        let defaultImageItems = [itemWithCamera, itemPlaceholder,itemPlaceholder, itemPlaceholder, itemPlaceholder,itemPlaceholder, itemPlaceholder, itemPlaceholder,itemPlaceholder]
        
        imageItems.append(contentsOf: defaultImageItems)
        
        self.collectionView.reloadData()
    }
    
    func showImagePickerAlert(sourceView: UIView, editting: Bool) {
        let action1 = AlertAction(title: TakePhoto, style: .default)
        let action2 = AlertAction(title: ChooseFromLibrary, style: .default)
        
        AlertProvider(vc: self).showActionSheetWithActions(title: nil, message: nil, actions: [action1, action2], sourceView: sourceView, completion:  { (action) in
            if action.title == TakePhoto {
                self.provideCameraForImagePicking(editting: editting)
            }
            else if action.title == ChooseFromLibrary {
                self.provideGalleryForImagePicking(editting: editting)
            }
        })
    }
    
    // Provide Camera
    func provideCameraForImagePicking(editting: Bool) {
        self.imagePicker.allowsEditing = editting
        self.imagePicker.sourceType = .camera
        self.imagePicker.cameraCaptureMode = .photo
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // Provide Image Library
    func provideGalleryForImagePicking(editting: Bool) {
        self.imagePicker.allowsEditing = editting
        self.imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image: UIImage = info[.originalImage] as? UIImage {
            
            let data = image.jpegData(compressionQuality: 0.5)
            
            guard data?.count ?? 0 < 5242880 else {
                self.dismiss(animated:true, completion: {
                    print("Maximum file size is 5Mb.")
                })
                return
            }
            
            imageItems[activeIndex].image = image
            imageItems[activeIndex].isActive = false
            
            
            let randomString = NSUUID().uuidString
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent(randomString + ".jpeg")
            
            if let _data = data {
                do {
                    try _data.write(to: fileURL)
                    imageURLs.append(fileURL)
                    imageItems[activeIndex].url = fileURL
                } catch {
                    print("Error saving image")
                }
            }
            
            self.dismiss(animated:true, completion: {
                self.activeIndex = self.activeIndex + 1
                self.imageItems[self.activeIndex].isActive = true
                self.collectionView.reloadData()
            })
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell: ImageItemCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageItemCell", for: indexPath) as? ImageItemCVCell {
            let item = imageItems[indexPath.row]
            cell.configureCell(with: item)
            
             return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = imageItems[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)
        
        switch item.isActive {
        case true:
            self.showImagePickerAlert(sourceView: cell?.contentView ?? UIView(), editting: false)
        default:
            self.removeImage(from: indexPath.row)
        }
    }
    
    func removeImage(from index: Int) {
        
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let itemWidth = (availableWidth / itemsPerRow)
        let itemHeight = itemWidth
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

let TakePhoto = "Take Photo"
let ChooseFromLibrary = "Choose from Library"

struct ImageItem {
    var isActive: Bool = false
    var image: UIImage?
    var url: URL?
}

