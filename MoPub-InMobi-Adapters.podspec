Pod::Spec.new do |s|
    s.name                  = 'MoPub-InMobi-Adapters'
    s.module_name           = 'MoPub_InMobi_Adapters'
    s.version               = '1.0.0'
    s.summary               = 'MoPub adapter for InMobi network'
    s.homepage              = 'https://github.com/ladeiko/MoPub-InMobi-Adapters'
    s.license               = 'MIT'
    s.author                = { 'Siarhei Ladzeika' => 'sergey.ladeiko@gmail.com',
                                'Vineet Srivastava' => '', 
                                'Ankit Pandey' => 'ankitpandey.ap273@gmail.com',
                                'Iti Agrawal' => '',
                                'Niranjan Agrawal' => '' }
    s.source                = { :git => 'https://github.com/ladeiko/MoPub-InMobi-Adapters.git', :tag => s.version }
    s.platform              = :ios, '9.0'
    s.requires_arc          = true
    s.static_framework      = true
    s.source_files          = 'Source/*.{m,h}'
    s.frameworks            = 'Foundation'
    s.dependency            'InMobiSDK'
    s.dependency            'mopub-ios-sdk'
end
