#
# Be sure to run `pod lib lint JSBFilesystem.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JSBFilesystem'
  s.version          = '0.1.4'
  s.summary          = 'Filesystem change notifications.'

  s.description      = <<-DESC
JSBFilesystem are lightweight classes that clean up the syntax with accessing the filesystem. Every read and write call is coordinated with `NSFileCoordinator`. `NSFilePresenter` is used by `JSBObservedDirectory` to get notifications when anything in that directory changes. The changes are detected whether they come from in or out of your process. IGListKit is then used to create a Diff between the old contents and the new contents. If changes are detected a closure/block is called so your code can update its UI.
                       DESC

  s.homepage         = 'https://github.com/jeffreybergier/JSBFilesystem'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author           = { 'jeffreybergier' => 'jeffburg@jeffburg.com' }
  s.source           = { :git => 'https://github.com/jeffreybergier/JSBFilesystem.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/jeffburg'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11.0'

  s.source_files = 'JSBFilesystem/JSBFilesystem_shared/**/*'
  
  # s.resource_bundles = {
  #   'JSBFilesystem' => ['JSBFilesystem/Assets/*.png']
  # }

  s.public_header_files = 'JSBFilesystem/JSBFilesystem_shared/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'IGListKit', '~> 3.4.0'
end
