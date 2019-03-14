//
//  ImageViewController.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//


import UIKit
import Alamofire

class ImageCollectionViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, recentTableCellDelegate {
    
    func didTapClearButton(_ sender: RecentTableViewCell) {
        guard let tappedIndexPath = recentTable.indexPath(for: sender) else {
            return
        }
        recentSearchesList.remove(at: tappedIndexPath.row)
        recentTable.reloadData()
        rebuildTableSize()
        
    }
    
    
    var recentIndexCell: Int?
    var maximumRecentSearches = 10
    var searchActive : Bool = false
    var actualPosition: CGPoint?
    var justPrefferedHeight: CGFloat = 150
    var basicIndent: CGFloat = 2
    var searchList = [String]()
    fileprivate var popularImageData: [Photo] = [Photo]()
    var popularImageSizes: [CGSize] = [CGSize]()
    fileprivate var searchImageData: [Photo] = [Photo]()
    var searchImageSizes: [CGSize] = [CGSize]()
    var recentSearchesList = [String]()
    var isSearching = false
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var searchConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var recentTable: UITableView!
    
    @IBAction func cancelButton(_ sender: DesignableButton) {
        print("will work soon")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCollectionView.alpha = 0
        popularCollectionView.alpha = 1
        recentTable.alpha = 0
        searchConstraint.priority = UILayoutPriority(rawValue: 999)
        searchConstraint.isActive = true
        searchTextField.delegate = self
        definesPresentationContext = true
        recentTable.delegate = self
        recentTable.dataSource = self
        searchTextField.addTarget(self, action: #selector(clickOnTextEventFunc), for: UIControl.Event.touchDown)
        searchTextField.addTarget(self, action: #selector(editingTextEventFunc), for: UIControl.Event.editingChanged)
        recentTable.rowHeight = UITableView.automaticDimension
        recentTable.register(UINib.init(nibName: "RecentTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentCell")
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Flickr",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rebuildTableSize()
        performFlickrPopular()
    }
    override func viewDidLayoutSubviews(){
        rebuildTableSize()
        recentTable.reloadData()
    }
    
    func rebuildTableSize() {
        recentTable.frame = CGRect(x: recentTable.frame.origin.x,
                                   y: recentTable.frame.origin.y,
                                   width: recentTable.frame.size.width,
                                   height: recentTable.contentSize.height)
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
    
    @objc func editingTextEventFunc(textField: UITextField) {
        recentTable_GoHide()
    }
    
    @objc func clickOnTextEventFunc(textField: UITextField) {
        recentTable.reloadData()
        recentTable_ShowMustGoOn()
    }
    
    func recentTable_GoHide() {
        UIView.animate(withDuration: 0.1, animations: {
            self.recentTable.alpha = 0
        })
    }
    
    func recentTable_ShowMustGoOn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.recentTable.alpha = 1
        })
    }
    
    func performTextSearch() {
        recentTable_GoHide()
        searchTextField.resignFirstResponder()
        let searchText = searchTextField.text
        guard let searchingText = searchText else {
            return
        }
        guard !searchingText.isEmpty else {
            displayAlert("Search text cannot be empty")
            return
        }
        updateRecentList(text: searchingText)
        performFlickrSearch(url: searchingText)
        searchCollectionView.alpha = 1
        isSearching = true
        return
    }
    
    func updateRecentList(text: String) {
        
        if recentSearchesList.contains(text) {
            return
        }
        if recentSearchesList.count == maximumRecentSearches {
            _ = recentSearchesList.dropFirst()
        }
        recentSearchesList.append(text)
        recentTable.reloadData()
    }
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performFlickrSearch(url: String) {
        print("\(Alamofire.request(Router.search(text: url, page: 1)).responseJSON)")
        Alamofire.request(Router.search(text: url, page: 1)).responseJSON { (response) in
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
        let laySizes: [CGSize] = popularImageSizes.lay_justify(for: popularCollectionView.frame.size.width - basicIndent ,
                                                               preferredHeight: justPrefferedHeight)
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
        let laySizes: [CGSize] = searchImageSizes.lay_justify(for: searchCollectionView.frame.size.width - basicIndent,
                                                              preferredHeight: justPrefferedHeight )
        searchImageSizes = laySizes
        print(data.value ?? "nothing")
        self.searchCollectionView.alpha = 1
        self.searchCollectionView.isHidden = false
        DispatchQueue.main.async() {
            self.searchCollectionView?.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performTextSearch()
        return true
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
                guard let gettedUrl = searchImageData[indexPath.row].url else {
                    return cellSearch
                }
                imageCell.fetchImage(url: gettedUrl)
                return cellSearch
            }
        }
        
        if collectionView == self.popularCollectionView {
            let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularImage Cell",
                                                                 for: indexPath)
            if let imageCell = cellPopular as? ImageCollectionViewCell {
                guard let url = popularImageData[indexPath.row].url else {
                    return cellPopular
                }
                imageCell.fetchImage(url: url)
                return cellPopular
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSearching == false {
            return popularImageSizes[indexPath.row]
        } else {
            return searchImageSizes[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return basicIndent
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return basicIndent/4
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        recentTable_GoHide()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if recentSearchesList.isEmpty {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath)
        
        if let recentCell = cell as? RecentTableViewCell {
            recentCell.delegate = self
            recentCell.loadDataTable(recentSearchesList, indexPath.row)
            return recentCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recentIndexCell = indexPath.row
        searchTextByRecentList(indexPath.row)
    }
    
    func searchTextByRecentList(_ index: Int) {
        let txt = recentSearchesList[index]
        searchTextField.text = txt
        performTextSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
