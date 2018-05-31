//
//  HomedPhotoViewList.swift
//  WYPhotoBrowser
//
//  Created by wangyong on 2018/2/1.
//  Copyright © 2018年 ipanel. All rights reserved.
//

import UIKit
import Kingfisher

class HomedPhotoViewList: UIView,UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate {

    let subViewList = NSMutableArray()

    let scrollView = UIScrollView()

    let topLabel = UILabel()

    let rightButton = UIButton()

    var isUrl: Bool?

    var imgArray: NSArray?

    var currentIndex: Int?

    var parentVC: UIViewController?
    
    var placeholderImage: UIImage?

    var selectBlock: ((Int)->(UIImageView))?

    var resultBlock: ((Any)->(UIImage))?

    var bigBgView: UIView?                          // the bigImageView's backgroundView when tap image

    var bigImageView: UIImageView?                  // the bigImageView when tap image

    var smallImageView = UIImageView()              // the small iamgeView of current imageView

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    // MARK: class func
    /*
     *  isUrl:is web picture
     *
     *  imgArray:if is web picture,imgArray is url.string list. otherwise,imgArray is convert Any to image,resultBlock can not be nil
     *
     *  currentIndex:tap image current index in imgArray
     *
     *  parentVC: UIViewController before push
     *
     *  placeholderImage: placeholderImage
     *
     *  selectBlock:Int is currentIndex, result UIImageView is current imageView in parentVC
     *
     *  resultBlock:convert Any to image, when isUrl is true ,resultBlock can not be nil
     */
    class func showView(isUrl:Bool,imgArray:NSArray,currentIndex:Int,parentVC:UIViewController,placeholderImage:UIImage?,selectBlock:@escaping ((Int)->(UIImageView)),resultBlock:((Any)->(UIImage))?) -> UIView {

        let selfView = HomedPhotoViewList(frame: parentVC.view.bounds)

        selfView.isUrl = isUrl

        selfView.imgArray = imgArray

        selfView.currentIndex = currentIndex

        selfView.parentVC = parentVC
        
        selfView.placeholderImage = placeholderImage

        selfView.selectBlock = selectBlock

        selfView.resultBlock = resultBlock

        selfView.show()

        return selfView
    }
    // MARK:UI
    func show() {

        parentVC?.view?.addSubview(self)

        smallImageView = selectBlock!(currentIndex!)

        loadBigView()

        weak var weakSelf = self

        UIView.animate(withDuration: 0.3, animations: {

            weakSelf?.bigBgView?.alpha = 1

            weakSelf?.setBigImageViewFrame()

        }) { (finished:Bool) in

            weakSelf?.initUI()
        }

    }

    func initUI() {

        weak var weakSelf = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

            weakSelf?.bigBgView?.alpha = 0

            weakSelf?.bigBgView?.backgroundColor = UIColor.clear

            weakSelf?.sendSubview(toBack: (weakSelf?.bigBgView)!)
        }

        self.backgroundColor = UIColor.clear

        initScrollView()

        initInfoView()

        setPicCurrentIndex(index: currentIndex!)

