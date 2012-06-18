require 'rubygems'
require 'bundler/setup'
require 'zip/zip'
require 'version/version_task'
require 'version'

$: << './build/lib'
require 'asrake'

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
	bin = "#{root}/bin"
	swc = "#{bin}/#{proj}.swc"
	zip = "#{bin}/#{proj}-#{Version.current(version_file) || '0.0.0'}.zip"

	desc "Build nexuslib.reflection"
	build_task = ASRake::SWC.new :build do |build|
		build.target_player = 11.0
		build.source_path << "#{root}/src"
		build.output = swc
		build.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
	end

	desc "Package the project into a zip"
	task :package => zip

	file version_file do
		Rake::Task["version:create"].execute
	end

	file zip => :build do
		rm_r zip rescue nil

		Zip::ZipFile.open(zip, Zip::ZipFile::CREATE) do |file|
			file.add("license.txt", "LICENSE")
			file.add(build_task.output_file, swc)
		end

		puts "zip #{zip}"
	end

	Rake::VersionTask.new do |task|
		task.filename = version_file
	end

	desc "Remove package results & temporary build artifacts"
	task :clean do
		list = FileList.new(File.join(build_task.output_dir, "*"))
		list.exclude(swc)
		list.each { |f| rm_r f rescue nil }
	end

	desc "Remove all build & package results"
	task :clobber => [:clean] do
		list = FileList.new(swc)
		list.each { |fn| rm_r fn rescue nil }
	end

end