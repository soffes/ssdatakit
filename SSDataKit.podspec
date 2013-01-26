Pod::Spec.new do |s|
  s.name         = "SSDataKit"
  s.version      = "0.1"
  s.summary      = "Eliminate your Core Data boilerplate code."
  s.homepage     = "https://github.com/soffes/ssdatakit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Sam Soffes" => "sam@soff.es" }
  s.source       = { :git => "https://github.com/rdougan/ssdatakit.git", :commit => '70b0809a00' }
  s.platform     = :ios
  s.source_files = 'SSDataKit/*.{h,m}'
  s.framework  = 'CoreData'
  s.requires_arc = true
end
