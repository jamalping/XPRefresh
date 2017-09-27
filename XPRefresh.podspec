Pod::Spec.new do |s|

  s.name         = "XPRefresh"
  s.version      = "0.0.5"
  s.summary      = "Swift版刷新控件."
  s.homepage     = "https://github.com/jamalping/XPRefresh"
  s.license      = 'MIT'
  s.author             = { "jamalping" => "420436097@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/jamalping/XPRefresh.git", :tag => s.version }
  s.source_files = "XPRefresh/**/*.swift"
  s.resource     = "XPRefresh/XPRefresh.bundle"
  s.requires_arc = true
end
