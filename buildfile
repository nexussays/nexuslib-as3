require "buildr/as3"

define "nexuslib" do

	compile.using :compc,
		:flexsdk => FlexSDK.new("4.5.1.21328"),

end