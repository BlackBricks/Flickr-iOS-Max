//
//  TableViewCell.swift
//  Flickr
//
//  Created by metoSimka on 12/03/2019.
//  Copyright © 2019 metoSimka. All rights reserved.
//

import UIKit

protocol recentTableCellDelegate : class {
    func didTapClearButton(_ sender: RecentTableViewCell)
}

class RecentTableViewCell: UITableViewCell {
    
    weak var delegate: recentTableCellDelegate?
    @IBOutlet weak var recentText: UILabel!
    
    @IBAction func clearButton(_ sender: UIButton) {
        delegate?.didTapClearButton(self)
    }
    func setText(_ txt: String) {
        recentText.text = txt
    }
}
