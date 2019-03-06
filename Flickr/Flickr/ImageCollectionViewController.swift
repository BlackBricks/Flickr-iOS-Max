//
//  ImageViewController.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//


import UIKit
import Alamofire

class ImageCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate var imageData: [Photo] = [Photo]()
    var isSearching = false
    var sizes: [CGSize] = [CGSize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCollectionView.alpha = 1
        popularCollectionView.alpha = 0
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Alamofire.request(Router.popular(page: 1)).responseJSON { (response) in
            self.handlingResponseData(data: response)
        }
    }
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func searchButtonAction(_ sender: UIButton) {
        isSearching = true
        let searchText = searchTextField.text
        guard let searchingText = searchText else {
            return
        }
        guard !searchingText.isEmpty else {
            displayAlert("Search text cannot be empty")
            return
        }
        performFlickrSearch(url: searchingText)
    }
    
    enum Router: URLRequestConvertible {
        case search(text: String, page: Int)
        case popular(page: Int)
        static let baseURLString = Constants.FlickrAPI.baseUrl
        static let perPage = 50
        // MARK: URLRequestConvertible
        func asURLRequest() throws -> URLRequest {
            let result: (path: String, parameters: Parameters) = {
                switch self {
                case let .search(text, _):
                    var searchParams = Constants.searchParams
                    searchParams["text"] = text
                    return (Constants.FlickrAPI.path, searchParams)
                case .popular(_):
                    return  (Constants.FlickrAPI.path, Constants.popularParams)
                }
            }()
            let url = try Router.baseURLString.asURL()
            let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
            return try URLEncoding.default.encode(urlRequest, with: result.parameters)
        }
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performFlickrSearch(url: String) {
        print("\(Alamofire.request(Router.search(text: url, page: 1)).responseJSON)")
        Alamofire.request(Router.search(text: url, page: 1)).responseJSON { (response) in
            self.handlingResponseData(data: response)
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
        sizes = Photo.getSizes(data: imageData)
        let LaySizes: [CGSize] = sizes.lay_justify(for: view.bounds.size.width, preferredHeight: view.bounds.size.height )
        sizes = LaySizes
        print(data.value ?? "nothing")
        DispatchQueue.main.async() {
            self.searchCollectionView?.reloadData()
            self.popularCollectionView?.reloadData()
            if self.isSearching == true {
                self.searchCollectionView.alpha = 1
                self.popularCollectionView.alpha = 0
                self.searchCollectionView.isHidden = false
                self.popularCollectionView.isHidden = true
            } else {
                self.popularCollectionView.alpha = 1
                self.searchCollectionView.alpha = 0
                self.popularCollectionView.isHidden = false
                self.searchCollectionView.isHidden = true
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        print("\(imageData.count) loaded")
        return imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.searchCollectionView {
            let cellSearch = collectionView.dequeueReusableCell(withReuseIdentifier: "image Cell",
                                                                for: indexPath)
            if let imageCell = cellSearch as? ImageCollectionViewCell {
                guard let gettedUrl = Photo.getUrlFromArray(photosArray: imageData, index: indexPath.row) else {
                    return cellSearch
                }
                imageCell.fetchImage(url: gettedUrl)
                return cellSearch
            }
        }
        
        if collectionView == self.popularCollectionView {
            let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularImage Cell",
                                                                 for: indexPath)
            if let imageCell = cellPopular as? PopularCollectionViewCell {
                guard let gettedUrl = Photo.getUrlFromArray(photosArray: imageData, index: indexPath.row) else {
                    return cellPopular
                }
                imageCell.fetchImage(url: gettedUrl)
                return cellPopular
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizes[indexPath.row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Constants.SegueIdentifier.GallerySegue,
                let gvcvc = segue.destination as? GalleryViewingCollectionViewController,
                let cell = sender as? ImageCollectionViewCell {
                let indexPath = self.searchCollectionView!.indexPath(for: cell)
                gvcvc.photoGalleryData = imageData
                gvcvc.indexCell = indexPath
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
