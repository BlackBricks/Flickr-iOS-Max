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
    var defaultHistoryList = [String]()
    var filteredHistoryList = [String]()
    var isUserInTextFieldInteraction = false
    
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
    @IBOutlet weak var heightConstraintTableView: NSLayoutConstraint!
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var containerSearchTextFieldView: UIView!
    @IBOutlet weak var subViewForSpinner: UIView!
    @IBOutlet weak var imageMagnify: UIImageView!
    @IBOutlet weak var collectionViewSearch: UICollectionView!
    @IBOutlet weak var collectionViewPopular: UICollectionView!
    @IBOutlet weak var constraintForHideTextField: NSLayoutConstraint!
    @IBOutlet weak var tableViewHistorySearch: UITableView!
    @IBOutlet weak var buttonCancel: DesignableButton!
    
    /// Mark: - enums
    enum ConstantNumbers {
        static let valueForBottomConstrainTableView: CGFloat = 400
        static let standartTimeForAnimation = 0.25
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
        textFieldSearch.clearButtonMode = .always
        customPullToUpdate()
    }
    
    func loadFormUserDefaults() {
        guard let defaults = UserDefaults.standard.array(forKey: "historySearch") else {
            return
        }
        if !defaults.isEmpty {
            defaultHistoryList = defaults as! [String]
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
    }
    
    func customPullToUpdate() {
        let refreshViewSearch = UIView(frame: CGRect(x: 0, y: 62, width: 0, height: 0))
        let refreshViewPopular = UIView(frame: CGRect(x: 0, y: 62, width: 0, height: 0))
        collectionViewSearch.addSubview(refreshViewSearch)
        collectionViewPopular.addSubview(refreshViewPopular)
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
            let indexPath = self.collectionViewSearch?.indexPath(for: cell) {
            gvcvc.detailPhotoData = searchImageData
            gvcvc.indexCell = indexPath
        }
        if identifier == Constants.SegueIdentifier.detailSegueFromPopulariew,
            let gvcvc = segue.destination as? ImageDetailViewController,
            let cell = sender as? ImageCollectionViewCell,
            let indexPath = self.collectionViewPopular?.indexPath(for: cell) {
            gvcvc.detailPhotoData = popularImageData
            gvcvc.indexCell = indexPath
        }
    }
    
    @IBAction func cancelButton(_ sender: DesignableButton) {
        textFieldSearch.text = ""
        textFieldSearch.endEditing(true)
        UIView.animate(withDuration: ConstantNumbers.standartTimeForAnimation,  animations: {
            if self.isUserInTextFieldInteraction {
                self.collectionViewPopular.alpha = 1
                self.searchHistoryHide()
                if self.isSearching {
                    self.collectionViewSearch.alpha = 1
                }
            } else {
                self.isSearching = false
                self.setAlphasDefault()
            }
        })
        isUserInTextFieldInteraction = false
        self.view.layoutIfNeeded()
    }
    
    func filtergHistory() {
        guard let text = textFieldSearch.text else {
            return
        }
        if text.isEmpty {
            filteredHistoryList = defaultHistoryList
        } else {
            var filtered = defaultHistoryList
            filtered = filtered.filter {
                $0.contains(text)
            }
            filteredHistoryList = filtered
        }
    }
    
    /// Mark: - model func block
    func updateHistoryList() {
        filtergHistory()
        rebuildTableSize()
    }
    
    @objc func editingTextEventFunc(textField: UITextField) {
        updateHistoryList()
        startEditingState()
    }
    
    @objc func refreshCurrentCollectionViewByPullToUpdate() {
        print("reload")
        pageFlickr = 1
        isNotUpdating = true
        if self.collectionViewSearch.alpha == 0 {
            self.performFlickrPopular()
            return
        } else {
            guard let lastValue = self.lastEnteredTextValue else {
                return
            }
            self.performFlickrSearch(url: lastValue)
        }
    }
    
    func initUpdateHistoryTableView() {
        updateHistoryList()
        startEditingState()
    }
    
    @objc func clickOnTextEventFunc(textField: UITextField) {
        initUpdateHistoryTableView()
    }
    
    func setDelegates_DataSources() {
        textFieldSearch.delegate = self
        tableViewHistorySearch.delegate = self
        tableViewHistorySearch.dataSource = self
    }
    
    func setMagnifyAndCancelButtonAlphasDefault() {
        buttonCancel.alpha = 0
        imageMagnify.alpha = 0.5
    }
    
    func setAlphasDefault() {
        subViewForSpinner.alpha = 0
        collectionViewSearch.alpha = 0
        collectionViewPopular.alpha = 1
        tableViewHistorySearch.alpha = 0
        setMagnifyAndCancelButtonAlphasDefault()
    }
    
    func scrollBack(view: UICollectionView, indexPath: IndexPath) {
        view.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
    func setConstraintMode() {
        tableViewHistorySearch.clipsToBounds = true
        constraintForHideTextField.priority = UILayoutPriority(rawValue: 999)
        heightConstraintTableView.constant = 0
        heightConstraintTableView.isActive = true
        constraintForHideTextField.isActive = true
    }
    
    
    @objc func tapImageAction(recognizer: UITapGestureRecognizer) {
        textFieldSearch.becomeFirstResponder()
        startEditingState()
    }
    
    func hideAllCollectionViews() {
        self.collectionViewSearch.alpha = 0
        self.collectionViewPopular.alpha = 0
    }
    
    func showEditingStyle() {
        self.imageMagnify.alpha = 1
        self.buttonCancel.alpha = 1
        self.tableViewHistorySearch.alpha = 1
    }
    
    func startEditingState() {
        isUserInTextFieldInteraction = true
        UIView.animate(withDuration: ConstantNumbers.standartTimeForAnimation,  animations: {
            self.hideAllCollectionViews()
            self.showEditingStyle()
        })
        rebuildTableSize()
    }
    func isCollectionsViewHidedBoth() -> Bool {
        if isUserInTextFieldInteraction {
            return true
        }
        return false
    }
    
    func setBehaviorTextBar() {
        let tapForImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImageAction))
        imageMagnify.isUserInteractionEnabled = true
        imageMagnify.addGestureRecognizer(tapForImageRecognizer)
        textFieldSearch.addTarget(self, action: #selector(clickOnTextEventFunc), for: UIControl.Event.touchDown)
        textFieldSearch.addTarget(self, action: #selector(editingTextEventFunc), for: UIControl.Event.editingChanged)
        textFieldSearch.attributedPlaceholder = NSAttributedString(string: "Search Flickr",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func setXibCellForRecentTableViewCell() {
        tableViewHistorySearch.rowHeight = UITableView.automaticDimension
        tableViewHistorySearch.register(UINib.init(nibName: "RecentTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentCell")
        tableViewHistorySearch.clipsToBounds = false
        tableViewHistorySearch.layer.masksToBounds = false
    }
    
    func searchHistoryHide() {
        UIView.animate(withDuration: 0.1, animations: {
            self.tableViewHistorySearch.alpha = 0
        })
    }
    
    func hideSearchCollectionView() {
        UIView.animate(withDuration: ConstantNumbers.standartTimeForAnimation,  animations: {
            self.collectionViewSearch.alpha = 0
            self.collectionViewSearch.isHidden = true
        })
    }
    
    func showSearchCollectionView() {
        UIView.animate(withDuration: ConstantNumbers.standartTimeForAnimation,  animations: {
            self.collectionViewSearch.alpha = 1
            self.collectionViewSearch.isHidden = false
        })
    }
    
    func searchHistoryShowMustGoOn() {
        UIView.animate(withDuration: ConstantNumbers.standartTimeForAnimation, animations: {
            self.tableViewHistorySearch.alpha = 1
        })
    }
    
    func rebuildTableSize() {
        tableViewHistorySearch.reloadData()
        heightConstraintTableView.constant = tableViewHistorySearch.contentSize.height
        tableViewHistorySearch.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func performTextSearch() {
        searchHistoryHide()
        isUserInTextFieldInteraction = false
        textFieldSearch.resignFirstResponder()
        guard let searchingText = lastEnteredTextValue else {
            return
        }
        updateSearchHistory(text: searchingText)
        lastEnteredTextValue = searchingText
        isSearching = true
        performFlickrSearch(url: searchingText)
        return
    }
    
    func updateSearchHistory(text: String) {
        if defaultHistoryList.contains(text) {
            return
        }
        defaultHistoryList.append(text)
        tableViewHistorySearch.reloadData()
        clearUserData()
        UserDefaults.standard.set(defaultHistoryList, forKey: "historySearch")
    }
    
    func searchTextByRecentList(_ index: Int) {
        let txt = filteredHistoryList[index]
        lastEnteredTextValue = txt
        UIView.animate(withDuration: ConstantNumbers.standartTimeForAnimation,  animations: {
            self.searchHistoryHide()
        })
        textFieldSearch.text = lastEnteredTextValue
        pageFlickr = 1
        performTextSearch()
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "historySearch")
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func finishCalculcateResponseData() {
        self.pageFlickr += 1
        self.subViewForSpinner.alpha = 0
        self.isNotUpdating = true
    }
    
    func transformDataResponseIntoDict(from data: DataResponse<Any>) -> [[String : AnyObject]] {
        guard data.result.isSuccess else {
            self.displayAlert("Error get data \(String(describing: data.result.error))")
            return [[String : AnyObject]]()
        }
        guard
            let value = data.result.value as? [String: AnyObject],
            let dict = value["photos"] as? [String: AnyObject],
            let photosData = dict["photo"] as? [[String: AnyObject]]
            else {
                print("Error parse data")
                return [[String : AnyObject]]()
        }
        //        print("\(value)")
        return photosData
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
        let pageCalculated = String(pageFlickr)
        Alamofire.request(Router.popular(page: pageCalculated)).responseJSON { (response) in
            self.handlingPopularResponseData(data: response)
        }
    }
    
    func handlingPopularResponseData (data: DataResponse<Any> ) {
        subViewForSpinner.alpha = 1
        let photosData = transformDataResponseIntoDict(from: data)
        let popularCollectionWidth = self.collectionViewPopular.frame.size.width
        DispatchQueue.global(qos: .background).async {
            let newData = Photo.getPhotos(from : photosData)
            let laySizes = self.treatmentNewData(popularCollectionWidth, newData)
            if self.pageFlickr == 1 {
                self.popularImageData = newData
                self.popularImageSizes = laySizes
            } else {
                self.popularImageData += newData
                self.popularImageSizes += laySizes
            }
            DispatchQueue.main.async {
                self.finishCalculcateResponseData()
                self.refreshControlForPopular.endRefreshing()
                self.collectionViewPopular?.reloadData()
                self.hideSearchCollectionView()
            }
        }
    }
    
    func treatmentNewData(_ collectionWidth : CGFloat,_ photosData: [Photo] ) -> [CGSize] {
        let newSizes = Photo.getSizes(from: photosData)
        let laySizes: [CGSize] = newSizes.lay_justify(for: collectionWidth - ConstantNumbers.basicIndent,
                                                      preferredHeight: ConstantNumbers.justPrefferedHeight )
        return laySizes
    }
    
    func handlingSearchResponseData (data: DataResponse<Any> ) {
        subViewForSpinner.alpha = 1
        let photosData = transformDataResponseIntoDict(from: data)
        let searchCollectionWidth = self.collectionViewSearch.frame.size.width
        DispatchQueue.global(qos: .background).async {
            let newData = Photo.getPhotos(from : photosData)
            let laySizes = self.treatmentNewData(searchCollectionWidth, newData)
            if self.pageFlickr == 1 {
                self.searchImageData = newData
                self.searchImageSizes = laySizes
            } else {
                self.searchImageData += newData
                self.searchImageSizes += laySizes
            }
            DispatchQueue.main.async {
                self.finishCalculcateResponseData()
                self.refreshControlForSearch.endRefreshing()
                self.collectionViewSearch?.reloadData()
                self.showSearchCollectionView()
            }
        }
    }
    
    /// Mark: - UITextField delegate implementaion block
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        lastEnteredTextValue = textFieldSearch.text
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
        if collectionView == self.collectionViewSearch {
            let cellSearch = collectionView.dequeueReusableCell(withReuseIdentifier: "image Cell",
                                                                for: indexPath)
            if let imageCell = cellSearch as? ImageCollectionViewCell {
                
                guard let lowQualityUrl = searchImageData[indexPath.row].url_t else {
                    return UICollectionViewCell()
                }
                guard let maxQualityUrl = searchImageData[indexPath.row].url_best else {
                    return UICollectionViewCell()
                }
                imageCell.fetchImage(url_Low: lowQualityUrl, url_High: maxQualityUrl)
                return cellSearch
            }
        }
        
        if collectionView == self.collectionViewPopular {
            let cellPopular = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularImage Cell",
                                                                 for: indexPath)
            if let imageCell = cellPopular as? ImageCollectionViewCell {
                
                guard let lowQualityUrl = popularImageData[indexPath.row].url_t else {
                    return cellPopular
                }
                guard let maxQualityUrl = popularImageData[indexPath.row].url_best else {
                    return UICollectionViewCell()
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
        if collectionView == self.collectionViewPopular {
            if indexPath.row >= popularImageData.count - ConstantNumbers.lastCells {
                performFlickrPopular()
                return
            }
        }
        if collectionView == self.collectionViewSearch {
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
        if scrollView != tableViewHistorySearch {
            textFieldSearch.endEditing(true)
            lastContentOffset = 0
            searchHistoryHide()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != tableViewHistorySearch {
            let velocityOfVerticalScroll = scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
            let isEnoughSpaceForSearchTextField = scrollView.contentOffset.y >= ConstantNumbers.offsetForHideSearchText
            let isScrollingDown = velocityOfVerticalScroll < 0
            let isScrollingUp = velocityOfVerticalScroll > 0
            UIView.animate(withDuration: ConstantNumbers.standartTimeForAnimation,  animations: {
                if isScrollingUp {
                    self.view.layoutIfNeeded()
                    self.constraintForHideTextField.priority = UILayoutPriority(rawValue: 999)
                    self.view.layoutIfNeeded()
                } else if isScrollingDown && isEnoughSpaceForSearchTextField {
                    self.view.layoutIfNeeded()
                    self.constraintForHideTextField.priority = UILayoutPriority(rawValue: 500)
                    self.view.layoutIfNeeded()
                }
            })
        } else {
            rebuildTableSize()
        }
    }
    
    /// Mark: - UITableView delegate implementaion block
    func numberOfSections(in tableView: UITableView) -> Int {
        if defaultHistoryList.isEmpty {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath)
        if let recentCell = cell as? RecentTableViewCell {
            recentCell.delegate = self
            recentCell.setText(filteredHistoryList[indexPath.row])
            return recentCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recentIndexCell = indexPath.row
        searchTextByRecentList(indexPath.row)
    }
    
    func didTapClearButton(_ sender: RecentTableViewCell) {
        guard let tappedIndexPath = tableViewHistorySearch.indexPath(for: sender) else {
            return
        }
        let removedValue = filteredHistoryList.remove(at: tappedIndexPath.row)
        defaultHistoryList = defaultHistoryList.filter { $0 != removedValue }
        UserDefaults.standard.set(defaultHistoryList, forKey: "historySearch")
        initUpdateHistoryTableView()
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

