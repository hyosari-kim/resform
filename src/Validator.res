type rec valueType<_> = String: valueType<string> | Integer: valueType<int> | Bool: valueType<bool>

type error = {type_: string, message: string}

type t<'a> = 'a => Result.t<'a, error>
