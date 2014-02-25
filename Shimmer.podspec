Pod::Spec.new do |spec|
  spec.name         = 'Shimmer'
  spec.version      = '0.0.1'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/facebook/Shimmer'
  spec.authors      = { 'Grant Paul' => 'shimmer@grantpaul.com', 'Kimon Tsinteris' => 'kimon@mac.com' }
  spec.summary      = 'Simple shimmering effect.'
  spec.source       = { :git => 'https://github.com/facebook/Shimmer.git', :commit => '0292130f472f46c8aac6fb0b647caf120babfdab' }
  spec.source_files = 'Shimmer/FBShimmering{,View,Layer}.{h,m}'
  spec.requires_arc = true
  
  spec.ios.deployment_target = '6.0'
end
