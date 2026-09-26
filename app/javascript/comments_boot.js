let unmountCurrent = null
let token = 0

async function mountIsland() {
  const node = document.querySelector("[data-comments-root]")
  if (!node) return

  const myToken = ++token

  try {
    const { mount } = await import("comments")
    if (myToken !== token || !node.isConnected) return

    unmountCurrent?.()
    unmountCurrent = mount(node)
  } catch (error) {
    console.error("Comments island failed to load", error)
  }
}

function teardownIsland() {
  token += 1
  unmountCurrent?.()
  unmountCurrent = null
}

document.addEventListener("turbo:load", mountIsland)
document.addEventListener("turbo:before-cache", teardownIsland)
