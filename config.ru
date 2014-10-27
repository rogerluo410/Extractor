# config.ru
BOOT_PATH = File.expand_path('../http.rb',  __FILE__)
require BOOT_PATH

class FiberSpawn
  def initialize(app)
    @app = app
  end

  def call(env)
    fib = Fiber.new do
      res = @app.call(env)
      env['async.callback'].call(res)
    end
    EM.next_tick{ fib.resume }
    throw :async
  end
end

use FiberSpawn
run Http
