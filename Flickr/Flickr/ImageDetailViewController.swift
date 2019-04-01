//
//  GalleryViewController.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit
import SDWebImage

class ImageDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, imageDetailViewCellDelegate {
    
    var curIndexPath: IndexPath?
    var isHiden = false
    var cellOffset:CGFloat = 24
    var detailPhotoData = [Photo]()
    var indexCell: IndexPath?
    let BackIdentifier = "Show main view"
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alpha = 0
               self.collectionView?.isPagingEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPath = indexCell else {
            return
        }
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionView.alpha = 1
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func createURLForIcon(iconFarm: String, iconServer: String, nsid: String) -> String {
        let url = "http://farm\(iconFarm).staticflickr.com/\(iconServer)/buddyicons/\(nsid).jpg"
        return url
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return detailPhotoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "Detail Image Cell",
                                                             for: indexPath)
        guard let imageCell = cellPopular as? ImageDetailViewCell else {
            return UICollectionViewCell()
        }
        
        /// Mark : - get data for creation url for avatar icon
        guard let icon_farm = detailPhotoData[indexPath.row].icon_farm else {
            return UICollectionViewCell()
        }
        guard let icon_server = detailPhotoData[indexPath.row].icon_server else {
            return UICollectionViewCell()
        }
        guard let nsid = detailPhotoData[indexPath.row].nsid else {
            return UICollectionViewCell()
        }
        let iconURL = createURLForIcon(iconFarm: icon_farm, iconServer: icon_server, nsid: nsid)
        
        /// Mark : - get best url and size for image
        guard let imageURL = detailPhotoData[indexPath.row].url_best else {
            return UICollectionViewCell()
        }
        guard let imageSize = detailPhotoData[indexPath.row].size_best else {
            return UICollectionViewCell()
        }
        
        imageCell.fetchImage(url: imageURL, icon: iconURL)
        imageCell.setScrollViewBehavior(for: imageSize)
        let titleText = detailPhotoData[indexPath.row].title
        imageCell.titleText.text = "Title: \(titleText ?? "")"
        let viewText = detailPhotoData[indexPath.row].views
        imageCell.viewText.text = "Views: \(viewText ?? "")"
        let nickText = detailPhotoData[indexPath.row].ownerName
        imageCell.nickLabel.text = " \(nickText ?? "")"
        return cellPopular
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        self.collectionView?.frame = view.frame.insetBy(dx: (-cellOffset/2), dy: 0.0)
        return cellOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellOffset/2, bottom: 0, right: cellOffset/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        curIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ImageDetailViewCell else {
            return
        }
        if isHiden {
            imageCell.infoView.alpha = 0
        } else {
            imageCell.infoView.alpha = 1
        }
        imageCell.delegate = self
        guard let imageSize = detailPhotoData[indexPath.row].size_best else {
            return 
        }
        imageCell.setScrollViewBehavior(for: imageSize)
    }
    
    func didTapScrollView(_ sender: ImageDetailViewCell) {
        for cell in self.collectionView.visibleCells {
            guard let cell = cell as? ImageDetailViewCell else {
                continue
            }
            UIView.animate(withDuration: 0.5, animations: {
                if self.isHiden {
                    cell.infoView.alpha = 1
                    self.backButton.alpha = 1
                    
                } else {
                    cell.infoView.alpha = 0
                    self.backButton.alpha = 0
                }
            })
        }
        if isHiden {
            isHiden = false
        } else {
            isHiden = true
        }
    }
    
}


