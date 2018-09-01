#
# Be sure to run `pod lib lint JSBFilesystem.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JSBFilesystem'
  s.version          = '0.8.3'
  s.summary          = 'Filesystem change notifications.'

  s.description      = <<-DESC
A small library that makes it easy to display data that exists as files on the disk of the local device. The library also makes it easy monitor additions, deletions, and modifications to the files so you can keep TableViews, CollectionViews, or any user interface up-to-date. This library uses NSFilePresenter for notifications from the operating system when files change and then uses IGListKit to diff the old and new contents.
                       DESC

  s.homepage         = 'https://github.com/jeffreybergier/JSBFilesystem'
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author           = { 'jeffreybergier' => 'jeffburg@jeffburg.com' }
  s.source           = { :git => 'https://github.com/jeffreybergier/JSBFilesystem.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'

  s.source_files = 'JSBFilesystem/JSBFilesystem_shared/**/*'
  s.public_header_files = 'JSBFilesystem/JSBFilesystem_shared/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'IGListKit', '~> 3.4.0'
end
