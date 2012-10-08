gem 'asrake', "~>1.0"
gem 'right_aws', ">=3.0"
require 'asrake'
require 'rake/clean'
require 'right_aws'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#
# Setup
#

PROJECTS = %w{reflection enigma mercury}

asdoc = ASRake::Asdoc.new "bin/doc"
asdoc.window_title = "\"nexuslib API Documentation\""
CLEAN.include(asdoc.output)

asdoc_footer = []

#
# Tasks
#

task :default do
	system "rake --tasks"
end

desc "Build all projects"
multitask :build_all

desc "Package all projects"
multitask :package_all

desc "Generate docs for all projects"
task :doc do
	asdoc.footer = asdoc_footer.join("/")
	asdoc.execute
end

multitask :deploy

desc "Deploy"
task :deploy, [:key, :secret_key] => [:package_all, :doc] do |t, args|
	s3 = RightAws::S3.new(args[:key], args[:secret_key])
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

	# default build task to namespace name
	desc "Build nexuslib.#{name}"
	task name => build

	namespace name do
		desc "Package #{project}-#{version}.zip"
		task :package => package

		ASRake::VersionTask.new :version, version_file
	end
	
	# add to root tasks
	task :build_all => build
	task :package_all => package

end