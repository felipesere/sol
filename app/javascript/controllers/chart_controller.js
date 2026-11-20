import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

const MIN = 60000
const HOUR = 60 * MIN

const cssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim()
const clock = (date) => date.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" })

// Draws the fever zone, the 38 °C line and the divider above the dose lanes.
const feverPlugin = {
  id: "fever",
  beforeDatasetsDraw(chart) {
    const { chartArea: area, scales: { y }, ctx } = chart
    const y38 = y.getPixelForValue(38)
    const yTop = y.getPixelForValue(40)
    ctx.save()
    ctx.fillStyle = cssVar("--fever-band")
    ctx.fillRect(area.left, yTop, area.right - area.left, y38 - yTop)
    ctx.strokeStyle = cssVar("--crit")
    ctx.lineWidth = 1
    ctx.setLineDash([5, 4])
    ctx.beginPath(); ctx.moveTo(area.left, y38); ctx.lineTo(area.right, y38); ctx.stroke()
    ctx.setLineDash([])
    ctx.fillStyle = cssVar("--crit")
    ctx.font = "600 11px Figtree, sans-serif"
    ctx.textAlign = "right"
    ctx.fillText("Fever 38.0", area.right - 4, y38 - 5)
    const lane = y.getPixelForValue(35.95)
    ctx.strokeStyle = cssVar("--line")
    ctx.beginPath(); ctx.moveTo(area.left, lane); ctx.lineTo(area.right, lane); ctx.stroke()
    ctx.restore()
  }
}

// Draws a full-height line through every dose so its effect on the temperature is easy to see.
const doseLinesPlugin = {
  id: "doseLines",
  beforeDatasetsDraw(chart) {
    const { chartArea: area, scales: { x }, ctx } = chart
    ctx.save()
    ctx.lineWidth = 1.5
    ctx.globalAlpha = 0.45
    chart.data.datasets.filter((set) => set.doseLines).forEach((set) => {
      ctx.strokeStyle = set.backgroundColor
      set.data.forEach((dose) => {
        const px = x.getPixelForValue(dose.x)
        if (px < area.left || px > area.right) return
        ctx.beginPath(); ctx.moveTo(px, area.top); ctx.lineTo(px, area.bottom); ctx.stroke()
      })
    })
    ctx.restore()
  }
}

export default class extends Controller {
  static targets = ["canvas"]
  static values = { data: Object }

  connect() {
    this.draw()
    this.scheme = window.matchMedia("(prefers-color-scheme: dark)")
    this.redraw = () => this.draw()
    this.scheme.addEventListener("change", this.redraw)
  }

  disconnect() {
    this.scheme?.removeEventListener("change", this.redraw)
    this.chart?.destroy()
  }

  draw() {
    this.chart?.destroy()
    const { hours, temperatures, doses, medicines } = this.dataValue
    const now = Date.now()
    const minX = -hours * 60
    const muted = cssVar("--muted"), line = cssVar("--line"), surface = cssVar("--surface")
    const LANE_STEP = 0.35
    const laneFor = (index) => 35.75 - index * LANE_STEP
    // Grow the axis downwards so every medicine lane stays inside the plot area.
    const yMin = Math.min(35, laneFor(Math.max(medicines.length, 1) - 1) - LANE_STEP * 0.75)

    const temps = temperatures.map((t) => ({ x: t.x, y: t.y, at: new Date(t.at), by: t.by, kind: "temperature" }))
    const datasets = [{
      label: "Temperature", data: temps, order: 1,
      borderColor: cssVar("--c-temp"), backgroundColor: cssVar("--c-temp"), borderWidth: 2.5, tension: 0.25,
      pointRadius: temps.map((_, i) => (i === temps.length - 1 ? 6 : 3.5)),
      pointBorderColor: surface, pointBorderWidth: 2, pointHoverRadius: 7, hitRadius: 14
    }]

    medicines.forEach((medicine, index) => {
      datasets.push({
        label: medicine.name, order: 2, doseLines: true, showLine: false, pointStyle: medicine.shape, radius: 7, hoverRadius: 9, hitRadius: 16,
        backgroundColor: cssVar(medicine.color), borderColor: surface, borderWidth: 1.5,
        data: doses.filter((d) => d.medicine === medicine.id).map((d) => ({
          x: d.x, y: laneFor(index), at: new Date(d.at), by: d.by, amount: d.amount, unit: d.unit, kind: "dose"
        }))
      })
    })

    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: { datasets },
      plugins: [feverPlugin, doseLinesPlugin],
      options: {
        responsive: true, maintainAspectRatio: false, animation: false,
        interaction: { mode: "nearest", intersect: true },
        layout: { padding: { right: 8, top: 4 } },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: cssVar("--ink"), titleColor: cssVar("--bg"), bodyColor: cssVar("--bg"),
            padding: 10, cornerRadius: 10, displayColors: false,
            callbacks: {
              title: (items) => clock(items[0].raw.at),
              label: (item) => {
                const r = item.raw
                return r.kind === "temperature" ? `${r.y.toFixed(1)} °C · ${r.by}` : `${item.dataset.label} ${r.unit === "count" ? `${r.amount}×` : `${r.amount} ${r.unit}`} · ${r.by}`
              }
            }
          }
        },
        scales: {
          x: {
            type: "linear", min: minX, max: 0,
            grid: { color: line, drawTicks: false }, border: { color: line },
            ticks: {
              color: muted, autoSkip: false, maxRotation: 0, padding: 6, font: { size: 11 },
              callback: (v) => {
                const date = new Date(now + v * MIN)
                return date.getHours() === 0 && date.getMinutes() === 0 ? date.toLocaleDateString("en-GB", { weekday: "short" }) : clock(date)
              }
            },
            // Ticks on the clock (every 3 or 6 hours), not relative to now.
            afterBuildTicks: (axis) => {
              const step = (hours > 24 ? 6 : 3) * HOUR
              const offset = new Date(now).getTimezoneOffset() * MIN
              const ticks = []
              for (let t = Math.ceil((now + minX * MIN - offset) / step) * step + offset; t <= now; t += step) {
                ticks.push({ value: (t - now) / MIN })
              }
              axis.ticks = ticks
            }
          },
          y: {
            min: yMin, max: 40, grid: { color: line, drawTicks: false }, border: { display: false },
            ticks: { color: muted, stepSize: 1, padding: 6, font: { size: 11 }, callback: (v) => (v >= 36 ? `${v.toFixed(0)}°` : "") },
            afterBuildTicks: (axis) => { axis.ticks = [36, 37, 38, 39, 40].map((value) => ({ value })) }
          }
        }
      }
    })
  }
}
