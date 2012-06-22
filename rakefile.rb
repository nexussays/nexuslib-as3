require 'rubygems'
require 'bundler/setup'

require './build/lib/asrake'
#require 'C:\Users\nexus\Development\Projects\Personal\ASRake\lib\asrake.rb'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#############################################
# Tasks
#############################################

task :default => :build

desc "Build all projects"
task :build

desc "Package all projects"
task :package

desc "Clean all projects"
task :clean

desc "Clobber all projects"
task :clobber

%w{reflection}.each do |project|
	project = project.to_sym

	namespace project do

		root = "projects/#{project}"
		proj = "nexuslib.#{project}"
		version_file = "#{root}/VERSION"
		version = "#{Version.current(version_file) || '0.0.0'}"
		bin = "#{root}/bin"
		swc = "#{bin}/#{proj}.swc"

		desc "Build nexuslib.#{project}"
		ASRake::SWCTask.new :build do |build|
			build.target_player = 11.0
			build.output = swc
			build.debug = true
			build.source_path << "#{root}/src"
			build.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
			#build.dump_config = "#{root}/src/compc_config.xml"
		end

		desc "Package the project into a zip"
		ASRake::PackageTask.new :package => :build do |package|
			package.output = "#{bin}/#{proj}-#{version}.zip"
			package.files = {
				"license.txt" => "LICENSE",
				"#{proj}-#{version}.swc" => swc
			}
		end

		ASRake::VersionTask.new :version, version_file

		desc "Remove package results & temporary build artifacts"
		task :clean do
			FileList.new(File.join(bin, "*")).exclude(swc).each { |f| rm_r f rescue nil }
		end

		desc "Remove all build & package results"
		task :clobber => [:clean] do
			FileList.new(swc).each { |f| rm_r f rescue nil }
		end

	end

	#add to root tasks
	task :build => "#{project}:build"
	task :package => "#{project}:package"
	task :clean => "#{project}:clean"
	task :clobber => "#{project}:clobber"
end