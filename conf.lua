-- Configuration
function love.conf(t)
  t.title = 'Scrolling Shooter Tutorial'  -- the title of the window the game is in (string)
  t.version = "11.3"  -- the löve version this game was made for (string)
  t.window.width = 480  -- we want the game to be long and thin
  t.window.height = 800

  -- for windows debugging
  t.console = true
end
