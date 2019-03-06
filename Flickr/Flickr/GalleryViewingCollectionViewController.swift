//
//  GalleryViewController.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class GalleryViewingCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var photoGalleryData = [Photo]()
    var main = ImageCollectionViewController()
    var indexCell: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
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
        print("\(photoGalleryData.count)")
        return photoGalleryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "Gallery Image Cell",
                                                             for: indexPath)
        if let imageCell = cellPopular as? GalleryViewingCollectionViewCell {
            guard let gettedUrl = Photo.getUrlFromArray(photosArray: photoGalleryData, index: indexPath.row) else {
                return cellPopular
            }
            let titleImage = Photo.getTitleFromArray(photosArray: photoGalleryData, index: indexPath.row)
            imageCell.titleText.text = "Title: \(titleImage ?? "no info")"
            let viewsImage = Photo.getViewsFromArray(photosArray: photoGalleryData, index: indexPath.row)
            imageCell.viewText.text = "Views: \(viewsImage ?? "no info")"
            imageCell.fetchImage(url: gettedUrl)
            imageCell.imageView.contentMode = .scaleAspectFit
            return cellPopular
        }
        return cellPopular
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

