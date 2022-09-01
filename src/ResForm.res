module type Config = {
  type field<'a>
  type state
  let set: (state, field<'a>, 'a) => state
  let get: (state, field<'a>) => 'a
}

module Make = (Config: Config) => {
  module V = Validator

  @unboxed
  type rec field = Field(Config.field<'a>): field

  module ErrorFieldCmp = Id.MakeComparable({
    type t = field
    let cmp = (a, b) => a == b ? 0 : 1
  })

  type errors = Map.t<field, V.error, ErrorFieldCmp.identity>

  type rec fieldValidator = FieldValidator(Config.field<'a>, array<V.t<'a>>): fieldValidator

  type state = {
    values: ref<Config.state>,
    refs: ref<List.t<(field, React.ref<Js.Nullable.t<React.element>>)>>,
    errors: ref<errors>,
    validators: List.t<fieldValidator>,
  }

  type registerResult = {
    onChange: ReactEvent.Form.t => unit,
    ref: option<React.ref<Js.Nullable.t<React.element>>>,
  }

  type useResult = {
    form: state,
    handleSubmit: ((Config.state, ReactEvent.Form.t) => unit, ReactEvent.Form.t) => unit,
  }

  let getError: 'b 'a. (state, Config.field<'a>) => option<V.error> = (state, field) =>
    Map.get(state.errors.contents, Field(field))

  let eqErrors: (errors, errors) => bool = (cur, next) =>
    Map.eq(cur, next, (ce, ne) => ce.type_ == ne.type_)

  let register: 'a. (state, Config.field<'a>) => registerResult = (state, field) => {
    state.refs :=
      state.refs.contents->List.setAssoc(Field(field), React.useRef(Js.Nullable.null), (a, b) =>
        a == b
      )

    let onChange = (e: ReactEvent.Form.t) => {
      let ref = state.refs.contents->List.getAssoc(Field(field), (a, b) => a == b)
      let target = (e->ReactEvent.Synthetic.target)["value"]

      state.values := state.values.contents->Config.set(field, target)
      ref->ignore
    }

    {
      onChange: onChange,
      ref: state.refs.contents->List.getAssoc(Field(field), (a, b) => a == b),
    }
  }

  let use = (initial: Config.state, ~validators: List.t<fieldValidator>): useResult => {
    validators->ignore

    let (state, _) = React.Uncurried.useState(_ => {
      values: ref(initial),
      refs: ref(list{}),
      errors: ref(Map.make(~id=module(ErrorFieldCmp))),
      validators: validators,
    })

    let handleSubmit = (fn, e: ReactEvent.Form.t) => {
      e->ReactEvent.Synthetic.preventDefault
      e->ReactEvent.Synthetic.stopPropagation

      fn(state.values.contents, e)
    }

    {form: state, handleSubmit: handleSubmit}
  }
}

// module Make = (Config: Config) => {
//   module V = Validator

//   @unboxed
//   type rec field = Field(Config.field<'a>): field

//   module ErrorFieldCmp = Id.MakeComparable({
//     type t = field
//     let cmp = (a, b) => a == b ? 0 : 1
//   })

//   type errors = Map.t<field, V.error, ErrorFieldCmp.identity>

//   type state<'a> = {
//     values: ref<Config.state>,
//     refs: ref<List.t<(field, React.ref<Js.Nullable.t<'a>>)>>,
//     errors: errors,
//   }

//   let getError: (errors, field) => option<V.error> = (errors, field) => Map.get(errors, field)

//   let eqErrors: (errors, errors) => bool = (cur, next) =>
//     Map.eq(cur, next, (ce, ne) => ce.type_ == ne.type_)

//   type registerResult<'a> = {
//     onChange: ReactEvent.Form.t => unit,
//     ref: option<React.ref<Js.Nullable.t<'a>>>,
//   }
//   type register<'a, 'b> = Config.field<'a> => registerResult<'b>

//   type useResult<'a, 'b> = {register: register<'a, 'b>}

//   let register = (state, field) => {
//     // let field = Field(rawField)
//     state.refs :=
//       state.refs.contents->List.setAssoc(field, React.useRef(Js.Nullable.null), (a, b) => a == b)

//     let onChange = (e: ReactEvent.Form.t) => {
//       let ref = state.refs.contents->List.getAssoc(field, (a, b) => a == b)
//       let target = (e->ReactEvent.Synthetic.target)["value"]

//       state.values := state.values.contents->Config.set(field, target)
//       Js.log4("ref: ", ref, "values: ", state.values.contents)
//     }
//     {
//       onChange: onChange,
//       ref: state.refs.contents->List.getAssoc(field, (a, b) => a == b),
//     }
//   }

//   let use: (Config.state, ~validators: List.t<(field, array<V.t<'a>>)>) => useResult<'b, 'c> = (
//     inital,
//     ~validators,
//   ) => {
//     validators->ignore
//     let (state, _) = React.Uncurried.useState(_ => {
//       values: ref(inital),
//       refs: ref(list{}),
//       errors: Map.make(~id=module(ErrorFieldCmp)),
//     })

//     {register: register(state)}
//   }
// }