        bringSubview(toFront: bigBgView!)
    }
    func initScrollView() {

        scrollView.frame = CGRect(x:0, y:0, width:self.frame.width + 20, height:self.frame.height)

        scrollView.delegate = self

        scrollView.backgroundColor = UIColor.black;

        scrollView.contentSize = CGSize(width:CGFloat(imgArray!.count*Int(self.frame.width + 20)), height:self.frame.height)

        scrollView.bounces = true

        scrollView.showsVerticalScrollIndicator = false

        scrollView.showsHorizontalScrollIndicator = false

        scrollView.isPagingEnabled = true

        scrollView.contentOffset = CGPoint(x:0, y:0);

        scrollView.clipsToBounds = false

        for _ in 0...(imgArray?.count)! - 1 {

            subViewList.add(NSNull())
        }

        self.addSubview(scrollView)
    }

    func initInfoView() {

        topLabel.frame = CGRect(x:self.frame.width/2 - 30, y:SpaceHeight, width:60, height:30)

        topLabel.text = String.init(format: "%zd/%zd", currentIndex! + 1,(imgArray?.count)!);

        topLabel.textColor = UIColor.white;

        topLabel.textAlignment = .center;

        topLabel.font = UIFont.systemFont(ofSize: 17);

        rightButton.frame = CGRect(x:self.frame.width - 40, y:SpaceHeight, width:20, height:30)

        rightButton.setImage(UIImage(named: "menu", in: Bundle(path: Bundle(for: HomedPhotoViewList.classForCoder()).resourcePath! + "/WYIcons.bundle"), compatibleWith: nil), for: .normal)

        rightButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit

        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControlEvents.touchUpInside)

        addSubview(rightButton)

        addSubview(topLabel)
    }
    func setPicCurrentIndex(index:Int) {

        currentIndex = index

        scrollView.contentOffset = CGPoint(x:scrollView.frame.width*CGFloat(index),y:0)

        loadPhoto(index: index)

        loadPhoto(index: index - 1)

        loadPhoto(index: index + 1)

    }
    func loadPhoto(index:Int) {

        if (index < 0 || index >= imgArray!.count) {

            return;
        }

        if !(subViewList[index] as AnyObject).isKind(of: HomedPhotoView.self) {

            let frame = CGRect(x:CGFloat(index)*scrollView.frame.width,y:0, width:self.frame.width, height:self.frame.height)

            var photoView: HomedPhotoView?

            if isUrl! {

                photoView = HomedPhotoView(frame: frame, photoUrl: imgArray![index] as! String, placeholderImage: placeholderImage)

            }else {

                let image = self.resultBlock!(imgArray![index])

                photoView = HomedPhotoView(frame: frame, image: image)

            }

            weak var weakSelf = self

            photoView?.gestureBlock = {(data:Int,isHidden:Bool) in

                weakSelf?.currentIndex = data

                if isHidden {

                    weakSelf?.tapHiddenPhotoView(index: data)

                }else{

                    weakSelf?.rightButtonAction(sender: (weakSelf?.rightButton)!)
                }
            }

            photoView?.panBlock = {(alpha: CGFloat, panFrame: CGRect) in

                weakSelf?.scrollView.backgroundColor = UIColor.black.withAlphaComponent(alpha)

                weakSelf?.bigImageView?.frame = panFrame

                weakSelf?.scrollView.isScrollEnabled = alpha == 1.0
            }

            photoView?.tag = imgViewTag + index

            scrollView.insertSubview(photoView!, at: 0)

            subViewList.replaceObject(at: index, with: photoView!)
        }

    }
