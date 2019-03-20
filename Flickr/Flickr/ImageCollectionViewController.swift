//
//  ImageViewController.swift
//  Flickr
//
//  Created by metoSimka on 25/02/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//


import UIKit
import Alamofire
import KafkaRefresh


class ImageCollectionViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, recentTableCellDelegate {
    
    /// Mark: - variables for searchCollectionView
    var searchImageData: [Photo] = [Photo]()
    var searchImageSizes: [CGSize] = [CGSize]()
    var lastEnteredTextValue: String?
    var originSizesBySearch: [CGSize] = [CGSize]()
    
    /// Mark: - variables for popularCollectionView
    var popularImageData: [Photo] = [Photo]()
    var popularImageSizes: [CGSize] = [CGSize]()
    var originSizesByPopular: [CGSize] = [CGSize]()
    
    /// Mark: - common
    var weOnPopularCollectionView = true
    var lastContentOffset: CGFloat = 0
    var isSearching = false
    var pageFlickr = 1
    var recentIndexCell: Int?
    var actualPosition: CGPoint?
    var searchHistoryList = [String]()
    var isNotUpdating = true
    var insets = UIEdgeInsets(top: 150, left: 0, bottom: 0, right: 0)
    
    /// Mark: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var subviewForTapEvent: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var subViewForSpinner: UIView!
    @IBOutlet weak var magnifyImage: UIImageView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    
    @IBOutlet weak var searchConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchHistoryView: UITableView!
    @IBOutlet weak var cancelButtonOutler: DesignableButton!
    
    
    
    /// Mark: - enums
    enum ConstantNumbers {
        static let perPage = 100
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
            let perPages = "100"
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
        //        searchCollectionView.footRefreshControl.autoRefreshOnFoot = true
        //        popularCollectionView.footRefreshControl.autoRefreshOnFoot = true
        setDelegates_DataSources()
        setAlphasDefault()
        setConstraintMode()
        setBehaviorTextBar()
        setXibCellForRecentTableViewCell()
        searchTextField.clearButtonMode = .always
        //        addPullRefresh()
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
        searchHistoryView.reloadData()
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
        isSearching = false
        showCurrentCollectionView()
        weOnPopularCollectionView = true
        searchTextField.text = ""
        searchTextField.endEditing(true)
        UIView.animate(withDuration: 0.25,  animations: {
            self.setAlphasDefault()
            self.view.layoutIfNeeded()
        })
    }
    
    /// Mark: - model func block
    @objc func editingTextEventFunc(textField: UITextField) {
        searchHistoryHide()
    }
    
    @objc func refreshCurrentCollectionViewByPullToUpdate() {
        print("reload")
        pageFlickr = 1
        isNotUpdating = true
        if self.searchCollectionView.alpha == 0 {
            self.performFlickrPopular()
        } else {
            guard let lastValue = self.lastEnteredTextValue else {
                return
            }
            self.performFlickrSearch(url: lastValue)
        }
    }
    
    @objc func clickOnTextEventFunc(textField: UITextField) {
        startEditingEvent()
    }
    
    func setDelegates_DataSources() {
        searchTextField.delegate = self
        searchHistoryView.delegate = self
        searchHistoryView.dataSource = self
    }
    
    func setMagnifyAndCancelButtonAlphasDefault() {
        cancelButtonOutler.alpha = 0
        magnifyImage.alpha = 0.5
    }
    
    func showCurrentCollectionView() {
        self.subviewForTapEvent.alpha = 0
        UIView.animate(withDuration: 0.25,  animations: {
            if !self.weOnPopularCollectionView {
                self.searchCollectionView.alpha = 1
            }
            self.popularCollectionView.alpha = 1
        })
    }
    
