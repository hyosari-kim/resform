module Example = {
  module Fields = %lenses(type state = {name: string, age: int})

  module Form = ResForm.Make(Fields)

  let initialValue: Fields.state = {
    name: "",
    age: 0,
  }

  @react.component
  let make = () => {
    let {form, handleSubmit} = Form.use(initialValue, ~validators=list{})

    let onClickSubmit = (_, _) => {
      Js.log2("form", form)
    }

    <form onSubmit={handleSubmit(onClickSubmit)}>
      <h2 className="h2"> {"ResForm Demo"->React.string} </h2>
      <SpreadProps props={form->Form.register(Fields.Name)}> <input /> </SpreadProps>
      <SpreadProps props={form->Form.register(Fields.Age)}> <input /> </SpreadProps>
      <button type_="submit"> {`제출`->React.string} </button>
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
