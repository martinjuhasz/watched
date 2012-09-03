Pod::Spec.new do |s|
  s.name     = 'ReachabilityForIOS5'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'some corrections for IOS5 and ARC'
  s.homepage = 'https://github.com/martinjuhasz/ReachabilityForIOS5'
  s.author   = { 'Gustavo Ambrozio' => '' }
  s.source   = { :git => 'https://github.com/martinjuhasz/ReachabilityForIOS5' }
  s.description = 'some corrections for IOS5 and ARC'
  s.platform = :ios
  s.source_files = 'Reachability.h', 'Reachability.m'
  s.requires_arc = true
end