import '../css/index.scss'

console.log('dai man')



function createElement(elementName, content) {
  const e = document.createElement(elementName)
  const textNode = docuemnt.createTextNode(content)
  e.appendChild(textNode)

  return e
}