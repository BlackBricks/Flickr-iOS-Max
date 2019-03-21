//
//  ImageViewController.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ImageCollectionViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, recentTableCellDelegate {
    
    /// Mark: - variables for searchCollectionView
    var searchImageData: [Photo] = [Photo]()
    var searchImageSizes: [CGSize] = [CGSize]()
    var lastEnteredTextValue: String?
    
    /// Mark: - variables for popularCollectionView
    var popularImageData: [Photo] = [Photo]()
    var popularImageSizes: [CGSize] = [CGSize]()
    
    /// Mark: - variables for tableView history list
    var searchHistoryList = [String]()
    var filteredHistoryList = [String]()
    
    /// Mark: - common
    var isOnSearchCollectionView = false
    var lastContentOffset: CGFloat = 0
    var isSearching = false
    var pageFlickr = 1
    var recentIndexCell: Int?
    var actualPosition: CGPoint?
    var isNotUpdating = true
    let refreshControlForSearch = UIRefreshControl()
    let refreshControlForPopular = UIRefreshControl()
    
    /// Mark: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var subViewForSpinner: UIView!
    @IBOutlet weak var magnifyImage: UIImageView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var searchConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchHistoryTableView: UITableView!
    @IBOutlet weak var cancelButtonOutler: DesignableButton!
    
    /// Mark: - enums
    enum ConstantNumbers {
        static let insetFromPopularCollectionView = 62
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
        setBehaviorTextBar()
        loadFormUserDefaults()
        setXibCellForRecentTableViewCell()
        searchTextField.clearButtonMode = .always
        customPullToUpdate()
    }
    
    func loadFormUserDefaults() {
        guard let defaults = UserDefaults.standard.array(forKey: "historySearch") else {
            return
        }
        if !defaults.isEmpty {
            searchHistoryList = defaults as! [String]
        }
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if searchImageData.isEmpty && popularImageData.isEmpty {
            rebuildTableSize()
            performFlickrPopular()
            return
        }
    }
    
    override func viewDidLayoutSubviews(){
        rebuildTableSize()
        searchHistoryTableView.reloadData()
    }
    
    func customPullToUpdate() {
        let refreshViewSearch = UIView(frame: CGRect(x: 0, y: 62, width: 0, height: 0))
        let refreshViewPopular = UIView(frame: CGRect(x: 0, y: 62, width: 0, height: 0))
        searchCollectionView.addSubview(refreshViewSearch)
        popularCollectionView.addSubview(refreshViewPopular)
        refreshControlForSearch.addTarget(self, action: #selector(refreshCurrentCollectionViewByPullToUpdate), for: .valueChanged)
        refreshControlForPopular.addTarget(self, action: #selector(refreshCurrentCollectionViewByPullToUpdate), for: .valueChanged)
        refreshViewSearch.addSubview(refreshControlForSearch)
        refreshViewPopular.addSubview(refreshControlForPopular)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        if identifier == Constants.SegueIdentifier.detailSegueFromSearchView,
            let gvcvc = segue.destination as? ImageDetailViewController,
            let cell = sender as? ImageCollectionViewCell,
            let indexPath = self.searchCollectionView!.indexPath(for: cell) {
            gvcvc.detailPhotoData = searchImageData
            gvcvc.indexCell = indexPath
        }
        if identifier == Constants.SegueIdentifier.detailSegueFromPopulariew,
            let gvcvc = segue.destination as? ImageDetailViewController,
            let cell = sender as? ImageCollectionViewCell,
            let indexPath = self.popularCollectionView!.indexPath(for: cell) {
            gvcvc.detailPhotoData = popularImageData
            gvcvc.indexCell = indexPath
        }
    }
    
    @IBAction func cancelButton(_ sender: DesignableButton) {
        searchTextField.text = ""
        searchTextField.endEditing(true)
        let hided = isCollectionsViewHidedBoth()
        if hided {
            UIView.animate(withDuration: 0.25,  animations: {
                self.popularCollectionView.alpha = 1
                self.searchHistoryHide()
                if self.isSearching {
                    self.searchCollectionView.alpha = 1
                }
            })
        } else {
            isSearching = false
            UIView.animate(withDuration: 0.25,  animations: {
                self.setAlphasDefault()
            })
        }
         self.view.layoutIfNeeded()
    }
    
    /// Mark: - model func block
    func getFilteredHistory() -> Bool {
        if !isTextFieldEmpty() {
            guard let text = searchTextField.text else {
                return false
            }
            var filtered = searchHistoryList
            filtered = filtered.filter{
                $0.contains(text)
            }
            print("\(searchHistoryList)")
            print("\(filtered)")
            filteredHistoryList = filtered
            rebuildTableSize()
            searchHistoryTableView.reloadData()
            return true
        }
        return false
    }
    
    @objc func editingTextEventFunc(textField: UITextField) {
        if getFilteredHistory() {
            return
        } else {
            startEditingEvent()
        }
    }
    
    @objc func refreshCurrentCollectionViewByPullToUpdate() {
        print("reload")
        pageFlickr = 1
        isNotUpdating = true
        if self.searchCollectionView.alpha == 0 {
            self.performFlickrPopular()
            return
        } else {
            guard let lastValue = self.lastEnteredTextValue else {
                return
            }
            self.performFlickrSearch(url: lastValue)
        }
    }
    
    @objc func clickOnTextEventFunc(textField: UITextField) {
       _ = getFilteredHistory()
        startEditingEvent()
    }
    
    func isTextFieldEmpty() -> Bool {
        guard let textField = searchTextField.text else {
            return false
        }
        if textField.count == 0 || textField == "" {
            return true
        }
        return false
    }
    
    func setDelegates_DataSources() {
        searchTextField.delegate = self
        searchHistoryTableView.delegate = self
        searchHistoryTableView.dataSource = self
    }
    
    func setMagnifyAndCancelButtonAlphasDefault() {
        cancelButtonOutler.alpha = 0
        magnifyImage.alpha = 0.5
    }
    
    func setAlphasDefault() {
        subViewForSpinner.alpha = 0
        searchCollectionView.alpha = 0
        popularCollectionView.alpha = 1
        searchHistoryTableView.alpha = 0
        setMagnifyAndCancelButtonAlphasDefault()
    }
    
    func scrollBack(view: UICollectionView, indexPath: IndexPath) {
        view.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
    func setConstraintMode() {
        searchConstraint.priority = UILayoutPriority(rawValue: 999)
        searchConstraint.isActive = true
    }
    
    @objc func tapImageAction(recognizer: UITapGestureRecognizer) {
        searchTextField.becomeFirstResponder()
        startEditingEvent()
    }
    
    func startEditingEvent() {
        UIView.animate(withDuration: 0.25,  animations: {
            self.searchCollectionView.alpha = 0
            self.popularCollectionView.alpha = 0
            self.magnifyImage.alpha = 1
            self.cancelButtonOutler.alpha = 1
            self.searchHistoryTableView.alpha = 1
            self.view.layoutIfNeeded()
        })
        searchHistoryTableView.reloadData()
        rebuildTableSize()
    }
    
    func isCollectionsViewHidedBoth() -> Bool {
        let check = (searchCollectionView.alpha == 0) && (popularCollectionView.alpha == 0)
        return check
    }
    
    func setBehaviorTextBar() {
        let tapForImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImageAction))
        magnifyImage.isUserInteractionEnabled = true
        magnifyImage.addGestureRecognizer(tapForImageRecognizer)
        searchTextField.addTarget(self, action: #selector(clickOnTextEventFunc), for: UIControl.Event.touchDown)
        searchTextField.addTarget(self, action: #selector(editingTextEventFunc), for: UIControl.Event.editingChanged)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Flickr",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func setXibCellForRecentTableViewCell() {
        searchHistoryTableView.rowHeight = UITableView.automaticDimension
        searchHistoryTableView.register(UINib.init(nibName: "RecentTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentCell")
        searchHistoryTableView.clipsToBounds = false
        searchHistoryTableView.layer.masksToBounds = false
    }
    
    func searchHistoryHide() {
        UIView.animate(withDuration: 0.1, animations: {
            self.searchHistoryTableView.alpha = 0
        })
    }
    
    func hideSearchCollectionView() {
        UIView.animate(withDuration: 0.25,  animations: {
            self.searchCollectionView.alpha = 0
            self.searchCollectionView.isHidden = true
        })
    }
    
    func showSearchCollectionView() {
        UIView.animate(withDuration: 0.25,  animations: {
            self.searchCollectionView.alpha = 1
            self.searchCollectionView.isHidden = false
        })
    }
    
    func searchHistoryShowMustGoOn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchHistoryTableView.alpha = 1
        })
    }
    
    func rebuildTableSize() {
        searchHistoryTableView.frame = CGRect(x: searchHistoryTableView.frame.origin.x,
                                         y: searchHistoryTableView.frame.origin.y,
                                         width: searchHistoryTableView.frame.size.width,
                                         height: CGFloat(searchHistoryTableView.contentSize.height))
    }
    
    func isWeOnSearchCollectionAndShouldUseLastTextValue() -> Bool {
        if isSearching {
            guard let lastValue = self.lastEnteredTextValue else {
                return false
            }
            if lastValue.isEmpty {
                return false
            }
        }
         return true
    }
    
    func performTextSearch() {
        searchHistoryHide()
        searchTextField.resignFirstResponder()
        let searchText = searchTextField.text
        guard var searchingText = searchText else {
            return
        }
        if searchingText.isEmpty {
            if isSearching {
                if isWeOnSearchCollectionAndShouldUseLastTextValue() {
                    guard let lastValue = self.lastEnteredTextValue else {
                        return
                    }
                    searchingText = lastValue
                }
            }
        }
        updateSearchHistory(text: searchingText)
        lastEnteredTextValue = searchingText
        isSearching = true
        performFlickrSearch(url: searchingText)
        return
    }
    
    func updateSearchHistory(text: String) {
        if searchHistoryList.contains(text) {
            return
        }
        searchHistoryList.append(text)
        searchHistoryTableView.reloadData()
        clearUserData()
        UserDefaults.standard.set(searchHistoryList, forKey: "historySearch")
    }
    
    func searchTextByRecentList(_ index: Int) {
        let txt = searchHistoryList[index]
        lastEnteredTextValue = txt
        UIView.animate(withDuration: 0.25,  animations: {
            self.searchHistoryHide()
        })
        searchTextField.text = txt
        pageFlickr = 1
        performTextSearch()
    }
    
    func clearUserData(){
        UserDefaults.standard.removeObject(forKey: "historySearch")
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func performFlickrSearch(url: String) {
        guard isNotUpdating else {
            return
        }
        isNotUpdating = false
        subViewForSpinner.alpha = 1
        let pageCalculated = String(pageFlickr)
        Alamofire.request(Router.search(text: url, page: pageCalculated)).responseJSON { (response) in
            self.handlingSearchResponseData(data: response)
        }
    }
    
    private func performFlickrPopular() {
        guard isNotUpdating else {
            return
        }
        isNotUpdating = false
        subViewForSpinner.alpha = 1
        let pageCalculated = String(pageFlickr)
        Alamofire.request(Router.popular(page: pageCalculated)).responseJSON { (response) in
            self.handlingPopularResponseData(data: response)
        }
    }
    
    func handlingPopularResponseData (data: DataResponse<Any> ) {
        let popularCollectionViewWidth = popularCollectionView.frame.size.width
        subViewForSpinner.alpha = 1
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
        print("\(value)")
        DispatchQueue.global(qos: .background).async {
            let photos = Photo.getPhotos(from : photosData)
            if self.pageFlickr > 1 {
                self.popularImageData += photos
                let newSizes = Photo.getSizes(from: photos)
                let laySizes: [CGSize] = newSizes.lay_justify(for: popularCollectionViewWidth - ConstantNumbers.basicIndent,
                                                              preferredHeight: ConstantNumbers.justPrefferedHeight )
                self.popularImageSizes += laySizes
            } else {
                self.popularImageData = photos
                let newSizes = Photo.getSizes(from: self.popularImageData)
                let laySizes: [CGSize] = newSizes.lay_justify(for: popularCollectionViewWidth - ConstantNumbers.basicIndent,
                                                              preferredHeight: ConstantNumbers.justPrefferedHeight )
                self.popularImageSizes = laySizes
            }
            DispatchQueue.main.async() {
//                self.popularCollectionView.headRefreshControl.endRefreshing()
                self.popularCollectionView?.reloadData()
                self.hideSearchCollectionView()
                self.pageFlickr += 1
                self.subViewForSpinner.alpha = 0
                self.isNotUpdating = true
                if self.popularImageData.count == 0 {
                    self.displayAlert("Oops! it's a TRAP! Flickr service have problem and return 0 values, try to search different values or wait untill Flickr start working!")
                }
            }
        }
    }
    
    func handlingSearchResponseData (data: DataResponse<Any> ) {
        let searchCollectionViewWidth = searchCollectionView.frame.size.width
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
        print("\(value)")
        DispatchQueue.global(qos: .background).async {
            let photos = Photo.getPhotos(from : photosData)
            if self.pageFlickr > 1 {
                self.searchImageData += photos
                let newSizes = Photo.getSizes(from: photos)
                let laySizes: [CGSize] = newSizes.lay_justify(for: searchCollectionViewWidth - ConstantNumbers.basicIndent,
                                                              preferredHeight: ConstantNumbers.justPrefferedHeight )
                self.searchImageSizes += laySizes
            } else {
                self.searchImageData = photos
                self.searchImageSizes = Photo.getSizes(from: self.searchImageData)
                let laySizes: [CGSize] = self.searchImageSizes.lay_justify(for: searchCollectionViewWidth - ConstantNumbers.basicIndent,
                                                                           preferredHeight: ConstantNumbers.justPrefferedHeight )
                self.searchImageSizes = laySizes
            }
            DispatchQueue.main.async() {
                self.refreshControlForSearch.endRefreshing()
//                self.searchCollectionView.headRefreshControl.endRefreshing()
                self.searchCollectionView?.reloadData()
                self.showSearchCollectionView()
                self.subViewForSpinner.alpha = 0
                self.isNotUpdating = true
                self.pageFlickr += 1
            }
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
                guard let maxQualityUrl = Photo.searchBestQualityInFuckingFlickr(from: searchImageData, indexPath: indexPath) else {
                    return cellSearch
                }
                guard let lowQualityUrl = searchImageData[indexPath.row].url_t else {
                    return UICollectionViewCell()
                }
                imageCell.fetchImage(url_Low: lowQualityUrl, url_High: maxQualityUrl)
                return cellSearch
            }
        }
        
        if collectionView == self.popularCollectionView {
            let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularImage Cell",
                                                                 for: indexPath)
            if let imageCell = cellPopular as? ImageCollectionViewCell {
                guard let lowQualityUrl = popularImageData[indexPath.row].url_t else {
                    return cellPopular
                }
                guard let maxQualityUrl = Photo.searchBestQualityInFuckingFlickr(from: popularImageData, indexPath: indexPath) else {
                    return cellPopular
                }
                imageCell.fetchImage(url_Low: lowQualityUrl, url_High: maxQualityUrl)
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
            if indexPath.row >= popularImageData.count - ConstantNumbers.lastCells {
                performFlickrPopular()
                return
            }
        }
        if collectionView == self.searchCollectionView {
            if indexPath.row >= searchImageData.count - ConstantNumbers.lastCells {
                performTextSearch()
                return
            }
        } else {
            return
        }
    }
    
    /// Mark: - UIScrollView delegate implementaion block
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != searchHistoryTableView {
            searchTextField.endEditing(true)
            lastContentOffset = 0
            searchHistoryHide()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != searchHistoryTableView {
            let velocityOfVerticalScroll = scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
            let isEnoughSpaceForSearchTextField = scrollView.contentOffset.y >= ConstantNumbers.offsetForHideSearchText
            let isScrollingDown = velocityOfVerticalScroll < 0
            let isScrollingUp = velocityOfVerticalScroll > 0
            if isScrollingUp {
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.25,  animations: {
                    self.searchConstraint.priority = UILayoutPriority(rawValue: 999)
                    self.view.layoutIfNeeded()
                })
            } else if isScrollingDown && isEnoughSpaceForSearchTextField {
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.25, animations: {
                    self.searchConstraint.priority = UILayoutPriority(rawValue: 500)
                    self.view.layoutIfNeeded()
                })
            } else {
                rebuildTableSize()
            }
        }
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
        if !isTextFieldEmpty() {
            return filteredHistoryList.count
        }
        return searchHistoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath)
        if isTextFieldEmpty() {
            if let recentCell = cell as? RecentTableViewCell {
                recentCell.delegate = self
                recentCell.setText(searchHistoryList[indexPath.row])
                return recentCell
            }
        } else {
            if let recentCell = cell as? RecentTableViewCell {
                recentCell.delegate = self
                recentCell.setText(filteredHistoryList[indexPath.row])
                return recentCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recentIndexCell = indexPath.row
        searchTextByRecentList(indexPath.row)
    }
    
    func didTapClearButton(_ sender: RecentTableViewCell) {
        guard let tappedIndexPath = searchHistoryTableView.indexPath(for: sender) else {
            return
        }
        searchHistoryList.remove(at: tappedIndexPath.row)
        searchHistoryTableView.reloadData()
        UserDefaults.standard.set(searchHistoryList, forKey: "historySearch")
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

