type rec valueType<_> = String: valueType<string> | Integer: valueType<int> | Bool: valueType<bool>

type error = {type_: string, message: string}

type t<'a> = 'a => Result.t<'a, error>

// let validate:
//   type a. (valueType<a>, a, array<t<a>>) => Result.t<a, error> =
//   (_, value, vs) => {
//     vs->Array.reduce(Result.Ok(value), (r, v) => {
//       switch (r, value->v) {
//       | (Ok(data), Ok(_)) => Ok(data)
//       | (Ok(_), Error(err)) => Error(err)
//       | (Error(err), _) => Error(err)
//       }
//     })
//   }
