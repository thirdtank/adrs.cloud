require "sinatra/base"

class AdrApp < Sinatra::Base
  get "/" do
    "Hello World!"
  end
end
