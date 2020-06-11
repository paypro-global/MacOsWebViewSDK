Pod::Spec.new do |spec|
  spec.name                  = "PPGAppKit" 
  spec.authors		     = "PayPro Global, Inc" 
  spec.version               = "0.0.1"
  spec.summary               = "Test"
  spec.description           = "Test123"
  spec.homepage              = "https://github.com"
  spec.platform              = :osx
  spec.osx.deployment_target = "10.13"
  spec.source                = { :git => "https://github.com"}
  spec.source_files          = 'Sources/**/*.{h,swift}'
  spec.swift_version 	     = '5.0'
end
