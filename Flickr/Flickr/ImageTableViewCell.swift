//
//  ImageTableViewCell.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ImageTableViewCell: UITableViewCell {
    
    var imagesArray: [[String: AnyObject]]?
    
    var cache: Cache?
    
    
//    func updateImage(newMedia: [[String: AnyObject]]?) {
//
//        imageView!.image = nil
//        guard let url = "0" else { return }
////        spinner?.startAnimating()
//
//        if let imageData = cache?[url] {
////            spinner?.stopAnimating()
//            imageView.image = UIImage(data: imageData)
//            return
//        }
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            if url == newMedia?.media.url,
//                let imageData = try? Data(contentsOf: url) {
//
//                DispatchQueue.main.async {
//                    self?.imageView.image = UIImage(data: imageData)
//
//                    self?.cache?[url] = imageData
////                    self?.spinner.stopAnimating()
//                }
//            }
//        }
//
//    }
    
    @IBOutlet weak var imageCell: UIImageView!
    
  

    
    func fetchImage(_ url: String) {
        
        let imageURL = URL(string: url)
        
        let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
            if error == nil {
                let downloadImage = UIImage(data: data!)!
                
                DispatchQueue.main.async(){
                    self.imageCell.image = downloadImage
                }
            }
        }
        
        task.resume()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
