//
//  HomedPhotoView.swift
//  WYPhotoBrowser
//
//  Created by wangyong on 2018/2/1.
//  Copyright © 2018年 ipanel. All rights reserved.
//
import UIKit
import Kingfisher
import MBProgressHUD
class HomedPhotoView: UIView,UIScrollViewDelegate  {

    let imageView = UIImageView()

    let scrollView = UIScrollView()

    var hud: MBProgressHUD?

    var gestureBlock: ((Int,Bool)->())?         //callBack when tap to go back or long press, Int:current index, Bool:is tap to go back

    var panBlock: ((CGFloat,CGRect)->())?       //callBack when panning to change backgroundColor and bigImageView's frame.  CGFloat:panning progress, CGRect:photo's frame which is panning now
    
    var moveImageView: UIImageView?             //imageView which to show on panning

    var isZooming = false                       //is zooming, do not execution panning method

    var isPanning = false                       //is panning

    var directionIsDown = false                 //whether it is panning down， if true,go back. else, Bounce back up

    var comProprotion: CGFloat = 0.0 {          //the progress of panning

        //setter
        didSet {

            if panBlock != nil && moveImageView != nil {

                panBlock!(CGFloat(1.0 - comProprotion),(moveImageView?.frame)!)

            }
        }
    }


    var panLastY: CGFloat = 0.0                 //the position of the last pan

    var panBeginPoint = CGPoint(x: 0, y: 0)     //the position of finger when the pan begin

