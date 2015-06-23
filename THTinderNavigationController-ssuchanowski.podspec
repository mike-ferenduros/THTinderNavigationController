Pod::Spec.new do |s|
  s.name         = "THTinderNavigationController-ssuchanowski"
  s.version      = "1.1.1"
  s.summary      = "iOS navigation component based on Tinder app"
  s.description  = <<-DESC
                 iOS navigation component based on Tinder app. This is a fork of https://github.com/Tgy31 repository
                 DESC
  s.homepage     = "https://github.com/ssuchanowski/THTinderNavigationController"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "Sebastian Suchanowski" => "sebastian@synappse.pl", "Tanguy Hélesbeux" => "tanguy.helesbeux@gmail.com" }
  s.social_media_url   = "http://twitter.com/ssuchanowski"
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/ssuchanowski/THTinderNavigationController.git", :tag => s.version.to_s }
  s.source_files  = "THTinderNavigationController/**/*.{h,m}"
  s.requires_arc = true
end
