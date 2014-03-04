Pod::Spec.new do |spec|
  spec.name         = 'Shimmer'
  spec.version      = '0.0.1'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/facebook/Shimmer'
  spec.authors      = { 'Grant Paul' => 'shimmer@grantpaul.com', 'Kimon Tsinteris' => 'kimon@mac.com' }
  spec.summary      = 'Simple shimmering effect.'
  spec.source       = { :git => 'https://github.com/facebook/Shimmer.git', :commit => '313cab89e74238dfea940151561e407042cade51' }
  spec.source_files = 'FBShimmering/FBShimmering{,View,Layer}.{h,m}'
  spec.requires_arc = true
  
  spec.ios.deployment_target = '6.0'
end
