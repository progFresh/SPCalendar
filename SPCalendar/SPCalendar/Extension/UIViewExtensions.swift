//
//  UIViewExtensions.swift
//  SPCalendar
//
//  Created by Сергей Полозов on 20/03/2019.
//  Copyright © 2019 Сергей Полозов. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

