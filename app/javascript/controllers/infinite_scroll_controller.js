import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "sentinel", "status"]
  static values = {
    url: String,
    page: { type: Number, default: 1 },
    hasMore: { type: Boolean, default: false }
  }

  connect() {
    if (!this.hasSentinelTarget || !this.hasMoreValue) return

    this.loading = false
    this.observer = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) this.load()
    }, { rootMargin: "240px" })

    this.observer.observe(this.sentinelTarget)
  }

  disconnect() {
    this.observer?.disconnect()
  }

  async load() {
    if (this.loading || !this.hasMoreValue || !this.hasListTarget) return

    this.loading = true
    this.element.setAttribute("aria-busy", "true")
    this.setStatus("Загрузка")

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("page", String(this.pageValue + 1))

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (!response.ok) {
        this.setStatus("Не удалось загрузить")
        return
      }

      const html = await response.text()
      if (html.includes('class="masthead"')) {
        this.setStatus("Не удалось загрузить")
        return
      }

      if (html.trim()) this.listTarget.insertAdjacentHTML("beforeend", html)

      this.pageValue += 1
      this.hasMoreValue = response.headers.get("X-Has-More") === "1"
      this.setStatus("")

      if (!this.hasMoreValue) {
        this.observer?.disconnect()
        this.sentinelTarget.remove()
        return
      }
    } catch {
      this.setStatus("Не удалось загрузить")
      return
    } finally {
      this.loading = false
      this.element.removeAttribute("aria-busy")
    }

    if (this.sentinelInView()) this.load()
  }

  sentinelInView() {
    if (!this.hasSentinelTarget) return false

    const rect = this.sentinelTarget.getBoundingClientRect()
    return rect.top <= window.innerHeight + 240
  }

  setStatus(text) {
    if (!this.hasStatusTarget) return

    this.statusTarget.hidden = text.length === 0
    this.statusTarget.textContent = text
  }
}
