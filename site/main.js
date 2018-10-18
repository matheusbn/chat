// Create WebSocket connection.
const socket = new WebSocket('ws://localhost:3000')

// Connection opened
socket.onopen = function (event) {
    console.log("connection opened")
    socket.send('Hello Server!')
}

// Listen for messages
socket.onmessage = function (event) {
    console.log('Message from server:', event.data)
    const messagesList = document.querySelector('.messages')

    const message = document.createElement('li')
    const messageContent = document.createTextNode(event.data)
    message.appendChild(messageContent)

    messagesList.appendChild(message)
}


const btnSend = document.querySelector('.button-send')
btnSend.onclick = () => {
    const input = document.querySelector('.message-input')
    const message = input.value
    socket.send(message)
}