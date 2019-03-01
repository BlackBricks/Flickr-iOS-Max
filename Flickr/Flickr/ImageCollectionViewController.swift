//
//  ImageViewController.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//


import UIKit
import Alamofire

class ImageCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
  
    fileprivate var imageData: [Photo] = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func searchButtonAction(_ sender: UIButton) {
        let searchText = searchTextField.text
        guard let searchingText = searchText else {
            return
        }
        guard !searchingText.isEmpty else {
            displayAlert("Search text cannot be empty")
            return
        }
        let searchURL = flickrURLFromParameters(searchString: searchingText)
        // Send the request
        guard let searchUrl = searchURL else {
            return
        }
        performFlickrSearch(url: searchUrl)
        self.collectionView?.reloadData()
    }
    

    private func showLayout() {
    }
    
    private func flickrURLFromParameters(searchString: String) -> URL? {       // needs for customize Search text
        // Build base URL
        var components = URLComponents()
        components.scheme = Constants.FlickrURLParams.APIScheme
        components.host = Constants.FlickrURLParams.APIHost
        components.path = Constants.FlickrURLParams.APIPath
        // Build query string
        components.queryItems = [URLQueryItem]()
        // Query components
        guard var compotent = components.queryItems else {
            return nil
        }
        compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.APIKey,
                                      value: Constants.FlickrAPIValues.APIKey));
        compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.SearchMethod,
                                      value: Constants.FlickrAPIValues.SearchMethod));
       compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.ResponseFormat,
                                     value: Constants.FlickrAPIValues.ResponseFormat));
        compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.Extras,
                                      value: Constants.FlickrAPIValues.ExtrasValue));
        compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.SafeSearch,
                                      value: Constants.FlickrAPIValues.SafeSearch));
        compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.DisableJSONCallback,
                                      value: Constants.FlickrAPIValues.DisableJSONCallback));
        compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.Text,
                                      value: searchString));
        compotent.append(URLQueryItem(name: Constants.FlickrAPIKeys.Sort,
                                      value: Constants.FlickrAPIValues.SortValue));
        
        components.queryItems = compotent
        guard let componentsUrl = components.url else {
            return nil
        }
        return componentsUrl
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performFlickrSearch(url: URL) {
        Alamofire.request(url).responseJSON { response in
        }
    }
    
    func handlingResponseData (data: DataResponse<Any> ) {
        guard data.result.isSuccess else {
            self.displayAlert("Error get data \(String(describing: data.result.error))")
            return
        }
        guard
            let value = data.result.value as? [String: AnyObject],
            let dict = value["photos"] as? [String: AnyObject],
            let photosData = dict["photo"] as? [[String: AnyObject]]
            else {
                print("Error parse data")
                return
        }
        let photos = Photo.getPhotos(data: photosData)
        self.imageData = photos
        print(data.value ?? "nothing")
        DispatchQueue.main.async() {
            self.collectionView?.reloadData()
        }
    }
    
    func getUrlFromArray(photosArray: [Photo], index: Int) -> String? {
        let photoItem = photosArray[index]
        guard let urlImage = photoItem.url else {
            return nil
        }
        return urlImage
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "image Cell", for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell {
            guard let gettedUrl = getUrlFromArray(photosArray: imageData,
                                                  index: indexPath.row) else {
                                                    return cell
            }
            imageCell.fetchImage(url: gettedUrl)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {    // in process
        if segue.identifier == Constants.SegueIdentifier.GallerySegue {
            if let gvcvc = segue.destination as? GalleryViewingCollectionViewController {
                gvcvc.photoGalleryData = imageData
                if let cell = sender as? ImageCollectionViewCell,
                    let tweetMedia = gvcvc.photoGalleryData {

                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}




