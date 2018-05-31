//
//  HomedMain.swift
//  WYPhotoBrowser
//
//  Created by wangyong on 2018/2/2.
//  Copyright © 2018年 ipanel. All rights reserved.
//
//  Associated    pod 'MBProgressHUD'
//                pod 'Kingfisher' 
//
import Foundation
import UIKit

let SpaceHeight = UIApplication.shared.statusBarFrame.size.height

let APPDisplayName:String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String    //app name

let imageMinZoom: CGFloat = 0.3      //min scaling ratio

let imagePanningSpeed: CGFloat = 1.0 //0.0-1.0

let imgViewTag = 4396

let alertSave = "保存图片"

let alertShare = "分享图片"
