namespace :javascript do
  desc "Build the comments React island"
  task :build do
    system("npm", "run", "build:comments", exception: true)
  end
end

Rake::Task["assets:precompile"].enhance([ "javascript:build" ])
