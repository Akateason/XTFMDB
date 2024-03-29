
Pod::Spec.new do |s|

  s.name         = "XTFMDB"
  s.version      = "3.0.0"
  s.summary      = "An FMDB based package. Rapid development framework."
  s.homepage     = "https://github.com/Akateason/XTFMDB"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "teason" => "teason.xie@cootek.cn" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Akateason/XTFMDB.git", :tag => s.version }

  s.source_files  = "demo_XTFMDB/XTFMDB","demo_XTFMDB/XTFMDB/Main","demo_XTFMDB/XTFMDB/Util"
  s.public_header_files = "demo_XTFMDB/XTFMDB/*.h","demo_XTFMDB/XTFMDB/Main/*.h","demo_XTFMDB/XTFMDB/Util/*h"

  s.dependency "FMDB"
  s.dependency "YYModel"

end
