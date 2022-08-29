module Example = {
  module FieldState = %lenses(type state = {name: string, age: int})

  module Form = ResForm.Make(FieldState)

  let initialValue: FieldState.state = {
    name: "",
    age: 0,
  }

  @react.component
  let make = () => {
    let {register} = Form.use(initialValue, ~validators=list{})

    <form>
      <h2 className="h2"> {"ResForm Demo"->React.string} </h2>
      <SpreadProps props={register(FieldState.Name->Form.Field)}> <input /> </SpreadProps>
      <SpreadProps props={register(FieldState.Age->Form.Field)}> <input /> </SpreadProps>
    </form>
  }
}

module Forms = {
  @react.component
  let make = () => {
    <div> <Header /> <Example /> </div>
  }
}

switch ReactDOM.querySelector("#root") {
| None => Js.Exn.raiseError("#root node not found")
| Some(root) => ReactDOM.render(<Forms />, root)
}
