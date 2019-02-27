//
//  ImageViewController.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit
import Alamofire
import collection_view_layouts

class ImageViewController: UIViewController, ContentDynamicLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    @IBInspectable
    var maxImagesToShow = 50 // just thinking about this, may be delete this idea. //sd
    var imageList = [[String: AnyObject]]()
    
    private var contentFlowLayout: ContentDynamicLayout?
    private var cellsSizes = [CGSize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func cellSize(indexPath: IndexPath) -> CGSize {
        return cellsSizes[indexPath.row]
    }
    
    private func showLayout() {
        contentFlowLayout = FlickrStyleFlowLayout()
        contentFlowLayout?.delegate = self
        contentFlowLayout?.contentPadding = ItemsPadding(horizontal: 10, vertical: 10)
        contentFlowLayout?.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
        collectionView.collectionViewLayout = contentFlowLayout!
        collectionView.setContentOffset(CGPoint.zero, animated: false)
        cellsSizes = CellSizeProvider.provideSizes()
        collectionView.reloadData()
        }

    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        let searchText = searchTextField.text
        if (searchText!.isEmpty) {
            displayAlert("Search text cannot be empty")
            return
        }
        let searchURL = flickrURLFromParameters(searchString: searchText!)
        print("URL: \(searchURL)")
        // Send the request
        performFlickrSearch(searchURL)
    }

    func displayAlert(_ message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func flickrURLFromParameters(searchString: String) -> URL {
        // Build base URL
        var components = URLComponents()
        components.scheme = Constants.FlickrURLParams.APIScheme
        components.host = Constants.FlickrURLParams.APIHost
        components.path = Constants.FlickrURLParams.APIPath
        // Build query string
        components.queryItems = [URLQueryItem]()
        // Query components
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.APIKey,
                                                   value: Constants.FlickrAPIValues.APIKey));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SearchMethod,
                                                   value: Constants.FlickrAPIValues.SearchMethod));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.ResponseFormat,
                                                   value: Constants.FlickrAPIValues.ResponseFormat));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Extras,
                                                   value: Constants.FlickrAPIValues.MediumURL));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SafeSearch,
                                                   value: Constants.FlickrAPIValues.SafeSearch));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.DisableJSONCallback,
                                                   value: Constants.FlickrAPIValues.DisableJSONCallback));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Text,
                                                   value: searchString));
        return components.url!
    }
    
    private func performFlickrSearch(_ searchURL: URL) {

        // Perform the request
        let session = URLSession.shared
        let request = URLRequest(url: searchURL)
        let task = session.dataTask(with: request){
            (data, response, error) in
            if (error == nil) {
                // Check response code
                let status = (response as! HTTPURLResponse).statusCode
                if (status < 200 || status > 300) {
                    self.displayAlert("Server returned an error")
                    return
                }

                /* Check data returned? */
                guard let data = data else {
                    self.displayAlert("No data was returned by the request!")
                    return
                }
                
                // Parse the data
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    self.displayAlert("Could not parse the data as JSON: '\(data)'")
                    return
                }
                print("Result: \(parsedResult)")
                
                // Check for "photos" key in our result
                guard let photosDictionary = parsedResult["photos"] as? [String:AnyObject] else {
                    self.displayAlert("Key 'photos' not in \(parsedResult)")
                    return
                }
                print("Result: \(photosDictionary)")
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    self.displayAlert("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }
                
                // Check number of photos
                if photosArray.count == 0 {
                    self.displayAlert("No Photos Found. Search Again.")
                    return
                } else {
                    // Get the first image
                    let photoDictionary = photosArray[0] as [String: AnyObject]
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary["url_m"] as? String else {
                        self.displayAlert("Cannot find key 'url_m' in \(photoDictionary)")
                        return
                    }
                    //     self.imageList = photosArray
                    self.imageList = photosArray
                    DispatchQueue.main.async(){
                    self.collectionView!.reloadData()
                    self.showLayout()
                    }
                }
            } else {
                self.displayAlert((error?.localizedDescription)!)
            }
        }
        task.resume()
    }

    func getUrlFromArray(photosArray: [[String: AnyObject]], index: Int) -> String? {
        
        let photoDictionary = photosArray[index] as [String: AnyObject]
        guard let imageUrlString = photoDictionary["url_m"] as? String else {
            self.displayAlert("Cannot find key 'url_m' in \(photoDictionary)")
            return nil
        }
        return imageUrlString
    }
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "image Cell",
                                                       for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell {
            guard let gettedUrl = getUrlFromArray(photosArray: imageList,
                                                  index: indexPath.row) else { return cell }
            imageCell.fetchImage(url: gettedUrl)
        }
        return cell
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        myCollection.collectionViewLayout.invalidateLayout()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }  
}




