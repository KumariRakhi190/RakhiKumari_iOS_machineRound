//
//  Loader.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//

import SVProgressHUD

class Loader{
    
    static func show(){
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
    }
    
    static func hide(){
        SVProgressHUD.dismiss()
    }
    
}

