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

  type state<'a> = {
    values: ref<Config.state>,
    refs: ref<List.t<(field, React.ref<Js.Nullable.t<'a>>)>>,
    errors: errors,
  }

  let getError: (errors, field) => option<V.error> = (errors, field) => Map.get(errors, field)

  let eqErrors: (errors, errors) => bool = (cur, next) =>
    Map.eq(cur, next, (ce, ne) => ce.type_ == ne.type_)

  type registerResult<'a> = {
    onChange: ReactEvent.Form.t => unit,
    ref: option<React.ref<Js.Nullable.t<'a>>>,
  }
  type register<'a, 'b> = Config.field<'a> => registerResult<'b>

  type useResult<'a, 'b> = {register: register<'a, 'b>}

  let register = (state, field) => {
    // let field = Field(rawField)
    state.refs :=
      state.refs.contents->List.setAssoc(field, React.useRef(Js.Nullable.null), (a, b) => a == b)

    let onChange = (e: ReactEvent.Form.t) => {
      let ref = state.refs.contents->List.getAssoc(field, (a, b) => a == b)
      let target = (e->ReactEvent.Synthetic.target)["value"]

      state.values := state.values.contents->Config.set(field, target)
      Js.log4("ref: ", ref, "values: ", state.values.contents)
    }
    {
      onChange: onChange,
      ref: state.refs.contents->List.getAssoc(field, (a, b) => a == b),
    }
  }

  let use: (Config.state, ~validators: List.t<(field, array<V.t<'a>>)>) => useResult<'b, 'c> = (
    inital,
    ~validators,
  ) => {
    validators->ignore
    let (state, _) = React.Uncurried.useState(_ => {
      values: ref(inital),
      refs: ref(list{}),
      errors: Map.make(~id=module(ErrorFieldCmp)),
    })

    {register: register(state)}
  }
}

// module Make = (Config: Config) => {
//   @unboxed
//   type rec field = Field(Config.field<'a>): field

//   type error = {type_: string, message: string}
//   type validator<'a> = 'a => Result.t<'a, error>

//   module ErrorFieldCmp = Id.MakeComparable({
//     type t = field
//     let cmp = (a, b) => a == b ? 0 : 1
//   })

//   type errors = Map.t<field, error, ErrorFieldCmp.identity>

//   type state = {
//     values: ref<Config.state>,
//     errors: errors,
//   }

//   type resolver = Config.state => Result.t<Config.state, errors>

//   type registerResult = {onChange: ReactEvent.Form.t => unit}

//   type register<'a> = Config.field<'a> => registerResult

//   type onSubmit = ReactEvent.Form.t => unit
//   type handleSubmit = ((Config.state, ReactEvent.Form.t) => unit) => onSubmit

//   type useResult<'a> = {register: register<'a>, handleSubmit: handleSubmit, state: state}

//   let getError:
//     type a. (errors, Config.field<a>) => option<error> =
//     (errors, field) => {
//       Map.get(errors, Field(field))
//     }

//   let errorsEq = (curr: errors, next: errors) => {
//     Map.eq(curr, next, (currError, nextError) => currError.type_ == nextError.type_)
//   }

//   let use = (initialValue: Config.state, ~resolver: resolver) => {
//     let (state: state, setState) = React.Uncurried.useState(_ => {
//       values: ref(initialValue),
//       errors: Map.make(~id=module(ErrorFieldCmp)),
//     })

//     let register = field => {
//       let onChange = (e: ReactEvent.Form.t) => {
//         let target = (e->ReactEvent.Synthetic.target)["value"]

//         state.values := state.values.contents->Config.set(field, target)

//         let newError = switch resolver(state.values.contents) {
//         | Ok(values') => {
//             state.values := values'
//             Map.make(~id=module(ErrorFieldCmp))
//           }
//         | Error(errors') => errors'
//         }

//         if !errorsEq(state.errors, newError) {
//           setState(._ => {
//             values: ref(state.values.contents),
//             errors: newError,
//           })
//         }
//       }

//       {onChange: onChange}
//     }

//     let handleSubmit: handleSubmit = (f, e) => {
//       f(state.values.contents, e)

//       e->ReactEvent.Synthetic.preventDefault
//       e->ReactEvent.Synthetic.stopPropagation
//     }

//     {register: register, handleSubmit: handleSubmit, state: state}
//   }
// }
