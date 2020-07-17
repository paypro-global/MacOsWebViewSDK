Pod::Spec.new do |spec|
  spec.name                  = "PPGAppKit" 
  spec.authors		     = "PayPro Global, Inc" 
  spec.version               = "0.0.32"
  spec.summary               = "PPGAppKit is PayPro Global's SDK  which enables quick integration of our shopping expereince in a Mac App."
  spec.description           = "PayPro Global Inc offers the best shopping experience through a complex payment processing system which delivers secure transactions, versatility (multiple options to satisfy all customer preferences), user friendly experience (localized content, payment methods and currencies) and the highest degree of transaction fulfillment."
  spec.homepage              = "https://github.com/srinivas-codezyng/PayProGlobalStore"
  spec.platform              = :osx
  spec.osx.deployment_target = "10.13"
  spec.source                = { :git => "https://github.com/srinivas-codezyng/PayProGlobalStore"}
  spec.source_files          = 'Sources/**/*.{h,swift}'
  spec.frameworks             = 'PDFKit'
  spec.swift_version 	       = '5.0'
end
