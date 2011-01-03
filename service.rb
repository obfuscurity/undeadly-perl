require 'rubygems'
require 'active_record'
require 'sinatra'
require 'erubis'

# models
require "#{File.dirname(__FILE__)}/models/user.rb"
require "#{File.dirname(__FILE__)}/models/role.rb"
require "#{File.dirname(__FILE__)}/models/article.rb"

# setting up the environment
env_index = ARGV.index('-e')
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV['SINATRA_ENV'] || 'development'
databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])

# options
set :erubis, :escape_html => true
#set :show_exceptions, false

# user listing
get '/users' do
  @users = User.find(:all)
  erubis 'users/list'.to_sym
end

# user registration
get '/users/add' do
  erubis 'users/add'.to_sym
end

# user registration submission
post '/users/add' do
  role = Role.find_by_name('normal')
  user = User.create_unless_user_exists({
    :role_id => role.id,
    :username => params[:username],
    :password => params[:password1],
    :firstname => params[:firstname],
    :lastname => params[:lastname],
    :email => params[:email],
    :url => params[:url],
    :tz => params[:tz],
  })
  if user.nil?
    @error = 'Username or email already exists, please try again'
    erubis 'users/add'.to_sym
  else
    redirect '/users'
  end
end

# user profile
get '/users/:username' do
  @user = User.find_by_username(params[:username])
  if @user
    erubis 'users/detail'.to_sym
  else
    erubis 'errors/404'.to_sym
  end
end

# front page
get %r{^/(articles|stories)?$} do
  @articles = Article.find_by_status('active')
  if @articles
    erubis 'articles/detail'.to_sym
  else
    erubis 'articles/list'.to_sym
  end
end

# unknown
get '*' do
   erubis 'errors/404'.to_sym
end

