//
//  ImageItemCVCell.swift
//  GridExample
//
//  Created by Dushan Saputhanthri on 3/10/19.
//  Copyright © 2019 Elegant Media Pvt Ltd. All rights reserved.
//

import UIKit

class ImageItemCVCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var actionImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        itemImageView.image = nil
        actionImageView.image = nil
        contentView.backgroundColor = .white
    }
    
    func configureCell(with model: ImageItem) {
        switch model.isActive {
        case true:
            itemImageView.image = nil
            actionImageView.image = #imageLiteral(resourceName: "ic_createprofile_camera")
            contentView.backgroundColor = .white
        default:
            guard let _image = model.image else {
                itemImageView.image = nil
                actionImageView.image = nil
                contentView.backgroundColor = .groupTableViewBackground
                return
            }
            
            itemImageView.image = _image
            actionImageView.image = #imageLiteral(resourceName: "ic_delete")
            contentView.backgroundColor = .white
        }
    }
}
