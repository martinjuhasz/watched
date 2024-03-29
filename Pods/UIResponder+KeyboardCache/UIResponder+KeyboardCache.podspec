Pod::Spec.new do |s|
  s.name     = 'UIResponder+KeyboardCache'
  s.version  = '0.1'
  s.license  = 'MIT'
  
  s.summary  = 'A simple workaround to the annoying problem of keyboard lag.'
  s.homepage = 'https://github.com/mbrandonw/UIResponder-KeyboardCache'
  s.author   = { 'Brandon Williams' => 'brandon@opetopic.com' }
  s.source   = { :git => 'https://github.com/mbrandonw/UIResponder-KeyboardCache.git' }
  
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end