// MARK:animate
    func setBigImageViewFrame() {

        if (bigImageView?.image == nil || bigImageView?.image?.size.width == 0 || bigImageView?.image?.size.height == 0)
        {
            return
        }

        let size = bigImageView?.image?.size

        if (size?.width)!/self.frame.width > (size?.height)!/self.frame.height {

            bigImageView?.frame.size.width = self.frame.width

            bigImageView?.frame.size.height = (bigImageView?.frame.width)! * (size?.height)!/(size?.width)!
        }else{

            bigImageView?.frame.size.height = self.frame.height

            bigImageView?.frame.size.width = (bigImageView?.frame.height)! * (size?.width)!/(size?.height)!
        }

        bigImageView?.center = CGPoint(x: self.frame.width/2, y:self.frame.height/2);
    }

    func loadBigView() {

        if smallImageView.image == nil
        {
            return
        }

        bigBgView = UIView(frame: self.bounds)

        bigBgView?.backgroundColor = UIColor.black

        let vcFrame = smallImageView.convert(smallImageView.bounds, to: self)

        bigImageView = UIImageView(frame: vcFrame)
        
        bigImageView?.image = smallImageView.image

        bigBgView?.addSubview(bigImageView!)

        bigBgView?.alpha = 0

        self.addSubview(bigBgView!)
    }
    // MARK:action
    @objc func rightButtonAction(sender:UIButton){

        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: alertSave, otherButtonTitles: alertShare)

        actionSheet.actionSheetStyle = UIActionSheetStyle.blackOpaque

        actionSheet.show(in: self)
    }
    func tapHiddenPhotoView(index:Int)  {

        scrollView.removeFromSuperview()

        topLabel.removeFromSuperview()

        rightButton.removeFromSuperview()

        if selectBlock != nil {

            smallImageView = selectBlock!(index)
        }

        if smallImageView.image != nil {

            bigImageView?.image = smallImageView.image
        }

        weak var weakSelf = self

        bigBgView?.alpha = 1

        UIView.animate(withDuration: 0.3, animations: {

            weakSelf?.bigBgView?.backgroundColor = UIColor.clear

            let vcFrame = weakSelf?.smallImageView.convert((weakSelf?.smallImageView.bounds)!, to: weakSelf?.parentVC?.view)

            weakSelf?.bigImageView?.frame = vcFrame!

        }) { (finished:Bool) in

            self.removeFromSuperview()
        }
    }
    func shareAction() {

        if !(subViewList[currentIndex!] as AnyObject).isKind(of: HomedPhotoView.self) {

            return
        }

        let imgView = (subViewList[currentIndex!] as! HomedPhotoView).imageView

        var imageData: NSData?

        var image: UIImage?
        
        if isUrl! {
            
            let isCached = KingfisherManager.shared.cache.imageCachedType(forKey: (imgView.kf.webURL?.absoluteString)!).cached
            
            if (isCached) {
                
                image = imgView.image
            }
            
            if imageData == nil && image == nil {
                
                imageData = NSData(contentsOf: imgView.kf.webURL!)
            }
            
        }else if imgView.image != nil{

            image = imgView.image
        }

        if image == nil && imageData != nil {

            image = UIImage(data: imageData! as Data)
        }

        if image != nil {

            let activityVC = UIActivityViewController(activityItems: [image!], applicationActivities: nil)

            activityVC.popoverPresentationController?.sourceView = self

            parentVC?.present(activityVC, animated: true, completion: nil)

        }
    }
    func saveAction() {

        if !(subViewList[currentIndex!] as AnyObject).isKind(of: HomedPhotoView.self) {

            return
        }

        let imgView = (subViewList[currentIndex!] as! HomedPhotoView).imageView

        var image: UIImage?

        if isUrl! {

            if KingfisherManager.shared.cache.imageCachedType(forKey: (imgView.kf.webURL?.absoluteString)!).cached {
                
                image = imgView.image
            }
            
        }else if imgView.image != nil{

           image = imgView.image

        }

        if image != nil {

            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(didFinishSavingWithError(image:error:contextInfo:)), nil)
        }
    }
    @objc func didFinishSavingWithError(image:UIImage,error:NSError?,contextInfo:UnsafeMutableRawPointer?){

        if error == nil {

            let alert = UIAlertView(title: "", message: "已存入手机相册", delegate: self, cancelButtonTitle: "确定")

            alert.show()

        }else{

            let alert = UIAlertView(title: "保存失败", message: String.init(format: "请打开 设置-隐私-照片 对“%@”设置为打开", APPDisplayName ?? "少年,app不取名字的?"), delegate: self, cancelButtonTitle: "确定", otherButtonTitles: "设置")

            alert.show()
        }
    }
    // MARK:UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int){

        let buttonTitle = actionSheet.buttonTitle(at: buttonIndex)

        if buttonTitle == alertSave {

            self.saveAction()
            
        }else if buttonTitle == alertShare{

            self.shareAction()
        }
    }
    // MARK:UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int)
    {
        if buttonIndex == 1 {

            let url = URL(string: "prefs:root=Privacy&path=PHOTOS")

            let settingUrl = URL(string: UIApplicationOpenSettingsURLString)

            let shareApplication = UIApplication.shared

            if shareApplication.canOpenURL(url!) {

                shareApplication.openURL(url!)

            }else if shareApplication.canOpenURL(settingUrl!) {

                shareApplication.openURL(settingUrl!)
            }

        }
    }
    // MARK:UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        print("scrollViewDidEndDecelerating")

        let index = Int((self.scrollView.contentOffset.x + 20)/self.scrollView.frame.width+1)

        loadPhoto(index: index - 1)

        topLabel.text = String.init(format: "%zd/%zd", index,imgArray!.count)

    }
}

