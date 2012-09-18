gem 'asrake', ">=0.10"
require 'asrake'
require 'rake/clean'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#############################################
# Tasks
#############################################

task :default => :build

desc "Build all projects"
task :build

desc "Package all projects"
task :package

desc "Generate docs for all projects"
task :doc do
	@doc.execute
end
@doc = ASRake::Asdoc.new
@doc.output = "bin/doc/"

CLEAN.include(@doc.output)

%w{reflection enigma}.each do |project|
	project = project.to_sym

	namespace project do

		root = "projects/#{project}"
		proj = "nexuslib.#{project}"
		version_file = "#{root}/VERSION"
		version = "#{Version.current(version_file) || '0.0.0'}"

		desc "Build nexuslib.#{project}"
		build = ASRake::CompcTask.new :build do |compc|
			compc.target_player = 11.0
			compc.output = "bin/#{proj}.swc"
			compc.debug = true
			compc.source_path << "#{root}/src"
			compc.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
			compc.include_asdoc = true
			#compc.dump_config = "#{root}/src/compc_config.xml"
		end

		desc "Package #{proj}-#{version}.zip"
		package = ASRake::PackageTask.new :package => :build do |package|
			package.output = "#{build.output_dir}/#{proj}-#{version}.zip"
			package.files = {
				"license.txt" => "LICENSE",
				"#{proj}-#{version}.swc" => build.output
			}
		end

		ASRake::VersionTask.new :version, version_file

		# add paths to asdoc task
		@doc.source_path << build.source_path
		@doc.library_path << build.library_path
		@doc.library_path << build.include_libraries

		# clean
		CLEAN.include(build.output)
		CLOBBER.include(package.output)

	end

	#add to root tasks
	task :build => "#{project}:build"
	task :package => "#{project}:package"
end