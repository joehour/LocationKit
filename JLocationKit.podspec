Pod::Spec.new do |s|
s.name = "JLocationKit"
s.version = "1.0.3"
s.license = "MIT"
s.summary = "An easy way to get the device's current location and geographical region monitoring on iOS(swift)."
s.homepage = "https://github.com/joehour/LocationKit"
s.authors = { "joe" => "joemail168@gmail.com" }
s.source = { :git => "https://github.com/joehour/LocationKit.git", :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = "8.0"
s.source_files = "LocationKit/*.{swift}"
end
