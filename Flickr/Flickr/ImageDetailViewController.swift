//
//  GalleryViewController.swift
//  Flickr
//
//  Created by metoSimka on 28/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var detailPhotoData = [Photo]()
    var indexCell: IndexPath?
    let BackIdentifier = "Show main view"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bigSpinner: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bigSpinner.startAnimating()
        guard let indexPath = indexCell else {
            return
        }
        collectionView?.scrollToItem(at: indexPath, at: .left, animated: false)
        bigSpinner.stopAnimating()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let identifier = segue.identifier else {
//            return
//        }
//        if identifier == BackIdentifier,
//            let icvc = segue.destination as? ImageDetailViewController,
//            let cell = sender as? ImageDetailViewCell,
//            let indexPath = self.searchCollectionView!.indexPath(for: cell) {
//            gvcvc.detailPhotoData = searchImageData
//            gvcvc.indexCell = indexPath
//        }
//        if identifier == Constants.SegueIdentifier.detailSegueFromPopulariew,
//            let gvcvc = segue.destination as? ImageDetailViewController,
//            let cell = sender as? ImageCollectionViewCell,
//            let indexPath = self.popularCollectionView!.indexPath(for: cell) {
//            gvcvc.detailPhotoData = popularImageData
//            gvcvc.indexCell = indexPath
//        }
//    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        
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
        guard let url = detailPhotoData[indexPath.row].url else {
            return cellPopular
        }
        imageCell.fetchImage(url: url)
        imageCell.imageView.contentMode = .scaleAspectFit
//        let viewsImage = detailPhotoData[indexPath.row].views
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
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
        
}

