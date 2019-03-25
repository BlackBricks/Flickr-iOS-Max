//
//  GalleryViewController.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var cellOffset:CGFloat = 8
    var detailPhotoData = [Photo]()
    var indexCell: IndexPath?
    let BackIdentifier = "Show main view"
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bigSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alpha = 0
        
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bigSpinner.startAnimating()
        guard let indexPath = indexCell else {
            return
        }
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        bigSpinner.stopAnimating()
        collectionView.alpha = 1
    }

    @IBAction func backButton(_ sender: UIButton) {
         _ = navigationController?.popViewController(animated: true)
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
        guard let imageURL = Photo.searchBestQualityInFuckingFlickr(from: detailPhotoData, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        imageCell.fetchImage(url: imageURL)
        imageCell.setScrollView()
        guard let titleText = detailPhotoData[indexPath.row].title else {
            return cellPopular
        }
        imageCell.titleText.text = "Title: \(titleText)"
        guard let viewText = detailPhotoData[indexPath.row].views else {
            return cellPopular
        }
        imageCell.viewText.text = "Views: \(viewText)"
        return cellPopular
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - cellOffset, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellOffset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellOffset/2, bottom: 0, right: cellOffset/2);
    }

}

