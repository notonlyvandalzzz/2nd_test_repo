require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def get_db
  @db = SQLite3::Database.new 'lepra.db'
  @db.results_as_hash = true
  return @db
end



helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before do
  get_db
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
  get_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_date DATE,
  posttext TEXT
  )'
  @db.execute 'CREATE TABLE IF NOT EXISTS Comms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pid INTEGER,
  created_date DATE,
  commtext TEXT
  )'
end

get '/' do
  #@newposts = @db.execute 'select * from Posts order by id desc'
  @newposts = @db.execute 'select Posts.id, Posts.posttext, Posts.author, ifnull(count(Comms.pid), 0) as commnum from Posts left join Comms on Posts.id = Comms.pid group by Posts.id order by Posts.id desc'
  erb :index
end

get '/login/form' do
  erb :login_form
end

get '/new' do
  erb :new
end

post '/new' do
  @posttext = params[:posttext]
  if @posttext.size <= 0 
    @error = "Post text can't be empty"
    return erb :new
  end
  @db.execute 'insert into Posts (posttext, created_date) values (?, datetime())',[@posttext]
  #erb "Your post: #{@posttext}"
  redirect to '/'
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
    post_id = params[:id]
    @currpost = @db.execute 'select * from Posts where id=?', [post_id]
    @allcomments = @db.execute 'select * from Comms where pid=? order by id desc', [post_id]
    erb :comments
end

post '/comms/:id' do
    post_id = params[:id]
    commtext = params[:commtext]

    @db.execute 'insert into Comms (pid, commtext, created_date) values (?, ?, datetime())',[post_id, commtext]
    redirect to "/comms/#{post_id}"
end