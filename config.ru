require "bundler"

Bundler.require
$LOAD_PATH << File.join(__dir__,"lib")
require_relative "app/boot"

run AdrApp
