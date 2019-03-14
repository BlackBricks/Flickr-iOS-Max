//
//  GalleryViewController.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var photoGalleryData = [Photo]()
    var main = ImageCollectionViewController()
    var indexCell: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alpha = 0
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPath = indexCell else {
            return
        }
        collectionView?.scrollToItem(at: indexPath, at: .left, animated: false)
        collectionView.alpha = 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return photoGalleryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "Gallery Image Cell",
                                                             for: indexPath)
        guard let imageCell = cellPopular as? ImageDetailViewCell else {
            return UICollectionViewCell()
        }
        guard let url = photoGalleryData[indexPath.row].url else {
            return cellPopular
        }
        let titleText = photoGalleryData[indexPath.row].title
        imageCell.titleText.text = "Title: \(titleText)"
        let viewsImage = photoGalleryData[indexPath.row].views
        imageCell.viewText.text = "Title: \(titleText)"
        imageCell.fetchImage(url: url)
        imageCell.imageView.contentMode = .scaleAspectFit
        return cellPopular
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

