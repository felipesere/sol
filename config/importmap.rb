# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "chart.js" # @4.6.1
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4
# jspm split Chart.js into two files; `bin/importmap pin` only downloads the first.
# vendor/javascript/chart-chunk.js is the second, and chart.js.js imports it as "chart.js/chunk".
# If you re-download Chart.js, repeat that (see README).
pin "chart.js/chunk", to: "chart-chunk.js"
