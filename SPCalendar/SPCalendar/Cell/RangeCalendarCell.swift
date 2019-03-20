//
//  RangeCalendarCell.swift
//  SPCalendar
//
//  Created by Сергей Полозов on 20/03/2019.
//  Copyright © 2019 Сергей Полозов. All rights reserved.
//

import UIKit
import JTAppleCalendar

class RangeCalendarCell: JTAppleCell {

    // MARK: - UIViews

    @IBOutlet weak var lightView: UIView!
    @IBOutlet weak var backView: UIView!

    // MARK: - Constants
    
    private let radius = CGFloat(7)
    let dateLabel = UILabel()
    private let lightColor = UIColor.blue.withAlphaComponent(0.5)
    private let backColor = UIColor.blue
    
    // MARK: - Awake from Nib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Internal helpers
    
    func setLeftState() {
        showOriginViews()
        lightView.roundCorners(corners: [.topLeft, .bottomLeft], radius: radius)
    }
    
    func setRightState() {
        showOriginViews()
        lightView.roundCorners(corners: [.topRight, .bottomRight], radius: radius)
    }
    
    func setMiddleState() {
        showOriginViews()
        backView.isHidden = true
    }
    
    func setFirstState() {
        showOriginViews()
        lightView.roundCorners(corners: [.topRight, .bottomRight, .topLeft, .bottomLeft], radius: radius)
    }
    
    func setNoneState() {
        hideOrangeViews()
    }
    
    // MARK: - Private helpers
    
    private func hideOrangeViews() {
        lightView.isHidden = true
        backView.isHidden = true
    }
    
    private func showOriginViews() {
        lightView.isHidden = false
        backView.isHidden = false
        lightView.roundCorners(corners: UIRectCorner(), radius: 0)
    }
    
    private func setupViews() {
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
        lightView.backgroundColor = lightColor
        backView.backgroundColor = backColor
        backView.layer.cornerRadius = radius
        clipsToBounds = false
    }
    
}
