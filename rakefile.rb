gem 'asrake', "~>0.14.0"
gem 'right_aws', ">=3.0"
require 'asrake'
require 'rake/clean'
require 'right_aws'

FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

#
# Setup
#

project_name = "nexuslib"
version = "#{Version.current || '0.0.0'}"

nexuslib = ASRake::Compc.new "bin/#{project_name}.swc"
nexuslib.target_player = 11.0
nexuslib.debug = false
nexuslib.source_path << "src"
nexuslib.statically_link_only_referenced_classes << "lib/blooddy_crypto_0.3.5/blooddy_crypto.swc"
nexuslib.include_asdoc = true
#nexuslib.dump_config = "compc_config.xml"
CLEAN.add(nexuslib)

# create task to package into a zip file
zip = ASRake::Package.new "#{nexuslib.output_dir}/#{project_name}-#{version}.zip"
zip.files = {
   "license.txt" => "LICENSE",
   "#{project_name}-#{version}.swc" => nexuslib.output
}
CLOBBER.add(zip.output)

asdoc = ASRake::Asdoc.new "bin/doc"
asdoc.window_title = "\"#{project_name} API Documentation\""
asdoc.footer = "#{project_name}-#{version}"
asdoc.add(nexuslib)
CLEAN.add(asdoc)

#
# Tasks
#

task :default do
   system "rake --tasks"
end

desc "Build #{project_name}"
task :build => nexuslib

desc "Package zip"
task :package => [:build, zip]

ASRake::VersionTask.new :version

desc "Generate docs"
task :doc => asdoc

desc "Deploy zip & docs to S3"
task :deploy, [:key, :secret_key] => [:package, :doc] do |t, args|
   s3 = RightAws::S3.new(args[:key], args[:secret_key])

   # documentation
   docs_bucket = s3.bucket('docs.nexussays.com')
   #docs_bucket.delete_folder('nexuslib')
   Dir.chdir(asdoc.output) do
      Dir.glob("**/*") do |file|
         if !File.directory?(file)
            key = File.join(project_name, file)
            puts "#{docs_bucket.name}/#{key}"
            # TODO: Only put if source is newer than destination
            docs_bucket.put(key, File.open(file), {}, 'public-read')
         end
      end
   end

   # zip
   pkg_bucket = s3.bucket('public.nexussays.com')
   key = File.join("code", project_name, zip.output_file)
   puts "#{pkg_bucket.name}/#{key}"
   pkg_bucket.put(key, File.open(zip.output), {}, 'public-read')
end
