gem 'asrake', "~>0.13.2"
gem 'right_aws', ">=3.0"
require 'asrake'
require 'rake/clean'
require 'right_aws'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#
# Setup
#

version = "#{Version.current || '0.0.0'}"

compc = ASRake::Compc.new "bin/nexuslib.swc"
compc.target_player = 11.0
compc.debug = false
compc.source_path << "src"
compc.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
compc.include_asdoc = true
#compc.dump_config = "compc_config.xml"
CLEAN.add compc

# create task to package into a zip file
zip = ASRake::Package.new "#{compc.output_dir}/nexuslib-#{version}.zip"
zip.files = {
	"license.txt" => "LICENSE",
	"nexuslib-#{version}.swc" => compc.output
}
CLOBBER.add zip.output

asdoc = ASRake::Asdoc.new "bin/doc"
asdoc.window_title = "\"nexuslib API Documentation\""
asdoc.footer = "nexuslib-#{version}"
asdoc.add compc
CLEAN.add asdoc

#
# Tasks
#

task :default do
	system "rake --tasks"
end

desc "Build nexuslib"
task :build => compc

desc "Package zip"
task :package => [:build, zip]

ASRake::VersionTask.new :version

desc "Generate docs"
task :doc => asdoc

namespace :doc do
	desc "Deploy docs to S3"
	task :deploy, [:key, :secret_key] => [:doc] do |t, args|
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
end