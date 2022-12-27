Pod::Spec.new do |s|
  s.name             = 'SkeletonableView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SkeletonableView.'

  s.homepage         = 'https://github.com/freddiebo/SkeletonableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Quick Bird' => 'freddiebo@yandex.ru' }
  s.source           = { :git => 'https://github.com/freddiebo/SkeletonableVie.git', :tag => s.version.to_s }
      
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/SkeletonableView/**/*'
end
