desc "drops you into a pry console"
task :console do
  require_relative(File.join('.', 'init'))
  Minion::Console.start # runs console
end

desc "starts the server"
task :start do
  exec("bundle exec puma -b tcp://0.0.0.0 -p 9001 --pidfile /tmp/puma.pid")
end

desc "see what TODOs remain in the code"
task :todo do
  exec('grep -Rin --include="*.rb" "TODO" *')
end
