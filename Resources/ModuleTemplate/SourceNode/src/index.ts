// ActionBee - Node Module Template

// ⚠️ please put compiled your src into ./dist/index.js

function finalizeResult(
  action: ActionBeeAction,
  content: string,
  continueQueue: boolean,
) {
  const result = {
    postAction: action, // none, overwrite, speak
    postContent: content, // your content to post
    continueQueue,
  }
  const base64 = Buffer.from(JSON.stringify(result)).toString('base64')
  process.stderr.write(`\nActionBee-Result-Recipe://${base64}`)
  process.exit(0)
}

function moduleMain() {
  const messageFromEnv = process.env['Communicator_Message']

  if (!messageFromEnv) {
    process.stderr.write('ActionBee-Error: No message found')
    return
  }

  const toString = Buffer.from(messageFromEnv, 'base64').toString()
  const event: ActionBeeMessageEvent = JSON.parse(toString)

  console.log(event.focusAppID) // optional
  console.log(event.focusAppName) // optional
  console.log(event.pasteboardContent) // string

  finalizeResult('overwrite', 'Hello World', false)
}

moduleMain()
