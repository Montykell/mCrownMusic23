//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import UIKit

extension UINavigationController {
    func setCenterTitleImage(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100) // Adjust size as needed
        self.navigationBar.topItem?.titleView = imageView
    }
}
