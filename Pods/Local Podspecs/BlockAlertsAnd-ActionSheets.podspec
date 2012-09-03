Pod::Spec.new do |s|
  s.name     = 'BlockAlertsAnd-ActionSheets'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'Beautifully done UIAlertView and UIActionSheet replacements'
  s.homepage = 'https://github.com/martinjuhasz/BlockAlertsAnd-ActionSheets.git'
  s.author   = { 'Gustavo Ambrozio' => '' }
  s.source   = { :git => 'https://github.com/martinjuhasz/BlockAlertsAnd-ActionSheets.git'}
  s.description = 'Beautifully done UIAlertView and UIActionSheet replacements'
  s.platform = :ios
  s.source_files = 'BlockAlertsDemo/BlockBackground.h', 
                    'BlockAlertsDemo/BlockBackground.m',
                    'BlockAlertsDemo/BlockActionSheet.h', 
                    'BlockAlertsDemo/BlockActionSheet.m', 
                    'BlockAlertsDemo/BlockAlertView.h', 
                    'BlockAlertsDemo/BlockAlertView.m', 
                    'BlockAlertsDemo/BlockTextPromptAlertView.h', 
                    'BlockAlertsDemo/BlockTextPromptAlertView.m', 
                    'BlockAlertsDemo/BlockTableAlertView.h',
                    'BlockAlertsDemo/BlockTableAlertView.m'
  s.resources = "BlockAlertsDemo/images/ActionSheet/*.png", "BlockAlertsDemo/images/AlertView/*.png"

end