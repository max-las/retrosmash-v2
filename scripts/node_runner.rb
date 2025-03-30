require "node-runner"

def run_js(filepath, method, *args)
  runner = NodeRunner.new(
    <<~JS
      import { #{method} } from '#{File.expand_path(filepath)}';
    JS
  )

  runner.public_send(method, *args)
end

puts run_js(
  "frontend/javascript/shared_components/gameCard.js",
  :gameCard,
  { title: 'Michel', consoleSlug: 'n64', slug: 'michel', players: 2 }
)
