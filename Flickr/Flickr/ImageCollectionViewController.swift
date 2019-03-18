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
    
    /// Mark: - variables for searchCollectionView
    var searchImageData: [Photo] = [Photo]()
    var searchImageSizes: [CGSize] = [CGSize]()
    
    /// Mark: - variables for popularCollectionView
    var popularImageData: [Photo] = [Photo]()
    var popularImageSizes: [CGSize] = [CGSize]()
    
    /// Mark: - common
    var lastContentOffset: CGFloat = 0
    var isSearching = false
    var pageFlickr = 1
    var recentIndexCell: Int?
    var actualPosition: CGPoint?
    var searchHistoryList = [String]()
    
    /// Mark: - Outlets
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchConstraint: NSLayoutConstraint!
    @IBOutlet weak var subViewForSpinner: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchHistoryView: UITableView!
   
    /// Mark: - enums
    enum ConstantNumbers {
        static let perPage = 50
        static let xibHeight = 50
        static let lastCells = 15
        static let justPrefferedHeight: CGFloat = 180
        static let basicIndent: CGFloat = 2
        static let offsetForHideSearchText: CGFloat = 55
    }
    
    enum Router: URLRequestConvertible {
        case search(text: String, page: String)
        case popular(page: String)
        static let baseURLString = Constants.FlickrAPI.baseUrl

        // MARK: URLRequestConvertible
        func asURLRequest() throws -> URLRequest {
            let perPages = "50"
            let result: (path: String, parameters: Parameters) = {
                switch self {
                case let .search(text, page) :
                    var searchParams = Constants.searchParams
                    searchParams["text"] = text
                    searchParams["page"] = page
                    return (Constants.FlickrAPI.path, searchParams)
                case let .popular(page):
                    var popularParams = Constants.popularParams
                    popularParams["page"] = page
                    popularParams["per_page"] = perPages
                    return  (Constants.FlickrAPI.path, popularParams)
                }
            }()
            let url = try Router.baseURLString.asURL()
            let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
            return try URLEncoding.default.encode(urlRequest, with: result.parameters)
        }
    }
    
    /// Mark: - override func block
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setDelegates_DataSources()
        setAlphasDefault()
        setConstraintMode()
        setBehaviorTextField()
        setXibCellForRecentTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rebuildTableSize()
        performFlickrPopular()
        
    }
    
    override func viewDidLayoutSubviews(){
        rebuildTableSize()
        searchHistoryView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        guard identifier == Constants.SegueIdentifier.GallerySegue,
            let gvcvc = segue.destination as? ImageDetailViewController,
            let cell = sender as? ImageCollectionViewCell else {
                return
        }
        let indexPath = self.searchCollectionView!.indexPath(for: cell)
        gvcvc.photoGalleryData = popularImageData
        gvcvc.indexCell = indexPath
    }
    
    @IBAction func cancelButton(_ sender: DesignableButton) {
         UIView.animate(withDuration: 0.25,  animations: {
            self.setAlphasDefault()
           self.view.layoutIfNeeded()
        })
        
    }
    
    /// Mark: - model func block
    @objc func editingTextEventFunc(textField: UITextField) {
        searchHistoryHide()
    }
    
    @objc func clickOnTextEventFunc(textField: UITextField) {
        searchHistoryView.reloadData()
        searchHistoryShowMustGoOn()
    }
    
    func setDelegates_DataSources() {
        searchTextField.delegate = self
        searchHistoryView.delegate = self
        searchHistoryView.dataSource = self
    }
    
    func setAlphasDefault() {
        subViewForSpinner.alpha = 0
        searchCollectionView.alpha = 0
        popularCollectionView.alpha = 1
        searchHistoryView.alpha = 0
    }
    
    func setConstraintMode() {
        searchConstraint.priority = UILayoutPriority(rawValue: 999)
        searchConstraint.isActive = true
    }
    
    func setBehaviorTextField() {
        searchTextField.addTarget(self, action: #selector(clickOnTextEventFunc), for: UIControl.Event.touchDown)
        searchTextField.addTarget(self, action: #selector(editingTextEventFunc), for: UIControl.Event.editingChanged)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Flickr",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func setXibCellForRecentTableViewCell() {
        searchHistoryView.rowHeight = UITableView.automaticDimension
        searchHistoryView.register(UINib.init(nibName: "RecentTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentCell")
        searchHistoryView.clipsToBounds = false
        searchHistoryView.layer.masksToBounds = false
    }
    
    
    func searchHistoryHide() {
        UIView.animate(withDuration: 0.1, animations: {
            self.searchHistoryView.alpha = 0
        })
    }
    
    func searchHistoryShowMustGoOn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchHistoryView.alpha = 1
        })
    }
    
    func rebuildTableSize() {
        searchHistoryView.frame = CGRect(x: searchHistoryView.frame.origin.x,
                                         y: searchHistoryView.frame.origin.y,
                                         width: searchHistoryView.frame.size.width,
                                         height: CGFloat(searchHistoryView.contentSize.height))
    }
    
    func performTextSearch() {
        searchHistoryHide()
        searchTextField.resignFirstResponder()
        let searchText = searchTextField.text
        guard let searchingText = searchText else {
            return
        }
        guard !searchingText.isEmpty else {
            displayAlert("Search text cannot be empty")
            return
        }
        updateSearchHistory(text: searchingText)
        performFlickrSearch(url: searchingText)
        searchCollectionView.alpha = 1
        isSearching = true
        return
    }
    
    func updateSearchHistory(text: String) {
        if searchHistoryList.contains(text) {
            return
        }
        searchHistoryList.append(text)
        searchHistoryView.reloadData()
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performFlickrSearch(url: String) {
        let pageCalculated = String(pageFlickr)
        Alamofire.request(Router.search(text: url, page: pageCalculated)).responseJSON { (response) in
            self.handlingSearchResponseData(data: response)
        }
    }
    
    private func performFlickrPopular() {
        let pageCalculated = String(pageFlickr)
        Alamofire.request(Router.popular(page: pageCalculated)).responseJSON { (response) in
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
        if pageFlickr > 1 {
            popularImageData += photos
            let newSizes = Photo.getSizes(from: popularImageData)
            let laySizes: [CGSize] = newSizes.lay_justify(for: popularCollectionView.frame.size.width - ConstantNumbers.basicIndent,
                                                          preferredHeight: ConstantNumbers.justPrefferedHeight )
            self.popularImageSizes = laySizes
        } else {
            self.popularImageData = photos
            let newSizes = Photo.getSizes(from: popularImageData)
            let laySizes: [CGSize] = newSizes.lay_justify(for: popularCollectionView.frame.size.width - ConstantNumbers.basicIndent,
                                                          preferredHeight: ConstantNumbers.justPrefferedHeight )
            self.popularImageSizes = laySizes
        }

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
        if pageFlickr > 1 {
            searchImageData += photos
        } else {
            self.searchImageData = photos
        }
        searchImageSizes = Photo.getSizes(from: searchImageData)
        let laySizes: [CGSize] = searchImageSizes.lay_justify(for: searchCollectionView.frame.size.width - ConstantNumbers.basicIndent,
                                                              preferredHeight: ConstantNumbers.justPrefferedHeight )
        searchImageSizes = laySizes
        self.searchCollectionView.alpha = 1
        self.searchCollectionView.isHidden = false
        DispatchQueue.main.async() {
            self.searchCollectionView?.reloadData()
        }
    }
    
    /// Mark: - UITextField delegate implementaion block
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pageFlickr = 1
        performTextSearch()
        return true
    }
    
    /// Mark: - UICollectionView delegate implementaion block
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
        return ConstantNumbers.basicIndent
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ConstantNumbers.basicIndent/4
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.popularCollectionView {
            if indexPath.row == (pageFlickr * ConstantNumbers.perPage) - ConstantNumbers.lastCells {
                subViewForSpinner.alpha = 1
                pageFlickr += 1
                performFlickrPopular()
                DispatchQueue.main.async() {
                    self.subViewForSpinner.alpha = 0
                }
               
            }
        }
        if collectionView == self.searchCollectionView {
            if indexPath.row == (pageFlickr * ConstantNumbers.perPage) - ConstantNumbers.lastCells {
                subViewForSpinner.alpha = 1
                pageFlickr += 1
                performTextSearch()
                DispatchQueue.main.async() {
                    self.subViewForSpinner.alpha = 0
                }
            }
        }
    }
    
    /// Mark: - UIScrollView delegate implementaion block
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = 0
        searchHistoryHide()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if (actualPosition.y > 0 || ((actualPosition.y > lastContentOffset && actualPosition.y != 0.0)))
            && !(actualPosition.y < lastContentOffset && actualPosition.y != 0.0) {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25,  animations: {
                self.searchConstraint.priority = UILayoutPriority(rawValue: 999)
                self.view.layoutIfNeeded()
                //                self.searchContainerView.layoutIfNeeded()     //This is solution dont work so i dont know that to do
                ()
            })
        } else if (actualPosition.y < 0 && scrollView.contentOffset.y >= ConstantNumbers.offsetForHideSearchText)
            || (actualPosition.y < lastContentOffset && actualPosition.y != 0.0 && scrollView.contentOffset.y >= ConstantNumbers.offsetForHideSearchText )   {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.25, animations: {
                self.searchConstraint.priority = UILayoutPriority(rawValue: 500)
                self.view.layoutIfNeeded()
                //                self.searchContainerView.layoutIfNeeded()
                ()
            })
        }
        lastContentOffset = actualPosition.y
    }
    
    /// Mark: - UITableView delegate implementaion block
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchHistoryList.isEmpty {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath)
        
        if let recentCell = cell as? RecentTableViewCell {
            recentCell.delegate = self
            recentCell.index = indexPath.row
            recentCell.setText(searchHistoryList)
            return recentCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recentIndexCell = indexPath.row
        searchTextByRecentList(indexPath.row)
    }
    
    func searchTextByRecentList(_ index: Int) {
        let txt = searchHistoryList[index]
        searchTextField.text = txt
        performTextSearch()
    }
    
    func didTapClearButton(_ sender: RecentTableViewCell) {
        guard let tappedIndexPath = searchHistoryView.indexPath(for: sender) else {
            return
        }
        searchHistoryList.remove(at: tappedIndexPath.row)
        searchHistoryView.reloadData()
        rebuildTableSize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
extension UIViewController {
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = style == .lightContent ? UIColor.black : .white
            statusBar.setValue(style == .lightContent ? UIColor.white : .black, forKey: "foregroundColor")
        }
    }
}
