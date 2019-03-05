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

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
                guard let gettedUrl = main.getUrlFromArray(photosArray: photoGalleryData, index: indexPath.row) else {
                    return cellPopular
                }
                imageCell.fetchImage(url: gettedUrl)
                return cellPopular
            }
        return cellPopular
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
    }
}
