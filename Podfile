# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def project_pods
  pod 'TesseractOCRiOS'
end

target 'CheckedItems' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CheckedItems
  project_pods
    
  target 'CheckedItemsTests' do
    inherit! :search_paths
    # Pods for testing
    project_pods
  end

  target 'CheckedItemsUITests' do
    inherit! :search_paths
    # Pods for testing
    project_pods
  end

end