    func setAlphasDefault() {
        subviewForTapEvent.alpha = 0
        subViewForSpinner.alpha = 0
        searchCollectionView.alpha = 0
        popularCollectionView.alpha = 1
        searchHistoryView.alpha = 0
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
    
    @objc func tapSuperViewAction(recognizer: UITapGestureRecognizer) {
        showCurrentCollectionView()
        searchTextField.endEditing(true)
        searchHistoryHide()
    }
    
    func startEditingEvent() {
        UIView.animate(withDuration: 0.25,  animations: {
            self.subviewForTapEvent.alpha = 1
            self.searchCollectionView.alpha = 0
            self.popularCollectionView.alpha = 0
            self.magnifyImage.alpha = 1
            self.cancelButtonOutler.alpha = 1
            self.view.layoutIfNeeded()
        })
        searchHistoryView.reloadData()
        searchHistoryShowMustGoOn()
    }
    
    func setBehaviorTextBar() {
        let tapForImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImageAction))
        magnifyImage.isUserInteractionEnabled = true
        magnifyImage.addGestureRecognizer(tapForImageRecognizer)
        let tapForSuperviewRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapSuperViewAction))
        subviewForTapEvent.isUserInteractionEnabled = true
        subviewForTapEvent.addGestureRecognizer(tapForSuperviewRecognizer)
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
    
    func addPullRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCurrentCollectionViewByPullToUpdate), for: .valueChanged)
        searchCollectionView.refreshControl = refreshControl
        DispatchQueue.main.async {
            self.searchCollectionView.refreshControl?.endRefreshing()
        }
    }
    
    func searchHistoryHide() {
        UIView.animate(withDuration: 0.1, animations: {
            self.searchHistoryView.alpha = 0
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
            return
        }
        updateSearchHistory(text: searchingText)
        performFlickrSearch(url: searchingText)
        lastEnteredTextValue = searchingText
        isSearching = true
        return
    }
    
    func updateSearchHistory(text: String) {
        if searchHistoryList.contains(text) {
            return
        }
        searchHistoryList.append(text)
        searchHistoryView.reloadData()
        clearUserData()
        UserDefaults.standard.set(searchHistoryList, forKey: "historySearch")
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
                let newSizes = Photo.getSizes(from: self.popularImageData)
                let laySizes: [CGSize] = newSizes.lay_justify(for: popularCollectionViewWidth - ConstantNumbers.basicIndent,
                                                              preferredHeight: ConstantNumbers.justPrefferedHeight )
                self.popularImageSizes = laySizes
            } else {
                self.popularImageData = photos
                let newSizes = Photo.getSizes(from: self.popularImageData)
                let laySizes: [CGSize] = newSizes.lay_justify(for: popularCollectionViewWidth - ConstantNumbers.basicIndent,
                                                              preferredHeight: ConstantNumbers.justPrefferedHeight )
                self.popularImageSizes = laySizes
            }
            DispatchQueue.main.async() {
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
            } else {
                self.searchImageData = photos
            }
            self.searchImageSizes = Photo.getSizes(from: self.searchImageData)
            let laySizes: [CGSize] = self.searchImageSizes.lay_justify(for: searchCollectionViewWidth - ConstantNumbers.basicIndent,
                                                                       preferredHeight: ConstantNumbers.justPrefferedHeight )
            self.searchImageSizes = laySizes
            DispatchQueue.main.async() {
                self.searchCollectionView?.reloadData()
                self.showSearchCollectionView()
                self.subViewForSpinner.alpha = 0
                self.isNotUpdating = true
                self.pageFlickr += 1
            }
        }
    }
    
    func performGetSizeRequest() {
        let idArray = Photo.getID(from: searchImageData)
        guard idArray.count == searchImageData.count else {
            return
        }
    }
    
    /// Mark: - UITextField delegate implementaion block
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        showCurrentCollectionView()
        weOnPopularCollectionView = false
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
            if indexPath.row >= popularImageData.count - ConstantNumbers.lastCells {
                performFlickrPopular()
            }
        }
        if collectionView == self.searchCollectionView {
            if indexPath.row >= searchImageData.count - ConstantNumbers.lastCells {
                performTextSearch()
            }
        } else {
            return
        }
    }
    
    /// Mark: - UIScrollView delegate implementaion block
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != searchHistoryView {
            searchTextField.endEditing(true)
            lastContentOffset = 0
            searchHistoryHide()
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != searchHistoryView {
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
                return
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
        weOnPopularCollectionView = false
        searchTextByRecentList(indexPath.row)
    }
    
    func searchTextByRecentList(_ index: Int) {
        let txt = searchHistoryList[index]
        lastEnteredTextValue = txt
        searchHistoryHide()
        searchTextField.text = txt
        
    }
    
    func didTapClearButton(_ sender: RecentTableViewCell) {
        guard let tappedIndexPath = searchHistoryView.indexPath(for: sender) else {
            return
        }
        searchHistoryList.remove(at: tappedIndexPath.row)
        searchHistoryView.reloadData()
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
