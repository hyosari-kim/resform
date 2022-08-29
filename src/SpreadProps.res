@react.component
let make = (~children, ~props) => {
  React.cloneElement(children, props)
}
