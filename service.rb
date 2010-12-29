require 'rubygems'
require 'active_record'
require 'sinatra'
require 'haml'

# models
require './models/user.rb'

# setting up the environment
env_index = ARGV.index('-e')
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV['SINATRA_ENV'] || 'development'
databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])

set :haml, :escape_html => true
set :show_exceptions, false

get '/users' do
  @users = User.find
  haml 'users/list'.to_sym
end

get '/users/add' do
  haml 'users/add'.to_sym
end

get '/users/:name' do
  user = User.find_by_name(params[:name])
  haml 'users/profile'.to_sym
end

