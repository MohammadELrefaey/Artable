# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
project 'Artable.xcodeproj'
def shared_pods
  pod 'Firebase/Core'
	pod 'Firebase/Auth'
	pod 'Firebase/Database'
	pod 'Firebase/Firestore'
	pod 'Firebase/Storage'
  pod 'Firebase/Functions'
	pod 'Kingfisher'
  pod 'Alamofire'
  pod 'Stripe'

end

target 'Artable' do
  # Comment the next line if you don't want to use dynamic frameworks
  
  use_frameworks!
  
  shared_pods
	
end


target 'Artable-Admin' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Artable-Admin
  shared_pods
end
