# web application
require 'rubygems'
require 'sinatra'
require 'lib/game_life'

INIT_GENERATION = \
".......\n" +
".......\n" +
".***...\n" +
"...***.\n" +
".......\n"

get '/' do
  game = GameLife.new :empty_cell=>'.', :life_cell=>'*'
  game.first_generation = INIT_GENERATION
  @screen = game.screen
  erb :index
end

post '/' do
  game = GameLife.new :empty_cell=>'.', :life_cell=>'*'
  game.first_generation = params[:g]
  game.do_step
  @screen = game.screen
  erb :index
end

__END__

@@ layout
<html>
  <head>
  <title>Life</title>
  </head>
  <body>
    <%= yield %>
  </body>
</html>

@@ index
  <form action="/" method="post">
  <pre><%= @screen %></pre>
  <input type="hidden" name="g" value="<%= @screen %>">
  <input type="submit" value="Step">
  </form>