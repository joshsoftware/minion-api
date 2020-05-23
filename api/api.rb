require 'sinatra'
require 'pp'

get '/' do
  @now = Time.now.strftime("I was first rendered on %D at %I:%M:%S%p %Z (UTC %z)")
  pp @now
end
