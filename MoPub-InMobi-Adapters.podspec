Pod::Spec.new do |s|
  s.name = "MoPub-InMobi-Adapters"
  s.module_name = "MoPub_InMobi_Adapters"
  s.version = "2.0.1"
  s.summary = "MoPub adapter for InMobi network"
  s.homepage = "https://github.com/ladeiko/MoPub-InMobi-Adapters"
  s.license = { :type => 'CUSTOM', :file => 'LICENSE' }
  s.author = { "Siarhei Ladzeika" => "sergey.ladeiko@gmail.com",
               "Vineet Srivastava" => "",
               "Ankit Pandey" => "ankitpandey.ap273@gmail.com",
               "Iti Agrawal" => "",
               "Niranjan Agrawal" => "" }
  s.source = { :git => "https://github.com/ladeiko/MoPub-InMobi-Adapters.git", :tag => s.version }
  s.swift_versions = '4.0', '4.2', '5.0', '5.1', '5.2', '5.3', '5.4'
  s.platform = :ios, "11.0"
  s.requires_arc = true
  s.static_framework = true
  s.source_files = "Source/*.{m,h}"
  s.frameworks = "Foundation"
  s.dependency "InMobiSDK"
  s.dependency "mopub-ios-sdk", ">= 5.16.0"
end
