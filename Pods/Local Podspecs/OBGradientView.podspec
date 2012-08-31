Pod::Spec.new do |s|
  s.name     = 'OBGradientView'
  s.version  = '1.0'
  s.license  = 'MIT'
  s.summary  = 'A simple UIView wrapper for CAGradientLayer. For the times when its more convenient to use a view instead of a CALayer'
  s.homepage = 'https://github.com/ole/OBGradientView'
  s.author   = { 'Ole Begemann' => 'ole@oleb.net' }

  s.source   = { :git => 'https://github.com/ole/OBGradientView', :commit => '080d3f87d4f39f85dd3a62d536d80c9b39fd9c66' }
  s.platform = :ios
  s.source_files = 'Classes', 'OBGradientView/*.{h,m}'
end
