//
//  CustomClases.swift
//  Injoy
//
//  Created by Juan Alejandro Galvis on 1/10/18.
//  Copyright © 2018 Juan Alejandro Galvis. All rights reserved.
//

import UIKit



class customUIAlertView: UIAlertController {
    override open func viewWillLayoutSubviews() {
        guard let subView = view.subviews.first else { return }
        guard let subView2 = subView.subviews.first else { return }
        guard let subView3 = subView2.subviews.first else { return }
        subView3.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.tintColor = UIColor.white
    }
}


