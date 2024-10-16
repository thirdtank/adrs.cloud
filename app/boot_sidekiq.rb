require "bundler"

Bundler.require(:default)
$LOAD_PATH << File.join(__dir__,"..","lib")
require_relative "boot"
