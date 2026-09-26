import { createRoot } from "react-dom/client"
import { Comments } from "./Comments"

function readComments(node) {
  try {
    const parsed = JSON.parse(node.dataset.comments || "[]")
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

export function mount(node) {
  const root = createRoot(node)
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || ""

  root.render(
    <Comments
      comments={readComments(node)}
      signedIn={node.dataset.signedIn === "true"}
      createUrl={node.dataset.createUrl}
      loginUrl={node.dataset.loginUrl}
      csrfToken={csrfToken}
    />
  )

  return () => root.unmount()
}
