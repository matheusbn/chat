import '../css/index.scss'

const messageForm = document.querySelector('.message-form')

messageForm.onsubmit = e => {
  e.preventDefault()
  const input =  messageForm.querySelector('input')
  const text = input.value
  
  if(text == '') return

  input.value = ''
  addMessage(text, { isCurrentUser: true })
  socket.send(text)
}




// Create WebSocket connection.
const socket = new WebSocket('ws://localhost:3000')

// Connection opened
socket.onopen = function (event) {
  console.log("connection opened")
}

// Listen for messages
socket.onmessage = function(event) {
  console.log('message from server:', event.data)
  addMessage(event.data, { isCurrentUser: false })
}



function addMessage(text, opt) {
  const { isCurrentUser } = opt

  const message = createElement('div', text)

  const classes = isCurrentUser ? 'current-user-message align-self-flex-end' :
                                  'other-user-message align-self-flex-start'

  message.className = classes

  const messages = document.querySelector('.messages')
  messages.appendChild(message)
}

function createElement(elementName, content) {
  const element = document.createElement(elementName)
  const textNode = document.createTextNode(content)
  element.appendChild(textNode)

  return element
}