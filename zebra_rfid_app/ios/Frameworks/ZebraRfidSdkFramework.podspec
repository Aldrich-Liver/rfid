Pod::Spec.new do |s|
  s.name             = 'ZebraRfidSdkFramework'
  s.version          = '1.1.94'
  s.summary          = 'Zebra RFID SDK for iOS'
  s.homepage         = 'https://www.zebra.com'
  s.license          = { :type => 'Commercial' }
  s.author           = { 'Zebra Technologies' => 'support@zebra.com' }
  s.platform         = :ios, '12.0'
  s.source           = { :path => '.' }
  s.vendored_frameworks = 'ZebraRfidSdkFramework.xcframework'
end
