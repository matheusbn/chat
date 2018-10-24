import '../css/index.scss'

addMessage('oi')

const messageForm = document.querySelector('.message-form')

messageForm.onsubmit = e => {
  e.preventDefault()
  const input =  messageForm.querySelector('input')
  const text = input.value
  input.value = ''

  if(text != '') addMessage(text)
}


function createElement(elementName, content) {
  const element = document.createElement(elementName)
  const textNode = document.createTextNode(content)
  element.appendChild(textNode)

  return element
}

function createMessage(text) {
  const element = createElement('div', text)
  element.className = "current-user-message align-self-flex-end"
  return element
}

function addMessage(text) {
  const messages = document.querySelector('.messages')
  messages.appendChild(createMessage(text))
}