#
# Sinatra Streaming example (EventSource)
#
# Start server:
#  ruby app_streaming.rb
#
# Port 4567
#
#
# Start base browser [base]:
# http://localhost:4567
#
#
# Start client-reader browser(s):
# [1] http://localhost:4567/reader
# [2] http://localhost:4567/reader
# ...
#
# Make step on [base] browser - click on button [Step]:
# all "readers" ([1], [2] ...) - have to be refreshed too
#
# 
# Make 200 life-steps by locate base browser on
# http://localhost:4567/loop
#
# all "readers" ([1], [2] ...) - show Game of Life
#
#
#
# web application
#
require 'rubygems'
require 'sinatra'
require 'lib/game_life'

set :server, 'thin'
connections = []


INIT_GENERATION = \
"                              \n" +
"                              \n" +
"                *             \n" +
"    ***         *             \n" +
"    *  *  *  *  ***   *  *    \n" +
"    ***   *  *  *  *  *  *    \n" +
"    *  *  *  *  *  *  *  *    \n" +
"    *  *   **   ***    ***    \n" +
"                         *    \n" +
"                      ***     \n" +
"                              \n"

get '/' do
  game = GameLife.new :empty_cell=>' ', :life_cell=>'*', :map=>INIT_GENERATION
  @screen = game.screen
  erb :index
end

post '/' do
  game = GameLife.new :empty_cell=>' ', :life_cell=>'*', :map=>params[:g]
  game.do_step
  @screen = game.screen
  
  # notify readers
  connections.each { |out| out << "data: #{@screen.gsub("\n", 'NL')}\n\n" }

  erb :index
end

get '/loop' do

  game = GameLife.new :empty_cell=>' ', :life_cell=>'*', :map=>INIT_GENERATION
  200.times do
    @screen = game.screen
    # notify readers
    connections.each { |out| out << "data: #{@screen.gsub("\n", 'NL')}\n\n" }
    game.do_step
  end

  erb :index
end


get '/stream', :provides => 'text/event-stream' do
  stream :keep_open do |out|
    connections << out
    out.callback { connections.delete(out) }
  end
end

get '/reader' do
  erb :reader, :layout=>:reader_layout
end


__END__

@@ layout
<html>
  <head>
  <title>John Horton Conway - Game of Life</title>
  </head>
  <body>
    <%= yield %>
  <br>
  <a href="http://ruby-game-life.cloudfoundry.com">index</a> |
  <a href="https://github.com/nemilya/ruby-game-life">github</a> |
  <a href="http://en.wikipedia.org/wiki/Conway's_Game_of_Life">wikipedia</a>
  ||
  <a target="blank" href="/reader">reader</a>
  
  </body>
</html>

@@ index
  <form action="/" method="post">
  <pre><%= @screen %></pre>
  <input type="hidden" name="g" value="<%= @screen %>">
  <input type="submit" value="Step">
  </form>

@@ reader_layout
<html>
  <head> 
    <title>Reader</title> 
    <meta charset="utf-8" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
  </head> 
  <body><%= yield %></body>
</html>

@@ reader
<pre id='chat'></pre>

<script>
  // reading
  var es = new EventSource('/stream');
  es.onmessage = function(e) { $('#chat').text(e.data.replace(/NL/g, "\n" )) };
</script>