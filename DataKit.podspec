Pod::Spec.new do |spec|
  spec.name         = 'DataKit'
  spec.version      = '1.0.0'
  spec.summary      = "Core Data's best friend."
  spec.homepage     = 'https://github.com/soffes/DataKit'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Sam Soffes' => 'sam@soff.es' }
  spec.source       = { :git => 'https://github.com/soffes/DataKit.git', :tag => "v#{spec.version}" }
  spec.framework  = 'CoreData'
  spec.requires_arc = true

  spec.dependency 'SAMCategories', '>= 0.4.1'

  spec.ios.deployment_target = '6.0'
  spec.ios.source_files = 'DataKit/*.{h,m}'

  spec.osx.deployment_target = '10.8'
  spec.osx.source_files = %w{DataKit/DataKit.h DataKit/NSManagedObjectContext+DKTAdditions.* DataKit/DKTManagedObject.* DataKit/DKTRemoteManagedObject.*}
end
