gem 'asrake', ">=1.0"
gem 'right_aws', ">=3.0"
require 'asrake'
require 'rake/clean'
require 'right_aws'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#
# Setup
#

PROJECTS = %w{reflection enigma mercury}

asdoc = ASRake::Asdoc.new
asdoc.output = "bin/doc"
asdoc.window_title = "\"nexuslib API Documentation\""
CLEAN.include(asdoc.output)

asdoc_footer = []

#
# Tasks
#

task :default => :build_all

desc "Build all projects"
multitask :build_all

desc "Package all projects"
task :package

desc "Generate docs for all projects"
task :doc do
	asdoc.footer = asdoc_footer.join("/")
	asdoc.execute
end

multitask :deploy

desc "Deploy"
task :deploy, [:key, :secret_key] => [:package, :doc] do |t, args|
	aws_secret_key = args[:secret_key].chomp
	aws_key = args[:key].chomp
	
	fail "Must provide AWS keys" if aws_secret_key == nil || aws_key == nil

	s3 = RightAws::S3.new(aws_key, aws_secret_key)
	docs = s3.bucket('docs.nexussays.com')
	#docs.delete_folder('nexuslib')
	Dir.chdir(asdoc.output) do
		Dir.glob("**/*") do |file|
			if !File.directory?(file)
				key = File.join('nexuslib', file)
				puts key
				# TODO: Only put if source is newer than destination
				docs.put(key, File.open(file), {}, 'public-read')
			end
		end
	end
end

#
# Generate Project Tasks
#

PROJECTS.each do |name|

	name = name.to_sym
	root = "projects/#{name}"
	project = "nexuslib.#{name}"
	version_file = "#{root}/VERSION"
	version = "#{Version.current(version_file) || '0.0.0'}"

	# create tasks to build the swc
	build = ASRake::Compc.new "bin/#{project}.swc"
	build.target_player = 11.0
	build.debug = true
	build.source_path << "#{root}/src"
	build.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
	build.include_asdoc = true
	#build.dump_config = "#{root}/src/compc_config.xml"
	CLEAN.include(build.output)

	# create task to package into a zip file
	package = ASRake::Package.new "#{build.output_dir}/#{project}-#{version}.zip"
	package.files = {
		"license.txt" => "LICENSE",
		"#{project}-#{version}.swc" => build.output
	}
	CLOBBER.include(package.output)

	# add to asdoc
	asdoc.add(build)
	# add version info to asdoc_footer of docs
	asdoc_footer << "#{project}-#{version}"

	namespace name do

		desc "Package #{project}-#{version}.zip"
		task :package => [build, package]

		ASRake::VersionTask.new :version, version_file

	end

	# default build task to namespace name
	desc "Build nexuslib.#{name}"
	task name => build
	
	# add to root tasks
	task :build_all => build
	task :package => "#{name}:package"

end