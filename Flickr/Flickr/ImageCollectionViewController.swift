//
//  ImageViewController.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//


import UIKit
import Alamofire

class ImageCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    var actualPosition: CGPoint?
    var justPrefferedHeight: CGFloat = 150
    var basicIndent: CGFloat = 2
    var searchList = [String]()
    fileprivate var popularImageData: [Photo] = [Photo]()
    var popularImageSizes: [CGSize] = [CGSize]()
    fileprivate var searchImageData: [Photo] = [Photo]()
    var searchImageSizes: [CGSize] = [CGSize]()
    var isSearching = false
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchConstraint: NSLayoutConstraint!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCollectionView.alpha = 0
        popularCollectionView.alpha = 1
        searchTextField.delegate = self
        searchConstraint.priority = UILayoutPriority(rawValue: 999);
        searchConstraint.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performFlickrPopular()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchText = searchTextField.text
        guard let searchingText = searchText else {
            return false
        }
        guard !searchingText.isEmpty else {
            displayAlert("Search text cannot be empty")
            return false
        }
        searchTextField?.resignFirstResponder()
        performFlickrSearch(url: searchingText)
        searchCollectionView.alpha = 1
        isSearching = true
        rememberWord(searchingText)
        return true
    }
    
    func rememberWord(_ text: String) {
        if searchList.contains(text) {
            return
        } else {
            searchList.append(text)
        }
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performFlickrSearch(url: String) {
        print("\(Alamofire.request(Router.search(text: url, page: 2)).responseJSON)")
        Alamofire.request(Router.search(text: url, page: 2)).responseJSON { (response) in
            self.handlingSearchResponseData(data: response)
        }
    }
    
    private func performFlickrPopular() {
        print("\(Alamofire.request(Router.popular(page: 1)).responseJSON)")
        Alamofire.request(Router.popular(page: 1)).responseJSON { (response) in
            self.handlingPopularResponseData(data: response)
        }
    }
    
    func handlingPopularResponseData (data: DataResponse<Any> ) {
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
        let photos = Photo.getPhotos(from : photosData)
        self.popularImageData = photos
        popularImageSizes = Photo.getSizes(from: popularImageData)
        let laySizes: [CGSize] = popularImageSizes.lay_justify(for: popularCollectionView.frame.size.width - basicIndent , preferredHeight: justPrefferedHeight)
        popularImageSizes = laySizes
        print(data.value ?? "nothing")
        self.searchCollectionView.alpha = 0
        self.searchCollectionView.isHidden = true
        DispatchQueue.main.async() {
            self.popularCollectionView?.reloadData()
        }
    }
    
    func handlingSearchResponseData (data: DataResponse<Any> ) {
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
        let photos = Photo.getPhotos(from : photosData)
        self.searchImageData = photos
        searchImageSizes = Photo.getSizes(from: searchImageData)
        let laySizes: [CGSize] = searchImageSizes.lay_justify(for: searchCollectionView.frame.size.width - basicIndent, preferredHeight: justPrefferedHeight )
        searchImageSizes = laySizes
        print(data.value ?? "nothing")
        self.searchCollectionView.alpha = 1
        self.searchCollectionView.isHidden = false
        DispatchQueue.main.async() {
            self.searchCollectionView?.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {     // frozen for a while
        if let identifier = segue.identifier {
            if identifier == Constants.SegueIdentifier.GallerySegue,
                let gvcvc = segue.destination as? ImageDetailViewController,
                let cell = sender as? ImageCollectionViewCell {
                let indexPath = self.searchCollectionView!.indexPath(for: cell)
                gvcvc.photoGalleryData = popularImageData
                gvcvc.indexCell = indexPath
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if isSearching == false {
            return popularImageData.count
        } else {
            return searchImageData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.searchCollectionView {
            let cellSearch = collectionView.dequeueReusableCell(withReuseIdentifier: "image Cell",
                                                                for: indexPath)
            if let imageCell = cellSearch as? ImageCollectionViewCell {
                guard let gettedUrl = Photo.getUrlFromArray(photosArray: searchImageData, index: indexPath.row) else {
                    return cellSearch
                }
                imageCell.fetchImageForSearch(url: gettedUrl)
                return cellSearch
            }
        }
        
        if collectionView == self.popularCollectionView {
            let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularImage Cell",
                                                                 for: indexPath)
            if let imageCell = cellPopular as? ImageCollectionViewCell {
                guard let gettedUrl = Photo.getUrlFromArray(photosArray: popularImageData, index: indexPath.row) else {
                    return cellPopular
                }
                imageCell.fetchImageForPopular(url: gettedUrl)
                return cellPopular
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSearching == false {
            return popularImageSizes[indexPath.item]
        } else {
            return searchImageSizes[indexPath.item]
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return basicIndent
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return basicIndent/3
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if actualPosition.y > 0 {
            self.view.layoutIfNeeded()                              //If u want animated cells while scrolling comment this
            UIView.animate(withDuration: 0.5,  animations: {
                self.searchConstraint.priority = UILayoutPriority(rawValue: 999)
                self.view.layoutIfNeeded()
            })
        } else if actualPosition.y < 0 {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.searchConstraint.priority = UILayoutPriority(rawValue: 500)
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    /// MARK: auto complete
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !autoCompleteText(in: textField, using: string, suggestions: searchList)
    }
    
    func autoCompleteText(in textField: UITextField, using string: String, suggestions: [String]) -> Bool {
        if !string.isEmpty,
            let selectedTextRange = textField.selectedTextRange, selectedTextRange.end == textField.endOfDocument,
            let prefixRange = textField.textRange(from: textField.beginningOfDocument, to: selectedTextRange.start),
            let text = textField.text(in: prefixRange) {
            let prefix = text + string
            let matches = suggestions.filter { $0.hasPrefix(prefix) }
            if (matches.count > 0) {
                textField.text = matches[0]
                if let start = textField.position(from: textField.beginningOfDocument, offset: prefix.count) {
                    textField.selectedTextRange = textField.textRange(from: start, to: textField.endOfDocument)
                    return true
                }
            }
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