    var imageFrameBegin = CGRect(x: 0, y: 0, width: 0, height: 0)//the frame of imageView when the pan begin
// MARK:
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
// MARK:UI
    init(frame: CGRect,photoUrl:String,placeholderImage:UIImage?) {

        super.init(frame: frame)

        initScrollView()

        initGesture()

        weak var weakSelf = self
        
        let isInCache = KingfisherManager.shared.cache.imageCachedType(forKey: photoUrl).cached
        
        if !isInCache {
            
            hud = MBProgressHUD.showAdded(to: self, animated: true)
            
            hud?.mode = MBProgressHUDMode.determinate
        }
        
        imageView.kf.setImage(with: URL.init(string: photoUrl), placeholder:(placeholderImage != nil) ? placeholderImage : UIImage(named: "placeholder.jpg", in: Bundle(path: Bundle(for: HomedPhotoViewList.classForCoder()).resourcePath! + "/WYIcons.bundle"), compatibleWith: nil), options: [KingfisherOptionsInfoItem.backgroundDecode], progressBlock: { (receivedSize:Int64, expectedSize:Int64) in
            
            weakSelf?.hud?.progress = Float(CGFloat(receivedSize)/CGFloat(expectedSize))
            
        }, completionHandler: { (image:UIImage?, error:NSError?, type:CacheType, url:URL?) in
            
            print("success");
            
            if !isInCache {
                
                weakSelf?.hud?.hide(animated: true)
            }
            
            if image != nil {
                
                weakSelf?.loadImageViewSize(image: image!)
            }
        })
    }
    init(frame: CGRect,image:UIImage) {

        super.init(frame: frame)

        initScrollView()

        initGesture()

        loadImageViewSize(image: image)
    }
    func initGesture() {

        imageView.frame = self.bounds

        imageView.contentMode = UIViewContentMode.scaleAspectFill

        imageView.isUserInteractionEnabled = true

        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTapAction(gestureRecognizer:)))

        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction(gestureRecognizer:)))

        let twoFingerTap = UITapGestureRecognizer.init(target: self, action: #selector(twoFingerTapAction(gestureRecognizer:)))

        let longPressTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressTapAction(gestureRecognizer:)))

        let selfSingleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTapAction(gestureRecognizer:)))

        singleTap.numberOfTapsRequired = 1;

        singleTap.numberOfTouchesRequired = 1;

        doubleTap.numberOfTapsRequired = 2;

        twoFingerTap.numberOfTouchesRequired = 2;

        singleTap.require(toFail: doubleTap)

        imageView.addGestureRecognizer(singleTap)

        imageView.addGestureRecognizer(doubleTap)

        imageView.addGestureRecognizer(twoFingerTap)

        imageView.addGestureRecognizer(longPressTap)

        self.addGestureRecognizer(selfSingleTap)

    }

    func initScrollView()  {

        // add scrollView
        scrollView.frame = self.bounds

        scrollView.delegate = self;

        scrollView.minimumZoomScale = 1;

        scrollView.maximumZoomScale = 3;

        scrollView.showsHorizontalScrollIndicator = false

        scrollView.showsVerticalScrollIndicator = false

        scrollView.alwaysBounceVertical = true

        scrollView.alwaysBounceHorizontal = true

        scrollView.contentSize = imageView.frame.size

        scrollView.setZoomScale(1, animated: false)

        scrollView.contentOffset = CGPoint(x:0,y:0);

        scrollView.addSubview(imageView)

        if #available(iOS 11.0, *) {

            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } 

        self.addSubview(scrollView)
    }
    // MARK:set

    func loadImageViewSize(image:UIImage) {

        imageView.image = image

        if (image.size.width == 0 || image.size.height == 0)
        {
            return
        }

        let size = image.size

        if (size.width)/self.frame.width > (size.height)/self.frame.height {

            imageView.frame.size.width = self.frame.width

            imageView.frame.size.height = (imageView.frame.width) * (size.height)/(size.width)
        }else{

            imageView.frame.size.height = self.frame.height

            imageView.frame.size.width = (imageView.frame.height) * (size.width)/(size.height)
        }

        imageView.center = CGPoint(x: self.frame.width/2, y:self.frame.height/2);
        
    }
    /*
     *  get size of zoom
     */
    func zoomRectForScale(_ scale:CGFloat,_ center:CGPoint) -> CGRect {

        let width = scrollView.frame.width/scale

        let height = scrollView.frame.height/scale

        return CGRect(x:center.x - width/2.0,y:center.y - height/2.0,width:width,height:height)

    }
    // MARK:action

    @objc func singleTapAction(gestureRecognizer:UITapGestureRecognizer) {

        print("singleTapAction")

        if gestureRecognizer.numberOfTapsRequired == 1  {

            if self.gestureBlock != nil {

                self.gestureBlock!(self.tag - imgViewTag,true)
            }
        }
    }
    @objc func doubleTapAction(gestureRecognizer:UITapGestureRecognizer) {

        print("doubleTapAction")

        if gestureRecognizer.numberOfTapsRequired == 2 {

            if scrollView.zoomScale == 1{

                let newScale = scrollView.zoomScale*2.0

                let zoomRect = zoomRectForScale(newScale, gestureRecognizer.location(in: gestureRecognizer.view))

                scrollView.zoom(to: zoomRect, animated: true)

            }else {

                let newScale = scrollView.zoomScale/2.0

                let zoomRect = zoomRectForScale(newScale, gestureRecognizer.location(in: gestureRecognizer.view))

                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
    }
    @objc func twoFingerTapAction(gestureRecognizer:UITapGestureRecognizer) {

        print("twoFingerTapAction")

        let newScale = scrollView.zoomScale/2.0

        let zoomRect = zoomRectForScale(newScale, gestureRecognizer.location(in: gestureRecognizer.view))

        scrollView.zoom(to: zoomRect, animated: true)
    }
    @objc func longPressTapAction(gestureRecognizer:UILongPressGestureRecognizer) {

        print("longPressTapAction")

        if gestureRecognizer.state.rawValue == UIGestureRecognizerState.began.rawValue{

            if self.gestureBlock != nil {

                self.gestureBlock!(self.tag - imgViewTag,false)
            }
        }
    }


    func panAction(_ gestureRecognizer:UIPanGestureRecognizer)  {

        if gestureRecognizer.state.rawValue == UIGestureRecognizerState.ended.rawValue || gestureRecognizer.state.rawValue == UIGestureRecognizerState.possible.rawValue {

            panBeginPoint = CGPoint(x: 0, y: 0)

            isPanning = false

            return
        }

        if gestureRecognizer.numberOfTouches != 1 || isZooming //two finger，is zooming
        {

            moveImageView = nil

            isPanning = false

            panBeginPoint = CGPoint(x: 0, y: 0)

            return;
        }

        if panBeginPoint == CGPoint(x: 0, y: 0)   //begin pan
        {
            panBeginPoint = gestureRecognizer.location(in: self)

            isPanning = true

            scrollView.isHidden = true

            imageFrameBegin = imageView.frame
        }

        if moveImageView == nil

        {
            moveImageView = UIImageView(frame: imageView.frame)

            moveImageView?.contentMode = UIViewContentMode.scaleAspectFill

            moveImageView?.layer.masksToBounds = true

            moveImageView?.image = imageView.image

            self.addSubview(moveImageView!)
        }

        let panCurrentPoint = gestureRecognizer.location(in: self)

        directionIsDown = panCurrentPoint.y > panLastY              //Judge whether it is panning down

        panLastY = panCurrentPoint.y

        self.comProprotion = (panCurrentPoint.y - panBeginPoint.y)/(self.frame.height/(1 + imagePanningSpeed))

        if panCurrentPoint.y > panBeginPoint.y
        {

            let zoomWidth = imageFrameBegin.width - (imageFrameBegin.width - imageFrameBegin.width * imageMinZoom) * comProprotion

            let zoomHeight = imageFrameBegin.height - (imageFrameBegin.height - imageFrameBegin.height * imageMinZoom) * comProprotion

            let minWidth = imageFrameBegin.width*imageMinZoom

            let minHeight = imageFrameBegin.height*imageMinZoom

            moveImageView?.frame.size.width = zoomWidth < minWidth ? minWidth : zoomWidth

            moveImageView?.frame.size.height = zoomHeight < minHeight ? minHeight : zoomHeight
        }
        else
        {
            moveImageView?.frame.size.width = imageFrameBegin.width

            moveImageView?.frame.size.height = imageFrameBegin.height
        }

        moveImageView?.frame.origin.x = (panBeginPoint.x - imageFrameBegin.origin.x)/imageFrameBegin.width*(imageFrameBegin.width - (moveImageView?.frame.width)!) + (panCurrentPoint.x - panBeginPoint.x) + imageFrameBegin.origin.x

        moveImageView?.frame.origin.y = (panBeginPoint.y - imageFrameBegin.origin.y)/imageFrameBegin.height*(imageFrameBegin.height - (moveImageView?.frame.height)!) + (panCurrentPoint.y - panBeginPoint.y) + imageFrameBegin.origin.y

    }
    func endPanAction() {

        if directionIsDown { //go back

            if gestureBlock != nil {

                self.gestureBlock!(self.tag - imgViewTag,true)
            }

        }else{

            weak var weakSelf = self

            UIView.animate(withDuration: TimeInterval(fabs((moveImageView?.frame.origin.y)! - imageFrameBegin.origin.y)/(self.frame.height*2)), animations: {

                weakSelf?.moveImageView?.frame = (weakSelf?.imageFrameBegin)!

                weakSelf?.comProprotion = 0.0

            }, completion: { (finished:Bool) in

                weakSelf?.scrollView.contentOffset = CGPoint(x: 0, y: 0)

                weakSelf?.panBeginPoint = CGPoint(x: 0, y: 0)

                weakSelf?.moveImageView?.isHidden = true

                weakSelf?.scrollView.isHidden = false

                weakSelf?.moveImageView = nil


            })
        }
    }
    // MARK:UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? // return a view that will be scaled. if delegate returns nil, nothing happens
    {
        return imageView
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) // called before the scroll view begins zooming its content
    {
        isZooming = true
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    {
        scrollView.setZoomScale(scale + 0.01, animated: false)

        scrollView.setZoomScale(scale, animated: false)

        isZooming = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {

        if (scrollView.contentOffset.y < 0 || isPanning) && !isZooming {

            panAction(scrollView.panGestureRecognizer)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if isPanning {

            endPanAction()
        }
    }
}
