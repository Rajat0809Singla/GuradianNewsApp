//
//  UIview+Extension.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    public class func fromNib(_ nibNameOrNil: String? = nil) -> Self? {
        return fromNib(nibNameOrNil, type: self)
    }
    
    public class func fromNib<T: UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T? {
        var view: T?
        let name = nibNameOrNil ?? nibName
        
        if let nibViews = Bundle.main.loadNibNamed(name, owner: nil, options: nil) {
            for nib in nibViews {
                if let viewOfType = nib as? T {
                    view = viewOfType
                    break
                }
            }
        }
        
        return view
    }
    
    public class func nib(_ nibNameOrNil: String? = nil, bundle: Bundle? = nil) -> UINib? {
        let name = nibNameOrNil ?? nibName
        return UINib(nibName: name, bundle: bundle)
    }
    
    public class var nibName: String {
        let name: String = "\(self)".components(separatedBy: ".").first ?? ""
        return name
    }
}

protocol ReusableViewRepresentable {
    static var reuseIdentifier: String { get }
}

extension ReusableViewRepresentable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableViewRepresentable {}
