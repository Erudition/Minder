(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File === 'function' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[94m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (typeof x.$ === 'undefined')
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return word
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	result = init(result.a);
	var model = result.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		result = A2(update, msg, model);
		stepper(model = result.a, viewMetadata);
		_Platform_dispatchEffects(managers, result.b, subscriptions(model));
	}

	_Platform_dispatchEffects(managers, result.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				p: bag.n,
				q: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.q)
		{
			x = temp.p(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		r: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		r: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**_UNUSED/
	var node = args['node'];
	//*/
	/**/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		message: func(record.message),
		stopPropagation: record.stopPropagation,
		preventDefault: record.preventDefault
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.message;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var view = impl.view;
			/**_UNUSED/
			var domNode = args['node'];
			//*/
			/**/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.setup && impl.setup(sendToApp)
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.onUrlChange;
	var onUrlRequest = impl.onUrlRequest;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		setup: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		init: function(flags)
		{
			return A3(impl.init, flags, _Browser_getUrl(), key);
		},
		view: impl.view,
		update: impl.update,
		subscriptions: impl.subscriptions
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { hidden: 'hidden', change: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { hidden: 'mozHidden', change: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { hidden: 'msHidden', change: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { hidden: 'webkitHidden', change: 'webkitvisibilitychange' }
		: { hidden: 'hidden', change: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		scene: _Browser_getScene(),
		viewport: {
			x: _Browser_window.pageXOffset,
			y: _Browser_window.pageYOffset,
			width: _Browser_doc.documentElement.clientWidth,
			height: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		width: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		height: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			scene: {
				width: node.scrollWidth,
				height: node.scrollHeight
			},
			viewport: {
				x: node.scrollLeft,
				y: node.scrollTop,
				width: node.clientWidth,
				height: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			scene: _Browser_getScene(),
			viewport: {
				x: x,
				y: y,
				width: _Browser_doc.documentElement.clientWidth,
				height: _Browser_doc.documentElement.clientHeight
			},
			element: {
				x: x + rect.left,
				y: y + rect.top,
				width: rect.width,
				height: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}


function _Url_percentEncode(string)
{
	return encodeURIComponent(string);
}

function _Url_percentDecode(string)
{
	try
	{
		return $elm$core$Maybe$Just(decodeURIComponent(string));
	}
	catch (e)
	{
		return $elm$core$Maybe$Nothing;
	}
}


function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2($elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = $elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = $elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}




// STRINGS


var _Parser_isSubString = F5(function(smallString, offset, row, col, bigString)
{
	var smallLength = smallString.length;
	var isGood = offset + smallLength <= bigString.length;

	for (var i = 0; isGood && i < smallLength; )
	{
		var code = bigString.charCodeAt(offset);
		isGood =
			smallString[i++] === bigString[offset++]
			&& (
				code === 0x000A /* \n */
					? ( row++, col=1 )
					: ( col++, (code & 0xF800) === 0xD800 ? smallString[i++] === bigString[offset++] : 1 )
			)
	}

	return _Utils_Tuple3(isGood ? offset : -1, row, col);
});



// CHARS


var _Parser_isSubChar = F3(function(predicate, offset, string)
{
	return (
		string.length <= offset
			? -1
			:
		(string.charCodeAt(offset) & 0xF800) === 0xD800
			? (predicate(_Utils_chr(string.substr(offset, 2))) ? offset + 2 : -1)
			:
		(predicate(_Utils_chr(string[offset]))
			? ((string[offset] === '\n') ? -2 : (offset + 1))
			: -1
		)
	);
});


var _Parser_isAsciiCode = F3(function(code, offset, string)
{
	return string.charCodeAt(offset) === code;
});



// NUMBERS


var _Parser_chompBase10 = F2(function(offset, string)
{
	for (; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (code < 0x30 || 0x39 < code)
		{
			return offset;
		}
	}
	return offset;
});


var _Parser_consumeBase = F3(function(base, offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var digit = string.charCodeAt(offset) - 0x30;
		if (digit < 0 || base <= digit) break;
		total = base * total + digit;
	}
	return _Utils_Tuple2(offset, total);
});


var _Parser_consumeBase16 = F2(function(offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (0x30 <= code && code <= 0x39)
		{
			total = 16 * total + code - 0x30;
		}
		else if (0x41 <= code && code <= 0x46)
		{
			total = 16 * total + code - 55;
		}
		else if (0x61 <= code && code <= 0x66)
		{
			total = 16 * total + code - 87;
		}
		else
		{
			break;
		}
	}
	return _Utils_Tuple2(offset, total);
});



// FIND STRING


var _Parser_findSubString = F5(function(smallString, offset, row, col, bigString)
{
	var newOffset = bigString.indexOf(smallString, offset);
	var target = newOffset < 0 ? bigString.length : newOffset + smallString.length;

	while (offset < target)
	{
		var code = bigString.charCodeAt(offset++);
		code === 0x000A /* \n */
			? ( col=1, row++ )
			: ( col++, (code & 0xF800) === 0xD800 && offset++ )
	}

	return _Utils_Tuple3(newOffset, row, col);
});



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.expect.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done($elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done($elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.expect.b, xhr)); });
		$elm$core$Maybe$isJust(request.tracker) && _Http_track(router, xhr, request.tracker.a);

		try {
			xhr.open(request.method, request.url, true);
		} catch (e) {
			return done($elm$http$Http$BadUrl_(request.url));
		}

		_Http_configureRequest(xhr, request);

		request.body.a && xhr.setRequestHeader('Content-Type', request.body.a);
		xhr.send(request.body.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.headers; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.timeout.a || 0;
	xhr.responseType = request.expect.d;
	xhr.withCredentials = request.allowCookiesFromOtherDomains;
}


// RESPONSES

function _Http_toResponse(toBody, xhr)
{
	return A2(
		200 <= xhr.status && xhr.status < 300 ? $elm$http$Http$GoodStatus_ : $elm$http$Http$BadStatus_,
		_Http_toMetadata(xhr),
		toBody(xhr.response)
	);
}


// METADATA

function _Http_toMetadata(xhr)
{
	return {
		url: xhr.responseURL,
		statusCode: xhr.status,
		statusText: xhr.statusText,
		headers: _Http_parseHeaders(xhr.getAllResponseHeaders())
	};
}


// HEADERS

function _Http_parseHeaders(rawHeaders)
{
	if (!rawHeaders)
	{
		return $elm$core$Dict$empty;
	}

	var headers = $elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3($elm$core$Dict$update, key, function(oldValue) {
				return $elm$core$Maybe$Just($elm$core$Maybe$isJust(oldValue)
					? value + ', ' + oldValue.a
					: value
				);
			}, headers);
		}
	}
	return headers;
}


// EXPECT

var _Http_expect = F3(function(type, toBody, toValue)
{
	return {
		$: 0,
		d: type,
		b: toBody,
		a: toValue
	};
});

var _Http_mapExpect = F2(function(func, expect)
{
	return {
		$: 0,
		d: expect.d,
		b: expect.b,
		a: function(x) { return func(expect.a(x)); }
	};
});

function _Http_toDataView(arrayBuffer)
{
	return new DataView(arrayBuffer);
}


// BODY and PARTS

var _Http_emptyBody = { $: 0 };
var _Http_pair = F2(function(a, b) { return { $: 0, a: a, b: b }; });

function _Http_toFormData(parts)
{
	for (var formData = new FormData(); parts.b; parts = parts.b) // WHILE_CONS
	{
		var part = parts.a;
		formData.append(part.a, part.b);
	}
	return formData;
}

var _Http_bytesToBlob = F2(function(mime, bytes)
{
	return new Blob([bytes], { type: mime });
});


// PROGRESS

function _Http_track(router, xhr, tracker)
{
	// TODO check out lengthComputable on loadstart event

	xhr.upload.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Sending({
			sent: event.loaded,
			size: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Receiving({
			received: event.loaded,
			size: event.lengthComputable ? $elm$core$Maybe$Just(event.total) : $elm$core$Maybe$Nothing
		}))));
	});
}

// BYTES

function _Bytes_width(bytes)
{
	return bytes.byteLength;
}

var _Bytes_getHostEndianness = F2(function(le, be)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(new Uint8Array(new Uint32Array([1]))[0] === 1 ? le : be));
	});
});


// ENCODERS

function _Bytes_encode(encoder)
{
	var mutableBytes = new DataView(new ArrayBuffer($elm$bytes$Bytes$Encode$getWidth(encoder)));
	$elm$bytes$Bytes$Encode$write(encoder)(mutableBytes)(0);
	return mutableBytes;
}


// SIGNED INTEGERS

var _Bytes_write_i8  = F3(function(mb, i, n) { mb.setInt8(i, n); return i + 1; });
var _Bytes_write_i16 = F4(function(mb, i, n, isLE) { mb.setInt16(i, n, isLE); return i + 2; });
var _Bytes_write_i32 = F4(function(mb, i, n, isLE) { mb.setInt32(i, n, isLE); return i + 4; });


// UNSIGNED INTEGERS

var _Bytes_write_u8  = F3(function(mb, i, n) { mb.setUint8(i, n); return i + 1 ;});
var _Bytes_write_u16 = F4(function(mb, i, n, isLE) { mb.setUint16(i, n, isLE); return i + 2; });
var _Bytes_write_u32 = F4(function(mb, i, n, isLE) { mb.setUint32(i, n, isLE); return i + 4; });


// FLOATS

var _Bytes_write_f32 = F4(function(mb, i, n, isLE) { mb.setFloat32(i, n, isLE); return i + 4; });
var _Bytes_write_f64 = F4(function(mb, i, n, isLE) { mb.setFloat64(i, n, isLE); return i + 8; });


// BYTES

var _Bytes_write_bytes = F3(function(mb, offset, bytes)
{
	for (var i = 0, len = bytes.byteLength, limit = len - 4; i <= limit; i += 4)
	{
		mb.setUint32(offset + i, bytes.getUint32(i));
	}
	for (; i < len; i++)
	{
		mb.setUint8(offset + i, bytes.getUint8(i));
	}
	return offset + len;
});


// STRINGS

function _Bytes_getStringWidth(string)
{
	for (var width = 0, i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		width +=
			(code < 0x80) ? 1 :
			(code < 0x800) ? 2 :
			(code < 0xD800 || 0xDBFF < code) ? 3 : (i++, 4);
	}
	return width;
}

var _Bytes_write_string = F3(function(mb, offset, string)
{
	for (var i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		offset +=
			(code < 0x80)
				? (mb.setUint8(offset, code)
				, 1
				)
				:
			(code < 0x800)
				? (mb.setUint16(offset, 0xC080 /* 0b1100000010000000 */
					| (code >>> 6 & 0x1F /* 0b00011111 */) << 8
					| code & 0x3F /* 0b00111111 */)
				, 2
				)
				:
			(code < 0xD800 || 0xDBFF < code)
				? (mb.setUint16(offset, 0xE080 /* 0b1110000010000000 */
					| (code >>> 12 & 0xF /* 0b00001111 */) << 8
					| code >>> 6 & 0x3F /* 0b00111111 */)
				, mb.setUint8(offset + 2, 0x80 /* 0b10000000 */
					| code & 0x3F /* 0b00111111 */)
				, 3
				)
				:
			(code = (code - 0xD800) * 0x400 + string.charCodeAt(++i) - 0xDC00 + 0x10000
			, mb.setUint32(offset, 0xF0808080 /* 0b11110000100000001000000010000000 */
				| (code >>> 18 & 0x7 /* 0b00000111 */) << 24
				| (code >>> 12 & 0x3F /* 0b00111111 */) << 16
				| (code >>> 6 & 0x3F /* 0b00111111 */) << 8
				| code & 0x3F /* 0b00111111 */)
			, 4
			);
	}
	return offset;
});


// DECODER

var _Bytes_decode = F2(function(decoder, bytes)
{
	try {
		return $elm$core$Maybe$Just(A2(decoder, bytes, 0).b);
	} catch(e) {
		return $elm$core$Maybe$Nothing;
	}
});

var _Bytes_read_i8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getInt8(offset)); });
var _Bytes_read_i16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getInt16(offset, isLE)); });
var _Bytes_read_i32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getInt32(offset, isLE)); });
var _Bytes_read_u8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getUint8(offset)); });
var _Bytes_read_u16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getUint16(offset, isLE)); });
var _Bytes_read_u32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getUint32(offset, isLE)); });
var _Bytes_read_f32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getFloat32(offset, isLE)); });
var _Bytes_read_f64 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 8, bytes.getFloat64(offset, isLE)); });

var _Bytes_read_bytes = F3(function(len, bytes, offset)
{
	return _Utils_Tuple2(offset + len, new DataView(bytes.buffer, bytes.byteOffset + offset, len));
});

var _Bytes_read_string = F3(function(len, bytes, offset)
{
	var string = '';
	var end = offset + len;
	for (; offset < end;)
	{
		var byte = bytes.getUint8(offset++);
		string +=
			(byte < 128)
				? String.fromCharCode(byte)
				:
			((byte & 0xE0 /* 0b11100000 */) === 0xC0 /* 0b11000000 */)
				? String.fromCharCode((byte & 0x1F /* 0b00011111 */) << 6 | bytes.getUint8(offset++) & 0x3F /* 0b00111111 */)
				:
			((byte & 0xF0 /* 0b11110000 */) === 0xE0 /* 0b11100000 */)
				? String.fromCharCode(
					(byte & 0xF /* 0b00001111 */) << 12
					| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
					| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
				)
				:
				(byte =
					((byte & 0x7 /* 0b00000111 */) << 18
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 12
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
						| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
					) - 0x10000
				, String.fromCharCode(Math.floor(byte / 0x400) + 0xD800, byte % 0x400 + 0xDC00)
				);
	}
	return _Utils_Tuple2(offset, string);
});

var _Bytes_decodeFailure = F2(function() { throw 0; });
var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$Basics$False = {$: 'False'};
var $elm$core$Basics$add = _Basics_add;
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $rtfeldman$elm_css$VirtualDom$Styled$Node = F3(
	function (a, b, c) {
		return {$: 'Node', a: a, b: b, c: c};
	});
var $rtfeldman$elm_css$VirtualDom$Styled$node = $rtfeldman$elm_css$VirtualDom$Styled$Node;
var $rtfeldman$elm_css$Html$Styled$node = $rtfeldman$elm_css$VirtualDom$Styled$node;
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles = F2(
	function (_v0, styles) {
		var newStyles = _v0.b;
		var classname = _v0.c;
		return $elm$core$List$isEmpty(newStyles) ? styles : A3($elm$core$Dict$insert, classname, newStyles, styles);
	});
var $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute = function (_v0) {
	var val = _v0.a;
	return val;
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 'Normal':
			return 0;
		case 'MayStopPropagation':
			return 1;
		case 'MayPreventDefault':
			return 2;
		default:
			return 3;
	}
};
var $elm$virtual_dom$VirtualDom$keyedNode = function (tag) {
	return _VirtualDom_keyedNode(
		_VirtualDom_noScript(tag));
};
var $elm$virtual_dom$VirtualDom$keyedNodeNS = F2(
	function (namespace, tag) {
		return A2(
			_VirtualDom_keyedNodeNS,
			namespace,
			_VirtualDom_noScript(tag));
	});
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$virtual_dom$VirtualDom$node = function (tag) {
	return _VirtualDom_node(
		_VirtualDom_noScript(tag));
};
var $elm$virtual_dom$VirtualDom$nodeNS = function (tag) {
	return _VirtualDom_nodeNS(
		_VirtualDom_noScript(tag));
};
var $rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml = F2(
	function (_v6, _v7) {
		var key = _v6.a;
		var html = _v6.b;
		var pairs = _v7.a;
		var styles = _v7.b;
		switch (html.$) {
			case 'Unstyled':
				var vdom = html.a;
				return _Utils_Tuple2(
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					styles);
			case 'Node':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v9 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v9.a;
				var finalStyles = _v9.b;
				var vdom = A3(
					$elm$virtual_dom$VirtualDom$node,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
			case 'NodeNS':
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v10 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v10.a;
				var finalStyles = _v10.b;
				var vdom = A4(
					$elm$virtual_dom$VirtualDom$nodeNS,
					ns,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
			case 'KeyedNode':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v11 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v11.a;
				var finalStyles = _v11.b;
				var vdom = A3(
					$elm$virtual_dom$VirtualDom$keyedNode,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
			default:
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v12 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v12.a;
				var finalStyles = _v12.b;
				var vdom = A4(
					$elm$virtual_dom$VirtualDom$keyedNodeNS,
					ns,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
		}
	});
var $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml = F2(
	function (html, _v0) {
		var nodes = _v0.a;
		var styles = _v0.b;
		switch (html.$) {
			case 'Unstyled':
				var vdomNode = html.a;
				return _Utils_Tuple2(
					A2($elm$core$List$cons, vdomNode, nodes),
					styles);
			case 'Node':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v2 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v2.a;
				var finalStyles = _v2.b;
				var vdomNode = A3(
					$elm$virtual_dom$VirtualDom$node,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2($elm$core$List$cons, vdomNode, nodes),
					finalStyles);
			case 'NodeNS':
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v3 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v3.a;
				var finalStyles = _v3.b;
				var vdomNode = A4(
					$elm$virtual_dom$VirtualDom$nodeNS,
					ns,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2($elm$core$List$cons, vdomNode, nodes),
					finalStyles);
			case 'KeyedNode':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v4 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v4.a;
				var finalStyles = _v4.b;
				var vdomNode = A3(
					$elm$virtual_dom$VirtualDom$keyedNode,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2($elm$core$List$cons, vdomNode, nodes),
					finalStyles);
			default:
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3($elm$core$List$foldl, $rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _v5 = A3(
					$elm$core$List$foldl,
					$rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _v5.a;
				var finalStyles = _v5.b;
				var vdomNode = A4(
					$elm$virtual_dom$VirtualDom$keyedNodeNS,
					ns,
					elemType,
					A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					$elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2($elm$core$List$cons, vdomNode, nodes),
					finalStyles);
		}
	});
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Dict$singleton = F2(
	function (key, value) {
		return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
	});
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $rtfeldman$elm_css$VirtualDom$Styled$stylesFromPropertiesHelp = F2(
	function (candidate, properties) {
		stylesFromPropertiesHelp:
		while (true) {
			if (!properties.b) {
				return candidate;
			} else {
				var _v1 = properties.a;
				var styles = _v1.b;
				var classname = _v1.c;
				var rest = properties.b;
				if ($elm$core$String$isEmpty(classname)) {
					var $temp$candidate = candidate,
						$temp$properties = rest;
					candidate = $temp$candidate;
					properties = $temp$properties;
					continue stylesFromPropertiesHelp;
				} else {
					var $temp$candidate = $elm$core$Maybe$Just(
						_Utils_Tuple2(classname, styles)),
						$temp$properties = rest;
					candidate = $temp$candidate;
					properties = $temp$properties;
					continue stylesFromPropertiesHelp;
				}
			}
		}
	});
var $rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties = function (properties) {
	var _v0 = A2($rtfeldman$elm_css$VirtualDom$Styled$stylesFromPropertiesHelp, $elm$core$Maybe$Nothing, properties);
	if (_v0.$ === 'Nothing') {
		return $elm$core$Dict$empty;
	} else {
		var _v1 = _v0.a;
		var classname = _v1.a;
		var styles = _v1.b;
		return A2($elm$core$Dict$singleton, classname, styles);
	}
};
var $elm$core$List$singleton = function (value) {
	return _List_fromArray(
		[value]);
};
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$Basics$not = _Basics_not;
var $elm$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			$elm$core$List$any,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, isOkay),
			list);
	});
var $rtfeldman$elm_css$Css$Structure$compactHelp = F2(
	function (declaration, _v0) {
		var keyframesByName = _v0.a;
		var declarations = _v0.b;
		switch (declaration.$) {
			case 'StyleBlockDeclaration':
				var _v2 = declaration.a;
				var properties = _v2.c;
				return $elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			case 'MediaRule':
				var styleBlocks = declaration.b;
				return A2(
					$elm$core$List$all,
					function (_v3) {
						var properties = _v3.c;
						return $elm$core$List$isEmpty(properties);
					},
					styleBlocks) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			case 'SupportsRule':
				var otherDeclarations = declaration.b;
				return $elm$core$List$isEmpty(otherDeclarations) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			case 'DocumentRule':
				return _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			case 'PageRule':
				var properties = declaration.b;
				return $elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			case 'FontFace':
				var properties = declaration.a;
				return $elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			case 'Keyframes':
				var record = declaration.a;
				return $elm$core$String$isEmpty(record.declaration) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					A3($elm$core$Dict$insert, record.name, record.declaration, keyframesByName),
					declarations);
			case 'Viewport':
				var properties = declaration.a;
				return $elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			case 'CounterStyle':
				var properties = declaration.a;
				return $elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
			default:
				var tuples = declaration.a;
				return A2(
					$elm$core$List$all,
					function (_v4) {
						var properties = _v4.b;
						return $elm$core$List$isEmpty(properties);
					},
					tuples) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2($elm$core$List$cons, declaration, declarations));
		}
	});
var $rtfeldman$elm_css$Css$Structure$Keyframes = function (a) {
	return {$: 'Keyframes', a: a};
};
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $rtfeldman$elm_css$Css$Structure$withKeyframeDeclarations = F2(
	function (keyframesByName, compactedDeclarations) {
		return A2(
			$elm$core$List$append,
			A2(
				$elm$core$List$map,
				function (_v0) {
					var name = _v0.a;
					var decl = _v0.b;
					return $rtfeldman$elm_css$Css$Structure$Keyframes(
						{declaration: decl, name: name});
				},
				$elm$core$Dict$toList(keyframesByName)),
			compactedDeclarations);
	});
var $rtfeldman$elm_css$Css$Structure$compactStylesheet = function (_v0) {
	var charset = _v0.charset;
	var imports = _v0.imports;
	var namespaces = _v0.namespaces;
	var declarations = _v0.declarations;
	var _v1 = A3(
		$elm$core$List$foldr,
		$rtfeldman$elm_css$Css$Structure$compactHelp,
		_Utils_Tuple2($elm$core$Dict$empty, _List_Nil),
		declarations);
	var keyframesByName = _v1.a;
	var compactedDeclarations = _v1.b;
	var finalDeclarations = A2($rtfeldman$elm_css$Css$Structure$withKeyframeDeclarations, keyframesByName, compactedDeclarations);
	return {charset: charset, declarations: finalDeclarations, imports: imports, namespaces: namespaces};
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $rtfeldman$elm_css$Css$Structure$Output$charsetToString = function (charset) {
	return A2(
		$elm$core$Maybe$withDefault,
		'',
		A2(
			$elm$core$Maybe$map,
			function (str) {
				return '@charset \"' + (str + '\"');
			},
			charset));
};
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $rtfeldman$elm_css$Css$Structure$Output$mediaExpressionToString = function (expression) {
	return '(' + (expression.feature + (A2(
		$elm$core$Maybe$withDefault,
		'',
		A2(
			$elm$core$Maybe$map,
			$elm$core$Basics$append(': '),
			expression.value)) + ')'));
};
var $rtfeldman$elm_css$Css$Structure$Output$mediaTypeToString = function (mediaType) {
	switch (mediaType.$) {
		case 'Print':
			return 'print';
		case 'Screen':
			return 'screen';
		default:
			return 'speech';
	}
};
var $rtfeldman$elm_css$Css$Structure$Output$mediaQueryToString = function (mediaQuery) {
	var prefixWith = F3(
		function (str, mediaType, expressions) {
			return str + (' ' + A2(
				$elm$core$String$join,
				' and ',
				A2(
					$elm$core$List$cons,
					$rtfeldman$elm_css$Css$Structure$Output$mediaTypeToString(mediaType),
					A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$mediaExpressionToString, expressions))));
		});
	switch (mediaQuery.$) {
		case 'AllQuery':
			var expressions = mediaQuery.a;
			return A2(
				$elm$core$String$join,
				' and ',
				A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$mediaExpressionToString, expressions));
		case 'OnlyQuery':
			var mediaType = mediaQuery.a;
			var expressions = mediaQuery.b;
			return A3(prefixWith, 'only', mediaType, expressions);
		case 'NotQuery':
			var mediaType = mediaQuery.a;
			var expressions = mediaQuery.b;
			return A3(prefixWith, 'not', mediaType, expressions);
		default:
			var str = mediaQuery.a;
			return str;
	}
};
var $rtfeldman$elm_css$Css$Structure$Output$importMediaQueryToString = F2(
	function (name, mediaQuery) {
		return '@import \"' + (name + ($rtfeldman$elm_css$Css$Structure$Output$mediaQueryToString(mediaQuery) + '\"'));
	});
var $rtfeldman$elm_css$Css$Structure$Output$importToString = function (_v0) {
	var name = _v0.a;
	var mediaQueries = _v0.b;
	return A2(
		$elm$core$String$join,
		'\n',
		A2(
			$elm$core$List$map,
			$rtfeldman$elm_css$Css$Structure$Output$importMediaQueryToString(name),
			mediaQueries));
};
var $rtfeldman$elm_css$Css$Structure$Output$namespaceToString = function (_v0) {
	var prefix = _v0.a;
	var str = _v0.b;
	return '@namespace ' + (prefix + ('\"' + (str + '\"')));
};
var $rtfeldman$elm_css$Css$Structure$Output$spaceIndent = '    ';
var $rtfeldman$elm_css$Css$Structure$Output$indent = function (str) {
	return _Utils_ap($rtfeldman$elm_css$Css$Structure$Output$spaceIndent, str);
};
var $rtfeldman$elm_css$Css$Structure$Output$noIndent = '';
var $rtfeldman$elm_css$Css$Structure$Output$emitProperty = function (str) {
	return str + ';';
};
var $rtfeldman$elm_css$Css$Structure$Output$emitProperties = function (properties) {
	return A2(
		$elm$core$String$join,
		'\n',
		A2(
			$elm$core$List$map,
			A2($elm$core$Basics$composeL, $rtfeldman$elm_css$Css$Structure$Output$indent, $rtfeldman$elm_css$Css$Structure$Output$emitProperty),
			properties));
};
var $elm$core$String$append = _String_append;
var $rtfeldman$elm_css$Css$Structure$Output$pseudoElementToString = function (_v0) {
	var str = _v0.a;
	return '::' + str;
};
var $rtfeldman$elm_css$Css$Structure$Output$combinatorToString = function (combinator) {
	switch (combinator.$) {
		case 'AdjacentSibling':
			return '+';
		case 'GeneralSibling':
			return '~';
		case 'Child':
			return '>';
		default:
			return '';
	}
};
var $rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString = function (repeatableSimpleSelector) {
	switch (repeatableSimpleSelector.$) {
		case 'ClassSelector':
			var str = repeatableSimpleSelector.a;
			return '.' + str;
		case 'IdSelector':
			var str = repeatableSimpleSelector.a;
			return '#' + str;
		case 'PseudoClassSelector':
			var str = repeatableSimpleSelector.a;
			return ':' + str;
		default:
			var str = repeatableSimpleSelector.a;
			return '[' + (str + ']');
	}
};
var $rtfeldman$elm_css$Css$Structure$Output$simpleSelectorSequenceToString = function (simpleSelectorSequence) {
	switch (simpleSelectorSequence.$) {
		case 'TypeSelectorSequence':
			var str = simpleSelectorSequence.a.a;
			var repeatableSimpleSelectors = simpleSelectorSequence.b;
			return A2(
				$elm$core$String$join,
				'',
				A2(
					$elm$core$List$cons,
					str,
					A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString, repeatableSimpleSelectors)));
		case 'UniversalSelectorSequence':
			var repeatableSimpleSelectors = simpleSelectorSequence.a;
			return $elm$core$List$isEmpty(repeatableSimpleSelectors) ? '*' : A2(
				$elm$core$String$join,
				'',
				A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString, repeatableSimpleSelectors));
		default:
			var str = simpleSelectorSequence.a;
			var repeatableSimpleSelectors = simpleSelectorSequence.b;
			return A2(
				$elm$core$String$join,
				'',
				A2(
					$elm$core$List$cons,
					str,
					A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString, repeatableSimpleSelectors)));
	}
};
var $rtfeldman$elm_css$Css$Structure$Output$selectorChainToString = function (_v0) {
	var combinator = _v0.a;
	var sequence = _v0.b;
	return A2(
		$elm$core$String$join,
		' ',
		_List_fromArray(
			[
				$rtfeldman$elm_css$Css$Structure$Output$combinatorToString(combinator),
				$rtfeldman$elm_css$Css$Structure$Output$simpleSelectorSequenceToString(sequence)
			]));
};
var $rtfeldman$elm_css$Css$Structure$Output$selectorToString = function (_v0) {
	var simpleSelectorSequence = _v0.a;
	var chain = _v0.b;
	var pseudoElement = _v0.c;
	var segments = A2(
		$elm$core$List$cons,
		$rtfeldman$elm_css$Css$Structure$Output$simpleSelectorSequenceToString(simpleSelectorSequence),
		A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$selectorChainToString, chain));
	var pseudoElementsString = A2(
		$elm$core$String$join,
		'',
		_List_fromArray(
			[
				A2(
				$elm$core$Maybe$withDefault,
				'',
				A2($elm$core$Maybe$map, $rtfeldman$elm_css$Css$Structure$Output$pseudoElementToString, pseudoElement))
			]));
	return A2(
		$elm$core$String$append,
		A2(
			$elm$core$String$join,
			' ',
			A2(
				$elm$core$List$filter,
				A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$String$isEmpty),
				segments)),
		pseudoElementsString);
};
var $rtfeldman$elm_css$Css$Structure$Output$prettyPrintStyleBlock = F2(
	function (indentLevel, _v0) {
		var firstSelector = _v0.a;
		var otherSelectors = _v0.b;
		var properties = _v0.c;
		var selectorStr = A2(
			$elm$core$String$join,
			', ',
			A2(
				$elm$core$List$map,
				$rtfeldman$elm_css$Css$Structure$Output$selectorToString,
				A2($elm$core$List$cons, firstSelector, otherSelectors)));
		return A2(
			$elm$core$String$join,
			'',
			_List_fromArray(
				[
					selectorStr,
					' {\n',
					indentLevel,
					$rtfeldman$elm_css$Css$Structure$Output$emitProperties(properties),
					'\n',
					indentLevel,
					'}'
				]));
	});
var $rtfeldman$elm_css$Css$Structure$Output$prettyPrintDeclaration = function (decl) {
	switch (decl.$) {
		case 'StyleBlockDeclaration':
			var styleBlock = decl.a;
			return A2($rtfeldman$elm_css$Css$Structure$Output$prettyPrintStyleBlock, $rtfeldman$elm_css$Css$Structure$Output$noIndent, styleBlock);
		case 'MediaRule':
			var mediaQueries = decl.a;
			var styleBlocks = decl.b;
			var query = A2(
				$elm$core$String$join,
				',\n',
				A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$mediaQueryToString, mediaQueries));
			var blocks = A2(
				$elm$core$String$join,
				'\n\n',
				A2(
					$elm$core$List$map,
					A2(
						$elm$core$Basics$composeL,
						$rtfeldman$elm_css$Css$Structure$Output$indent,
						$rtfeldman$elm_css$Css$Structure$Output$prettyPrintStyleBlock($rtfeldman$elm_css$Css$Structure$Output$spaceIndent)),
					styleBlocks));
			return '@media ' + (query + (' {\n' + (blocks + '\n}')));
		case 'SupportsRule':
			return 'TODO';
		case 'DocumentRule':
			return 'TODO';
		case 'PageRule':
			return 'TODO';
		case 'FontFace':
			return 'TODO';
		case 'Keyframes':
			var name = decl.a.name;
			var declaration = decl.a.declaration;
			return '@keyframes ' + (name + (' {\n' + (declaration + '\n}')));
		case 'Viewport':
			return 'TODO';
		case 'CounterStyle':
			return 'TODO';
		default:
			return 'TODO';
	}
};
var $rtfeldman$elm_css$Css$Structure$Output$prettyPrint = function (_v0) {
	var charset = _v0.charset;
	var imports = _v0.imports;
	var namespaces = _v0.namespaces;
	var declarations = _v0.declarations;
	return A2(
		$elm$core$String$join,
		'\n\n',
		A2(
			$elm$core$List$filter,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$String$isEmpty),
			_List_fromArray(
				[
					$rtfeldman$elm_css$Css$Structure$Output$charsetToString(charset),
					A2(
					$elm$core$String$join,
					'\n',
					A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$importToString, imports)),
					A2(
					$elm$core$String$join,
					'\n',
					A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$namespaceToString, namespaces)),
					A2(
					$elm$core$String$join,
					'\n\n',
					A2($elm$core$List$map, $rtfeldman$elm_css$Css$Structure$Output$prettyPrintDeclaration, declarations))
				])));
};
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $rtfeldman$elm_css$Css$Structure$CounterStyle = function (a) {
	return {$: 'CounterStyle', a: a};
};
var $rtfeldman$elm_css$Css$Structure$FontFace = function (a) {
	return {$: 'FontFace', a: a};
};
var $rtfeldman$elm_css$Css$Structure$PageRule = F2(
	function (a, b) {
		return {$: 'PageRule', a: a, b: b};
	});
var $rtfeldman$elm_css$Css$Structure$Selector = F3(
	function (a, b, c) {
		return {$: 'Selector', a: a, b: b, c: c};
	});
var $rtfeldman$elm_css$Css$Structure$StyleBlock = F3(
	function (a, b, c) {
		return {$: 'StyleBlock', a: a, b: b, c: c};
	});
var $rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration = function (a) {
	return {$: 'StyleBlockDeclaration', a: a};
};
var $rtfeldman$elm_css$Css$Structure$SupportsRule = F2(
	function (a, b) {
		return {$: 'SupportsRule', a: a, b: b};
	});
var $rtfeldman$elm_css$Css$Structure$Viewport = function (a) {
	return {$: 'Viewport', a: a};
};
var $rtfeldman$elm_css$Css$Structure$MediaRule = F2(
	function (a, b) {
		return {$: 'MediaRule', a: a, b: b};
	});
var $rtfeldman$elm_css$Css$Structure$mapLast = F2(
	function (update, list) {
		if (!list.b) {
			return list;
		} else {
			if (!list.b.b) {
				var only = list.a;
				return _List_fromArray(
					[
						update(only)
					]);
			} else {
				var first = list.a;
				var rest = list.b;
				return A2(
					$elm$core$List$cons,
					first,
					A2($rtfeldman$elm_css$Css$Structure$mapLast, update, rest));
			}
		}
	});
var $rtfeldman$elm_css$Css$Structure$withPropertyAppended = F2(
	function (property, _v0) {
		var firstSelector = _v0.a;
		var otherSelectors = _v0.b;
		var properties = _v0.c;
		return A3(
			$rtfeldman$elm_css$Css$Structure$StyleBlock,
			firstSelector,
			otherSelectors,
			_Utils_ap(
				properties,
				_List_fromArray(
					[property])));
	});
var $rtfeldman$elm_css$Css$Structure$appendProperty = F2(
	function (property, declarations) {
		if (!declarations.b) {
			return declarations;
		} else {
			if (!declarations.b.b) {
				switch (declarations.a.$) {
					case 'StyleBlockDeclaration':
						var styleBlock = declarations.a.a;
						return _List_fromArray(
							[
								$rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
								A2($rtfeldman$elm_css$Css$Structure$withPropertyAppended, property, styleBlock))
							]);
					case 'MediaRule':
						var _v1 = declarations.a;
						var mediaQueries = _v1.a;
						var styleBlocks = _v1.b;
						return _List_fromArray(
							[
								A2(
								$rtfeldman$elm_css$Css$Structure$MediaRule,
								mediaQueries,
								A2(
									$rtfeldman$elm_css$Css$Structure$mapLast,
									$rtfeldman$elm_css$Css$Structure$withPropertyAppended(property),
									styleBlocks))
							]);
					default:
						return declarations;
				}
			} else {
				var first = declarations.a;
				var rest = declarations.b;
				return A2(
					$elm$core$List$cons,
					first,
					A2($rtfeldman$elm_css$Css$Structure$appendProperty, property, rest));
			}
		}
	});
var $rtfeldman$elm_css$Css$Structure$appendToLastSelector = F2(
	function (f, styleBlock) {
		if (!styleBlock.b.b) {
			var only = styleBlock.a;
			var properties = styleBlock.c;
			return _List_fromArray(
				[
					A3($rtfeldman$elm_css$Css$Structure$StyleBlock, only, _List_Nil, properties),
					A3(
					$rtfeldman$elm_css$Css$Structure$StyleBlock,
					f(only),
					_List_Nil,
					_List_Nil)
				]);
		} else {
			var first = styleBlock.a;
			var rest = styleBlock.b;
			var properties = styleBlock.c;
			var newRest = A2($elm$core$List$map, f, rest);
			var newFirst = f(first);
			return _List_fromArray(
				[
					A3($rtfeldman$elm_css$Css$Structure$StyleBlock, first, rest, properties),
					A3($rtfeldman$elm_css$Css$Structure$StyleBlock, newFirst, newRest, _List_Nil)
				]);
		}
	});
var $rtfeldman$elm_css$Css$Structure$applyPseudoElement = F2(
	function (pseudo, _v0) {
		var sequence = _v0.a;
		var selectors = _v0.b;
		return A3(
			$rtfeldman$elm_css$Css$Structure$Selector,
			sequence,
			selectors,
			$elm$core$Maybe$Just(pseudo));
	});
var $rtfeldman$elm_css$Css$Structure$appendPseudoElementToLastSelector = F2(
	function (pseudo, styleBlock) {
		return A2(
			$rtfeldman$elm_css$Css$Structure$appendToLastSelector,
			$rtfeldman$elm_css$Css$Structure$applyPseudoElement(pseudo),
			styleBlock);
	});
var $rtfeldman$elm_css$Css$Structure$CustomSelector = F2(
	function (a, b) {
		return {$: 'CustomSelector', a: a, b: b};
	});
var $rtfeldman$elm_css$Css$Structure$TypeSelectorSequence = F2(
	function (a, b) {
		return {$: 'TypeSelectorSequence', a: a, b: b};
	});
var $rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence = function (a) {
	return {$: 'UniversalSelectorSequence', a: a};
};
var $rtfeldman$elm_css$Css$Structure$appendRepeatable = F2(
	function (selector, sequence) {
		switch (sequence.$) {
			case 'TypeSelectorSequence':
				var typeSelector = sequence.a;
				var list = sequence.b;
				return A2(
					$rtfeldman$elm_css$Css$Structure$TypeSelectorSequence,
					typeSelector,
					_Utils_ap(
						list,
						_List_fromArray(
							[selector])));
			case 'UniversalSelectorSequence':
				var list = sequence.a;
				return $rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence(
					_Utils_ap(
						list,
						_List_fromArray(
							[selector])));
			default:
				var str = sequence.a;
				var list = sequence.b;
				return A2(
					$rtfeldman$elm_css$Css$Structure$CustomSelector,
					str,
					_Utils_ap(
						list,
						_List_fromArray(
							[selector])));
		}
	});
var $rtfeldman$elm_css$Css$Structure$appendRepeatableWithCombinator = F2(
	function (selector, list) {
		if (!list.b) {
			return _List_Nil;
		} else {
			if (!list.b.b) {
				var _v1 = list.a;
				var combinator = _v1.a;
				var sequence = _v1.b;
				return _List_fromArray(
					[
						_Utils_Tuple2(
						combinator,
						A2($rtfeldman$elm_css$Css$Structure$appendRepeatable, selector, sequence))
					]);
			} else {
				var first = list.a;
				var rest = list.b;
				return A2(
					$elm$core$List$cons,
					first,
					A2($rtfeldman$elm_css$Css$Structure$appendRepeatableWithCombinator, selector, rest));
			}
		}
	});
var $rtfeldman$elm_css$Css$Structure$appendRepeatableSelector = F2(
	function (repeatableSimpleSelector, selector) {
		if (!selector.b.b) {
			var sequence = selector.a;
			var pseudoElement = selector.c;
			return A3(
				$rtfeldman$elm_css$Css$Structure$Selector,
				A2($rtfeldman$elm_css$Css$Structure$appendRepeatable, repeatableSimpleSelector, sequence),
				_List_Nil,
				pseudoElement);
		} else {
			var firstSelector = selector.a;
			var tuples = selector.b;
			var pseudoElement = selector.c;
			return A3(
				$rtfeldman$elm_css$Css$Structure$Selector,
				firstSelector,
				A2($rtfeldman$elm_css$Css$Structure$appendRepeatableWithCombinator, repeatableSimpleSelector, tuples),
				pseudoElement);
		}
	});
var $rtfeldman$elm_css$Css$Structure$appendRepeatableToLastSelector = F2(
	function (selector, styleBlock) {
		return A2(
			$rtfeldman$elm_css$Css$Structure$appendToLastSelector,
			$rtfeldman$elm_css$Css$Structure$appendRepeatableSelector(selector),
			styleBlock);
	});
var $rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors = function (declarations) {
	collectSelectors:
	while (true) {
		if (!declarations.b) {
			return _List_Nil;
		} else {
			if (declarations.a.$ === 'StyleBlockDeclaration') {
				var _v1 = declarations.a.a;
				var firstSelector = _v1.a;
				var otherSelectors = _v1.b;
				var rest = declarations.b;
				return _Utils_ap(
					A2($elm$core$List$cons, firstSelector, otherSelectors),
					$rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors(rest));
			} else {
				var rest = declarations.b;
				var $temp$declarations = rest;
				declarations = $temp$declarations;
				continue collectSelectors;
			}
		}
	}
};
var $rtfeldman$elm_css$Css$Structure$DocumentRule = F5(
	function (a, b, c, d, e) {
		return {$: 'DocumentRule', a: a, b: b, c: c, d: d, e: e};
	});
var $rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock = F2(
	function (update, declarations) {
		_v0$12:
		while (true) {
			if (!declarations.b) {
				return declarations;
			} else {
				if (!declarations.b.b) {
					switch (declarations.a.$) {
						case 'StyleBlockDeclaration':
							var styleBlock = declarations.a.a;
							return A2(
								$elm$core$List$map,
								$rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration,
								update(styleBlock));
						case 'MediaRule':
							if (declarations.a.b.b) {
								if (!declarations.a.b.b.b) {
									var _v1 = declarations.a;
									var mediaQueries = _v1.a;
									var _v2 = _v1.b;
									var styleBlock = _v2.a;
									return _List_fromArray(
										[
											A2(
											$rtfeldman$elm_css$Css$Structure$MediaRule,
											mediaQueries,
											update(styleBlock))
										]);
								} else {
									var _v3 = declarations.a;
									var mediaQueries = _v3.a;
									var _v4 = _v3.b;
									var first = _v4.a;
									var rest = _v4.b;
									var _v5 = A2(
										$rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock,
										update,
										_List_fromArray(
											[
												A2($rtfeldman$elm_css$Css$Structure$MediaRule, mediaQueries, rest)
											]));
									if ((_v5.b && (_v5.a.$ === 'MediaRule')) && (!_v5.b.b)) {
										var _v6 = _v5.a;
										var newMediaQueries = _v6.a;
										var newStyleBlocks = _v6.b;
										return _List_fromArray(
											[
												A2(
												$rtfeldman$elm_css$Css$Structure$MediaRule,
												newMediaQueries,
												A2($elm$core$List$cons, first, newStyleBlocks))
											]);
									} else {
										var newDeclarations = _v5;
										return newDeclarations;
									}
								}
							} else {
								break _v0$12;
							}
						case 'SupportsRule':
							var _v7 = declarations.a;
							var str = _v7.a;
							var nestedDeclarations = _v7.b;
							return _List_fromArray(
								[
									A2(
									$rtfeldman$elm_css$Css$Structure$SupportsRule,
									str,
									A2($rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock, update, nestedDeclarations))
								]);
						case 'DocumentRule':
							var _v8 = declarations.a;
							var str1 = _v8.a;
							var str2 = _v8.b;
							var str3 = _v8.c;
							var str4 = _v8.d;
							var styleBlock = _v8.e;
							return A2(
								$elm$core$List$map,
								A4($rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4),
								update(styleBlock));
						case 'PageRule':
							var _v9 = declarations.a;
							return declarations;
						case 'FontFace':
							return declarations;
						case 'Keyframes':
							return declarations;
						case 'Viewport':
							return declarations;
						case 'CounterStyle':
							return declarations;
						default:
							return declarations;
					}
				} else {
					break _v0$12;
				}
			}
		}
		var first = declarations.a;
		var rest = declarations.b;
		return A2(
			$elm$core$List$cons,
			first,
			A2($rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock, update, rest));
	});
var $elm$core$String$cons = _String_cons;
var $Skinney$murmur3$Murmur3$HashData = F4(
	function (shift, seed, hash, charsProcessed) {
		return {charsProcessed: charsProcessed, hash: hash, seed: seed, shift: shift};
	});
var $Skinney$murmur3$Murmur3$c1 = 3432918353;
var $Skinney$murmur3$Murmur3$c2 = 461845907;
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $Skinney$murmur3$Murmur3$multiplyBy = F2(
	function (b, a) {
		return ((a & 65535) * b) + ((((a >>> 16) * b) & 65535) << 16);
	});
var $elm$core$Basics$neq = _Utils_notEqual;
var $elm$core$Bitwise$or = _Bitwise_or;
var $Skinney$murmur3$Murmur3$rotlBy = F2(
	function (b, a) {
		return (a << b) | (a >>> (32 - b));
	});
var $elm$core$Bitwise$xor = _Bitwise_xor;
var $Skinney$murmur3$Murmur3$finalize = function (data) {
	var acc = (!(!data.hash)) ? (data.seed ^ A2(
		$Skinney$murmur3$Murmur3$multiplyBy,
		$Skinney$murmur3$Murmur3$c2,
		A2(
			$Skinney$murmur3$Murmur3$rotlBy,
			15,
			A2($Skinney$murmur3$Murmur3$multiplyBy, $Skinney$murmur3$Murmur3$c1, data.hash)))) : data.seed;
	var h0 = acc ^ data.charsProcessed;
	var h1 = A2($Skinney$murmur3$Murmur3$multiplyBy, 2246822507, h0 ^ (h0 >>> 16));
	var h2 = A2($Skinney$murmur3$Murmur3$multiplyBy, 3266489909, h1 ^ (h1 >>> 13));
	return (h2 ^ (h2 >>> 16)) >>> 0;
};
var $elm$core$String$foldl = _String_foldl;
var $Skinney$murmur3$Murmur3$mix = F2(
	function (h1, k1) {
		return A2(
			$Skinney$murmur3$Murmur3$multiplyBy,
			5,
			A2(
				$Skinney$murmur3$Murmur3$rotlBy,
				13,
				h1 ^ A2(
					$Skinney$murmur3$Murmur3$multiplyBy,
					$Skinney$murmur3$Murmur3$c2,
					A2(
						$Skinney$murmur3$Murmur3$rotlBy,
						15,
						A2($Skinney$murmur3$Murmur3$multiplyBy, $Skinney$murmur3$Murmur3$c1, k1))))) + 3864292196;
	});
var $Skinney$murmur3$Murmur3$hashFold = F2(
	function (c, data) {
		var res = data.hash | ((255 & $elm$core$Char$toCode(c)) << data.shift);
		var _v0 = data.shift;
		if (_v0 === 24) {
			return {
				charsProcessed: data.charsProcessed + 1,
				hash: 0,
				seed: A2($Skinney$murmur3$Murmur3$mix, data.seed, res),
				shift: 0
			};
		} else {
			return {charsProcessed: data.charsProcessed + 1, hash: res, seed: data.seed, shift: data.shift + 8};
		}
	});
var $Skinney$murmur3$Murmur3$hashString = F2(
	function (seed, str) {
		return $Skinney$murmur3$Murmur3$finalize(
			A3(
				$elm$core$String$foldl,
				$Skinney$murmur3$Murmur3$hashFold,
				A4($Skinney$murmur3$Murmur3$HashData, 0, seed, 0, 0),
				str));
	});
var $rtfeldman$elm_css$Hash$murmurSeed = 15739;
var $elm$core$String$fromList = _String_fromList;
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$core$Basics$modBy = _Basics_modBy;
var $rtfeldman$elm_hex$Hex$unsafeToDigit = function (num) {
	unsafeToDigit:
	while (true) {
		switch (num) {
			case 0:
				return _Utils_chr('0');
			case 1:
				return _Utils_chr('1');
			case 2:
				return _Utils_chr('2');
			case 3:
				return _Utils_chr('3');
			case 4:
				return _Utils_chr('4');
			case 5:
				return _Utils_chr('5');
			case 6:
				return _Utils_chr('6');
			case 7:
				return _Utils_chr('7');
			case 8:
				return _Utils_chr('8');
			case 9:
				return _Utils_chr('9');
			case 10:
				return _Utils_chr('a');
			case 11:
				return _Utils_chr('b');
			case 12:
				return _Utils_chr('c');
			case 13:
				return _Utils_chr('d');
			case 14:
				return _Utils_chr('e');
			case 15:
				return _Utils_chr('f');
			default:
				var $temp$num = num;
				num = $temp$num;
				continue unsafeToDigit;
		}
	}
};
var $rtfeldman$elm_hex$Hex$unsafePositiveToDigits = F2(
	function (digits, num) {
		unsafePositiveToDigits:
		while (true) {
			if (num < 16) {
				return A2(
					$elm$core$List$cons,
					$rtfeldman$elm_hex$Hex$unsafeToDigit(num),
					digits);
			} else {
				var $temp$digits = A2(
					$elm$core$List$cons,
					$rtfeldman$elm_hex$Hex$unsafeToDigit(
						A2($elm$core$Basics$modBy, 16, num)),
					digits),
					$temp$num = (num / 16) | 0;
				digits = $temp$digits;
				num = $temp$num;
				continue unsafePositiveToDigits;
			}
		}
	});
var $rtfeldman$elm_hex$Hex$toString = function (num) {
	return $elm$core$String$fromList(
		(num < 0) ? A2(
			$elm$core$List$cons,
			_Utils_chr('-'),
			A2($rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, -num)) : A2($rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, num));
};
var $rtfeldman$elm_css$Hash$fromString = function (str) {
	return A2(
		$elm$core$String$cons,
		_Utils_chr('_'),
		$rtfeldman$elm_hex$Hex$toString(
			A2($Skinney$murmur3$Murmur3$hashString, $rtfeldman$elm_css$Hash$murmurSeed, str)));
};
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$last = function (list) {
	last:
	while (true) {
		if (!list.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			if (!list.b.b) {
				var singleton = list.a;
				return $elm$core$Maybe$Just(singleton);
			} else {
				var rest = list.b;
				var $temp$list = rest;
				list = $temp$list;
				continue last;
			}
		}
	}
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$lastDeclaration = function (declarations) {
	lastDeclaration:
	while (true) {
		if (!declarations.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			if (!declarations.b.b) {
				var x = declarations.a;
				return $elm$core$Maybe$Just(
					_List_fromArray(
						[x]));
			} else {
				var xs = declarations.b;
				var $temp$declarations = xs;
				declarations = $temp$declarations;
				continue lastDeclaration;
			}
		}
	}
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$oneOf = function (maybes) {
	oneOf:
	while (true) {
		if (!maybes.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			var maybe = maybes.a;
			var rest = maybes.b;
			if (maybe.$ === 'Nothing') {
				var $temp$maybes = rest;
				maybes = $temp$maybes;
				continue oneOf;
			} else {
				return maybe;
			}
		}
	}
};
var $rtfeldman$elm_css$Css$Structure$FontFeatureValues = function (a) {
	return {$: 'FontFeatureValues', a: a};
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$resolveFontFeatureValues = function (tuples) {
	var expandTuples = function (tuplesToExpand) {
		if (!tuplesToExpand.b) {
			return _List_Nil;
		} else {
			var properties = tuplesToExpand.a;
			var rest = tuplesToExpand.b;
			return A2(
				$elm$core$List$cons,
				properties,
				expandTuples(rest));
		}
	};
	var newTuples = expandTuples(tuples);
	return _List_fromArray(
		[
			$rtfeldman$elm_css$Css$Structure$FontFeatureValues(newTuples)
		]);
};
var $rtfeldman$elm_css$Css$Structure$styleBlockToMediaRule = F2(
	function (mediaQueries, declaration) {
		if (declaration.$ === 'StyleBlockDeclaration') {
			var styleBlock = declaration.a;
			return A2(
				$rtfeldman$elm_css$Css$Structure$MediaRule,
				mediaQueries,
				_List_fromArray(
					[styleBlock]));
		} else {
			return declaration;
		}
	});
var $elm$core$List$tail = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(xs);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule = F5(
	function (str1, str2, str3, str4, declaration) {
		if (declaration.$ === 'StyleBlockDeclaration') {
			var structureStyleBlock = declaration.a;
			return A5($rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4, structureStyleBlock);
		} else {
			return declaration;
		}
	});
var $rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule = F2(
	function (mediaQueries, declaration) {
		switch (declaration.$) {
			case 'StyleBlockDeclaration':
				var structureStyleBlock = declaration.a;
				return A2(
					$rtfeldman$elm_css$Css$Structure$MediaRule,
					mediaQueries,
					_List_fromArray(
						[structureStyleBlock]));
			case 'MediaRule':
				var newMediaQueries = declaration.a;
				var structureStyleBlocks = declaration.b;
				return A2(
					$rtfeldman$elm_css$Css$Structure$MediaRule,
					_Utils_ap(mediaQueries, newMediaQueries),
					structureStyleBlocks);
			case 'SupportsRule':
				var str = declaration.a;
				var declarations = declaration.b;
				return A2(
					$rtfeldman$elm_css$Css$Structure$SupportsRule,
					str,
					A2(
						$elm$core$List$map,
						$rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule(mediaQueries),
						declarations));
			case 'DocumentRule':
				var str1 = declaration.a;
				var str2 = declaration.b;
				var str3 = declaration.c;
				var str4 = declaration.d;
				var structureStyleBlock = declaration.e;
				return A5($rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4, structureStyleBlock);
			case 'PageRule':
				return declaration;
			case 'FontFace':
				return declaration;
			case 'Keyframes':
				return declaration;
			case 'Viewport':
				return declaration;
			case 'CounterStyle':
				return declaration;
			default:
				return declaration;
		}
	});
var $rtfeldman$elm_css$Css$Preprocess$unwrapSnippet = function (_v0) {
	var declarations = _v0.a;
	return declarations;
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$applyNestedStylesToLast = F4(
	function (nestedStyles, rest, f, declarations) {
		var withoutParent = function (decls) {
			return A2(
				$elm$core$Maybe$withDefault,
				_List_Nil,
				$elm$core$List$tail(decls));
		};
		var nextResult = A2(
			$rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
			rest,
			A2(
				$elm$core$Maybe$withDefault,
				_List_Nil,
				$rtfeldman$elm_css$Css$Preprocess$Resolve$lastDeclaration(declarations)));
		var newDeclarations = function () {
			var _v14 = _Utils_Tuple2(
				$elm$core$List$head(nextResult),
				$rtfeldman$elm_css$Css$Preprocess$Resolve$last(declarations));
			if ((_v14.a.$ === 'Just') && (_v14.b.$ === 'Just')) {
				var nextResultParent = _v14.a.a;
				var originalParent = _v14.b.a;
				return _Utils_ap(
					A2(
						$elm$core$List$take,
						$elm$core$List$length(declarations) - 1,
						declarations),
					_List_fromArray(
						[
							(!_Utils_eq(originalParent, nextResultParent)) ? nextResultParent : originalParent
						]));
			} else {
				return declarations;
			}
		}();
		var insertStylesToNestedDecl = function (lastDecl) {
			return $elm$core$List$concat(
				A2(
					$rtfeldman$elm_css$Css$Structure$mapLast,
					$rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles(nestedStyles),
					A2(
						$elm$core$List$map,
						$elm$core$List$singleton,
						A2($rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock, f, lastDecl))));
		};
		var initialResult = A2(
			$elm$core$Maybe$withDefault,
			_List_Nil,
			A2(
				$elm$core$Maybe$map,
				insertStylesToNestedDecl,
				$rtfeldman$elm_css$Css$Preprocess$Resolve$lastDeclaration(declarations)));
		return _Utils_ap(
			newDeclarations,
			_Utils_ap(
				withoutParent(initialResult),
				withoutParent(nextResult)));
	});
var $rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles = F2(
	function (styles, declarations) {
		if (!styles.b) {
			return declarations;
		} else {
			switch (styles.a.$) {
				case 'AppendProperty':
					var property = styles.a.a;
					var rest = styles.b;
					return A2(
						$rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
						rest,
						A2($rtfeldman$elm_css$Css$Structure$appendProperty, property, declarations));
				case 'ExtendSelector':
					var _v4 = styles.a;
					var selector = _v4.a;
					var nestedStyles = _v4.b;
					var rest = styles.b;
					return A4(
						$rtfeldman$elm_css$Css$Preprocess$Resolve$applyNestedStylesToLast,
						nestedStyles,
						rest,
						$rtfeldman$elm_css$Css$Structure$appendRepeatableToLastSelector(selector),
						declarations);
				case 'NestSnippet':
					var _v5 = styles.a;
					var selectorCombinator = _v5.a;
					var snippets = _v5.b;
					var rest = styles.b;
					var chain = F2(
						function (_v9, _v10) {
							var originalSequence = _v9.a;
							var originalTuples = _v9.b;
							var originalPseudoElement = _v9.c;
							var newSequence = _v10.a;
							var newTuples = _v10.b;
							var newPseudoElement = _v10.c;
							return A3(
								$rtfeldman$elm_css$Css$Structure$Selector,
								originalSequence,
								_Utils_ap(
									originalTuples,
									A2(
										$elm$core$List$cons,
										_Utils_Tuple2(selectorCombinator, newSequence),
										newTuples)),
								$rtfeldman$elm_css$Css$Preprocess$Resolve$oneOf(
									_List_fromArray(
										[newPseudoElement, originalPseudoElement])));
						});
					var expandDeclaration = function (declaration) {
						switch (declaration.$) {
							case 'StyleBlockDeclaration':
								var _v7 = declaration.a;
								var firstSelector = _v7.a;
								var otherSelectors = _v7.b;
								var nestedStyles = _v7.c;
								var newSelectors = A2(
									$elm$core$List$concatMap,
									function (originalSelector) {
										return A2(
											$elm$core$List$map,
											chain(originalSelector),
											A2($elm$core$List$cons, firstSelector, otherSelectors));
									},
									$rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors(declarations));
								var newDeclarations = function () {
									if (!newSelectors.b) {
										return _List_Nil;
									} else {
										var first = newSelectors.a;
										var remainder = newSelectors.b;
										return _List_fromArray(
											[
												$rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
												A3($rtfeldman$elm_css$Css$Structure$StyleBlock, first, remainder, _List_Nil))
											]);
									}
								}();
								return A2($rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles, nestedStyles, newDeclarations);
							case 'MediaRule':
								var mediaQueries = declaration.a;
								var styleBlocks = declaration.b;
								return A2($rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule, mediaQueries, styleBlocks);
							case 'SupportsRule':
								var str = declaration.a;
								var otherSnippets = declaration.b;
								return A2($rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule, str, otherSnippets);
							case 'DocumentRule':
								var str1 = declaration.a;
								var str2 = declaration.b;
								var str3 = declaration.c;
								var str4 = declaration.d;
								var styleBlock = declaration.e;
								return A2(
									$elm$core$List$map,
									A4($rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule, str1, str2, str3, str4),
									$rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
							case 'PageRule':
								var str = declaration.a;
								var properties = declaration.b;
								return _List_fromArray(
									[
										A2($rtfeldman$elm_css$Css$Structure$PageRule, str, properties)
									]);
							case 'FontFace':
								var properties = declaration.a;
								return _List_fromArray(
									[
										$rtfeldman$elm_css$Css$Structure$FontFace(properties)
									]);
							case 'Viewport':
								var properties = declaration.a;
								return _List_fromArray(
									[
										$rtfeldman$elm_css$Css$Structure$Viewport(properties)
									]);
							case 'CounterStyle':
								var properties = declaration.a;
								return _List_fromArray(
									[
										$rtfeldman$elm_css$Css$Structure$CounterStyle(properties)
									]);
							default:
								var tuples = declaration.a;
								return $rtfeldman$elm_css$Css$Preprocess$Resolve$resolveFontFeatureValues(tuples);
						}
					};
					return $elm$core$List$concat(
						_Utils_ap(
							_List_fromArray(
								[
									A2($rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles, rest, declarations)
								]),
							A2(
								$elm$core$List$map,
								expandDeclaration,
								A2($elm$core$List$concatMap, $rtfeldman$elm_css$Css$Preprocess$unwrapSnippet, snippets))));
				case 'WithPseudoElement':
					var _v11 = styles.a;
					var pseudoElement = _v11.a;
					var nestedStyles = _v11.b;
					var rest = styles.b;
					return A4(
						$rtfeldman$elm_css$Css$Preprocess$Resolve$applyNestedStylesToLast,
						nestedStyles,
						rest,
						$rtfeldman$elm_css$Css$Structure$appendPseudoElementToLastSelector(pseudoElement),
						declarations);
				case 'WithKeyframes':
					var str = styles.a.a;
					var rest = styles.b;
					var name = $rtfeldman$elm_css$Hash$fromString(str);
					var newProperty = 'animation-name:' + name;
					var newDeclarations = A2(
						$rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
						rest,
						A2($rtfeldman$elm_css$Css$Structure$appendProperty, newProperty, declarations));
					return A2(
						$elm$core$List$append,
						newDeclarations,
						_List_fromArray(
							[
								$rtfeldman$elm_css$Css$Structure$Keyframes(
								{declaration: str, name: name})
							]));
				case 'WithMedia':
					var _v12 = styles.a;
					var mediaQueries = _v12.a;
					var nestedStyles = _v12.b;
					var rest = styles.b;
					var extraDeclarations = function () {
						var _v13 = $rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors(declarations);
						if (!_v13.b) {
							return _List_Nil;
						} else {
							var firstSelector = _v13.a;
							var otherSelectors = _v13.b;
							return A2(
								$elm$core$List$map,
								$rtfeldman$elm_css$Css$Structure$styleBlockToMediaRule(mediaQueries),
								A2(
									$rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
									nestedStyles,
									$elm$core$List$singleton(
										$rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
											A3($rtfeldman$elm_css$Css$Structure$StyleBlock, firstSelector, otherSelectors, _List_Nil)))));
						}
					}();
					return _Utils_ap(
						A2($rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles, rest, declarations),
						extraDeclarations);
				default:
					var otherStyles = styles.a.a;
					var rest = styles.b;
					return A2(
						$rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
						_Utils_ap(otherStyles, rest),
						declarations);
			}
		}
	});
var $rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock = function (_v2) {
	var firstSelector = _v2.a;
	var otherSelectors = _v2.b;
	var styles = _v2.c;
	return A2(
		$rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
		styles,
		_List_fromArray(
			[
				$rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
				A3($rtfeldman$elm_css$Css$Structure$StyleBlock, firstSelector, otherSelectors, _List_Nil))
			]));
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$extract = function (snippetDeclarations) {
	if (!snippetDeclarations.b) {
		return _List_Nil;
	} else {
		var first = snippetDeclarations.a;
		var rest = snippetDeclarations.b;
		return _Utils_ap(
			$rtfeldman$elm_css$Css$Preprocess$Resolve$toDeclarations(first),
			$rtfeldman$elm_css$Css$Preprocess$Resolve$extract(rest));
	}
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule = F2(
	function (mediaQueries, styleBlocks) {
		var handleStyleBlock = function (styleBlock) {
			return A2(
				$elm$core$List$map,
				$rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule(mediaQueries),
				$rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
		};
		return A2($elm$core$List$concatMap, handleStyleBlock, styleBlocks);
	});
var $rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule = F2(
	function (str, snippets) {
		var declarations = $rtfeldman$elm_css$Css$Preprocess$Resolve$extract(
			A2($elm$core$List$concatMap, $rtfeldman$elm_css$Css$Preprocess$unwrapSnippet, snippets));
		return _List_fromArray(
			[
				A2($rtfeldman$elm_css$Css$Structure$SupportsRule, str, declarations)
			]);
	});
var $rtfeldman$elm_css$Css$Preprocess$Resolve$toDeclarations = function (snippetDeclaration) {
	switch (snippetDeclaration.$) {
		case 'StyleBlockDeclaration':
			var styleBlock = snippetDeclaration.a;
			return $rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock);
		case 'MediaRule':
			var mediaQueries = snippetDeclaration.a;
			var styleBlocks = snippetDeclaration.b;
			return A2($rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule, mediaQueries, styleBlocks);
		case 'SupportsRule':
			var str = snippetDeclaration.a;
			var snippets = snippetDeclaration.b;
			return A2($rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule, str, snippets);
		case 'DocumentRule':
			var str1 = snippetDeclaration.a;
			var str2 = snippetDeclaration.b;
			var str3 = snippetDeclaration.c;
			var str4 = snippetDeclaration.d;
			var styleBlock = snippetDeclaration.e;
			return A2(
				$elm$core$List$map,
				A4($rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule, str1, str2, str3, str4),
				$rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
		case 'PageRule':
			var str = snippetDeclaration.a;
			var properties = snippetDeclaration.b;
			return _List_fromArray(
				[
					A2($rtfeldman$elm_css$Css$Structure$PageRule, str, properties)
				]);
		case 'FontFace':
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					$rtfeldman$elm_css$Css$Structure$FontFace(properties)
				]);
		case 'Viewport':
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					$rtfeldman$elm_css$Css$Structure$Viewport(properties)
				]);
		case 'CounterStyle':
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					$rtfeldman$elm_css$Css$Structure$CounterStyle(properties)
				]);
		default:
			var tuples = snippetDeclaration.a;
			return $rtfeldman$elm_css$Css$Preprocess$Resolve$resolveFontFeatureValues(tuples);
	}
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$toStructure = function (_v0) {
	var charset = _v0.charset;
	var imports = _v0.imports;
	var namespaces = _v0.namespaces;
	var snippets = _v0.snippets;
	var declarations = $rtfeldman$elm_css$Css$Preprocess$Resolve$extract(
		A2($elm$core$List$concatMap, $rtfeldman$elm_css$Css$Preprocess$unwrapSnippet, snippets));
	return {charset: charset, declarations: declarations, imports: imports, namespaces: namespaces};
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$compileHelp = function (sheet) {
	return $rtfeldman$elm_css$Css$Structure$Output$prettyPrint(
		$rtfeldman$elm_css$Css$Structure$compactStylesheet(
			$rtfeldman$elm_css$Css$Preprocess$Resolve$toStructure(sheet)));
};
var $rtfeldman$elm_css$Css$Preprocess$Resolve$compile = function (styles) {
	return A2(
		$elm$core$String$join,
		'\n\n',
		A2($elm$core$List$map, $rtfeldman$elm_css$Css$Preprocess$Resolve$compileHelp, styles));
};
var $rtfeldman$elm_css$Css$Structure$ClassSelector = function (a) {
	return {$: 'ClassSelector', a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $rtfeldman$elm_css$Css$Preprocess$Snippet = function (a) {
	return {$: 'Snippet', a: a};
};
var $rtfeldman$elm_css$Css$Preprocess$StyleBlock = F3(
	function (a, b, c) {
		return {$: 'StyleBlock', a: a, b: b, c: c};
	});
var $rtfeldman$elm_css$Css$Preprocess$StyleBlockDeclaration = function (a) {
	return {$: 'StyleBlockDeclaration', a: a};
};
var $rtfeldman$elm_css$VirtualDom$Styled$makeSnippet = F2(
	function (styles, sequence) {
		var selector = A3($rtfeldman$elm_css$Css$Structure$Selector, sequence, _List_Nil, $elm$core$Maybe$Nothing);
		return $rtfeldman$elm_css$Css$Preprocess$Snippet(
			_List_fromArray(
				[
					$rtfeldman$elm_css$Css$Preprocess$StyleBlockDeclaration(
					A3($rtfeldman$elm_css$Css$Preprocess$StyleBlock, selector, _List_Nil, styles))
				]));
	});
var $rtfeldman$elm_css$VirtualDom$Styled$snippetFromPair = function (_v0) {
	var classname = _v0.a;
	var styles = _v0.b;
	return A2(
		$rtfeldman$elm_css$VirtualDom$Styled$makeSnippet,
		styles,
		$rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence(
			_List_fromArray(
				[
					$rtfeldman$elm_css$Css$Structure$ClassSelector(classname)
				])));
};
var $rtfeldman$elm_css$Css$Preprocess$stylesheet = function (snippets) {
	return {charset: $elm$core$Maybe$Nothing, imports: _List_Nil, namespaces: _List_Nil, snippets: snippets};
};
var $rtfeldman$elm_css$VirtualDom$Styled$toDeclaration = function (dict) {
	return $rtfeldman$elm_css$Css$Preprocess$Resolve$compile(
		$elm$core$List$singleton(
			$rtfeldman$elm_css$Css$Preprocess$stylesheet(
				A2(
					$elm$core$List$map,
					$rtfeldman$elm_css$VirtualDom$Styled$snippetFromPair,
					$elm$core$Dict$toList(dict)))));
};
var $rtfeldman$elm_css$VirtualDom$Styled$toStyleNode = function (styles) {
	return A3(
		$elm$virtual_dom$VirtualDom$node,
		'style',
		_List_Nil,
		$elm$core$List$singleton(
			$elm$virtual_dom$VirtualDom$text(
				$rtfeldman$elm_css$VirtualDom$Styled$toDeclaration(styles))));
};
var $rtfeldman$elm_css$VirtualDom$Styled$unstyle = F3(
	function (elemType, properties, children) {
		var unstyledProperties = A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = $rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _v0 = A3(
			$elm$core$List$foldl,
			$rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			children);
		var childNodes = _v0.a;
		var styles = _v0.b;
		var styleNode = $rtfeldman$elm_css$VirtualDom$Styled$toStyleNode(styles);
		return A3(
			$elm$virtual_dom$VirtualDom$node,
			elemType,
			unstyledProperties,
			A2(
				$elm$core$List$cons,
				styleNode,
				$elm$core$List$reverse(childNodes)));
	});
var $rtfeldman$elm_css$VirtualDom$Styled$containsKey = F2(
	function (key, pairs) {
		containsKey:
		while (true) {
			if (!pairs.b) {
				return false;
			} else {
				var _v1 = pairs.a;
				var str = _v1.a;
				var rest = pairs.b;
				if (_Utils_eq(key, str)) {
					return true;
				} else {
					var $temp$key = key,
						$temp$pairs = rest;
					key = $temp$key;
					pairs = $temp$pairs;
					continue containsKey;
				}
			}
		}
	});
var $rtfeldman$elm_css$VirtualDom$Styled$getUnusedKey = F2(
	function (_default, pairs) {
		getUnusedKey:
		while (true) {
			if (!pairs.b) {
				return _default;
			} else {
				var _v1 = pairs.a;
				var firstKey = _v1.a;
				var rest = pairs.b;
				var newKey = '_' + firstKey;
				if (A2($rtfeldman$elm_css$VirtualDom$Styled$containsKey, newKey, rest)) {
					var $temp$default = newKey,
						$temp$pairs = rest;
					_default = $temp$default;
					pairs = $temp$pairs;
					continue getUnusedKey;
				} else {
					return newKey;
				}
			}
		}
	});
var $rtfeldman$elm_css$VirtualDom$Styled$toKeyedStyleNode = F2(
	function (allStyles, keyedChildNodes) {
		var styleNodeKey = A2($rtfeldman$elm_css$VirtualDom$Styled$getUnusedKey, '_', keyedChildNodes);
		var finalNode = $rtfeldman$elm_css$VirtualDom$Styled$toStyleNode(allStyles);
		return _Utils_Tuple2(styleNodeKey, finalNode);
	});
var $rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyed = F3(
	function (elemType, properties, keyedChildren) {
		var unstyledProperties = A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = $rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _v0 = A3(
			$elm$core$List$foldl,
			$rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			keyedChildren);
		var keyedChildNodes = _v0.a;
		var styles = _v0.b;
		var keyedStyleNode = A2($rtfeldman$elm_css$VirtualDom$Styled$toKeyedStyleNode, styles, keyedChildNodes);
		return A3(
			$elm$virtual_dom$VirtualDom$keyedNode,
			elemType,
			unstyledProperties,
			A2(
				$elm$core$List$cons,
				keyedStyleNode,
				$elm$core$List$reverse(keyedChildNodes)));
	});
var $rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyedNS = F4(
	function (ns, elemType, properties, keyedChildren) {
		var unstyledProperties = A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = $rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _v0 = A3(
			$elm$core$List$foldl,
			$rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			keyedChildren);
		var keyedChildNodes = _v0.a;
		var styles = _v0.b;
		var keyedStyleNode = A2($rtfeldman$elm_css$VirtualDom$Styled$toKeyedStyleNode, styles, keyedChildNodes);
		return A4(
			$elm$virtual_dom$VirtualDom$keyedNodeNS,
			ns,
			elemType,
			unstyledProperties,
			A2(
				$elm$core$List$cons,
				keyedStyleNode,
				$elm$core$List$reverse(keyedChildNodes)));
	});
var $rtfeldman$elm_css$VirtualDom$Styled$unstyleNS = F4(
	function (ns, elemType, properties, children) {
		var unstyledProperties = A2($elm$core$List$map, $rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = $rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _v0 = A3(
			$elm$core$List$foldl,
			$rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			children);
		var childNodes = _v0.a;
		var styles = _v0.b;
		var styleNode = $rtfeldman$elm_css$VirtualDom$Styled$toStyleNode(styles);
		return A4(
			$elm$virtual_dom$VirtualDom$nodeNS,
			ns,
			elemType,
			unstyledProperties,
			A2(
				$elm$core$List$cons,
				styleNode,
				$elm$core$List$reverse(childNodes)));
	});
var $rtfeldman$elm_css$VirtualDom$Styled$toUnstyled = function (vdom) {
	switch (vdom.$) {
		case 'Unstyled':
			var plainNode = vdom.a;
			return plainNode;
		case 'Node':
			var elemType = vdom.a;
			var properties = vdom.b;
			var children = vdom.c;
			return A3($rtfeldman$elm_css$VirtualDom$Styled$unstyle, elemType, properties, children);
		case 'NodeNS':
			var ns = vdom.a;
			var elemType = vdom.b;
			var properties = vdom.c;
			var children = vdom.d;
			return A4($rtfeldman$elm_css$VirtualDom$Styled$unstyleNS, ns, elemType, properties, children);
		case 'KeyedNode':
			var elemType = vdom.a;
			var properties = vdom.b;
			var children = vdom.c;
			return A3($rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyed, elemType, properties, children);
		default:
			var ns = vdom.a;
			var elemType = vdom.b;
			var properties = vdom.c;
			var children = vdom.d;
			return A4($rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyedNS, ns, elemType, properties, children);
	}
};
var $rtfeldman$elm_css$Html$Styled$toUnstyled = $rtfeldman$elm_css$VirtualDom$Styled$toUnstyled;
var $author$project$Browserless$browserlessView = function (_v0) {
	var viewState = _v0.viewState;
	var profile = _v0.profile;
	var environment = _v0.environment;
	return $rtfeldman$elm_css$Html$Styled$toUnstyled(
		A3($rtfeldman$elm_css$Html$Styled$node, 'AbsoluteLayout', _List_Nil, _List_Nil));
};
var $elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var $elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $elm$url$Url$Http = {$: 'Http'};
var $elm$url$Url$Https = {$: 'Https'};
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 'Nothing') {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Http,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Https,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0.a;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(_Utils_Tuple0);
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0.a;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return _Utils_Tuple0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0.a;
		return $elm$core$Task$Perform(
			A2($elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2($elm$core$Task$map, toMessage, task)));
	});
var $elm$browser$Browser$element = _Browser_element;
var $elm$json$Json$Decode$index = _Json_decodeIndex;
var $author$project$Main$NewUrl = function (a) {
	return {$: 'NewUrl', a: a};
};
var $author$project$Main$SetZoneAndTime = F2(
	function (a, b) {
		return {$: 'SetZoneAndTime', a: a, b: b};
	});
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $author$project$SmartTime$Duration$Duration = function (a) {
	return {$: 'Duration', a: a};
};
var $author$project$SmartTime$Duration$millisecondLength = 1;
var $author$project$SmartTime$Duration$secondLength = 1000 * $author$project$SmartTime$Duration$millisecondLength;
var $author$project$SmartTime$Duration$minuteLength = 60 * $author$project$SmartTime$Duration$secondLength;
var $elm$core$Basics$round = _Basics_round;
var $author$project$SmartTime$Duration$fromMinutes = function (_float) {
	return $author$project$SmartTime$Duration$Duration(
		$elm$core$Basics$round(_float * $author$project$SmartTime$Duration$minuteLength));
};
var $author$project$SmartTime$Human$Moment$utc = {
	defaultOffset: $author$project$SmartTime$Duration$fromMinutes(0),
	history: _List_Nil,
	name: 'Universal'
};
var $author$project$SmartTime$Moment$Moment = function (a) {
	return {$: 'Moment', a: a};
};
var $author$project$SmartTime$Duration$zero = $author$project$SmartTime$Duration$Duration(0);
var $author$project$SmartTime$Moment$zero = $author$project$SmartTime$Moment$Moment($author$project$SmartTime$Duration$zero);
var $author$project$Environment$preInit = function (maybeKey) {
	return {launchTime: $author$project$SmartTime$Moment$zero, navkey: maybeKey, time: $author$project$SmartTime$Moment$zero, timeZone: $author$project$SmartTime$Human$Moment$utc};
};
var $elm$url$Url$addPort = F2(
	function (maybePort, starter) {
		if (maybePort.$ === 'Nothing') {
			return starter;
		} else {
			var port_ = maybePort.a;
			return starter + (':' + $elm$core$String$fromInt(port_));
		}
	});
var $elm$url$Url$addPrefixed = F3(
	function (prefix, maybeSegment, starter) {
		if (maybeSegment.$ === 'Nothing') {
			return starter;
		} else {
			var segment = maybeSegment.a;
			return _Utils_ap(
				starter,
				_Utils_ap(prefix, segment));
		}
	});
var $elm$url$Url$toString = function (url) {
	var http = function () {
		var _v0 = url.protocol;
		if (_v0.$ === 'Http') {
			return 'http://';
		} else {
			return 'https://';
		}
	}();
	return A3(
		$elm$url$Url$addPrefixed,
		'#',
		url.fragment,
		A3(
			$elm$url$Url$addPrefixed,
			'?',
			url.query,
			_Utils_ap(
				A2(
					$elm$url$Url$addPort,
					url.port_,
					_Utils_ap(http, url.host)),
				url.path)));
};
var $author$project$Main$bypassFakeFragment = function (url) {
	var _v0 = A2($elm$core$Maybe$map, $elm$core$String$uncons, url.fragment);
	if (((_v0.$ === 'Just') && (_v0.a.$ === 'Just')) && ('/' === _v0.a.a.a.valueOf())) {
		var _v1 = _v0.a.a;
		var fakeFragment = _v1.b;
		var _v2 = A2(
			$elm$core$String$split,
			'#',
			$elm$url$Url$toString(url));
		if (_v2.b) {
			var front = _v2.a;
			return A2(
				$elm$core$Maybe$withDefault,
				url,
				$elm$url$Url$fromString(
					_Utils_ap(front, fakeFragment)));
		} else {
			return url;
		}
	} else {
		return url;
	}
};
var $author$project$Main$Timeline = function (a) {
	return {$: 'Timeline', a: a};
};
var $author$project$Main$ViewState = F2(
	function (primaryView, uid) {
		return {primaryView: primaryView, uid: uid};
	});
var $author$project$Main$defaultView = A2(
	$author$project$Main$ViewState,
	$author$project$Main$Timeline($elm$core$Maybe$Nothing),
	0);
var $elm$url$Url$Parser$State = F5(
	function (visited, unvisited, params, frag, value) {
		return {frag: frag, params: params, unvisited: unvisited, value: value, visited: visited};
	});
var $elm$url$Url$Parser$getFirstMatch = function (states) {
	getFirstMatch:
	while (true) {
		if (!states.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			var state = states.a;
			var rest = states.b;
			var _v1 = state.unvisited;
			if (!_v1.b) {
				return $elm$core$Maybe$Just(state.value);
			} else {
				if ((_v1.a === '') && (!_v1.b.b)) {
					return $elm$core$Maybe$Just(state.value);
				} else {
					var $temp$states = rest;
					states = $temp$states;
					continue getFirstMatch;
				}
			}
		}
	}
};
var $elm$url$Url$Parser$removeFinalEmpty = function (segments) {
	if (!segments.b) {
		return _List_Nil;
	} else {
		if ((segments.a === '') && (!segments.b.b)) {
			return _List_Nil;
		} else {
			var segment = segments.a;
			var rest = segments.b;
			return A2(
				$elm$core$List$cons,
				segment,
				$elm$url$Url$Parser$removeFinalEmpty(rest));
		}
	}
};
var $elm$url$Url$Parser$preparePath = function (path) {
	var _v0 = A2($elm$core$String$split, '/', path);
	if (_v0.b && (_v0.a === '')) {
		var segments = _v0.b;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	} else {
		var segments = _v0;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	}
};
var $elm$url$Url$Parser$addToParametersHelp = F2(
	function (value, maybeList) {
		if (maybeList.$ === 'Nothing') {
			return $elm$core$Maybe$Just(
				_List_fromArray(
					[value]));
		} else {
			var list = maybeList.a;
			return $elm$core$Maybe$Just(
				A2($elm$core$List$cons, value, list));
		}
	});
var $elm$url$Url$percentDecode = _Url_percentDecode;
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.e.d.$ === 'RBNode_elm_builtin') && (dict.e.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.d.d.$ === 'RBNode_elm_builtin') && (dict.d.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Black')) {
					if (right.d.$ === 'RBNode_elm_builtin') {
						if (right.d.a.$ === 'Black') {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor.$ === 'Black') {
			if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === 'RBNode_elm_builtin') {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Black')) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === 'RBNode_elm_builtin') {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBNode_elm_builtin') {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === 'RBNode_elm_builtin') {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (_v0.$ === 'Just') {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $elm$url$Url$Parser$addParam = F2(
	function (segment, dict) {
		var _v0 = A2($elm$core$String$split, '=', segment);
		if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
			var rawKey = _v0.a;
			var _v1 = _v0.b;
			var rawValue = _v1.a;
			var _v2 = $elm$url$Url$percentDecode(rawKey);
			if (_v2.$ === 'Nothing') {
				return dict;
			} else {
				var key = _v2.a;
				var _v3 = $elm$url$Url$percentDecode(rawValue);
				if (_v3.$ === 'Nothing') {
					return dict;
				} else {
					var value = _v3.a;
					return A3(
						$elm$core$Dict$update,
						key,
						$elm$url$Url$Parser$addToParametersHelp(value),
						dict);
				}
			}
		} else {
			return dict;
		}
	});
var $elm$url$Url$Parser$prepareQuery = function (maybeQuery) {
	if (maybeQuery.$ === 'Nothing') {
		return $elm$core$Dict$empty;
	} else {
		var qry = maybeQuery.a;
		return A3(
			$elm$core$List$foldr,
			$elm$url$Url$Parser$addParam,
			$elm$core$Dict$empty,
			A2($elm$core$String$split, '&', qry));
	}
};
var $elm$url$Url$Parser$parse = F2(
	function (_v0, url) {
		var parser = _v0.a;
		return $elm$url$Url$Parser$getFirstMatch(
			parser(
				A5(
					$elm$url$Url$Parser$State,
					_List_Nil,
					$elm$url$Url$Parser$preparePath(url.path),
					$elm$url$Url$Parser$prepareQuery(url.query),
					url.fragment,
					$elm$core$Basics$identity)));
	});
var $author$project$Main$TaskList = function (a) {
	return {$: 'TaskList', a: a};
};
var $author$project$Main$TimeTracker = function (a) {
	return {$: 'TimeTracker', a: a};
};
var $elm$url$Url$Parser$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var $elm$url$Url$Parser$mapState = F2(
	function (func, _v0) {
		var visited = _v0.visited;
		var unvisited = _v0.unvisited;
		var params = _v0.params;
		var frag = _v0.frag;
		var value = _v0.value;
		return A5(
			$elm$url$Url$Parser$State,
			visited,
			unvisited,
			params,
			frag,
			func(value));
	});
var $elm$url$Url$Parser$map = F2(
	function (subValue, _v0) {
		var parseArg = _v0.a;
		return $elm$url$Url$Parser$Parser(
			function (_v1) {
				var visited = _v1.visited;
				var unvisited = _v1.unvisited;
				var params = _v1.params;
				var frag = _v1.frag;
				var value = _v1.value;
				return A2(
					$elm$core$List$map,
					$elm$url$Url$Parser$mapState(value),
					parseArg(
						A5($elm$url$Url$Parser$State, visited, unvisited, params, frag, subValue)));
			});
	});
var $elm$url$Url$Parser$oneOf = function (parsers) {
	return $elm$url$Url$Parser$Parser(
		function (state) {
			return A2(
				$elm$core$List$concatMap,
				function (_v0) {
					var parser = _v0.a;
					return parser(state);
				},
				parsers);
		});
};
var $author$project$TaskList$IncompleteTasksOnly = {$: 'IncompleteTasksOnly'};
var $author$project$TaskList$Normal = F3(
	function (a, b, c) {
		return {$: 'Normal', a: a, b: b, c: c};
	});
var $elm$url$Url$Parser$s = function (str) {
	return $elm$url$Url$Parser$Parser(
		function (_v0) {
			var visited = _v0.visited;
			var unvisited = _v0.unvisited;
			var params = _v0.params;
			var frag = _v0.frag;
			var value = _v0.value;
			if (!unvisited.b) {
				return _List_Nil;
			} else {
				var next = unvisited.a;
				var rest = unvisited.b;
				return _Utils_eq(next, str) ? _List_fromArray(
					[
						A5(
						$elm$url$Url$Parser$State,
						A2($elm$core$List$cons, next, visited),
						rest,
						params,
						frag,
						value)
					]) : _List_Nil;
			}
		});
};
var $author$project$TaskList$routeView = A2(
	$elm$url$Url$Parser$map,
	A3(
		$author$project$TaskList$Normal,
		_List_fromArray(
			[$author$project$TaskList$IncompleteTasksOnly]),
		$elm$core$Maybe$Nothing,
		''),
	$elm$url$Url$Parser$s('tasks'));
var $author$project$TimeTracker$Normal = {$: 'Normal'};
var $author$project$TimeTracker$routeView = A2(
	$elm$url$Url$Parser$map,
	$author$project$TimeTracker$Normal,
	$elm$url$Url$Parser$s('timetracker'));
var $author$project$Main$screenToViewState = function (screen) {
	return {primaryView: screen, uid: 0};
};
var $author$project$Main$routeParser = function () {
	var wrapScreen = function (parser) {
		return A2($elm$url$Url$Parser$map, $author$project$Main$screenToViewState, parser);
	};
	return $elm$url$Url$Parser$oneOf(
		_List_fromArray(
			[
				wrapScreen(
				A2($elm$url$Url$Parser$map, $author$project$Main$TaskList, $author$project$TaskList$routeView)),
				wrapScreen(
				A2($elm$url$Url$Parser$map, $author$project$Main$TimeTracker, $author$project$TimeTracker$routeView))
			]));
}();
var $author$project$Main$viewUrl = function (url) {
	var finalUrl = $author$project$Main$bypassFakeFragment(url);
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$Main$defaultView,
		A2($elm$url$Url$Parser$parse, $author$project$Main$routeParser, finalUrl));
};
var $author$project$Main$buildModel = F3(
	function (profile, url, maybeKey) {
		return {
			environment: $author$project$Environment$preInit(maybeKey),
			profile: profile,
			viewState: $author$project$Main$viewUrl(url)
		};
	});
var $elm_community$intdict$IntDict$Empty = {$: 'Empty'};
var $elm_community$intdict$IntDict$empty = $elm_community$intdict$IntDict$Empty;
var $author$project$Incubator$Todoist$IncrementalSyncToken = function (a) {
	return {$: 'IncrementalSyncToken', a: a};
};
var $author$project$Incubator$Todoist$emptyCache = {
	items: $elm_community$intdict$IntDict$empty,
	nextSync: $author$project$Incubator$Todoist$IncrementalSyncToken('*'),
	pendingCommands: _List_Nil,
	projects: $elm_community$intdict$IntDict$empty
};
var $author$project$Profile$emptyTodoistIntegrationData = {activityProjectIDs: $elm_community$intdict$IntDict$empty, cache: $author$project$Incubator$Todoist$emptyCache, parentProjectID: $elm$core$Maybe$Nothing};
var $author$project$Profile$fromScratch = {activities: $elm_community$intdict$IntDict$empty, errors: _List_Nil, taskClasses: $elm_community$intdict$IntDict$empty, taskEntries: _List_Nil, taskInstances: $elm_community$intdict$IntDict$empty, timeBlocks: _List_Nil, timeline: _List_Nil, todoist: $author$project$Profile$emptyTodoistIntegrationData, uid: 0};
var $elm$time$Time$Name = function (a) {
	return {$: 'Name', a: a};
};
var $elm$time$Time$Offset = function (a) {
	return {$: 'Offset', a: a};
};
var $elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 'Zone', a: a, b: b};
	});
var $elm$time$Time$customZone = $elm$time$Time$Zone;
var $elm$time$Time$getZoneName = _Time_getZoneName(_Utils_Tuple0);
var $elm$time$Time$here = _Time_here(_Utils_Tuple0);
var $author$project$SmartTime$Human$Calendar$Month$DayOfMonth = function (a) {
	return {$: 'DayOfMonth', a: a};
};
var $author$project$SmartTime$Human$Calendar$Year$Year = function (a) {
	return {$: 'Year', a: a};
};
var $author$project$SmartTime$Human$Duration$Hours = function (a) {
	return {$: 'Hours', a: a};
};
var $author$project$SmartTime$Human$Duration$Milliseconds = function (a) {
	return {$: 'Milliseconds', a: a};
};
var $author$project$SmartTime$Human$Duration$Minutes = function (a) {
	return {$: 'Minutes', a: a};
};
var $author$project$SmartTime$Human$Duration$Seconds = function (a) {
	return {$: 'Seconds', a: a};
};
var $author$project$SmartTime$Duration$fromInt = function (_int) {
	return $author$project$SmartTime$Duration$Duration(_int);
};
var $author$project$SmartTime$Duration$inMs = function (_v0) {
	var _int = _v0.a;
	return _int;
};
var $author$project$SmartTime$Duration$hourLength = 60 * $author$project$SmartTime$Duration$minuteLength;
var $author$project$SmartTime$Duration$dayLength = 24 * $author$project$SmartTime$Duration$hourLength;
var $author$project$SmartTime$Duration$aDay = $author$project$SmartTime$Duration$Duration($author$project$SmartTime$Duration$dayLength);
var $author$project$SmartTime$Duration$aMillisecond = $author$project$SmartTime$Duration$Duration($author$project$SmartTime$Duration$millisecondLength);
var $author$project$SmartTime$Duration$aMinute = $author$project$SmartTime$Duration$Duration($author$project$SmartTime$Duration$minuteLength);
var $author$project$SmartTime$Duration$aSecond = $author$project$SmartTime$Duration$Duration($author$project$SmartTime$Duration$secondLength);
var $author$project$SmartTime$Duration$anHour = $author$project$SmartTime$Duration$Duration($author$project$SmartTime$Duration$hourLength);
var $author$project$SmartTime$Duration$scale = F2(
	function (_v0, scalar) {
		var dur = _v0.a;
		return $author$project$SmartTime$Duration$Duration(
			$elm$core$Basics$round(dur * scalar));
	});
var $author$project$SmartTime$Human$Duration$toDuration = function (humanDuration) {
	switch (humanDuration.$) {
		case 'Days':
			var days = humanDuration.a;
			return A2($author$project$SmartTime$Duration$scale, $author$project$SmartTime$Duration$aDay, days);
		case 'Hours':
			var hours = humanDuration.a;
			return A2($author$project$SmartTime$Duration$scale, $author$project$SmartTime$Duration$anHour, hours);
		case 'Minutes':
			var minutes = humanDuration.a;
			return A2($author$project$SmartTime$Duration$scale, $author$project$SmartTime$Duration$aMinute, minutes);
		case 'Seconds':
			var seconds = humanDuration.a;
			return A2($author$project$SmartTime$Duration$scale, $author$project$SmartTime$Duration$aSecond, seconds);
		default:
			var milliseconds = humanDuration.a;
			return A2($author$project$SmartTime$Duration$scale, $author$project$SmartTime$Duration$aMillisecond, milliseconds);
	}
};
var $author$project$SmartTime$Human$Duration$normalize = function (human) {
	return $author$project$SmartTime$Duration$inMs(
		$author$project$SmartTime$Human$Duration$toDuration(human));
};
var $elm$core$List$sum = function (numbers) {
	return A3($elm$core$List$foldl, $elm$core$Basics$add, 0, numbers);
};
var $author$project$SmartTime$Human$Duration$build = function (list) {
	return $author$project$SmartTime$Duration$fromInt(
		$elm$core$List$sum(
			A2($elm$core$List$map, $author$project$SmartTime$Human$Duration$normalize, list)));
};
var $author$project$SmartTime$Human$Clock$clock = F4(
	function (hh, mm, ss, ms) {
		return $author$project$SmartTime$Human$Duration$build(
			_List_fromArray(
				[
					$author$project$SmartTime$Human$Duration$Hours(hh),
					$author$project$SmartTime$Human$Duration$Minutes(mm),
					$author$project$SmartTime$Human$Duration$Seconds(ss),
					$author$project$SmartTime$Human$Duration$Milliseconds(ms)
				]));
	});
var $author$project$SmartTime$Duration$add = F2(
	function (_v0, _v1) {
		var int1 = _v0.a;
		var int2 = _v1.a;
		return $author$project$SmartTime$Duration$Duration(int1 + int2);
	});
var $author$project$SmartTime$Human$Calendar$toRataDie = function (_v0) {
	var _int = _v0.a;
	return _int;
};
var $author$project$SmartTime$Moment$UTC = {$: 'UTC'};
var $author$project$SmartTime$Moment$commonEraStart = $author$project$SmartTime$Moment$Moment(
	$author$project$SmartTime$Duration$fromInt(0));
var $author$project$SmartTime$Moment$Earlier = {$: 'Earlier'};
var $author$project$SmartTime$Moment$Coincident = {$: 'Coincident'};
var $author$project$SmartTime$Moment$Later = {$: 'Later'};
var $author$project$SmartTime$Moment$compare = F2(
	function (_v0, _v1) {
		var time1 = _v0.a;
		var time2 = _v1.a;
		var _v2 = A2(
			$elm$core$Basics$compare,
			$author$project$SmartTime$Duration$inMs(time1),
			$author$project$SmartTime$Duration$inMs(time2));
		switch (_v2.$) {
			case 'GT':
				return $author$project$SmartTime$Moment$Later;
			case 'LT':
				return $author$project$SmartTime$Moment$Earlier;
			default:
				return $author$project$SmartTime$Moment$Coincident;
		}
	});
var $author$project$SmartTime$Human$Moment$searchRemainingZoneHistory = F3(
	function (moment, fallback, history) {
		searchRemainingZoneHistory:
		while (true) {
			if (!history.b) {
				return fallback;
			} else {
				var _v1 = history.a;
				var zoneChange = _v1.a;
				var offsetAtThatTime = _v1.b;
				var remainingHistory = history.b;
				if (!_Utils_eq(
					A2($author$project$SmartTime$Moment$compare, moment, zoneChange),
					$author$project$SmartTime$Moment$Earlier)) {
					return offsetAtThatTime;
				} else {
					var $temp$moment = moment,
						$temp$fallback = offsetAtThatTime,
						$temp$history = remainingHistory;
					moment = $temp$moment;
					fallback = $temp$fallback;
					history = $temp$history;
					continue searchRemainingZoneHistory;
				}
			}
		}
	});
var $author$project$SmartTime$Human$Moment$getOffset = F2(
	function (referencePoint, zone) {
		return A3($author$project$SmartTime$Human$Moment$searchRemainingZoneHistory, referencePoint, zone.defaultOffset, zone.history);
	});
var $author$project$SmartTime$Moment$TAI = {$: 'TAI'};
var $author$project$SmartTime$Duration$fromMs = function (_float) {
	return $author$project$SmartTime$Duration$Duration(
		$elm$core$Basics$round(_float));
};
var $author$project$SmartTime$Duration$fromSeconds = function (_float) {
	return $author$project$SmartTime$Duration$Duration(
		$elm$core$Basics$round(_float * $author$project$SmartTime$Duration$secondLength));
};
var $elm_community$list_extra$List$Extra$last = function (items) {
	last:
	while (true) {
		if (!items.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			if (!items.b.b) {
				var x = items.a;
				return $elm$core$Maybe$Just(x);
			} else {
				var rest = items.b;
				var $temp$items = rest;
				items = $temp$items;
				continue last;
			}
		}
	}
};
var $author$project$SmartTime$Moment$nineteen00 = $author$project$SmartTime$Moment$Moment(
	$author$project$SmartTime$Duration$fromInt(0));
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $elm_community$list_extra$List$Extra$takeWhileRight = function (p) {
	var step = F2(
		function (x, _v0) {
			var xs = _v0.a;
			var free = _v0.b;
			return (p(x) && free) ? _Utils_Tuple2(
				A2($elm$core$List$cons, x, xs),
				true) : _Utils_Tuple2(xs, false);
		});
	return A2(
		$elm$core$Basics$composeL,
		$elm$core$Tuple$first,
		A2(
			$elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, true)));
};
var $author$project$SmartTime$Moment$linearFromUTC = function (momentAsDur) {
	return A2(
		$author$project$SmartTime$Duration$add,
		momentAsDur,
		$author$project$SmartTime$Moment$utcOffset(momentAsDur));
};
var $author$project$SmartTime$Moment$moment = F3(
	function (timeScale, _v2, inputDuration) {
		var epochDur = _v2.a;
		var input = A2($author$project$SmartTime$Duration$add, inputDuration, epochDur);
		switch (timeScale.$) {
			case 'TAI':
				return $author$project$SmartTime$Moment$Moment(input);
			case 'UTC':
				return $author$project$SmartTime$Moment$Moment(
					$author$project$SmartTime$Moment$linearFromUTC(input));
			case 'GPS':
				return $author$project$SmartTime$Moment$Moment(
					A2(
						$author$project$SmartTime$Duration$add,
						input,
						$author$project$SmartTime$Duration$fromSeconds(19)));
			default:
				return $author$project$SmartTime$Moment$Moment(
					A2(
						$author$project$SmartTime$Duration$add,
						input,
						$author$project$SmartTime$Duration$fromMs(32184)));
		}
	});
var $author$project$SmartTime$Moment$utcOffset = function (rawUTCMomentAsDur) {
	var ntpEpoch = $author$project$SmartTime$Moment$nineteen00;
	var leapSecondsTable = _List_fromArray(
		[
			_Utils_Tuple2(2272060800, 10),
			_Utils_Tuple2(2287785600, 11),
			_Utils_Tuple2(2303683200, 12),
			_Utils_Tuple2(2335219200, 13),
			_Utils_Tuple2(2366755200, 14),
			_Utils_Tuple2(2398291200, 15),
			_Utils_Tuple2(2429913600, 16),
			_Utils_Tuple2(2461449600, 17),
			_Utils_Tuple2(2492985600, 18),
			_Utils_Tuple2(2524521600, 19),
			_Utils_Tuple2(2571782400, 20),
			_Utils_Tuple2(2603318400, 21),
			_Utils_Tuple2(2634854400, 22),
			_Utils_Tuple2(2698012800, 23),
			_Utils_Tuple2(2776982400, 24),
			_Utils_Tuple2(2840140800, 25),
			_Utils_Tuple2(2871676800, 26),
			_Utils_Tuple2(2918937600, 27),
			_Utils_Tuple2(2950473600, 28),
			_Utils_Tuple2(2982009600, 29),
			_Utils_Tuple2(3029443200, 30),
			_Utils_Tuple2(3076704000, 31),
			_Utils_Tuple2(3124137600, 32),
			_Utils_Tuple2(3345062400, 33),
			_Utils_Tuple2(3439756800, 34),
			_Utils_Tuple2(3550089600, 35),
			_Utils_Tuple2(3644697600, 36),
			_Utils_Tuple2(3692217600, 37)
		]);
	var fromNTPtime = function (num) {
		return A3(
			$author$project$SmartTime$Moment$moment,
			$author$project$SmartTime$Moment$TAI,
			ntpEpoch,
			$author$project$SmartTime$Duration$fromSeconds(num));
	};
	var fromTableItem = function (_v1) {
		var ntpTime = _v1.a;
		var leaps = _v1.b;
		return _Utils_Tuple2(
			fromNTPtime(ntpTime),
			$author$project$SmartTime$Duration$fromSeconds(leaps));
	};
	var leapSeconds = A2($elm$core$List$map, fromTableItem, leapSecondsTable);
	var oldest = fromTableItem(
		_Utils_Tuple2(2272060800, 10));
	var fakeMoment = A3($author$project$SmartTime$Moment$moment, $author$project$SmartTime$Moment$TAI, $author$project$SmartTime$Moment$commonEraStart, rawUTCMomentAsDur);
	var periodStartsEarlier = function (_v0) {
		var periodStartMoment = _v0.a;
		return _Utils_eq(
			A2($author$project$SmartTime$Moment$compare, periodStartMoment, fakeMoment),
			$author$project$SmartTime$Moment$Earlier);
	};
	var goBackThroughTime = A2($elm_community$list_extra$List$Extra$takeWhileRight, periodStartsEarlier, leapSeconds);
	var relevantPeriod = A2(
		$elm$core$Maybe$withDefault,
		oldest,
		$elm_community$list_extra$List$Extra$last(goBackThroughTime));
	var offsetAtThatTime = relevantPeriod.b;
	return offsetAtThatTime;
};
var $author$project$SmartTime$Duration$subtract = F2(
	function (_v0, _v1) {
		var int1 = _v0.a;
		var int2 = _v1.a;
		return $author$project$SmartTime$Duration$Duration(int1 - int2);
	});
var $author$project$SmartTime$Human$Moment$toTAIAndUnlocalize = F2(
	function (zone, localMomentDur) {
		var toMoment = function (duration) {
			return A3($author$project$SmartTime$Moment$moment, $author$project$SmartTime$Moment$UTC, $author$project$SmartTime$Moment$commonEraStart, duration);
		};
		var zoneOffset = A2(
			$author$project$SmartTime$Human$Moment$getOffset,
			toMoment(localMomentDur),
			zone);
		return toMoment(
			A2($author$project$SmartTime$Duration$subtract, localMomentDur, zoneOffset));
	});
var $author$project$SmartTime$Human$Moment$fromDateAndTime = F3(
	function (zone, date, timeOfDay) {
		var woleDaysBefore = A2(
			$author$project$SmartTime$Duration$scale,
			$author$project$SmartTime$Duration$aDay,
			$author$project$SmartTime$Human$Calendar$toRataDie(date));
		var total = A2($author$project$SmartTime$Duration$add, timeOfDay, woleDaysBefore);
		return A2($author$project$SmartTime$Human$Moment$toTAIAndUnlocalize, zone, total);
	});
var $author$project$SmartTime$Moment$unixEpoch = function () {
	var jan1st1970_rataDie = 719163;
	return $author$project$SmartTime$Moment$Moment(
		A2($author$project$SmartTime$Duration$scale, $author$project$SmartTime$Duration$aDay, jan1st1970_rataDie));
}();
var $author$project$SmartTime$Moment$fromElmInt = function (intMsUtc) {
	return A3(
		$author$project$SmartTime$Moment$moment,
		$author$project$SmartTime$Moment$UTC,
		$author$project$SmartTime$Moment$unixEpoch,
		$author$project$SmartTime$Duration$fromInt(intMsUtc));
};
var $elm$time$Time$posixToMillis = function (_v0) {
	var millis = _v0.a;
	return millis;
};
var $author$project$SmartTime$Moment$fromElmTime = function (intMsUtc) {
	return $author$project$SmartTime$Moment$fromElmInt(
		$elm$time$Time$posixToMillis(intMsUtc));
};
var $elm$core$Basics$clamp = F3(
	function (low, high, number) {
		return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
	});
var $author$project$SmartTime$Human$Calendar$Year$isLeapYear = function (_v0) {
	var _int = _v0.a;
	return (!A2($elm$core$Basics$modBy, 4, _int)) && ((!A2($elm$core$Basics$modBy, 400, _int)) || (!(!A2($elm$core$Basics$modBy, 100, _int))));
};
var $author$project$SmartTime$Human$Calendar$Month$length = F2(
	function (givenYear, m) {
		switch (m.$) {
			case 'Jan':
				return 31;
			case 'Feb':
				return $author$project$SmartTime$Human$Calendar$Year$isLeapYear(givenYear) ? 29 : 28;
			case 'Mar':
				return 31;
			case 'Apr':
				return 30;
			case 'May':
				return 31;
			case 'Jun':
				return 30;
			case 'Jul':
				return 31;
			case 'Aug':
				return 31;
			case 'Sep':
				return 30;
			case 'Oct':
				return 31;
			case 'Nov':
				return 30;
			default:
				return 31;
		}
	});
var $author$project$SmartTime$Human$Calendar$Month$clampToValidDayOfMonth = F3(
	function (givenYear, givenMonth, _v0) {
		var originalDay = _v0.a;
		var targetMonthLength = A2($author$project$SmartTime$Human$Calendar$Month$length, givenYear, givenMonth);
		return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(
			A3($elm$core$Basics$clamp, 1, targetMonthLength, originalDay));
	});
var $author$project$SmartTime$Human$Calendar$CalendarDate = function (a) {
	return {$: 'CalendarDate', a: a};
};
var $author$project$SmartTime$Human$Calendar$Month$dayToInt = function (_v0) {
	var day = _v0.a;
	return day;
};
var $author$project$SmartTime$Human$Calendar$Month$daysBefore = F2(
	function (givenYear, m) {
		var leapDays = $author$project$SmartTime$Human$Calendar$Year$isLeapYear(givenYear) ? 1 : 0;
		switch (m.$) {
			case 'Jan':
				return 0;
			case 'Feb':
				return 31;
			case 'Mar':
				return 59 + leapDays;
			case 'Apr':
				return 90 + leapDays;
			case 'May':
				return 120 + leapDays;
			case 'Jun':
				return 151 + leapDays;
			case 'Jul':
				return 181 + leapDays;
			case 'Aug':
				return 212 + leapDays;
			case 'Sep':
				return 243 + leapDays;
			case 'Oct':
				return 273 + leapDays;
			case 'Nov':
				return 304 + leapDays;
			default:
				return 334 + leapDays;
		}
	});
var $author$project$SmartTime$Human$Calendar$Year$daysBefore = function (_v0) {
	var givenYearInt = _v0.a;
	var yearFromZero = givenYearInt - 1;
	var leapYears = (((yearFromZero / 4) | 0) - ((yearFromZero / 100) | 0)) + ((yearFromZero / 400) | 0);
	return (365 * yearFromZero) + leapYears;
};
var $author$project$SmartTime$Human$Calendar$fromPartsTrusted = function (given) {
	return $author$project$SmartTime$Human$Calendar$CalendarDate(
		($author$project$SmartTime$Human$Calendar$Year$daysBefore(given.year) + A2($author$project$SmartTime$Human$Calendar$Month$daysBefore, given.year, given.month)) + $author$project$SmartTime$Human$Calendar$Month$dayToInt(given.day));
};
var $author$project$SmartTime$Human$Calendar$fromPartsForced = function (given) {
	return $author$project$SmartTime$Human$Calendar$fromPartsTrusted(
		{
			day: A3($author$project$SmartTime$Human$Calendar$Month$clampToValidDayOfMonth, given.year, given.month, given.day),
			month: given.month,
			year: given.year
		});
};
var $author$project$SmartTime$Human$Calendar$Month$Apr = {$: 'Apr'};
var $author$project$SmartTime$Human$Calendar$Month$Aug = {$: 'Aug'};
var $author$project$SmartTime$Human$Calendar$Month$Dec = {$: 'Dec'};
var $author$project$SmartTime$Human$Calendar$Month$Feb = {$: 'Feb'};
var $author$project$SmartTime$Human$Calendar$Month$Jan = {$: 'Jan'};
var $author$project$SmartTime$Human$Calendar$Month$Jul = {$: 'Jul'};
var $author$project$SmartTime$Human$Calendar$Month$Jun = {$: 'Jun'};
var $author$project$SmartTime$Human$Calendar$Month$Mar = {$: 'Mar'};
var $author$project$SmartTime$Human$Calendar$Month$May = {$: 'May'};
var $author$project$SmartTime$Human$Calendar$Month$Nov = {$: 'Nov'};
var $author$project$SmartTime$Human$Calendar$Month$Oct = {$: 'Oct'};
var $author$project$SmartTime$Human$Calendar$Month$Sep = {$: 'Sep'};
var $author$project$SmartTime$Human$Moment$importElmMonth = function (elmMonth) {
	switch (elmMonth.$) {
		case 'Jan':
			return $author$project$SmartTime$Human$Calendar$Month$Jan;
		case 'Feb':
			return $author$project$SmartTime$Human$Calendar$Month$Feb;
		case 'Mar':
			return $author$project$SmartTime$Human$Calendar$Month$Mar;
		case 'Apr':
			return $author$project$SmartTime$Human$Calendar$Month$Apr;
		case 'May':
			return $author$project$SmartTime$Human$Calendar$Month$May;
		case 'Jun':
			return $author$project$SmartTime$Human$Calendar$Month$Jun;
		case 'Jul':
			return $author$project$SmartTime$Human$Calendar$Month$Jul;
		case 'Aug':
			return $author$project$SmartTime$Human$Calendar$Month$Aug;
		case 'Sep':
			return $author$project$SmartTime$Human$Calendar$Month$Sep;
		case 'Oct':
			return $author$project$SmartTime$Human$Calendar$Month$Oct;
		case 'Nov':
			return $author$project$SmartTime$Human$Calendar$Month$Nov;
		default:
			return $author$project$SmartTime$Human$Calendar$Month$Dec;
	}
};
var $elm$time$Time$flooredDiv = F2(
	function (numerator, denominator) {
		return $elm$core$Basics$floor(numerator / denominator);
	});
var $elm$time$Time$toAdjustedMinutesHelp = F3(
	function (defaultOffset, posixMinutes, eras) {
		toAdjustedMinutesHelp:
		while (true) {
			if (!eras.b) {
				return posixMinutes + defaultOffset;
			} else {
				var era = eras.a;
				var olderEras = eras.b;
				if (_Utils_cmp(era.start, posixMinutes) < 0) {
					return posixMinutes + era.offset;
				} else {
					var $temp$defaultOffset = defaultOffset,
						$temp$posixMinutes = posixMinutes,
						$temp$eras = olderEras;
					defaultOffset = $temp$defaultOffset;
					posixMinutes = $temp$posixMinutes;
					eras = $temp$eras;
					continue toAdjustedMinutesHelp;
				}
			}
		}
	});
var $elm$time$Time$toAdjustedMinutes = F2(
	function (_v0, time) {
		var defaultOffset = _v0.a;
		var eras = _v0.b;
		return A3(
			$elm$time$Time$toAdjustedMinutesHelp,
			defaultOffset,
			A2(
				$elm$time$Time$flooredDiv,
				$elm$time$Time$posixToMillis(time),
				60000),
			eras);
	});
var $elm$core$Basics$ge = _Utils_ge;
var $elm$time$Time$toCivil = function (minutes) {
	var rawDay = A2($elm$time$Time$flooredDiv, minutes, 60 * 24) + 719468;
	var era = (((rawDay >= 0) ? rawDay : (rawDay - 146096)) / 146097) | 0;
	var dayOfEra = rawDay - (era * 146097);
	var yearOfEra = ((((dayOfEra - ((dayOfEra / 1460) | 0)) + ((dayOfEra / 36524) | 0)) - ((dayOfEra / 146096) | 0)) / 365) | 0;
	var dayOfYear = dayOfEra - (((365 * yearOfEra) + ((yearOfEra / 4) | 0)) - ((yearOfEra / 100) | 0));
	var mp = (((5 * dayOfYear) + 2) / 153) | 0;
	var month = mp + ((mp < 10) ? 3 : (-9));
	var year = yearOfEra + (era * 400);
	return {
		day: (dayOfYear - ((((153 * mp) + 2) / 5) | 0)) + 1,
		month: month,
		year: year + ((month <= 2) ? 1 : 0)
	};
};
var $elm$time$Time$toDay = F2(
	function (zone, time) {
		return $elm$time$Time$toCivil(
			A2($elm$time$Time$toAdjustedMinutes, zone, time)).day;
	});
var $elm$time$Time$toHour = F2(
	function (zone, time) {
		return A2(
			$elm$core$Basics$modBy,
			24,
			A2(
				$elm$time$Time$flooredDiv,
				A2($elm$time$Time$toAdjustedMinutes, zone, time),
				60));
	});
var $elm$time$Time$toMillis = F2(
	function (_v0, time) {
		return A2(
			$elm$core$Basics$modBy,
			1000,
			$elm$time$Time$posixToMillis(time));
	});
var $elm$time$Time$toMinute = F2(
	function (zone, time) {
		return A2(
			$elm$core$Basics$modBy,
			60,
			A2($elm$time$Time$toAdjustedMinutes, zone, time));
	});
var $elm$time$Time$Apr = {$: 'Apr'};
var $elm$time$Time$Aug = {$: 'Aug'};
var $elm$time$Time$Dec = {$: 'Dec'};
var $elm$time$Time$Feb = {$: 'Feb'};
var $elm$time$Time$Jan = {$: 'Jan'};
var $elm$time$Time$Jul = {$: 'Jul'};
var $elm$time$Time$Jun = {$: 'Jun'};
var $elm$time$Time$Mar = {$: 'Mar'};
var $elm$time$Time$May = {$: 'May'};
var $elm$time$Time$Nov = {$: 'Nov'};
var $elm$time$Time$Oct = {$: 'Oct'};
var $elm$time$Time$Sep = {$: 'Sep'};
var $elm$time$Time$toMonth = F2(
	function (zone, time) {
		var _v0 = $elm$time$Time$toCivil(
			A2($elm$time$Time$toAdjustedMinutes, zone, time)).month;
		switch (_v0) {
			case 1:
				return $elm$time$Time$Jan;
			case 2:
				return $elm$time$Time$Feb;
			case 3:
				return $elm$time$Time$Mar;
			case 4:
				return $elm$time$Time$Apr;
			case 5:
				return $elm$time$Time$May;
			case 6:
				return $elm$time$Time$Jun;
			case 7:
				return $elm$time$Time$Jul;
			case 8:
				return $elm$time$Time$Aug;
			case 9:
				return $elm$time$Time$Sep;
			case 10:
				return $elm$time$Time$Oct;
			case 11:
				return $elm$time$Time$Nov;
			default:
				return $elm$time$Time$Dec;
		}
	});
var $elm$time$Time$toSecond = F2(
	function (_v0, time) {
		return A2(
			$elm$core$Basics$modBy,
			60,
			A2(
				$elm$time$Time$flooredDiv,
				$elm$time$Time$posixToMillis(time),
				1000));
	});
var $author$project$SmartTime$Moment$toSmartInt = function (_v0) {
	var dur = _v0.a;
	return $author$project$SmartTime$Duration$inMs(dur);
};
var $elm$time$Time$toYear = F2(
	function (zone, time) {
		return $elm$time$Time$toCivil(
			A2($elm$time$Time$toAdjustedMinutes, zone, time)).year;
	});
var $author$project$SmartTime$Human$Moment$deduceZoneOffset = F2(
	function (zone, elmTime) {
		var zonedTime = A4(
			$author$project$SmartTime$Human$Clock$clock,
			A2($elm$time$Time$toHour, zone, elmTime),
			A2($elm$time$Time$toMinute, zone, elmTime),
			A2($elm$time$Time$toSecond, zone, elmTime),
			A2($elm$time$Time$toMillis, zone, elmTime));
		var zonedDate = $author$project$SmartTime$Human$Calendar$fromPartsForced(
			{
				day: $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(
					A2($elm$time$Time$toDay, zone, elmTime)),
				month: $author$project$SmartTime$Human$Moment$importElmMonth(
					A2($elm$time$Time$toMonth, zone, elmTime)),
				year: $author$project$SmartTime$Human$Calendar$Year$Year(
					A2($elm$time$Time$toYear, zone, elmTime))
			});
		var utcTime = $author$project$SmartTime$Moment$fromElmTime(elmTime);
		var combinedMoment = A3($author$project$SmartTime$Human$Moment$fromDateAndTime, $author$project$SmartTime$Human$Moment$utc, zonedDate, zonedTime);
		var localTime = combinedMoment;
		var offset = $author$project$SmartTime$Moment$toSmartInt(localTime) - $author$project$SmartTime$Moment$toSmartInt(utcTime);
		return $author$project$SmartTime$Duration$fromMs(offset);
	});
var $author$project$SmartTime$Human$Moment$makeZone = F3(
	function (elmZoneName, elmZone, now) {
		var deducedOffset = A2($author$project$SmartTime$Human$Moment$deduceZoneOffset, elmZone, now);
		if (elmZoneName.$ === 'Name') {
			var zoneName = elmZoneName.a;
			return {defaultOffset: deducedOffset, history: _List_Nil, name: zoneName};
		} else {
			var offsetMinutes = elmZoneName.a;
			return {
				defaultOffset: $author$project$SmartTime$Duration$fromMinutes(offsetMinutes),
				history: _List_Nil,
				name: 'Unsupported'
			};
		}
	});
var $elm$core$Task$map3 = F4(
	function (func, taskA, taskB, taskC) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return A2(
							$elm$core$Task$andThen,
							function (c) {
								return $elm$core$Task$succeed(
									A3(func, a, b, c));
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var $elm$time$Time$Posix = function (a) {
	return {$: 'Posix', a: a};
};
var $elm$time$Time$millisToPosix = $elm$time$Time$Posix;
var $elm$time$Time$now = _Time_now($elm$time$Time$millisToPosix);
var $author$project$SmartTime$Human$Moment$localZone = A4($elm$core$Task$map3, $author$project$SmartTime$Human$Moment$makeZone, $elm$time$Time$getZoneName, $elm$time$Time$here, $elm$time$Time$now);
var $author$project$SmartTime$Moment$now = A2($elm$core$Task$map, $author$project$SmartTime$Moment$fromElmTime, $elm$time$Time$now);
var $author$project$Profile$Profile = F9(
	function (uid, errors, taskEntries, taskClasses, taskInstances, activities, timeline, todoist, timeBlocks) {
		return {activities: activities, errors: errors, taskClasses: taskClasses, taskEntries: taskEntries, taskInstances: taskInstances, timeBlocks: timeBlocks, timeline: timeline, todoist: todoist, uid: uid};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder = function (a) {
	return {$: 'Decoder', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$ok = F2(
	function (json, val) {
		return $elm$core$Result$Ok(
			{json: json, value: val, warnings: _List_Nil});
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed = function (val) {
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$ok, json, val);
		});
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode = $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed;
var $author$project$Task$Class$ClassSkel = function (title) {
	return function (id) {
		return function (activity) {
			return function (completionUnits) {
				return function (minEffort) {
					return function (predictedEffort) {
						return function (maxEffort) {
							return function (defaultExternalDeadline) {
								return function (defaultStartBy) {
									return function (defaultFinishBy) {
										return function (defaultRelevanceStarts) {
											return function (defaultRelevanceEnds) {
												return function (importance) {
													return {activity: activity, completionUnits: completionUnits, defaultExternalDeadline: defaultExternalDeadline, defaultFinishBy: defaultFinishBy, defaultRelevanceEnds: defaultRelevanceEnds, defaultRelevanceStarts: defaultRelevanceStarts, defaultStartBy: defaultStartBy, id: id, importance: importance, maxEffort: maxEffort, minEffort: minEffort, predictedEffort: predictedEffort, title: title};
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$ID$ID = function (a) {
	return {$: 'ID', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TInt = {$: 'TInt'};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Expected = F2(
	function (a, b) {
		return {$: 'Expected', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here = function (a) {
	return {$: 'Here', a: a};
};
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$json$Json$Encode$float = _Json_wrap;
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var $elm$core$Tuple$mapSecond = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $zwilias$json_decode_exploration$Json$Decode$Exploration$encode = function (v) {
	switch (v.$) {
		case 'String':
			var val = v.b;
			return $elm$json$Json$Encode$string(val);
		case 'Number':
			var val = v.b;
			return $elm$json$Json$Encode$float(val);
		case 'Bool':
			var val = v.b;
			return $elm$json$Json$Encode$bool(val);
		case 'Null':
			return $elm$json$Json$Encode$null;
		case 'Array':
			var values = v.b;
			return A2($elm$json$Json$Encode$list, $zwilias$json_decode_exploration$Json$Decode$Exploration$encode, values);
		default:
			var kvPairs = v.b;
			return $elm$json$Json$Encode$object(
				A2(
					$elm$core$List$map,
					$elm$core$Tuple$mapSecond($zwilias$json_decode_exploration$Json$Decode$Exploration$encode),
					kvPairs));
	}
};
var $mgold$elm_nonempty_list$List$Nonempty$Nonempty = F2(
	function (a, b) {
		return {$: 'Nonempty', a: a, b: b};
	});
var $mgold$elm_nonempty_list$List$Nonempty$fromElement = function (x) {
	return A2($mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, _List_Nil);
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$expected = F2(
	function (expectedType, json) {
		return $elm$core$Result$Err(
			$mgold$elm_nonempty_list$List$Nonempty$fromElement(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
					A2(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Expected,
						expectedType,
						$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Array = F2(
	function (a, b) {
		return {$: 'Array', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Bool = F2(
	function (a, b) {
		return {$: 'Bool', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Null = function (a) {
	return {$: 'Null', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Number = F2(
	function (a, b) {
		return {$: 'Number', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Object = F2(
	function (a, b) {
		return {$: 'Object', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$String = F2(
	function (a, b) {
		return {$: 'String', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed = function (annotatedValue) {
	switch (annotatedValue.$) {
		case 'String':
			var val = annotatedValue.b;
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$String, true, val);
		case 'Number':
			var val = annotatedValue.b;
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Number, true, val);
		case 'Bool':
			var val = annotatedValue.b;
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Bool, true, val);
		case 'Null':
			return $zwilias$json_decode_exploration$Json$Decode$Exploration$Null(true);
		case 'Array':
			var values = annotatedValue.b;
			return A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Array,
				true,
				A2($elm$core$List$map, $zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed, values));
		default:
			var values = annotatedValue.b;
			return A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Object,
				true,
				A2(
					$elm$core$List$map,
					$elm$core$Tuple$mapSecond($zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed),
					values));
	}
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$int = $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Number') {
			var val = json.b;
			return _Utils_eq(
				$elm$core$Basics$round(val),
				val) ? A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				$elm$core$Basics$round(val)) : A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TInt, json);
		} else {
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TInt, json);
		}
	});
var $elm$core$Result$map = F2(
	function (func, ra) {
		if (ra.$ === 'Ok') {
			var a = ra.a;
			return $elm$core$Result$Ok(
				func(a));
		} else {
			var e = ra.a;
			return $elm$core$Result$Err(e);
		}
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$mapAcc = F2(
	function (f, acc) {
		return {
			json: acc.json,
			value: f(acc.value),
			warnings: acc.warnings
		};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$map = F2(
	function (f, _v0) {
		var decoderFn = _v0.a;
		return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				return A2(
					$elm$core$Result$map,
					$zwilias$json_decode_exploration$Json$Decode$Exploration$mapAcc(f),
					decoderFn(json));
			});
	});
var $author$project$ID$decode = A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$ID$ID, $zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var $author$project$Task$Class$decodeClassID = $zwilias$json_decode_exploration$Json$Decode$Exploration$int;
var $author$project$Porting$decodeDuration = A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$SmartTime$Duration$fromInt, $zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var $author$project$Task$Class$FromDeadline = function (a) {
	return {$: 'FromDeadline', a: a};
};
var $author$project$Task$Class$decodeRelativeTiming = A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$Task$Class$FromDeadline, $author$project$Porting$decodeDuration);
var $author$project$Task$Progress$None = {$: 'None'};
var $author$project$Task$Progress$Percent = {$: 'Percent'};
var $author$project$Task$Progress$Permille = {$: 'Permille'};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$andThen = F2(
	function (toDecoderB, _v0) {
		var decoderFnA = _v0.a;
		return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				var _v1 = decoderFnA(json);
				if (_v1.$ === 'Ok') {
					var accA = _v1.a;
					var _v2 = toDecoderB(accA.value);
					var decoderFnB = _v2.a;
					return A2(
						$elm$core$Result$map,
						function (accB) {
							return _Utils_update(
								accB,
								{
									warnings: _Utils_ap(accA.warnings, accB.warnings)
								});
						},
						decoderFnB(accA.json));
				} else {
					var e = _v1.a;
					return $elm$core$Result$Err(e);
				}
			});
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$fail = function (message) {
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			return $elm$core$Result$Err(
				$mgold$elm_nonempty_list$List$Nonempty$fromElement(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
						A2(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Failure,
							message,
							$elm$core$Maybe$Just(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json))))));
		});
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$check = F3(
	function (checkDecoder, expectedVal, actualDecoder) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (actual) {
				return _Utils_eq(actual, expectedVal) ? actualDecoder : $zwilias$json_decode_exploration$Json$Decode$Exploration$fail('Verification failed');
			},
			checkDecoder);
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$BadOneOf = function (a) {
	return {$: 'BadOneOf', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOfHelp = F3(
	function (decoders, val, errorAcc) {
		oneOfHelp:
		while (true) {
			if (!decoders.b) {
				return $elm$core$Result$Err(
					$mgold$elm_nonempty_list$List$Nonempty$fromElement(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$BadOneOf(
								$elm$core$List$reverse(errorAcc)))));
			} else {
				var decoderFn = decoders.a.a;
				var rest = decoders.b;
				var _v1 = decoderFn(val);
				if (_v1.$ === 'Ok') {
					var res = _v1.a;
					return $elm$core$Result$Ok(res);
				} else {
					var e = _v1.a;
					var $temp$decoders = rest,
						$temp$val = val,
						$temp$errorAcc = A2($elm$core$List$cons, e, errorAcc);
					decoders = $temp$decoders;
					val = $temp$val;
					errorAcc = $temp$errorAcc;
					continue oneOfHelp;
				}
			}
		}
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf = function (decoders) {
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			return A3($zwilias$json_decode_exploration$Json$Decode$Exploration$oneOfHelp, decoders, json, _List_Nil);
		});
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TString = {$: 'TString'};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$string = $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'String') {
			var val = json.b;
			return A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				val);
		} else {
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TString, json);
		}
	});
var $author$project$Task$Progress$decodeUnit = $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			'Percent',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Task$Progress$Percent)),
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			'Permille',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Task$Progress$Permille)),
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			'None',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Task$Progress$None))
		]));
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TNumber = {$: 'TNumber'};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$float = $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Number') {
			var val = json.b;
			return A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				val);
		} else {
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TNumber, json);
		}
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex = F2(
	function (a, b) {
		return {$: 'AtIndex', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TArray = {$: 'TArray'};
var $mgold$elm_nonempty_list$List$Nonempty$cons = F2(
	function (y, _v0) {
		var x = _v0.a;
		var xs = _v0.b;
		return A2(
			$mgold$elm_nonempty_list$List$Nonempty$Nonempty,
			y,
			A2($elm$core$List$cons, x, xs));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$list = function (_v0) {
	var decoderFn = _v0.a;
	var finalize = function (_v5) {
		var json = _v5.a;
		var warnings = _v5.b;
		var values = _v5.c;
		return {
			json: A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, json),
			value: values,
			warnings: warnings
		};
	};
	var accumulate = F2(
		function (val, _v4) {
			var idx = _v4.a;
			var acc = _v4.b;
			var _v2 = _Utils_Tuple2(
				acc,
				decoderFn(val));
			if (_v2.a.$ === 'Err') {
				if (_v2.b.$ === 'Err') {
					var errors = _v2.a.a;
					var newErrors = _v2.b.a;
					return _Utils_Tuple2(
						idx - 1,
						$elm$core$Result$Err(
							A2(
								$mgold$elm_nonempty_list$List$Nonempty$cons,
								A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex, idx, newErrors),
								errors)));
				} else {
					var errors = _v2.a.a;
					return _Utils_Tuple2(
						idx - 1,
						$elm$core$Result$Err(errors));
				}
			} else {
				if (_v2.b.$ === 'Err') {
					var errors = _v2.b.a;
					return _Utils_Tuple2(
						idx - 1,
						$elm$core$Result$Err(
							$mgold$elm_nonempty_list$List$Nonempty$fromElement(
								A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex, idx, errors))));
				} else {
					var _v3 = _v2.a.a;
					var jsonAcc = _v3.a;
					var warnAcc = _v3.b;
					var valAcc = _v3.c;
					var res = _v2.b.a;
					return _Utils_Tuple2(
						idx - 1,
						$elm$core$Result$Ok(
							_Utils_Tuple3(
								A2($elm$core$List$cons, res.json, jsonAcc),
								_Utils_ap(res.warnings, warnAcc),
								A2($elm$core$List$cons, res.value, valAcc))));
				}
			}
		});
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			if (json.$ === 'Array') {
				var values = json.b;
				return A2(
					$elm$core$Result$map,
					finalize,
					A3(
						$elm$core$List$foldr,
						accumulate,
						_Utils_Tuple2(
							$elm$core$List$length(values) - 1,
							$elm$core$Result$Ok(
								_Utils_Tuple3(_List_Nil, _List_Nil, _List_Nil))),
						values).b);
			} else {
				return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TArray, json);
			}
		});
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TNull = {$: 'TNull'};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$null = function (val) {
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			if (json.$ === 'Null') {
				return A2(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Null(true),
					val);
			} else {
				return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TNull, json);
			}
		});
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$nullable = function (decoder) {
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
		_List_fromArray(
			[
				$zwilias$json_decode_exploration$Json$Decode$Exploration$null($elm$core$Maybe$Nothing),
				A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $elm$core$Maybe$Just, decoder)
			]));
};
var $mgold$elm_nonempty_list$List$Nonempty$append = F2(
	function (_v0, _v1) {
		var x = _v0.a;
		var xs = _v0.b;
		var y = _v1.a;
		var ys = _v1.b;
		return A2(
			$mgold$elm_nonempty_list$List$Nonempty$Nonempty,
			x,
			_Utils_ap(
				xs,
				A2($elm$core$List$cons, y, ys)));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$map2 = F3(
	function (f, _v0, _v1) {
		var decoderFnA = _v0.a;
		var decoderFnB = _v1.a;
		return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				var _v2 = decoderFnA(json);
				if (_v2.$ === 'Ok') {
					var accA = _v2.a;
					var _v3 = decoderFnB(accA.json);
					if (_v3.$ === 'Ok') {
						var accB = _v3.a;
						return $elm$core$Result$Ok(
							{
								json: accB.json,
								value: A2(f, accA.value, accB.value),
								warnings: _Utils_ap(accA.warnings, accB.warnings)
							});
					} else {
						var e = _v3.a;
						return $elm$core$Result$Err(e);
					}
				} else {
					var e = _v2.a;
					var _v4 = decoderFnB(json);
					if (_v4.$ === 'Ok') {
						return $elm$core$Result$Err(e);
					} else {
						var e2 = _v4.a;
						return $elm$core$Result$Err(
							A2($mgold$elm_nonempty_list$List$Nonempty$append, e, e2));
					}
				}
			});
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$andMap = $zwilias$json_decode_exploration$Json$Decode$Exploration$map2($elm$core$Basics$apR);
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField = F2(
	function (a, b) {
		return {$: 'InField', a: a, b: b};
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TObject = {$: 'TObject'};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TObjectField = function (a) {
	return {$: 'TObjectField', a: a};
};
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$field = F2(
	function (fieldName, _v0) {
		var decoderFn = _v0.a;
		var finalize = F2(
			function (json, _v6) {
				var values = _v6.a;
				var warnings = _v6.b;
				var res = _v6.c;
				if (res.$ === 'Nothing') {
					return A2(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$expected,
						$zwilias$json_decode_exploration$Json$Decode$Exploration$TObjectField(fieldName),
						json);
				} else {
					if (res.a.$ === 'Err') {
						var e = res.a.a;
						return $elm$core$Result$Err(e);
					} else {
						var v = res.a.a;
						return $elm$core$Result$Ok(
							{
								json: A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, values),
								value: v,
								warnings: warnings
							});
					}
				}
			});
		var accumulate = F2(
			function (_v3, _v4) {
				var key = _v3.a;
				var val = _v3.b;
				var acc = _v4.a;
				var warnings = _v4.b;
				var result = _v4.c;
				if (_Utils_eq(key, fieldName)) {
					var _v2 = decoderFn(val);
					if (_v2.$ === 'Err') {
						var e = _v2.a;
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								_Utils_Tuple2(key, val),
								acc),
							warnings,
							$elm$core$Maybe$Just(
								$elm$core$Result$Err(
									$mgold$elm_nonempty_list$List$Nonempty$fromElement(
										A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField, key, e)))));
					} else {
						var res = _v2.a;
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								_Utils_Tuple2(key, res.json),
								acc),
							_Utils_ap(
								A2(
									$elm$core$List$map,
									A2(
										$elm$core$Basics$composeR,
										$mgold$elm_nonempty_list$List$Nonempty$fromElement,
										$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField(key)),
									res.warnings),
								warnings),
							$elm$core$Maybe$Just(
								$elm$core$Result$Ok(res.value)));
					}
				} else {
					return _Utils_Tuple3(
						A2(
							$elm$core$List$cons,
							_Utils_Tuple2(key, val),
							acc),
						warnings,
						result);
				}
			});
		return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				if (json.$ === 'Object') {
					var kvPairs = json.b;
					return A2(
						finalize,
						json,
						A3(
							$elm$core$List$foldr,
							accumulate,
							_Utils_Tuple3(_List_Nil, _List_Nil, $elm$core$Maybe$Nothing),
							kvPairs));
				} else {
					return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TObject, json);
				}
			});
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required = F3(
	function (key, valDecoder, decoder) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$andMap,
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$field, key, valDecoder),
			decoder);
	});
var $author$project$Task$Class$decodeClass = A3(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'importance',
	$zwilias$json_decode_exploration$Json$Decode$Exploration$float,
	A3(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'defaultRelevanceEnds',
		$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Task$Class$decodeRelativeTiming),
		A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'defaultRelevanceStarts',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Task$Class$decodeRelativeTiming),
			A3(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'defaultFinishBy',
				$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Task$Class$decodeRelativeTiming),
				A3(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'defaultStartBy',
					$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Task$Class$decodeRelativeTiming),
					A3(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
						'defaultExternalDeadline',
						$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Task$Class$decodeRelativeTiming),
						A3(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
							'maxEffort',
							$author$project$Porting$decodeDuration,
							A3(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
								'predictedEffort',
								$author$project$Porting$decodeDuration,
								A3(
									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
									'minEffort',
									$author$project$Porting$decodeDuration,
									A3(
										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'completionUnits',
										$author$project$Task$Progress$decodeUnit,
										A3(
											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
											'activity',
											$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$ID$decode),
											A3(
												$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'id',
												$author$project$Task$Class$decodeClassID,
												A3(
													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'title',
													$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Task$Class$ClassSkel))))))))))))));
var $elm$core$Debug$todo = _Debug_todo;
var $author$project$Task$Entry$decodeEntry = function () {
	var get = function (id) {
		switch (id) {
			case 'SingletonTask':
				return _Debug_todo(
					'Task.Entry',
					{
						start: {line: 55, column: 21},
						end: {line: 55, column: 31}
					})('Cannot decode variant with params: SingletonTask');
			case 'OneoffContainer':
				return _Debug_todo(
					'Task.Entry',
					{
						start: {line: 58, column: 21},
						end: {line: 58, column: 31}
					})('Cannot decode variant with params: OneoffContainer');
			case 'RecurrenceContainer':
				return _Debug_todo(
					'Task.Entry',
					{
						start: {line: 61, column: 21},
						end: {line: 61, column: 31}
					})('Cannot decode variant with params: RecurrenceContainer');
			case 'NestedRecurrenceContainer':
				return _Debug_todo(
					'Task.Entry',
					{
						start: {line: 64, column: 21},
						end: {line: 64, column: 31}
					})('Cannot decode variant with params: NestedRecurrenceContainer');
			default:
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$fail('unknown value for Entry: ' + id);
		}
	};
	return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$andThen, get, $zwilias$json_decode_exploration$Json$Decode$Exploration$string);
}();
var $author$project$Task$Instance$InstanceSkel = function (_class) {
	return function (id) {
		return function (memberOfSeries) {
			return function (completion) {
				return function (externalDeadline) {
					return function (startBy) {
						return function (finishBy) {
							return function (plannedSessions) {
								return function (relevanceStarts) {
									return function (relevanceEnds) {
										return {_class: _class, completion: completion, externalDeadline: externalDeadline, finishBy: finishBy, id: id, memberOfSeries: memberOfSeries, plannedSessions: plannedSessions, relevanceEnds: relevanceEnds, relevanceStarts: relevanceStarts, startBy: startBy};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Task$Instance$decodeInstanceID = $zwilias$json_decode_exploration$Json$Decode$Exploration$int;
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TArrayIndex = function (a) {
	return {$: 'TArrayIndex', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$index = F2(
	function (idx, _v0) {
		var decoderFn = _v0.a;
		var finalize = F2(
			function (json, _v6) {
				var values = _v6.a;
				var warnings = _v6.b;
				var res = _v6.c;
				if (res.$ === 'Nothing') {
					return A2(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$expected,
						$zwilias$json_decode_exploration$Json$Decode$Exploration$TArrayIndex(idx),
						json);
				} else {
					if (res.a.$ === 'Err') {
						var e = res.a.a;
						return $elm$core$Result$Err(e);
					} else {
						var v = res.a.a;
						return $elm$core$Result$Ok(
							{
								json: A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, values),
								value: v,
								warnings: warnings
							});
					}
				}
			});
		var accumulate = F2(
			function (val, _v3) {
				var i = _v3.a;
				var _v4 = _v3.b;
				var acc = _v4.a;
				var warnings = _v4.b;
				var result = _v4.c;
				if (_Utils_eq(i, idx)) {
					var _v2 = decoderFn(val);
					if (_v2.$ === 'Err') {
						var e = _v2.a;
						return _Utils_Tuple2(
							i - 1,
							_Utils_Tuple3(
								A2($elm$core$List$cons, val, acc),
								warnings,
								$elm$core$Maybe$Just(
									$elm$core$Result$Err(
										$mgold$elm_nonempty_list$List$Nonempty$fromElement(
											A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex, i, e))))));
					} else {
						var res = _v2.a;
						return _Utils_Tuple2(
							i - 1,
							_Utils_Tuple3(
								A2($elm$core$List$cons, res.json, acc),
								_Utils_ap(res.warnings, warnings),
								$elm$core$Maybe$Just(
									$elm$core$Result$Ok(res.value))));
					}
				} else {
					return _Utils_Tuple2(
						i - 1,
						_Utils_Tuple3(
							A2($elm$core$List$cons, val, acc),
							warnings,
							result));
				}
			});
		return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				if (json.$ === 'Array') {
					var values = json.b;
					return A2(
						finalize,
						json,
						A3(
							$elm$core$List$foldr,
							accumulate,
							_Utils_Tuple2(
								$elm$core$List$length(values) - 1,
								_Utils_Tuple3(_List_Nil, _List_Nil, $elm$core$Maybe$Nothing)),
							values).b);
				} else {
					return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TArray, json);
				}
			});
	});
var $author$project$Porting$arrayAsTuple2 = F2(
	function (a, b) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (aVal) {
				return A2(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
					function (bVal) {
						return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
							_Utils_Tuple2(aVal, bVal));
					},
					A2($zwilias$json_decode_exploration$Json$Decode$Exploration$index, 1, b));
			},
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$index, 0, a));
	});
var $author$project$Porting$customDecoder = F2(
	function (primitiveDecoder, customDecoderFunction) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (a) {
				var _v0 = customDecoderFunction(a);
				if (_v0.$ === 'Ok') {
					var b = _v0.a;
					return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(b);
				} else {
					var err = _v0.a;
					return $zwilias$json_decode_exploration$Json$Decode$Exploration$fail(err);
				}
			},
			primitiveDecoder);
	});
var $author$project$SmartTime$Human$Moment$DateOnly = function (a) {
	return {$: 'DateOnly', a: a};
};
var $author$project$SmartTime$Human$Moment$Floating = function (a) {
	return {$: 'Floating', a: a};
};
var $author$project$SmartTime$Human$Moment$Global = function (a) {
	return {$: 'Global', a: a};
};
var $elm$core$String$endsWith = _String_endsWith;
var $elm$core$Result$andThen = F2(
	function (callback, result) {
		if (result.$ === 'Ok') {
			var value = result.a;
			return callback(value);
		} else {
			var msg = result.a;
			return $elm$core$Result$Err(msg);
		}
	});
var $author$project$SmartTime$Human$Calendar$Month$lastDay = F2(
	function (givenYear, givenMonth) {
		switch (givenMonth.$) {
			case 'Jan':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(31);
			case 'Feb':
				return $author$project$SmartTime$Human$Calendar$Year$isLeapYear(givenYear) ? $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(29) : $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(28);
			case 'Mar':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(31);
			case 'Apr':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(30);
			case 'May':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(31);
			case 'Jun':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(30);
			case 'Jul':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(31);
			case 'Aug':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(31);
			case 'Sep':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(30);
			case 'Oct':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(31);
			case 'Nov':
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(30);
			default:
				return $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(31);
		}
	});
var $author$project$SmartTime$Human$Calendar$Month$dayOfMonthValidFor = F3(
	function (givenYear, givenMonth, day) {
		var maxValidDay = $author$project$SmartTime$Human$Calendar$Month$dayToInt(
			A2($author$project$SmartTime$Human$Calendar$Month$lastDay, givenYear, givenMonth));
		return ((day > 0) && (!_Utils_eq(
			A2($elm$core$Basics$compare, day, maxValidDay),
			$elm$core$Basics$GT))) ? $elm$core$Maybe$Just(
			$author$project$SmartTime$Human$Calendar$Month$DayOfMonth(day)) : $elm$core$Maybe$Nothing;
	});
var $author$project$SmartTime$Human$Calendar$Month$toName = function (m) {
	switch (m.$) {
		case 'Jan':
			return 'January';
		case 'Feb':
			return 'February';
		case 'Mar':
			return 'March';
		case 'Apr':
			return 'April';
		case 'May':
			return 'May';
		case 'Jun':
			return 'June';
		case 'Jul':
			return 'July';
		case 'Aug':
			return 'August';
		case 'Sep':
			return 'September';
		case 'Oct':
			return 'October';
		case 'Nov':
			return 'November';
		default:
			return 'December';
	}
};
var $author$project$SmartTime$Human$Calendar$Year$isBeforeCommonEra = function (_v0) {
	var y = _v0.a;
	return y <= 0;
};
var $author$project$SmartTime$Human$Calendar$Year$toBCEYear = function (_v0) {
	var negativeYear = _v0.a;
	return (-negativeYear) + 1;
};
var $author$project$SmartTime$Human$Calendar$Year$toString = function (year) {
	var yearInt = year.a;
	return $author$project$SmartTime$Human$Calendar$Year$isBeforeCommonEra(year) ? ($elm$core$String$fromInt(
		$author$project$SmartTime$Human$Calendar$Year$toBCEYear(year)) + ' BCE') : $elm$core$String$fromInt(yearInt);
};
var $author$project$SmartTime$Human$Calendar$fromParts = function (given) {
	var _v0 = given.day;
	var dayInt = _v0.a;
	var _v1 = A3($author$project$SmartTime$Human$Calendar$Month$dayOfMonthValidFor, given.year, given.month, dayInt);
	if (_v1.$ === 'Just') {
		return $elm$core$Result$Ok(
			$author$project$SmartTime$Human$Calendar$fromPartsTrusted(given));
	} else {
		var dayString = $elm$core$String$fromInt(dayInt);
		var _v2 = given.day;
		var rawDay = _v2.a;
		return (dayInt < 1) ? $elm$core$Result$Err('You gave me a DayOfMonth of ' + (dayString + '. Non-positive values for DayOfMonth are never valid! The day should be between 1 and 31.')) : ((dayInt > 31) ? $elm$core$Result$Err('You gave me a DayOfMonth of ' + (dayString + '. No months have more than 31 days!')) : ((_Utils_eq(given.month, $author$project$SmartTime$Human$Calendar$Month$Feb) && ((dayInt === 29) && (!$author$project$SmartTime$Human$Calendar$Year$isLeapYear(given.year)))) ? $elm$core$Result$Err(
			'Sorry, but ' + ($author$project$SmartTime$Human$Calendar$Year$toString(given.year) + ' isn\'t a leap year, so that February doesn\'t have 29 days!')) : ((_Utils_cmp(
			dayInt,
			A2($author$project$SmartTime$Human$Calendar$Month$length, given.year, given.month)) > 0) ? $elm$core$Result$Err(
			'You gave me a DayOfMonth of ' + (dayString + (', but ' + ($author$project$SmartTime$Human$Calendar$Month$toName(given.month) + (' only has ' + ($elm$core$String$fromInt(
				A2($author$project$SmartTime$Human$Calendar$Month$length, given.year, given.month)) + ' days!')))))) : $elm$core$Result$Err('The date was invalid, but I\'m not sure why. Please report this issue!'))));
	}
};
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (result.$ === 'Ok') {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $elm$parser$Parser$Advanced$Empty = {$: 'Empty'};
var $elm$parser$Parser$Advanced$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var $elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 'Append', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 'Bad', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2($elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a.a;
				var remainingParsers = parsers.b;
				var _v1 = parse(s0);
				if (_v1.$ === 'Good') {
					var step = _v1;
					return step;
				} else {
					var step = _v1;
					var p = step.a;
					var x = step.b;
					if (p) {
						return step;
					} else {
						var $temp$s0 = s0,
							$temp$bag = A2($elm$parser$Parser$Advanced$Append, bag, x),
							$temp$parsers = remainingParsers;
						s0 = $temp$s0;
						bag = $temp$bag;
						parsers = $temp$parsers;
						continue oneOfHelp;
					}
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$oneOf = function (parsers) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3($elm$parser$Parser$Advanced$oneOfHelp, s, $elm$parser$Parser$Advanced$Empty, parsers);
		});
};
var $elm$parser$Parser$oneOf = $elm$parser$Parser$Advanced$oneOf;
var $elm$core$String$concat = function (strings) {
	return A2($elm$core$String$join, '', strings);
};
var $author$project$ParserExtra$problemToString = function (p) {
	switch (p.$) {
		case 'Expecting':
			var s = p.a;
			return 'expecting \'' + (s + '\'');
		case 'ExpectingInt':
			return 'expecting int';
		case 'ExpectingHex':
			return 'expecting hex';
		case 'ExpectingOctal':
			return 'expecting octal';
		case 'ExpectingBinary':
			return 'expecting binary';
		case 'ExpectingFloat':
			return 'expecting float';
		case 'ExpectingNumber':
			return 'expecting number';
		case 'ExpectingVariable':
			return 'expecting variable';
		case 'ExpectingSymbol':
			var s = p.a;
			return 'expecting symbol \'' + (s + '\'');
		case 'ExpectingKeyword':
			var s = p.a;
			return 'expecting keyword \'' + (s + '\'');
		case 'ExpectingEnd':
			return 'expecting end';
		case 'UnexpectedChar':
			return 'unexpected char';
		case 'Problem':
			var s = p.a;
			return 'Problem parsing: ' + s;
		default:
			return 'bad repeat';
	}
};
var $author$project$ParserExtra$deadEndToString = function (deadend) {
	return $author$project$ParserExtra$problemToString(deadend.problem) + (' at row ' + ($elm$core$String$fromInt(deadend.row) + (', col ' + $elm$core$String$fromInt(deadend.col))));
};
var $elm$core$List$intersperse = F2(
	function (sep, xs) {
		if (!xs.b) {
			return _List_Nil;
		} else {
			var hd = xs.a;
			var tl = xs.b;
			var step = F2(
				function (x, rest) {
					return A2(
						$elm$core$List$cons,
						sep,
						A2($elm$core$List$cons, x, rest));
				});
			var spersed = A3($elm$core$List$foldr, step, _List_Nil, tl);
			return A2($elm$core$List$cons, hd, spersed);
		}
	});
var $author$project$ParserExtra$deadEndsToString = function (deadEnds) {
	return $elm$core$String$concat(
		A2(
			$elm$core$List$intersperse,
			'; ',
			A2($elm$core$List$map, $author$project$ParserExtra$deadEndToString, deadEnds)));
};
var $author$project$ParserExtra$realDeadEndsToString = $author$project$ParserExtra$deadEndsToString;
var $elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {col: col, problem: problem, row: row};
	});
var $elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3($elm$parser$Parser$DeadEnd, p.row, p.col, p.problem);
};
var $elm$parser$Parser$Advanced$bagToList = F2(
	function (bag, list) {
		bagToList:
		while (true) {
			switch (bag.$) {
				case 'Empty':
					return list;
				case 'AddRight':
					var bag1 = bag.a;
					var x = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$core$List$cons, x, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
				default:
					var bag1 = bag.a;
					var bag2 = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$parser$Parser$Advanced$bagToList, bag2, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
			}
		}
	});
var $elm$parser$Parser$Advanced$run = F2(
	function (_v0, src) {
		var parse = _v0.a;
		var _v1 = parse(
			{col: 1, context: _List_Nil, indent: 1, offset: 0, row: 1, src: src});
		if (_v1.$ === 'Good') {
			var value = _v1.b;
			return $elm$core$Result$Ok(value);
		} else {
			var bag = _v1.b;
			return $elm$core$Result$Err(
				A2($elm$parser$Parser$Advanced$bagToList, bag, _List_Nil));
		}
	});
var $elm$parser$Parser$run = F2(
	function (parser, source) {
		var _v0 = A2($elm$parser$Parser$Advanced$run, parser, source);
		if (_v0.$ === 'Ok') {
			var a = _v0.a;
			return $elm$core$Result$Ok(a);
		} else {
			var problems = _v0.a;
			return $elm$core$Result$Err(
				A2($elm$core$List$map, $elm$parser$Parser$problemToDeadEnd, problems));
		}
	});
var $author$project$SmartTime$Human$Calendar$Parts = F3(
	function (year, month, day) {
		return {day: day, month: month, year: year};
	});
var $elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 'Good', a: a, b: b, c: c};
	});
var $elm$parser$Parser$Advanced$backtrackable = function (_v0) {
	var parse = _v0.a;
	return $elm$parser$Parser$Advanced$Parser(
		function (s0) {
			var _v1 = parse(s0);
			if (_v1.$ === 'Bad') {
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, false, x);
			} else {
				var a = _v1.b;
				var s1 = _v1.c;
				return A3($elm$parser$Parser$Advanced$Good, false, a, s1);
			}
		});
};
var $elm$parser$Parser$backtrackable = $elm$parser$Parser$Advanced$backtrackable;
var $elm$core$Basics$always = F2(
	function (a, _v0) {
		return a;
	});
var $elm$parser$Parser$Advanced$map2 = F3(
	function (func, _v0, _v1) {
		var parseA = _v0.a;
		var parseB = _v1.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v2 = parseA(s0);
				if (_v2.$ === 'Bad') {
					var p = _v2.a;
					var x = _v2.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _v2.a;
					var a = _v2.b;
					var s1 = _v2.c;
					var _v3 = parseB(s1);
					if (_v3.$ === 'Bad') {
						var p2 = _v3.a;
						var x = _v3.b;
						return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _v3.a;
						var b = _v3.b;
						var s2 = _v3.c;
						return A3(
							$elm$parser$Parser$Advanced$Good,
							p1 || p2,
							A2(func, a, b),
							s2);
					}
				}
			});
	});
var $elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$always, keepParser, ignoreParser);
	});
var $elm$parser$Parser$ignorer = $elm$parser$Parser$Advanced$ignorer;
var $elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$apL, parseFunc, parseArg);
	});
var $elm$parser$Parser$keeper = $elm$parser$Parser$Advanced$keeper;
var $elm$parser$Parser$Advanced$andThen = F2(
	function (callback, _v0) {
		var parseA = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parseA(s0);
				if (_v1.$ === 'Bad') {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					var _v2 = callback(a);
					var parseB = _v2.a;
					var _v3 = parseB(s1);
					if (_v3.$ === 'Bad') {
						var p2 = _v3.a;
						var x = _v3.b;
						return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _v3.a;
						var b = _v3.b;
						var s2 = _v3.c;
						return A3($elm$parser$Parser$Advanced$Good, p1 || p2, b, s2);
					}
				}
			});
	});
var $elm$parser$Parser$andThen = $elm$parser$Parser$Advanced$andThen;
var $elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var $elm$parser$Parser$Advanced$chompWhileHelp = F5(
	function (isGood, offset, row, col, s0) {
		chompWhileHelp:
		while (true) {
			var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, offset, s0.src);
			if (_Utils_eq(newOffset, -1)) {
				return A3(
					$elm$parser$Parser$Advanced$Good,
					_Utils_cmp(s0.offset, offset) < 0,
					_Utils_Tuple0,
					{col: col, context: s0.context, indent: s0.indent, offset: offset, row: row, src: s0.src});
			} else {
				if (_Utils_eq(newOffset, -2)) {
					var $temp$isGood = isGood,
						$temp$offset = offset + 1,
						$temp$row = row + 1,
						$temp$col = 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				} else {
					var $temp$isGood = isGood,
						$temp$offset = newOffset,
						$temp$row = row,
						$temp$col = col + 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$chompWhile = function (isGood) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A5($elm$parser$Parser$Advanced$chompWhileHelp, isGood, s.offset, s.row, s.col, s);
		});
};
var $elm$parser$Parser$chompWhile = $elm$parser$Parser$Advanced$chompWhile;
var $elm$parser$Parser$Problem = function (a) {
	return {$: 'Problem', a: a};
};
var $elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 'AddRight', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {col: col, contextStack: contextStack, problem: problem, row: row};
	});
var $elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			$elm$parser$Parser$Advanced$AddRight,
			$elm$parser$Parser$Advanced$Empty,
			A4($elm$parser$Parser$Advanced$DeadEnd, s.row, s.col, x, s.context));
	});
var $elm$parser$Parser$Advanced$problem = function (x) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var $elm$parser$Parser$problem = function (msg) {
	return $elm$parser$Parser$Advanced$problem(
		$elm$parser$Parser$Problem(msg));
};
var $author$project$ParserExtra$impossibleIntFailure = $elm$parser$Parser$problem('This should be impossible: a string of digits (verified with Char.isDigit) could not be converted to a valid `Int` (with String.fromInt).');
var $elm$parser$Parser$Advanced$succeed = function (a) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3($elm$parser$Parser$Advanced$Good, false, a, s);
		});
};
var $elm$parser$Parser$succeed = $elm$parser$Parser$Advanced$succeed;
var $author$project$ParserExtra$digitStringToInt = function (numbers) {
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$ParserExtra$impossibleIntFailure,
		A2(
			$elm$core$Maybe$map,
			$elm$parser$Parser$succeed,
			$elm$core$String$toInt(numbers)));
};
var $elm$parser$Parser$Advanced$mapChompedString = F2(
	function (func, _v0) {
		var parse = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parse(s0);
				if (_v1.$ === 'Bad') {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p,
						A2(
							func,
							A3($elm$core$String$slice, s0.offset, s1.offset, s0.src),
							a),
						s1);
				}
			});
	});
var $elm$parser$Parser$Advanced$getChompedString = function (parser) {
	return A2($elm$parser$Parser$Advanced$mapChompedString, $elm$core$Basics$always, parser);
};
var $elm$parser$Parser$getChompedString = $elm$parser$Parser$Advanced$getChompedString;
var $author$project$ParserExtra$strictPaddedInt = function (minLength) {
	var checkSize = function (digits) {
		return (_Utils_cmp(
			$elm$core$String$length(digits),
			minLength) > -1) ? $elm$parser$Parser$succeed(digits) : $elm$parser$Parser$problem(
			'Found number: ' + (digits + (' but it was not padded to a minimum of ' + ($elm$core$String$fromInt(minLength) + ' digits long.'))));
	};
	return A2(
		$elm$parser$Parser$andThen,
		$author$project$ParserExtra$digitStringToInt,
		A2(
			$elm$parser$Parser$andThen,
			checkSize,
			$elm$parser$Parser$getChompedString(
				$elm$parser$Parser$chompWhile($elm$core$Char$isDigit))));
};
var $author$project$SmartTime$Human$Calendar$Year$parse4DigitYear = function () {
	var toYearNum = function (num) {
		return $elm$parser$Parser$succeed(
			$author$project$SmartTime$Human$Calendar$Year$Year(num));
	};
	return A2(
		$elm$parser$Parser$andThen,
		toYearNum,
		$author$project$ParserExtra$strictPaddedInt(4));
}();
var $elm$parser$Parser$Advanced$map = F2(
	function (func, _v0) {
		var parse = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parse(s0);
				if (_v1.$ === 'Good') {
					var p = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p,
						func(a),
						s1);
				} else {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				}
			});
	});
var $elm$parser$Parser$map = $elm$parser$Parser$Advanced$map;
var $author$project$ParserExtra$possiblyPaddedInt = A2(
	$elm$parser$Parser$andThen,
	$author$project$ParserExtra$digitStringToInt,
	$elm$parser$Parser$getChompedString(
		$elm$parser$Parser$chompWhile($elm$core$Char$isDigit)));
var $author$project$SmartTime$Human$Calendar$Month$parseDayOfMonth = A2($elm$parser$Parser$map, $author$project$SmartTime$Human$Calendar$Month$DayOfMonth, $author$project$ParserExtra$possiblyPaddedInt);
var $author$project$SmartTime$Human$Calendar$Month$fromInt = function (n) {
	var _v0 = A2($elm$core$Basics$max, 1, n);
	switch (_v0) {
		case 1:
			return $author$project$SmartTime$Human$Calendar$Month$Jan;
		case 2:
			return $author$project$SmartTime$Human$Calendar$Month$Feb;
		case 3:
			return $author$project$SmartTime$Human$Calendar$Month$Mar;
		case 4:
			return $author$project$SmartTime$Human$Calendar$Month$Apr;
		case 5:
			return $author$project$SmartTime$Human$Calendar$Month$May;
		case 6:
			return $author$project$SmartTime$Human$Calendar$Month$Jun;
		case 7:
			return $author$project$SmartTime$Human$Calendar$Month$Jul;
		case 8:
			return $author$project$SmartTime$Human$Calendar$Month$Aug;
		case 9:
			return $author$project$SmartTime$Human$Calendar$Month$Sep;
		case 10:
			return $author$project$SmartTime$Human$Calendar$Month$Oct;
		case 11:
			return $author$project$SmartTime$Human$Calendar$Month$Nov;
		default:
			return $author$project$SmartTime$Human$Calendar$Month$Dec;
	}
};
var $author$project$SmartTime$Human$Calendar$Month$parseMonthInt = function () {
	var checkMonth = function (givenInt) {
		return ((givenInt >= 1) && (givenInt <= 12)) ? $elm$parser$Parser$succeed(
			$author$project$SmartTime$Human$Calendar$Month$fromInt(givenInt)) : $elm$parser$Parser$problem(
			'A month number should be from 1 to 12, but I got ' + ($elm$core$String$fromInt(givenInt) + ' instead?'));
	};
	return A2($elm$parser$Parser$andThen, checkMonth, $author$project$ParserExtra$possiblyPaddedInt);
}();
var $elm$parser$Parser$Advanced$spaces = $elm$parser$Parser$Advanced$chompWhile(
	function (c) {
		return _Utils_eq(
			c,
			_Utils_chr(' ')) || (_Utils_eq(
			c,
			_Utils_chr('\n')) || _Utils_eq(
			c,
			_Utils_chr('\r')));
	});
var $elm$parser$Parser$spaces = $elm$parser$Parser$Advanced$spaces;
var $elm$parser$Parser$ExpectingSymbol = function (a) {
	return {$: 'ExpectingSymbol', a: a};
};
var $elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 'Token', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var $elm$parser$Parser$Advanced$token = function (_v0) {
	var str = _v0.a;
	var expecting = _v0.b;
	var progress = !$elm$core$String$isEmpty(str);
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			var _v1 = A5($elm$parser$Parser$Advanced$isSubString, str, s.offset, s.row, s.col, s.src);
			var newOffset = _v1.a;
			var newRow = _v1.b;
			var newCol = _v1.c;
			return _Utils_eq(newOffset, -1) ? A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
				$elm$parser$Parser$Advanced$Good,
				progress,
				_Utils_Tuple0,
				{col: newCol, context: s.context, indent: s.indent, offset: newOffset, row: newRow, src: s.src});
		});
};
var $elm$parser$Parser$Advanced$symbol = $elm$parser$Parser$Advanced$token;
var $elm$parser$Parser$symbol = function (str) {
	return $elm$parser$Parser$Advanced$symbol(
		A2(
			$elm$parser$Parser$Advanced$Token,
			str,
			$elm$parser$Parser$ExpectingSymbol(str)));
};
var $author$project$SmartTime$Human$Calendar$separatedYMD = function (separator) {
	return A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			A2(
				$elm$parser$Parser$keeper,
				A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed($author$project$SmartTime$Human$Calendar$Parts),
					$elm$parser$Parser$spaces),
				A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$backtrackable($author$project$SmartTime$Human$Calendar$Year$parse4DigitYear),
					$elm$parser$Parser$symbol(separator))),
			A2(
				$elm$parser$Parser$ignorer,
				$author$project$SmartTime$Human$Calendar$Month$parseMonthInt,
				$elm$parser$Parser$symbol(separator))),
		$author$project$SmartTime$Human$Calendar$Month$parseDayOfMonth);
};
var $author$project$SmartTime$Human$Calendar$fromNumberString = function (input) {
	var parserResult = A2(
		$elm$parser$Parser$run,
		$elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					$author$project$SmartTime$Human$Calendar$separatedYMD('-'),
					$author$project$SmartTime$Human$Calendar$separatedYMD('/'),
					$author$project$SmartTime$Human$Calendar$separatedYMD('.'),
					$author$project$SmartTime$Human$Calendar$separatedYMD(' ')
				])),
		input);
	var stringErrorResult = A2($elm$core$Result$mapError, $author$project$ParserExtra$realDeadEndsToString, parserResult);
	return A2($elm$core$Result$andThen, $author$project$SmartTime$Human$Calendar$fromParts, stringErrorResult);
};
var $elm$parser$Parser$ExpectingEnd = {$: 'ExpectingEnd'};
var $elm$parser$Parser$Advanced$end = function (x) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return _Utils_eq(
				$elm$core$String$length(s.src),
				s.offset) ? A3($elm$parser$Parser$Advanced$Good, false, _Utils_Tuple0, s) : A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var $elm$parser$Parser$end = $elm$parser$Parser$Advanced$end($elm$parser$Parser$ExpectingEnd);
var $author$project$SmartTime$Human$Moment$fromStringHelper = F2(
	function (givenParser, input) {
		var parserResult = A2($elm$parser$Parser$run, givenParser, input);
		var withNiceErrors = A2($elm$core$Result$mapError, $author$project$ParserExtra$realDeadEndsToString, parserResult);
		var combiner = F2(
			function (d, t) {
				return A3($author$project$SmartTime$Human$Moment$fromDateAndTime, $author$project$SmartTime$Human$Moment$utc, d, t);
			});
		var fromAll = function (_v0) {
			var dateparts = _v0.a;
			var time = _v0.b;
			return A2(
				$elm$core$Result$map,
				function (d) {
					return A2(combiner, d, time);
				},
				$author$project$SmartTime$Human$Calendar$fromParts(dateparts));
		};
		return A2($elm$core$Result$andThen, fromAll, withNiceErrors);
	});
var $elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var $elm$parser$Parser$ExpectingFloat = {$: 'ExpectingFloat'};
var $elm$parser$Parser$Advanced$consumeBase = _Parser_consumeBase;
var $elm$parser$Parser$Advanced$consumeBase16 = _Parser_consumeBase16;
var $elm$parser$Parser$Advanced$bumpOffset = F2(
	function (newOffset, s) {
		return {col: s.col + (newOffset - s.offset), context: s.context, indent: s.indent, offset: newOffset, row: s.row, src: s.src};
	});
var $elm$parser$Parser$Advanced$chompBase10 = _Parser_chompBase10;
var $elm$parser$Parser$Advanced$isAsciiCode = _Parser_isAsciiCode;
var $elm$parser$Parser$Advanced$consumeExp = F2(
	function (offset, src) {
		if (A3($elm$parser$Parser$Advanced$isAsciiCode, 101, offset, src) || A3($elm$parser$Parser$Advanced$isAsciiCode, 69, offset, src)) {
			var eOffset = offset + 1;
			var expOffset = (A3($elm$parser$Parser$Advanced$isAsciiCode, 43, eOffset, src) || A3($elm$parser$Parser$Advanced$isAsciiCode, 45, eOffset, src)) ? (eOffset + 1) : eOffset;
			var newOffset = A2($elm$parser$Parser$Advanced$chompBase10, expOffset, src);
			return _Utils_eq(expOffset, newOffset) ? (-newOffset) : newOffset;
		} else {
			return offset;
		}
	});
var $elm$parser$Parser$Advanced$consumeDotAndExp = F2(
	function (offset, src) {
		return A3($elm$parser$Parser$Advanced$isAsciiCode, 46, offset, src) ? A2(
			$elm$parser$Parser$Advanced$consumeExp,
			A2($elm$parser$Parser$Advanced$chompBase10, offset + 1, src),
			src) : A2($elm$parser$Parser$Advanced$consumeExp, offset, src);
	});
var $elm$parser$Parser$Advanced$finalizeInt = F5(
	function (invalid, handler, startOffset, _v0, s) {
		var endOffset = _v0.a;
		var n = _v0.b;
		if (handler.$ === 'Err') {
			var x = handler.a;
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				true,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		} else {
			var toValue = handler.a;
			return _Utils_eq(startOffset, endOffset) ? A2(
				$elm$parser$Parser$Advanced$Bad,
				_Utils_cmp(s.offset, startOffset) < 0,
				A2($elm$parser$Parser$Advanced$fromState, s, invalid)) : A3(
				$elm$parser$Parser$Advanced$Good,
				true,
				toValue(n),
				A2($elm$parser$Parser$Advanced$bumpOffset, endOffset, s));
		}
	});
var $elm$parser$Parser$Advanced$fromInfo = F4(
	function (row, col, x, context) {
		return A2(
			$elm$parser$Parser$Advanced$AddRight,
			$elm$parser$Parser$Advanced$Empty,
			A4($elm$parser$Parser$Advanced$DeadEnd, row, col, x, context));
	});
var $elm$core$String$toFloat = _String_toFloat;
var $elm$parser$Parser$Advanced$finalizeFloat = F6(
	function (invalid, expecting, intSettings, floatSettings, intPair, s) {
		var intOffset = intPair.a;
		var floatOffset = A2($elm$parser$Parser$Advanced$consumeDotAndExp, intOffset, s.src);
		if (floatOffset < 0) {
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				true,
				A4($elm$parser$Parser$Advanced$fromInfo, s.row, s.col - (floatOffset + s.offset), invalid, s.context));
		} else {
			if (_Utils_eq(s.offset, floatOffset)) {
				return A2(
					$elm$parser$Parser$Advanced$Bad,
					false,
					A2($elm$parser$Parser$Advanced$fromState, s, expecting));
			} else {
				if (_Utils_eq(intOffset, floatOffset)) {
					return A5($elm$parser$Parser$Advanced$finalizeInt, invalid, intSettings, s.offset, intPair, s);
				} else {
					if (floatSettings.$ === 'Err') {
						var x = floatSettings.a;
						return A2(
							$elm$parser$Parser$Advanced$Bad,
							true,
							A2($elm$parser$Parser$Advanced$fromState, s, invalid));
					} else {
						var toValue = floatSettings.a;
						var _v1 = $elm$core$String$toFloat(
							A3($elm$core$String$slice, s.offset, floatOffset, s.src));
						if (_v1.$ === 'Nothing') {
							return A2(
								$elm$parser$Parser$Advanced$Bad,
								true,
								A2($elm$parser$Parser$Advanced$fromState, s, invalid));
						} else {
							var n = _v1.a;
							return A3(
								$elm$parser$Parser$Advanced$Good,
								true,
								toValue(n),
								A2($elm$parser$Parser$Advanced$bumpOffset, floatOffset, s));
						}
					}
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$number = function (c) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			if (A3($elm$parser$Parser$Advanced$isAsciiCode, 48, s.offset, s.src)) {
				var zeroOffset = s.offset + 1;
				var baseOffset = zeroOffset + 1;
				return A3($elm$parser$Parser$Advanced$isAsciiCode, 120, zeroOffset, s.src) ? A5(
					$elm$parser$Parser$Advanced$finalizeInt,
					c.invalid,
					c.hex,
					baseOffset,
					A2($elm$parser$Parser$Advanced$consumeBase16, baseOffset, s.src),
					s) : (A3($elm$parser$Parser$Advanced$isAsciiCode, 111, zeroOffset, s.src) ? A5(
					$elm$parser$Parser$Advanced$finalizeInt,
					c.invalid,
					c.octal,
					baseOffset,
					A3($elm$parser$Parser$Advanced$consumeBase, 8, baseOffset, s.src),
					s) : (A3($elm$parser$Parser$Advanced$isAsciiCode, 98, zeroOffset, s.src) ? A5(
					$elm$parser$Parser$Advanced$finalizeInt,
					c.invalid,
					c.binary,
					baseOffset,
					A3($elm$parser$Parser$Advanced$consumeBase, 2, baseOffset, s.src),
					s) : A6(
					$elm$parser$Parser$Advanced$finalizeFloat,
					c.invalid,
					c.expecting,
					c._int,
					c._float,
					_Utils_Tuple2(zeroOffset, 0),
					s)));
			} else {
				return A6(
					$elm$parser$Parser$Advanced$finalizeFloat,
					c.invalid,
					c.expecting,
					c._int,
					c._float,
					A3($elm$parser$Parser$Advanced$consumeBase, 10, s.offset, s.src),
					s);
			}
		});
};
var $elm$parser$Parser$Advanced$float = F2(
	function (expecting, invalid) {
		return $elm$parser$Parser$Advanced$number(
			{
				binary: $elm$core$Result$Err(invalid),
				expecting: expecting,
				_float: $elm$core$Result$Ok($elm$core$Basics$identity),
				hex: $elm$core$Result$Err(invalid),
				_int: $elm$core$Result$Ok($elm$core$Basics$toFloat),
				invalid: invalid,
				octal: $elm$core$Result$Err(invalid)
			});
	});
var $elm$parser$Parser$float = A2($elm$parser$Parser$Advanced$float, $elm$parser$Parser$ExpectingFloat, $elm$parser$Parser$ExpectingFloat);
var $author$project$ParserExtra$strictLengthInt = F2(
	function (minLength, maxLength) {
		var checkSize = function (digits) {
			return (_Utils_cmp(
				$elm$core$String$length(digits),
				minLength) > -1) ? ((_Utils_cmp(
				$elm$core$String$length(digits),
				maxLength) < 1) ? $elm$parser$Parser$succeed(digits) : $elm$parser$Parser$problem(
				'Found number: ' + (digits + (' but it exceeded the maximum of ' + ($elm$core$String$fromInt(maxLength) + ' digits long.'))))) : $elm$parser$Parser$problem(
				'Found number: ' + (digits + (' but it was not padded to a minimum of ' + ($elm$core$String$fromInt(minLength) + ' digits long.'))));
		};
		return A2(
			$elm$parser$Parser$andThen,
			$author$project$ParserExtra$digitStringToInt,
			A2(
				$elm$parser$Parser$andThen,
				checkSize,
				$elm$parser$Parser$getChompedString(
					$elm$parser$Parser$chompWhile($elm$core$Char$isDigit))));
	});
var $author$project$SmartTime$Human$Clock$parseHMS = function () {
	var secsFracToMs = function (frac) {
		return $elm$core$Basics$round(frac * 1000);
	};
	var decimalOptional = $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				$elm$parser$Parser$float,
				$elm$parser$Parser$succeed(0)
			]));
	return A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			A2(
				$elm$parser$Parser$keeper,
				A2(
					$elm$parser$Parser$keeper,
					$elm$parser$Parser$succeed($author$project$SmartTime$Human$Clock$clock),
					A2(
						$elm$parser$Parser$ignorer,
						$elm$parser$Parser$backtrackable($author$project$ParserExtra$possiblyPaddedInt),
						$elm$parser$Parser$symbol(':'))),
				A2(
					$elm$parser$Parser$ignorer,
					A2($author$project$ParserExtra$strictLengthInt, 2, 2),
					$elm$parser$Parser$symbol(':'))),
			A2($author$project$ParserExtra$strictLengthInt, 2, 2)),
		A2($elm$parser$Parser$map, secsFracToMs, decimalOptional));
}();
var $author$project$SmartTime$Human$Moment$fromStandardString = function (input) {
	var combinedParser = A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			$elm$parser$Parser$succeed($elm$core$Tuple$pair),
			A2(
				$elm$parser$Parser$ignorer,
				$author$project$SmartTime$Human$Calendar$separatedYMD('-'),
				$elm$parser$Parser$symbol('T'))),
		A2(
			$elm$parser$Parser$ignorer,
			A2(
				$elm$parser$Parser$ignorer,
				$author$project$SmartTime$Human$Clock$parseHMS,
				$elm$parser$Parser$symbol('Z')),
			$elm$parser$Parser$end));
	return A2($author$project$SmartTime$Human$Moment$fromStringHelper, combinedParser, input);
};
var $author$project$SmartTime$Human$Moment$fromStandardStringLoose = function (input) {
	var combinedParser = A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			$elm$parser$Parser$succeed($elm$core$Tuple$pair),
			A2(
				$elm$parser$Parser$ignorer,
				$author$project$SmartTime$Human$Calendar$separatedYMD('-'),
				$elm$parser$Parser$symbol('T'))),
		$author$project$SmartTime$Human$Clock$parseHMS);
	return A2($author$project$SmartTime$Human$Moment$fromStringHelper, combinedParser, input);
};
var $author$project$SmartTime$Duration$fromDays = function (_float) {
	return $author$project$SmartTime$Duration$Duration(
		$elm$core$Basics$round(_float * $author$project$SmartTime$Duration$dayLength));
};
var $author$project$SmartTime$Human$Calendar$fromRataDie = $author$project$SmartTime$Human$Calendar$CalendarDate;
var $author$project$SmartTime$Duration$inWholeDays = function (duration) {
	return ($author$project$SmartTime$Duration$inMs(duration) / $author$project$SmartTime$Duration$dayLength) | 0;
};
var $author$project$SmartTime$Moment$utcFromLinear = function (momentAsDur) {
	return A2(
		$author$project$SmartTime$Duration$subtract,
		momentAsDur,
		$author$project$SmartTime$Moment$utcOffset(momentAsDur));
};
var $author$project$SmartTime$Moment$toInt = F3(
	function (_v0, timeScale, _v1) {
		var inputTAI = _v0.a;
		var epochDur = _v1.a;
		var newScale = function () {
			switch (timeScale.$) {
				case 'TAI':
					return inputTAI;
				case 'UTC':
					return $author$project$SmartTime$Moment$utcFromLinear(inputTAI);
				case 'GPS':
					return A2(
						$author$project$SmartTime$Duration$subtract,
						inputTAI,
						$author$project$SmartTime$Duration$fromSeconds(19));
				default:
					return A2(
						$author$project$SmartTime$Duration$subtract,
						inputTAI,
						$author$project$SmartTime$Duration$fromMs(32184));
			}
		}();
		return $author$project$SmartTime$Duration$inMs(
			A2($author$project$SmartTime$Duration$subtract, newScale, epochDur));
	});
var $author$project$SmartTime$Human$Moment$toUTCAndLocalize = F2(
	function (zone, moment) {
		var momentAsDur = $author$project$SmartTime$Duration$fromInt(
			A3($author$project$SmartTime$Moment$toInt, moment, $author$project$SmartTime$Moment$UTC, $author$project$SmartTime$Moment$commonEraStart));
		return A2(
			$author$project$SmartTime$Duration$add,
			momentAsDur,
			A2($author$project$SmartTime$Human$Moment$getOffset, moment, zone));
	});
var $author$project$SmartTime$Human$Moment$humanize = F2(
	function (zone, moment) {
		var localMomentDur = A2($author$project$SmartTime$Human$Moment$toUTCAndLocalize, zone, moment);
		var daysSinceEpoch = $author$project$SmartTime$Duration$inWholeDays(localMomentDur);
		var remaining = A2(
			$author$project$SmartTime$Duration$subtract,
			localMomentDur,
			$author$project$SmartTime$Duration$fromDays(daysSinceEpoch));
		return _Utils_Tuple2(
			$author$project$SmartTime$Human$Calendar$fromRataDie(daysSinceEpoch),
			remaining);
	});
var $author$project$SmartTime$Human$Moment$fuzzyFromString = function (givenString) {
	return A2($elm$core$String$endsWith, 'Z', givenString) ? A2(
		$elm$core$Result$map,
		$author$project$SmartTime$Human$Moment$Global,
		$author$project$SmartTime$Human$Moment$fromStandardString(givenString)) : (A2($elm$core$String$contains, 'T', givenString) ? A2(
		$elm$core$Result$map,
		A2(
			$elm$core$Basics$composeL,
			$author$project$SmartTime$Human$Moment$Floating,
			$author$project$SmartTime$Human$Moment$humanize($author$project$SmartTime$Human$Moment$utc)),
		$author$project$SmartTime$Human$Moment$fromStandardStringLoose(givenString)) : A2(
		$elm$core$Result$map,
		$author$project$SmartTime$Human$Moment$DateOnly,
		$author$project$SmartTime$Human$Calendar$fromNumberString(givenString)));
};
var $author$project$Porting$decodeFuzzyMoment = A2($author$project$Porting$customDecoder, $zwilias$json_decode_exploration$Json$Decode$Exploration$string, $author$project$SmartTime$Human$Moment$fuzzyFromString);
var $author$project$Task$SessionSkel$decodeSession = A2($author$project$Porting$arrayAsTuple2, $author$project$Porting$decodeFuzzyMoment, $author$project$Porting$decodeDuration);
var $author$project$Task$Class$decodeTaskMoment = A2($author$project$Porting$customDecoder, $zwilias$json_decode_exploration$Json$Decode$Exploration$string, $author$project$SmartTime$Human$Moment$fuzzyFromString);
var $zwilias$json_decode_exploration$Json$Decode$Exploration$isObject = $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Object') {
			var pairs = json.b;
			return A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, pairs),
				_Utils_Tuple0);
		} else {
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TObject, json);
		}
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$resolve = $zwilias$json_decode_exploration$Json$Decode$Exploration$andThen($elm$core$Basics$identity);
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optionalField = F3(
	function (field, decoder, fallback) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (_v0) {
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$resolve(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
						_List_fromArray(
							[
								A2(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$field,
								field,
								$zwilias$json_decode_exploration$Json$Decode$Exploration$null(
									$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(fallback))),
								A2(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$field,
								field,
								$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
									A2($zwilias$json_decode_exploration$Json$Decode$Exploration$field, field, decoder))),
								$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(fallback))
							])));
			},
			$zwilias$json_decode_exploration$Json$Decode$Exploration$isObject);
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional = F4(
	function (key, valDecoder, fallback, decoder) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$andMap,
			A3($zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optionalField, key, valDecoder, fallback),
			decoder);
	});
var $author$project$Task$Instance$decodeInstance = A3(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'relevanceEnds',
	$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Task$Class$decodeTaskMoment),
	A3(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'relevanceStarts',
		$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Task$Class$decodeTaskMoment),
		A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'plannedSessions',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Task$SessionSkel$decodeSession),
			A3(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'finishBy',
				$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Task$Class$decodeTaskMoment),
				A3(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'startBy',
					$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Task$Class$decodeTaskMoment),
					A3(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
						'externalDeadline',
						$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Task$Class$decodeTaskMoment),
						A3(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
							'completion',
							$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
							A4(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
								'memberOfSeries',
								$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$int),
								$elm$core$Maybe$Nothing,
								A3(
									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
									'id',
									$author$project$Task$Instance$decodeInstanceID,
									A3(
										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'class',
										$author$project$Task$Class$decodeClassID,
										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Task$Instance$InstanceSkel)))))))))));
var $author$project$Porting$decodeTuple2 = F2(
	function (decoderA, decoderB) {
		return A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$map2,
			$elm$core$Tuple$pair,
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$index, 0, decoderA),
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$index, 1, decoderB));
	});
var $elm_community$intdict$IntDict$Inner = function (a) {
	return {$: 'Inner', a: a};
};
var $elm_community$intdict$IntDict$size = function (dict) {
	switch (dict.$) {
		case 'Empty':
			return 0;
		case 'Leaf':
			return 1;
		default:
			var i = dict.a;
			return i.size;
	}
};
var $elm_community$intdict$IntDict$inner = F3(
	function (p, l, r) {
		var _v0 = _Utils_Tuple2(l, r);
		if (_v0.a.$ === 'Empty') {
			var _v1 = _v0.a;
			return r;
		} else {
			if (_v0.b.$ === 'Empty') {
				var _v2 = _v0.b;
				return l;
			} else {
				return $elm_community$intdict$IntDict$Inner(
					{
						left: l,
						prefix: p,
						right: r,
						size: $elm_community$intdict$IntDict$size(l) + $elm_community$intdict$IntDict$size(r)
					});
			}
		}
	});
var $elm$core$Bitwise$complement = _Bitwise_complement;
var $elm_community$intdict$IntDict$highestBitSet = function (n) {
	var shiftOr = F2(
		function (i, shift) {
			return i | (i >>> shift);
		});
	var n1 = A2(shiftOr, n, 1);
	var n2 = A2(shiftOr, n1, 2);
	var n3 = A2(shiftOr, n2, 4);
	var n4 = A2(shiftOr, n3, 8);
	var n5 = A2(shiftOr, n4, 16);
	return n5 & (~(n5 >>> 1));
};
var $elm_community$intdict$IntDict$signBit = $elm_community$intdict$IntDict$highestBitSet(-1);
var $elm_community$intdict$IntDict$isBranchingBitSet = function (p) {
	return A2(
		$elm$core$Basics$composeR,
		$elm$core$Bitwise$xor($elm_community$intdict$IntDict$signBit),
		A2(
			$elm$core$Basics$composeR,
			$elm$core$Bitwise$and(p.branchingBit),
			$elm$core$Basics$neq(0)));
};
var $elm_community$intdict$IntDict$higherBitMask = function (branchingBit) {
	return branchingBit ^ (~(branchingBit - 1));
};
var $elm_community$intdict$IntDict$lcp = F2(
	function (x, y) {
		var branchingBit = $elm_community$intdict$IntDict$highestBitSet(x ^ y);
		var mask = $elm_community$intdict$IntDict$higherBitMask(branchingBit);
		var prefixBits = x & mask;
		return {branchingBit: branchingBit, prefixBits: prefixBits};
	});
var $elm_community$intdict$IntDict$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm_community$intdict$IntDict$leaf = F2(
	function (k, v) {
		return $elm_community$intdict$IntDict$Leaf(
			{key: k, value: v});
	});
var $elm_community$intdict$IntDict$prefixMatches = F2(
	function (p, n) {
		return _Utils_eq(
			n & $elm_community$intdict$IntDict$higherBitMask(p.branchingBit),
			p.prefixBits);
	});
var $elm_community$intdict$IntDict$update = F3(
	function (key, alter, dict) {
		var join = F2(
			function (_v2, _v3) {
				var k1 = _v2.a;
				var l = _v2.b;
				var k2 = _v3.a;
				var r = _v3.b;
				var prefix = A2($elm_community$intdict$IntDict$lcp, k1, k2);
				return A2($elm_community$intdict$IntDict$isBranchingBitSet, prefix, k2) ? A3($elm_community$intdict$IntDict$inner, prefix, l, r) : A3($elm_community$intdict$IntDict$inner, prefix, r, l);
			});
		var alteredNode = function (mv) {
			var _v1 = alter(mv);
			if (_v1.$ === 'Just') {
				var v = _v1.a;
				return A2($elm_community$intdict$IntDict$leaf, key, v);
			} else {
				return $elm_community$intdict$IntDict$empty;
			}
		};
		switch (dict.$) {
			case 'Empty':
				return alteredNode($elm$core$Maybe$Nothing);
			case 'Leaf':
				var l = dict.a;
				return _Utils_eq(l.key, key) ? alteredNode(
					$elm$core$Maybe$Just(l.value)) : A2(
					join,
					_Utils_Tuple2(
						key,
						alteredNode($elm$core$Maybe$Nothing)),
					_Utils_Tuple2(l.key, dict));
			default:
				var i = dict.a;
				return A2($elm_community$intdict$IntDict$prefixMatches, i.prefix, key) ? (A2($elm_community$intdict$IntDict$isBranchingBitSet, i.prefix, key) ? A3(
					$elm_community$intdict$IntDict$inner,
					i.prefix,
					i.left,
					A3($elm_community$intdict$IntDict$update, key, alter, i.right)) : A3(
					$elm_community$intdict$IntDict$inner,
					i.prefix,
					A3($elm_community$intdict$IntDict$update, key, alter, i.left),
					i.right)) : A2(
					join,
					_Utils_Tuple2(
						key,
						alteredNode($elm$core$Maybe$Nothing)),
					_Utils_Tuple2(i.prefix.prefixBits, dict));
		}
	});
var $elm_community$intdict$IntDict$insert = F3(
	function (key, value, dict) {
		return A3(
			$elm_community$intdict$IntDict$update,
			key,
			$elm$core$Basics$always(
				$elm$core$Maybe$Just(value)),
			dict);
	});
var $elm_community$intdict$IntDict$fromList = function (pairs) {
	return A3(
		$elm$core$List$foldl,
		function (_v0) {
			var a = _v0.a;
			var b = _v0.b;
			return A2($elm_community$intdict$IntDict$insert, a, b);
		},
		$elm_community$intdict$IntDict$empty,
		pairs);
};
var $author$project$Porting$decodeIntDict = function (valueDecoder) {
	return A2(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$map,
		$elm_community$intdict$IntDict$fromList,
		$zwilias$json_decode_exploration$Json$Decode$Exploration$list(
			A2($author$project$Porting$decodeTuple2, $zwilias$json_decode_exploration$Json$Decode$Exploration$int, valueDecoder)));
};
var $author$project$Activity$Activity$Customizations = function (names) {
	return function (icon) {
		return function (excusable) {
			return function (taskOptional) {
				return function (evidence) {
					return function (category) {
						return function (backgroundable) {
							return function (maxTime) {
								return function (hidden) {
									return function (template) {
										return function (id) {
											return function (externalIDs) {
												return {backgroundable: backgroundable, category: category, evidence: evidence, excusable: excusable, externalIDs: externalIDs, hidden: hidden, icon: icon, id: id, maxTime: maxTime, names: names, taskOptional: taskOptional, template: template};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$TBool = {$: 'TBool'};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$bool = $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Bool') {
			var val = json.b;
			return A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				val);
		} else {
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TBool, json);
		}
	});
var $author$project$Activity$Activity$Communication = {$: 'Communication'};
var $author$project$Activity$Activity$Entertainment = {$: 'Entertainment'};
var $author$project$Activity$Activity$Hygiene = {$: 'Hygiene'};
var $author$project$Activity$Activity$Slacking = {$: 'Slacking'};
var $author$project$Activity$Activity$Transit = {$: 'Transit'};
var $author$project$Activity$Activity$decodeCategory = A2(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
	function (string) {
		switch (string) {
			case 'Transit':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$Transit);
			case 'Entertainment':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$Entertainment);
			case 'Hygiene':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$Hygiene);
			case 'Slacking':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$Slacking);
			case 'Communication':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$Communication);
			default:
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$fail('Invalid Category');
		}
	},
	$zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var $author$project$SmartTime$Human$Duration$Days = function (a) {
	return {$: 'Days', a: a};
};
var $author$project$SmartTime$Duration$breakdown = function (duration) {
	var all = $author$project$SmartTime$Duration$inMs(duration);
	var days = (all / $author$project$SmartTime$Duration$dayLength) | 0;
	var withoutDays = all - (days * $author$project$SmartTime$Duration$dayLength);
	var hours = (withoutDays / $author$project$SmartTime$Duration$hourLength) | 0;
	var withoutHours = withoutDays - (hours * $author$project$SmartTime$Duration$hourLength);
	var minutes = (withoutHours / $author$project$SmartTime$Duration$minuteLength) | 0;
	var withoutMinutes = withoutHours - (minutes * $author$project$SmartTime$Duration$minuteLength);
	var seconds = (withoutMinutes / $author$project$SmartTime$Duration$secondLength) | 0;
	var withoutSeconds = withoutMinutes - (seconds * $author$project$SmartTime$Duration$secondLength);
	return {days: days, hours: hours, milliseconds: withoutSeconds, minutes: minutes, seconds: seconds};
};
var $author$project$SmartTime$Human$Duration$breakdownDHMSM = function (duration) {
	var _v0 = $author$project$SmartTime$Duration$breakdown(duration);
	var days = _v0.days;
	var hours = _v0.hours;
	var minutes = _v0.minutes;
	var seconds = _v0.seconds;
	var milliseconds = _v0.milliseconds;
	return _List_fromArray(
		[
			$author$project$SmartTime$Human$Duration$Days(days),
			$author$project$SmartTime$Human$Duration$Hours(hours),
			$author$project$SmartTime$Human$Duration$Minutes(minutes),
			$author$project$SmartTime$Human$Duration$Seconds(seconds),
			$author$project$SmartTime$Human$Duration$Milliseconds(milliseconds)
		]);
};
var $author$project$SmartTime$Duration$inWholeHours = function (duration) {
	return ($author$project$SmartTime$Duration$inMs(duration) / $author$project$SmartTime$Duration$hourLength) | 0;
};
var $author$project$SmartTime$Duration$inWholeMinutes = function (duration) {
	return ($author$project$SmartTime$Duration$inMs(duration) / $author$project$SmartTime$Duration$minuteLength) | 0;
};
var $author$project$SmartTime$Duration$inWholeSeconds = function (duration) {
	return ($author$project$SmartTime$Duration$inMs(duration) / $author$project$SmartTime$Duration$secondLength) | 0;
};
var $author$project$SmartTime$Human$Duration$inLargestExactUnits = function (duration) {
	var smallestPartMaybe = $elm_community$list_extra$List$Extra$last(
		$author$project$SmartTime$Human$Duration$breakdownDHMSM(duration));
	var smallestPart = A2(
		$elm$core$Maybe$withDefault,
		$author$project$SmartTime$Human$Duration$Milliseconds(0),
		smallestPartMaybe);
	switch (smallestPart.$) {
		case 'Days':
			var days = smallestPart.a;
			return $author$project$SmartTime$Human$Duration$Days(days);
		case 'Hours':
			var hours = smallestPart.a;
			return $author$project$SmartTime$Human$Duration$Hours(
				$author$project$SmartTime$Duration$inWholeHours(duration));
		case 'Minutes':
			var minutes = smallestPart.a;
			return $author$project$SmartTime$Human$Duration$Minutes(
				$author$project$SmartTime$Duration$inWholeMinutes(duration));
		case 'Seconds':
			var seconds = smallestPart.a;
			return $author$project$SmartTime$Human$Duration$Seconds(
				$author$project$SmartTime$Duration$inWholeSeconds(duration));
		default:
			var milliseconds = smallestPart.a;
			return $author$project$SmartTime$Human$Duration$Milliseconds(
				$author$project$SmartTime$Duration$inMs(duration));
	}
};
var $author$project$Activity$Activity$decodeHumanDuration = function () {
	var convertAndNormalize = function (durationAsInt) {
		return $author$project$SmartTime$Human$Duration$inLargestExactUnits(
			$author$project$SmartTime$Duration$fromInt(durationAsInt));
	};
	return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, convertAndNormalize, $zwilias$json_decode_exploration$Json$Decode$Exploration$int);
}();
var $author$project$Activity$Activity$decodeDurationPerPeriod = A2($author$project$Porting$arrayAsTuple2, $author$project$Activity$Activity$decodeHumanDuration, $author$project$Activity$Activity$decodeHumanDuration);
var $author$project$Activity$Evidence$AppDescriptor = F2(
	function (_package, name) {
		return {name: name, _package: _package};
	});
var $author$project$Activity$Evidence$StepCountPace = function (a) {
	return {$: 'StepCountPace', a: a};
};
var $author$project$Activity$Evidence$UsingApp = F2(
	function (a, b) {
		return {$: 'UsingApp', a: a, b: b};
	});
var $author$project$Activity$Evidence$decodeEvidence = A2(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
	function (string) {
		switch (string) {
			case 'UsingApp':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
					A2(
						$author$project$Activity$Evidence$UsingApp,
						A2($author$project$Activity$Evidence$AppDescriptor, '', ''),
						$elm$core$Maybe$Nothing));
			case 'StepCountPace':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
					$author$project$Activity$Evidence$StepCountPace(0));
			default:
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$fail('Invalid Evidence');
		}
	},
	$zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var $author$project$Activity$Activity$IndefinitelyExcused = {$: 'IndefinitelyExcused'};
var $author$project$Activity$Activity$NeverExcused = {$: 'NeverExcused'};
var $author$project$Activity$Activity$TemporarilyExcused = function (a) {
	return {$: 'TemporarilyExcused', a: a};
};
var $author$project$Porting$decodeCustom = function (tagsWithDecoders) {
	var tryValues = function (_v0) {
		var tag = _v0.a;
		var decoder = _v0.b;
		return A3($zwilias$json_decode_exploration$Json$Decode$Exploration$check, $zwilias$json_decode_exploration$Json$Decode$Exploration$string, tag, decoder);
	};
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
		A2($elm$core$List$map, tryValues, tagsWithDecoders));
};
var $author$project$Activity$Activity$decodeExcusable = $author$project$Porting$decodeCustom(
	_List_fromArray(
		[
			_Utils_Tuple2(
			'NeverExcused',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$NeverExcused)),
			_Utils_Tuple2(
			'TemporarilyExcused',
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$Activity$Activity$TemporarilyExcused, $author$project$Activity$Activity$decodeDurationPerPeriod)),
			_Utils_Tuple2(
			'IndefinitelyExcused',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$IndefinitelyExcused))
		]));
var $author$project$Activity$Activity$Emoji = function (a) {
	return {$: 'Emoji', a: a};
};
var $author$project$Activity$Activity$Ion = {$: 'Ion'};
var $author$project$Activity$Activity$Other = {$: 'Other'};
var $author$project$Activity$Activity$File = function (a) {
	return {$: 'File', a: a};
};
var $author$project$Activity$Activity$decodeFile = A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$Activity$Activity$File, $zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var $author$project$Activity$Activity$decodeIcon = $author$project$Porting$decodeCustom(
	_List_fromArray(
		[
			_Utils_Tuple2('File', $author$project$Activity$Activity$decodeFile),
			_Utils_Tuple2(
			'Ion',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$Ion)),
			_Utils_Tuple2(
			'Other',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Activity$Activity$Other)),
			_Utils_Tuple2(
			'Emoji',
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$Activity$Activity$Emoji, $zwilias$json_decode_exploration$Json$Decode$Exploration$string))
		]));
var $author$project$Activity$Template$Apparel = {$: 'Apparel'};
var $author$project$Activity$Template$Bedward = {$: 'Bedward'};
var $author$project$Activity$Template$BrainTrain = {$: 'BrainTrain'};
var $author$project$Activity$Template$Broadcast = {$: 'Broadcast'};
var $author$project$Activity$Template$Browse = {$: 'Browse'};
var $author$project$Activity$Template$Call = {$: 'Call'};
var $author$project$Activity$Template$Children = {$: 'Children'};
var $author$project$Activity$Template$Chores = {$: 'Chores'};
var $author$project$Activity$Template$Cinema = {$: 'Cinema'};
var $author$project$Activity$Template$Configure = {$: 'Configure'};
var $author$project$Activity$Template$Course = {$: 'Course'};
var $author$project$Activity$Template$Create = {$: 'Create'};
var $author$project$Activity$Template$DillyDally = {$: 'DillyDally'};
var $author$project$Activity$Template$Driving = {$: 'Driving'};
var $author$project$Activity$Template$Email = {$: 'Email'};
var $author$project$Activity$Template$Fiction = {$: 'Fiction'};
var $author$project$Activity$Template$FilmWatching = {$: 'FilmWatching'};
var $author$project$Activity$Template$Finance = {$: 'Finance'};
var $author$project$Activity$Template$Flight = {$: 'Flight'};
var $author$project$Activity$Template$Floss = {$: 'Floss'};
var $author$project$Activity$Template$Grooming = {$: 'Grooming'};
var $author$project$Activity$Template$Homework = {$: 'Homework'};
var $author$project$Activity$Template$Housekeeping = {$: 'Housekeeping'};
var $author$project$Activity$Template$Laundry = {$: 'Laundry'};
var $author$project$Activity$Template$Learning = {$: 'Learning'};
var $author$project$Activity$Template$Lover = {$: 'Lover'};
var $author$project$Activity$Template$Meal = {$: 'Meal'};
var $author$project$Activity$Template$MealPrep = {$: 'MealPrep'};
var $author$project$Activity$Template$Meditate = {$: 'Meditate'};
var $author$project$Activity$Template$Meeting = {$: 'Meeting'};
var $author$project$Activity$Template$Messaging = {$: 'Messaging'};
var $author$project$Activity$Template$Music = {$: 'Music'};
var $author$project$Activity$Template$Networking = {$: 'Networking'};
var $author$project$Activity$Template$Pacing = {$: 'Pacing'};
var $author$project$Activity$Template$Parents = {$: 'Parents'};
var $author$project$Activity$Template$Pet = {$: 'Pet'};
var $author$project$Activity$Template$Plan = {$: 'Plan'};
var $author$project$Activity$Template$Prepare = {$: 'Prepare'};
var $author$project$Activity$Template$Presentation = {$: 'Presentation'};
var $author$project$Activity$Template$Projects = {$: 'Projects'};
var $author$project$Activity$Template$Restroom = {$: 'Restroom'};
var $author$project$Activity$Template$Riding = {$: 'Riding'};
var $author$project$Activity$Template$Series = {$: 'Series'};
var $author$project$Activity$Template$Shopping = {$: 'Shopping'};
var $author$project$Activity$Template$Shower = {$: 'Shower'};
var $author$project$Activity$Template$Sleep = {$: 'Sleep'};
var $author$project$Activity$Template$SocialMedia = {$: 'SocialMedia'};
var $author$project$Activity$Template$Sport = {$: 'Sport'};
var $author$project$Activity$Template$Supplements = {$: 'Supplements'};
var $author$project$Activity$Template$Theatre = {$: 'Theatre'};
var $author$project$Activity$Template$Toothbrush = {$: 'Toothbrush'};
var $author$project$Activity$Template$VideoGaming = {$: 'VideoGaming'};
var $author$project$Activity$Template$Wakeup = {$: 'Wakeup'};
var $author$project$Activity$Template$Work = {$: 'Work'};
var $author$project$Activity$Template$Workout = {$: 'Workout'};
var $author$project$Porting$decodeCustomFlat = function (tags) {
	var justTag = $elm$core$Tuple$mapSecond($zwilias$json_decode_exploration$Json$Decode$Exploration$succeed);
	return $author$project$Porting$decodeCustom(
		A2($elm$core$List$map, justTag, tags));
};
var $author$project$Activity$Template$decodeTemplate = $author$project$Porting$decodeCustomFlat(
	_List_fromArray(
		[
			_Utils_Tuple2('DillyDally', $author$project$Activity$Template$DillyDally),
			_Utils_Tuple2('Apparel', $author$project$Activity$Template$Apparel),
			_Utils_Tuple2('Messaging', $author$project$Activity$Template$Messaging),
			_Utils_Tuple2('Restroom', $author$project$Activity$Template$Restroom),
			_Utils_Tuple2('Grooming', $author$project$Activity$Template$Grooming),
			_Utils_Tuple2('Meal', $author$project$Activity$Template$Meal),
			_Utils_Tuple2('Supplements', $author$project$Activity$Template$Supplements),
			_Utils_Tuple2('Workout', $author$project$Activity$Template$Workout),
			_Utils_Tuple2('Shower', $author$project$Activity$Template$Shower),
			_Utils_Tuple2('Toothbrush', $author$project$Activity$Template$Toothbrush),
			_Utils_Tuple2('Floss', $author$project$Activity$Template$Floss),
			_Utils_Tuple2('Wakeup', $author$project$Activity$Template$Wakeup),
			_Utils_Tuple2('Sleep', $author$project$Activity$Template$Sleep),
			_Utils_Tuple2('Plan', $author$project$Activity$Template$Plan),
			_Utils_Tuple2('Configure', $author$project$Activity$Template$Configure),
			_Utils_Tuple2('Email', $author$project$Activity$Template$Email),
			_Utils_Tuple2('Work', $author$project$Activity$Template$Work),
			_Utils_Tuple2('Call', $author$project$Activity$Template$Call),
			_Utils_Tuple2('Chores', $author$project$Activity$Template$Chores),
			_Utils_Tuple2('Parents', $author$project$Activity$Template$Parents),
			_Utils_Tuple2('Prepare', $author$project$Activity$Template$Prepare),
			_Utils_Tuple2('Lover', $author$project$Activity$Template$Lover),
			_Utils_Tuple2('Driving', $author$project$Activity$Template$Driving),
			_Utils_Tuple2('Riding', $author$project$Activity$Template$Riding),
			_Utils_Tuple2('SocialMedia', $author$project$Activity$Template$SocialMedia),
			_Utils_Tuple2('Pacing', $author$project$Activity$Template$Pacing),
			_Utils_Tuple2('Sport', $author$project$Activity$Template$Sport),
			_Utils_Tuple2('Finance', $author$project$Activity$Template$Finance),
			_Utils_Tuple2('Laundry', $author$project$Activity$Template$Laundry),
			_Utils_Tuple2('Bedward', $author$project$Activity$Template$Bedward),
			_Utils_Tuple2('Browse', $author$project$Activity$Template$Browse),
			_Utils_Tuple2('Fiction', $author$project$Activity$Template$Fiction),
			_Utils_Tuple2('Learning', $author$project$Activity$Template$Learning),
			_Utils_Tuple2('BrainTrain', $author$project$Activity$Template$BrainTrain),
			_Utils_Tuple2('Music', $author$project$Activity$Template$Music),
			_Utils_Tuple2('Create', $author$project$Activity$Template$Create),
			_Utils_Tuple2('Children', $author$project$Activity$Template$Children),
			_Utils_Tuple2('Meeting', $author$project$Activity$Template$Meeting),
			_Utils_Tuple2('Cinema', $author$project$Activity$Template$Cinema),
			_Utils_Tuple2('FilmWatching', $author$project$Activity$Template$FilmWatching),
			_Utils_Tuple2('Series', $author$project$Activity$Template$Series),
			_Utils_Tuple2('Broadcast', $author$project$Activity$Template$Broadcast),
			_Utils_Tuple2('Theatre', $author$project$Activity$Template$Theatre),
			_Utils_Tuple2('Shopping', $author$project$Activity$Template$Shopping),
			_Utils_Tuple2('VideoGaming', $author$project$Activity$Template$VideoGaming),
			_Utils_Tuple2('Housekeeping', $author$project$Activity$Template$Housekeeping),
			_Utils_Tuple2('MealPrep', $author$project$Activity$Template$MealPrep),
			_Utils_Tuple2('Networking', $author$project$Activity$Template$Networking),
			_Utils_Tuple2('Meditate', $author$project$Activity$Template$Meditate),
			_Utils_Tuple2('Homework', $author$project$Activity$Template$Homework),
			_Utils_Tuple2('Flight', $author$project$Activity$Template$Flight),
			_Utils_Tuple2('Course', $author$project$Activity$Template$Course),
			_Utils_Tuple2('Pet', $author$project$Activity$Template$Pet),
			_Utils_Tuple2('Presentation', $author$project$Activity$Template$Presentation),
			_Utils_Tuple2('Projects', $author$project$Activity$Template$Projects)
		]));
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$keyValuePairs = function (_v0) {
	var decoderFn = _v0.a;
	var finalize = function (_v5) {
		var json = _v5.a;
		var warnings = _v5.b;
		var val = _v5.c;
		return {
			json: A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, json),
			value: val,
			warnings: warnings
		};
	};
	var accumulate = F2(
		function (_v4, acc) {
			var key = _v4.a;
			var val = _v4.b;
			var _v2 = _Utils_Tuple2(
				acc,
				decoderFn(val));
			if (_v2.a.$ === 'Err') {
				if (_v2.b.$ === 'Err') {
					var e = _v2.a.a;
					var _new = _v2.b.a;
					return $elm$core$Result$Err(
						A2(
							$mgold$elm_nonempty_list$List$Nonempty$cons,
							A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField, key, _new),
							e));
				} else {
					var e = _v2.a.a;
					return $elm$core$Result$Err(e);
				}
			} else {
				if (_v2.b.$ === 'Err') {
					var e = _v2.b.a;
					return $elm$core$Result$Err(
						$mgold$elm_nonempty_list$List$Nonempty$fromElement(
							A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField, key, e)));
				} else {
					var _v3 = _v2.a.a;
					var jsonAcc = _v3.a;
					var warningsAcc = _v3.b;
					var accAcc = _v3.c;
					var res = _v2.b.a;
					return $elm$core$Result$Ok(
						_Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								_Utils_Tuple2(key, res.json),
								jsonAcc),
							_Utils_ap(
								A2(
									$elm$core$List$map,
									A2(
										$elm$core$Basics$composeR,
										$mgold$elm_nonempty_list$List$Nonempty$fromElement,
										$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField(key)),
									res.warnings),
								warningsAcc),
							A2(
								$elm$core$List$cons,
								_Utils_Tuple2(key, res.value),
								accAcc)));
				}
			}
		});
	return $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			if (json.$ === 'Object') {
				var kvPairs = json.b;
				return A2(
					$elm$core$Result$map,
					finalize,
					A3(
						$elm$core$List$foldr,
						accumulate,
						$elm$core$Result$Ok(
							_Utils_Tuple3(_List_Nil, _List_Nil, _List_Nil)),
						kvPairs));
			} else {
				return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$expected, $zwilias$json_decode_exploration$Json$Decode$Exploration$TObject, json);
			}
		});
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$dict = function (decoder) {
	return A2(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$map,
		$elm$core$Dict$fromList,
		$zwilias$json_decode_exploration$Json$Decode$Exploration$keyValuePairs(decoder));
};
var $author$project$Porting$withPresence = F2(
	function (fieldName, decoder) {
		return A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			fieldName,
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $elm$core$Maybe$Just, decoder),
			$elm$core$Maybe$Nothing);
	});
var $author$project$Porting$withPresenceList = F2(
	function (fieldName, decoder) {
		return A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			fieldName,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$list(decoder),
			_List_Nil);
	});
var $author$project$Activity$Activity$decodeCustomizations = A4(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
	'externalIDs',
	$zwilias$json_decode_exploration$Json$Decode$Exploration$dict($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
	$elm$core$Dict$empty,
	A3(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'id',
		$author$project$ID$decode,
		A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'template',
			$author$project$Activity$Template$decodeTemplate,
			A3(
				$author$project$Porting$withPresence,
				'hidden',
				$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
				A3(
					$author$project$Porting$withPresence,
					'maxTime',
					$author$project$Activity$Activity$decodeDurationPerPeriod,
					A3(
						$author$project$Porting$withPresence,
						'backgroundable',
						$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
						A3(
							$author$project$Porting$withPresence,
							'category',
							$author$project$Activity$Activity$decodeCategory,
							A3(
								$author$project$Porting$withPresenceList,
								'evidence',
								$author$project$Activity$Evidence$decodeEvidence,
								A3(
									$author$project$Porting$withPresence,
									'taskOptional',
									$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
									A3(
										$author$project$Porting$withPresence,
										'excusable',
										$author$project$Activity$Activity$decodeExcusable,
										A3(
											$author$project$Porting$withPresence,
											'icon',
											$author$project$Activity$Activity$decodeIcon,
											A3(
												$author$project$Porting$withPresence,
												'names',
												$zwilias$json_decode_exploration$Json$Decode$Exploration$list($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
												$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Activity$Activity$Customizations)))))))))))));
var $author$project$Activity$Activity$decodeStoredActivities = A2(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$map,
	$elm_community$intdict$IntDict$fromList,
	$zwilias$json_decode_exploration$Json$Decode$Exploration$list(
		A2($author$project$Porting$decodeTuple2, $zwilias$json_decode_exploration$Json$Decode$Exploration$int, $author$project$Activity$Activity$decodeCustomizations)));
var $author$project$Activity$Activity$Switch = F2(
	function (a, b) {
		return {$: 'Switch', a: a, b: b};
	});
var $author$project$SmartTime$Moment$fromSmartInt = function (_int) {
	return $author$project$SmartTime$Moment$Moment(
		$author$project$SmartTime$Duration$fromInt(_int));
};
var $author$project$Porting$decodeMoment = A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$SmartTime$Moment$fromSmartInt, $zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var $author$project$Porting$subtype2 = F5(
	function (tagger, fieldName1, subType1Decoder, fieldName2, subType2Decoder) {
		return A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$map2,
			tagger,
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName1, subType1Decoder),
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName2, subType2Decoder));
	});
var $author$project$Activity$Activity$decodeSwitch = A5($author$project$Porting$subtype2, $author$project$Activity$Activity$Switch, 'Time', $author$project$Porting$decodeMoment, 'Activity', $author$project$ID$decode);
var $author$project$TimeBlock$TimeBlock$TimeBlock = F2(
	function (focus, range) {
		return {focus: focus, range: range};
	});
var $author$project$SmartTime$Period$Period = F2(
	function (a, b) {
		return {$: 'Period', a: a, b: b};
	});
var $author$project$SmartTime$Period$fromPair = function (_v0) {
	var moment1 = _v0.a;
	var moment2 = _v0.b;
	return _Utils_eq(
		A2($author$project$SmartTime$Moment$compare, moment1, moment2),
		$author$project$SmartTime$Moment$Later) ? A2($author$project$SmartTime$Period$Period, moment2, moment1) : A2($author$project$SmartTime$Period$Period, moment1, moment2);
};
var $author$project$TimeBlock$TimeBlock$periodDecoder = function () {
	var momentDecoder = A2($author$project$Porting$customDecoder, $zwilias$json_decode_exploration$Json$Decode$Exploration$string, $author$project$SmartTime$Human$Moment$fromStandardString);
	return A2(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$map,
		$author$project$SmartTime$Period$fromPair,
		A2($author$project$Porting$arrayAsTuple2, momentDecoder, momentDecoder));
}();
var $author$project$TimeBlock$TimeBlock$decodeTimeBlock = A3(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'range',
	$author$project$TimeBlock$TimeBlock$periodDecoder,
	A3(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'focus',
		$author$project$ID$decode,
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$TimeBlock$TimeBlock$TimeBlock)));
var $author$project$Profile$TodoistIntegrationData = F3(
	function (cache, parentProjectID, activityProjectIDs) {
		return {activityProjectIDs: activityProjectIDs, cache: cache, parentProjectID: parentProjectID};
	});
var $author$project$Incubator$Todoist$Cache = F4(
	function (nextSync, items, projects, pendingCommands) {
		return {items: items, nextSync: nextSync, pendingCommands: pendingCommands, projects: projects};
	});
var $author$project$Incubator$Todoist$decodeIncrementalSyncToken = A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $author$project$Incubator$Todoist$IncrementalSyncToken, $zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var $author$project$Incubator$Todoist$Item$Item = function (id) {
	return function (user_id) {
		return function (project_id) {
			return function (content) {
				return function (due) {
					return function (priority) {
						return function (parent_id) {
							return function (child_order) {
								return function (day_order) {
									return function (collapsed) {
										return function (children) {
											return function (assigned_by_uid) {
												return function (responsible_uid) {
													return function (checked) {
														return function (in_history) {
															return function (is_deleted) {
																return function (is_archived) {
																	return function (date_added) {
																		return {assigned_by_uid: assigned_by_uid, checked: checked, child_order: child_order, children: children, collapsed: collapsed, content: content, date_added: date_added, day_order: day_order, due: due, id: id, in_history: in_history, is_archived: is_archived, is_deleted: is_deleted, parent_id: parent_id, priority: priority, project_id: project_id, responsible_uid: responsible_uid, user_id: user_id};
																	};
																};
															};
														};
													};
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Porting$decodeBoolFromInt = $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			1,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(true)),
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			0,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(false))
		]));
var $author$project$Incubator$Todoist$Item$Due = F5(
	function (date, timezone, string, lang, isRecurring) {
		return {date: date, isRecurring: isRecurring, lang: lang, string: string, timezone: timezone};
	});
var $author$project$Incubator$Todoist$Item$decodeDue = A3(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'is_recurring',
	$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
	A3(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'lang',
		$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
		A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'string',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			A3(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'timezone',
				$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
				A3(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'date',
					$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Incubator$Todoist$Item$Due))))));
var $author$project$Incubator$Todoist$Item$Priority = function (a) {
	return {$: 'Priority', a: a};
};
var $author$project$Incubator$Todoist$Item$decodePriority = $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			4,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				$author$project$Incubator$Todoist$Item$Priority(1))),
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			3,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				$author$project$Incubator$Todoist$Item$Priority(2))),
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			2,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				$author$project$Incubator$Todoist$Item$Priority(3))),
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			1,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				$author$project$Incubator$Todoist$Item$Priority(4)))
		]));
var $zwilias$json_decode_exploration$Json$Decode$Exploration$value = $zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
			$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json));
	});
var $author$project$Porting$optionalIgnored = F2(
	function (field, pipeline) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (_v0) {
				return pipeline;
			},
			$zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
				_List_fromArray(
					[
						A2($zwilias$json_decode_exploration$Json$Decode$Exploration$field, field, $zwilias$json_decode_exploration$Json$Decode$Exploration$value),
						$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($elm$json$Json$Encode$null)
					])));
	});
var $author$project$Incubator$Todoist$Item$decodeItem = A2(
	$author$project$Porting$optionalIgnored,
	'added_by_uid',
	A2(
		$author$project$Porting$optionalIgnored,
		'due_is_recurring',
		A2(
			$author$project$Porting$optionalIgnored,
			'section_id',
			A2(
				$author$project$Porting$optionalIgnored,
				'has_more_notes',
				A2(
					$author$project$Porting$optionalIgnored,
					'date_completed',
					A2(
						$author$project$Porting$optionalIgnored,
						'sync_id',
						A2(
							$author$project$Porting$optionalIgnored,
							'legacy_parent_id',
							A2(
								$author$project$Porting$optionalIgnored,
								'legacy_project_id',
								A2(
									$author$project$Porting$optionalIgnored,
									'legacy_id',
									A2(
										$author$project$Porting$optionalIgnored,
										'indent',
										A3(
											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
											'date_added',
											$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
											A4(
												$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
												'is_archived',
												$author$project$Porting$decodeBoolFromInt,
												false,
												A3(
													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'is_deleted',
													$author$project$Porting$decodeBoolFromInt,
													A3(
														$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
														'in_history',
														$author$project$Porting$decodeBoolFromInt,
														A3(
															$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
															'checked',
															$author$project$Porting$decodeBoolFromInt,
															A3(
																$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																'responsible_uid',
																$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$int),
																A4(
																	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																	'assigned_by_uid',
																	$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																	0,
																	A2(
																		$author$project$Porting$optionalIgnored,
																		'labels',
																		A4(
																			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																			'children',
																			$zwilias$json_decode_exploration$Json$Decode$Exploration$list($zwilias$json_decode_exploration$Json$Decode$Exploration$int),
																			_List_Nil,
																			A3(
																				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																				'collapsed',
																				$author$project$Porting$decodeBoolFromInt,
																				A3(
																					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																					'day_order',
																					$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																					A3(
																						$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																						'child_order',
																						$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																						A3(
																							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																							'parent_id',
																							$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$int),
																							A3(
																								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																								'priority',
																								$author$project$Incubator$Todoist$Item$decodePriority,
																								A3(
																									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																									'due',
																									$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Incubator$Todoist$Item$decodeDue),
																									A3(
																										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																										'content',
																										$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																										A3(
																											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																											'project_id',
																											$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																											A3(
																												$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																												'user_id',
																												$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																												A3(
																													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																													'id',
																													$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Incubator$Todoist$Item$Item))))))))))))))))))))))))))))));
var $author$project$Incubator$Todoist$Project$Project = function (id) {
	return function (name) {
		return function (color) {
			return function (parent_id) {
				return function (child_order) {
					return function (collapsed) {
						return function (shared) {
							return function (is_deleted) {
								return function (is_archived) {
									return function (is_favorite) {
										return function (inbox_project) {
											return function (team_inbox) {
												return {child_order: child_order, collapsed: collapsed, color: color, id: id, inbox_project: inbox_project, is_archived: is_archived, is_deleted: is_deleted, is_favorite: is_favorite, name: name, parent_id: parent_id, shared: shared, team_inbox: team_inbox};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Incubator$Todoist$Project$decodeProject = A2(
	$author$project$Porting$optionalIgnored,
	'sync_id',
	A2(
		$author$project$Porting$optionalIgnored,
		'has_more_notes',
		A2(
			$author$project$Porting$optionalIgnored,
			'legacy_id',
			A2(
				$author$project$Porting$optionalIgnored,
				'legacy_parent_id',
				A4(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
					'team_inbox',
					$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
					false,
					A4(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
						'inbox_project',
						$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
						false,
						A3(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
							'is_favorite',
							$author$project$Porting$decodeBoolFromInt,
							A3(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
								'is_archived',
								$author$project$Porting$decodeBoolFromInt,
								A3(
									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
									'is_deleted',
									$author$project$Porting$decodeBoolFromInt,
									A3(
										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'shared',
										$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
										A3(
											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
											'collapsed',
											$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
											A3(
												$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'child_order',
												$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
												A3(
													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'parent_id',
													$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$int),
													A3(
														$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
														'color',
														$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
														A3(
															$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
															'name',
															$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
															A3(
																$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																'id',
																$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Incubator$Todoist$Project$Project)))))))))))))))));
var $author$project$Incubator$Todoist$decodeCache = A3(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'pendingCommands',
	$zwilias$json_decode_exploration$Json$Decode$Exploration$list($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
	A3(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'projects',
		$author$project$Porting$decodeIntDict($author$project$Incubator$Todoist$Project$decodeProject),
		A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'items',
			$author$project$Porting$decodeIntDict($author$project$Incubator$Todoist$Item$decodeItem),
			A4(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
				'nextSync',
				$author$project$Incubator$Todoist$decodeIncrementalSyncToken,
				$author$project$Incubator$Todoist$emptyCache.nextSync,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Incubator$Todoist$Cache)))));
var $author$project$Profile$decodeTodoistIntegrationData = A3(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'activityProjectIDs',
	$author$project$Porting$decodeIntDict($author$project$ID$decode),
	A3(
		$author$project$Porting$withPresence,
		'parentProjectID',
		$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
		A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'cache',
			$author$project$Incubator$Todoist$decodeCache,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Profile$TodoistIntegrationData))));
var $author$project$Profile$decodeProfile = A4(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
	'timeBlocks',
	$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$TimeBlock$TimeBlock$decodeTimeBlock),
	_List_Nil,
	A4(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
		'todoist',
		$author$project$Profile$decodeTodoistIntegrationData,
		$author$project$Profile$emptyTodoistIntegrationData,
		A4(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			'timeline',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Activity$Activity$decodeSwitch),
			_List_Nil,
			A4(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
				'activities',
				$author$project$Activity$Activity$decodeStoredActivities,
				$elm_community$intdict$IntDict$empty,
				A4(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
					'taskInstances',
					$author$project$Porting$decodeIntDict($author$project$Task$Instance$decodeInstance),
					$elm_community$intdict$IntDict$empty,
					A4(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
						'taskClasses',
						$author$project$Porting$decodeIntDict($author$project$Task$Class$decodeClass),
						$elm_community$intdict$IntDict$empty,
						A4(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
							'taskEntries',
							$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Task$Entry$decodeEntry),
							_List_Nil,
							A4(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
								'errors',
								$zwilias$json_decode_exploration$Json$Decode$Exploration$list($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
								_List_Nil,
								A3(
									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
									'uid',
									$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Profile$Profile))))))))));
var $zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson = {$: 'BadJson'};
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Errors = function (a) {
	return {$: 'Errors', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Success = function (a) {
	return {$: 'Success', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$WithWarnings = F2(
	function (a, b) {
		return {$: 'WithWarnings', a: a, b: b};
	});
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
var $elm$json$Json$Decode$lazy = function (thunk) {
	return A2(
		$elm$json$Json$Decode$andThen,
		thunk,
		$elm$json$Json$Decode$succeed(_Utils_Tuple0));
};
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$string = _Json_decodeString;
function $zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder() {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$json$Json$Decode$map,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$String(false),
				$elm$json$Json$Decode$string),
				A2(
				$elm$json$Json$Decode$map,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Number(false),
				$elm$json$Json$Decode$float),
				A2(
				$elm$json$Json$Decode$map,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Bool(false),
				$elm$json$Json$Decode$bool),
				$elm$json$Json$Decode$null(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Null(false)),
				A2(
				$elm$json$Json$Decode$map,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Array(false),
				$elm$json$Json$Decode$list(
					$elm$json$Json$Decode$lazy(
						function (_v0) {
							return $zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder();
						}))),
				A2(
				$elm$json$Json$Decode$map,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Object(false),
				$elm$json$Json$Decode$keyValuePairs(
					$elm$json$Json$Decode$lazy(
						function (_v1) {
							return $zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder();
						})))
			]));
}
try {
	var $zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder = $zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder();
	$zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder = function () {
		return $zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder;
	};
} catch ($) {
	throw 'Some top-level definitions from `Json.Decode.Exploration` are causing infinite recursion:\n\n  ┌─────┐\n  │    annotatedDecoder\n  └─────┘\n\nThese errors are very tricky, so read https://elm-lang.org/0.19.1/bad-recursion to learn how to fix it!';}
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $zwilias$json_decode_exploration$Json$Decode$Exploration$decode = $elm$json$Json$Decode$decodeValue($zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder);
var $zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue = function (a) {
	return {$: 'UnusedValue', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings = function (json) {
	_v0$8:
	while (true) {
		switch (json.$) {
			case 'String':
				if (!json.a) {
					return _List_fromArray(
						[
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _v0$8;
				}
			case 'Number':
				if (!json.a) {
					return _List_fromArray(
						[
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _v0$8;
				}
			case 'Bool':
				if (!json.a) {
					return _List_fromArray(
						[
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _v0$8;
				}
			case 'Null':
				if (!json.a) {
					return _List_fromArray(
						[
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _v0$8;
				}
			case 'Array':
				if (!json.a) {
					return _List_fromArray(
						[
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					var values = json.b;
					return $elm$core$List$concat(
						A2(
							$elm$core$List$indexedMap,
							F2(
								function (idx, val) {
									var _v1 = $zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(val);
									if (!_v1.b) {
										return _List_Nil;
									} else {
										var x = _v1.a;
										var xs = _v1.b;
										return _List_fromArray(
											[
												A2(
												$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex,
												idx,
												A2($mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs))
											]);
									}
								}),
							values));
				}
			default:
				if (!json.a) {
					return _List_fromArray(
						[
							$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								$zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					var kvPairs = json.b;
					return A2(
						$elm$core$List$concatMap,
						function (_v2) {
							var key = _v2.a;
							var val = _v2.b;
							var _v3 = $zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(val);
							if (!_v3.b) {
								return _List_Nil;
							} else {
								var x = _v3.a;
								var xs = _v3.b;
								return _List_fromArray(
									[
										A2(
										$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField,
										key,
										A2($mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs))
									]);
							}
						},
						kvPairs);
				}
		}
	}
	return _List_Nil;
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue = F2(
	function (_v0, val) {
		var decoderFn = _v0.a;
		var _v1 = $zwilias$json_decode_exploration$Json$Decode$Exploration$decode(val);
		if (_v1.$ === 'Err') {
			return $zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson;
		} else {
			var json = _v1.a;
			var _v2 = decoderFn(json);
			if (_v2.$ === 'Err') {
				var errors = _v2.a;
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$Errors(errors);
			} else {
				var acc = _v2.a;
				var _v3 = _Utils_ap(
					acc.warnings,
					$zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(acc.json));
				if (!_v3.b) {
					return $zwilias$json_decode_exploration$Json$Decode$Exploration$Success(acc.value);
				} else {
					var x = _v3.a;
					var xs = _v3.b;
					return A2(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$WithWarnings,
						A2($mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs),
						acc.value);
				}
			}
		}
	});
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $zwilias$json_decode_exploration$Json$Decode$Exploration$decodeString = F2(
	function (decoder, jsonString) {
		var _v0 = A2($elm$json$Json$Decode$decodeString, $elm$json$Json$Decode$value, jsonString);
		if (_v0.$ === 'Err') {
			return $zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson;
		} else {
			var json = _v0.a;
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue, decoder, json);
		}
	});
var $author$project$Main$profileFromJson = function (incomingJson) {
	return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$decodeString, $author$project$Profile$decodeProfile, incomingJson);
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$expectedTypeToString = function (expectedType) {
	switch (expectedType.$) {
		case 'TString':
			return 'a string';
		case 'TInt':
			return 'an integer number';
		case 'TNumber':
			return 'a number';
		case 'TNull':
			return 'null';
		case 'TBool':
			return 'a boolean';
		case 'TArray':
			return 'an array';
		case 'TObject':
			return 'an object';
		case 'TArrayIndex':
			var idx = expectedType.a;
			return 'an array with index ' + $elm$core$String$fromInt(idx);
		default:
			var aField = expectedType.a;
			return 'an object with a field \'' + (aField + '\'');
	}
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$indent = $elm$core$List$map(
	$elm$core$Basics$append('  '));
var $zwilias$json_decode_exploration$Json$Decode$Exploration$intercalateMap = F3(
	function (sep, toList, xs) {
		return $elm$core$List$concat(
			A2(
				$elm$core$List$intersperse,
				_List_fromArray(
					[sep]),
				A2($elm$core$List$map, toList, xs)));
	});
var $elm$core$String$lines = _String_lines;
var $zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines = A2(
	$elm$core$Basics$composeR,
	$elm$json$Json$Encode$encode(2),
	$elm$core$String$lines);
var $elm$core$Tuple$mapFirst = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$flatten = function (located) {
	switch (located.$) {
		case 'Here':
			var v = located.a;
			return _List_fromArray(
				[
					_Utils_Tuple2(
					'',
					_List_fromArray(
						[v]))
				]);
		case 'InField':
			var s = located.a;
			var vals = located.b;
			return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather, '/' + s, vals);
		default:
			var i = located.a;
			var vals = located.b;
			return A2(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather,
				'/' + $elm$core$String$fromInt(i),
				vals);
	}
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather = F2(
	function (prefix, _v0) {
		var first = _v0.a;
		var rest = _v0.b;
		return A2(
			$elm$core$List$map,
			$elm$core$Tuple$mapFirst(
				$elm$core$Basics$append(prefix)),
			A2(
				$elm$core$List$concatMap,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$flatten,
				A2($elm$core$List$cons, first, rest)));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$intercalate = F2(
	function (sep, lists) {
		return $elm$core$List$concat(
			A2(
				$elm$core$List$intersperse,
				_List_fromArray(
					[sep]),
				lists));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$indent = $elm$core$Basics$append('  ');
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$render = F3(
	function (itemToString, path, errors) {
		var formattedErrors = A2(
			$elm$core$List$map,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$indent,
			A2($elm$core$List$concatMap, itemToString, errors));
		return $elm$core$String$isEmpty(path) ? formattedErrors : A2(
			$elm$core$List$cons,
			'At path ' + path,
			A2($elm$core$List$cons, '', formattedErrors));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$toString = F2(
	function (itemToString, locatedItems) {
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$intercalate,
			'',
			A2(
				$elm$core$List$map,
				function (_v0) {
					var x = _v0.a;
					var vals = _v0.b;
					return A3($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$render, itemToString, x, vals);
				},
				A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather, '', locatedItems)));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$errorToString = function (error) {
	switch (error.$) {
		case 'Failure':
			var failure = error.a;
			var json = error.b;
			if (json.$ === 'Just') {
				var val = json.a;
				return A2(
					$elm$core$List$cons,
					failure,
					A2(
						$elm$core$List$cons,
						'',
						$zwilias$json_decode_exploration$Json$Decode$Exploration$indent(
							$zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines(val))));
			} else {
				return _List_fromArray(
					[failure]);
			}
		case 'Expected':
			var expectedType = error.a;
			var actualValue = error.b;
			return A2(
				$elm$core$List$cons,
				'I expected ' + ($zwilias$json_decode_exploration$Json$Decode$Exploration$expectedTypeToString(expectedType) + ' here, but instead found this value:'),
				A2(
					$elm$core$List$cons,
					'',
					$zwilias$json_decode_exploration$Json$Decode$Exploration$indent(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines(actualValue))));
		default:
			var errors = error.a;
			if (!errors.b) {
				return _List_fromArray(
					['I encountered a `oneOf` without any options.']);
			} else {
				return A2(
					$elm$core$List$cons,
					'I encountered multiple issues:',
					A2(
						$elm$core$List$cons,
						'',
						A3($zwilias$json_decode_exploration$Json$Decode$Exploration$intercalateMap, '', $zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToStrings, errors)));
			}
	}
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToStrings = function (errors) {
	return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$toString, $zwilias$json_decode_exploration$Json$Decode$Exploration$errorToString, errors);
};
var $elm$core$String$trimRight = _String_trimRight;
var $zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString = function (errors) {
	return A2(
		$elm$core$String$join,
		'\n',
		A2(
			$elm$core$List$map,
			$elm$core$String$trimRight,
			A2(
				$elm$core$List$cons,
				'I encountered some errors while decoding this JSON:',
				A2(
					$elm$core$List$cons,
					'',
					$zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToStrings(errors)))));
};
var $author$project$Profile$saveError = F2(
	function (appData, error) {
		return _Utils_update(
			appData,
			{
				errors: A2($elm$core$List$cons, error, appData.errors)
			});
	});
var $author$project$Profile$saveDecodeErrors = F2(
	function (appData, errors) {
		return A2(
			$author$project$Profile$saveError,
			appData,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString(errors));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$warningToString = function (warning) {
	var _v0 = function () {
		if (warning.$ === 'Warning') {
			var message_ = warning.a;
			var val_ = warning.b;
			return _Utils_Tuple2(message_, val_);
		} else {
			var val_ = warning.a;
			return _Utils_Tuple2('Unused value:', val_);
		}
	}();
	var message = _v0.a;
	var val = _v0.b;
	return A2(
		$elm$core$List$cons,
		message,
		A2(
			$elm$core$List$cons,
			'',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$indent(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines(val))));
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToString = function (warnings) {
	return A2(
		$elm$core$String$join,
		'\n',
		A2(
			$elm$core$List$map,
			$elm$core$String$trimRight,
			A2(
				$elm$core$List$cons,
				'While I was able to decode this JSON successfully, I did produce one or more warnings:',
				A2(
					$elm$core$List$cons,
					'',
					A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Located$toString, $zwilias$json_decode_exploration$Json$Decode$Exploration$warningToString, warnings)))));
};
var $author$project$Profile$saveWarnings = F2(
	function (appData, warnings) {
		return _Utils_update(
			appData,
			{
				errors: _Utils_ap(
					_List_fromArray(
						[
							$zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToString(warnings)
						]),
					appData.errors)
			});
	});
var $author$project$Main$NoOp = {$: 'NoOp'};
var $author$project$Main$Tick = function (a) {
	return {$: 'Tick', a: a};
};
var $author$project$Main$Tock = F2(
	function (a, b) {
		return {$: 'Tock', a: a, b: b};
	});
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Main$ClearErrors = {$: 'ClearErrors'};
var $author$project$NativeScript$Notification$High = {$: 'High'};
var $author$project$Main$Marvin = {$: 'Marvin'};
var $author$project$Main$MarvinServer = function (a) {
	return {$: 'MarvinServer', a: a};
};
var $author$project$Main$Model = F3(
	function (viewState, profile, environment) {
		return {environment: environment, profile: profile, viewState: viewState};
	});
var $author$project$Main$TaskListMsg = function (a) {
	return {$: 'TaskListMsg', a: a};
};
var $author$project$Main$ThirdPartyServerResponded = function (a) {
	return {$: 'ThirdPartyServerResponded', a: a};
};
var $author$project$Main$ThirdPartySync = function (a) {
	return {$: 'ThirdPartySync', a: a};
};
var $author$project$Main$TimeTrackerMsg = function (a) {
	return {$: 'TimeTrackerMsg', a: a};
};
var $author$project$Main$Todoist = {$: 'Todoist'};
var $author$project$Main$TodoistServer = function (a) {
	return {$: 'TodoistServer', a: a};
};
var $author$project$NativeScript$Notification$basicChannel = function (name) {
	return {description: $elm$core$Maybe$Nothing, id: name, importance: $elm$core$Maybe$Nothing, led: $elm$core$Maybe$Nothing, name: name, sound: $elm$core$Maybe$Nothing, vibrate: $elm$core$Maybe$Nothing};
};
var $author$project$NativeScript$Notification$build = function (channel) {
	return {accentColor: $elm$core$Maybe$Nothing, actions: _List_Nil, at: $elm$core$Maybe$Nothing, autoCancel: $elm$core$Maybe$Nothing, background_color: $elm$core$Maybe$Nothing, badge: $elm$core$Maybe$Nothing, bigTextStyle: $elm$core$Maybe$Nothing, body: $elm$core$Maybe$Nothing, body_expanded: $elm$core$Maybe$Nothing, channel: channel, chronometer: $elm$core$Maybe$Nothing, color_from_media: $elm$core$Maybe$Nothing, countdown: $elm$core$Maybe$Nothing, detail: $elm$core$Maybe$Nothing, expiresAfter: $elm$core$Maybe$Nothing, group: $elm$core$Maybe$Nothing, groupAlertBehavior: $elm$core$Maybe$Nothing, groupedMessages: $elm$core$Maybe$Nothing, icon: $elm$core$Maybe$Nothing, id: $elm$core$Maybe$Nothing, image: $elm$core$Maybe$Nothing, interval: $elm$core$Maybe$Nothing, isGroupSummary: $elm$core$Maybe$Nothing, media: $elm$core$Maybe$Nothing, media_layout: $elm$core$Maybe$Nothing, on_create: $elm$core$Maybe$Nothing, on_dismiss: $elm$core$Maybe$Nothing, on_touch: $elm$core$Maybe$Nothing, ongoing: $elm$core$Maybe$Nothing, phone_only: $elm$core$Maybe$Nothing, picture_expanded_icon: $elm$core$Maybe$Nothing, picture_skip_cache: $elm$core$Maybe$Nothing, privacy: $elm$core$Maybe$Nothing, progress: $elm$core$Maybe$Nothing, silhouetteIcon: $elm$core$Maybe$Nothing, sortKey: $elm$core$Maybe$Nothing, status_icon: $elm$core$Maybe$Nothing, status_text_size: $elm$core$Maybe$Nothing, subtitle: $elm$core$Maybe$Nothing, thumbnail: $elm$core$Maybe$Nothing, ticker: $elm$core$Maybe$Nothing, title: $elm$core$Maybe$Nothing, title_expanded: $elm$core$Maybe$Nothing, update: $elm$core$Maybe$Nothing, url: $elm$core$Maybe$Nothing, useHTML: $elm$core$Maybe$Nothing, when: $elm$core$Maybe$Nothing};
};
var $author$project$TaskList$AllTasks = {$: 'AllTasks'};
var $author$project$TaskList$defaultView = A3(
	$author$project$TaskList$Normal,
	_List_fromArray(
		[$author$project$TaskList$AllTasks]),
	$elm$core$Maybe$Nothing,
	'');
var $author$project$TimeTracker$defaultView = $author$project$TimeTracker$Normal;
var $elm$url$Url$Parser$Internal$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var $elm$url$Url$Parser$Query$custom = F2(
	function (key, func) {
		return $elm$url$Url$Parser$Internal$Parser(
			function (dict) {
				return func(
					A2(
						$elm$core$Maybe$withDefault,
						_List_Nil,
						A2($elm$core$Dict$get, key, dict)));
			});
	});
var $elm$url$Url$Parser$Query$enum = F2(
	function (key, dict) {
		return A2(
			$elm$url$Url$Parser$Query$custom,
			key,
			function (stringList) {
				if (stringList.b && (!stringList.b.b)) {
					var str = stringList.a;
					return A2($elm$core$Dict$get, str, dict);
				} else {
					return $elm$core$Maybe$Nothing;
				}
			});
	});
var $author$project$Incubator$Todoist$Items = {$: 'Items'};
var $author$project$Incubator$Todoist$Projects = {$: 'Projects'};
var $author$project$Integrations$Todoist$devSecret = '0bdc5149510737ab941485bace8135c60e2d812b';
var $author$project$Incubator$Todoist$SyncResponded = function (a) {
	return {$: 'SyncResponded', a: a};
};
var $author$project$Incubator$Todoist$Response = F5(
	function (sync_token, sync_status, full_sync, items, projects) {
		return {full_sync: full_sync, items: items, projects: projects, sync_status: sync_status, sync_token: sync_token};
	});
var $author$project$Incubator$Todoist$Command$CommandError = F2(
	function (error_code, error) {
		return {error: error, error_code: error_code};
	});
var $author$project$Incubator$Todoist$Command$decodeCommandError = A2(
	$author$project$Porting$optionalIgnored,
	'error_extra',
	A2(
		$author$project$Porting$optionalIgnored,
		'http_code',
		A2(
			$author$project$Porting$optionalIgnored,
			'error_tag',
			A3(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'error',
				$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
				A3(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'error_code',
					$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Incubator$Todoist$Command$CommandError))))));
var $author$project$Incubator$Todoist$Command$decodeCommandResult = $zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			'ok',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				$elm$core$Result$Ok(_Utils_Tuple0))),
			A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $elm$core$Result$Err, $author$project$Incubator$Todoist$Command$decodeCommandError)
		]));
var $author$project$Incubator$Todoist$decodeResponse = A2(
	$author$project$Porting$optionalIgnored,
	'tooltips',
	A2(
		$author$project$Porting$optionalIgnored,
		'locations',
		A2(
			$author$project$Porting$optionalIgnored,
			'stats',
			A2(
				$author$project$Porting$optionalIgnored,
				'incomplete_item_ids',
				A2(
					$author$project$Porting$optionalIgnored,
					'incomplete_project_ids',
					A2(
						$author$project$Porting$optionalIgnored,
						'day_orders_timestamp',
						A2(
							$author$project$Porting$optionalIgnored,
							'due_exceptions',
							A2(
								$author$project$Porting$optionalIgnored,
								'sections',
								A2(
									$author$project$Porting$optionalIgnored,
									'user_settings',
									A2(
										$author$project$Porting$optionalIgnored,
										'user',
										A2(
											$author$project$Porting$optionalIgnored,
											'temp_id_mapping',
											A2(
												$author$project$Porting$optionalIgnored,
												'settings_notifications',
												A2(
													$author$project$Porting$optionalIgnored,
													'reminders',
													A2(
														$author$project$Porting$optionalIgnored,
														'project_notes',
														A2(
															$author$project$Porting$optionalIgnored,
															'notes',
															A2(
																$author$project$Porting$optionalIgnored,
																'live_notifications_last_read_id',
																A2(
																	$author$project$Porting$optionalIgnored,
																	'live_notifications',
																	A2(
																		$author$project$Porting$optionalIgnored,
																		'labels',
																		A2(
																			$author$project$Porting$optionalIgnored,
																			'filters',
																			A2(
																				$author$project$Porting$optionalIgnored,
																				'day_orders',
																				A2(
																					$author$project$Porting$optionalIgnored,
																					'collaborator_states',
																					A2(
																						$author$project$Porting$optionalIgnored,
																						'collaborators',
																						A4(
																							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																							'projects',
																							$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Incubator$Todoist$Project$decodeProject),
																							_List_Nil,
																							A4(
																								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																								'items',
																								$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Incubator$Todoist$Item$decodeItem),
																								_List_Nil,
																								A3(
																									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																									'full_sync',
																									$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																									A4(
																										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																										'sync_status',
																										$zwilias$json_decode_exploration$Json$Decode$Exploration$dict($author$project$Incubator$Todoist$Command$decodeCommandResult),
																										$elm$core$Dict$empty,
																										A4(
																											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																											'sync_token',
																											A2($zwilias$json_decode_exploration$Json$Decode$Exploration$map, $elm$core$Maybe$Just, $author$project$Incubator$Todoist$decodeIncrementalSyncToken),
																											$elm$core$Maybe$Nothing,
																											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode($author$project$Incubator$Todoist$Response))))))))))))))))))))))))))));
var $elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 'BadStatus_', a: a, b: b};
	});
var $elm$http$Http$BadUrl_ = function (a) {
	return {$: 'BadUrl_', a: a};
};
var $elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 'GoodStatus_', a: a, b: b};
	});
var $elm$http$Http$NetworkError_ = {$: 'NetworkError_'};
var $elm$http$Http$Receiving = function (a) {
	return {$: 'Receiving', a: a};
};
var $elm$http$Http$Sending = function (a) {
	return {$: 'Sending', a: a};
};
var $elm$http$Http$Timeout_ = {$: 'Timeout_'};
var $elm$core$Maybe$isJust = function (maybe) {
	if (maybe.$ === 'Just') {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$http$Http$emptyBody = _Http_emptyBody;
var $elm$http$Http$expectStringResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'',
			$elm$core$Basics$identity,
			A2($elm$core$Basics$composeR, toResult, toMsg));
	});
var $elm$http$Http$BadBody = function (a) {
	return {$: 'BadBody', a: a};
};
var $elm$http$Http$BadStatus = function (a) {
	return {$: 'BadStatus', a: a};
};
var $elm$http$Http$BadUrl = function (a) {
	return {$: 'BadUrl', a: a};
};
var $elm$http$Http$NetworkError = {$: 'NetworkError'};
var $elm$http$Http$Timeout = {$: 'Timeout'};
var $elm$http$Http$resolve = F2(
	function (toResult, response) {
		switch (response.$) {
			case 'BadUrl_':
				var url = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadUrl(url));
			case 'Timeout_':
				return $elm$core$Result$Err($elm$http$Http$Timeout);
			case 'NetworkError_':
				return $elm$core$Result$Err($elm$http$Http$NetworkError);
			case 'BadStatus_':
				var metadata = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadStatus(metadata.statusCode));
			default:
				var body = response.b;
				return A2(
					$elm$core$Result$mapError,
					$elm$http$Http$BadBody,
					toResult(body));
		}
	});
var $elm$http$Http$expectJson = F2(
	function (toMsg, decoder) {
		return A2(
			$elm$http$Http$expectStringResponse,
			toMsg,
			$elm$http$Http$resolve(
				function (string) {
					return A2(
						$elm$core$Result$mapError,
						$elm$json$Json$Decode$errorToString,
						A2($elm$json$Json$Decode$decodeString, decoder, string));
				}));
	});
var $elm$http$Http$Request = function (a) {
	return {$: 'Request', a: a};
};
var $elm$http$Http$State = F2(
	function (reqs, subs) {
		return {reqs: reqs, subs: subs};
	});
var $elm$http$Http$init = $elm$core$Task$succeed(
	A2($elm$http$Http$State, $elm$core$Dict$empty, _List_Nil));
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$http$Http$updateReqs = F3(
	function (router, cmds, reqs) {
		updateReqs:
		while (true) {
			if (!cmds.b) {
				return $elm$core$Task$succeed(reqs);
			} else {
				var cmd = cmds.a;
				var otherCmds = cmds.b;
				if (cmd.$ === 'Cancel') {
					var tracker = cmd.a;
					var _v2 = A2($elm$core$Dict$get, tracker, reqs);
					if (_v2.$ === 'Nothing') {
						var $temp$router = router,
							$temp$cmds = otherCmds,
							$temp$reqs = reqs;
						router = $temp$router;
						cmds = $temp$cmds;
						reqs = $temp$reqs;
						continue updateReqs;
					} else {
						var pid = _v2.a;
						return A2(
							$elm$core$Task$andThen,
							function (_v3) {
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A2($elm$core$Dict$remove, tracker, reqs));
							},
							$elm$core$Process$kill(pid));
					}
				} else {
					var req = cmd.a;
					return A2(
						$elm$core$Task$andThen,
						function (pid) {
							var _v4 = req.tracker;
							if (_v4.$ === 'Nothing') {
								return A3($elm$http$Http$updateReqs, router, otherCmds, reqs);
							} else {
								var tracker = _v4.a;
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A3($elm$core$Dict$insert, tracker, pid, reqs));
							}
						},
						$elm$core$Process$spawn(
							A3(
								_Http_toTask,
								router,
								$elm$core$Platform$sendToApp(router),
								req)));
				}
			}
		}
	});
var $elm$http$Http$onEffects = F4(
	function (router, cmds, subs, state) {
		return A2(
			$elm$core$Task$andThen,
			function (reqs) {
				return $elm$core$Task$succeed(
					A2($elm$http$Http$State, reqs, subs));
			},
			A3($elm$http$Http$updateReqs, router, cmds, state.reqs));
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$http$Http$maybeSend = F4(
	function (router, desiredTracker, progress, _v0) {
		var actualTracker = _v0.a;
		var toMsg = _v0.b;
		return _Utils_eq(desiredTracker, actualTracker) ? $elm$core$Maybe$Just(
			A2(
				$elm$core$Platform$sendToApp,
				router,
				toMsg(progress))) : $elm$core$Maybe$Nothing;
	});
var $elm$http$Http$onSelfMsg = F3(
	function (router, _v0, state) {
		var tracker = _v0.a;
		var progress = _v0.b;
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$filterMap,
					A3($elm$http$Http$maybeSend, router, tracker, progress),
					state.subs)));
	});
var $elm$http$Http$Cancel = function (a) {
	return {$: 'Cancel', a: a};
};
var $elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (cmd.$ === 'Cancel') {
			var tracker = cmd.a;
			return $elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return $elm$http$Http$Request(
				{
					allowCookiesFromOtherDomains: r.allowCookiesFromOtherDomains,
					body: r.body,
					expect: A2(_Http_mapExpect, func, r.expect),
					headers: r.headers,
					method: r.method,
					timeout: r.timeout,
					tracker: r.tracker,
					url: r.url
				});
		}
	});
var $elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 'MySub', a: a, b: b};
	});
var $elm$http$Http$subMap = F2(
	function (func, _v0) {
		var tracker = _v0.a;
		var toMsg = _v0.b;
		return A2(
			$elm$http$Http$MySub,
			tracker,
			A2($elm$core$Basics$composeR, toMsg, func));
	});
_Platform_effectManagers['Http'] = _Platform_createManager($elm$http$Http$init, $elm$http$Http$onEffects, $elm$http$Http$onSelfMsg, $elm$http$Http$cmdMap, $elm$http$Http$subMap);
var $elm$http$Http$command = _Platform_leaf('Http');
var $elm$http$Http$subscription = _Platform_leaf('Http');
var $elm$http$Http$request = function (r) {
	return $elm$http$Http$command(
		$elm$http$Http$Request(
			{allowCookiesFromOtherDomains: false, body: r.body, expect: r.expect, headers: r.headers, method: r.method, timeout: r.timeout, tracker: r.tracker, url: r.url}));
};
var $elm$http$Http$post = function (r) {
	return $elm$http$Http$request(
		{body: r.body, expect: r.expect, headers: _List_Nil, method: 'POST', timeout: $elm$core$Maybe$Nothing, tracker: $elm$core$Maybe$Nothing, url: r.url});
};
var $elm$url$Url$Builder$toQueryPair = function (_v0) {
	var key = _v0.a;
	var value = _v0.b;
	return key + ('=' + value);
};
var $elm$url$Url$Builder$toQuery = function (parameters) {
	if (!parameters.b) {
		return '';
	} else {
		return '?' + A2(
			$elm$core$String$join,
			'&',
			A2($elm$core$List$map, $elm$url$Url$Builder$toQueryPair, parameters));
	}
};
var $elm$url$Url$Builder$crossOrigin = F3(
	function (prePath, pathSegments, parameters) {
		return prePath + ('/' + (A2($elm$core$String$join, '/', pathSegments) + $elm$url$Url$Builder$toQuery(parameters)));
	});
var $author$project$Porting$encodeTuple2 = F3(
	function (firstEncoder, secondEncoder, _v0) {
		var first = _v0.a;
		var second = _v0.b;
		return A2(
			$elm$json$Json$Encode$list,
			$elm$core$Basics$identity,
			_List_fromArray(
				[
					firstEncoder(first),
					secondEncoder(second)
				]));
	});
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm_community$intdict$IntDict$foldr = F3(
	function (f, acc, dict) {
		foldr:
		while (true) {
			switch (dict.$) {
				case 'Empty':
					return acc;
				case 'Leaf':
					var l = dict.a;
					return A3(f, l.key, l.value, acc);
				default:
					var i = dict.a;
					var $temp$f = f,
						$temp$acc = A3($elm_community$intdict$IntDict$foldr, f, acc, i.right),
						$temp$dict = i.left;
					f = $temp$f;
					acc = $temp$acc;
					dict = $temp$dict;
					continue foldr;
			}
		}
	});
var $elm_community$intdict$IntDict$toList = function (dict) {
	return A3(
		$elm_community$intdict$IntDict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $author$project$Porting$encodeIntDict = F2(
	function (valueEncoder, dict) {
		return A2(
			$elm$json$Json$Encode$list,
			A2($author$project$Porting$encodeTuple2, $elm$json$Json$Encode$int, valueEncoder),
			$elm_community$intdict$IntDict$toList(dict));
	});
var $author$project$Porting$encodeBoolToInt = function (bool) {
	if (bool) {
		return $elm$json$Json$Encode$int(1);
	} else {
		return $elm$json$Json$Encode$int(0);
	}
};
var $elm_community$json_extra$Json$Encode$Extra$maybe = function (encoder) {
	return A2(
		$elm$core$Basics$composeR,
		$elm$core$Maybe$map(encoder),
		$elm$core$Maybe$withDefault($elm$json$Json$Encode$null));
};
var $author$project$Incubator$Todoist$Item$encodeDue = function (record) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'date',
				$elm$json$Json$Encode$string(record.date)),
				_Utils_Tuple2(
				'timezone',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $elm$json$Json$Encode$string, record.timezone)),
				_Utils_Tuple2(
				'string',
				$elm$json$Json$Encode$string(record.string)),
				_Utils_Tuple2(
				'lang',
				$elm$json$Json$Encode$string(record.lang)),
				_Utils_Tuple2(
				'is_recurring',
				$elm$json$Json$Encode$bool(record.isRecurring))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeItemID = function (realOrTemp) {
	if (realOrTemp.$ === 'RealItem') {
		var intID = realOrTemp.a;
		return $elm$json$Json$Encode$int(intID);
	} else {
		var tempID = realOrTemp.a;
		return $elm$json$Json$Encode$string(tempID);
	}
};
var $author$project$Porting$encodeObjectWithoutNothings = A2(
	$elm$core$Basics$composeL,
	$elm$json$Json$Encode$object,
	$elm$core$List$filterMap($elm$core$Basics$identity));
var $author$project$Incubator$Todoist$Item$encodePriority = function (priority) {
	switch (priority.a) {
		case 1:
			return $elm$json$Json$Encode$int(4);
		case 2:
			return $elm$json$Json$Encode$int(3);
		case 3:
			return $elm$json$Json$Encode$int(2);
		default:
			return $elm$json$Json$Encode$int(1);
	}
};
var $author$project$Porting$normal = $elm$core$Maybe$Just;
var $author$project$Porting$omittable = function (_v0) {
	var name = _v0.a;
	var encoder = _v0.b;
	var fieldToCheck = _v0.c;
	return A2(
		$elm$core$Maybe$map,
		function (field) {
			return _Utils_Tuple2(
				name,
				encoder(field));
		},
		fieldToCheck);
};
var $author$project$Incubator$Todoist$Command$encodeItemChanges = function (item) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'id',
					$author$project$Incubator$Todoist$Command$encodeItemID(item.id))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('content', $elm$json$Json$Encode$string, item.content)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('due', $author$project$Incubator$Todoist$Item$encodeDue, item.due)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('priority', $author$project$Incubator$Todoist$Item$encodePriority, item.priority)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('day_order', $elm$json$Json$Encode$int, item.day_order)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('collapsed', $author$project$Porting$encodeBoolToInt, item.collapsed))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeItemCompletion = function (item) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'id',
					$author$project$Incubator$Todoist$Command$encodeItemID(item.id))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('date_completed', $elm$json$Json$Encode$string, item.date_completed)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'force_history',
					$elm$json$Json$Encode$bool(item.force_history)))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeItemOrder = function (order) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(order.id)),
				_Utils_Tuple2(
				'child_order',
				$elm$json$Json$Encode$int(order.child_order))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeProjectID = function (realOrTemp) {
	if (realOrTemp.$ === 'RealProject') {
		var intID = realOrTemp.a;
		return $elm$json$Json$Encode$int(intID);
	} else {
		var tempID = realOrTemp.a;
		return $elm$json$Json$Encode$string(tempID);
	}
};
var $author$project$Incubator$Todoist$Command$encodeNewItem = function (_new) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$omittable(
				_Utils_Tuple3('temp_id', $elm$json$Json$Encode$string, _new.temp_id)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'content',
					$elm$json$Json$Encode$string(_new.content))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('project_id', $author$project$Incubator$Todoist$Command$encodeProjectID, _new.project_id)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('due', $author$project$Incubator$Todoist$Item$encodeDue, _new.due)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'priority',
					$author$project$Incubator$Todoist$Item$encodePriority(_new.priority))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('parent_id', $author$project$Incubator$Todoist$Command$encodeItemID, _new.parent_id)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('child_order', $elm$json$Json$Encode$int, _new.child_order)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('day_order', $elm$json$Json$Encode$int, _new.day_order)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('collapsed', $author$project$Porting$encodeBoolToInt, _new.collapsed)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('auto_reminder', $elm$json$Json$Encode$bool, _new.auto_reminder))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeNewProject = function (_new) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$omittable(
				_Utils_Tuple3('temp_id', $elm$json$Json$Encode$string, _new.temp_id)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'name',
					$elm$json$Json$Encode$string(_new.name))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('color', $elm$json$Json$Encode$int, _new.color)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('parent_id', $elm$json$Json$Encode$int, _new.parent_id)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('child_order', $elm$json$Json$Encode$int, _new.child_order)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'is_favorite',
					$elm$json$Json$Encode$bool(_new.is_favorite)))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeProjectChanges = function (_new) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$omittable(
				_Utils_Tuple3('temp_id', $elm$json$Json$Encode$string, _new.temp_id)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'name',
					$elm$json$Json$Encode$string(_new.name))),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'color',
					$elm$json$Json$Encode$int(_new.color))),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'collapsed',
					$elm$json$Json$Encode$bool(_new.collapsed))),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'is_favorite',
					$elm$json$Json$Encode$bool(_new.is_favorite)))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeProjectOrder = function (v) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(v.id)),
				_Utils_Tuple2(
				'child_order',
				$elm$json$Json$Encode$int(v.child_order))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeRecurringItemCompletion = function (item) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'id',
					$author$project$Incubator$Todoist$Command$encodeItemID(item.id))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('due', $elm$json$Json$Encode$string, item.due))
			]));
};
var $author$project$Incubator$Todoist$Command$encodeCommandInstance = function (_v0) {
	var uuid = _v0.a;
	var command = _v0.b;
	var encodeWrapper = F2(
		function (typeName, args) {
			return $author$project$Porting$encodeObjectWithoutNothings(
				_List_fromArray(
					[
						$author$project$Porting$normal(
						_Utils_Tuple2(
							'type',
							$elm$json$Json$Encode$string(typeName))),
						$author$project$Porting$normal(
						_Utils_Tuple2('args', args)),
						$author$project$Porting$normal(
						_Utils_Tuple2(
							'uuid',
							$elm$json$Json$Encode$string(uuid))),
						$author$project$Porting$omittable(
						_Utils_Tuple3('temp_id', $elm$json$Json$Encode$string, $elm$core$Maybe$Nothing))
					]));
		});
	switch (command.$) {
		case 'ProjectAdd':
			var _new = command.a;
			return A2(
				encodeWrapper,
				'project_add',
				$author$project$Incubator$Todoist$Command$encodeNewProject(_new));
		case 'ProjectUpdate':
			var _new = command.a;
			return A2(
				encodeWrapper,
				'project_update',
				$author$project$Incubator$Todoist$Command$encodeProjectChanges(_new));
		case 'ProjectMove':
			var id = command.a;
			var newParent = command.b;
			return A2(
				encodeWrapper,
				'project_move',
				$author$project$Porting$encodeObjectWithoutNothings(
					_List_fromArray(
						[
							$author$project$Porting$normal(
							_Utils_Tuple2(
								'id',
								$author$project$Incubator$Todoist$Command$encodeProjectID(id))),
							$author$project$Porting$omittable(
							_Utils_Tuple3('parent_id', $author$project$Incubator$Todoist$Command$encodeProjectID, newParent))
						])));
		case 'ProjectDelete':
			var id = command.a;
			return A2(
				encodeWrapper,
				'project_delete',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							$author$project$Incubator$Todoist$Command$encodeProjectID(id))
						])));
		case 'ReorderProjects':
			var orderList = command.a;
			return A2(
				encodeWrapper,
				'project_reorder',
				A2($elm$json$Json$Encode$list, $author$project$Incubator$Todoist$Command$encodeProjectOrder, orderList));
		case 'DayOrdersUpdate':
			var dayOrdersDict = command.a;
			return A2(
				encodeWrapper,
				'item_update_day_orders',
				A2($author$project$Porting$encodeIntDict, $elm$json$Json$Encode$int, dayOrdersDict));
		case 'ItemAdd':
			var _new = command.a;
			return A2(
				encodeWrapper,
				'item_add',
				$author$project$Incubator$Todoist$Command$encodeNewItem(_new));
		case 'ItemSwitchProject':
			var id = command.a;
			var newProject = command.b;
			return A2(
				encodeWrapper,
				'item_move',
				$author$project$Porting$encodeObjectWithoutNothings(
					_List_fromArray(
						[
							$author$project$Porting$normal(
							_Utils_Tuple2(
								'id',
								$author$project$Incubator$Todoist$Command$encodeItemID(id))),
							$author$project$Porting$omittable(
							_Utils_Tuple3('parent_id', $author$project$Incubator$Todoist$Command$encodeProjectID, newProject))
						])));
		case 'ItemSwitchParent':
			var id = command.a;
			var newParentItem = command.b;
			return A2(
				encodeWrapper,
				'item_move',
				$author$project$Porting$encodeObjectWithoutNothings(
					_List_fromArray(
						[
							$author$project$Porting$normal(
							_Utils_Tuple2(
								'id',
								$author$project$Incubator$Todoist$Command$encodeItemID(id))),
							$author$project$Porting$omittable(
							_Utils_Tuple3('project_id', $author$project$Incubator$Todoist$Command$encodeItemID, newParentItem))
						])));
		case 'ItemDelete':
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_delete',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							$author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 'ItemClose':
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_close',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							$author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 'ItemComplete':
			var completionDetails = command.a;
			return A2(
				encodeWrapper,
				'item_complete',
				$author$project$Incubator$Todoist$Command$encodeItemCompletion(completionDetails));
		case 'ItemCompleteRecurring':
			var completionDetails = command.a;
			return A2(
				encodeWrapper,
				'item_update_date_complete',
				$author$project$Incubator$Todoist$Command$encodeRecurringItemCompletion(completionDetails));
		case 'ItemUncomplete':
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_uncomplete',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							$author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 'ItemArchive':
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_archive',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							$author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 'ItemUnarchive':
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_unarchive',
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							$author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 'ItemUpdate':
			var changes = command.a;
			return A2(
				encodeWrapper,
				'item_update',
				$author$project$Incubator$Todoist$Command$encodeItemChanges(changes));
		default:
			var orderList = command.a;
			return A2(
				encodeWrapper,
				'item_reorder',
				A2($elm$json$Json$Encode$list, $author$project$Incubator$Todoist$Command$encodeItemOrder, orderList));
	}
};
var $author$project$Incubator$Todoist$encodeResources = function (resource) {
	switch (resource.$) {
		case 'Projects':
			return $elm$json$Json$Encode$string('projects');
		case 'Items':
			return $elm$json$Json$Encode$string('items');
		default:
			return $elm$json$Json$Encode$string('user');
	}
};
var $elm$url$Url$Builder$QueryParameter = F2(
	function (a, b) {
		return {$: 'QueryParameter', a: a, b: b};
	});
var $elm$url$Url$percentEncode = _Url_percentEncode;
var $elm$url$Url$Builder$string = F2(
	function (key, value) {
		return A2(
			$elm$url$Url$Builder$QueryParameter,
			$elm$url$Url$percentEncode(key),
			$elm$url$Url$percentEncode(value));
	});
var $author$project$Incubator$Todoist$serverUrl = F4(
	function (secret, resourceList, commandList, _v0) {
		var syncToken = _v0.a;
		var resources = A2($elm$json$Json$Encode$list, $author$project$Incubator$Todoist$encodeResources, resourceList);
		var withRead = ($elm$core$List$length(resourceList) > 0) ? _List_fromArray(
			[
				A2($elm$url$Url$Builder$string, 'sync_token', syncToken),
				A2(
				$elm$url$Url$Builder$string,
				'resource_types',
				A2($elm$json$Json$Encode$encode, 0, resources))
			]) : _List_Nil;
		var commands = A2($elm$json$Json$Encode$list, $author$project$Incubator$Todoist$Command$encodeCommandInstance, commandList);
		var withWrite = ($elm$core$List$length(commandList) > 0) ? _List_fromArray(
			[
				A2(
				$elm$url$Url$Builder$string,
				'commands',
				A2($elm$json$Json$Encode$encode, 0, commands))
			]) : _List_Nil;
		var chosenResources = '[%22items%22,%22projects%22]';
		return A3(
			$elm$url$Url$Builder$crossOrigin,
			'https://todoist.com',
			_List_fromArray(
				['api', 'v8', 'sync']),
			_Utils_ap(
				_List_fromArray(
					[
						A2($elm$url$Url$Builder$string, 'token', secret)
					]),
				_Utils_ap(withRead, withWrite)));
	});
var $elm$json$Json$Decode$fail = _Json_fail;
var $elm_community$json_extra$Json$Decode$Extra$fromResult = function (result) {
	if (result.$ === 'Ok') {
		var successValue = result.a;
		return $elm$json$Json$Decode$succeed(successValue);
	} else {
		var errorMessage = result.a;
		return $elm$json$Json$Decode$fail(errorMessage);
	}
};
var $mgold$elm_nonempty_list$List$Nonempty$map = F2(
	function (f, _v0) {
		var x = _v0.a;
		var xs = _v0.b;
		return A2(
			$mgold$elm_nonempty_list$List$Nonempty$Nonempty,
			f(x),
			A2($elm$core$List$map, f, xs));
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map = F2(
	function (op, located) {
		switch (located.$) {
			case 'InField':
				var f = located.a;
				var val = located.b;
				return A2(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField,
					f,
					A2(
						$mgold$elm_nonempty_list$List$Nonempty$map,
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map(op),
						val));
			case 'AtIndex':
				var i = located.a;
				var val = located.b;
				return A2(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex,
					i,
					A2(
						$mgold$elm_nonempty_list$List$Nonempty$map,
						$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map(op),
						val));
			default:
				var v = located.a;
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
					op(v));
		}
	});
var $zwilias$json_decode_exploration$Json$Decode$Exploration$warningToError = function (warning) {
	if (warning.$ === 'UnusedValue') {
		var v = warning.a;
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Failure,
			'Unused value',
			$elm$core$Maybe$Just(v));
	} else {
		var w = warning.a;
		var v = warning.b;
		return A2(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Failure,
			w,
			$elm$core$Maybe$Just(v));
	}
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToErrors = $mgold$elm_nonempty_list$List$Nonempty$map(
	$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map($zwilias$json_decode_exploration$Json$Decode$Exploration$warningToError));
var $zwilias$json_decode_exploration$Json$Decode$Exploration$strict = function (res) {
	switch (res.$) {
		case 'Errors':
			var e = res.a;
			return $elm$core$Result$Err(e);
		case 'BadJson':
			return $elm$core$Result$Err(
				$mgold$elm_nonempty_list$List$Nonempty$fromElement(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
						A2($zwilias$json_decode_exploration$Json$Decode$Exploration$Failure, 'Invalid JSON', $elm$core$Maybe$Nothing))));
		case 'WithWarnings':
			var w = res.a;
			return $elm$core$Result$Err(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToErrors(w));
		default:
			var v = res.a;
			return $elm$core$Result$Ok(v);
	}
};
var $author$project$Porting$toClassic = function (decoder) {
	var runRealDecoder = function (value) {
		return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue, decoder, value);
	};
	var convertToNormalResult = function (fancyResult) {
		return A2($elm$core$Result$mapError, $zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString, fancyResult);
	};
	var asResult = function (value) {
		return $zwilias$json_decode_exploration$Json$Decode$Exploration$strict(
			runRealDecoder(value));
	};
	var _final = function (value) {
		return convertToNormalResult(
			asResult(value));
	};
	return A2(
		$elm$json$Json$Decode$andThen,
		A2($elm$core$Basics$composeL, $elm_community$json_extra$Json$Decode$Extra$fromResult, _final),
		$elm$json$Json$Decode$value);
};
var $author$project$Incubator$Todoist$sync = F4(
	function (cache, secret, resourceList, commandList) {
		return $elm$http$Http$post(
			{
				body: $elm$http$Http$emptyBody,
				expect: A2(
					$elm$http$Http$expectJson,
					$author$project$Incubator$Todoist$SyncResponded,
					$author$project$Porting$toClassic($author$project$Incubator$Todoist$decodeResponse)),
				url: A4($author$project$Incubator$Todoist$serverUrl, secret, resourceList, commandList, cache.nextSync)
			});
	});
var $author$project$Integrations$Todoist$fetchUpdates = function (localData) {
	return A4(
		$author$project$Incubator$Todoist$sync,
		localData.cache,
		$author$project$Integrations$Todoist$devSecret,
		_List_fromArray(
			[$author$project$Incubator$Todoist$Items, $author$project$Incubator$Todoist$Projects]),
		_List_Nil);
};
var $author$project$Integrations$Marvin$GotLabels = function (a) {
	return {$: 'GotLabels', a: a};
};
var $author$project$Integrations$Marvin$MarvinItem$MarvinLabel = F3(
	function (id, title, color) {
		return {color: color, id: id, title: title};
	});
var $author$project$Integrations$Marvin$MarvinItem$decodeMarvinLabel = A2(
	$author$project$Porting$optionalIgnored,
	'_rev',
	A4(
		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
		'color',
		$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
		'',
		A3(
			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'title',
			$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			A3(
				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'_id',
				$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
				$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Integrations$Marvin$MarvinItem$MarvinLabel)))));
var $elm$http$Http$Header = F2(
	function (a, b) {
		return {$: 'Header', a: a, b: b};
	});
var $elm$http$Http$header = $elm$http$Http$Header;
var $author$project$Integrations$Marvin$marvinEndpointURL = function (endpoint) {
	return A3(
		$elm$url$Url$Builder$crossOrigin,
		'https://serv.amazingmarvin.com',
		_List_fromArray(
			['api', endpoint]),
		_List_Nil);
};
var $author$project$Porting$toClassicLoose = function (decoder) {
	var runRealDecoder = function (value) {
		return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue, decoder, value);
	};
	var asResult = function (value) {
		var _v0 = runRealDecoder(value);
		switch (_v0.$) {
			case 'BadJson':
				return $elm$core$Result$Err('Bad JSON');
			case 'Errors':
				var errors = _v0.a;
				return $elm$core$Result$Err(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString(errors));
			case 'WithWarnings':
				var result = _v0.b;
				return $elm$core$Result$Ok(result);
			default:
				var result = _v0.a;
				return $elm$core$Result$Ok(result);
		}
	};
	var _final = function (value) {
		return asResult(value);
	};
	return A2(
		$elm$json$Json$Decode$andThen,
		A2($elm$core$Basics$composeL, $elm_community$json_extra$Json$Decode$Extra$fromResult, _final),
		$elm$json$Json$Decode$value);
};
var $author$project$Integrations$Marvin$getLabels = function (secret) {
	return $elm$http$Http$request(
		{
			body: $elm$http$Http$emptyBody,
			expect: A2(
				$elm$http$Http$expectJson,
				$author$project$Integrations$Marvin$GotLabels,
				$author$project$Porting$toClassicLoose(
					$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Integrations$Marvin$MarvinItem$decodeMarvinLabel))),
			headers: _List_fromArray(
				[
					A2($elm$http$Http$header, 'X-API-Token', secret)
				]),
			method: 'GET',
			timeout: $elm$core$Maybe$Nothing,
			tracker: $elm$core$Maybe$Nothing,
			url: $author$project$Integrations$Marvin$marvinEndpointURL('labels')
		});
};
var $author$project$Integrations$Marvin$partialAccessToken = 'm47dqHEwdJy56/j8tyAcXARlADg=';
var $author$project$Integrations$Marvin$getLabelsCmd = $elm$core$Platform$Cmd$batch(
	_List_fromArray(
		[
			$author$project$Integrations$Marvin$getLabels($author$project$Integrations$Marvin$partialAccessToken)
		]));
var $author$project$Integrations$Marvin$blankTriplet = {taskClasses: $elm_community$intdict$IntDict$empty, taskEntries: _List_Nil, taskInstances: $elm_community$intdict$IntDict$empty};
var $author$project$Integrations$Marvin$describeError = function (error) {
	switch (error.$) {
		case 'BadUrl':
			var msg = error.a;
			return 'For some reason we were told the URL is bad. This should never happen, it\'s a perfectly tested working URL! The error: ' + msg;
		case 'Timeout':
			return 'Timed out. Try again later?';
		case 'NetworkError':
			return 'Are you offline? I couldn\'t get on the network, but it could also be your system blocking me.';
		case 'BadStatus':
			var status = error.a;
			switch (status) {
				case 400:
					return '400 Bad Request: The request was incorrect.';
				case 401:
					return '401 Unauthorized: Authentication is required, and has failed, or has not yet been provided. Maybe your API credentials are messed up?';
				case 403:
					return '403 Forbidden: The request was valid, but for something that is forbidden.';
				case 404:
					return '404 Not Found! That should never happen, because I definitely used the right URL. Is your system or proxy blocking or messing with internet requests? Is it many years in future, where the API has been deprecated, obsoleted, and then discontinued? Or maybe it\'s far enough in the future that the service doesn\'t exist anymore but for some reason you\'re still using this version of the software?';
				case 429:
					return '429 Too Many Requests: Slow down, cowboy! Check out the API Docs for Usage Limits.';
				case 500:
					return '500 Internal Server Error: They got the message, and it got confused';
				case 502:
					return '502 Bad Gateway: I was trying to reach the server but I got stopped along the way. If you\'re definitely connected, it\'s probably a temporary hiccup on their side -- but if you see this a lot, check that your DNS is resolving (try amazingmarvin.com) and any proxy setup you have is working.';
				case 503:
					return '503 Service Unavailable: Not my fault! The service must be bogged down today, or perhaps experiencing a DDoS attack. :O';
				default:
					var other = status;
					return 'Got HTTP Error code ' + ($elm$core$String$fromInt(other) + ', not sure what that means in this case. Sorry!');
			}
		default:
			var string = error.a;
			return 'I successfully talked with the servers, but the response had some weird parts I was never trained for. Either Marvin changed something recently, or you\'ve found a weird edge case the developer didn\'t know about. Either way, please report this! \n' + string;
	}
};
var $author$project$Integrations$Marvin$GotItems = function (a) {
	return {$: 'GotItems', a: a};
};
var $zwilias$json_decode_exploration$Json$Decode$Exploration$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $zwilias$json_decode_exploration$Json$Decode$Exploration$field, decoder, fields);
	});
var $elm$bytes$Bytes$Encode$getWidth = function (builder) {
	switch (builder.$) {
		case 'I8':
			return 1;
		case 'I16':
			return 2;
		case 'I32':
			return 4;
		case 'U8':
			return 1;
		case 'U16':
			return 2;
		case 'U32':
			return 4;
		case 'F32':
			return 4;
		case 'F64':
			return 8;
		case 'Seq':
			var w = builder.a;
			return w;
		case 'Utf8':
			var w = builder.a;
			return w;
		default:
			var bs = builder.a;
			return _Bytes_width(bs);
	}
};
var $elm$bytes$Bytes$LE = {$: 'LE'};
var $elm$bytes$Bytes$Encode$write = F3(
	function (builder, mb, offset) {
		switch (builder.$) {
			case 'I8':
				var n = builder.a;
				return A3(_Bytes_write_i8, mb, offset, n);
			case 'I16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'I32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_i32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U8':
				var n = builder.a;
				return A3(_Bytes_write_u8, mb, offset, n);
			case 'U16':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u16,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'U32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_u32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F32':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f32,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'F64':
				var e = builder.a;
				var n = builder.b;
				return A4(
					_Bytes_write_f64,
					mb,
					offset,
					n,
					_Utils_eq(e, $elm$bytes$Bytes$LE));
			case 'Seq':
				var bs = builder.b;
				return A3($elm$bytes$Bytes$Encode$writeSequence, bs, mb, offset);
			case 'Utf8':
				var s = builder.b;
				return A3(_Bytes_write_string, mb, offset, s);
			default:
				var bs = builder.a;
				return A3(_Bytes_write_bytes, mb, offset, bs);
		}
	});
var $elm$bytes$Bytes$Encode$writeSequence = F3(
	function (builders, mb, offset) {
		writeSequence:
		while (true) {
			if (!builders.b) {
				return offset;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$builders = bs,
					$temp$mb = mb,
					$temp$offset = A3($elm$bytes$Bytes$Encode$write, b, mb, offset);
				builders = $temp$builders;
				mb = $temp$mb;
				offset = $temp$offset;
				continue writeSequence;
			}
		}
	});
var $elm$bytes$Bytes$Encode$encode = _Bytes_encode;
var $elm$bytes$Bytes$Decode$decode = F2(
	function (_v0, bs) {
		var decoder = _v0.a;
		return A2(_Bytes_decode, decoder, bs);
	});
var $elm$bytes$Bytes$Decode$Decoder = function (a) {
	return {$: 'Decoder', a: a};
};
var $elm$bytes$Bytes$Decode$loopHelp = F4(
	function (state, callback, bites, offset) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var decoder = _v0.a;
			var _v1 = A2(decoder, bites, offset);
			var newOffset = _v1.a;
			var step = _v1.b;
			if (step.$ === 'Loop') {
				var newState = step.a;
				var $temp$state = newState,
					$temp$callback = callback,
					$temp$bites = bites,
					$temp$offset = newOffset;
				state = $temp$state;
				callback = $temp$callback;
				bites = $temp$bites;
				offset = $temp$offset;
				continue loopHelp;
			} else {
				var result = step.a;
				return _Utils_Tuple2(newOffset, result);
			}
		}
	});
var $elm$bytes$Bytes$Decode$loop = F2(
	function (state, callback) {
		return $elm$bytes$Bytes$Decode$Decoder(
			A2($elm$bytes$Bytes$Decode$loopHelp, state, callback));
	});
var $elm$bytes$Bytes$Decode$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$bytes$Bytes$Decode$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $elm$core$String$fromChar = function (_char) {
	return A2($elm$core$String$cons, _char, '');
};
var $danfishgold$base64_bytes$Decode$lowest6BitsMask = 63;
var $elm$core$Char$fromCode = _Char_fromCode;
var $danfishgold$base64_bytes$Decode$unsafeToChar = function (n) {
	if (n <= 25) {
		return $elm$core$Char$fromCode(65 + n);
	} else {
		if (n <= 51) {
			return $elm$core$Char$fromCode(97 + (n - 26));
		} else {
			if (n <= 61) {
				return $elm$core$Char$fromCode(48 + (n - 52));
			} else {
				switch (n) {
					case 62:
						return _Utils_chr('+');
					case 63:
						return _Utils_chr('/');
					default:
						return _Utils_chr('\u0000');
				}
			}
		}
	}
};
var $danfishgold$base64_bytes$Decode$bitsToChars = F2(
	function (bits, missing) {
		var s = $danfishgold$base64_bytes$Decode$unsafeToChar(bits & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var r = $danfishgold$base64_bytes$Decode$unsafeToChar((bits >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var q = $danfishgold$base64_bytes$Decode$unsafeToChar((bits >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var p = $danfishgold$base64_bytes$Decode$unsafeToChar(bits >>> 18);
		switch (missing) {
			case 0:
				return A2(
					$elm$core$String$cons,
					p,
					A2(
						$elm$core$String$cons,
						q,
						A2(
							$elm$core$String$cons,
							r,
							$elm$core$String$fromChar(s))));
			case 1:
				return A2(
					$elm$core$String$cons,
					p,
					A2(
						$elm$core$String$cons,
						q,
						A2($elm$core$String$cons, r, '=')));
			case 2:
				return A2(
					$elm$core$String$cons,
					p,
					A2($elm$core$String$cons, q, '=='));
			default:
				return '';
		}
	});
var $danfishgold$base64_bytes$Decode$bitsToCharSpecialized = F4(
	function (bits1, bits2, bits3, accum) {
		var z = $danfishgold$base64_bytes$Decode$unsafeToChar((bits3 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var y = $danfishgold$base64_bytes$Decode$unsafeToChar((bits3 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var x = $danfishgold$base64_bytes$Decode$unsafeToChar(bits3 >>> 18);
		var w = $danfishgold$base64_bytes$Decode$unsafeToChar(bits3 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var s = $danfishgold$base64_bytes$Decode$unsafeToChar(bits1 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var r = $danfishgold$base64_bytes$Decode$unsafeToChar((bits1 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var q = $danfishgold$base64_bytes$Decode$unsafeToChar((bits1 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var p = $danfishgold$base64_bytes$Decode$unsafeToChar(bits1 >>> 18);
		var d = $danfishgold$base64_bytes$Decode$unsafeToChar(bits2 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var c = $danfishgold$base64_bytes$Decode$unsafeToChar((bits2 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var b = $danfishgold$base64_bytes$Decode$unsafeToChar((bits2 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
		var a = $danfishgold$base64_bytes$Decode$unsafeToChar(bits2 >>> 18);
		return A2(
			$elm$core$String$cons,
			x,
			A2(
				$elm$core$String$cons,
				y,
				A2(
					$elm$core$String$cons,
					z,
					A2(
						$elm$core$String$cons,
						w,
						A2(
							$elm$core$String$cons,
							a,
							A2(
								$elm$core$String$cons,
								b,
								A2(
									$elm$core$String$cons,
									c,
									A2(
										$elm$core$String$cons,
										d,
										A2(
											$elm$core$String$cons,
											p,
											A2(
												$elm$core$String$cons,
												q,
												A2(
													$elm$core$String$cons,
													r,
													A2($elm$core$String$cons, s, accum))))))))))));
	});
var $danfishgold$base64_bytes$Decode$decode18Help = F5(
	function (a, b, c, d, e) {
		var combined6 = ((255 & d) << 16) | e;
		var combined5 = d >>> 8;
		var combined4 = 16777215 & c;
		var combined3 = ((65535 & b) << 8) | (c >>> 24);
		var combined2 = ((255 & a) << 16) | (b >>> 16);
		var combined1 = a >>> 8;
		return A4(
			$danfishgold$base64_bytes$Decode$bitsToCharSpecialized,
			combined3,
			combined2,
			combined1,
			A4($danfishgold$base64_bytes$Decode$bitsToCharSpecialized, combined6, combined5, combined4, ''));
	});
var $elm$bytes$Bytes$Decode$map5 = F6(
	function (func, _v0, _v1, _v2, _v3, _v4) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		var decodeC = _v2.a;
		var decodeD = _v3.a;
		var decodeE = _v4.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v5 = A2(decodeA, bites, offset);
					var aOffset = _v5.a;
					var a = _v5.b;
					var _v6 = A2(decodeB, bites, aOffset);
					var bOffset = _v6.a;
					var b = _v6.b;
					var _v7 = A2(decodeC, bites, bOffset);
					var cOffset = _v7.a;
					var c = _v7.b;
					var _v8 = A2(decodeD, bites, cOffset);
					var dOffset = _v8.a;
					var d = _v8.b;
					var _v9 = A2(decodeE, bites, dOffset);
					var eOffset = _v9.a;
					var e = _v9.b;
					return _Utils_Tuple2(
						eOffset,
						A5(func, a, b, c, d, e));
				}));
	});
var $elm$bytes$Bytes$BE = {$: 'BE'};
var $elm$bytes$Bytes$Decode$unsignedInt16 = function (endianness) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_u16(
			_Utils_eq(endianness, $elm$bytes$Bytes$LE)));
};
var $danfishgold$base64_bytes$Decode$u16BE = $elm$bytes$Bytes$Decode$unsignedInt16($elm$bytes$Bytes$BE);
var $elm$bytes$Bytes$Decode$unsignedInt32 = function (endianness) {
	return $elm$bytes$Bytes$Decode$Decoder(
		_Bytes_read_u32(
			_Utils_eq(endianness, $elm$bytes$Bytes$LE)));
};
var $danfishgold$base64_bytes$Decode$u32BE = $elm$bytes$Bytes$Decode$unsignedInt32($elm$bytes$Bytes$BE);
var $danfishgold$base64_bytes$Decode$decode18Bytes = A6($elm$bytes$Bytes$Decode$map5, $danfishgold$base64_bytes$Decode$decode18Help, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u16BE);
var $elm$bytes$Bytes$Decode$map = F2(
	function (func, _v0) {
		var decodeA = _v0.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v1 = A2(decodeA, bites, offset);
					var aOffset = _v1.a;
					var a = _v1.b;
					return _Utils_Tuple2(
						aOffset,
						func(a));
				}));
	});
var $elm$bytes$Bytes$Decode$map2 = F3(
	function (func, _v0, _v1) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v2 = A2(decodeA, bites, offset);
					var aOffset = _v2.a;
					var a = _v2.b;
					var _v3 = A2(decodeB, bites, aOffset);
					var bOffset = _v3.a;
					var b = _v3.b;
					return _Utils_Tuple2(
						bOffset,
						A2(func, a, b));
				}));
	});
var $elm$bytes$Bytes$Decode$map3 = F4(
	function (func, _v0, _v1, _v2) {
		var decodeA = _v0.a;
		var decodeB = _v1.a;
		var decodeC = _v2.a;
		return $elm$bytes$Bytes$Decode$Decoder(
			F2(
				function (bites, offset) {
					var _v3 = A2(decodeA, bites, offset);
					var aOffset = _v3.a;
					var a = _v3.b;
					var _v4 = A2(decodeB, bites, aOffset);
					var bOffset = _v4.a;
					var b = _v4.b;
					var _v5 = A2(decodeC, bites, bOffset);
					var cOffset = _v5.a;
					var c = _v5.b;
					return _Utils_Tuple2(
						cOffset,
						A3(func, a, b, c));
				}));
	});
var $elm$bytes$Bytes$Decode$succeed = function (a) {
	return $elm$bytes$Bytes$Decode$Decoder(
		F2(
			function (_v0, offset) {
				return _Utils_Tuple2(offset, a);
			}));
};
var $elm$bytes$Bytes$Decode$unsignedInt8 = $elm$bytes$Bytes$Decode$Decoder(_Bytes_read_u8);
var $danfishgold$base64_bytes$Decode$loopHelp = function (_v0) {
	var remaining = _v0.remaining;
	var string = _v0.string;
	if (remaining >= 18) {
		return A2(
			$elm$bytes$Bytes$Decode$map,
			function (result) {
				return $elm$bytes$Bytes$Decode$Loop(
					{
						remaining: remaining - 18,
						string: _Utils_ap(string, result)
					});
			},
			$danfishgold$base64_bytes$Decode$decode18Bytes);
	} else {
		if (remaining >= 3) {
			var helper = F3(
				function (a, b, c) {
					var combined = ((a << 16) | (b << 8)) | c;
					return $elm$bytes$Bytes$Decode$Loop(
						{
							remaining: remaining - 3,
							string: _Utils_ap(
								string,
								A2($danfishgold$base64_bytes$Decode$bitsToChars, combined, 0))
						});
				});
			return A4($elm$bytes$Bytes$Decode$map3, helper, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8);
		} else {
			if (!remaining) {
				return $elm$bytes$Bytes$Decode$succeed(
					$elm$bytes$Bytes$Decode$Done(string));
			} else {
				if (remaining === 2) {
					var helper = F2(
						function (a, b) {
							var combined = (a << 16) | (b << 8);
							return $elm$bytes$Bytes$Decode$Done(
								_Utils_ap(
									string,
									A2($danfishgold$base64_bytes$Decode$bitsToChars, combined, 1)));
						});
					return A3($elm$bytes$Bytes$Decode$map2, helper, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8);
				} else {
					return A2(
						$elm$bytes$Bytes$Decode$map,
						function (a) {
							return $elm$bytes$Bytes$Decode$Done(
								_Utils_ap(
									string,
									A2($danfishgold$base64_bytes$Decode$bitsToChars, a << 16, 2)));
						},
						$elm$bytes$Bytes$Decode$unsignedInt8);
				}
			}
		}
	}
};
var $danfishgold$base64_bytes$Decode$decoder = function (width) {
	return A2(
		$elm$bytes$Bytes$Decode$loop,
		{remaining: width, string: ''},
		$danfishgold$base64_bytes$Decode$loopHelp);
};
var $elm$bytes$Bytes$width = _Bytes_width;
var $danfishgold$base64_bytes$Decode$fromBytes = function (bytes) {
	return A2(
		$elm$bytes$Bytes$Decode$decode,
		$danfishgold$base64_bytes$Decode$decoder(
			$elm$bytes$Bytes$width(bytes)),
		bytes);
};
var $danfishgold$base64_bytes$Base64$fromBytes = $danfishgold$base64_bytes$Decode$fromBytes;
var $elm$bytes$Bytes$Encode$Utf8 = F2(
	function (a, b) {
		return {$: 'Utf8', a: a, b: b};
	});
var $elm$bytes$Bytes$Encode$string = function (str) {
	return A2(
		$elm$bytes$Bytes$Encode$Utf8,
		_Bytes_getStringWidth(str),
		str);
};
var $author$project$Integrations$Marvin$buildAuthorizationToken = F2(
	function (username, password) {
		return A2(
			$elm$core$Maybe$withDefault,
			'',
			$danfishgold$base64_bytes$Base64$fromBytes(
				$elm$bytes$Bytes$Encode$encode(
					$elm$bytes$Bytes$Encode$string(username + (':' + password)))));
	});
var $author$project$Integrations$Marvin$buildAuthorizationHeader = F2(
	function (username, password) {
		return A2(
			$elm$http$Http$header,
			'Authorization',
			'Basic ' + A2($author$project$Integrations$Marvin$buildAuthorizationToken, username, password));
	});
var $author$project$Integrations$Marvin$MarvinItem$Essential = {$: 'Essential'};
var $author$project$Integrations$Marvin$MarvinItem$MarvinItem = function (id) {
	return function (done) {
		return function (day) {
			return function (title) {
				return function (parentId) {
					return function (labelIds) {
						return function (firstScheduled) {
							return function (rank) {
								return function (dailySection) {
									return function (bonusSection) {
										return function (customSection) {
											return function (timeBlockSection) {
												return function (note) {
													return function (dueDate) {
														return function (timeEstimate) {
															return function (isReward) {
																return function (isStarred) {
																	return function (isFrogged) {
																		return function (plannedWeek) {
																			return function (plannedMonth) {
																				return function (rewardPoints) {
																					return function (rewardId) {
																						return function (backburner) {
																							return function (reviewDate) {
																								return function (itemSnoozeTime) {
																									return function (permaSnoozeTime) {
																										return function (timeZoneOffset) {
																											return function (startDate) {
																												return function (endDate) {
																													return function (db) {
																														return function (type_) {
																															return function (times) {
																																return function (taskTime) {
																																	return {backburner: backburner, bonusSection: bonusSection, customSection: customSection, dailySection: dailySection, day: day, db: db, done: done, dueDate: dueDate, endDate: endDate, firstScheduled: firstScheduled, id: id, isFrogged: isFrogged, isReward: isReward, isStarred: isStarred, itemSnoozeTime: itemSnoozeTime, labelIds: labelIds, note: note, parentId: parentId, permaSnoozeTime: permaSnoozeTime, plannedMonth: plannedMonth, plannedWeek: plannedWeek, rank: rank, reviewDate: reviewDate, rewardId: rewardId, rewardPoints: rewardPoints, startDate: startDate, taskTime: taskTime, timeBlockSection: timeBlockSection, timeEstimate: timeEstimate, timeZoneOffset: timeZoneOffset, times: times, title: title, type_: type_};
																																};
																															};
																														};
																													};
																												};
																											};
																										};
																									};
																								};
																							};
																						};
																					};
																				};
																			};
																		};
																	};
																};
															};
														};
													};
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Integrations$Marvin$MarvinItem$Task = {$: 'Task'};
var $author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder = A2($author$project$Porting$customDecoder, $zwilias$json_decode_exploration$Json$Decode$Exploration$string, $author$project$SmartTime$Human$Calendar$fromNumberString);
var $author$project$Integrations$Marvin$MarvinItem$Category = {$: 'Category'};
var $author$project$Integrations$Marvin$MarvinItem$Project = {$: 'Project'};
var $author$project$Integrations$Marvin$MarvinItem$decodeItemType = function () {
	var get = function (id) {
		switch (id) {
			case 'task':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Integrations$Marvin$MarvinItem$Task);
			case 'project':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Integrations$Marvin$MarvinItem$Project);
			case 'category':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Integrations$Marvin$MarvinItem$Category);
			default:
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$fail('unknown value for ItemType: ' + id);
		}
	};
	return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$andThen, get, $zwilias$json_decode_exploration$Json$Decode$Exploration$string);
}();
var $author$project$Integrations$Marvin$MarvinItem$Bonus = {$: 'Bonus'};
var $author$project$Integrations$Marvin$MarvinItem$essentialOrBonusDecoder = function () {
	var get = function (id) {
		switch (id) {
			case 'Essential':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Integrations$Marvin$MarvinItem$Essential);
			case 'Bonus':
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Integrations$Marvin$MarvinItem$Bonus);
			default:
				return $zwilias$json_decode_exploration$Json$Decode$Exploration$fail('unknown value for EssentialOrBonus: ' + id);
		}
	};
	return A2($zwilias$json_decode_exploration$Json$Decode$Exploration$andThen, get, $zwilias$json_decode_exploration$Json$Decode$Exploration$string);
}();
var $author$project$SmartTime$Human$Calendar$Month$next = function (givenMonth) {
	switch (givenMonth.$) {
		case 'Jan':
			return $author$project$SmartTime$Human$Calendar$Month$Feb;
		case 'Feb':
			return $author$project$SmartTime$Human$Calendar$Month$Mar;
		case 'Mar':
			return $author$project$SmartTime$Human$Calendar$Month$Apr;
		case 'Apr':
			return $author$project$SmartTime$Human$Calendar$Month$May;
		case 'May':
			return $author$project$SmartTime$Human$Calendar$Month$Jun;
		case 'Jun':
			return $author$project$SmartTime$Human$Calendar$Month$Jul;
		case 'Jul':
			return $author$project$SmartTime$Human$Calendar$Month$Aug;
		case 'Aug':
			return $author$project$SmartTime$Human$Calendar$Month$Sep;
		case 'Sep':
			return $author$project$SmartTime$Human$Calendar$Month$Oct;
		case 'Oct':
			return $author$project$SmartTime$Human$Calendar$Month$Nov;
		case 'Nov':
			return $author$project$SmartTime$Human$Calendar$Month$Dec;
		default:
			return $author$project$SmartTime$Human$Calendar$Month$Jan;
	}
};
var $author$project$SmartTime$Human$Calendar$calculate = F3(
	function (givenYear, givenMonth, dayCounter) {
		calculate:
		while (true) {
			var monthsLeftToGo = !_Utils_eq(givenMonth, $author$project$SmartTime$Human$Calendar$Month$Dec);
			var monthSize = A2($author$project$SmartTime$Human$Calendar$Month$length, givenYear, givenMonth);
			var monthOverFlow = _Utils_cmp(dayCounter, monthSize) > 0;
			if (monthsLeftToGo && monthOverFlow) {
				var remainingDaysToCount = dayCounter - monthSize;
				var nextMonthToCheck = $author$project$SmartTime$Human$Calendar$Month$next(givenMonth);
				var $temp$givenYear = givenYear,
					$temp$givenMonth = nextMonthToCheck,
					$temp$dayCounter = remainingDaysToCount;
				givenYear = $temp$givenYear;
				givenMonth = $temp$givenMonth;
				dayCounter = $temp$dayCounter;
				continue calculate;
			} else {
				return {
					day: $author$project$SmartTime$Human$Calendar$Month$DayOfMonth(dayCounter),
					month: givenMonth,
					year: givenYear
				};
			}
		}
	});
var $author$project$SmartTime$Human$Calendar$divWithRemainder = F2(
	function (a, b) {
		return _Utils_Tuple2(
			(a / b) | 0,
			A2($elm$core$Basics$modBy, b, a));
	});
var $author$project$SmartTime$Human$Calendar$year = function (_v0) {
	var givenDays = _v0.a;
	var daysInYear = 365;
	var daysInLeapCycle = 146097;
	var daysInFourYears = 1461;
	var daysInCentury = 36524;
	var _v1 = A2($author$project$SmartTime$Human$Calendar$divWithRemainder, givenDays, daysInLeapCycle);
	var leapCyclesPassed = _v1.a;
	var daysWithoutLeapCycles = _v1.b;
	var yearsFromLeapCycles = leapCyclesPassed * 400;
	var _v2 = A2($author$project$SmartTime$Human$Calendar$divWithRemainder, daysWithoutLeapCycles, daysInCentury);
	var centuriesPassed = _v2.a;
	var daysWithoutCenturies = _v2.b;
	var yearsFromCenturies = centuriesPassed * 100;
	var _v3 = A2($author$project$SmartTime$Human$Calendar$divWithRemainder, daysWithoutCenturies, daysInFourYears);
	var fourthYearsPassed = _v3.a;
	var daysWithoutFourthYears = _v3.b;
	var _v4 = A2($author$project$SmartTime$Human$Calendar$divWithRemainder, daysWithoutFourthYears, daysInYear);
	var wholeYears = _v4.a;
	var daysWithoutYears = _v4.b;
	var newYear = (!daysWithoutYears) ? 0 : 1;
	var yearsFromFourYearBlocks = fourthYearsPassed * 4;
	var totalYears = (((yearsFromLeapCycles + yearsFromCenturies) + yearsFromFourYearBlocks) + wholeYears) + newYear;
	return $author$project$SmartTime$Human$Calendar$Year$Year(totalYears);
};
var $author$project$SmartTime$Human$Calendar$toOrdinalDate = function (_v0) {
	var rd = _v0.a;
	var givenYear = $author$project$SmartTime$Human$Calendar$year(
		$author$project$SmartTime$Human$Calendar$CalendarDate(rd));
	return {
		ordinalDay: rd - $author$project$SmartTime$Human$Calendar$Year$daysBefore(givenYear),
		year: givenYear
	};
};
var $author$project$SmartTime$Human$Calendar$toParts = function (_v0) {
	var rd = _v0.a;
	var date = $author$project$SmartTime$Human$Calendar$toOrdinalDate(
		$author$project$SmartTime$Human$Calendar$CalendarDate(rd));
	return A3($author$project$SmartTime$Human$Calendar$calculate, date.year, $author$project$SmartTime$Human$Calendar$Month$Jan, date.ordinalDay);
};
var $author$project$SmartTime$Human$Calendar$month = A2(
	$elm$core$Basics$composeR,
	$author$project$SmartTime$Human$Calendar$toParts,
	function ($) {
		return $.month;
	});
var $author$project$Integrations$Marvin$MarvinItem$monthDecoder = function () {
	var toYearAndMonth = function (date) {
		return _Utils_Tuple2(
			$author$project$SmartTime$Human$Calendar$year(date),
			$author$project$SmartTime$Human$Calendar$month(date));
	};
	var fakeDate = function (twoPartString) {
		return $author$project$SmartTime$Human$Calendar$fromNumberString(twoPartString + '-01');
	};
	var output = function (input) {
		return A2(
			$elm$core$Result$map,
			toYearAndMonth,
			fakeDate(input));
	};
	return A2($author$project$Porting$customDecoder, $zwilias$json_decode_exploration$Json$Decode$Exploration$string, output);
}();
var $author$project$SmartTime$Human$Clock$parseHM = A2(
	$elm$parser$Parser$keeper,
	A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			A2(
				$elm$parser$Parser$keeper,
				$elm$parser$Parser$succeed($author$project$SmartTime$Human$Clock$clock),
				A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$backtrackable($author$project$ParserExtra$possiblyPaddedInt),
					$elm$parser$Parser$symbol(':'))),
			A2($author$project$ParserExtra$strictLengthInt, 2, 2)),
		$elm$parser$Parser$succeed(0)),
	$elm$parser$Parser$succeed(0));
var $author$project$SmartTime$Human$Clock$fromStandardString = function (input) {
	var parserHMSResult = A2($elm$parser$Parser$run, $author$project$SmartTime$Human$Clock$parseHMS, input);
	var parserHMResult = A2($elm$parser$Parser$run, $author$project$SmartTime$Human$Clock$parseHM, input);
	var bestResult = function () {
		if (parserHMSResult.$ === 'Ok') {
			return parserHMSResult;
		} else {
			return parserHMResult;
		}
	}();
	return A2($elm$core$Result$mapError, $author$project$ParserExtra$realDeadEndsToString, bestResult);
};
var $author$project$Integrations$Marvin$MarvinItem$timeOfDayDecoder = A2($author$project$Porting$customDecoder, $zwilias$json_decode_exploration$Json$Decode$Exploration$string, $author$project$SmartTime$Human$Clock$fromStandardString);
var $author$project$Integrations$Marvin$MarvinItem$decodeMarvinItem = A2(
	$author$project$Porting$optionalIgnored,
	'rank_43f625b3-1d08-4f0f-b21e-d0a8d2f707ea',
	A2(
		$author$project$Porting$optionalIgnored,
		'priority',
		A2(
			$author$project$Porting$optionalIgnored,
			'ackedDeps',
			A2(
				$author$project$Porting$optionalIgnored,
				'dependsOn',
				A2(
					$author$project$Porting$optionalIgnored,
					'',
					A2(
						$author$project$Porting$optionalIgnored,
						'newRecurringProject',
						A2(
							$author$project$Porting$optionalIgnored,
							'workedOnAt',
							A2(
								$author$project$Porting$optionalIgnored,
								'imported',
								A2(
									$author$project$Porting$optionalIgnored,
									'_rev',
									A2(
										$author$project$Porting$optionalIgnored,
										'sectionid',
										A2(
											$author$project$Porting$optionalIgnored,
											'sectionId',
											A2(
												$author$project$Porting$optionalIgnored,
												'generatedAt',
												A2(
													$author$project$Porting$optionalIgnored,
													'createdAt',
													A2(
														$author$project$Porting$optionalIgnored,
														'recurringTaskId',
														A2(
															$author$project$Porting$optionalIgnored,
															'recurring',
															A2(
																$author$project$Porting$optionalIgnored,
																'echoId',
																A2(
																	$author$project$Porting$optionalIgnored,
																	'remindAt',
																	A2(
																		$author$project$Porting$optionalIgnored,
																		'reminder',
																		A2(
																			$author$project$Porting$optionalIgnored,
																			'echo',
																			A2(
																				$author$project$Porting$optionalIgnored,
																				'remind',
																				A2(
																					$author$project$Porting$optionalIgnored,
																					'completedAt',
																					A2(
																						$author$project$Porting$optionalIgnored,
																						'doneAt',
																						A2(
																							$author$project$Porting$optionalIgnored,
																							'duration',
																							A2(
																								$author$project$Porting$optionalIgnored,
																								'updatedAt',
																								A2(
																									$author$project$Porting$optionalIgnored,
																									'fieldUpdates',
																									A2(
																										$author$project$Porting$optionalIgnored,
																										'echoedAt',
																										A2(
																											$author$project$Porting$optionalIgnored,
																											'rank_fbfe2f43-3ed1-472a-bea7-d1bc2185ccf6',
																											A2(
																												$author$project$Porting$optionalIgnored,
																												'fixParentId',
																												A2(
																													$author$project$Porting$optionalIgnored,
																													'masterRank',
																													A2(
																														$author$project$Porting$optionalIgnored,
																														'reminderOffset',
																														A2(
																															$author$project$Porting$optionalIgnored,
																															'snooze',
																															A2(
																																$author$project$Porting$optionalIgnored,
																																'autoSnooze',
																																A2(
																																	$author$project$Porting$optionalIgnored,
																																	'reminderTime',
																																	A2(
																																		$author$project$Porting$optionalIgnored,
																																		'subtasks',
																																		A4(
																																			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																			'taskTime',
																																			$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$timeOfDayDecoder),
																																			$elm$core$Maybe$Nothing,
																																			A4(
																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																				'times',
																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Porting$decodeMoment),
																																				_List_Nil,
																																				A4(
																																					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																					'type',
																																					$author$project$Integrations$Marvin$MarvinItem$decodeItemType,
																																					$author$project$Integrations$Marvin$MarvinItem$Task,
																																					A4(
																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																						'db',
																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																																						'',
																																						A4(
																																							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																							'endDate',
																																							$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder),
																																							$elm$core$Maybe$Nothing,
																																							A4(
																																								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																								'startDate',
																																								$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder),
																																								$elm$core$Maybe$Nothing,
																																								A4(
																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																									'timeZoneOffset',
																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$int),
																																									$elm$core$Maybe$Nothing,
																																									A4(
																																										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																										'permaSnoozeTime',
																																										$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$timeOfDayDecoder),
																																										$elm$core$Maybe$Nothing,
																																										A4(
																																											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																											'itemSnoozeTime',
																																											$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Porting$decodeMoment),
																																											$elm$core$Maybe$Nothing,
																																											A4(
																																												$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																												'reviewDate',
																																												$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder),
																																												$elm$core$Maybe$Nothing,
																																												A4(
																																													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																													'backburner',
																																													$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																																													false,
																																													A4(
																																														$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																														'rewardId',
																																														$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
																																														$elm$core$Maybe$Nothing,
																																														A4(
																																															$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																															'rewardPoints',
																																															$zwilias$json_decode_exploration$Json$Decode$Exploration$float,
																																															0,
																																															A4(
																																																$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																'plannedMonth',
																																																$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$monthDecoder),
																																																$elm$core$Maybe$Nothing,
																																																A4(
																																																	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																	'plannedWeek',
																																																	$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder),
																																																	$elm$core$Maybe$Nothing,
																																																	A4(
																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																		'isFrogged',
																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
																																																			_List_fromArray(
																																																				[
																																																					A3(
																																																					$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
																																																					$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																																																					false,
																																																					$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(0)),
																																																					$zwilias$json_decode_exploration$Json$Decode$Exploration$int
																																																				])),
																																																		0,
																																																		A4(
																																																			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																			'isStarred',
																																																			$zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
																																																				_List_fromArray(
																																																					[
																																																						A3(
																																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
																																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																																																						false,
																																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(0)),
																																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$int
																																																					])),
																																																			0,
																																																			A4(
																																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																				'isReward',
																																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																																																				false,
																																																				A4(
																																																					$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																					'timeEstimate',
																																																					$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Porting$decodeDuration),
																																																					$elm$core$Maybe$Nothing,
																																																					A4(
																																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																						'dueDate',
																																																						$zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
																																																							_List_fromArray(
																																																								[
																																																									A3(
																																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
																																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																																																									'',
																																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($elm$core$Maybe$Nothing)),
																																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder)
																																																								])),
																																																						$elm$core$Maybe$Nothing,
																																																						A4(
																																																							$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																							'note',
																																																							$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
																																																							$elm$core$Maybe$Nothing,
																																																							A4(
																																																								$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																								'timeBlockSection',
																																																								$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
																																																								$elm$core$Maybe$Nothing,
																																																								A4(
																																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																									'customSection',
																																																									$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
																																																									$elm$core$Maybe$Nothing,
																																																									A4(
																																																										$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																										'bonusSection',
																																																										$author$project$Integrations$Marvin$MarvinItem$essentialOrBonusDecoder,
																																																										$author$project$Integrations$Marvin$MarvinItem$Essential,
																																																										A4(
																																																											$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																											'dailySection',
																																																											$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
																																																											$elm$core$Maybe$Nothing,
																																																											A4(
																																																												$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																												'rank',
																																																												$zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																																																												0,
																																																												A4(
																																																													$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																													'firstScheduled',
																																																													$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder),
																																																													$elm$core$Maybe$Nothing,
																																																													A4(
																																																														$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																														'labelIds',
																																																														$zwilias$json_decode_exploration$Json$Decode$Exploration$list($zwilias$json_decode_exploration$Json$Decode$Exploration$string),
																																																														_List_Nil,
																																																														A4(
																																																															$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																															'parentId',
																																																															$zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
																																																																_List_fromArray(
																																																																	[
																																																																		A3(
																																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
																																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																																																																		'unassigned',
																																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($elm$core$Maybe$Nothing)),
																																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($zwilias$json_decode_exploration$Json$Decode$Exploration$string)
																																																																	])),
																																																															$elm$core$Maybe$Nothing,
																																																															A3(
																																																																$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																																																																'title',
																																																																$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																																																																A4(
																																																																	$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																																	'day',
																																																																	$zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
																																																																		_List_fromArray(
																																																																			[
																																																																				A3(
																																																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$check,
																																																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																																																																				'unassigned',
																																																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($elm$core$Maybe$Nothing)),
																																																																				$zwilias$json_decode_exploration$Json$Decode$Exploration$nullable($author$project$Integrations$Marvin$MarvinItem$calendarDateDecoder)
																																																																			])),
																																																																	$elm$core$Maybe$Nothing,
																																																																	A4(
																																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																																																																		'done',
																																																																		$zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																																																																		false,
																																																																		A3(
																																																																			$zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																																																																			'_id',
																																																																			$zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																																																																			$zwilias$json_decode_exploration$Json$Decode$Exploration$succeed($author$project$Integrations$Marvin$MarvinItem$MarvinItem))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
var $elm$http$Http$jsonBody = function (value) {
	return A2(
		_Http_pair,
		'application/json',
		A2($elm$json$Json$Encode$encode, 0, value));
};
var $author$project$Integrations$Marvin$marvinCloudantDatabaseUrl = F2(
	function (directories, params) {
		return A3($elm$url$Url$Builder$crossOrigin, 'https://512940bf-6e0c-4d7b-884b-9fc66185836b-bluemix.cloudant.com', directories, params);
	});
var $author$project$Integrations$Marvin$syncDatabase = 'u32410002';
var $author$project$Integrations$Marvin$syncPassword = '3c749548fd996396c2bfefdb44bd140fc9d25de8';
var $author$project$Integrations$Marvin$syncUser = 'tuddereartheirceirleacco';
var $author$project$Integrations$Marvin$getTasks = function (secret) {
	return $elm$http$Http$request(
		{
			body: $elm$http$Http$jsonBody(
				$elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'selector',
							$elm$json$Json$Encode$object(
								_List_fromArray(
									[
										_Utils_Tuple2(
										'db',
										$elm$json$Json$Encode$string('Tasks')),
										_Utils_Tuple2(
										'timeEstimate',
										$elm$json$Json$Encode$object(
											_List_fromArray(
												[
													_Utils_Tuple2(
													'$gt',
													$elm$json$Json$Encode$int(0))
												]))),
										_Utils_Tuple2(
										'day',
										$elm$json$Json$Encode$object(
											_List_fromArray(
												[
													_Utils_Tuple2(
													'$regex',
													$elm$json$Json$Encode$string('^\\d'))
												]))),
										_Utils_Tuple2(
										'labelIds',
										$elm$json$Json$Encode$object(
											_List_fromArray(
												[
													_Utils_Tuple2(
													'$not',
													$elm$json$Json$Encode$object(
														_List_fromArray(
															[
																_Utils_Tuple2(
																'$size',
																$elm$json$Json$Encode$int(0))
															])))
												])))
									]))),
							_Utils_Tuple2(
							'fields',
							A2(
								$elm$json$Json$Encode$list,
								$elm$json$Json$Encode$string,
								_List_fromArray(
									['_id', 'done', 'day', 'title', 'parentID', 'labelIds', 'dueDate', 'timeEstimate', 'startDate', 'endDate', 'times', 'taskTime'])))
						]))),
			expect: A2(
				$elm$http$Http$expectJson,
				$author$project$Integrations$Marvin$GotItems,
				$author$project$Porting$toClassicLoose(
					A2(
						$zwilias$json_decode_exploration$Json$Decode$Exploration$at,
						_List_fromArray(
							['docs']),
						$zwilias$json_decode_exploration$Json$Decode$Exploration$list($author$project$Integrations$Marvin$MarvinItem$decodeMarvinItem)))),
			headers: _List_fromArray(
				[
					A2($elm$http$Http$header, 'Accept', 'application/json'),
					A2($author$project$Integrations$Marvin$buildAuthorizationHeader, $author$project$Integrations$Marvin$syncUser, $author$project$Integrations$Marvin$syncPassword)
				]),
			method: 'POST',
			timeout: $elm$core$Maybe$Nothing,
			tracker: $elm$core$Maybe$Nothing,
			url: A2(
				$author$project$Integrations$Marvin$marvinCloudantDatabaseUrl,
				_List_fromArray(
					[$author$project$Integrations$Marvin$syncDatabase, '_find']),
				_List_Nil)
		});
};
var $author$project$Integrations$Marvin$MarvinItem$ConvertedToActivity = function (a) {
	return {$: 'ConvertedToActivity', a: a};
};
var $author$project$Integrations$Marvin$MarvinItem$ConvertedToTaskTriplet = function (a) {
	return {$: 'ConvertedToTaskTriplet', a: a};
};
var $author$project$Activity$Activity$defaults = function (startWith) {
	switch (startWith.$) {
		case 'DillyDally':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$File('shrugging-attempt.svg'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Minutes(0),
					$author$project$SmartTime$Human$Duration$Hours(1)),
				names: _List_fromArray(
					['Nothing', 'Dilly-dally', 'Distracted']),
				taskOptional: true,
				template: startWith
			};
		case 'Apparel':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Hygiene,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(5),
						$author$project$SmartTime$Human$Duration$Hours(3))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$File('shirt.svg'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Appareling', 'Dressing', 'Getting Dressed', 'Dressing Up']),
				taskOptional: true,
				template: startWith
			};
		case 'Messaging':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Communication,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(7),
						$author$project$SmartTime$Human$Duration$Minutes(30))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$File('messaging.svg'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Hours(5)),
				names: _List_fromArray(
					['Messaging', 'Texting', 'Chatting', 'Text Messaging']),
				taskOptional: true,
				template: startWith
			};
		case 'Restroom':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(15),
						$author$project$SmartTime$Human$Duration$Hours(2))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🚽'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Minutes(20),
					$author$project$SmartTime$Human$Duration$Hours(2)),
				names: _List_fromArray(
					['Restroom', 'Toilet', 'WC', 'Washroom', 'Latrine', 'Lavatory', 'Water Closet']),
				taskOptional: true,
				template: startWith
			};
		case 'Grooming':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💈'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Grooming', 'Tending', 'Groom', 'Personal Care']),
				taskOptional: true,
				template: startWith
			};
		case 'Meal':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(40),
						$author$project$SmartTime$Human$Duration$Hours(3))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🍽'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meal', 'Eating', 'Food', 'Lunch', 'Dinner', 'Breakfast']),
				taskOptional: true,
				template: startWith
			};
		case 'Supplements':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💊'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Supplements', 'Pills', 'Medication']),
				taskOptional: true,
				template: startWith
			};
		case 'Workout':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(12),
						$author$project$SmartTime$Human$Duration$Hours(3))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💪'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Workout', 'Working Out', 'Work Out']),
				taskOptional: true,
				template: startWith
			};
		case 'Shower':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(25),
						$author$project$SmartTime$Human$Duration$Hours(18))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🚿'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Shower', 'Bathing', 'Showering']),
				taskOptional: true,
				template: startWith
			};
		case 'Toothbrush':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDEA5'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Toothbrush', 'Teeth', 'Brushing Teeth', 'Teethbrushing']),
				taskOptional: true,
				template: startWith
			};
		case 'Floss':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDDB7'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Floss', 'Flossing']),
				taskOptional: true,
				template: startWith
			};
		case 'Wakeup':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(12),
						$author$project$SmartTime$Human$Duration$Hours(15))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDD71'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Wakeup', 'Waking Up', 'Wakeup Walk']),
				taskOptional: true,
				template: startWith
			};
		case 'Sleep':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$IndefinitelyExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💤'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Sleep', 'Sleeping']),
				taskOptional: true,
				template: startWith
			};
		case 'Plan':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(20),
						$author$project$SmartTime$Human$Duration$Hours(3))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📅'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Plan', 'Planning', 'Plans']),
				taskOptional: true,
				template: startWith
			};
		case 'Configure':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(15),
						$author$project$SmartTime$Human$Duration$Hours(5))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🔧'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Configure', 'Configuring', 'Configuration']),
				taskOptional: true,
				template: startWith
			};
		case 'Email':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(15),
						$author$project$SmartTime$Human$Duration$Hours(4))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📧'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Email', 'E-Mail', 'E-mail', 'Emailing', 'E-mails', 'Emails', 'E-mailing']),
				taskOptional: true,
				template: startWith
			};
		case 'Work':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Hours(1),
						$author$project$SmartTime$Human$Duration$Hours(12))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💼'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(8),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Work', 'Working', 'Listings Work']),
				taskOptional: true,
				template: startWith
			};
		case 'Call':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(35),
						$author$project$SmartTime$Human$Duration$Hours(4))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🗣'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Call', 'Calling', 'Phone Call', 'Phone', 'Phone Calls', 'Calling', 'Voice Call', 'Voice Chat', 'Video Call']),
				taskOptional: true,
				template: startWith
			};
		case 'Chores':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(25),
						$author$project$SmartTime$Human$Duration$Hours(4))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDDF9'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Chore', 'Chores']),
				taskOptional: true,
				template: startWith
			};
		case 'Parents':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Hours(1),
						$author$project$SmartTime$Human$Duration$Hours(12))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('👫'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Parents', 'Parent']),
				taskOptional: true,
				template: startWith
			};
		case 'Prepare':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDDF3'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Minutes(30),
					$author$project$SmartTime$Human$Duration$Hours(24)),
				names: _List_fromArray(
					['Prepare', 'Preparing', 'Preparation']),
				taskOptional: false,
				template: startWith
			};
		case 'Lover':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Hours(2),
						$author$project$SmartTime$Human$Duration$Hours(8))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💋'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Lover', 'S.O.', 'Partner']),
				taskOptional: true,
				template: startWith
			};
		case 'Driving':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Transit,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Hours(1),
						$author$project$SmartTime$Human$Duration$Hours(6))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🚗'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Driving', 'Drive']),
				taskOptional: true,
				template: startWith
			};
		case 'Riding':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(30),
						$author$project$SmartTime$Human$Duration$Hours(8))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💺'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Minutes(30),
					$author$project$SmartTime$Human$Duration$Hours(5)),
				names: _List_fromArray(
					['Riding', 'Ride', 'Passenger']),
				taskOptional: true,
				template: startWith
			};
		case 'SocialMedia':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(20),
						$author$project$SmartTime$Human$Duration$Hours(4))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('👁'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Social Media']),
				taskOptional: true,
				template: startWith
			};
		case 'Pacing':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🚶'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Pacing', 'Pace']),
				taskOptional: true,
				template: startWith
			};
		case 'Sport':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(20),
						$author$project$SmartTime$Human$Duration$Hours(8))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('⛹'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Sport', 'Sports', 'Playing Sports']),
				taskOptional: true,
				template: startWith
			};
		case 'Finance':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(20),
						$author$project$SmartTime$Human$Duration$Hours(16))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💸'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Finance', 'Financial', 'Finances']),
				taskOptional: true,
				template: startWith
			};
		case 'Laundry':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('👕'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Laundry']),
				taskOptional: true,
				template: startWith
			};
		case 'Bedward':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🛏'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Bedward', 'Bedward-bound', 'Going to Bed']),
				taskOptional: true,
				template: startWith
			};
		case 'Browse':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📑'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Browse', 'Browsing']),
				taskOptional: true,
				template: startWith
			};
		case 'Fiction':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🐉'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Fiction', 'Reading Fiction']),
				taskOptional: true,
				template: startWith
			};
		case 'Learning':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(15),
						$author$project$SmartTime$Human$Duration$Hours(10))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDDE0'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Learn', 'Learning', 'Reading', 'Read', 'Book', 'Books']),
				taskOptional: true,
				template: startWith
			};
		case 'BrainTrain':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(30),
						$author$project$SmartTime$Human$Duration$Hours(20))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('💡'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Brain Training', 'Braining', 'Brain Train', 'Mental Math Practice']),
				taskOptional: true,
				template: startWith
			};
		case 'Music':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🎧'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Music', 'Music Listening']),
				taskOptional: true,
				template: startWith
			};
		case 'Create':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(35),
						$author$project$SmartTime$Human$Duration$Hours(16))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🛠'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Create', 'Creating', 'Creation', 'Making']),
				taskOptional: true,
				template: startWith
			};
		case 'Children':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: true,
				icon: $author$project$Activity$Activity$Emoji('🚸'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Children', 'Kids']),
				taskOptional: true,
				template: startWith
			};
		case 'Meeting':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(35),
						$author$project$SmartTime$Human$Duration$Hours(8))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('👥'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meeting', 'Meet', 'Meetings']),
				taskOptional: true,
				template: startWith
			};
		case 'Cinema':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🎟'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Cinema', 'Movies', 'Movie Theatre', 'Movie Theater']),
				taskOptional: true,
				template: startWith
			};
		case 'FilmWatching':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🎞'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Films', 'Film Watching', 'Watching Movies']),
				taskOptional: true,
				template: startWith
			};
		case 'Series':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📺'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Series', 'TV Shows', 'TV Series']),
				taskOptional: true,
				template: startWith
			};
		case 'Broadcast':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📻'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Broadcast']),
				taskOptional: true,
				template: startWith
			};
		case 'Theatre':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🎭'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Theatre', 'Play', 'Play/Musical', 'Drama']),
				taskOptional: true,
				template: startWith
			};
		case 'Shopping':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🛍'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Shopping', 'Shop']),
				taskOptional: true,
				template: startWith
			};
		case 'VideoGaming':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🎮'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Video', 'Video Gaming', 'Gaming']),
				taskOptional: true,
				template: startWith
			};
		case 'Housekeeping':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(20),
						$author$project$SmartTime$Human$Duration$Hours(6))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🏠'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Housekeeping']),
				taskOptional: true,
				template: startWith
			};
		case 'MealPrep':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(45),
						$author$project$SmartTime$Human$Duration$Hours(6))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🍳'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meal Prep', 'Cooking', 'Food making']),
				taskOptional: true,
				template: startWith
			};
		case 'Networking':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDD1D'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Networking']),
				taskOptional: true,
				template: startWith
			};
		case 'Meditate':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDDD8'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meditate', 'Meditation', 'Meditating']),
				taskOptional: true,
				template: startWith
			};
		case 'Homework':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📝'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Homework', 'Schoolwork']),
				taskOptional: true,
				template: startWith
			};
		case 'Flight':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('✈'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Flight', 'Aviation', 'Flying', 'Airport']),
				taskOptional: true,
				template: startWith
			};
		case 'Course':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📔'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Course', 'Courses', 'Classes', 'Class']),
				taskOptional: true,
				template: startWith
			};
		case 'Pet':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🐶'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Pet', 'Pets', 'Pet Care']),
				taskOptional: true,
				template: startWith
			};
		case 'Presentation':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$NeverExcused,
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('📊'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Presentation', 'Presenting', 'Present']),
				taskOptional: true,
				template: startWith
			};
		case 'Projects':
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(40),
						$author$project$SmartTime$Human$Duration$Hours(4))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('🌟'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(2),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Project', 'Projects', 'Project Work', 'Fun Project']),
				taskOptional: true,
				template: startWith
			};
		default:
			return {
				backgroundable: false,
				category: $author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: $author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						$author$project$SmartTime$Human$Duration$Minutes(10),
						$author$project$SmartTime$Human$Duration$Hours(3))),
				externalIDs: $elm$core$Dict$empty,
				hidden: false,
				icon: $author$project$Activity$Activity$Emoji('\uD83E\uDD13'),
				maxTime: _Utils_Tuple2(
					$author$project$SmartTime$Human$Duration$Hours(6),
					$author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Research', 'Researching', 'Looking Stuff Up', 'Evaluating']),
				taskOptional: true,
				template: startWith
			};
	}
};
var $elm_community$intdict$IntDict$map = F2(
	function (f, dict) {
		switch (dict.$) {
			case 'Empty':
				return $elm_community$intdict$IntDict$empty;
			case 'Leaf':
				var l = dict.a;
				return A2(
					$elm_community$intdict$IntDict$leaf,
					l.key,
					A2(f, l.key, l.value));
			default:
				var i = dict.a;
				return A3(
					$elm_community$intdict$IntDict$inner,
					i.prefix,
					A2($elm_community$intdict$IntDict$map, f, i.left),
					A2($elm_community$intdict$IntDict$map, f, i.right));
		}
	});
var $author$project$Activity$Template$Research = {$: 'Research'};
var $author$project$Activity$Template$stockActivities = _List_fromArray(
	[$author$project$Activity$Template$DillyDally, $author$project$Activity$Template$Apparel, $author$project$Activity$Template$Messaging, $author$project$Activity$Template$Restroom, $author$project$Activity$Template$Grooming, $author$project$Activity$Template$Meal, $author$project$Activity$Template$Supplements, $author$project$Activity$Template$Workout, $author$project$Activity$Template$Shower, $author$project$Activity$Template$Toothbrush, $author$project$Activity$Template$Floss, $author$project$Activity$Template$Wakeup, $author$project$Activity$Template$Sleep, $author$project$Activity$Template$Plan, $author$project$Activity$Template$Configure, $author$project$Activity$Template$Email, $author$project$Activity$Template$Work, $author$project$Activity$Template$Call, $author$project$Activity$Template$Chores, $author$project$Activity$Template$Parents, $author$project$Activity$Template$Prepare, $author$project$Activity$Template$Lover, $author$project$Activity$Template$Driving, $author$project$Activity$Template$Riding, $author$project$Activity$Template$SocialMedia, $author$project$Activity$Template$Pacing, $author$project$Activity$Template$Sport, $author$project$Activity$Template$Finance, $author$project$Activity$Template$Laundry, $author$project$Activity$Template$Bedward, $author$project$Activity$Template$Browse, $author$project$Activity$Template$Fiction, $author$project$Activity$Template$Learning, $author$project$Activity$Template$BrainTrain, $author$project$Activity$Template$Music, $author$project$Activity$Template$Create, $author$project$Activity$Template$Children, $author$project$Activity$Template$Meeting, $author$project$Activity$Template$Cinema, $author$project$Activity$Template$FilmWatching, $author$project$Activity$Template$Series, $author$project$Activity$Template$Broadcast, $author$project$Activity$Template$Theatre, $author$project$Activity$Template$Shopping, $author$project$Activity$Template$VideoGaming, $author$project$Activity$Template$Housekeeping, $author$project$Activity$Template$MealPrep, $author$project$Activity$Template$Networking, $author$project$Activity$Template$Meditate, $author$project$Activity$Template$Homework, $author$project$Activity$Template$Flight, $author$project$Activity$Template$Course, $author$project$Activity$Template$Pet, $author$project$Activity$Template$Presentation, $author$project$Activity$Template$Projects, $author$project$Activity$Template$Research]);
var $elm_community$intdict$IntDict$Disjunct = F2(
	function (a, b) {
		return {$: 'Disjunct', a: a, b: b};
	});
var $elm_community$intdict$IntDict$Left = {$: 'Left'};
var $elm_community$intdict$IntDict$Parent = F2(
	function (a, b) {
		return {$: 'Parent', a: a, b: b};
	});
var $elm_community$intdict$IntDict$Right = {$: 'Right'};
var $elm_community$intdict$IntDict$SamePrefix = {$: 'SamePrefix'};
var $elm_community$intdict$IntDict$combineBits = F3(
	function (a, b, mask) {
		return (a & (~mask)) | (b & mask);
	});
var $elm_community$intdict$IntDict$mostSignificantBranchingBit = F2(
	function (a, b) {
		return (_Utils_eq(a, $elm_community$intdict$IntDict$signBit) || _Utils_eq(b, $elm_community$intdict$IntDict$signBit)) ? $elm_community$intdict$IntDict$signBit : A2($elm$core$Basics$max, a, b);
	});
var $elm_community$intdict$IntDict$determineBranchRelation = F2(
	function (l, r) {
		var rp = r.prefix;
		var lp = l.prefix;
		var mask = $elm_community$intdict$IntDict$highestBitSet(
			A2($elm_community$intdict$IntDict$mostSignificantBranchingBit, lp.branchingBit, rp.branchingBit));
		var modifiedRightPrefix = A3($elm_community$intdict$IntDict$combineBits, rp.prefixBits, ~lp.prefixBits, mask);
		var prefix = A2($elm_community$intdict$IntDict$lcp, lp.prefixBits, modifiedRightPrefix);
		var childEdge = F2(
			function (branchPrefix, c) {
				return A2($elm_community$intdict$IntDict$isBranchingBitSet, branchPrefix, c.prefix.prefixBits) ? $elm_community$intdict$IntDict$Right : $elm_community$intdict$IntDict$Left;
			});
		return _Utils_eq(lp, rp) ? $elm_community$intdict$IntDict$SamePrefix : (_Utils_eq(prefix, lp) ? A2(
			$elm_community$intdict$IntDict$Parent,
			$elm_community$intdict$IntDict$Left,
			A2(childEdge, l.prefix, r)) : (_Utils_eq(prefix, rp) ? A2(
			$elm_community$intdict$IntDict$Parent,
			$elm_community$intdict$IntDict$Right,
			A2(childEdge, r.prefix, l)) : A2(
			$elm_community$intdict$IntDict$Disjunct,
			prefix,
			A2(childEdge, prefix, l))));
	});
var $elm_community$intdict$IntDict$uniteWith = F3(
	function (merger, l, r) {
		var mergeWith = F3(
			function (key, left, right) {
				var _v14 = _Utils_Tuple2(left, right);
				if (_v14.a.$ === 'Just') {
					if (_v14.b.$ === 'Just') {
						var l2 = _v14.a.a;
						var r2 = _v14.b.a;
						return $elm$core$Maybe$Just(
							A3(merger, key, l2, r2));
					} else {
						return left;
					}
				} else {
					if (_v14.b.$ === 'Just') {
						return right;
					} else {
						var _v15 = _v14.a;
						var _v16 = _v14.b;
						return $elm$core$Maybe$Nothing;
					}
				}
			});
		var _v0 = _Utils_Tuple2(l, r);
		_v0$1:
		while (true) {
			_v0$2:
			while (true) {
				switch (_v0.a.$) {
					case 'Empty':
						var _v1 = _v0.a;
						return r;
					case 'Leaf':
						switch (_v0.b.$) {
							case 'Empty':
								break _v0$1;
							case 'Leaf':
								break _v0$2;
							default:
								break _v0$2;
						}
					default:
						switch (_v0.b.$) {
							case 'Empty':
								break _v0$1;
							case 'Leaf':
								var r2 = _v0.b.a;
								return A3(
									$elm_community$intdict$IntDict$update,
									r2.key,
									function (l_) {
										return A3(
											mergeWith,
											r2.key,
											l_,
											$elm$core$Maybe$Just(r2.value));
									},
									l);
							default:
								var il = _v0.a.a;
								var ir = _v0.b.a;
								var _v3 = A2($elm_community$intdict$IntDict$determineBranchRelation, il, ir);
								switch (_v3.$) {
									case 'SamePrefix':
										return A3(
											$elm_community$intdict$IntDict$inner,
											il.prefix,
											A3($elm_community$intdict$IntDict$uniteWith, merger, il.left, ir.left),
											A3($elm_community$intdict$IntDict$uniteWith, merger, il.right, ir.right));
									case 'Parent':
										if (_v3.a.$ === 'Left') {
											if (_v3.b.$ === 'Right') {
												var _v4 = _v3.a;
												var _v5 = _v3.b;
												return A3(
													$elm_community$intdict$IntDict$inner,
													il.prefix,
													il.left,
													A3($elm_community$intdict$IntDict$uniteWith, merger, il.right, r));
											} else {
												var _v8 = _v3.a;
												var _v9 = _v3.b;
												return A3(
													$elm_community$intdict$IntDict$inner,
													il.prefix,
													A3($elm_community$intdict$IntDict$uniteWith, merger, il.left, r),
													il.right);
											}
										} else {
											if (_v3.b.$ === 'Right') {
												var _v6 = _v3.a;
												var _v7 = _v3.b;
												return A3(
													$elm_community$intdict$IntDict$inner,
													ir.prefix,
													ir.left,
													A3($elm_community$intdict$IntDict$uniteWith, merger, l, ir.right));
											} else {
												var _v10 = _v3.a;
												var _v11 = _v3.b;
												return A3(
													$elm_community$intdict$IntDict$inner,
													ir.prefix,
													A3($elm_community$intdict$IntDict$uniteWith, merger, l, ir.left),
													ir.right);
											}
										}
									default:
										if (_v3.b.$ === 'Left') {
											var parentPrefix = _v3.a;
											var _v12 = _v3.b;
											return A3($elm_community$intdict$IntDict$inner, parentPrefix, l, r);
										} else {
											var parentPrefix = _v3.a;
											var _v13 = _v3.b;
											return A3($elm_community$intdict$IntDict$inner, parentPrefix, r, l);
										}
								}
						}
				}
			}
			var l2 = _v0.a.a;
			return A3(
				$elm_community$intdict$IntDict$update,
				l2.key,
				function (r_) {
					return A3(
						mergeWith,
						l2.key,
						$elm$core$Maybe$Just(l2.value),
						r_);
				},
				r);
		}
		var _v2 = _v0.b;
		return l;
	});
var $elm_community$intdict$IntDict$union = $elm_community$intdict$IntDict$uniteWith(
	F3(
		function (key, old, _new) {
			return old;
		}));
var $author$project$Activity$Activity$withTemplate = function (delta) {
	var over = F2(
		function (b, s) {
			return A2($elm$core$Maybe$withDefault, b, s);
		});
	var base = $author$project$Activity$Activity$defaults(delta.template);
	return {
		backgroundable: A2(over, base.backgroundable, delta.backgroundable),
		category: A2(over, base.category, delta.category),
		evidence: A2($elm$core$List$append, base.evidence, delta.evidence),
		excusable: A2(over, base.excusable, delta.excusable),
		externalIDs: delta.externalIDs,
		hidden: A2(over, base.hidden, delta.hidden),
		icon: A2(over, base.icon, delta.icon),
		maxTime: A2(over, base.maxTime, delta.maxTime),
		names: A2(over, base.names, delta.names),
		taskOptional: A2(over, base.taskOptional, delta.taskOptional),
		template: delta.template
	};
};
var $author$project$Activity$Activity$allActivities = function (stored) {
	var stock = $elm_community$intdict$IntDict$fromList(
		A2(
			$elm$core$List$indexedMap,
			$elm$core$Tuple$pair,
			A2($elm$core$List$map, $author$project$Activity$Activity$defaults, $author$project$Activity$Template$stockActivities)));
	var customized = A2(
		$elm_community$intdict$IntDict$map,
		F2(
			function (_v0, v) {
				return $author$project$Activity$Activity$withTemplate(v);
			}),
		stored);
	return A2($elm_community$intdict$IntDict$union, customized, stock);
};
var $elm_community$intdict$IntDict$foldl = F3(
	function (f, acc, dict) {
		foldl:
		while (true) {
			switch (dict.$) {
				case 'Empty':
					return acc;
				case 'Leaf':
					var l = dict.a;
					return A3(f, l.key, l.value, acc);
				default:
					var i = dict.a;
					var $temp$f = f,
						$temp$acc = A3($elm_community$intdict$IntDict$foldl, f, acc, i.left),
						$temp$dict = i.right;
					f = $temp$f;
					acc = $temp$acc;
					dict = $temp$dict;
					continue foldl;
			}
		}
	});
var $elm_community$intdict$IntDict$filter = F2(
	function (predicate, dict) {
		var add = F3(
			function (k, v, d) {
				return A2(predicate, k, v) ? A3($elm_community$intdict$IntDict$insert, k, v, d) : d;
			});
		return A3($elm_community$intdict$IntDict$foldl, add, $elm_community$intdict$IntDict$empty, dict);
	});
var $elm$core$Debug$log = _Debug_log;
var $elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			$elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var $author$project$ID$read = function (_v0) {
	var _int = _v0.a;
	return _int;
};
var $author$project$ID$tag = function (_int) {
	return $author$project$ID$ID(_int);
};
var $author$project$Integrations$Marvin$MarvinItem$projectToDocketActivity = F2(
	function (activities, marvinCategory) {
		var nameMatch = F2(
			function (key, value) {
				return A2($elm$core$List$member, marvinCategory.title, value.names);
			});
		var matchingActivities = A2(
			$elm$core$Debug$log,
			'matching activity names for ' + marvinCategory.title,
			A2(
				$elm_community$intdict$IntDict$filter,
				nameMatch,
				$author$project$Activity$Activity$allActivities(activities)));
		var firstActivityMatch = $elm$core$List$head(
			$elm_community$intdict$IntDict$toList(matchingActivities));
		var toCustomizations = function () {
			if (firstActivityMatch.$ === 'Just') {
				var _v2 = firstActivityMatch.a;
				var key = _v2.a;
				var activity = _v2.b;
				return $elm$core$Maybe$Just(
					{
						backgroundable: $elm$core$Maybe$Nothing,
						category: $elm$core$Maybe$Nothing,
						evidence: _List_Nil,
						excusable: $elm$core$Maybe$Nothing,
						externalIDs: A3($elm$core$Dict$insert, 'marvinCategory', marvinCategory.id, activity.externalIDs),
						hidden: $elm$core$Maybe$Nothing,
						icon: $elm$core$Maybe$Nothing,
						id: $author$project$ID$tag(key),
						maxTime: $elm$core$Maybe$Nothing,
						names: $elm$core$Maybe$Nothing,
						taskOptional: $elm$core$Maybe$Nothing,
						template: activity.template
					});
			} else {
				return $elm$core$Maybe$Nothing;
			}
		}();
		if (toCustomizations.$ === 'Just') {
			var customizedActivity = toCustomizations.a;
			return A3(
				$elm_community$intdict$IntDict$insert,
				$author$project$ID$read(customizedActivity.id),
				customizedActivity,
				activities);
		} else {
			return activities;
		}
	});
var $author$project$SmartTime$Human$Clock$endOfDay = $author$project$SmartTime$Duration$aDay;
var $author$project$SmartTime$Duration$isPositive = function (_v0) {
	var _int = _v0.a;
	return _int > 0;
};
var $author$project$Task$Class$newClassSkel = F2(
	function (givenTitle, newID) {
		return {activity: $elm$core$Maybe$Nothing, completionUnits: $author$project$Task$Progress$Percent, defaultExternalDeadline: _List_Nil, defaultFinishBy: _List_Nil, defaultRelevanceEnds: _List_Nil, defaultRelevanceStarts: _List_Nil, defaultStartBy: _List_Nil, id: newID, importance: 1, maxEffort: $author$project$SmartTime$Duration$zero, minEffort: $author$project$SmartTime$Duration$zero, predictedEffort: $author$project$SmartTime$Duration$zero, title: givenTitle};
	});
var $author$project$Task$Instance$newInstanceSkel = F2(
	function (newID, _class) {
		return {_class: _class.id, completion: 0, externalDeadline: $elm$core$Maybe$Nothing, finishBy: $elm$core$Maybe$Nothing, id: newID, memberOfSeries: $elm$core$Maybe$Nothing, plannedSessions: _List_Nil, relevanceEnds: $elm$core$Maybe$Nothing, relevanceStarts: $elm$core$Maybe$Nothing, startBy: $elm$core$Maybe$Nothing};
	});
var $author$project$Task$Entry$FollowerParent = F2(
	function (properties, children) {
		return {children: children, properties: properties};
	});
var $author$project$Task$Entry$LeaderIsHere = function (a) {
	return {$: 'LeaderIsHere', a: a};
};
var $author$project$Task$Entry$LeaderParent = F3(
	function (properties, recurrenceRules, children) {
		return {children: children, properties: properties, recurrenceRules: recurrenceRules};
	});
var $author$project$Task$Class$ParentProperties = function (title) {
	return {title: title};
};
var $author$project$Task$Entry$Singleton = function (a) {
	return {$: 'Singleton', a: a};
};
var $author$project$Task$Entry$WrapperParent = F2(
	function (properties, children) {
		return {children: children, properties: properties};
	});
var $author$project$Task$Entry$newRootEntry = function (classID) {
	var parentProps = $author$project$Task$Class$ParentProperties(
		$elm$core$Maybe$Just('none'));
	var follower = A2(
		$author$project$Task$Entry$FollowerParent,
		parentProps,
		$mgold$elm_nonempty_list$List$Nonempty$fromElement(
			$author$project$Task$Entry$Singleton(classID)));
	var leader = A3(
		$author$project$Task$Entry$LeaderParent,
		parentProps,
		$elm$core$Maybe$Nothing,
		$mgold$elm_nonempty_list$List$Nonempty$fromElement(follower));
	var outsideWrap = A2(
		$author$project$Task$Entry$WrapperParent,
		parentProps,
		$mgold$elm_nonempty_list$List$Nonempty$fromElement(
			$author$project$Task$Entry$LeaderIsHere(leader)));
	return outsideWrap;
};
var $elm_community$maybe_extra$Maybe$Extra$or = F2(
	function (ma, mb) {
		if (ma.$ === 'Nothing') {
			return mb;
		} else {
			return ma;
		}
	});
var $author$project$Integrations$Marvin$MarvinItem$toDocketTaskNaive = F3(
	function (classCounter, activities, marvinItem) {
		var whichActivity = function () {
			var _v6 = _Utils_Tuple2(marvinItem.parentId, marvinItem.labelIds);
			if ((_v6.a.$ === 'Just') && (!_v6.b.b)) {
				var someParent = _v6.a.a;
				var getMarvinID = function (_v8) {
					var intID = _v8.a;
					var activity = _v8.b;
					return _Utils_Tuple2(
						$author$project$ID$tag(intID),
						A2($elm$core$Dict$get, 'marvinCategory', activity.externalIDs));
				};
				var activitiesWithMarvinCategories = A2(
					$elm$core$List$map,
					getMarvinID,
					$elm_community$intdict$IntDict$toList(
						$author$project$Activity$Activity$allActivities(activities)));
				var matchingActivities = A2(
					$elm$core$List$filterMap,
					function (_v7) {
						var id = _v7.a;
						var actCat = _v7.b;
						return _Utils_eq(
							A2($elm$core$Maybe$withDefault, 'nope', actCat),
							someParent) ? $elm$core$Maybe$Just(id) : $elm$core$Maybe$Nothing;
					},
					activitiesWithMarvinCategories);
				return $elm$core$List$head(matchingActivities);
			} else {
				var labels = _v6.b;
				var getMarvinID = function (_v11) {
					var intID = _v11.a;
					var activity = _v11.b;
					return _Utils_Tuple2(
						$author$project$ID$tag(intID),
						A2($elm$core$Dict$get, 'marvinLabel', activity.externalIDs));
				};
				var activitiesWithMarvinLabels = A2(
					$elm$core$List$map,
					getMarvinID,
					$elm_community$intdict$IntDict$toList(
						$author$project$Activity$Activity$allActivities(activities)));
				var matchingActivities = A2(
					$elm$core$List$filterMap,
					function (_v9) {
						var id = _v9.a;
						var associatedLabelMaybe = _v9.b;
						if (associatedLabelMaybe.$ === 'Just') {
							var associatedLabel = associatedLabelMaybe.a;
							return A2($elm$core$List$member, associatedLabel, labels) ? $elm$core$Maybe$Just(id) : $elm$core$Maybe$Nothing;
						} else {
							return $elm$core$Maybe$Nothing;
						}
					},
					activitiesWithMarvinLabels);
				return $elm$core$List$head(matchingActivities);
			}
		}();
		var plannedSessionList = function () {
			var _v0 = _Utils_Tuple2(
				A2($elm$core$Maybe$map, $author$project$SmartTime$Duration$isPositive, marvinItem.timeEstimate),
				marvinItem.timeEstimate);
			_v0$2:
			while (true) {
				if (_v0.a.$ === 'Just') {
					if (_v0.a.a) {
						if (_v0.b.$ === 'Just') {
							var plannedDuration = _v0.b.a;
							var _v1 = _Utils_Tuple2(marvinItem.taskTime, marvinItem.day);
							if (_v1.a.$ === 'Just') {
								if (_v1.b.$ === 'Just') {
									var plannedTime = _v1.a.a;
									var plannedDay = _v1.b.a;
									return $elm$core$List$singleton(
										_Utils_Tuple2(
											$author$project$SmartTime$Human$Moment$Floating(
												_Utils_Tuple2(plannedDay, plannedTime)),
											plannedDuration));
								} else {
									var _v2 = _v1.b;
									return A2($elm$core$Debug$log, 'no planned day for ' + marvinItem.title, _List_Nil);
								}
							} else {
								if (_v1.b.$ === 'Just') {
									var _v3 = _v1.a;
									var plannedDay = _v1.b.a;
									return A3(
										$elm$core$Debug$log,
										'no tasktime for ' + (marvinItem.title + ', assuming end of day'),
										$elm$core$List$singleton,
										_Utils_Tuple2(
											$author$project$SmartTime$Human$Moment$Floating(
												_Utils_Tuple2(plannedDay, $author$project$SmartTime$Human$Clock$endOfDay)),
											plannedDuration));
								} else {
									var _v4 = _v1.a;
									var _v5 = _v1.b;
									return A2($elm$core$Debug$log, 'no tasktime or planned day for ' + marvinItem.title, _List_Nil);
								}
							}
						} else {
							break _v0$2;
						}
					} else {
						return A2($elm$core$Debug$log, 'no time estimate for ' + marvinItem.title, _List_Nil);
					}
				} else {
					break _v0$2;
				}
			}
			return _List_Nil;
		}();
		var classID = classCounter + 1;
		var entry = $author$project$Task$Entry$newRootEntry(classID);
		var classBase = A2($author$project$Task$Class$newClassSkel, marvinItem.title, classID);
		var finalClass = _Utils_update(
			classBase,
			{
				activity: whichActivity,
				importance: marvinItem.isStarred,
				predictedEffort: A2($elm$core$Maybe$withDefault, $author$project$SmartTime$Duration$zero, marvinItem.timeEstimate)
			});
		var instanceBase = A2($author$project$Task$Instance$newInstanceSkel, classCounter, finalClass);
		var finalInstance = _Utils_update(
			instanceBase,
			{
				completion: marvinItem.done ? 100 : 0,
				externalDeadline: A2($elm$core$Maybe$map, $author$project$SmartTime$Human$Moment$DateOnly, marvinItem.dueDate),
				finishBy: A2(
					$elm_community$maybe_extra$Maybe$Extra$or,
					A2($elm$core$Maybe$map, $author$project$SmartTime$Human$Moment$DateOnly, marvinItem.endDate),
					A2($elm$core$Maybe$map, $author$project$SmartTime$Human$Moment$DateOnly, marvinItem.day)),
				plannedSessions: plannedSessionList,
				startBy: A2($elm$core$Maybe$map, $author$project$SmartTime$Human$Moment$DateOnly, marvinItem.startDate)
			});
		return {_class: finalClass, entry: entry, instance: finalInstance};
	});
var $author$project$Integrations$Marvin$MarvinItem$toDocketItem = F3(
	function (classCounter, profile, marvinItem) {
		var _v0 = marvinItem.type_;
		switch (_v0.$) {
			case 'Task':
				return $author$project$Integrations$Marvin$MarvinItem$ConvertedToTaskTriplet(
					A3($author$project$Integrations$Marvin$MarvinItem$toDocketTaskNaive, classCounter, profile.activities, marvinItem));
			case 'Project':
				return $author$project$Integrations$Marvin$MarvinItem$ConvertedToTaskTriplet(
					A3($author$project$Integrations$Marvin$MarvinItem$toDocketTaskNaive, classCounter, profile.activities, marvinItem));
			default:
				return $author$project$Integrations$Marvin$MarvinItem$ConvertedToActivity(
					A2($author$project$Integrations$Marvin$MarvinItem$projectToDocketActivity, profile.activities, marvinItem));
		}
	});
var $author$project$Integrations$Marvin$importItems = F3(
	function (classCounter, profile, itemList) {
		var toNumberedDocketTask = function (index) {
			return A2($author$project$Integrations$Marvin$MarvinItem$toDocketItem, classCounter + index, profile);
		};
		var tasksOnly = function (outputItem) {
			if (outputItem.$ === 'ConvertedToTaskTriplet') {
				var taskitem = outputItem.a;
				return $elm$core$Maybe$Just(taskitem);
			} else {
				return $elm$core$Maybe$Nothing;
			}
		};
		var bigList = A2($elm$core$List$indexedMap, toNumberedDocketTask, itemList);
		var bigTaskList = A2($elm$core$List$filterMap, tasksOnly, bigList);
		var activitiesOnly = function (outputItem) {
			if (outputItem.$ === 'ConvertedToActivity') {
				var activitystore = outputItem.a;
				return $elm$core$Maybe$Just(activitystore);
			} else {
				return $elm$core$Maybe$Nothing;
			}
		};
		var finalActivities = A3(
			$elm$core$List$foldl,
			$elm_community$intdict$IntDict$union,
			$elm_community$intdict$IntDict$empty,
			A2($elm$core$List$filterMap, activitiesOnly, bigList));
		return _Utils_Tuple2(
			{
				taskClasses: $elm_community$intdict$IntDict$fromList(
					A2(
						$elm$core$List$map,
						function (i) {
							return _Utils_Tuple2(i._class.id, i._class);
						},
						bigTaskList)),
				taskEntries: A2(
					$elm$core$List$map,
					function ($) {
						return $.entry;
					},
					bigTaskList),
				taskInstances: $elm_community$intdict$IntDict$fromList(
					A2(
						$elm$core$List$map,
						function (i) {
							return _Utils_Tuple2(i.instance.id, i.instance);
						},
						bigTaskList))
			},
			finalActivities);
	});
var $elm$core$String$toLower = _String_toLower;
var $elm$core$String$trim = _String_trim;
var $author$project$Integrations$Marvin$MarvinItem$labelToDocketActivity = F2(
	function (activities, label) {
		var nameMatch = F2(
			function (key, value) {
				return A2($elm$core$List$member, label.title, value.names) || A2(
					$elm$core$List$member,
					$elm$core$String$toLower(label.title),
					A2(
						$elm$core$List$map,
						A2($elm$core$Basics$composeL, $elm$core$String$toLower, $elm$core$String$trim),
						value.names));
			});
		var matchingActivities = A2(
			$elm$core$Debug$log,
			'matching activity names for ' + label.title,
			A2(
				$elm_community$intdict$IntDict$filter,
				nameMatch,
				$author$project$Activity$Activity$allActivities(activities)));
		var firstActivityMatch = $elm$core$List$head(
			$elm_community$intdict$IntDict$toList(matchingActivities));
		var toCustomizations = function () {
			if (firstActivityMatch.$ === 'Just') {
				var _v2 = firstActivityMatch.a;
				var key = _v2.a;
				var activity = _v2.b;
				return $elm$core$Maybe$Just(
					{
						backgroundable: $elm$core$Maybe$Nothing,
						category: $elm$core$Maybe$Nothing,
						evidence: _List_Nil,
						excusable: $elm$core$Maybe$Nothing,
						externalIDs: A3($elm$core$Dict$insert, 'marvinLabel', label.id, activity.externalIDs),
						hidden: $elm$core$Maybe$Nothing,
						icon: $elm$core$Maybe$Nothing,
						id: $author$project$ID$tag(key),
						maxTime: $elm$core$Maybe$Nothing,
						names: $elm$core$Maybe$Nothing,
						taskOptional: $elm$core$Maybe$Nothing,
						template: activity.template
					});
			} else {
				return $elm$core$Maybe$Nothing;
			}
		}();
		if (toCustomizations.$ === 'Just') {
			var customizedActivity = toCustomizations.a;
			return A3(
				$elm_community$intdict$IntDict$insert,
				$author$project$ID$read(customizedActivity.id),
				customizedActivity,
				activities);
		} else {
			return activities;
		}
	});
var $author$project$Integrations$Marvin$importLabels = F2(
	function (profile, labels) {
		var activities = A2(
			$elm$core$List$map,
			$author$project$Integrations$Marvin$MarvinItem$labelToDocketActivity(profile.activities),
			labels);
		var finalActivities = A3($elm$core$List$foldl, $elm_community$intdict$IntDict$union, $elm_community$intdict$IntDict$empty, activities);
		return finalActivities;
	});
var $elm$core$Debug$toString = _Debug_toString;
var $author$project$Integrations$Marvin$handle = F3(
	function (classCounter, profile, response) {
		switch (response.$) {
			case 'TestResult':
				var result = response.a;
				if (result.$ === 'Ok') {
					var serversays = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						serversays,
						$elm$core$Platform$Cmd$none);
				} else {
					var err = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						$author$project$Integrations$Marvin$describeError(err),
						$elm$core$Platform$Cmd$none);
				}
			case 'AuthResult':
				var result = response.a;
				if (result.$ === 'Ok') {
					var serversays = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						serversays,
						$elm$core$Platform$Cmd$none);
				} else {
					var err = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						$author$project$Integrations$Marvin$describeError(err),
						$elm$core$Platform$Cmd$none);
				}
			case 'GotItems':
				var result = response.a;
				if (result.$ === 'Ok') {
					var itemList = result.a;
					var _v4 = A3($author$project$Integrations$Marvin$importItems, classCounter, profile, itemList);
					var newTriplets = _v4.a;
					var newActivities = _v4.b;
					return _Utils_Tuple3(
						_Utils_Tuple2(
							newTriplets,
							$elm$core$Maybe$Just(newActivities)),
						$elm$core$Debug$toString(itemList),
						$elm$core$Platform$Cmd$none);
				} else {
					var err = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						$author$project$Integrations$Marvin$describeError(err),
						$elm$core$Platform$Cmd$none);
				}
			case 'GotLabels':
				var result = response.a;
				if (result.$ === 'Ok') {
					var labelList = result.a;
					var newActivities = A2($author$project$Integrations$Marvin$importLabels, profile, labelList);
					return _Utils_Tuple3(
						_Utils_Tuple2(
							$author$project$Integrations$Marvin$blankTriplet,
							$elm$core$Maybe$Just(newActivities)),
						$elm$core$Debug$toString(labelList),
						$author$project$Integrations$Marvin$getTasks($author$project$Integrations$Marvin$partialAccessToken));
				} else {
					var err = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						$author$project$Integrations$Marvin$describeError(err),
						$elm$core$Platform$Cmd$none);
				}
			default:
				var result = response.a;
				if (result.$ === 'Ok') {
					var timeBlockList = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						$elm$core$Debug$toString(timeBlockList),
						$elm$core$Platform$Cmd$none);
				} else {
					var err = result.a;
					return _Utils_Tuple3(
						_Utils_Tuple2($author$project$Integrations$Marvin$blankTriplet, $elm$core$Maybe$Nothing),
						$author$project$Integrations$Marvin$describeError(err),
						$elm$core$Platform$Cmd$none);
				}
		}
	});
var $author$project$Incubator$Todoist$describeError = function (error) {
	switch (error.$) {
		case 'BadUrl':
			var msg = error.a;
			return 'For some reason we were told the URL is bad. This should never happen, it\'s a perfectly tested working URL! The error: ' + msg;
		case 'Timeout':
			return 'Timed out. Try again later?';
		case 'NetworkError':
			return 'Couldn\'t get on the network. Are you offline?';
		case 'BadStatus':
			var status = error.a;
			switch (status) {
				case 400:
					return '400 Bad Request: The request was incorrect.';
				case 401:
					return '401 Unauthorized: Authentication is required, and has failed, or has not yet been provided. Maybe your API credentials are messed up?';
				case 403:
					return '403 Forbidden: The request was valid, but for something that is forbidden.';
				case 404:
					return '404 Not Found! That should never happen, because I definitely used the right URL. Is your system or proxy blocking or messing with internet requests? Is it many years in future, where Todoist API v8 has been deprecated, obseleted, and then discontinued? Or maybe it\'s far enough in the future that Todoist doesn\'t exist anymore but for some reason you\'re still using this library?';
				case 429:
					return '429 Too Many Requests: Slow down, cowboy! Check out the Todoist API Docs for Usage Limits. Maybe try batching more requests into one?';
				case 500:
					return '500 Internal Server Error: Not my fault! Todoist must be having a bad day.';
				case 502:
					return '502 Bad Gateway: I was trying to reach the Todoist server but I got stopped along the way. If you\'re definitely connected, it\'s probably a temporary hiccup on their side -- but if you see this a lot, check that your DNS is resolving (try todoist.com) and any proxy setup you have is working.';
				case 503:
					return '503 Service Unavailable: Not my fault! Todoist must be bogged down today, or perhaps experiencing a DDoS attack. :O';
				default:
					var other = status;
					return 'Got HTTP Error code ' + ($elm$core$String$fromInt(other) + ', not sure what that means in this case. Sorry!');
			}
		default:
			var string = error.a;
			return 'I successfully talked with Todoist servers, but the response had some weird parts I was never trained for. Either Todoist changed something recently, or you\'ve found a weird edge case the developer didn\'t know about. Either way, please report this! \n' + string;
	}
};
var $elm$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var left = dict.d;
				var right = dict.e;
				var $temp$n = A2($elm$core$Dict$sizeHelp, n + 1, right),
					$temp$dict = left;
				n = $temp$n;
				dict = $temp$dict;
				continue sizeHelp;
			}
		}
	});
var $elm$core$Dict$size = function (dict) {
	return A2($elm$core$Dict$sizeHelp, 0, dict);
};
var $elm$core$Set$size = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$size(dict);
};
var $author$project$Integrations$Todoist$describeSuccess = function (report) {
	var _v0 = _Utils_Tuple3(
		$elm$core$Set$size(report.projectsAdded),
		$elm$core$Set$size(report.projectsDeleted),
		$elm$core$Set$size(report.projectsChanged));
	var projectsAdded = _v0.a;
	var projectsDeleted = _v0.b;
	var projectsModified = _v0.c;
	var totalProjectChanges = (projectsAdded + projectsDeleted) + projectsModified;
	var projectReport = (totalProjectChanges > 0) ? $elm$core$Maybe$Just(
		$elm$core$String$fromInt(totalProjectChanges) + (' projects updated (' + ($elm$core$String$fromInt(projectsAdded) + (' created, ' + ($elm$core$String$fromInt(projectsDeleted) + ' deleted)'))))) : $elm$core$Maybe$Nothing;
	var _v1 = _Utils_Tuple3(
		$elm$core$Set$size(report.itemsAdded),
		$elm$core$Set$size(report.itemsDeleted),
		$elm$core$Set$size(report.itemsChanged));
	var itemsAdded = _v1.a;
	var itemsDeleted = _v1.b;
	var itemsModified = _v1.c;
	var totalItemChanges = (itemsAdded + itemsDeleted) + itemsModified;
	var itemReport = (totalItemChanges > 0) ? $elm$core$Maybe$Just(
		$elm$core$String$fromInt(totalItemChanges) + (' items updated (' + ($elm$core$String$fromInt(itemsAdded) + (' created, ' + ($elm$core$String$fromInt(itemsDeleted) + ' deleted)'))))) : $elm$core$Maybe$Nothing;
	var reportList = A2(
		$elm$core$List$filterMap,
		$elm$core$Basics$identity,
		_List_fromArray(
			[itemReport, projectReport]));
	return 'Todoist sync complete: ' + ((!(totalProjectChanges + totalItemChanges)) ? 'Nothing changed since last sync.' : ($elm$core$String$concat(
		A2($elm$core$List$intersperse, ' and ', reportList)) + '.'));
};
var $author$project$Incubator$IntDict$Extra$filterMap = F2(
	function (f, dict) {
		return A3(
			$elm_community$intdict$IntDict$foldl,
			F3(
				function (k, v, acc) {
					var _v0 = A2(f, k, v);
					if (_v0.$ === 'Just') {
						var newVal = _v0.a;
						return A3($elm_community$intdict$IntDict$insert, k, newVal, acc);
					} else {
						return acc;
					}
				}),
			$elm_community$intdict$IntDict$empty,
			dict);
	});
var $author$project$Incubator$IntDict$Extra$mapValues = F2(
	function (func, dict) {
		return A2(
			$elm_community$intdict$IntDict$map,
			F2(
				function (_v0, v) {
					return func(v);
				}),
			dict);
	});
var $elm_community$intdict$IntDict$values = function (dict) {
	return A3(
		$elm_community$intdict$IntDict$foldr,
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Integrations$Todoist$filterActivityProjects = F2(
	function (projects, activities) {
		var matchToID = F3(
			function (nameToTest, activityID, nameList) {
				return A2($elm$core$List$member, nameToTest, nameList) ? $elm$core$Maybe$Just(
					$author$project$ID$tag(activityID)) : $elm$core$Maybe$Nothing;
			});
		var activityNamesDict = A2(
			$author$project$Incubator$IntDict$Extra$mapValues,
			function ($) {
				return $.names;
			},
			activities);
		var activityNameMatches = function (nameToTest) {
			return A2(
				$author$project$Incubator$IntDict$Extra$filterMap,
				matchToID(nameToTest),
				activityNamesDict);
		};
		var pickFirstMatch = function (nameToTest) {
			return $elm$core$List$head(
				$elm_community$intdict$IntDict$values(
					activityNameMatches(nameToTest)));
		};
		return A2(
			$author$project$Incubator$IntDict$Extra$filterMap,
			F2(
				function (i, p) {
					return pickFirstMatch(p.name);
				}),
			projects);
	});
var $author$project$Incubator$IntDict$Extra$filterValues = F2(
	function (func, dict) {
		return A2(
			$elm_community$intdict$IntDict$filter,
			F2(
				function (_v0, v) {
					return func(v);
				}),
			dict);
	});
var $elm_community$maybe_extra$Maybe$Extra$unwrap = F3(
	function (d, f, m) {
		if (m.$ === 'Nothing') {
			return d;
		} else {
			var a = m.a;
			return f(a);
		}
	});
var $author$project$Integrations$Todoist$detectActivityProjects = F3(
	function (maybeParent, app, cache) {
		if (maybeParent.$ === 'Nothing') {
			return $elm_community$intdict$IntDict$empty;
		} else {
			var parentProjectID = maybeParent.a;
			var oldActivityLookupTable = app.todoist.activityProjectIDs;
			var hasTimetrackAsParent = function (p) {
				return A3(
					$elm_community$maybe_extra$Maybe$Extra$unwrap,
					false,
					$elm$core$Basics$eq(parentProjectID),
					p.parent_id);
			};
			var validActivityProjects = A2($author$project$Incubator$IntDict$Extra$filterValues, hasTimetrackAsParent, cache.projects);
			var activities = $author$project$Activity$Activity$allActivities(app.activities);
			var newActivityLookupTable = A2($author$project$Integrations$Todoist$filterActivityProjects, validActivityProjects, activities);
			return A2($elm_community$intdict$IntDict$union, newActivityLookupTable, oldActivityLookupTable);
		}
	});
var $author$project$Incubator$IntDict$Extra$filterMapValues = F2(
	function (f, dict) {
		return A3(
			$elm_community$intdict$IntDict$foldl,
			F3(
				function (k, v, acc) {
					var _v0 = f(v);
					if (_v0.$ === 'Just') {
						var newVal = _v0.a;
						return A3($elm_community$intdict$IntDict$insert, k, newVal, acc);
					} else {
						return acc;
					}
				}),
			$elm_community$intdict$IntDict$empty,
			dict);
	});
var $author$project$Incubator$Todoist$pruneDeleted = function (items) {
	return A2(
		$author$project$Incubator$IntDict$Extra$filterValues,
		A2(
			$elm$core$Basics$composeL,
			$elm$core$Basics$not,
			function ($) {
				return $.is_deleted;
			}),
		items);
};
var $elm$core$Set$Set_elm_builtin = function (a) {
	return {$: 'Set_elm_builtin', a: a};
};
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			$elm$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2($elm$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});
var $elm$core$Set$diff = F2(
	function (_v0, _v1) {
		var dict1 = _v0.a;
		var dict2 = _v1.a;
		return $elm$core$Set$Set_elm_builtin(
			A2($elm$core$Dict$diff, dict1, dict2));
	});
var $elm$core$Dict$filter = F2(
	function (isGood, dict) {
		return A3(
			$elm$core$Dict$foldl,
			F3(
				function (k, v, d) {
					return A2(isGood, k, v) ? A3($elm$core$Dict$insert, k, v, d) : d;
				}),
			$elm$core$Dict$empty,
			dict);
	});
var $elm$core$Set$filter = F2(
	function (isGood, _v0) {
		var dict = _v0.a;
		return $elm$core$Set$Set_elm_builtin(
			A2(
				$elm$core$Dict$filter,
				F2(
					function (key, _v1) {
						return isGood(key);
					}),
				dict));
	});
var $elm$core$Set$empty = $elm$core$Set$Set_elm_builtin($elm$core$Dict$empty);
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0.a;
		return $elm$core$Set$Set_elm_builtin(
			A3($elm$core$Dict$insert, key, _Utils_Tuple0, dict));
	});
var $elm$core$Set$fromList = function (list) {
	return A3($elm$core$List$foldl, $elm$core$Set$insert, $elm$core$Set$empty, list);
};
var $elm_community$intdict$IntDict$get = F2(
	function (key, dict) {
		get:
		while (true) {
			switch (dict.$) {
				case 'Empty':
					return $elm$core$Maybe$Nothing;
				case 'Leaf':
					var l = dict.a;
					return _Utils_eq(l.key, key) ? $elm$core$Maybe$Just(l.value) : $elm$core$Maybe$Nothing;
				default:
					var i = dict.a;
					if (!A2($elm_community$intdict$IntDict$prefixMatches, i.prefix, key)) {
						return $elm$core$Maybe$Nothing;
					} else {
						if (A2($elm_community$intdict$IntDict$isBranchingBitSet, i.prefix, key)) {
							var $temp$key = key,
								$temp$dict = i.right;
							key = $temp$key;
							dict = $temp$dict;
							continue get;
						} else {
							var $temp$key = key,
								$temp$dict = i.left;
							key = $temp$key;
							dict = $temp$dict;
							continue get;
						}
					}
			}
		}
	});
var $elm_community$intdict$IntDict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm_community$intdict$IntDict$get, key, dict);
		if (_v0.$ === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $elm$core$Set$union = F2(
	function (_v0, _v1) {
		var dict1 = _v0.a;
		var dict2 = _v1.a;
		return $elm$core$Set$Set_elm_builtin(
			A2($elm$core$Dict$union, dict1, dict2));
	});
var $author$project$Incubator$Todoist$summarizeChanges = F2(
	function (oldCache, _new) {
		var toIDSet = function (list) {
			return $elm$core$Set$fromList(
				A2(
					$elm$core$List$map,
					function ($) {
						return $.id;
					},
					list));
		};
		var _v0 = _Utils_Tuple2(
			toIDSet(
				A2(
					$elm$core$List$filter,
					function ($) {
						return $.is_deleted;
					},
					_new.items)),
			toIDSet(
				A2(
					$elm$core$List$filter,
					function ($) {
						return $.is_deleted;
					},
					_new.projects)));
		var deletedItemIDs = _v0.a;
		var deletedProjectIDs = _v0.b;
		var _v1 = _Utils_Tuple2(
			toIDSet(_new.items),
			toIDSet(_new.projects));
		var allChangedItemIDs = _v1.a;
		var allChangedProjectIDs = _v1.b;
		var _v2 = _Utils_Tuple2(
			A2(
				$elm$core$Set$filter,
				function (id) {
					return !A2($elm_community$intdict$IntDict$member, id, oldCache.items);
				},
				allChangedItemIDs),
			A2(
				$elm$core$Set$filter,
				function (id) {
					return !A2($elm_community$intdict$IntDict$member, id, oldCache.projects);
				},
				allChangedProjectIDs));
		var newlyAddedItemIDs = _v2.a;
		var newlyAddedProjectIDs = _v2.b;
		var _v3 = _Utils_Tuple2(
			A2(
				$elm$core$Set$diff,
				allChangedItemIDs,
				A2($elm$core$Set$union, newlyAddedItemIDs, deletedItemIDs)),
			A2(
				$elm$core$Set$diff,
				allChangedProjectIDs,
				A2($elm$core$Set$union, newlyAddedProjectIDs, deletedProjectIDs)));
		var remainingItemIDs = _v3.a;
		var remainingProjectIDs = _v3.b;
		return {itemsAdded: newlyAddedItemIDs, itemsChanged: remainingItemIDs, itemsDeleted: deletedItemIDs, projectsAdded: newlyAddedProjectIDs, projectsChanged: remainingProjectIDs, projectsDeleted: deletedProjectIDs};
	});
var $author$project$Incubator$Todoist$handleResponse = F2(
	function (_v0, oldCache) {
		var response = _v0.a;
		if (response.$ === 'Ok') {
			var newStuff = response.a;
			var prune = function (inputDict) {
				return (!newStuff.full_sync) ? $author$project$Incubator$Todoist$pruneDeleted(inputDict) : inputDict;
			};
			var _v2 = _Utils_Tuple2(
				$elm_community$intdict$IntDict$fromList(
					A2(
						$elm$core$List$map,
						function (i) {
							return _Utils_Tuple2(i.id, i);
						},
						newStuff.items)),
				$elm_community$intdict$IntDict$fromList(
					A2(
						$elm$core$List$map,
						function (p) {
							return _Utils_Tuple2(p.id, p);
						},
						newStuff.projects)));
			var itemsDict = _v2.a;
			var projectsDict = _v2.b;
			return $elm$core$Result$Ok(
				_Utils_Tuple2(
					{
						items: prune(
							A2($elm_community$intdict$IntDict$union, itemsDict, oldCache.items)),
						nextSync: A2($elm$core$Maybe$withDefault, oldCache.nextSync, newStuff.sync_token),
						pendingCommands: _List_Nil,
						projects: prune(
							A2($elm_community$intdict$IntDict$union, projectsDict, oldCache.projects))
					},
					A2($author$project$Incubator$Todoist$summarizeChanges, oldCache, newStuff)));
		} else {
			var err = response.a;
			return $elm$core$Result$Err(err);
		}
	});
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (maybeValue.$ === 'Just') {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Integrations$Todoist$calcImportance = function (_v0) {
	var priority = _v0.priority;
	var day_order = _v0.day_order;
	var orderingFactor = _Utils_eq(day_order, -1) ? 0 : ((0 - (day_order * 0.01)) + 0.99);
	var _v1 = priority;
	var _int = _v1.a;
	var priorityFactor = (0 - _int) + 4;
	return priorityFactor + orderingFactor;
};
var $elm$core$String$dropRight = F2(
	function (n, string) {
		return (n < 1) ? string : A3($elm$core$String$slice, 0, -n, string);
	});
var $author$project$Integrations$Todoist$timing = A2(
	$elm$parser$Parser$keeper,
	A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$ignorer,
			A2(
				$elm$parser$Parser$ignorer,
				$elm$parser$Parser$succeed($elm$core$Tuple$pair),
				$elm$parser$Parser$symbol('(')),
			$elm$parser$Parser$spaces),
		A2(
			$elm$parser$Parser$ignorer,
			$elm$parser$Parser$float,
			$elm$parser$Parser$symbol('-'))),
	A2(
		$elm$parser$Parser$ignorer,
		A2(
			$elm$parser$Parser$ignorer,
			A2(
				$elm$parser$Parser$ignorer,
				$elm$parser$Parser$float,
				$elm$parser$Parser$symbol('m')),
			$elm$parser$Parser$spaces),
		$elm$parser$Parser$symbol(')')));
var $author$project$Integrations$Todoist$extractTiming2 = function (input) {
	var _default = _Utils_Tuple2(
		input,
		_Utils_Tuple2($elm$core$Maybe$Nothing, $elm$core$Maybe$Nothing));
	var chunk = function (start) {
		return A2($elm$core$String$dropLeft, start, input);
	};
	var withoutChunk = function (chunkStart) {
		return A2(
			$elm$core$String$dropRight,
			$elm$core$String$length(
				chunk(chunkStart)),
			input);
	};
	var _v0 = $elm_community$list_extra$List$Extra$last(
		A2($elm$core$String$indexes, '(', input));
	if (_v0.$ === 'Nothing') {
		return _default;
	} else {
		var chunkStart = _v0.a;
		var _v1 = A2(
			$elm$parser$Parser$run,
			$author$project$Integrations$Todoist$timing,
			chunk(chunkStart));
		if (_v1.$ === 'Err') {
			return _default;
		} else {
			var _v2 = _v1.a;
			var num1 = _v2.a;
			var num2 = _v2.b;
			return _Utils_Tuple2(
				withoutChunk(chunkStart),
				_Utils_Tuple2(
					$elm$core$Maybe$Just(
						$author$project$SmartTime$Duration$fromMinutes(num1)),
					$elm$core$Maybe$Just(
						$author$project$SmartTime$Duration$fromMinutes(num2))));
		}
	}
};
var $elm$core$Result$toMaybe = function (result) {
	if (result.$ === 'Ok') {
		var v = result.a;
		return $elm$core$Maybe$Just(v);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Incubator$Todoist$Item$fromRFC3339Date = A2($elm$core$Basics$composeL, $elm$core$Result$toMaybe, $author$project$SmartTime$Human$Moment$fuzzyFromString);
var $author$project$Task$Class$normalizeTitle = function (newTaskTitle) {
	return $elm$core$String$trim(newTaskTitle);
};
var $author$project$Task$Progress$unitMax = function (unit) {
	switch (unit.$) {
		case 'None':
			return 1;
		case 'Percent':
			return 100;
		case 'Permille':
			return 1000;
		case 'Word':
			var wordTarget = unit.a;
			return wordTarget;
		case 'Minute':
			var minuteTarget = unit.a;
			return minuteTarget;
		default:
			var _v1 = unit.a;
			var customTarget = unit.b;
			return customTarget;
	}
};
var $author$project$Integrations$Todoist$itemToTask = F2(
	function (activityID, item) {
		var getDueDate = function (due) {
			return $author$project$Incubator$Todoist$Item$fromRFC3339Date(due.date);
		};
		var _v0 = $author$project$Integrations$Todoist$extractTiming2(item.content);
		var newName = _v0.a;
		var _v1 = _v0.b;
		var minDur = _v1.a;
		var maxDur = _v1.b;
		var base = A2(
			$author$project$Task$Class$newClassSkel,
			$author$project$Task$Class$normalizeTitle(newName),
			item.id);
		var _class = _Utils_update(
			base,
			{
				activity: $elm$core$Maybe$Just(activityID),
				importance: $author$project$Integrations$Todoist$calcImportance(item),
				maxEffort: A2(
					$elm$core$Maybe$withDefault,
					$author$project$SmartTime$Human$Duration$toDuration(
						$author$project$SmartTime$Human$Duration$Minutes(4)),
					maxDur),
				minEffort: A2($elm$core$Maybe$withDefault, base.minEffort, minDur)
			});
		var newTaskInstance = A2($author$project$Task$Instance$newInstanceSkel, item.id, _class);
		var instance = _Utils_update(
			newTaskInstance,
			{
				completion: item.checked ? $author$project$Task$Progress$unitMax(_class.completionUnits) : newTaskInstance.completion,
				externalDeadline: A2($elm$core$Maybe$andThen, getDueDate, item.due)
			});
		return _Utils_Tuple2(_class, instance);
	});
var $author$project$Integrations$Todoist$timetrackItemToTask = F2(
	function (lookup, item) {
		var _v0 = A2($elm_community$intdict$IntDict$get, item.project_id, lookup);
		if (_v0.$ === 'Just') {
			var act = _v0.a;
			return $elm$core$Maybe$Just(
				A2($author$project$Integrations$Todoist$itemToTask, act, item));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm_community$intdict$IntDict$keys = function (dict) {
	return A3(
		$elm_community$intdict$IntDict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Integrations$Todoist$tryGetTimetrackParentProject = F2(
	function (localData, cache) {
		var _v0 = localData.parentProjectID;
		if (_v0.$ === 'Just') {
			var parentProjectID = _v0.a;
			return $elm$core$Maybe$Just(parentProjectID);
		} else {
			return $elm$core$List$head(
				$elm_community$intdict$IntDict$keys(
					A2(
						$elm_community$intdict$IntDict$filter,
						F2(
							function (_v1, p) {
								return p.name === 'Timetrack';
							}),
						cache.projects)));
		}
	});
var $author$project$Integrations$Todoist$handle = F2(
	function (msg, app) {
		var _v0 = A2($author$project$Incubator$Todoist$handleResponse, msg, app.todoist.cache);
		if (_v0.$ === 'Ok') {
			var _v1 = _v0.a;
			var newCache = _v1.a;
			var changes = _v1.b;
			var newMaybeParent = A2($author$project$Integrations$Todoist$tryGetTimetrackParentProject, app.todoist, newCache);
			var projectToActivityMapping = A3($author$project$Integrations$Todoist$detectActivityProjects, newMaybeParent, app, newCache);
			var newTodoistData = {activityProjectIDs: projectToActivityMapping, cache: newCache, parentProjectID: newMaybeParent};
			var convertItemsToTasks = A2(
				$author$project$Incubator$IntDict$Extra$filterMapValues,
				$author$project$Integrations$Todoist$timetrackItemToTask(projectToActivityMapping),
				newCache.items);
			var _v2 = _Utils_Tuple2(
				A2($author$project$Incubator$IntDict$Extra$mapValues, $elm$core$Tuple$first, convertItemsToTasks),
				A2($author$project$Incubator$IntDict$Extra$mapValues, $elm$core$Tuple$second, convertItemsToTasks));
			var newClasses = _v2.a;
			var newInstances = _v2.b;
			return _Utils_Tuple2(
				_Utils_update(
					app,
					{
						taskClasses: A2($elm_community$intdict$IntDict$union, newClasses, app.taskClasses),
						taskEntries: app.taskEntries,
						taskInstances: A2($elm_community$intdict$IntDict$union, newInstances, app.taskInstances),
						todoist: newTodoistData
					}),
				$author$project$Integrations$Todoist$describeSuccess(changes));
		} else {
			var err = _v0.a;
			var description = $author$project$Incubator$Todoist$describeError(err);
			return _Utils_Tuple2(
				A2($author$project$Profile$saveError, app, description),
				description);
		}
	});
var $elm$browser$Browser$Navigation$load = _Browser_load;
var $elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2($elm$core$Dict$map, func, left),
				A2($elm$core$Dict$map, func, right));
		}
	});
var $elm$core$Platform$Cmd$map = _Platform_map;
var $author$project$NativeScript$Notification$encodeAction = function (v) {
	return $elm$json$Json$Encode$object(
		_Utils_ap(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'id',
					$elm$json$Json$Encode$string(v.id)),
					_Utils_Tuple2(
					'launch',
					$elm$json$Json$Encode$bool(v.launch))
				]),
			function () {
				var _v0 = v.button;
				if (_v0.$ === 'Button') {
					var label = _v0.a;
					return _List_fromArray(
						[
							_Utils_Tuple2(
							'type',
							$elm$json$Json$Encode$string('button')),
							_Utils_Tuple2(
							'title',
							$elm$json$Json$Encode$string(label))
						]);
				} else {
					var textPlaceholder = _v0.a;
					var submitLabel = _v0.b;
					return _List_fromArray(
						[
							_Utils_Tuple2(
							'type',
							$elm$json$Json$Encode$string('input')),
							_Utils_Tuple2(
							'placeholder',
							$elm$json$Json$Encode$string(textPlaceholder)),
							_Utils_Tuple2(
							'submitLabel',
							$elm$json$Json$Encode$string(submitLabel))
						]);
				}
			}()));
};
var $author$project$NativeScript$Notification$encodeExpiresAfter = function (dur) {
	return $elm$json$Json$Encode$int(
		$author$project$SmartTime$Duration$inMs(dur));
};
var $author$project$NativeScript$Notification$encodeImportance = function (v) {
	switch (v.$) {
		case 'Default':
			return $elm$json$Json$Encode$int(0);
		case 'Low':
			return $elm$json$Json$Encode$int(-1);
		case 'High':
			return $elm$json$Json$Encode$int(1);
		case 'Min':
			return $elm$json$Json$Encode$int(-2);
		default:
			return $elm$json$Json$Encode$int(2);
	}
};
var $author$project$NativeScript$Notification$encodeMediaInfo = function (v) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				$elm$json$Json$Encode$string(v.title))
			]));
};
var $author$project$NativeScript$Notification$encodeProgress = function (v) {
	if (v.$ === 'Indeterminate') {
		return $elm$json$Json$Encode$int(0);
	} else {
		var current = v.a;
		return $elm$json$Json$Encode$int(current);
	}
};
var $author$project$NativeScript$Notification$encodeProgressMax = function (v) {
	if (v.$ === 'Indeterminate') {
		return $elm$json$Json$Encode$null;
	} else {
		var progressMax = v.b;
		return $elm$json$Json$Encode$int(progressMax);
	}
};
var $author$project$NativeScript$Notification$encodeRepeatEvery = function (v) {
	switch (v.$) {
		case 'Second':
			return $elm$json$Json$Encode$string('second');
		case 'Minute':
			return $elm$json$Json$Encode$string('minute');
		case 'Hour':
			return $elm$json$Json$Encode$string('hour');
		case 'Day':
			return $elm$json$Json$Encode$string('day');
		case 'Week':
			return $elm$json$Json$Encode$string('week');
		case 'Month':
			return $elm$json$Json$Encode$string('month');
		default:
			return $elm$json$Json$Encode$string('year');
	}
};
var $author$project$NativeScript$Notification$encodeSound = function (v) {
	switch (v.$) {
		case 'DefaultSound':
			return $elm$json$Json$Encode$string('default');
		case 'Silent':
			return $elm$json$Json$Encode$null;
		default:
			var path = v.a;
			return $elm$json$Json$Encode$string(path);
	}
};
var $author$project$NativeScript$Notification$encodeThumbnail = function (v) {
	switch (v.$) {
		case 'UsePicture':
			return $elm$json$Json$Encode$bool(true);
		case 'FromResource':
			var link = v.a;
			return $elm$json$Json$Encode$string(link);
		default:
			var link = v.a;
			return $elm$json$Json$Encode$string(link);
	}
};
var $author$project$NativeScript$Notification$encodevibratePattern = function (durs) {
	var unbundlePair = function (_v0) {
		var silence = _v0.a;
		var vibration = _v0.b;
		return _List_fromArray(
			[silence, vibration]);
	};
	var flattenedList = $elm$core$List$concat(
		A2($elm$core$List$map, unbundlePair, durs));
	var intList = A2($elm$core$List$map, $author$project$SmartTime$Duration$inMs, flattenedList);
	return A2($elm$json$Json$Encode$list, $elm$json$Json$Encode$int, intList);
};
var $author$project$NativeScript$Notification$encodeVibrationSetting = function (v) {
	switch (v.$) {
		case 'NoVibration':
			return $elm$json$Json$Encode$null;
		case 'Vibrate':
			return $elm$json$Json$Encode$bool(true);
		default:
			var pattern = v.a;
			return $author$project$NativeScript$Notification$encodevibratePattern(pattern);
	}
};
var $elm_community$maybe_extra$Maybe$Extra$filter = F2(
	function (f, m) {
		var _v0 = A2($elm$core$Maybe$map, f, m);
		if ((_v0.$ === 'Just') && _v0.a) {
			return m;
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Porting$omittableList = function (_v0) {
	var name = _v0.a;
	var encoder = _v0.b;
	var fieldToCheck = _v0.c;
	var listToCheck = A2(
		$elm_community$maybe_extra$Maybe$Extra$filter,
		A2($elm$core$Basics$composeL, $elm$core$Basics$not, $elm$core$List$isEmpty),
		$elm$core$Maybe$Just(fieldToCheck));
	return A2(
		$elm$core$Maybe$map,
		function (field) {
			return _Utils_Tuple2(
				name,
				A2($elm$json$Json$Encode$list, encoder, field));
		},
		listToCheck);
};
var $author$project$SmartTime$Moment$toJSTime = function (givenMoment) {
	return A3($author$project$SmartTime$Moment$toInt, givenMoment, $author$project$SmartTime$Moment$UTC, $author$project$SmartTime$Moment$unixEpoch);
};
var $author$project$NativeScript$Notification$encode = function (v) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$omittable(
				_Utils_Tuple3('id', $elm$json$Json$Encode$int, v.id)),
				$author$project$Porting$omittable(
				_Utils_Tuple3(
					'at',
					A2($elm$core$Basics$composeL, $elm$json$Json$Encode$float, $author$project$SmartTime$Moment$toJSTime),
					v.at)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('ongoing', $elm$json$Json$Encode$bool, v.ongoing)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('expiresAfter', $author$project$NativeScript$Notification$encodeExpiresAfter, v.expiresAfter)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('importance', $author$project$NativeScript$Notification$encodeImportance, v.channel.importance)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('title', $elm$json$Json$Encode$string, v.title)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('title_expanded', $elm$json$Json$Encode$string, v.title_expanded)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('body', $elm$json$Json$Encode$string, v.body)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('bigTextStyle', $elm$json$Json$Encode$bool, v.bigTextStyle)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('subtitle', $elm$json$Json$Encode$string, v.subtitle)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('ticker', $elm$json$Json$Encode$string, v.ticker)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('icon', $elm$json$Json$Encode$string, v.icon)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('status_icon', $elm$json$Json$Encode$string, v.status_icon)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('status_text_size', $elm$json$Json$Encode$int, v.status_text_size)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('color', $elm$json$Json$Encode$string, v.accentColor)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('color_from_media', $elm$json$Json$Encode$bool, v.color_from_media)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('badge', $elm$json$Json$Encode$int, v.badge)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('image', $elm$json$Json$Encode$string, v.image)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('picture_skip_cache', $elm$json$Json$Encode$bool, v.picture_skip_cache)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('picture_expanded_icon', $elm$json$Json$Encode$string, v.picture_expanded_icon)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('media_layout', $elm$json$Json$Encode$bool, v.media_layout)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('media', $author$project$NativeScript$Notification$encodeMediaInfo, v.media)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('url', $elm$json$Json$Encode$string, v.url)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('on_create', $elm$json$Json$Encode$string, v.on_create)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('on_touch', $elm$json$Json$Encode$string, v.on_touch)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('on_dismiss', $elm$json$Json$Encode$string, v.on_dismiss)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('autoCancel', $elm$json$Json$Encode$bool, v.autoCancel)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('chronometer', $elm$json$Json$Encode$bool, v.chronometer)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('countdown', $elm$json$Json$Encode$bool, v.countdown)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'channel',
					$elm$json$Json$Encode$string(v.channel.name))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('channelDescription', $elm$json$Json$Encode$string, v.channel.description)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('notificationLed', $elm$json$Json$Encode$string, v.channel.led)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('sound', $author$project$NativeScript$Notification$encodeSound, v.channel.sound)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('vibratePattern', $author$project$NativeScript$Notification$encodeVibrationSetting, v.channel.vibrate)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('phone_only', $elm$json$Json$Encode$bool, v.phone_only)),
				$author$project$Porting$omittable(
				_Utils_Tuple3(
					'groupedMessages',
					$elm$json$Json$Encode$list($elm$json$Json$Encode$string),
					v.groupedMessages)),
				$author$project$Porting$omittable(
				_Utils_Tuple3(
					'group',
					function (_v0) {
						var s = _v0.a;
						return $elm$json$Json$Encode$string(s);
					},
					v.group)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('interval', $author$project$NativeScript$Notification$encodeRepeatEvery, v.interval)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('icon', $elm$json$Json$Encode$string, v.icon)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('silhouetteIcon', $elm$json$Json$Encode$string, v.silhouetteIcon)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('thumbnail', $author$project$NativeScript$Notification$encodeThumbnail, v.thumbnail)),
				$author$project$Porting$omittableList(
				_Utils_Tuple3('actions', $author$project$NativeScript$Notification$encodeAction, v.actions)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('progress', $author$project$NativeScript$Notification$encodeProgress, v.progress)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('progressMax', $author$project$NativeScript$Notification$encodeProgressMax, v.progress)),
				$author$project$Porting$omittable(
				_Utils_Tuple3(
					'when',
					A2($elm$core$Basics$composeL, $elm$json$Json$Encode$float, $author$project$SmartTime$Moment$toJSTime),
					v.when)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('chronometer', $elm$json$Json$Encode$bool, v.chronometer)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('sortKey', $elm$json$Json$Encode$string, v.sortKey))
			]));
};
var $author$project$NativeScript$Commands$ns_notify = _Platform_outgoingPort('ns_notify', $elm$core$Basics$identity);
var $author$project$NativeScript$Commands$notify = function (notification) {
	return $author$project$NativeScript$Commands$ns_notify(
		A2($elm$json$Json$Encode$list, $author$project$NativeScript$Notification$encode, notification));
};
var $elm$browser$Browser$Navigation$pushUrl = _Browser_pushUrl;
var $elm$url$Url$Parser$query = function (_v0) {
	var queryParser = _v0.a;
	return $elm$url$Url$Parser$Parser(
		function (_v1) {
			var visited = _v1.visited;
			var unvisited = _v1.unvisited;
			var params = _v1.params;
			var frag = _v1.frag;
			var value = _v1.value;
			return _List_fromArray(
				[
					A5(
					$elm$url$Url$Parser$State,
					visited,
					unvisited,
					params,
					frag,
					value(
						queryParser(params)))
				]);
		});
};
var $elm$browser$Browser$Navigation$replaceUrl = _Browser_replaceUrl;
var $author$project$NativeScript$Notification$setBody = F2(
	function (body, givenNotif) {
		return _Utils_update(
			givenNotif,
			{
				body: $elm$core$Maybe$Just(body)
			});
	});
var $author$project$NativeScript$Notification$setChannelDescription = F2(
	function (text, givenChannel) {
		return _Utils_update(
			givenChannel,
			{
				description: $elm$core$Maybe$Just(text)
			});
	});
var $author$project$NativeScript$Notification$setChannelImportance = F2(
	function (givenImportance, givenChannel) {
		return _Utils_update(
			givenChannel,
			{
				importance: $elm$core$Maybe$Just(givenImportance)
			});
	});
var $author$project$NativeScript$Notification$setExpiresAfter = F2(
	function (expiresAfter, givenNotif) {
		return _Utils_update(
			givenNotif,
			{
				expiresAfter: $elm$core$Maybe$Just(expiresAfter)
			});
	});
var $author$project$NativeScript$Notification$setID = F2(
	function (id, givenNotif) {
		return _Utils_update(
			givenNotif,
			{
				id: $elm$core$Maybe$Just(id)
			});
	});
var $author$project$NativeScript$Notification$setSubtitle = F2(
	function (subtitle, givenNotif) {
		return _Utils_update(
			givenNotif,
			{
				subtitle: $elm$core$Maybe$Just(subtitle)
			});
	});
var $author$project$NativeScript$Notification$setTitle = F2(
	function (title, givenNotif) {
		return _Utils_update(
			givenNotif,
			{
				title: $elm$core$Maybe$Just(title)
			});
	});
var $author$project$External$Tasker$flash = _Platform_outgoingPort('flash', $elm$json$Json$Encode$string);
var $author$project$External$Commands$toast = function (message) {
	return $author$project$External$Tasker$flash(message);
};
var $author$project$Incubator$Todoist$Command$ItemClose = function (a) {
	return {$: 'ItemClose', a: a};
};
var $author$project$Incubator$Todoist$Command$ItemUncomplete = function (a) {
	return {$: 'ItemUncomplete', a: a};
};
var $author$project$TaskList$NoOp = {$: 'NoOp'};
var $author$project$Incubator$Todoist$Command$RealItem = function (a) {
	return {$: 'RealItem', a: a};
};
var $author$project$TaskList$TodoistServerResponse = function (a) {
	return {$: 'TodoistServerResponse', a: a};
};
var $elm$core$Task$onError = _Scheduler_onError;
var $elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2(
					$elm$core$Task$onError,
					A2(
						$elm$core$Basics$composeL,
						A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
						$elm$core$Result$Err),
					A2(
						$elm$core$Task$andThen,
						A2(
							$elm$core$Basics$composeL,
							A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
							$elm$core$Result$Ok),
						task))));
	});
var $elm$browser$Browser$Dom$focus = _Browser_call('focus');
var $author$project$Task$Progress$getUnits = function (_v0) {
	var unit = _v0.b;
	return unit;
};
var $author$project$Task$Instance$instanceProgress = function (fullInstance) {
	return _Utils_Tuple2(fullInstance.instance.completion, fullInstance._class.completionUnits);
};
var $author$project$Task$Progress$getPortion = function (_v0) {
	var part = _v0.a;
	return part;
};
var $author$project$Task$Progress$getWhole = function (_v0) {
	var unit = _v0.b;
	return $author$project$Task$Progress$unitMax(unit);
};
var $author$project$Task$Progress$isMax = function (progress) {
	return _Utils_eq(
		$author$project$Task$Progress$getPortion(progress),
		$author$project$Task$Progress$getWhole(progress));
};
var $elm_community$intdict$IntDict$remove = F2(
	function (key, dict) {
		return A3(
			$elm_community$intdict$IntDict$update,
			key,
			$elm$core$Basics$always($elm$core$Maybe$Nothing),
			dict);
	});
var $author$project$Integrations$Todoist$sendChanges = F2(
	function (localData, changeList) {
		return A4(
			$author$project$Incubator$Todoist$sync,
			localData.cache,
			$author$project$Integrations$Todoist$devSecret,
			_List_fromArray(
				[$author$project$Incubator$Todoist$Items, $author$project$Incubator$Todoist$Projects]),
			changeList);
	});
var $author$project$SmartTime$Human$Calendar$dayOfMonth = A2(
	$elm$core$Basics$composeR,
	$author$project$SmartTime$Human$Calendar$toParts,
	function ($) {
		return $.day;
	});
var $elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
var $elm$core$String$repeatHelp = F3(
	function (n, chunk, result) {
		return (n <= 0) ? result : A3(
			$elm$core$String$repeatHelp,
			n >> 1,
			_Utils_ap(chunk, chunk),
			(!(n & 1)) ? result : _Utils_ap(result, chunk));
	});
var $elm$core$String$repeat = F2(
	function (n, chunk) {
		return A3($elm$core$String$repeatHelp, n, chunk, '');
	});
var $author$project$SmartTime$Human$Calendar$padNumber = F2(
	function (targetLength, numString) {
		var minLength = A3($elm$core$Basics$clamp, 1, targetLength, targetLength);
		var zerosToAdd = minLength - $elm$core$String$length(numString);
		return _Utils_ap(
			A2($elm$core$String$repeat, zerosToAdd, '0'),
			numString);
	});
var $author$project$SmartTime$Human$Calendar$Year$toAstronomicalString = function (year) {
	var yearInt = year.a;
	return $elm$core$String$fromInt(yearInt);
};
var $author$project$SmartTime$Human$Calendar$Month$toInt = function (givenMonth) {
	switch (givenMonth.$) {
		case 'Jan':
			return 1;
		case 'Feb':
			return 2;
		case 'Mar':
			return 3;
		case 'Apr':
			return 4;
		case 'May':
			return 5;
		case 'Jun':
			return 6;
		case 'Jul':
			return 7;
		case 'Aug':
			return 8;
		case 'Sep':
			return 9;
		case 'Oct':
			return 10;
		case 'Nov':
			return 11;
		default:
			return 12;
	}
};
var $author$project$SmartTime$Human$Calendar$toStandardString = function (givenDate) {
	var yearPart = A2(
		$author$project$SmartTime$Human$Calendar$padNumber,
		4,
		$author$project$SmartTime$Human$Calendar$Year$toAstronomicalString(
			$author$project$SmartTime$Human$Calendar$year(givenDate)));
	var monthPart = A2(
		$author$project$SmartTime$Human$Calendar$padNumber,
		2,
		$elm$core$String$fromInt(
			$author$project$SmartTime$Human$Calendar$Month$toInt(
				$author$project$SmartTime$Human$Calendar$month(givenDate))));
	var dayPart = A2(
		$author$project$SmartTime$Human$Calendar$padNumber,
		2,
		$elm$core$String$fromInt(
			$author$project$SmartTime$Human$Calendar$Month$dayToInt(
				$author$project$SmartTime$Human$Calendar$dayOfMonth(givenDate))));
	return yearPart + ('-' + (monthPart + ('-' + dayPart)));
};
var $author$project$SmartTime$Human$Duration$breakdownHMSM = function (duration) {
	var _v0 = $author$project$SmartTime$Duration$breakdown(duration);
	var days = _v0.days;
	var hours = _v0.hours;
	var minutes = _v0.minutes;
	var seconds = _v0.seconds;
	var milliseconds = _v0.milliseconds;
	return _List_fromArray(
		[
			$author$project$SmartTime$Human$Duration$Hours(
			$author$project$SmartTime$Duration$inWholeHours(duration)),
			$author$project$SmartTime$Human$Duration$Minutes(minutes),
			$author$project$SmartTime$Human$Duration$Seconds(seconds),
			$author$project$SmartTime$Human$Duration$Milliseconds(milliseconds)
		]);
};
var $elm_community$list_extra$List$Extra$init = function (items) {
	if (!items.b) {
		return $elm$core$Maybe$Nothing;
	} else {
		var nonEmptyList = items;
		return A2(
			$elm$core$Maybe$map,
			$elm$core$List$reverse,
			$elm$core$List$tail(
				$elm$core$List$reverse(nonEmptyList)));
	}
};
var $author$project$SmartTime$Human$Duration$padNumber = F2(
	function (targetLength, numString) {
		var minLength = A3($elm$core$Basics$clamp, 1, targetLength, targetLength);
		var zerosToAdd = minLength - $elm$core$String$length(numString);
		return _Utils_ap(
			A2($elm$core$String$repeat, zerosToAdd, '0'),
			numString);
	});
var $author$project$SmartTime$Human$Duration$justNumberPadded = function (unit) {
	switch (unit.$) {
		case 'Milliseconds':
			var _int = unit.a;
			return A2(
				$author$project$SmartTime$Human$Duration$padNumber,
				3,
				$elm$core$String$fromInt(_int));
		case 'Seconds':
			var _int = unit.a;
			return A2(
				$author$project$SmartTime$Human$Duration$padNumber,
				2,
				$elm$core$String$fromInt(_int));
		case 'Minutes':
			var _int = unit.a;
			return A2(
				$author$project$SmartTime$Human$Duration$padNumber,
				2,
				$elm$core$String$fromInt(_int));
		case 'Hours':
			var _int = unit.a;
			return A2(
				$author$project$SmartTime$Human$Duration$padNumber,
				2,
				$elm$core$String$fromInt(_int));
		default:
			var _int = unit.a;
			return A2(
				$author$project$SmartTime$Human$Duration$padNumber,
				2,
				$elm$core$String$fromInt(_int));
	}
};
var $author$project$SmartTime$Human$Duration$colonSeparated = function (breakdownList) {
	var separate = function (list) {
		return $elm$core$String$concat(
			A2(
				$elm$core$List$intersperse,
				':',
				A2($elm$core$List$map, $author$project$SmartTime$Human$Duration$justNumberPadded, list)));
	};
	var _v0 = $elm_community$list_extra$List$Extra$last(breakdownList);
	if ((_v0.$ === 'Just') && (_v0.a.$ === 'Milliseconds')) {
		var ms = _v0.a.a;
		var withoutLast = A2(
			$elm$core$Maybe$withDefault,
			_List_Nil,
			$elm_community$list_extra$List$Extra$init(breakdownList));
		return separate(withoutLast) + ('.' + A2(
			$author$project$SmartTime$Human$Duration$padNumber,
			3,
			$elm$core$String$fromInt(ms)));
	} else {
		return separate(breakdownList);
	}
};
var $author$project$SmartTime$Human$Clock$toStandardString = function (timeOfDay) {
	return $author$project$SmartTime$Human$Duration$colonSeparated(
		$author$project$SmartTime$Human$Duration$breakdownHMSM(timeOfDay));
};
var $author$project$SmartTime$Human$Moment$toStandardString = function (moment) {
	var _v0 = A2($author$project$SmartTime$Human$Moment$humanize, $author$project$SmartTime$Human$Moment$utc, moment);
	var date = _v0.a;
	var time = _v0.b;
	return $author$project$SmartTime$Human$Calendar$toStandardString(date) + ('T' + ($author$project$SmartTime$Human$Clock$toStandardString(time) + 'Z'));
};
var $author$project$TaskList$update = F4(
	function (msg, state, app, env) {
		switch (msg.$) {
			case 'Add':
				if (state.c === '') {
					var filters = state.a;
					return _Utils_Tuple3(
						A3($author$project$TaskList$Normal, filters, $elm$core$Maybe$Nothing, ''),
						app,
						$elm$core$Platform$Cmd$none);
				} else {
					var filters = state.a;
					var newTaskTitle = state.c;
					var newClassID = $author$project$SmartTime$Moment$toSmartInt(env.time);
					var newEntry = $author$project$Task$Entry$newRootEntry(newClassID);
					var newTaskClass = A2(
						$author$project$Task$Class$newClassSkel,
						$author$project$Task$Class$normalizeTitle(newTaskTitle),
						newClassID);
					var newTaskInstance = A2(
						$author$project$Task$Instance$newInstanceSkel,
						$author$project$SmartTime$Moment$toSmartInt(env.time),
						newTaskClass);
					return _Utils_Tuple3(
						A3($author$project$TaskList$Normal, filters, $elm$core$Maybe$Nothing, ''),
						_Utils_update(
							app,
							{
								taskClasses: A3($elm_community$intdict$IntDict$insert, newTaskClass.id, newTaskClass, app.taskClasses),
								taskEntries: A2(
									$elm$core$List$append,
									app.taskEntries,
									_List_fromArray(
										[newEntry])),
								taskInstances: A3($elm_community$intdict$IntDict$insert, newTaskInstance.id, newTaskInstance, app.taskInstances)
							}),
						$elm$core$Platform$Cmd$none);
				}
			case 'UpdateNewEntryField':
				var typedSoFar = msg.a;
				return _Utils_Tuple3(
					function () {
						var _v2 = state;
						var filters = _v2.a;
						var expanded = _v2.b;
						return A3($author$project$TaskList$Normal, filters, expanded, typedSoFar);
					}(),
					app,
					$elm$core$Platform$Cmd$none);
			case 'EditingTitle':
				var id = msg.a;
				var isEditing = msg.b;
				var updateTask = function (t) {
					return t;
				};
				var focus = $elm$browser$Browser$Dom$focus(
					'task-' + $elm$core$String$fromInt(id));
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							taskInstances: A3(
								$elm_community$intdict$IntDict$update,
								id,
								$elm$core$Maybe$map(updateTask),
								app.taskInstances)
						}),
					A2(
						$elm$core$Task$attempt,
						function (_v3) {
							return $author$project$TaskList$NoOp;
						},
						focus));
			case 'UpdateTitle':
				var classID = msg.a;
				var task = msg.b;
				var updateTitle = function (t) {
					return _Utils_update(
						t,
						{title: task});
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							taskClasses: A3(
								$elm_community$intdict$IntDict$update,
								classID,
								$elm$core$Maybe$map(updateTitle),
								app.taskClasses)
						}),
					$elm$core$Platform$Cmd$none);
			case 'UpdateTaskDate':
				var id = msg.a;
				var field = msg.b;
				var date = msg.c;
				var updateTask = function (t) {
					return _Utils_update(
						t,
						{externalDeadline: date});
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							taskInstances: A3(
								$elm_community$intdict$IntDict$update,
								id,
								$elm$core$Maybe$map(updateTask),
								app.taskInstances)
						}),
					$elm$core$Platform$Cmd$none);
			case 'Delete':
				var id = msg.a;
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							taskInstances: A2($elm_community$intdict$IntDict$remove, id, app.taskInstances)
						}),
					$elm$core$Platform$Cmd$none);
			case 'DeleteComplete':
				return _Utils_Tuple3(state, app, $elm$core$Platform$Cmd$none);
			case 'UpdateProgress':
				var givenTask = msg.a;
				var new_completion = msg.b;
				var updateTask = function (t) {
					return _Utils_update(
						t,
						{completion: new_completion});
				};
				var oldProgress = $author$project$Task$Instance$instanceProgress(givenTask);
				var handleCompletion = function () {
					var _v4 = _Utils_Tuple2(
						$author$project$Task$Progress$isMax(oldProgress),
						$author$project$Task$Progress$isMax(
							_Utils_Tuple2(
								new_completion,
								$author$project$Task$Progress$getUnits(oldProgress))));
					_v4$2:
					while (true) {
						if (!_v4.a) {
							if (_v4.b) {
								return $elm$core$Platform$Cmd$batch(
									_List_fromArray(
										[
											$author$project$External$Commands$toast('Marked as complete: ' + givenTask._class.title),
											A2(
											$elm$core$Platform$Cmd$map,
											$author$project$TaskList$TodoistServerResponse,
											A2(
												$author$project$Integrations$Todoist$sendChanges,
												app.todoist,
												_List_fromArray(
													[
														_Utils_Tuple2(
														$author$project$SmartTime$Human$Moment$toStandardString(env.time),
														$author$project$Incubator$Todoist$Command$ItemClose(
															$author$project$Incubator$Todoist$Command$RealItem(givenTask.instance.id)))
													])))
										]));
							} else {
								break _v4$2;
							}
						} else {
							if (!_v4.b) {
								return $elm$core$Platform$Cmd$batch(
									_List_fromArray(
										[
											$author$project$External$Commands$toast('No longer marked as complete: ' + givenTask._class.title),
											A2(
											$elm$core$Platform$Cmd$map,
											$author$project$TaskList$TodoistServerResponse,
											A2(
												$author$project$Integrations$Todoist$sendChanges,
												app.todoist,
												_List_fromArray(
													[
														_Utils_Tuple2(
														$author$project$SmartTime$Human$Moment$toStandardString(env.time),
														$author$project$Incubator$Todoist$Command$ItemUncomplete(
															$author$project$Incubator$Todoist$Command$RealItem(givenTask.instance.id)))
													])))
										]));
							} else {
								break _v4$2;
							}
						}
					}
					return $elm$core$Platform$Cmd$none;
				}();
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							taskInstances: A3(
								$elm_community$intdict$IntDict$update,
								givenTask.instance.id,
								$elm$core$Maybe$map(updateTask),
								app.taskInstances)
						}),
					handleCompletion);
			case 'FocusSlider':
				var task = msg.a;
				var focused = msg.b;
				return _Utils_Tuple3(state, app, $elm$core$Platform$Cmd$none);
			case 'NoOp':
				return _Utils_Tuple3(state, app, $elm$core$Platform$Cmd$none);
			case 'TodoistServerResponse':
				var response = msg.a;
				var _v5 = A2($author$project$Integrations$Todoist$handle, response, app);
				var newAppData = _v5.a;
				var whatHappened = _v5.b;
				return _Utils_Tuple3(
					state,
					newAppData,
					$author$project$External$Commands$toast(whatHappened));
			default:
				var newList = msg.a;
				return _Utils_Tuple3(
					function () {
						var filterList = state.a;
						var expandedTaskMaybe = state.b;
						var newTaskField = state.c;
						return A3($author$project$TaskList$Normal, newList, expandedTaskMaybe, newTaskField);
					}(),
					app,
					$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Activity$Activity$getName = function (activity) {
	return A2(
		$elm$core$Maybe$withDefault,
		'?',
		$elm$core$List$head(activity.names));
};
var $author$project$Activity$Activity$showing = function (activity) {
	return !activity.hidden;
};
var $author$project$SmartTime$Duration$inMinutesRounded = function (duration) {
	return $elm$core$Basics$round(
		$author$project$SmartTime$Duration$inMs(duration) / $author$project$SmartTime$Duration$minuteLength);
};
var $author$project$SmartTime$Human$Duration$dur = $author$project$SmartTime$Human$Duration$toDuration;
var $author$project$SmartTime$Moment$past = F2(
	function (_v0, duration) {
		var time = _v0.a;
		return $author$project$SmartTime$Moment$Moment(
			A2($author$project$SmartTime$Duration$subtract, time, duration));
	});
var $author$project$Activity$Measure$lookBack = F2(
	function (present, humanDuration) {
		return A2(
			$author$project$SmartTime$Moment$past,
			present,
			$author$project$SmartTime$Human$Duration$dur(humanDuration));
	});
var $author$project$Activity$Activity$dummy = $author$project$ID$tag(0);
var $elm$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _v0) {
				var trues = _v0.a;
				var falses = _v0.b;
				return pred(x) ? _Utils_Tuple2(
					A2($elm$core$List$cons, x, trues),
					falses) : _Utils_Tuple2(
					trues,
					A2($elm$core$List$cons, x, falses));
			});
		return A3(
			$elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, _List_Nil),
			list);
	});
var $author$project$Activity$Measure$timelineLimit = F3(
	function (timeline, now, pastLimit) {
		var switchActivityID = function (_v2) {
			var id = _v2.b;
			return id;
		};
		var recentEnough = function (_v1) {
			var moment = _v1.a;
			return _Utils_eq(
				A2($author$project$SmartTime$Moment$compare, moment, pastLimit),
				$author$project$SmartTime$Moment$Later);
		};
		var _v0 = A2($elm$core$List$partition, recentEnough, timeline);
		var pass = _v0.a;
		var fail = _v0.b;
		var justMissedId = A2(
			$elm$core$Maybe$withDefault,
			$author$project$Activity$Activity$dummy,
			A2(
				$elm$core$Maybe$map,
				switchActivityID,
				$elm$core$List$head(fail)));
		var fakeEndSwitch = A2($author$project$Activity$Activity$Switch, pastLimit, justMissedId);
		return _Utils_ap(
			pass,
			_List_fromArray(
				[fakeEndSwitch]));
	});
var $author$project$Activity$Measure$relevantTimeline = F3(
	function (timeline, now, duration) {
		return A3(
			$author$project$Activity$Measure$timelineLimit,
			timeline,
			now,
			A2($author$project$Activity$Measure$lookBack, now, duration));
	});
var $author$project$SmartTime$Duration$combine = function (durationList) {
	return A3(
		$elm$core$List$foldl,
		$author$project$SmartTime$Duration$add,
		$author$project$SmartTime$Duration$Duration(0),
		durationList);
};
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $author$project$SmartTime$Duration$difference = F2(
	function (_v0, _v1) {
		var int1 = _v0.a;
		var int2 = _v1.a;
		return $author$project$SmartTime$Duration$Duration(
			$elm$core$Basics$abs(int1 - int2));
	});
var $author$project$SmartTime$Moment$difference = F2(
	function (_v0, _v1) {
		var time1 = _v0.a;
		var time2 = _v1.a;
		return A2($author$project$SmartTime$Duration$difference, time1, time2);
	});
var $author$project$Activity$Measure$session = F2(
	function (_v0, _v1) {
		var newer = _v0.a;
		var older = _v1.a;
		var activityId = _v1.b;
		return _Utils_Tuple2(
			activityId,
			A2($author$project$SmartTime$Moment$difference, newer, older));
	});
var $author$project$Activity$Measure$allSessions = function (switchList) {
	var offsetList = A2($elm$core$List$drop, 1, switchList);
	return A3($elm$core$List$map2, $author$project$Activity$Measure$session, switchList, offsetList);
};
var $author$project$Activity$Measure$sessions = F2(
	function (switchList, activityId) {
		var isMatchingDuration = F2(
			function (targetId, _v0) {
				var itemId = _v0.a;
				var dur = _v0.b;
				return _Utils_eq(itemId, targetId) ? $elm$core$Maybe$Just(dur) : $elm$core$Maybe$Nothing;
			});
		var all = $author$project$Activity$Measure$allSessions(switchList);
		return A2(
			$elm$core$List$filterMap,
			isMatchingDuration(activityId),
			all);
	});
var $author$project$Activity$Measure$totalLive = F3(
	function (now, switchList, activityId) {
		var fakeSwitch = A2($author$project$Activity$Activity$Switch, now, activityId);
		return $author$project$SmartTime$Duration$combine(
			A2(
				$author$project$Activity$Measure$sessions,
				A2($elm$core$List$cons, fakeSwitch, switchList),
				activityId));
	});
var $author$project$TimeTracker$writeActivityUsage = F3(
	function (app, env, _v0) {
		var activityID = _v0.a;
		var activity = _v0.b;
		var period = activity.maxTime.b;
		var lastPeriod = A3($author$project$Activity$Measure$relevantTimeline, app.timeline, env.time, period);
		var total = A3($author$project$Activity$Measure$totalLive, env.time, lastPeriod, activityID);
		var totalMinutes = $author$project$SmartTime$Duration$inMinutesRounded(total);
		return ($author$project$SmartTime$Duration$inMs(total) > 0) ? ($elm$core$String$fromInt(totalMinutes) + ('/' + ($elm$core$String$fromInt(
			$author$project$SmartTime$Duration$inMinutesRounded(
				$author$project$SmartTime$Human$Duration$toDuration(period))) + 'm'))) : '';
	});
var $author$project$TimeTracker$exportActivityViewModel = F2(
	function (appData, environment) {
		var encodeActivityVM = function (_v0) {
			var activityID = _v0.a;
			var activity = _v0.b;
			return $elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'name',
						$elm$json$Json$Encode$string(
							$author$project$Activity$Activity$getName(activity))),
						_Utils_Tuple2(
						'excusedUsage',
						$elm$json$Json$Encode$string(
							A3(
								$author$project$TimeTracker$writeActivityUsage,
								appData,
								environment,
								_Utils_Tuple2(
									$author$project$ID$tag(activityID),
									activity)))),
						_Utils_Tuple2(
						'totalToday',
						$elm$json$Json$Encode$string(
							A3(
								$author$project$TimeTracker$writeActivityUsage,
								appData,
								environment,
								_Utils_Tuple2(
									$author$project$ID$tag(activityID),
									activity))))
					]));
		};
		return A2(
			$elm$json$Json$Encode$list,
			encodeActivityVM,
			$elm_community$intdict$IntDict$toList(
				A2(
					$author$project$Incubator$IntDict$Extra$filterValues,
					$author$project$Activity$Activity$showing,
					$author$project$Activity$Activity$allActivities(appData.activities))));
	});
var $author$project$SmartTime$Human$Duration$breakdownHMS = function (duration) {
	var _v0 = $author$project$SmartTime$Duration$breakdown(duration);
	var minutes = _v0.minutes;
	var seconds = _v0.seconds;
	return _List_fromArray(
		[
			$author$project$SmartTime$Human$Duration$Hours(
			$author$project$SmartTime$Duration$inWholeHours(duration)),
			$author$project$SmartTime$Human$Duration$Minutes(minutes),
			$author$project$SmartTime$Human$Duration$Seconds(seconds)
		]);
};
var $author$project$Activity$Activity$latestSwitch = function (timeline) {
	return A2(
		$elm$core$Maybe$withDefault,
		A2(
			$author$project$Activity$Activity$Switch,
			$author$project$SmartTime$Moment$zero,
			$author$project$ID$tag(0)),
		$elm$core$List$head(timeline));
};
var $author$project$Activity$Activity$currentActivityID = function (switchList) {
	var getId = function (_v0) {
		var activityId = _v0.b;
		return activityId;
	};
	return getId(
		$author$project$Activity$Activity$latestSwitch(switchList));
};
var $author$project$Activity$Switching$currentActivityFromApp = function (app) {
	return $author$project$Activity$Activity$currentActivityID(app.timeline);
};
var $author$project$Task$Instance$completed = function (spec) {
	return $author$project$Task$Progress$isMax(
		_Utils_Tuple2(spec.instance.completion, spec._class.completionUnits));
};
var $author$project$Task$Entry$LookupFailure = function (a) {
	return {$: 'LookupFailure', a: a};
};
var $mgold$elm_nonempty_list$List$Nonempty$head = function (_v0) {
	var x = _v0.a;
	var xs = _v0.b;
	return x;
};
var $mgold$elm_nonempty_list$List$Nonempty$tail = function (_v0) {
	var x = _v0.a;
	var xs = _v0.b;
	return xs;
};
var $mgold$elm_nonempty_list$List$Nonempty$toList = function (_v0) {
	var x = _v0.a;
	var xs = _v0.b;
	return A2($elm$core$List$cons, x, xs);
};
var $mgold$elm_nonempty_list$List$Nonempty$concat = function (_v0) {
	var xs = _v0.a;
	var xss = _v0.b;
	var tl = _Utils_ap(
		$mgold$elm_nonempty_list$List$Nonempty$tail(xs),
		$elm$core$List$concat(
			A2($elm$core$List$map, $mgold$elm_nonempty_list$List$Nonempty$toList, xss)));
	var hd = $mgold$elm_nonempty_list$List$Nonempty$head(xs);
	return A2($mgold$elm_nonempty_list$List$Nonempty$Nonempty, hd, tl);
};
var $mgold$elm_nonempty_list$List$Nonempty$concatMap = F2(
	function (f, xs) {
		return $mgold$elm_nonempty_list$List$Nonempty$concat(
			A2($mgold$elm_nonempty_list$List$Nonempty$map, f, xs));
	});
var $author$project$Task$Class$makeFullClass = F3(
	function (parentList, recurrenceRules, _class) {
		return {_class: _class, parents: parentList, recurrence: recurrenceRules};
	});
var $elm_community$result_extra$Result$Extra$partition = function (rs) {
	return A3(
		$elm$core$List$foldr,
		F2(
			function (r, _v0) {
				var succ = _v0.a;
				var err = _v0.b;
				if (r.$ === 'Ok') {
					var v = r.a;
					return _Utils_Tuple2(
						A2($elm$core$List$cons, v, succ),
						err);
				} else {
					var v = r.a;
					return _Utils_Tuple2(
						succ,
						A2($elm$core$List$cons, v, err));
				}
			}),
		_Utils_Tuple2(_List_Nil, _List_Nil),
		rs);
};
var $author$project$Task$Entry$getClassesFromEntries = function (_v0) {
	var entries = _v0.a;
	var classes = _v0.b;
	var appendPropsIfMeaningful = F2(
		function (oldList, newParentProps) {
			return (!_Utils_eq(newParentProps.title, $elm$core$Maybe$Nothing)) ? A2($elm$core$List$cons, newParentProps, oldList) : oldList;
		});
	var traverseFollowerChild = F3(
		function (accumulator, recurrenceRules, child) {
			if (child.$ === 'Singleton') {
				var classID = child.a;
				var _v3 = A2($elm_community$intdict$IntDict$get, classID, classes);
				if (_v3.$ === 'Just') {
					var classSkel = _v3.a;
					return $mgold$elm_nonempty_list$List$Nonempty$fromElement(
						$elm$core$Result$Ok(
							A3($author$project$Task$Class$makeFullClass, accumulator, recurrenceRules, classSkel)));
				} else {
					return $mgold$elm_nonempty_list$List$Nonempty$fromElement(
						$elm$core$Result$Err(
							$author$project$Task$Entry$LookupFailure(classID)));
				}
			} else {
				var followerParent = child.a;
				return A3(
					traverseFollowerParent,
					A2(appendPropsIfMeaningful, accumulator, followerParent.properties),
					recurrenceRules,
					followerParent);
			}
		});
	var traverseFollowerParent = F3(
		function (accumulator, recurrenceRules, parent) {
			return A2(
				$mgold$elm_nonempty_list$List$Nonempty$concatMap,
				A2(traverseFollowerChild, accumulator, recurrenceRules),
				parent.children);
		});
	var traverseLeaderParent = F2(
		function (accumulator, parent) {
			return A2(
				$mgold$elm_nonempty_list$List$Nonempty$concatMap,
				A2(traverseFollowerParent, accumulator, parent.recurrenceRules),
				parent.children);
		});
	var traverseWrapperChild = F2(
		function (accumulator, child) {
			if (child.$ === 'LeaderIsDeeper') {
				var parent = child.a;
				return A2(
					traverseWrapperParent,
					A2(appendPropsIfMeaningful, accumulator, parent.properties),
					parent);
			} else {
				var parent = child.a;
				return A2(
					traverseLeaderParent,
					A2(appendPropsIfMeaningful, accumulator, parent.properties),
					parent);
			}
		});
	var traverseWrapperParent = F2(
		function (accumulator, parent) {
			return A2(
				$mgold$elm_nonempty_list$List$Nonempty$concatMap,
				traverseWrapperChild(accumulator),
				parent.children);
		});
	var traverseRootWrappers = function (entry) {
		return $mgold$elm_nonempty_list$List$Nonempty$toList(
			A2(
				traverseWrapperParent,
				A2(appendPropsIfMeaningful, _List_Nil, entry.properties),
				entry));
	};
	return $elm_community$result_extra$Result$Extra$partition(
		A2($elm$core$List$concatMap, traverseRootWrappers, entries));
};
var $author$project$ZoneHistory$ZoneHistory = F2(
	function (a, b) {
		return {$: 'ZoneHistory', a: a, b: b};
	});
var $author$project$ZoneHistory$init = F2(
	function (now, nowZone) {
		return A2(
			$author$project$ZoneHistory$ZoneHistory,
			nowZone,
			A2(
				$elm$core$Dict$singleton,
				$author$project$SmartTime$Moment$toSmartInt(now),
				nowZone));
	});
var $author$project$SmartTime$Period$instantaneous = function (moment) {
	return A2($author$project$SmartTime$Period$Period, moment, moment);
};
var $author$project$Task$Instance$fillSeries = F3(
	function (_v0, fullClass, seriesRule) {
		var zoneHistory = _v0.a;
		var relevantPeriod = _v0.b;
		return _List_Nil;
	});
var $author$project$Task$Instance$singleClassToActiveInstances = F3(
	function (_v0, allSavedInstances, fullClass) {
		var zoneHistory = _v0.a;
		var relevantPeriod = _v0.b;
		var toFull = function (instanceSkel) {
			return {_class: fullClass._class, instance: instanceSkel, parents: fullClass.parents};
		};
		var savedInstancesWithMatchingClass = A2(
			$elm$core$List$filter,
			function (instance) {
				return _Utils_eq(instance._class, fullClass._class.id);
			},
			$elm_community$intdict$IntDict$values(allSavedInstances));
		var savedInstancesFull = A2($elm$core$List$map, toFull, savedInstancesWithMatchingClass);
		var relevantSeriesMembers = A3(
			$author$project$Task$Instance$fillSeries,
			_Utils_Tuple2(zoneHistory, relevantPeriod),
			fullClass,
			fullClass.recurrence);
		var isRelevant = function (savedInstance) {
			return true;
		};
		var relevantSavedInstances = A2($elm$core$List$filter, isRelevant, savedInstancesFull);
		return _Utils_ap(relevantSavedInstances, relevantSeriesMembers);
	});
var $author$project$Task$Instance$listAllInstances = F3(
	function (fullClasses, savedInstanceSkeletons, timeData) {
		return A2(
			$elm$core$List$concatMap,
			A2($author$project$Task$Instance$singleClassToActiveInstances, timeData, savedInstanceSkeletons),
			fullClasses);
	});
var $author$project$Activity$Switching$instanceListNow = F2(
	function (profile, env) {
		var zoneHistory = A2($author$project$ZoneHistory$init, env.time, env.timeZone);
		var rightNow = $author$project$SmartTime$Period$instantaneous(env.time);
		var _v0 = $author$project$Task$Entry$getClassesFromEntries(
			_Utils_Tuple2(profile.taskEntries, profile.taskClasses));
		var fullClasses = _v0.a;
		var warnings = _v0.b;
		return A3(
			$author$project$Task$Instance$listAllInstances,
			fullClasses,
			profile.taskInstances,
			_Utils_Tuple2(zoneHistory, rightNow));
	});
var $author$project$SmartTime$Human$Calendar$compareLateness = F2(
	function (_v0, _v1) {
		var a = _v0.a;
		var b = _v1.a;
		return A2($elm$core$Basics$compare, a, b);
	});
var $author$project$SmartTime$Moment$compareLateness = F2(
	function (_v0, _v1) {
		var time1 = _v0.a;
		var time2 = _v1.a;
		return A2(
			$elm$core$Basics$compare,
			$author$project$SmartTime$Duration$inMs(time1),
			$author$project$SmartTime$Duration$inMs(time2));
	});
var $author$project$SmartTime$Human$Moment$fromFuzzyWithDefaultTime = F3(
	function (zone, defaultTime, fuzzy) {
		switch (fuzzy.$) {
			case 'DateOnly':
				var date = fuzzy.a;
				return A3($author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, defaultTime);
			case 'Floating':
				var _v1 = fuzzy.a;
				var date = _v1.a;
				var time = _v1.b;
				return A3($author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, time);
			default:
				var moment = fuzzy.a;
				return moment;
		}
	});
var $author$project$SmartTime$Human$Moment$compareFuzzyLateness = F4(
	function (zone, defaultTime, fuzzyA, fuzzyB) {
		var _v0 = _Utils_Tuple2(fuzzyA, fuzzyB);
		if ((_v0.a.$ === 'DateOnly') && (_v0.b.$ === 'DateOnly')) {
			var dateA = _v0.a.a;
			var dateB = _v0.b.a;
			return A2($author$project$SmartTime$Human$Calendar$compareLateness, dateA, dateB);
		} else {
			return A2(
				$author$project$SmartTime$Moment$compareLateness,
				A3($author$project$SmartTime$Human$Moment$fromFuzzyWithDefaultTime, zone, defaultTime, fuzzyA),
				A3($author$project$SmartTime$Human$Moment$fromFuzzyWithDefaultTime, zone, defaultTime, fuzzyB));
		}
	});
var $author$project$Task$Instance$compareSoonness = F3(
	function (zone, taskA, taskB) {
		var _v0 = _Utils_Tuple2(taskA.instance.externalDeadline, taskB.instance.externalDeadline);
		if (_v0.a.$ === 'Just') {
			if (_v0.b.$ === 'Just') {
				var fuzzyMomentA = _v0.a.a;
				var fuzzyMomentB = _v0.b.a;
				return A4($author$project$SmartTime$Human$Moment$compareFuzzyLateness, zone, $author$project$SmartTime$Human$Clock$endOfDay, fuzzyMomentA, fuzzyMomentB);
			} else {
				var _v3 = _v0.b;
				return $elm$core$Basics$LT;
			}
		} else {
			if (_v0.b.$ === 'Nothing') {
				var _v1 = _v0.a;
				var _v2 = _v0.b;
				return $elm$core$Basics$EQ;
			} else {
				var _v4 = _v0.a;
				return $elm$core$Basics$GT;
			}
		}
	});
var $elm$core$List$sortWith = _List_sortWith;
var $author$project$Task$Instance$deepSort = F2(
	function (compareFuncs, listToSort) {
		var deepCompare = F3(
			function (funcs, a, b) {
				deepCompare:
				while (true) {
					if (!funcs.b) {
						return $elm$core$Basics$EQ;
					} else {
						var nextCompareFunc = funcs.a;
						var laterCompareFuncs = funcs.b;
						var check = A2(nextCompareFunc, a, b);
						if (_Utils_eq(check, $elm$core$Basics$EQ)) {
							var $temp$funcs = laterCompareFuncs,
								$temp$a = a,
								$temp$b = b;
							funcs = $temp$funcs;
							a = $temp$a;
							b = $temp$b;
							continue deepCompare;
						} else {
							return check;
						}
					}
				}
			});
		return A2(
			$elm$core$List$sortWith,
			deepCompare(compareFuncs),
			listToSort);
	});
var $author$project$Task$Instance$prioritize = F3(
	function (now, zone, taskList) {
		var comparePropInverted = F3(
			function (prop, a, b) {
				return A2(
					$elm$core$Basics$compare,
					prop(b),
					prop(a));
			});
		var compareProp = F3(
			function (prop, a, b) {
				return A2(
					$elm$core$Basics$compare,
					prop(a),
					prop(b));
			});
		return A2(
			$author$project$Task$Instance$deepSort,
			_List_fromArray(
				[
					$author$project$Task$Instance$compareSoonness(zone)
				]),
			taskList);
	});
var $author$project$Activity$Switching$determineNextTask = F2(
	function (profile, env) {
		return $elm$core$List$head(
			A3(
				$author$project$Task$Instance$prioritize,
				env.time,
				env.timeZone,
				A2(
					$elm$core$List$filter,
					A2($elm$core$Basics$composeR, $author$project$Task$Instance$completed, $elm$core$Basics$not),
					A2($author$project$Activity$Switching$instanceListNow, profile, env))));
	});
var $author$project$Activity$Activity$excusableFor = function (activity) {
	var _v0 = activity.excusable;
	switch (_v0.$) {
		case 'NeverExcused':
			return _Utils_Tuple2(
				$author$project$SmartTime$Human$Duration$Minutes(0),
				$author$project$SmartTime$Human$Duration$Minutes(0));
		case 'TemporarilyExcused':
			var durationPerPeriod = _v0.a;
			return durationPerPeriod;
		default:
			return _Utils_Tuple2(
				$author$project$SmartTime$Human$Duration$Hours(24),
				$author$project$SmartTime$Human$Duration$Hours(24));
	}
};
var $author$project$Activity$Measure$excusableLimit = function (activity) {
	return $author$project$SmartTime$Human$Duration$dur(
		$author$project$Activity$Activity$excusableFor(activity).a);
};
var $author$project$Activity$Measure$excusedUsage = F3(
	function (timeline, now, _v0) {
		var activityID = _v0.a;
		var activity = _v0.b;
		var lastPeriod = A3(
			$author$project$Activity$Measure$relevantTimeline,
			timeline,
			now,
			$author$project$Activity$Activity$excusableFor(activity).a);
		return A3($author$project$Activity$Measure$totalLive, now, lastPeriod, activityID);
	});
var $author$project$Activity$Measure$excusedLeft = F3(
	function (timeline, now, _v0) {
		var activityID = _v0.a;
		var activity = _v0.b;
		return A2(
			$author$project$SmartTime$Duration$difference,
			$author$project$Activity$Measure$excusableLimit(activity),
			A3(
				$author$project$Activity$Measure$excusedUsage,
				timeline,
				now,
				_Utils_Tuple2(activityID, activity)));
	});
var $author$project$SmartTime$Moment$future = F2(
	function (_v0, duration) {
		var time = _v0.a;
		return $author$project$SmartTime$Moment$Moment(
			A2($author$project$SmartTime$Duration$add, time, duration));
	});
var $author$project$Activity$Activity$getActivity = F2(
	function (activityId, activities) {
		var _v0 = A2(
			$elm_community$intdict$IntDict$get,
			$author$project$ID$read(activityId),
			activities);
		if (_v0.$ === 'Just') {
			var activity = _v0.a;
			return activity;
		} else {
			return $author$project$Activity$Activity$defaults($author$project$Activity$Template$DillyDally);
		}
	});
var $author$project$SmartTime$Human$Moment$setTime = F3(
	function (newTime, zone, moment) {
		var _v0 = A2($author$project$SmartTime$Human$Moment$humanize, zone, moment);
		var oldDate = _v0.a;
		return A3($author$project$SmartTime$Human$Moment$fromDateAndTime, zone, oldDate, newTime);
	});
var $author$project$SmartTime$Human$Moment$clockTurnBack = F3(
	function (timeOfDay, zone, moment) {
		var newMoment = A3($author$project$SmartTime$Human$Moment$setTime, timeOfDay, zone, moment);
		return _Utils_eq(
			A2($author$project$SmartTime$Moment$compare, newMoment, moment),
			$author$project$SmartTime$Moment$Earlier) ? newMoment : A2($author$project$SmartTime$Moment$past, newMoment, $author$project$SmartTime$Duration$aDay);
	});
var $author$project$SmartTime$Duration$fromHours = function (_float) {
	return $author$project$SmartTime$Duration$Duration(
		$elm$core$Basics$round(_float * $author$project$SmartTime$Duration$hourLength));
};
var $author$project$Activity$Measure$justToday = F2(
	function (timeline, _v0) {
		var now = _v0.a;
		var zone = _v0.b;
		var threeAM = $author$project$SmartTime$Duration$fromHours(3);
		var last3am = A3($author$project$SmartTime$Human$Moment$clockTurnBack, threeAM, zone, now);
		return A3($author$project$Activity$Measure$timelineLimit, timeline, now, last3am);
	});
var $author$project$Activity$Measure$justTodayTotal = F3(
	function (timeline, env, activityID) {
		var lastPeriod = A2(
			$author$project$Activity$Measure$justToday,
			timeline,
			_Utils_Tuple2(env.time, env.timeZone));
		return A3($author$project$Activity$Measure$totalLive, env.time, lastPeriod, activityID);
	});
var $author$project$Activity$Measure$lastSession = F2(
	function (timeline, old) {
		return $elm$core$List$head(
			A2($author$project$Activity$Measure$sessions, timeline, old));
	});
var $elm_community$list_extra$List$Extra$filterNot = F2(
	function (pred, list) {
		return A2(
			$elm$core$List$filter,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, pred),
			list);
	});
var $author$project$Activity$Switching$multiline = function (inputListOfLists) {
	var unWords = function (wordsList) {
		return $elm$core$String$concat(
			A2($elm$core$List$intersperse, ' ', wordsList));
	};
	var unLines = function (linesList) {
		return $elm$core$String$concat(
			A2(
				$elm$core$List$intersperse,
				'\n',
				A2($elm_community$list_extra$List$Extra$filterNot, $elm$core$String$isEmpty, linesList)));
	};
	return unLines(
		A2($elm$core$List$map, unWords, inputListOfLists));
};
var $author$project$NativeScript$Commands$ns_notify_cancel = _Platform_outgoingPort('ns_notify_cancel', $elm$core$Basics$identity);
var $author$project$NativeScript$Commands$notifyCancel = function (id) {
	return $author$project$NativeScript$Commands$ns_notify_cancel(
		$elm$json$Json$Encode$int(id));
};
var $author$project$NativeScript$Notification$Button = function (a) {
	return {$: 'Button', a: a};
};
var $author$project$NativeScript$Notification$Progress = F2(
	function (a, b) {
		return {$: 'Progress', a: a, b: b};
	});
var $author$project$SmartTime$Human$Duration$withAbbreviation = function (unit) {
	switch (unit.$) {
		case 'Milliseconds':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'ms';
		case 'Seconds':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'sec';
		case 'Minutes':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'min';
		case 'Hours':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'hr';
		default:
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'd';
	}
};
var $author$project$SmartTime$Human$Duration$abbreviatedSpaced = function (humanDurationList) {
	return $elm$core$String$concat(
		A2(
			$elm$core$List$intersperse,
			' ',
			A2($elm$core$List$map, $author$project$SmartTime$Human$Duration$withAbbreviation, humanDurationList)));
};
var $author$project$SmartTime$Human$Duration$breakdownNonzero = function (duration) {
	var makeOptional = function (_v1) {
		var tagger = _v1.a;
		var amount = _v1.b;
		return (amount > 0) ? $elm$core$Maybe$Just(
			tagger(amount)) : $elm$core$Maybe$Nothing;
	};
	var _v0 = $author$project$SmartTime$Duration$breakdown(duration);
	var days = _v0.days;
	var hours = _v0.hours;
	var minutes = _v0.minutes;
	var seconds = _v0.seconds;
	var milliseconds = _v0.milliseconds;
	var maybeList = A2(
		$elm$core$List$map,
		makeOptional,
		_List_fromArray(
			[
				_Utils_Tuple2($author$project$SmartTime$Human$Duration$Days, days),
				_Utils_Tuple2($author$project$SmartTime$Human$Duration$Hours, hours),
				_Utils_Tuple2($author$project$SmartTime$Human$Duration$Minutes, minutes),
				_Utils_Tuple2($author$project$SmartTime$Human$Duration$Seconds, seconds),
				_Utils_Tuple2($author$project$SmartTime$Human$Duration$Milliseconds, milliseconds)
			]));
	return A2($elm$core$List$filterMap, $elm$core$Basics$identity, maybeList);
};
var $author$project$SmartTime$Duration$compare = F2(
	function (_v0, _v1) {
		var int1 = _v0.a;
		var int2 = _v1.a;
		return A2($elm$core$Basics$compare, int1, int2);
	});
var $elm$random$Random$step = F2(
	function (_v0, seed) {
		var generator = _v0.a;
		return generator(seed);
	});
var $elm$random$Random$addOne = function (value) {
	return _Utils_Tuple2(1, value);
};
var $elm$random$Random$Generator = function (a) {
	return {$: 'Generator', a: a};
};
var $elm$random$Random$Seed = F2(
	function (a, b) {
		return {$: 'Seed', a: a, b: b};
	});
var $elm$random$Random$next = function (_v0) {
	var state0 = _v0.a;
	var incr = _v0.b;
	return A2($elm$random$Random$Seed, ((state0 * 1664525) + incr) >>> 0, incr);
};
var $elm$random$Random$peel = function (_v0) {
	var state = _v0.a;
	var word = (state ^ (state >>> ((state >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var $elm$random$Random$float = F2(
	function (a, b) {
		return $elm$random$Random$Generator(
			function (seed0) {
				var seed1 = $elm$random$Random$next(seed0);
				var range = $elm$core$Basics$abs(b - a);
				var n1 = $elm$random$Random$peel(seed1);
				var n0 = $elm$random$Random$peel(seed0);
				var lo = (134217727 & n1) * 1.0;
				var hi = (67108863 & n0) * 1.0;
				var val = ((hi * 134217728.0) + lo) / 9007199254740992.0;
				var scaled = (val * range) + a;
				return _Utils_Tuple2(
					scaled,
					$elm$random$Random$next(seed1));
			});
	});
var $elm$random$Random$getByWeight = F3(
	function (_v0, others, countdown) {
		getByWeight:
		while (true) {
			var weight = _v0.a;
			var value = _v0.b;
			if (!others.b) {
				return value;
			} else {
				var second = others.a;
				var otherOthers = others.b;
				if (_Utils_cmp(
					countdown,
					$elm$core$Basics$abs(weight)) < 1) {
					return value;
				} else {
					var $temp$_v0 = second,
						$temp$others = otherOthers,
						$temp$countdown = countdown - $elm$core$Basics$abs(weight);
					_v0 = $temp$_v0;
					others = $temp$others;
					countdown = $temp$countdown;
					continue getByWeight;
				}
			}
		}
	});
var $elm$random$Random$map = F2(
	function (func, _v0) {
		var genA = _v0.a;
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v1 = genA(seed0);
				var a = _v1.a;
				var seed1 = _v1.b;
				return _Utils_Tuple2(
					func(a),
					seed1);
			});
	});
var $elm$random$Random$weighted = F2(
	function (first, others) {
		var normalize = function (_v0) {
			var weight = _v0.a;
			return $elm$core$Basics$abs(weight);
		};
		var total = normalize(first) + $elm$core$List$sum(
			A2($elm$core$List$map, normalize, others));
		return A2(
			$elm$random$Random$map,
			A2($elm$random$Random$getByWeight, first, others),
			A2($elm$random$Random$float, 0, total));
	});
var $elm$random$Random$uniform = F2(
	function (value, valueList) {
		return A2(
			$elm$random$Random$weighted,
			$elm$random$Random$addOne(value),
			A2($elm$core$List$map, $elm$random$Random$addOne, valueList));
	});
var $elm$random$Random$initialSeed = function (x) {
	var _v0 = $elm$random$Random$next(
		A2($elm$random$Random$Seed, 0, 1013904223));
	var state1 = _v0.a;
	var incr = _v0.b;
	var state2 = (state1 + x) >>> 0;
	return $elm$random$Random$next(
		A2($elm$random$Random$Seed, state2, incr));
};
var $author$project$SmartTime$Moment$useAsRandomSeed = function (givenMoment) {
	return $elm$random$Random$initialSeed(
		$author$project$SmartTime$Moment$toSmartInt(givenMoment));
};
var $author$project$Activity$Switching$pickEncouragementMessage = function (time) {
	var encouragementMessages = A2(
		$elm$random$Random$uniform,
		'Do this later',
		_List_fromArray(
			['You have important goals to meet!', 'Why not put this in your task list for later?', 'This was not part of the plan', 'Get back on task now!']));
	return A2(
		$elm$random$Random$step,
		encouragementMessages,
		$author$project$SmartTime$Moment$useAsRandomSeed(time)).a;
};
var $elm_community$list_extra$List$Extra$takeWhile = function (predicate) {
	var takeWhileMemo = F2(
		function (memo, list) {
			takeWhileMemo:
			while (true) {
				if (!list.b) {
					return $elm$core$List$reverse(memo);
				} else {
					var x = list.a;
					var xs = list.b;
					if (predicate(x)) {
						var $temp$memo = A2($elm$core$List$cons, x, memo),
							$temp$list = xs;
						memo = $temp$memo;
						list = $temp$list;
						continue takeWhileMemo;
					} else {
						return $elm$core$List$reverse(memo);
					}
				}
			}
		});
	return takeWhileMemo(_List_Nil);
};
var $author$project$Activity$Switching$scheduleExcusedReminders = F3(
	function (now, excusedLimit, timeLeft) {
		var write = function (durLeft) {
			return $author$project$SmartTime$Human$Duration$abbreviatedSpaced(
				$author$project$SmartTime$Human$Duration$breakdownNonzero(durLeft));
		};
		var timesUp = A2($author$project$SmartTime$Moment$future, now, timeLeft);
		var halfLeftThisSession = A2($author$project$SmartTime$Duration$scale, timeLeft, 1 / 2);
		var firstIsLess = F2(
			function (first, last) {
				return _Utils_eq(
					A2($author$project$SmartTime$Duration$compare, first, last),
					$elm$core$Basics$LT);
			});
		var firstIsGreater = F2(
			function (first, last) {
				return _Utils_eq(
					A2($author$project$SmartTime$Duration$compare, first, last),
					$elm$core$Basics$GT);
			});
		var gettingCloseList = A2(
			$elm_community$list_extra$List$Extra$takeWhile,
			firstIsGreater(halfLeftThisSession),
			_List_fromArray(
				[
					$author$project$SmartTime$Duration$zero,
					$author$project$SmartTime$Human$Duration$dur(
					$author$project$SmartTime$Human$Duration$Minutes(1)),
					$author$project$SmartTime$Human$Duration$dur(
					$author$project$SmartTime$Human$Duration$Minutes(2)),
					$author$project$SmartTime$Human$Duration$dur(
					$author$project$SmartTime$Human$Duration$Minutes(3)),
					$author$project$SmartTime$Human$Duration$dur(
					$author$project$SmartTime$Human$Duration$Minutes(5)),
					$author$project$SmartTime$Human$Duration$dur(
					$author$project$SmartTime$Human$Duration$Minutes(10)),
					$author$project$SmartTime$Human$Duration$dur(
					$author$project$SmartTime$Human$Duration$Minutes(30))
				]));
		var substantialTimeLeft = A2(
			firstIsGreater,
			timeLeft,
			$author$project$SmartTime$Duration$fromSeconds(30.0));
		var excusedChannel = {description: $elm$core$Maybe$Nothing, id: 'Excused Reminders', importance: $elm$core$Maybe$Nothing, led: $elm$core$Maybe$Nothing, name: 'Excused Reminders', sound: $elm$core$Maybe$Nothing, vibrate: $elm$core$Maybe$Nothing};
		var scratch = $author$project$NativeScript$Notification$build(excusedChannel);
		var encouragementMessages = A2(
			$elm$random$Random$uniform,
			'Get back on task as soon as possible - do this later!',
			_List_fromArray(
				['You have important goals to meet!', 'Why not put this in your task list for later?']));
		var beforeTimesUp = function (timeBefore) {
			return A2($author$project$SmartTime$Moment$past, timesUp, timeBefore);
		};
		var actions = _List_fromArray(
			[
				{
				button: $author$project$NativeScript$Notification$Button('OK I\'m Ready'),
				id: 'BackOnTask',
				launch: false
			}
			]);
		var base = _Utils_update(
			scratch,
			{
				accentColor: $elm$core$Maybe$Just('gold'),
				actions: actions,
				channel: excusedChannel,
				chronometer: $elm$core$Maybe$Just(true),
				countdown: $elm$core$Maybe$Just(true),
				id: $elm$core$Maybe$Just(100),
				when: $elm$core$Maybe$Just(timesUp)
			});
		var buildGettingCloseReminder = function (amountLeft) {
			return _Utils_update(
				base,
				{
					at: $elm$core$Maybe$Just(
						beforeTimesUp(amountLeft)),
					progress: $elm$core$Maybe$Just(
						A2(
							$author$project$NativeScript$Notification$Progress,
							$author$project$SmartTime$Duration$inMs(amountLeft),
							$author$project$SmartTime$Duration$inMs(excusedLimit))),
					subtitle: $elm$core$Maybe$Just(
						'Excused for up to ' + write(excusedLimit)),
					title: $elm$core$Maybe$Just(
						'Finish up! Only ' + (write(amountLeft) + ' left!'))
				});
		};
		var interimReminders = _List_fromArray(
			[
				_Utils_update(
				base,
				{
					at: $elm$core$Maybe$Just(
						A2(
							$author$project$SmartTime$Moment$future,
							now,
							$author$project$SmartTime$Human$Duration$dur(
								$author$project$SmartTime$Human$Duration$Minutes(10)))),
					subtitle: $elm$core$Maybe$Just(
						$author$project$Activity$Switching$pickEncouragementMessage(
							A2(
								$author$project$SmartTime$Moment$future,
								now,
								$author$project$SmartTime$Human$Duration$dur(
									$author$project$SmartTime$Human$Duration$Minutes(10))))),
					title: $elm$core$Maybe$Just('Distraction taken care of?')
				}),
				_Utils_update(
				base,
				{
					at: $elm$core$Maybe$Just(
						A2(
							$author$project$SmartTime$Moment$future,
							now,
							$author$project$SmartTime$Human$Duration$dur(
								$author$project$SmartTime$Human$Duration$Minutes(20)))),
					subtitle: $elm$core$Maybe$Just(
						$author$project$Activity$Switching$pickEncouragementMessage(
							A2(
								$author$project$SmartTime$Moment$future,
								now,
								$author$project$SmartTime$Human$Duration$dur(
									$author$project$SmartTime$Human$Duration$Minutes(20))))),
					title: $elm$core$Maybe$Just('Ready to get back on task?')
				}),
				_Utils_update(
				base,
				{
					at: $elm$core$Maybe$Just(
						A2(
							$author$project$SmartTime$Moment$future,
							now,
							$author$project$SmartTime$Human$Duration$dur(
								$author$project$SmartTime$Human$Duration$Minutes(30)))),
					subtitle: $elm$core$Maybe$Just(
						$author$project$Activity$Switching$pickEncouragementMessage(
							A2(
								$author$project$SmartTime$Moment$future,
								now,
								$author$project$SmartTime$Human$Duration$dur(
									$author$project$SmartTime$Human$Duration$Minutes(30))))),
					title: $elm$core$Maybe$Just('Can this wait?')
				})
			]);
		return substantialTimeLeft ? A2($elm$core$List$map, buildGettingCloseReminder, gettingCloseList) : _List_Nil;
	});
var $author$project$NativeScript$Notification$CustomSound = function (a) {
	return {$: 'CustomSound', a: a};
};
var $author$project$SmartTime$Period$end = function (_v0) {
	var endMoment = _v0.b;
	return endMoment;
};
var $author$project$SmartTime$Period$between = F2(
	function (moment1, moment2) {
		return _Utils_eq(
			A2($author$project$SmartTime$Moment$compare, moment1, moment2),
			$author$project$SmartTime$Moment$Later) ? A2($author$project$SmartTime$Period$Period, moment2, moment1) : A2($author$project$SmartTime$Period$Period, moment1, moment2);
	});
var $author$project$SmartTime$Period$fromStart = F2(
	function (startMoment, duration) {
		return A2(
			$author$project$SmartTime$Period$between,
			startMoment,
			A2($author$project$SmartTime$Moment$future, startMoment, duration));
	});
var $author$project$Activity$Switching$reminderDistance = function (reminderNum) {
	return $author$project$SmartTime$Duration$fromSeconds(60 * reminderNum);
};
var $author$project$Activity$Switching$stopAfterCount = 10;
var $author$project$Activity$Switching$giveUpNotif = function (fireTime) {
	var reminderPeriod = A2(
		$author$project$SmartTime$Period$fromStart,
		fireTime,
		$author$project$Activity$Switching$reminderDistance($author$project$Activity$Switching$stopAfterCount));
	var giveUpChannel = {
		description: $elm$core$Maybe$Just('Lets you know when a previous reminder has exceeded the maximum number of attempts to catch your attention.'),
		id: 'Gave Up Trying To Alert You',
		importance: $elm$core$Maybe$Nothing,
		led: $elm$core$Maybe$Nothing,
		name: 'Gave Up Trying To Alert You',
		sound: $elm$core$Maybe$Just(
			$author$project$NativeScript$Notification$CustomSound('eek')),
		vibrate: $elm$core$Maybe$Nothing
	};
	var base = $author$project$NativeScript$Notification$build(giveUpChannel);
	return _Utils_update(
		base,
		{
			at: $elm$core$Maybe$Just(
				$author$project$SmartTime$Period$end(reminderPeriod)),
			body: $elm$core$Maybe$Just(
				'Gave up after ' + $elm$core$String$fromInt($author$project$Activity$Switching$stopAfterCount)),
			chronometer: $elm$core$Maybe$Just(false),
			countdown: $elm$core$Maybe$Just(false),
			expiresAfter: $elm$core$Maybe$Just(
				$author$project$SmartTime$Duration$fromHours(8)),
			id: $elm$core$Maybe$Just($author$project$Activity$Switching$stopAfterCount + 1),
			subtitle: $elm$core$Maybe$Just('Off Task warnings have failed.'),
			when: $elm$core$Maybe$Just(
				$author$project$SmartTime$Period$end(reminderPeriod))
		});
};
var $author$project$SmartTime$Period$length = function (_v0) {
	var startMoment = _v0.a;
	var endMoment = _v0.b;
	return A2($author$project$SmartTime$Moment$difference, startMoment, endMoment);
};
var $author$project$Activity$Switching$offTaskActions = _List_fromArray(
	[
		{
		button: $author$project$NativeScript$Notification$Button('Snooze'),
		id: 'SnoozeButton',
		launch: false
	},
		{
		button: $author$project$NativeScript$Notification$Button('Go'),
		id: 'LaunchButton',
		launch: true
	},
		{
		button: $author$project$NativeScript$Notification$Button('Zap'),
		id: 'ZapButton',
		launch: false
	}
	]);
var $author$project$NativeScript$Notification$Max = {$: 'Max'};
var $author$project$NativeScript$Notification$CustomVibration = function (a) {
	return {$: 'CustomVibration', a: a};
};
var $elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2($elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var $elm$core$List$repeat = F2(
	function (n, value) {
		return A3($elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var $author$project$Activity$Switching$urgentVibe = function (count) {
	return $author$project$NativeScript$Notification$CustomVibration(
		A2(
			$elm$core$List$repeat,
			count,
			_Utils_Tuple2(
				$author$project$SmartTime$Duration$fromMs(100),
				$author$project$SmartTime$Duration$fromMs(100))));
};
var $author$project$Activity$Switching$offTaskChannel = function (step) {
	var channelName = function () {
		switch (step) {
			case 1:
				return 'Off Task, First Warning';
			case 2:
				return 'Off Task! Second Warning';
			case 3:
				return 'Off Task! Third Warning';
			default:
				return 'Off Task Warnings';
		}
	}();
	return {
		description: $elm$core$Maybe$Just('These reminders are meant to be-in-your-face and annoying, so you don\'t ignore them.'),
		id: 'Off Task Warnings',
		importance: $elm$core$Maybe$Just($author$project$NativeScript$Notification$Max),
		led: $elm$core$Maybe$Nothing,
		name: channelName,
		sound: $elm$core$Maybe$Just(
			$author$project$NativeScript$Notification$CustomSound('eek')),
		vibrate: $elm$core$Maybe$Just(
			$author$project$Activity$Switching$urgentVibe(5 + step))
	};
};
var $author$project$SmartTime$Period$start = function (_v0) {
	var startMoment = _v0.a;
	return startMoment;
};
var $author$project$Activity$Switching$offTaskReminder = F2(
	function (fireTime, reminderNum) {
		var reminderPeriod = A2(
			$author$project$SmartTime$Period$fromStart,
			fireTime,
			$author$project$Activity$Switching$reminderDistance(reminderNum));
		var base = $author$project$NativeScript$Notification$build(
			$author$project$Activity$Switching$offTaskChannel(reminderNum));
		return _Utils_update(
			base,
			{
				accentColor: $elm$core$Maybe$Just('red'),
				actions: $author$project$Activity$Switching$offTaskActions,
				at: $elm$core$Maybe$Just(
					$author$project$SmartTime$Period$end(reminderPeriod)),
				body: $elm$core$Maybe$Just(
					$author$project$Activity$Switching$pickEncouragementMessage(
						$author$project$SmartTime$Period$start(reminderPeriod))),
				chronometer: $elm$core$Maybe$Just(true),
				countdown: $elm$core$Maybe$Just(true),
				expiresAfter: $elm$core$Maybe$Just(
					A2(
						$author$project$SmartTime$Duration$subtract,
						$author$project$SmartTime$Period$length(reminderPeriod),
						$author$project$SmartTime$Duration$fromSeconds(1))),
				id: $elm$core$Maybe$Just(reminderNum),
				subtitle: $elm$core$Maybe$Just(
					'Off Task! Warning ' + $elm$core$String$fromInt(reminderNum)),
				when: $elm$core$Maybe$Just(
					$author$project$SmartTime$Period$end(reminderPeriod))
			});
	});
var $author$project$Activity$Switching$scheduleOffTaskReminders = F2(
	function (nextTask, now) {
		var title = $elm$core$Maybe$Just('Do now: ' + nextTask._class.title);
		return _Utils_ap(
			A2(
				$elm$core$List$map,
				$author$project$Activity$Switching$offTaskReminder(now),
				A2($elm$core$List$range, 0, $author$project$Activity$Switching$stopAfterCount)),
			_List_fromArray(
				[
					$author$project$Activity$Switching$giveUpNotif(now)
				]));
	});
var $author$project$Activity$Switching$onTaskChannel = {
	description: $elm$core$Maybe$Just('Reminders of time passing, as well as progress reports, while on task.'),
	id: 'Task Progress',
	importance: $elm$core$Maybe$Just($author$project$NativeScript$Notification$High),
	led: $elm$core$Maybe$Nothing,
	name: 'Task Progress',
	sound: $elm$core$Maybe$Nothing,
	vibrate: $elm$core$Maybe$Nothing
};
var $author$project$Activity$Switching$scheduleOnTaskReminders = F3(
	function (task, now, timeLeft) {
		var fractionLeft = function (denom) {
			return A2(
				$author$project$SmartTime$Moment$future,
				now,
				A2(
					$author$project$SmartTime$Duration$subtract,
					timeLeft,
					A2($author$project$SmartTime$Duration$scale, timeLeft, 1 / denom)));
		};
		var blank = $author$project$NativeScript$Notification$build($author$project$Activity$Switching$onTaskChannel);
		var reminderBase = _Utils_update(
			blank,
			{
				accentColor: $elm$core$Maybe$Just('green'),
				expiresAfter: $elm$core$Maybe$Just(
					$author$project$SmartTime$Duration$fromMinutes(1)),
				id: $elm$core$Maybe$Just(0),
				when: $elm$core$Maybe$Just(
					A2($author$project$SmartTime$Moment$future, now, timeLeft))
			});
		return _List_fromArray(
			[
				_Utils_update(
				reminderBase,
				{
					at: $elm$core$Maybe$Just(
						fractionLeft(2)),
					body: $elm$core$Maybe$Just('1/2 time left for this task.'),
					progress: $elm$core$Maybe$Just(
						A2($author$project$NativeScript$Notification$Progress, 1, 2)),
					subtitle: $elm$core$Maybe$Just(task._class.title),
					title: $elm$core$Maybe$Just('Half-way done!')
				}),
				_Utils_update(
				reminderBase,
				{
					at: $elm$core$Maybe$Just(
						fractionLeft(3)),
					body: $elm$core$Maybe$Just('1/3 time left for this task.'),
					progress: $elm$core$Maybe$Just(
						A2($author$project$NativeScript$Notification$Progress, 2, 3)),
					subtitle: $elm$core$Maybe$Just(task._class.title),
					title: $elm$core$Maybe$Just('Two-thirds done!')
				}),
				_Utils_update(
				reminderBase,
				{
					at: $elm$core$Maybe$Just(
						fractionLeft(4)),
					body: $elm$core$Maybe$Just('1/4 time left for this task.'),
					progress: $elm$core$Maybe$Just(
						A2($author$project$NativeScript$Notification$Progress, 3, 4)),
					subtitle: $elm$core$Maybe$Just(task._class.title),
					title: $elm$core$Maybe$Just('Three-quarters done!')
				}),
				_Utils_update(
				reminderBase,
				{
					at: $elm$core$Maybe$Just(
						A2($author$project$SmartTime$Moment$future, now, timeLeft)),
					body: $elm$core$Maybe$Just('You have spent all of the time reserved for this task.'),
					subtitle: $elm$core$Maybe$Just(task._class.title),
					title: $elm$core$Maybe$Just('Time\'s up!')
				})
			]);
	});
var $author$project$SmartTime$Human$Duration$withLetter = function (unit) {
	switch (unit.$) {
		case 'Milliseconds':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'ms';
		case 'Seconds':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 's';
		case 'Minutes':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'm';
		case 'Hours':
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'h';
		default:
			var _int = unit.a;
			return $elm$core$String$fromInt(_int) + 'd';
	}
};
var $author$project$SmartTime$Human$Duration$singleLetterSpaced = function (humanDurationList) {
	return $elm$core$String$concat(
		A2(
			$elm$core$List$intersperse,
			' ',
			A2($elm$core$List$map, $author$project$SmartTime$Human$Duration$withLetter, humanDurationList)));
};
var $author$project$Task$Instance$partiallyCompleted = function (spec) {
	return spec.instance.completion > 0;
};
var $author$project$NativeScript$Notification$Low = {$: 'Low'};
var $author$project$Activity$Switching$suggestedTasksChannel = {
	description: $elm$core$Maybe$Just('Other tasks you could start right now.'),
	id: 'Suggested Tasks',
	importance: $elm$core$Maybe$Just($author$project$NativeScript$Notification$Low),
	led: $elm$core$Maybe$Nothing,
	name: 'Suggested Tasks',
	sound: $elm$core$Maybe$Nothing,
	vibrate: $elm$core$Maybe$Nothing
};
var $author$project$NativeScript$Notification$GroupKey = function (a) {
	return {$: 'GroupKey', a: a};
};
var $author$project$Activity$Switching$suggestedTasksGroup = $author$project$NativeScript$Notification$GroupKey('suggestions');
var $author$project$Activity$Switching$suggestedTaskNotif = F2(
	function (now, taskInstance) {
		var base = $author$project$NativeScript$Notification$build($author$project$Activity$Switching$suggestedTasksChannel);
		return _Utils_update(
			base,
			{
				at: $elm$core$Maybe$Just(now),
				body: $elm$core$Maybe$Nothing,
				chronometer: $elm$core$Maybe$Just(false),
				countdown: $elm$core$Maybe$Just(false),
				expiresAfter: $elm$core$Maybe$Just(
					$author$project$SmartTime$Duration$fromHours(8)),
				group: $elm$core$Maybe$Just($author$project$Activity$Switching$suggestedTasksGroup),
				id: $elm$core$Maybe$Just(9000 + taskInstance._class.id),
				progress: $author$project$Task$Instance$partiallyCompleted(taskInstance) ? $elm$core$Maybe$Just(
					A2(
						$author$project$NativeScript$Notification$Progress,
						$author$project$Task$Progress$getPortion(
							$author$project$Task$Instance$instanceProgress(taskInstance)),
						$author$project$Task$Progress$getWhole(
							$author$project$Task$Instance$instanceProgress(taskInstance)))) : $elm$core$Maybe$Nothing,
				title: $elm$core$Maybe$Just(taskInstance._class.title),
				when: $elm$core$Maybe$Nothing
			});
	});
var $author$project$Activity$Switching$suggestedTasks = F2(
	function (tasks, now) {
		return A2(
			$elm$core$List$map,
			$author$project$Activity$Switching$suggestedTaskNotif(now),
			A2($elm$core$List$take, 5, tasks));
	});
var $elm_community$list_extra$List$Extra$dropWhile = F2(
	function (predicate, list) {
		dropWhile:
		while (true) {
			if (!list.b) {
				return _List_Nil;
			} else {
				var x = list.a;
				var xs = list.b;
				if (predicate(x)) {
					var $temp$predicate = predicate,
						$temp$list = xs;
					predicate = $temp$predicate;
					list = $temp$list;
					continue dropWhile;
				} else {
					return list;
				}
			}
		}
	});
var $elm_community$list_extra$List$Extra$dropWhileRight = function (p) {
	return A2(
		$elm$core$List$foldr,
		F2(
			function (x, xs) {
				return (p(x) && $elm$core$List$isEmpty(xs)) ? _List_Nil : A2($elm$core$List$cons, x, xs);
			}),
		_List_Nil);
};
var $author$project$SmartTime$Human$Duration$trim = function (humanDurationList) {
	var isZero = function (humanDuration) {
		_v0$5:
		while (true) {
			switch (humanDuration.$) {
				case 'Days':
					if (!humanDuration.a) {
						return true;
					} else {
						break _v0$5;
					}
				case 'Hours':
					if (!humanDuration.a) {
						return true;
					} else {
						break _v0$5;
					}
				case 'Minutes':
					if (!humanDuration.a) {
						return true;
					} else {
						break _v0$5;
					}
				case 'Seconds':
					if (!humanDuration.a) {
						return true;
					} else {
						break _v0$5;
					}
				default:
					if (!humanDuration.a) {
						return true;
					} else {
						break _v0$5;
					}
			}
		}
		return false;
	};
	return A2(
		$elm_community$list_extra$List$Extra$dropWhileRight,
		isZero,
		A2($elm_community$list_extra$List$Extra$dropWhile, isZero, humanDurationList));
};
var $author$project$SmartTime$Human$Duration$trimToSmall = function (humanDurationList) {
	var trimmed = $author$project$SmartTime$Human$Duration$trim(humanDurationList);
	if ($elm$core$List$isEmpty(trimmed)) {
		var smallestUnit = $elm_community$list_extra$List$Extra$last(humanDurationList);
		var singletonList = A2($elm$core$Maybe$map, $elm$core$List$singleton, smallestUnit);
		return A2($elm$core$Maybe$withDefault, _List_Nil, singletonList);
	} else {
		return trimmed;
	}
};
var $author$project$Activity$Switching$updateSticky = F5(
	function (now, todayTotal, newActivity, status, nextTaskMaybe) {
		var statusChannel = $author$project$NativeScript$Notification$basicChannel('Status');
		var blank = $author$project$NativeScript$Notification$build(statusChannel);
		var actions = _List_fromArray(
			[
				{
				button: $author$project$NativeScript$Notification$Button('Sync Tasks'),
				id: 'sync=marvin',
				launch: false
			},
				{
				button: $author$project$NativeScript$Notification$Button('Complete'),
				id: 'complete=next',
				launch: false
			}
			]);
		return _Utils_update(
			blank,
			{
				actions: actions,
				autoCancel: $elm$core$Maybe$Just(false),
				background_color: $elm$core$Maybe$Nothing,
				badge: $elm$core$Maybe$Nothing,
				body: A2(
					$elm$core$Maybe$map,
					function (nt) {
						return 'Up next:' + nt._class.title;
					},
					nextTaskMaybe),
				body_expanded: $elm$core$Maybe$Nothing,
				chronometer: $elm$core$Maybe$Just(true),
				countdown: $elm$core$Maybe$Nothing,
				detail: $elm$core$Maybe$Nothing,
				icon: $elm$core$Maybe$Nothing,
				id: $elm$core$Maybe$Just(42),
				ongoing: $elm$core$Maybe$Just(true),
				privacy: $elm$core$Maybe$Nothing,
				progress: $elm$core$Maybe$Nothing,
				silhouetteIcon: $elm$core$Maybe$Nothing,
				status_icon: $elm$core$Maybe$Nothing,
				status_text_size: $elm$core$Maybe$Nothing,
				subtitle: $elm$core$Maybe$Just(status),
				title: $elm$core$Maybe$Just(
					$author$project$Activity$Activity$getName(newActivity)),
				title_expanded: $elm$core$Maybe$Nothing,
				update: $elm$core$Maybe$Nothing,
				useHTML: $elm$core$Maybe$Nothing,
				when: $elm$core$Maybe$Just(
					A2($author$project$SmartTime$Moment$past, now, todayTotal))
			});
	});
var $author$project$Activity$Switching$switchActivity = F3(
	function (newActivityID, app, env) {
		var suggestions = A2(
			$author$project$Activity$Switching$suggestedTasks,
			A2($author$project$Activity$Switching$instanceListNow, app, env),
			env.time);
		var statusIDs = _List_fromArray(
			[42]);
		var popup = function (message) {
			return $author$project$External$Commands$toast(
				$author$project$Activity$Switching$multiline(message));
		};
		var onTaskReminderIDs = _List_fromArray(
			[0]);
		var oldActivityID = $author$project$Activity$Switching$currentActivityFromApp(app);
		var updatedApp = _Utils_eq(newActivityID, oldActivityID) ? app : _Utils_update(
			app,
			{
				timeline: A2(
					$elm$core$List$cons,
					A2($author$project$Activity$Activity$Switch, env.time, newActivityID),
					app.timeline)
			});
		var todayTotal = A3($author$project$Activity$Measure$justTodayTotal, updatedApp.timeline, env, newActivityID);
		var oldActivity = A2(
			$author$project$Activity$Activity$getActivity,
			oldActivityID,
			$author$project$Activity$Activity$allActivities(app.activities));
		var offTaskReminderIDs = _List_fromArray(
			[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
		var newActivity = A2(
			$author$project$Activity$Activity$getActivity,
			newActivityID,
			$author$project$Activity$Activity$allActivities(app.activities));
		var lastSession = A2($author$project$Activity$Measure$lastSession, updatedApp.timeline, oldActivityID);
		var formatDuration = function (givenDur) {
			return $author$project$SmartTime$Human$Duration$singleLetterSpaced(
				$author$project$SmartTime$Human$Duration$trimToSmall(
					$author$project$SmartTime$Human$Duration$breakdownHMS(givenDur)));
		};
		var sessionTotalString = formatDuration(
			A2($elm$core$Maybe$withDefault, $author$project$SmartTime$Duration$zero, lastSession));
		var todayTotalString = formatDuration(todayTotal);
		var excusedReminderIDs = _List_fromArray(
			[100]);
		var describeTodayTotal = $author$project$SmartTime$Duration$isPositive(todayTotal) ? _List_fromArray(
			['So far', todayTotalString, 'today']) : _List_Nil;
		var cancelAll = function (idList) {
			return $elm$core$Platform$Cmd$batch(
				A2($elm$core$List$map, $author$project$NativeScript$Commands$notifyCancel, idList));
		};
		var _v0 = _Utils_Tuple2(
			$author$project$Activity$Activity$getName(oldActivity),
			$author$project$Activity$Activity$getName(newActivity));
		var oldName = _v0.a;
		var newName = _v0.b;
		var _v1 = A2($author$project$Activity$Switching$determineNextTask, app, env);
		if (_v1.$ === 'Nothing') {
			return _Utils_Tuple2(
				updatedApp,
				$elm$core$Platform$Cmd$batch(
					_List_fromArray(
						[
							popup(
							_List_fromArray(
								[
									_List_fromArray(
									[oldName, 'stopped:', sessionTotalString]),
									_List_fromArray(
									[oldName, '➤', newName]),
									describeTodayTotal
								])),
							$author$project$NativeScript$Commands$notify(
							_Utils_ap(
								_List_fromArray(
									[
										A5($author$project$Activity$Switching$updateSticky, env.time, todayTotal, newActivity, '✔️ All Done', $elm$core$Maybe$Nothing)
									]),
								suggestions)),
							cancelAll(
							_Utils_ap(offTaskReminderIDs, onTaskReminderIDs))
						])));
		} else {
			var nextTask = _v1.a;
			var _v2 = nextTask._class.activity;
			if (_v2.$ === 'Nothing') {
				return _Utils_Tuple2(
					updatedApp,
					$elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								popup(
								_List_fromArray(
									[
										_List_fromArray(
										['❌ Next Task has no Activity! ']),
										_List_fromArray(
										[oldName, 'stopped:', sessionTotalString]),
										_List_fromArray(
										[oldName, '➤', newName]),
										describeTodayTotal
									])),
								$author$project$NativeScript$Commands$notify(
								_Utils_ap(
									_List_fromArray(
										[
											A5(
											$author$project$Activity$Switching$updateSticky,
											env.time,
											todayTotal,
											newActivity,
											'❌ Unknown - No Activity',
											$elm$core$Maybe$Just(nextTask))
										]),
									_Utils_ap(
										A2($author$project$Activity$Switching$scheduleOffTaskReminders, nextTask, env.time),
										suggestions))),
								cancelAll(
								_Utils_ap(offTaskReminderIDs, onTaskReminderIDs))
							])));
			} else {
				var nextActivity = _v2.a;
				var excusedUsage = A3(
					$author$project$Activity$Measure$excusedUsage,
					updatedApp.timeline,
					env.time,
					_Utils_Tuple2(newActivityID, newActivity));
				var excusedUsageString = formatDuration(excusedUsage);
				var excusedLeft = A3(
					$author$project$Activity$Measure$excusedLeft,
					updatedApp.timeline,
					env.time,
					_Utils_Tuple2(
						newActivityID,
						A2(
							$author$project$Activity$Activity$getActivity,
							newActivityID,
							$author$project$Activity$Activity$allActivities(app.activities))));
				var describeExcusedUsage = $author$project$SmartTime$Duration$isPositive(excusedUsage) ? _List_fromArray(
					['Already used', excusedUsageString]) : _List_Nil;
				if (_Utils_eq(nextActivity, newActivityID)) {
					var timeSpent = A3($author$project$Activity$Measure$totalLive, env.time, updatedApp.timeline, newActivityID);
					var timeRemaining = A2($author$project$SmartTime$Duration$subtract, nextTask._class.maxEffort, timeSpent);
					return _Utils_Tuple2(
						updatedApp,
						$elm$core$Platform$Cmd$batch(
							_List_fromArray(
								[
									popup(
									_List_fromArray(
										[
											_List_fromArray(
											[oldName, 'stopped:', sessionTotalString]),
											_List_fromArray(
											[oldName, '➤', newName, '✔️']),
											describeTodayTotal
										])),
									$author$project$NativeScript$Commands$notify(
									_Utils_ap(
										_List_fromArray(
											[
												A5(
												$author$project$Activity$Switching$updateSticky,
												env.time,
												todayTotal,
												newActivity,
												'✔️ On Task',
												$elm$core$Maybe$Just(nextTask))
											]),
										_Utils_ap(
											A3($author$project$Activity$Switching$scheduleOnTaskReminders, nextTask, env.time, timeRemaining),
											suggestions))),
									cancelAll(
									_Utils_ap(offTaskReminderIDs, excusedReminderIDs))
								])));
				} else {
					if ($author$project$SmartTime$Duration$isPositive(excusedLeft)) {
						return _Utils_Tuple2(
							updatedApp,
							$elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										popup(
										_List_fromArray(
											[
												_List_fromArray(
												[oldName, 'stopped:', sessionTotalString]),
												_List_fromArray(
												[oldName, '➤', newName, '❌']),
												describeExcusedUsage
											])),
										$author$project$NativeScript$Commands$notify(
										_Utils_ap(
											_List_fromArray(
												[
													A5(
													$author$project$Activity$Switching$updateSticky,
													env.time,
													todayTotal,
													newActivity,
													'⏸ Off Task (Excused)',
													$elm$core$Maybe$Just(nextTask))
												]),
											_Utils_ap(
												A3(
													$author$project$Activity$Switching$scheduleExcusedReminders,
													env.time,
													$author$project$Activity$Measure$excusableLimit(newActivity),
													excusedLeft),
												_Utils_ap(
													A2(
														$author$project$Activity$Switching$scheduleOffTaskReminders,
														nextTask,
														A2($author$project$SmartTime$Moment$future, env.time, excusedLeft)),
													suggestions)))),
										cancelAll(
										_Utils_ap(offTaskReminderIDs, onTaskReminderIDs))
									])));
					} else {
						return _Utils_Tuple2(
							updatedApp,
							$elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										popup(
										_List_fromArray(
											[
												_List_fromArray(
												[oldName, 'stopped:', sessionTotalString]),
												_List_fromArray(
												[oldName, '➤', newName, '❌']),
												_List_fromArray(
												['Previously excused for', excusedUsageString])
											])),
										$author$project$NativeScript$Commands$notify(
										_Utils_ap(
											_List_fromArray(
												[
													A5(
													$author$project$Activity$Switching$updateSticky,
													env.time,
													todayTotal,
													newActivity,
													'❌ Off Task',
													$elm$core$Maybe$Just(nextTask))
												]),
											_Utils_ap(
												A2($author$project$Activity$Switching$scheduleOffTaskReminders, nextTask, env.time),
												suggestions))),
										cancelAll(
										_Utils_ap(onTaskReminderIDs, excusedReminderIDs))
									])));
					}
				}
			}
		}
	});
var $author$project$External$Tasker$variableOut = _Platform_outgoingPort(
	'variableOut',
	function ($) {
		var a = $.a;
		var b = $.b;
		return A2(
			$elm$json$Json$Encode$list,
			$elm$core$Basics$identity,
			_List_fromArray(
				[
					$elm$json$Json$Encode$string(a),
					$elm$json$Json$Encode$string(b)
				]));
	});
var $author$project$TimeTracker$update = F4(
	function (msg, state, app, env) {
		switch (msg.$) {
			case 'NoOp':
				return _Utils_Tuple3(state, app, $elm$core$Platform$Cmd$none);
			case 'StartTracking':
				var activityId = msg.a;
				var _v1 = A3($author$project$Activity$Switching$switchActivity, activityId, app, env);
				var updatedApp = _v1.a;
				var cmds = _v1.b;
				return _Utils_Tuple3(
					state,
					updatedApp,
					$elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								cmds,
								$author$project$External$Tasker$variableOut(
								_Utils_Tuple2(
									'activities',
									A2(
										$elm$json$Json$Encode$encode,
										0,
										A2($author$project$TimeTracker$exportActivityViewModel, updatedApp, env))))
							])));
			default:
				return _Utils_Tuple3(
					state,
					app,
					$author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'activities',
							A2(
								$elm$json$Json$Encode$encode,
								0,
								A2($author$project$TimeTracker$exportActivityViewModel, app, env)))));
		}
	});
var $author$project$TaskList$UpdateProgress = F2(
	function (a, b) {
		return {$: 'UpdateProgress', a: a, b: b};
	});
var $author$project$TaskList$instanceListNow = F2(
	function (profile, env) {
		var zoneHistory = A2($author$project$ZoneHistory$init, env.time, env.timeZone);
		var rightNow = $author$project$SmartTime$Period$instantaneous(env.time);
		var _v0 = $author$project$Task$Entry$getClassesFromEntries(
			_Utils_Tuple2(profile.taskEntries, profile.taskClasses));
		var fullClasses = _v0.a;
		var warnings = _v0.b;
		return A3(
			$author$project$Task$Instance$listAllInstances,
			fullClasses,
			profile.taskInstances,
			_Utils_Tuple2(zoneHistory, rightNow));
	});
var $author$project$TaskList$urlTriggers = F2(
	function (profile, env) {
		var triggerEntry = function (fullInstance) {
			return _Utils_Tuple2(
				fullInstance._class.title,
				A2(
					$author$project$TaskList$UpdateProgress,
					fullInstance,
					$author$project$Task$Progress$getWhole(
						$author$project$Task$Instance$instanceProgress(fullInstance))));
		};
		var noNextTaskEntry = _List_fromArray(
			[
				_Utils_Tuple2('next', $author$project$TaskList$NoOp)
			]);
		var buildNextTaskEntry = function (nextTaskFullInstance) {
			return _List_fromArray(
				[
					_Utils_Tuple2(
					'next',
					A2(
						$author$project$TaskList$UpdateProgress,
						nextTaskFullInstance,
						$author$project$Task$Progress$getWhole(
							$author$project$Task$Instance$instanceProgress(nextTaskFullInstance))))
				]);
		};
		var nextTaskEntry = A2(
			$elm$core$Maybe$map,
			buildNextTaskEntry,
			A2($author$project$Activity$Switching$determineNextTask, profile, env));
		var allFullTaskInstances = A2($author$project$TaskList$instanceListNow, profile, env);
		var tasksPairedWithNames = A2($elm$core$List$map, triggerEntry, allFullTaskInstances);
		var allEntries = _Utils_ap(
			A2($elm$core$Maybe$withDefault, noNextTaskEntry, nextTaskEntry),
			tasksPairedWithNames);
		return _List_fromArray(
			[
				_Utils_Tuple2(
				'complete',
				$elm$core$Dict$fromList(allEntries))
			]);
	});
var $author$project$TimeTracker$ExportVM = {$: 'ExportVM'};
var $author$project$TimeTracker$StartTracking = function (a) {
	return {$: 'StartTracking', a: a};
};
var $author$project$TimeTracker$urlTriggers = function (app) {
	var entriesPerActivity = function (_v0) {
		var id = _v0.a;
		var activity = _v0.b;
		return _Utils_ap(
			A2(
				$elm$core$List$map,
				function (nm) {
					return _Utils_Tuple2(
						nm,
						$author$project$TimeTracker$StartTracking(
							$author$project$ID$tag(id)));
				},
				activity.names),
			A2(
				$elm$core$List$map,
				function (nm) {
					return _Utils_Tuple2(
						$elm$core$String$toLower(nm),
						$author$project$TimeTracker$StartTracking(
							$author$project$ID$tag(id)));
				},
				activity.names));
	};
	var activitiesWithNames = $elm$core$List$concat(
		A2(
			$elm$core$List$map,
			entriesPerActivity,
			$elm_community$intdict$IntDict$toList(
				$author$project$Activity$Activity$allActivities(app.activities))));
	return _List_fromArray(
		[
			_Utils_Tuple2(
			'start',
			$elm$core$Dict$fromList(activitiesWithNames)),
			_Utils_Tuple2(
			'stop',
			$elm$core$Dict$fromList(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'stop',
						$author$project$TimeTracker$StartTracking($author$project$Activity$Activity$dummy))
					]))),
			_Utils_Tuple2(
			'export',
			$elm$core$Dict$fromList(
				_List_fromArray(
					[
						_Utils_Tuple2('all', $author$project$TimeTracker$ExportVM)
					])))
		]);
};
var $author$project$Main$handleUrlTriggers = F2(
	function (rawUrl, model) {
		var profile = model.profile;
		var environment = model.environment;
		var wrapMsgs = F2(
			function (tagger, _v28) {
				var key = _v28.a;
				var dict = _v28.b;
				return _Utils_Tuple2(
					key,
					A2(
						$elm$core$Dict$map,
						F2(
							function (_v27, msg) {
								return tagger(msg);
							}),
						dict));
			});
		var url = $author$project$Main$bypassFakeFragment(rawUrl);
		var removeTriggersFromUrl = function () {
			var _v26 = environment.navkey;
			if (_v26.$ === 'Just') {
				var navkey = _v26.a;
				return A2(
					$elm$browser$Browser$Navigation$replaceUrl,
					navkey,
					$elm$url$Url$toString(
						_Utils_update(
							url,
							{query: $elm$core$Maybe$Nothing})));
			} else {
				return $elm$core$Platform$Cmd$none;
			}
		}();
		var normalizedUrl = _Utils_update(
			url,
			{path: ''});
		var fancyRecursiveParse = function (checkList) {
			fancyRecursiveParse:
			while (true) {
				if (checkList.b) {
					var _v14 = checkList.a;
					var triggerName = _v14.a;
					var triggerValues = _v14.b;
					var rest = checkList.b;
					var _v15 = A2(
						$elm$url$Url$Parser$parse,
						$elm$url$Url$Parser$query(
							A2($elm$url$Url$Parser$Query$enum, triggerName, triggerValues)),
						normalizedUrl);
					if (_v15.$ === 'Nothing') {
						var $temp$checkList = rest;
						checkList = $temp$checkList;
						continue fancyRecursiveParse;
					} else {
						if (_v15.a.$ === 'Nothing') {
							var _v16 = _v15.a;
							var $temp$checkList = rest;
							checkList = $temp$checkList;
							continue fancyRecursiveParse;
						} else {
							var match = _v15.a;
							return $elm$core$Maybe$Just(match);
						}
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		};
		var createQueryParsers = function (_v25) {
			var key = _v25.a;
			var values = _v25.b;
			return A2($elm$url$Url$Parser$Query$enum, key, values);
		};
		var allTriggers = _Utils_ap(
			A2(
				$elm$core$List$map,
				wrapMsgs($author$project$Main$TaskListMsg),
				A2($author$project$TaskList$urlTriggers, profile, environment)),
			_Utils_ap(
				A2(
					$elm$core$List$map,
					wrapMsgs($author$project$Main$TimeTrackerMsg),
					$author$project$TimeTracker$urlTriggers(profile)),
				_List_fromArray(
					[
						_Utils_Tuple2(
						'sync',
						$elm$core$Dict$fromList(
							_List_fromArray(
								[
									_Utils_Tuple2(
									'todoist',
									$author$project$Main$ThirdPartySync($author$project$Main$Todoist)),
									_Utils_Tuple2(
									'marvin',
									$author$project$Main$ThirdPartySync($author$project$Main$Marvin))
								]))),
						_Utils_Tuple2(
						'clearerrors',
						$elm$core$Dict$fromList(
							_List_fromArray(
								[
									_Utils_Tuple2('clearerrors', $author$project$Main$ClearErrors)
								])))
					])));
		var parseList = A2(
			$elm$core$List$map,
			$elm$url$Url$Parser$query,
			A2($elm$core$List$map, createQueryParsers, allTriggers));
		var parsed = A2(
			$elm$url$Url$Parser$parse,
			$elm$url$Url$Parser$oneOf(parseList),
			normalizedUrl);
		var _v17 = fancyRecursiveParse(allTriggers);
		if (_v17.$ === 'Just') {
			var parsedUrlSuccessfully = _v17.a;
			var _v18 = _Utils_Tuple2(parsedUrlSuccessfully, normalizedUrl.query);
			if (_v18.a.$ === 'Just') {
				if (_v18.b.$ === 'Just') {
					var triggerMsg = _v18.a.a;
					var _v19 = A2($author$project$Main$update, triggerMsg, model);
					var newModel = _v19.a;
					var newCmd = _v19.b;
					var newCmdWithUrlCleaner = $elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[newCmd, removeTriggersFromUrl]));
					return _Utils_Tuple2(newModel, newCmdWithUrlCleaner);
				} else {
					var triggerMsg = _v18.a.a;
					var _v21 = _v18.b;
					var problemText = 'Handle URL Triggers: impossible situation. No query (Nothing) but we still successfully parsed it!';
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								profile: A2($author$project$Profile$saveError, profile, problemText)
							}),
						$author$project$External$Commands$toast(problemText));
				}
			} else {
				if (_v18.b.$ === 'Just') {
					var _v20 = _v18.a;
					var query = _v18.b.a;
					var problemText = 'Handle URL Triggers: none of  ' + ($elm$core$String$fromInt(
						$elm$core$List$length(parseList)) + (' parsers matched key and value: ' + query));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								profile: A2($author$project$Profile$saveError, profile, problemText)
							}),
						$author$project$External$Commands$toast(problemText));
				} else {
					var _v22 = _v18.a;
					var _v23 = _v18.b;
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			}
		} else {
			var _v24 = normalizedUrl.query;
			if (_v24.$ === 'Nothing') {
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			} else {
				var queriesPresent = _v24.a;
				var problemText = 'URL: not sure what to do with: ' + (queriesPresent + ', so I just left it there. Is the trigger misspelled?');
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							profile: A2($author$project$Profile$saveError, profile, problemText)
						}),
					$author$project$External$Commands$toast(problemText));
			}
		}
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		var viewState = model.viewState;
		var profile = model.profile;
		var environment = model.environment;
		var justSetEnv = function (newEnv) {
			return _Utils_Tuple2(
				A3($author$project$Main$Model, viewState, profile, newEnv),
				$elm$core$Platform$Cmd$none);
		};
		var justRunCommand = function (command) {
			return _Utils_Tuple2(model, command);
		};
		switch (msg.$) {
			case 'ClearErrors':
				return _Utils_Tuple2(
					A3(
						$author$project$Main$Model,
						viewState,
						_Utils_update(
							profile,
							{errors: _List_Nil}),
						environment),
					$elm$core$Platform$Cmd$none);
			case 'ThirdPartySync':
				var service = msg.a;
				if (service.$ === 'Todoist') {
					return justRunCommand(
						A2(
							$elm$core$Platform$Cmd$map,
							$author$project$Main$ThirdPartyServerResponded,
							A2(
								$elm$core$Platform$Cmd$map,
								$author$project$Main$TodoistServer,
								$author$project$Integrations$Todoist$fetchUpdates(profile.todoist))));
				} else {
					return justRunCommand(
						$elm$core$Platform$Cmd$batch(
							_List_fromArray(
								[
									A2(
									$elm$core$Platform$Cmd$map,
									$author$project$Main$ThirdPartyServerResponded,
									A2($elm$core$Platform$Cmd$map, $author$project$Main$MarvinServer, $author$project$Integrations$Marvin$getLabelsCmd)),
									$author$project$External$Commands$toast('Reached out to Marvin server...')
								])));
				}
			case 'ThirdPartyServerResponded':
				if (msg.a.$ === 'TodoistServer') {
					var response = msg.a.a;
					var syncStatusChannel = A2(
						$author$project$NativeScript$Notification$setChannelImportance,
						$author$project$NativeScript$Notification$High,
						A2(
							$author$project$NativeScript$Notification$setChannelDescription,
							'Lets you know what happened the last time we tried to sync with online servers.',
							$author$project$NativeScript$Notification$basicChannel('Sync Status')));
					var _v2 = A2($author$project$Integrations$Todoist$handle, response, profile);
					var newAppData = _v2.a;
					var whatHappened = _v2.b;
					var notification = A2(
						$author$project$NativeScript$Notification$setBody,
						whatHappened,
						A2(
							$author$project$NativeScript$Notification$setSubtitle,
							'Sync Status',
							A2(
								$author$project$NativeScript$Notification$setTitle,
								'Todoist Response',
								A2(
									$author$project$NativeScript$Notification$setExpiresAfter,
									$author$project$SmartTime$Duration$fromMinutes(1),
									A2(
										$author$project$NativeScript$Notification$setID,
										23,
										$author$project$NativeScript$Notification$build(syncStatusChannel))))));
					return _Utils_Tuple2(
						A3($author$project$Main$Model, viewState, newAppData, environment),
						$author$project$NativeScript$Commands$notify(
							_List_fromArray(
								[notification])));
				} else {
					var response = msg.a.a;
					var _v3 = A3(
						$author$project$Integrations$Marvin$handle,
						$author$project$SmartTime$Moment$toSmartInt(environment.time),
						profile,
						response);
					var _v4 = _v3.a;
					var newItems = _v4.a;
					var newActivities = _v4.b;
					var whatHappened = _v3.b;
					var nextStep = _v3.c;
					var newProfile1WithItems = _Utils_update(
						profile,
						{
							activities: A2($elm$core$Maybe$withDefault, profile.activities, newActivities),
							taskClasses: A2($elm_community$intdict$IntDict$union, profile.taskClasses, newItems.taskClasses),
							taskEntries: _Utils_ap(profile.taskEntries, newItems.taskEntries),
							taskInstances: A2($elm_community$intdict$IntDict$union, profile.taskInstances, newItems.taskInstances)
						});
					var newProfile2WithErrors = A2($author$project$Profile$saveError, newProfile1WithItems, 'Here\'s what happened: \n' + whatHappened);
					return _Utils_Tuple2(
						A3($author$project$Main$Model, viewState, newProfile2WithErrors, environment),
						$elm$core$Platform$Cmd$batch(
							_List_fromArray(
								[
									A2(
									$elm$core$Platform$Cmd$map,
									$author$project$Main$ThirdPartyServerResponded,
									A2($elm$core$Platform$Cmd$map, $author$project$Main$MarvinServer, nextStep)),
									$author$project$External$Commands$toast('Got Response from Marvin.')
								])));
				}
			case 'Link':
				var urlRequest = msg.a;
				if (urlRequest.$ === 'Internal') {
					var url = urlRequest.a;
					var _v6 = environment.navkey;
					if (_v6.$ === 'Just') {
						var navkey = _v6.a;
						return justRunCommand(
							A2(
								$elm$browser$Browser$Navigation$pushUrl,
								navkey,
								$elm$url$Url$toString(url)));
					} else {
						return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
					}
				} else {
					var href = urlRequest.a;
					return justRunCommand(
						$elm$browser$Browser$Navigation$load(href));
				}
			case 'NewUrl':
				var url = msg.a;
				var _v7 = A2($author$project$Main$handleUrlTriggers, url, model);
				var modelAfter = _v7.a;
				var effectsAfter = _v7.b;
				return _Utils_Tuple2(
					_Utils_update(
						modelAfter,
						{
							viewState: $author$project$Main$viewUrl(url)
						}),
					effectsAfter);
			case 'TaskListMsg':
				var subMsg = msg.a;
				var subViewState = function () {
					var _v9 = viewState.primaryView;
					if (_v9.$ === 'TaskList') {
						var subView = _v9.a;
						return subView;
					} else {
						return $author$project$TaskList$defaultView;
					}
				}();
				var _v8 = A4($author$project$TaskList$update, subMsg, subViewState, profile, environment);
				var newState = _v8.a;
				var newApp = _v8.b;
				var newCommand = _v8.c;
				return _Utils_Tuple2(
					A3(
						$author$project$Main$Model,
						A2(
							$author$project$Main$ViewState,
							$author$project$Main$TaskList(newState),
							0),
						newApp,
						environment),
					A2($elm$core$Platform$Cmd$map, $author$project$Main$TaskListMsg, newCommand));
			case 'TimeTrackerMsg':
				var subMsg = msg.a;
				var subViewState = function () {
					var _v11 = viewState.primaryView;
					if (_v11.$ === 'TimeTracker') {
						var subView = _v11.a;
						return subView;
					} else {
						return $author$project$TimeTracker$defaultView;
					}
				}();
				var _v10 = A4($author$project$TimeTracker$update, subMsg, subViewState, profile, environment);
				var newState = _v10.a;
				var newApp = _v10.b;
				var newCommand = _v10.c;
				return _Utils_Tuple2(
					A3(
						$author$project$Main$Model,
						A2(
							$author$project$Main$ViewState,
							$author$project$Main$TimeTracker(newState),
							0),
						newApp,
						environment),
					A2($elm$core$Platform$Cmd$map, $author$project$Main$TimeTrackerMsg, newCommand));
			case 'NewAppData':
				var newJSON = msg.a;
				var maybeNewApp = $author$project$Main$profileFromJson(newJSON);
				switch (maybeNewApp.$) {
					case 'Success':
						var savedAppData = maybeNewApp.a;
						return _Utils_Tuple2(
							A3($author$project$Main$Model, viewState, savedAppData, environment),
							$author$project$External$Commands$toast('Synced with another browser tab!'));
					case 'WithWarnings':
						var warnings = maybeNewApp.a;
						var savedAppData = maybeNewApp.b;
						return _Utils_Tuple2(
							A3(
								$author$project$Main$Model,
								viewState,
								A2($author$project$Profile$saveWarnings, savedAppData, warnings),
								environment),
							$elm$core$Platform$Cmd$none);
					case 'Errors':
						var errors = maybeNewApp.a;
						return _Utils_Tuple2(
							A3(
								$author$project$Main$Model,
								viewState,
								A2($author$project$Profile$saveDecodeErrors, profile, errors),
								environment),
							$elm$core$Platform$Cmd$none);
					default:
						return _Utils_Tuple2(
							A3(
								$author$project$Main$Model,
								viewState,
								A2($author$project$Profile$saveError, profile, 'Got bad JSON from cross-sync'),
								environment),
							$elm$core$Platform$Cmd$none);
				}
			default:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$ID$encode = function (_v0) {
	var _int = _v0.a;
	return $elm$json$Json$Encode$int(_int);
};
var $author$project$Porting$encodeDuration = function (dur) {
	return $elm$json$Json$Encode$int(
		$author$project$SmartTime$Duration$inMs(dur));
};
var $author$project$Task$Class$encodeRelativeTiming = function (relativeTaskTiming) {
	if (relativeTaskTiming.$ === 'FromDeadline') {
		var duration = relativeTaskTiming.a;
		return $author$project$Porting$encodeDuration(duration);
	} else {
		var duration = relativeTaskTiming.a;
		return $author$project$Porting$encodeDuration(duration);
	}
};
var $author$project$Task$Progress$encodeUnit = function (unit) {
	switch (unit.$) {
		case 'None':
			return $elm$json$Json$Encode$string('None');
		case 'Permille':
			return $elm$json$Json$Encode$string('Permille');
		case 'Percent':
			return $elm$json$Json$Encode$string('Percent');
		case 'Word':
			var targetWordCount = unit.a;
			return $elm$json$Json$Encode$int(targetWordCount);
		case 'Minute':
			var targetTotalMinutes = unit.a;
			return $elm$json$Json$Encode$int(targetTotalMinutes);
		default:
			var _v1 = unit.a;
			var string1 = _v1.a;
			var string2 = _v1.b;
			var _int = unit.b;
			return _Debug_todo(
				'Task.Progress',
				{
					start: {line: 71, column: 13},
					end: {line: 71, column: 23}
				})('Encode CustomUnits');
	}
};
var $author$project$Task$Class$encodeClass = function (taskClass) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				$elm$json$Json$Encode$string(taskClass.title)),
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(taskClass.id)),
				_Utils_Tuple2(
				'activity',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $author$project$ID$encode, taskClass.activity)),
				_Utils_Tuple2(
				'completionUnits',
				$author$project$Task$Progress$encodeUnit(taskClass.completionUnits)),
				_Utils_Tuple2(
				'minEffort',
				$author$project$Porting$encodeDuration(taskClass.minEffort)),
				_Utils_Tuple2(
				'predictedEffort',
				$author$project$Porting$encodeDuration(taskClass.predictedEffort)),
				_Utils_Tuple2(
				'maxEffort',
				$author$project$Porting$encodeDuration(taskClass.maxEffort)),
				_Utils_Tuple2(
				'defaultExternalDeadline',
				A2($elm$json$Json$Encode$list, $author$project$Task$Class$encodeRelativeTiming, taskClass.defaultExternalDeadline)),
				_Utils_Tuple2(
				'defaultStartBy',
				A2($elm$json$Json$Encode$list, $author$project$Task$Class$encodeRelativeTiming, taskClass.defaultStartBy)),
				_Utils_Tuple2(
				'defaultFinishBy',
				A2($elm$json$Json$Encode$list, $author$project$Task$Class$encodeRelativeTiming, taskClass.defaultFinishBy)),
				_Utils_Tuple2(
				'defaultRelevanceStarts',
				A2($elm$json$Json$Encode$list, $author$project$Task$Class$encodeRelativeTiming, taskClass.defaultRelevanceStarts)),
				_Utils_Tuple2(
				'defaultRelevanceEnds',
				A2($elm$json$Json$Encode$list, $author$project$Task$Class$encodeRelativeTiming, taskClass.defaultRelevanceEnds)),
				_Utils_Tuple2(
				'importance',
				$elm$json$Json$Encode$float(taskClass.importance))
			]));
};
var $author$project$SmartTime$Human$Clock$midnight = $author$project$SmartTime$Duration$zero;
var $author$project$SmartTime$Human$Moment$fromDate = F2(
	function (zone, date) {
		return A3($author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, $author$project$SmartTime$Human$Clock$midnight);
	});
var $author$project$SmartTime$Human$Moment$fromFuzzy = F2(
	function (zone, fuzzy) {
		switch (fuzzy.$) {
			case 'DateOnly':
				var date = fuzzy.a;
				return A2($author$project$SmartTime$Human$Moment$fromDate, zone, date);
			case 'Floating':
				var _v1 = fuzzy.a;
				var date = _v1.a;
				var time = _v1.b;
				return A3($author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, time);
			default:
				var moment = fuzzy.a;
				return moment;
		}
	});
var $author$project$SmartTime$Human$Moment$fuzzyToString = function (fuzzyMoment) {
	switch (fuzzyMoment.$) {
		case 'Global':
			var moment = fuzzyMoment.a;
			return $author$project$SmartTime$Human$Moment$toStandardString(moment);
		case 'Floating':
			return A2(
				$elm$core$String$dropRight,
				1,
				$author$project$SmartTime$Human$Moment$toStandardString(
					A2($author$project$SmartTime$Human$Moment$fromFuzzy, $author$project$SmartTime$Human$Moment$utc, fuzzyMoment)));
		default:
			var date = fuzzyMoment.a;
			return $author$project$SmartTime$Human$Calendar$toStandardString(date);
	}
};
var $author$project$Porting$encodeFuzzyMoment = function (fuzzy) {
	return $elm$json$Json$Encode$string(
		$author$project$SmartTime$Human$Moment$fuzzyToString(fuzzy));
};
var $author$project$Task$SessionSkel$encodeSession = function (plannedSession) {
	return A3($author$project$Porting$encodeTuple2, $author$project$Porting$encodeFuzzyMoment, $author$project$Porting$encodeDuration, plannedSession);
};
var $author$project$Task$Class$encodeTaskMoment = function (fuzzy) {
	return $elm$json$Json$Encode$string(
		$author$project$SmartTime$Human$Moment$fuzzyToString(fuzzy));
};
var $author$project$Task$Instance$encodeInstance = function (taskInstance) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'class',
				$elm$json$Json$Encode$int(taskInstance._class)),
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(taskInstance.id)),
				_Utils_Tuple2(
				'memberOfSeries',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $elm$json$Json$Encode$int, taskInstance.memberOfSeries)),
				_Utils_Tuple2(
				'completion',
				$elm$json$Json$Encode$int(taskInstance.completion)),
				_Utils_Tuple2(
				'externalDeadline',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $author$project$Task$Class$encodeTaskMoment, taskInstance.externalDeadline)),
				_Utils_Tuple2(
				'startBy',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $author$project$Task$Class$encodeTaskMoment, taskInstance.startBy)),
				_Utils_Tuple2(
				'finishBy',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $author$project$Task$Class$encodeTaskMoment, taskInstance.finishBy)),
				_Utils_Tuple2(
				'plannedSessions',
				A2($elm$json$Json$Encode$list, $author$project$Task$SessionSkel$encodeSession, taskInstance.plannedSessions)),
				_Utils_Tuple2(
				'relevanceStarts',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $author$project$Task$Class$encodeTaskMoment, taskInstance.relevanceStarts)),
				_Utils_Tuple2(
				'relevanceEnds',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $author$project$Task$Class$encodeTaskMoment, taskInstance.relevanceEnds))
			]));
};
var $elm$json$Json$Encode$dict = F3(
	function (toKey, toValue, dictionary) {
		return _Json_wrap(
			A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, value, obj) {
						return A3(
							_Json_addField,
							toKey(key),
							toValue(value),
							obj);
					}),
				_Json_emptyObject(_Utils_Tuple0),
				dictionary));
	});
var $author$project$Activity$Activity$encodeCategory = function (v) {
	switch (v.$) {
		case 'Transit':
			return $elm$json$Json$Encode$string('Transit');
		case 'Entertainment':
			return $elm$json$Json$Encode$string('Entertainment');
		case 'Hygiene':
			return $elm$json$Json$Encode$string('Hygiene');
		case 'Slacking':
			return $elm$json$Json$Encode$string('Slacking');
		default:
			return $elm$json$Json$Encode$string('Communication');
	}
};
var $author$project$Activity$Activity$encodeHumanDuration = function (humanDuration) {
	return $elm$json$Json$Encode$int(
		$author$project$SmartTime$Duration$inMs(
			$author$project$SmartTime$Human$Duration$dur(humanDuration)));
};
var $author$project$Porting$homogeneousTuple2AsArray = F2(
	function (encoder, _v0) {
		var a = _v0.a;
		var b = _v0.b;
		return A2(
			$elm$json$Json$Encode$list,
			encoder,
			_List_fromArray(
				[a, b]));
	});
var $author$project$Activity$Activity$encodeDurationPerPeriod = function (tuple) {
	return A2($author$project$Porting$homogeneousTuple2AsArray, $author$project$Activity$Activity$encodeHumanDuration, tuple);
};
var $author$project$Activity$Evidence$encodeEvidence = function (v) {
	if (v.$ === 'UsingApp') {
		return $elm$json$Json$Encode$string('UsingApp');
	} else {
		var pace = v.a;
		return $elm$json$Json$Encode$string('StepCountPace');
	}
};
var $author$project$Activity$Activity$encodeExcusable = function (v) {
	switch (v.$) {
		case 'NeverExcused':
			return $elm$json$Json$Encode$string('NeverExcused');
		case 'TemporarilyExcused':
			var dpp = v.a;
			return $elm$json$Json$Encode$string('TemporarilyExcused');
		default:
			return $elm$json$Json$Encode$string('IndefinitelyExcused');
	}
};
var $author$project$Activity$Activity$encodeIcon = function (v) {
	switch (v.$) {
		case 'File':
			var path = v.a;
			return $elm$json$Json$Encode$string('File');
		case 'Ion':
			return $elm$json$Json$Encode$string('Ion');
		case 'Other':
			return $elm$json$Json$Encode$string('Other');
		default:
			var singleEmoji = v.a;
			return $elm$json$Json$Encode$string(singleEmoji);
	}
};
var $author$project$Activity$Template$encodeTemplate = function (v) {
	switch (v.$) {
		case 'DillyDally':
			return $elm$json$Json$Encode$string('DillyDally');
		case 'Apparel':
			return $elm$json$Json$Encode$string('Apparel');
		case 'Messaging':
			return $elm$json$Json$Encode$string('Messaging');
		case 'Restroom':
			return $elm$json$Json$Encode$string('Restroom');
		case 'Grooming':
			return $elm$json$Json$Encode$string('Grooming');
		case 'Meal':
			return $elm$json$Json$Encode$string('Meal');
		case 'Supplements':
			return $elm$json$Json$Encode$string('Supplements');
		case 'Workout':
			return $elm$json$Json$Encode$string('Workout');
		case 'Shower':
			return $elm$json$Json$Encode$string('Shower');
		case 'Toothbrush':
			return $elm$json$Json$Encode$string('Toothbrush');
		case 'Floss':
			return $elm$json$Json$Encode$string('Floss');
		case 'Wakeup':
			return $elm$json$Json$Encode$string('Wakeup');
		case 'Sleep':
			return $elm$json$Json$Encode$string('Sleep');
		case 'Plan':
			return $elm$json$Json$Encode$string('Plan');
		case 'Configure':
			return $elm$json$Json$Encode$string('Configure');
		case 'Email':
			return $elm$json$Json$Encode$string('Email');
		case 'Work':
			return $elm$json$Json$Encode$string('Work');
		case 'Call':
			return $elm$json$Json$Encode$string('Call');
		case 'Chores':
			return $elm$json$Json$Encode$string('Chores');
		case 'Parents':
			return $elm$json$Json$Encode$string('Parents');
		case 'Prepare':
			return $elm$json$Json$Encode$string('Prepare');
		case 'Lover':
			return $elm$json$Json$Encode$string('Lover');
		case 'Driving':
			return $elm$json$Json$Encode$string('Driving');
		case 'Riding':
			return $elm$json$Json$Encode$string('Riding');
		case 'SocialMedia':
			return $elm$json$Json$Encode$string('SocialMedia');
		case 'Pacing':
			return $elm$json$Json$Encode$string('Pacing');
		case 'Sport':
			return $elm$json$Json$Encode$string('Sport');
		case 'Finance':
			return $elm$json$Json$Encode$string('Finance');
		case 'Laundry':
			return $elm$json$Json$Encode$string('Laundry');
		case 'Bedward':
			return $elm$json$Json$Encode$string('Bedward');
		case 'Browse':
			return $elm$json$Json$Encode$string('Browse');
		case 'Fiction':
			return $elm$json$Json$Encode$string('Fiction');
		case 'Learning':
			return $elm$json$Json$Encode$string('Learning');
		case 'BrainTrain':
			return $elm$json$Json$Encode$string('BrainTrain');
		case 'Music':
			return $elm$json$Json$Encode$string('Music');
		case 'Create':
			return $elm$json$Json$Encode$string('Create');
		case 'Children':
			return $elm$json$Json$Encode$string('Children');
		case 'Meeting':
			return $elm$json$Json$Encode$string('Meeting');
		case 'Cinema':
			return $elm$json$Json$Encode$string('Cinema');
		case 'FilmWatching':
			return $elm$json$Json$Encode$string('FilmWatching');
		case 'Series':
			return $elm$json$Json$Encode$string('Series');
		case 'Broadcast':
			return $elm$json$Json$Encode$string('Broadcast');
		case 'Theatre':
			return $elm$json$Json$Encode$string('Theatre');
		case 'Shopping':
			return $elm$json$Json$Encode$string('Shopping');
		case 'VideoGaming':
			return $elm$json$Json$Encode$string('VideoGaming');
		case 'Housekeeping':
			return $elm$json$Json$Encode$string('Housekeeping');
		case 'MealPrep':
			return $elm$json$Json$Encode$string('MealPrep');
		case 'Networking':
			return $elm$json$Json$Encode$string('Networking');
		case 'Meditate':
			return $elm$json$Json$Encode$string('Meditate');
		case 'Homework':
			return $elm$json$Json$Encode$string('Homework');
		case 'Flight':
			return $elm$json$Json$Encode$string('Flight');
		case 'Course':
			return $elm$json$Json$Encode$string('Course');
		case 'Pet':
			return $elm$json$Json$Encode$string('Pet');
		case 'Presentation':
			return $elm$json$Json$Encode$string('Presentation');
		case 'Projects':
			return $elm$json$Json$Encode$string('Projects');
		default:
			return $elm$json$Json$Encode$string('Research');
	}
};
var $author$project$Activity$Activity$encodeCustomizations = function (record) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'template',
					$author$project$Activity$Template$encodeTemplate(record.template))),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'id',
					$author$project$ID$encode(record.id))),
				$author$project$Porting$omittable(
				_Utils_Tuple3(
					'names',
					$elm$json$Json$Encode$list($elm$json$Json$Encode$string),
					record.names)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('icon', $author$project$Activity$Activity$encodeIcon, record.icon)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('excusable', $author$project$Activity$Activity$encodeExcusable, record.excusable)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('taskOptional', $elm$json$Json$Encode$bool, record.taskOptional)),
				$author$project$Porting$omittableList(
				_Utils_Tuple3('evidence', $author$project$Activity$Evidence$encodeEvidence, record.evidence)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('category', $author$project$Activity$Activity$encodeCategory, record.category)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('backgroundable', $elm$json$Json$Encode$bool, record.backgroundable)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('maxTime', $author$project$Activity$Activity$encodeDurationPerPeriod, record.maxTime)),
				$author$project$Porting$omittable(
				_Utils_Tuple3('hidden', $elm$json$Json$Encode$bool, record.hidden)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'externalIDs',
					A3($elm$json$Json$Encode$dict, $elm$core$Basics$identity, $elm$json$Json$Encode$string, record.externalIDs)))
			]));
};
var $author$project$Activity$Activity$encodeStoredActivities = function (value) {
	return A2(
		$elm$json$Json$Encode$list,
		A2($author$project$Porting$encodeTuple2, $elm$json$Json$Encode$int, $author$project$Activity$Activity$encodeCustomizations),
		$elm_community$intdict$IntDict$toList(value));
};
var $author$project$Porting$encodeMoment = function (dur) {
	return $elm$json$Json$Encode$int(
		$author$project$SmartTime$Moment$toSmartInt(dur));
};
var $author$project$Activity$Activity$encodeSwitch = function (_v0) {
	var time = _v0.a;
	var activityId = _v0.b;
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'Time',
				$author$project$Porting$encodeMoment(time)),
				_Utils_Tuple2(
				'Activity',
				$author$project$ID$encode(activityId))
			]));
};
var $author$project$SmartTime$Period$toPair = function (_v0) {
	var startMoment = _v0.a;
	var endMoment = _v0.b;
	return _Utils_Tuple2(startMoment, endMoment);
};
var $author$project$TimeBlock$TimeBlock$periodEncoder = function (period) {
	var momentEncoder = function (moment) {
		return $elm$json$Json$Encode$string(
			$author$project$SmartTime$Human$Moment$toStandardString(moment));
	};
	return A2(
		$author$project$Porting$homogeneousTuple2AsArray,
		momentEncoder,
		$author$project$SmartTime$Period$toPair(period));
};
var $author$project$TimeBlock$TimeBlock$encodeTimeBlock = function (timeBlock) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'focus',
				$author$project$ID$encode(timeBlock.focus)),
				_Utils_Tuple2(
				'range',
				$author$project$TimeBlock$TimeBlock$periodEncoder(timeBlock.range))
			]));
};
var $author$project$Incubator$Todoist$encodeIncrementalSyncToken = function (_v0) {
	var token = _v0.a;
	return $elm$json$Json$Encode$string(token);
};
var $author$project$Incubator$Todoist$Item$encodeItem = function (record) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(record.id)),
				_Utils_Tuple2(
				'user_id',
				$elm$json$Json$Encode$int(record.user_id)),
				_Utils_Tuple2(
				'project_id',
				$elm$json$Json$Encode$int(record.project_id)),
				_Utils_Tuple2(
				'content',
				$elm$json$Json$Encode$string(record.content)),
				_Utils_Tuple2(
				'due',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $author$project$Incubator$Todoist$Item$encodeDue, record.due)),
				_Utils_Tuple2(
				'priority',
				$author$project$Incubator$Todoist$Item$encodePriority(record.priority)),
				_Utils_Tuple2(
				'parent_id',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $elm$json$Json$Encode$int, record.parent_id)),
				_Utils_Tuple2(
				'child_order',
				$elm$json$Json$Encode$int(record.child_order)),
				_Utils_Tuple2(
				'day_order',
				$elm$json$Json$Encode$int(record.day_order)),
				_Utils_Tuple2(
				'collapsed',
				$author$project$Porting$encodeBoolToInt(record.collapsed)),
				_Utils_Tuple2(
				'children',
				A2($elm$json$Json$Encode$list, $elm$json$Json$Encode$int, record.children)),
				_Utils_Tuple2(
				'assigned_by_uid',
				$elm$json$Json$Encode$int(record.assigned_by_uid)),
				_Utils_Tuple2(
				'responsible_uid',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $elm$json$Json$Encode$int, record.responsible_uid)),
				_Utils_Tuple2(
				'checked',
				$author$project$Porting$encodeBoolToInt(record.checked)),
				_Utils_Tuple2(
				'in_history',
				$author$project$Porting$encodeBoolToInt(record.in_history)),
				_Utils_Tuple2(
				'is_deleted',
				$author$project$Porting$encodeBoolToInt(record.is_deleted)),
				_Utils_Tuple2(
				'is_archived',
				$author$project$Porting$encodeBoolToInt(record.is_archived)),
				_Utils_Tuple2(
				'date_added',
				$elm$json$Json$Encode$string(record.date_added))
			]));
};
var $author$project$Incubator$Todoist$Project$encodeProject = function (record) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				$elm$json$Json$Encode$int(record.id)),
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(record.name)),
				_Utils_Tuple2(
				'color',
				$elm$json$Json$Encode$int(record.color)),
				_Utils_Tuple2(
				'parent_id',
				A2($elm_community$json_extra$Json$Encode$Extra$maybe, $elm$json$Json$Encode$int, record.parent_id)),
				_Utils_Tuple2(
				'child_order',
				$elm$json$Json$Encode$int(record.child_order)),
				_Utils_Tuple2(
				'collapsed',
				$elm$json$Json$Encode$int(record.collapsed)),
				_Utils_Tuple2(
				'shared',
				$elm$json$Json$Encode$bool(record.shared)),
				_Utils_Tuple2(
				'is_deleted',
				$author$project$Porting$encodeBoolToInt(record.is_deleted)),
				_Utils_Tuple2(
				'is_archived',
				$author$project$Porting$encodeBoolToInt(record.is_archived)),
				_Utils_Tuple2(
				'is_favorite',
				$author$project$Porting$encodeBoolToInt(record.is_favorite)),
				_Utils_Tuple2(
				'inbox_project',
				$elm$json$Json$Encode$bool(record.inbox_project)),
				_Utils_Tuple2(
				'team_inbox',
				$elm$json$Json$Encode$bool(record.team_inbox))
			]));
};
var $author$project$Incubator$Todoist$encodeCache = function (record) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'nextSync',
				$author$project$Incubator$Todoist$encodeIncrementalSyncToken(record.nextSync)),
				_Utils_Tuple2(
				'items',
				A2($author$project$Porting$encodeIntDict, $author$project$Incubator$Todoist$Item$encodeItem, record.items)),
				_Utils_Tuple2(
				'projects',
				A2($author$project$Porting$encodeIntDict, $author$project$Incubator$Todoist$Project$encodeProject, record.projects)),
				_Utils_Tuple2(
				'pendingCommands',
				A2($elm$json$Json$Encode$list, $elm$json$Json$Encode$string, record.pendingCommands))
			]));
};
var $author$project$Profile$encodeTodoistIntegrationData = function (data) {
	return $author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'cache',
					$author$project$Incubator$Todoist$encodeCache(data.cache))),
				$author$project$Porting$omittable(
				_Utils_Tuple3('parentProjectID', $elm$json$Json$Encode$int, data.parentProjectID)),
				$author$project$Porting$normal(
				_Utils_Tuple2(
					'activityProjectIDs',
					A2($author$project$Porting$encodeIntDict, $author$project$ID$encode, data.activityProjectIDs)))
			]));
};
var $author$project$Profile$encodeProfile = function (record) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'taskClasses',
				A2($author$project$Porting$encodeIntDict, $author$project$Task$Class$encodeClass, record.taskClasses)),
				_Utils_Tuple2(
				'taskInstances',
				A2($author$project$Porting$encodeIntDict, $author$project$Task$Instance$encodeInstance, record.taskInstances)),
				_Utils_Tuple2(
				'activities',
				$author$project$Activity$Activity$encodeStoredActivities(record.activities)),
				_Utils_Tuple2(
				'uid',
				$elm$json$Json$Encode$int(record.uid)),
				_Utils_Tuple2(
				'errors',
				A2(
					$elm$json$Json$Encode$list,
					$elm$json$Json$Encode$string,
					A2($elm$core$List$take, 100, record.errors))),
				_Utils_Tuple2(
				'timeline',
				A2($elm$json$Json$Encode$list, $author$project$Activity$Activity$encodeSwitch, record.timeline)),
				_Utils_Tuple2(
				'todoist',
				$author$project$Profile$encodeTodoistIntegrationData(record.todoist)),
				_Utils_Tuple2(
				'timeBlocks',
				A2($elm$json$Json$Encode$list, $author$project$TimeBlock$TimeBlock$encodeTimeBlock, record.timeBlocks))
			]));
};
var $author$project$Main$profileToJson = function (appData) {
	return A2(
		$elm$json$Json$Encode$encode,
		0,
		$author$project$Profile$encodeProfile(appData));
};
var $author$project$Main$setStorage = _Platform_outgoingPort('setStorage', $elm$json$Json$Encode$string);
var $author$project$Main$updateWithStorage = F2(
	function (msg, model) {
		var _v0 = A2($author$project$Main$update, msg, model);
		var newModel = _v0.a;
		var cmds = _v0.b;
		return _Utils_Tuple2(
			newModel,
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						$author$project$Main$setStorage(
						$author$project$Main$profileToJson(newModel.profile)),
						cmds
					])));
	});
var $author$project$Main$updateWithTime = F2(
	function (msg, model) {
		updateWithTime:
		while (true) {
			var environment = model.environment;
			switch (msg.$) {
				case 'NoOp':
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				case 'Tick':
					var submsg = msg.a;
					return _Utils_Tuple2(
						model,
						A2(
							$elm$core$Task$perform,
							$author$project$Main$Tock(submsg),
							$author$project$SmartTime$Moment$now));
				case 'Tock':
					if (msg.a.$ === 'NoOp') {
						var _v1 = msg.a;
						var time = msg.b;
						var newEnv = _Utils_update(
							environment,
							{time: time});
						return A2(
							$author$project$Main$update,
							$author$project$Main$NoOp,
							_Utils_update(
								model,
								{environment: newEnv}));
					} else {
						var submsg = msg.a;
						var time = msg.b;
						var newEnv = _Utils_update(
							environment,
							{time: time});
						return A2(
							$author$project$Main$updateWithStorage,
							submsg,
							_Utils_update(
								model,
								{environment: newEnv}));
					}
				case 'SetZoneAndTime':
					var zone = msg.a;
					var time = msg.b;
					var newEnv = _Utils_update(
						environment,
						{launchTime: time, time: time, timeZone: zone});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{environment: newEnv}),
						$elm$core$Platform$Cmd$none);
				default:
					var otherMsg = msg;
					var $temp$msg = $author$project$Main$Tick(msg),
						$temp$model = model;
					msg = $temp$msg;
					model = $temp$model;
					continue updateWithTime;
			}
		}
	});
var $author$project$Main$init = F3(
	function (maybeJson, url, maybeKey) {
		var startingModel = function () {
			if (maybeJson.$ === 'Just') {
				var jsonAppDatabase = maybeJson.a;
				var _v2 = $author$project$Main$profileFromJson(jsonAppDatabase);
				switch (_v2.$) {
					case 'Success':
						var savedAppData = _v2.a;
						return A3($author$project$Main$buildModel, savedAppData, url, maybeKey);
					case 'WithWarnings':
						var warnings = _v2.a;
						var savedAppData = _v2.b;
						return A3(
							$author$project$Main$buildModel,
							A2($author$project$Profile$saveWarnings, savedAppData, warnings),
							url,
							maybeKey);
					case 'Errors':
						var errors = _v2.a;
						return A3(
							$author$project$Main$buildModel,
							A2($author$project$Profile$saveDecodeErrors, $author$project$Profile$fromScratch, errors),
							url,
							maybeKey);
					default:
						return A3($author$project$Main$buildModel, $author$project$Profile$fromScratch, url, maybeKey);
				}
			} else {
				return A3($author$project$Main$buildModel, $author$project$Profile$fromScratch, url, maybeKey);
			}
		}();
		var _v0 = A2(
			$author$project$Main$updateWithTime,
			$author$project$Main$NewUrl(url),
			startingModel);
		var modelWithFirstUpdate = _v0.a;
		var firstEffects = _v0.b;
		var effects = _List_fromArray(
			[
				A2(
				$elm$core$Task$perform,
				$elm$core$Basics$identity,
				A3($elm$core$Task$map2, $author$project$Main$SetZoneAndTime, $author$project$SmartTime$Human$Moment$localZone, $author$project$SmartTime$Moment$now)),
				firstEffects
			]);
		return _Utils_Tuple2(
			modelWithFirstUpdate,
			$elm$core$Platform$Cmd$batch(effects));
	});
var $author$project$Browserless$fallbackUrl = {fragment: $elm$core$Maybe$Nothing, host: 'headless.docket.com', path: '', port_: $elm$core$Maybe$Nothing, protocol: $elm$url$Url$Http, query: $elm$core$Maybe$Nothing};
var $elm$core$String$replace = F3(
	function (before, after, string) {
		return A2(
			$elm$core$String$join,
			after,
			A2($elm$core$String$split, before, string));
	});
var $author$project$Browserless$urlOrElse = function (urlAsString) {
	var finalUrlAsString = A3($elm$core$String$replace, 'minder://', 'https://internalURI.minder.app/', urlAsString);
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$Browserless$fallbackUrl,
		$elm$url$Url$fromString(
			A2($elm$core$Debug$log, 'url in elm:', finalUrlAsString)));
};
var $author$project$Browserless$initBrowserless = function (_v0) {
	var urlAsString = _v0.a;
	var maybeJson = _v0.b;
	return A3(
		$author$project$Main$init,
		maybeJson,
		$author$project$Browserless$urlOrElse(urlAsString),
		$elm$core$Maybe$Nothing);
};
var $author$project$Main$NewAppData = function (a) {
	return {$: 'NewAppData', a: a};
};
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$time$Time$Every = F2(
	function (a, b) {
		return {$: 'Every', a: a, b: b};
	});
var $elm$time$Time$State = F2(
	function (taggers, processes) {
		return {processes: processes, taggers: taggers};
	});
var $elm$time$Time$init = $elm$core$Task$succeed(
	A2($elm$time$Time$State, $elm$core$Dict$empty, $elm$core$Dict$empty));
var $elm$time$Time$addMySub = F2(
	function (_v0, state) {
		var interval = _v0.a;
		var tagger = _v0.b;
		var _v1 = A2($elm$core$Dict$get, interval, state);
		if (_v1.$ === 'Nothing') {
			return A3(
				$elm$core$Dict$insert,
				interval,
				_List_fromArray(
					[tagger]),
				state);
		} else {
			var taggers = _v1.a;
			return A3(
				$elm$core$Dict$insert,
				interval,
				A2($elm$core$List$cons, tagger, taggers),
				state);
		}
	});
var $elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _v0) {
				stepState:
				while (true) {
					var list = _v0.a;
					var result = _v0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _v2 = list.a;
						var lKey = _v2.a;
						var lValue = _v2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_v0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_v0 = $temp$_v0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _v3 = A3(
			$elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				$elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _v3.a;
		var intermediateResult = _v3.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v4, result) {
					var k = _v4.a;
					var v = _v4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var $elm$time$Time$setInterval = _Time_setInterval;
var $elm$time$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		if (!intervals.b) {
			return $elm$core$Task$succeed(processes);
		} else {
			var interval = intervals.a;
			var rest = intervals.b;
			var spawnTimer = $elm$core$Process$spawn(
				A2(
					$elm$time$Time$setInterval,
					interval,
					A2($elm$core$Platform$sendToSelf, router, interval)));
			var spawnRest = function (id) {
				return A3(
					$elm$time$Time$spawnHelp,
					router,
					rest,
					A3($elm$core$Dict$insert, interval, id, processes));
			};
			return A2($elm$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var $elm$time$Time$onEffects = F3(
	function (router, subs, _v0) {
		var processes = _v0.processes;
		var rightStep = F3(
			function (_v6, id, _v7) {
				var spawns = _v7.a;
				var existing = _v7.b;
				var kills = _v7.c;
				return _Utils_Tuple3(
					spawns,
					existing,
					A2(
						$elm$core$Task$andThen,
						function (_v5) {
							return kills;
						},
						$elm$core$Process$kill(id)));
			});
		var newTaggers = A3($elm$core$List$foldl, $elm$time$Time$addMySub, $elm$core$Dict$empty, subs);
		var leftStep = F3(
			function (interval, taggers, _v4) {
				var spawns = _v4.a;
				var existing = _v4.b;
				var kills = _v4.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, interval, spawns),
					existing,
					kills);
			});
		var bothStep = F4(
			function (interval, taggers, id, _v3) {
				var spawns = _v3.a;
				var existing = _v3.b;
				var kills = _v3.c;
				return _Utils_Tuple3(
					spawns,
					A3($elm$core$Dict$insert, interval, id, existing),
					kills);
			});
		var _v1 = A6(
			$elm$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			processes,
			_Utils_Tuple3(
				_List_Nil,
				$elm$core$Dict$empty,
				$elm$core$Task$succeed(_Utils_Tuple0)));
		var spawnList = _v1.a;
		var existingDict = _v1.b;
		var killTask = _v1.c;
		return A2(
			$elm$core$Task$andThen,
			function (newProcesses) {
				return $elm$core$Task$succeed(
					A2($elm$time$Time$State, newTaggers, newProcesses));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v2) {
					return A3($elm$time$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var $elm$time$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _v0 = A2($elm$core$Dict$get, interval, state.taggers);
		if (_v0.$ === 'Nothing') {
			return $elm$core$Task$succeed(state);
		} else {
			var taggers = _v0.a;
			var tellTaggers = function (time) {
				return $elm$core$Task$sequence(
					A2(
						$elm$core$List$map,
						function (tagger) {
							return A2(
								$elm$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						taggers));
			};
			return A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$succeed(state);
				},
				A2($elm$core$Task$andThen, tellTaggers, $elm$time$Time$now));
		}
	});
var $elm$time$Time$subMap = F2(
	function (f, _v0) {
		var interval = _v0.a;
		var tagger = _v0.b;
		return A2(
			$elm$time$Time$Every,
			interval,
			A2($elm$core$Basics$composeL, f, tagger));
	});
_Platform_effectManagers['Time'] = _Platform_createManager($elm$time$Time$init, $elm$time$Time$onEffects, $elm$time$Time$onSelfMsg, 0, $elm$time$Time$subMap);
var $elm$time$Time$subscription = _Platform_leaf('Time');
var $elm$time$Time$every = F2(
	function (interval, tagger) {
		return $elm$time$Time$subscription(
			A2($elm$time$Time$Every, interval, tagger));
	});
var $author$project$SmartTime$Moment$every = F2(
	function (interval, tagger) {
		var convertedTagger = function (elmTime) {
			return tagger(
				$author$project$SmartTime$Moment$fromElmTime(elmTime));
		};
		return A2(
			$elm$time$Time$every,
			$author$project$SmartTime$Duration$inMs(interval),
			convertedTagger);
	});
var $author$project$SmartTime$Human$Clock$forward = F2(
	function (timeSinceDayStart, amountToAdd) {
		return A2(
			$author$project$SmartTime$Duration$add,
			$author$project$SmartTime$Human$Duration$dur(amountToAdd),
			timeSinceDayStart);
	});
var $author$project$SmartTime$Human$Clock$truncateMinute = function (timeSinceDayStart) {
	var oldTime = $author$project$SmartTime$Duration$breakdown(timeSinceDayStart);
	return A4($author$project$SmartTime$Human$Clock$clock, oldTime.hours, oldTime.minutes, 0, 0);
};
var $author$project$SmartTime$Human$Moment$nextMinute = F2(
	function (zone, moment) {
		var _v0 = A2($author$project$SmartTime$Human$Moment$humanize, zone, moment);
		var originalTimeOfDay = _v0.b;
		var newTimeOfDay = A2(
			$author$project$SmartTime$Human$Clock$forward,
			$author$project$SmartTime$Human$Clock$truncateMinute(originalTimeOfDay),
			$author$project$SmartTime$Human$Duration$Minutes(1));
		return A3($author$project$SmartTime$Human$Moment$setTime, newTimeOfDay, zone, moment);
	});
var $author$project$SmartTime$Human$Moment$everyMinuteOnTheMinute = F3(
	function (now, zone, tagger) {
		var nextTick = A2($author$project$SmartTime$Human$Moment$nextMinute, zone, now);
		var waitingTime = A2($author$project$SmartTime$Moment$difference, now, nextTick);
		var fallbackTicker = A2($author$project$SmartTime$Moment$every, $author$project$SmartTime$Duration$aSecond, tagger);
		var debugMsg = 'it\'s ' + ($author$project$SmartTime$Human$Moment$toStandardString(now) + (', nextTick at ' + ($author$project$SmartTime$Human$Moment$toStandardString(nextTick) + (' which is in ' + $author$project$SmartTime$Human$Duration$singleLetterSpaced(
			$author$project$SmartTime$Human$Duration$breakdownNonzero(waitingTime))))));
		return _Utils_eq(
			A2($author$project$SmartTime$Moment$compare, now, $author$project$SmartTime$Moment$zero),
			$author$project$SmartTime$Moment$Later) ? A2($author$project$SmartTime$Moment$every, waitingTime, tagger) : fallbackTicker;
	});
var $elm$browser$Browser$Events$Document = {$: 'Document'};
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 'MySub', a: a, b: b, c: c};
	});
var $elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {pids: pids, subs: subs};
	});
var $elm$browser$Browser$Events$init = $elm$core$Task$succeed(
	A2($elm$browser$Browser$Events$State, _List_Nil, $elm$core$Dict$empty));
var $elm$browser$Browser$Events$nodeToKey = function (node) {
	if (node.$ === 'Document') {
		return 'd_';
	} else {
		return 'w_';
	}
};
var $elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			$elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var $elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {event: event, key: key};
	});
var $elm$browser$Browser$Events$spawn = F3(
	function (router, key, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var actualNode = function () {
			if (node.$ === 'Document') {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			$elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						$elm$core$Platform$sendToSelf,
						router,
						A2($elm$browser$Browser$Events$Event, key, event));
				}));
	});
var $elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _v6) {
				var deads = _v6.a;
				var lives = _v6.b;
				var news = _v6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						$elm$core$List$cons,
						A3($elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_v4, pid, _v5) {
				var deads = _v5.a;
				var lives = _v5.b;
				var news = _v5.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _v2, _v3) {
				var deads = _v3.a;
				var lives = _v3.b;
				var news = _v3.c;
				return _Utils_Tuple3(
					deads,
					A3($elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2($elm$core$List$map, $elm$browser$Browser$Events$addKey, subs);
		var _v0 = A6(
			$elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.pids,
			$elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, $elm$core$Dict$empty, _List_Nil));
		var deadPids = _v0.a;
		var livePids = _v0.b;
		var makeNewPids = _v0.c;
		return A2(
			$elm$core$Task$andThen,
			function (pids) {
				return $elm$core$Task$succeed(
					A2(
						$elm$browser$Browser$Events$State,
						newSubs,
						A2(
							$elm$core$Dict$union,
							livePids,
							$elm$core$Dict$fromList(pids))));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$sequence(makeNewPids);
				},
				$elm$core$Task$sequence(
					A2($elm$core$List$map, $elm$core$Process$kill, deadPids))));
	});
var $elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _v0, state) {
		var key = _v0.key;
		var event = _v0.event;
		var toMessage = function (_v2) {
			var subKey = _v2.a;
			var _v3 = _v2.b;
			var node = _v3.a;
			var name = _v3.b;
			var decoder = _v3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : $elm$core$Maybe$Nothing;
		};
		var messages = A2($elm$core$List$filterMap, toMessage, state.subs);
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Platform$sendToApp(router),
					messages)));
	});
var $elm$browser$Browser$Events$subMap = F2(
	function (func, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var decoder = _v0.c;
		return A3(
			$elm$browser$Browser$Events$MySub,
			node,
			name,
			A2($elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager($elm$browser$Browser$Events$init, $elm$browser$Browser$Events$onEffects, $elm$browser$Browser$Events$onSelfMsg, 0, $elm$browser$Browser$Events$subMap);
var $elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var $elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return $elm$browser$Browser$Events$subscription(
			A3($elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var $elm$browser$Browser$Events$Hidden = {$: 'Hidden'};
var $elm$browser$Browser$Events$Visible = {$: 'Visible'};
var $elm$browser$Browser$Events$withHidden = F2(
	function (func, isHidden) {
		return func(
			isHidden ? $elm$browser$Browser$Events$Hidden : $elm$browser$Browser$Events$Visible);
	});
var $elm$browser$Browser$Events$onVisibilityChange = function (func) {
	var info = _Browser_visibilityInfo(_Utils_Tuple0);
	return A3(
		$elm$browser$Browser$Events$on,
		$elm$browser$Browser$Events$Document,
		info.change,
		A2(
			$elm$json$Json$Decode$map,
			$elm$browser$Browser$Events$withHidden(func),
			A2(
				$elm$json$Json$Decode$field,
				'target',
				A2($elm$json$Json$Decode$field, info.hidden, $elm$json$Json$Decode$bool))));
};
var $author$project$Main$storageChangedElsewhere = _Platform_incomingPort('storageChangedElsewhere', $elm$json$Json$Decode$string);
var $author$project$Main$subscriptions = function (model) {
	var profile = model.profile;
	var environment = model.environment;
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				A3(
				$author$project$SmartTime$Human$Moment$everyMinuteOnTheMinute,
				environment.time,
				environment.timeZone,
				$author$project$Main$Tock($author$project$Main$NoOp)),
				$elm$browser$Browser$Events$onVisibilityChange(
				function (_v0) {
					return $author$project$Main$Tick($author$project$Main$NoOp);
				}),
				$author$project$Main$storageChangedElsewhere($author$project$Main$NewAppData)
			]));
};
var $author$project$Browserless$main = $elm$browser$Browser$element(
	{init: $author$project$Browserless$initBrowserless, subscriptions: $author$project$Main$subscriptions, update: $author$project$Main$updateWithTime, view: $author$project$Browserless$browserlessView});
_Platform_export({'Browserless':{'init':$author$project$Browserless$main(
	A2(
		$elm$json$Json$Decode$andThen,
		function (_v0) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (_v1) {
					return $elm$json$Json$Decode$succeed(
						_Utils_Tuple2(_v0, _v1));
				},
				A2(
					$elm$json$Json$Decode$index,
					1,
					$elm$json$Json$Decode$oneOf(
						_List_fromArray(
							[
								$elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
								A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, $elm$json$Json$Decode$string)
							]))));
		},
		A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string)))(0)}});}(this));