//
//  CalendarHeader.swift
//  SPCalendar
//
//  Created by Сергей Полозов on 20/03/2019.
//  Copyright © 2019 Сергей Полозов. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarHeader: JTAppleCollectionReusableView {

    // MARK: - UIViews

    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Awake from Nib

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = UIColor.gray
    }
    
}
