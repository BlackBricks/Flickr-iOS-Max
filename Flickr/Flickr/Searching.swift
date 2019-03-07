
//
//  Searching.swift
//  Flickr
//
//  Created by metoSimka on 06/03/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//


class ParentVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchField: UITextField!
    ....
    
    override func viewDidLoad() {
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControlEvents.editingChanged)
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        searchViewController = storyboard.instantiateViewController(withIdentifier: "searchView")
        let vc = searchViewController!
        addChildViewController(vc)
        vc.view.frame = mainView.bounds
        mainView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        
        /** MARK: In order for the string to be set, the Notification has to be called AFTER the search view is presented **/
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: handleTextChangeNotification), object: nil, userInfo: ["text":searchField.text!])
        
        return true
}
