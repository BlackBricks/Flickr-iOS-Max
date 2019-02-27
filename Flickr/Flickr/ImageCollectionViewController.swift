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

class ImageCollectionViewController: UIViewController, ContentDynamicLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    class Photo {
        var Url: String?
        var id: Int?
        var someAnotherVarJustForExample: String?
    }
    fileprivate var imageList: [Photo] = [Photo]()
    private var contentFlowLayout: ContentDynamicLayout?
    private var cellsSizes = [CGSize]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func searchButtonAction(_ sender: UIButton) {
        
        let searchText = searchTextField.text
        guard let searchingText = searchText else { return }
        if searchingText.isEmpty {
            displayAlert("Search text cannot be empty")
            return
        }
        let searchURL = flickrURLFromParameters(searchString: searchText!)
        print("URL: \(searchURL)")
        // Send the request
        performFlickrSearch(url: searchURL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func cellSize(indexPath: IndexPath) -> CGSize {
        return cellsSizes[indexPath.row]
    }
    
    private func showLayout() {
        contentFlowLayout = FlickrStyleFlowLayout()
        guard let contentFlowLayout = contentFlowLayout else {
            return
        }
        contentFlowLayout.delegate = self
        contentFlowLayout.contentPadding = ItemsPadding(horizontal: 10, vertical: 10)
        contentFlowLayout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
        contentFlowLayout.contentAlign = .left
        
        collectionView.collectionViewLayout = contentFlowLayout
        collectionView.setContentOffset(CGPoint.zero, animated: false)
//        cellsSizes = CellSizeProvider.provideSizes()
        collectionView.reloadData()
    }
    
    private func flickrURLFromParameters(searchString: String) -> URL {       // needs for customize Search text
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
 
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performFlickrSearch(url: URL) {
        Alamofire.request(url).responseJSON { response in
            guard response.result.isSuccess else {
                print("Ошибка при запросе данных \(String(describing: response.result.error))")
                return
            }

            guard
                let value = response.result.value as? [String: AnyObject],
                let dict = value["photos"] as? [String: AnyObject],
                let photosData = dict["photo"] as? [[String: AnyObject]]
                else {
                    print("Error parse data")
                    return
            }

            let photos = photosData.map({ (photoDictionary) -> Photo in
                let interestData = Photo()
                
               guard let imageUrl = photoDictionary["url_m"] as? String else { return interestData }
                interestData.Url = imageUrl
                
                guard let idNumber = photoDictionary["id"] as? Int else { return interestData }
                interestData.id = idNumber
                
                return interestData
            })
            self.imageList = photos
            print(response.value)
            DispatchQueue.main.async(){
                self.collectionView!.reloadData()
                self.showLayout()
            }
        }
    }
    
    func getUrlFromArray(photosArray: [Photo], index: Int) -> String? {
        let photoItem = photosArray[index]
        let urlImage = photoItem.Url!
        return urlImage
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }  
}




