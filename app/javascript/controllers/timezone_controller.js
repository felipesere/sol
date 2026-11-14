import { Controller } from "@hotwired/stimulus"

// Tells the server which timezone this browser is in, so times are entered and shown
// on the same clock as the phone. Runs once: after the cookie changes it reloads the page.
export default class extends Controller {
  connect() {
    const zone = Intl.DateTimeFormat().resolvedOptions().timeZone
    if (!zone || this.current() === zone) return

    document.cookie = `timezone=${encodeURIComponent(zone)}; path=/; max-age=31536000; samesite=lax`
    if (this.current() === zone) window.Turbo.visit(window.location.href, { action: "replace" })
  }

  current() {
    const match = document.cookie.match(/(?:^|; )timezone=([^;]*)/)
    return match && decodeURIComponent(match[1])
  }
}
