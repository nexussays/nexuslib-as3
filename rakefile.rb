gem 'asrake', ">=0.11"
gem 'right_aws', ">=3.0"
require 'asrake'
require 'rake/clean'
require 'right_aws'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#
# Setup
#

PROJECTS = %w{reflection enigma mercury}

doc = ASRake::Asdoc.new
doc.output = "bin/doc"
doc.window_title = "\"nexuslib API Documentation\""
CLEAN.include(doc.output)

doc_footer = []

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
	doc.footer = doc_footer.join("/")
	doc.execute
end

multitask :deploy
desc "Deploy"
task :deploy, [:key, :secret_key] => [:package, :doc] do |t, args|
	aws_secret_key = args[:secret_key]
	aws_key = args[:key]
	
	fail "Must provide AWS keys" if aws_secret_key == nil || aws_key == nil

	s3 = RightAws::S3.new(aws_key, aws_secret_key)
	docs = s3.bucket('docs.nexussays.com')
	#docs.delete_folder('nexuslib')
	Dir.chdir(doc.output) do
		Dir.glob("**/*") do |file|
			if !File.directory?(file)
				key = File.join('nexuslib', file)
				puts key
				docs.put(key, File.open(file), {}, 'public-read')
			end
		end
	end
end

#
# Generate Project Tasks
#

PROJECTS.each do |project|
	project = project.to_sym

	# default build task to namespace name
	desc "Build nexuslib.#{project}"
	task project => "#{project}:build"
	
	# add to root tasks
	task :build_all => "#{project}:build"
	task :package => "#{project}:package"

	namespace project do

		root = "projects/#{project}"
		proj = "nexuslib.#{project}"
		version_file = "#{root}/VERSION"
		version = "#{Version.current(version_file) || '0.0.0'}"
		# add version info to doc_footer of docs
		doc_footer << "#{proj}-#{version}"

		build = ASRake::CompcArguments.new
		build.target_player = 11.0
		build.output = "bin/#{proj}.swc"
		build.debug = true
		build.source_path << "#{root}/src"
		build.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
		build.include_asdoc = true
		#build.dump_config = "#{root}/src/compc_config.xml"
		CLEAN.include(build.output)

		ASRake::CompcTask.new :build, build

		# add paths to asdoc task
		doc.add build

		desc "Package #{proj}-#{version}.zip"
		package = ASRake::PackageTask.new :package => :build do |package|
			package.output = "#{build.output_dir}/#{proj}-#{version}.zip"
			package.files = {
				"license.txt" => "LICENSE",
				"#{proj}-#{version}.swc" => build.output
			}
		end
		CLOBBER.include(package.output)

		ASRake::VersionTask.new :version, version_file

	end

end