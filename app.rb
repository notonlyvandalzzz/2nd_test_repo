require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'sinatra/activerecord'

set :database, "sqlite3:lepranew2.db"

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

  # 365  git add Rakefile     - 2) создаем файл 
  # 366  git commit -M "Rakefile add"
  # 367  git commit -m "Rakefile add"
  # 368  git push
  # 369  ls -las
  # 370  rake -T
  # 371  tux
  # 372  rake db:create_migration NAME=create_clients - 3) создаем файл миграции
  # 373  cat db/migrate/20160822232920_create_clients.rb
  # 374  git status
  # 375  git add db/migrate/20160822232920_create_clients.rb
  # 376  git commit -m "Migration create"
  # 377  git push
  # 378  git pull  - 4) правим и заливаем его
  # 379  rake db:migrate 5) проводим миграцию

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before do
  # @newposts = Posts.left_outer_joins(:comments).distinct.select('posts.*, ifnull(count(comments.post_id), 0) as commnum').group('posts.id')
  @newposts = Post.order "created_at DESC"
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

configure do
  enable :sessions
  # get_db
  # @db.execute 'CREATE TABLE IF NOT EXISTS Posts (
  # id INTEGER PRIMARY KEY AUTOINCREMENT,
  # created_date DATE,
  # posttext TEXT
  # )'
  # @db.execute 'CREATE TABLE IF NOT EXISTS Comms (
  # id INTEGER PRIMARY KEY AUTOINCREMENT,
  # pid INTEGER,
  # created_date DATE,
  # commtext TEXT
  # )'
end

get '/' do
  #@newposts = @db.execute 'select * from Posts order by id desc'
  # @newposts = @db.execute 'select Posts.id, Posts.posttext, Posts.author, Posts.created_date, ifnull(count(Comms.pid), 0) as commnum from Posts left join Comms on Posts.id = Comms.pid group by Posts.id order by Posts.id desc'
  erb :index
end

get '/login/form' do
  erb :login_form
end

get '/new' do
  erb :new
end

post '/new' do
  # @posttext = params[:posttext]
  # author = params[:author]
  # if @posttext.size <= 0 
  #   @error = "Post text can't be empty"
  #   return erb :new
  # end
  # @db.execute 'insert into Posts (posttext, author, created_date) values (?, ?, datetime())',[@posttext, author]
  # #erb "Your post: #{@posttext}"
  @p_new = Post.new params[:posts]
  if @p_new.save
    redirect to '/'
  else
    @error = "Error somewhere: " + @p_new.errors.full_messages.first
    erb :new
  end
end


post '/login/attempt' do
  if params['username'] == 'admin' && params['passwd'] == 'mypass'
    session[:identity] = params['username']
    where_user_came_from = session[:previous_url] || '/'
    redirect to where_user_came_from
  else
    @error = 'Wrong login/password pair'
    halt erb(:login_form)
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
  erb :secret_area
end

get '/comms/:id' do
    # post_id = params[:id]
    # @currpost = @db.execute 'select * from Posts where id=?', [post_id]
    # @allcomments = @db.execute 'select * from Comms where pid=? order by id desc', [post_id]
    @c_post = Posts.find(params[:id])
    @cmnts = @c_post.comments
    erb :comments
end

post '/comms/:id' do
    # post_id = params[:id]
    # commtext = params[:commtext]
    # author = params[:author]
    # @db.execute 'insert into Comms (pid, commtext, author, created_date) values (?, ?, ?, datetime())',[post_id, commtext, author]
    # redirect to "/comms/#{post_id}"
    @com_new = Comment.new params[:comments]
    if @com_new.save
    redirect to '/'
  else
    @error = "Error somewhere: " + @com_new.errors.full_messages.first
    erb :new
  end
end