//
//  TableViewCell.swift
//  Flickr
//
//  Created by metoSimka on 12/03/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    var dataRecentSearches = [String]()
    var index = Int()
    weak var delegate: recentTableCellDelegate?
    @IBOutlet weak var recentText: UILabel!
    @IBAction func clearButton(_ sender: UIButton) {
        delegate?.didTapClearButton(self)
    }
    
    func setText(_ array: [String]) {
        recentText.text = array[index]
    }
}

protocol recentTableCellDelegate : class {
    func didTapClearButton(_ sender: RecentTableViewCell)
}

