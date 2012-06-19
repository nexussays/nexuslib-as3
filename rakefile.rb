require 'rubygems'
require 'bundler/setup'
require 'version/version_task'
require 'version'

require './build/lib/asrake'
#require 'C:\Users\nexus\Development\Projects\Personal\ASRake\lib\asrake.rb'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#############################################
# Tasks
#############################################

task :default => :build

desc "Build all projects"
task :build => [ "reflection:build" ]

desc "Package all projects"
task :package => [ "reflection:package" ]

desc "Clean all projects"
task :clean => [ "reflection:clean" ]

desc "Clobber all projects"
task :clobber => [ "reflection:clobber" ]

namespace :reflection do

	root = "projects/reflection"
	proj = "nexuslib.reflection"
	version_file = "#{root}/VERSION"
	version = "#{Version.current(version_file) || '0.0.0'}"
	bin = "#{root}/bin"
	swc = "#{bin}/#{proj}.swc"

	desc "Build nexuslib.reflection"
	build_task = ASRake::SWC.new :build do |build|
		build.target_player = 11.0
		build.source_path << "#{root}/src"
		build.output = swc
		build.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
		#build.dump_config = "#{root}/src/compc_config.xml"
	end

	desc "Package the project into a zip"
	ASRake::Package.new :package => :build do |package|
		package.output = "#{bin}/#{proj}-#{version}.zip"
		package.files = {
			"license.txt" => "LICENSE",
			"#{proj}-#{version}.swc" => swc
		}
	end

	file version_file do
		Rake::Task["version:create"].invoke()
	end

	Rake::VersionTask.new do |task|
		task.filename = version_file
	end

	desc "Remove package results & temporary build artifacts"
	task :clean do
		FileList.new(build_task.output_dir/"*").exclude(swc).each { |f| rm_r f rescue nil }
	end

	desc "Remove all build & package results"
	task :clobber => [:clean] do
		FileList.new(swc).each { |f| rm_r f rescue nil }
	end

end