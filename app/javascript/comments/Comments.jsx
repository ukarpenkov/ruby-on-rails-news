import { useRef, useState } from "react"

function formatTime(value) {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return ""

  return date.toLocaleString("ru-RU", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  })
}

export function Comments({ comments, signedIn, createUrl, loginUrl, csrfToken }) {
  const [items, setItems] = useState(comments)
  const [body, setBody] = useState("")
  const [error, setError] = useState(null)
  const [sending, setSending] = useState(false)
  const sendingRef = useRef(false)

  async function onSubmit(event) {
    event.preventDefault()
    const text = body.trim()
    if (!text || sendingRef.current) return

    sendingRef.current = true
    setSending(true)
    setError(null)

    try {
      const response = await fetch(createUrl, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ comment: { body: text } })
      })

      if (response.status === 401) {
        window.location.assign(loginUrl)
        return
      }

      const payload = await response.json().catch(() => ({}))

      if (!response.ok) {
        setError(payload.error || "Не получилось отправить")
        return
      }

      setItems((current) => [...current, payload])
      setBody("")
    } catch {
      setError("Не получилось отправить. Попробуйте ещё раз.")
    } finally {
      sendingRef.current = false
      setSending(false)
    }
  }

  return (
    <>
      <h2 className="comments__title">Комментарии</h2>

      {items.length === 0 ? (
        <p className="comments__empty">Пока никто не написал.</p>
      ) : (
        <ol className="comments__list">
          {items.map((comment) => (
            <li key={comment.id} className="comments__item">
              <p className="comments__meta">
                <span className="comments__author">{comment.author}</span>
                <time dateTime={comment.created_at}>{formatTime(comment.created_at)}</time>
              </p>
              <p className="comments__body">{comment.body}</p>
            </li>
          ))}
        </ol>
      )}

      {signedIn ? (
        <form className="comments__form" onSubmit={onSubmit}>
          <label className="comments__field">
            Комментарий
            <textarea
              value={body}
              onChange={(event) => setBody(event.target.value)}
              rows={4}
              required
            />
          </label>
          {error ? <p className="comments__error" role="alert">{error}</p> : null}
          <button type="submit" className="comments__submit" disabled={sending || body.trim() === ""}>
            {sending ? "Отправка…" : "Отправить"}
          </button>
        </form>
      ) : (
        <p className="comments__login">
          <a href={loginUrl}>Войдите</a>, чтобы оставить комментарий.
        </p>
      )}
    </>
  )
}
