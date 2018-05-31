//
//  ViewController.swift
//  WYPhotoViewList
//
//  Created by 王勇 on 2018/5/31.
//  Copyright © 2018年 王勇. All rights reserved.
//

import UIKit
import Kingfisher

let Screen_width = UIScreen.main.bounds.width

let Screen_height = UIScreen.main.bounds.height

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    let cellIdentifier = "cellIdentifier"
    
    let dataSource = NSMutableArray()
    
    var collectionView : UICollectionView?
    
    var resultBlock: ((Any) -> (UIImage))?
    
    let imageUrlArray = ["http://pic.qiantucdn.com/58pic/18/85/34/56561c9192d9f_1024.jpg",
                         "http://img.sc115.com/uploads1/sc/jpgs/1511/apic23847_sc115.com.jpg",
                         "http://pic.qqtn.com/up/2017-2/201702131606225644712.png",
                         "http://www.tupianzj.com/uploads/Bizhi/mn2_1680.jpg",
                         "http://imgsrc.baidu.com/image/c0%3Dpixel_huitu%2C0%2C0%2C294%2C40/sign=87efb04af0f2b211f0238d0ea3f80054/2e2eb9389b504fc242b5663ceedde71190ef6d25.jpg",
                         "http://img.zcool.cn/community/033ee1a554c723d00000158fc2f64fe.jpg",
                         "http://img.sc115.com/uploads1/sc/jpgs/1511/apic23847_sc115.com.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLocalData()
        
        initCollectionView()
        
        initChangeImageTypeButton()
        // Do any additional setup after loading the view, typically from a nib.
    }
    // MARK:
    func loadLocalData() {
        
        dataSource.removeAllObjects()
        
        for _ in 1...7 {
            
            for j in 1...7 {
                
                dataSource.add(String(format:"%03zd.jpg",j))
                
            }
        }
        
        resultBlock = { (name:Any) -> (UIImage) in
            
            return UIImage.init(named: name as! String)!
        }
        
        collectionView?.reloadData()
    }
    func loadUrlData() {
        
        dataSource.removeAllObjects()
        
        for _ in 1...7 {
            
            dataSource.addObjects(from: imageUrlArray)
        }
        
        resultBlock = nil
        
        collectionView?.reloadData()
    }
    // MARK:UI
    func initCollectionView() {
        
        collectionView?.removeFromSuperview()
        
        collectionView = nil
        
        let defaultLayout = UICollectionViewFlowLayout()
        
        defaultLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        collectionView = UICollectionView(frame: CGRect(x:45.0/4.0, y:100, width:Screen_width - 45.0/2.0, height:Screen_height - 100), collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView?.dataSource = self
        
        collectionView?.delegate = self
        
        collectionView?.showsVerticalScrollIndicator =  false
        
        collectionView?.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(collectionView!)
        
    }
    
    func initChangeImageTypeButton() {
        
        let button = UIButton(frame: CGRect(x:50, y:Screen_height - 100, width:Screen_width - 100, height:40))
        
        button.addTarget(self, action: #selector(changeImageTypeButtonAction(sender:)), for: UIControlEvents.touchUpInside)
        
        button.backgroundColor = UIColor.green
        
        button.setTitle("change to web pictures", for: .normal)
        
        button.setTitleColor(UIColor.white, for: .normal)
        
        button.layer.cornerRadius = button.frame.height/2.0
        
        view.addSubview(button)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:action
    @objc func changeImageTypeButtonAction(sender:UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        sender.setTitle(sender.isSelected ? "change to lcoal pictures" : "change to web pictures", for: .normal)
        
        if sender.isSelected {
            
            loadUrlData()
            
        }else {
            
            loadLocalData()
        }
        
        collectionView?.reloadData()
        
    }
    // MARK:UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return dataSource.count;
        
    }
    //cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell:UICollectionViewCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath)
        
        for view:UIView in cell.contentView.subviews {
            
            view.removeFromSuperview()
        }
        
        let imgView:UIImageView = UIImageView.init(frame: cell.contentView.bounds)
        
        if resultBlock != nil {
            
            imgView.image = resultBlock!(dataSource[indexPath.row])
            
        }else {

            imgView.kf.setImage(with:URL.init(string: dataSource[indexPath.row] as! String), placeholder: UIImage(named: "placeholder.jpg", in: Bundle(path: Bundle(for: HomedPhotoViewList.classForCoder()).resourcePath! + "/WYIcons.bundle"), compatibleWith: nil), options: [KingfisherOptionsInfoItem.backgroundDecode], progressBlock: nil, completionHandler: nil)
        }
 
        imgView.tag = imgViewTag
        
        cell.contentView.addSubview(imgView)
        
        return cell;
        
    }
    
    //select item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        
    {
        _ = HomedPhotoViewList.showView(isUrl: resultBlock == nil, imgArray: dataSource, currentIndex: indexPath.row, parentVC: self, placeholderImage: nil, selectBlock: { (index:Int) -> (UIImageView) in
            
            let cell:UICollectionViewCell? = collectionView.cellForItem(at: NSIndexPath(item: index, section: 0) as IndexPath)
            
            if cell == nil {    //can not be nil
                
                return UIImageView()
                
            }
            
            return cell!.contentView.viewWithTag(imgViewTag) as! (UIImageView)
        }, resultBlock:resultBlock)
    }
    
    //item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: Screen_width/3.0 - 15.0, height: Screen_width/3.0 - 15.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        
        return UIEdgeInsetsMake(0, 0, 0, 0);
        
    }
}

