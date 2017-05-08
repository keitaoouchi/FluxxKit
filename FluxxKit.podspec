Pod::Spec.new do |s|
  s.name          = "FluxxKit"
  s.version       = "1.0.0"
  s.summary       = "Unidirectional data flow for Reactive programming."
  s.homepage      = "https://github.com/keitaoouchi/FluxxKit"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "keitaoouchi" => "keita.oouchi@gmail.com" }
  s.source        = { :git => "https://github.com/keitaoouchi/FluxxKit.git", :tag => "#{s.version}" }
  s.source_files  = "FluxxKit/*.swift"
  s.frameworks    = "Foundation"
  s.ios.deployment_target = "8.0"
  s.pod_target_xcconfig = {
    "SWIFT_VERSION": "3.0"
  }
end
