@version = "1.0.1"

Pod::Spec.new do |s| 
s.name = "WYPhotoViewList" 
s.version = @version 
s.summary = "图片浏览器" 
s.description = "A swift-based Photo browser" 
s.homepage = "https://github.com/wangyongy/WYPhotoViewList.git" 
s.license = "Copyright (c) 2018年 wangyong. All rights reserved."
s.author = { "wangyong" => "15889450281@163.com" } 
s.ios.deployment_target = '8.0' 
s.source = { :git => "https://github.com/wangyongy/WYPhotoViewList.git", :tag => "v#{s.version}" } 
s.source_files = 'WYPhotoViewList/WYPhotoViewList/**/*.{h,m,swift}' 
s.resource     = "WYPhotoViewList/WYPhotoViewList/WYIcons.bundle"
s.requires_arc = true 
s.framework = 'Foundation','UIKit'
s.dependency 'Kingfisher'
s.dependency 'MBProgressHUD' 

end