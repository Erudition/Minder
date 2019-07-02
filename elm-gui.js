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

console.warn('Compiled in DEBUG mode. Follow the advice at https://elm-lang.org/0.19.0/optimize for better performance and smaller assets.');


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
				+ _Debug_toAnsiString(ansi, elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Array$toList(value));
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
		x = elm$core$Set$toList(x);
		y = elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = elm$core$Dict$toList(x);
		y = elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = elm$core$Dict$toList(x);
		y = elm$core$Dict$toList(y);
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
	return n < 0 ? elm$core$Basics$LT : n ? elm$core$Basics$GT : elm$core$Basics$EQ;
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
		return ord === elm$core$Basics$EQ ? 0 : ord === elm$core$Basics$LT ? -1 : 1;
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
		? elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: elm$core$Maybe$Nothing;
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
			return elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? elm$core$Maybe$Nothing
		: elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? elm$core$Maybe$Just(n) : elm$core$Maybe$Nothing;
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
	return elm$json$Json$Decode$errorToString(error);
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
		? elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? elm$core$Result$Ok(value)
		: (value instanceof String)
			? elm$core$Result$Ok(value + '')
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
		return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
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
				? elm$core$Result$Ok(decoder.c)
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
			return (elm$core$Result$isOk(result)) ? result : elm$core$Result$Err(A2(elm$json$Json$Decode$Field, field, result.a));

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
			return (elm$core$Result$isOk(result)) ? result : elm$core$Result$Err(A2(elm$json$Json$Decode$Index, index, result.a));

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
					if (!elm$core$Result$isOk(result))
					{
						return elm$core$Result$Err(A2(elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return elm$core$Result$Ok(elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if (elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return elm$core$Result$Err(elm$json$Json$Decode$OneOf(elm$core$List$reverse(errors)));

		case 1:
			return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!elm$core$Result$isOk(result))
		{
			return elm$core$Result$Err(A2(elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2(elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
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


function _Url_percentEncode(string)
{
	return encodeURIComponent(string);
}

function _Url_percentDecode(string)
{
	try
	{
		return elm$core$Maybe$Just(decodeURIComponent(string));
	}
	catch (e)
	{
		return elm$core$Maybe$Nothing;
	}
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
	elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
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

		elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

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



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.expect.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done(elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done(elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.expect.b, xhr)); });
		elm$core$Maybe$isJust(request.tracker) && _Http_track(router, xhr, request.tracker.a);

		try {
			xhr.open(request.method, request.url, true);
		} catch (e) {
			return done(elm$http$Http$BadUrl_(request.url));
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
		200 <= xhr.status && xhr.status < 300 ? elm$http$Http$GoodStatus_ : elm$http$Http$BadStatus_,
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
		return elm$core$Dict$empty;
	}

	var headers = elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3(elm$core$Dict$update, key, function(oldValue) {
				return elm$core$Maybe$Just(elm$core$Maybe$isJust(oldValue)
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
		_Scheduler_rawSpawn(A2(elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, elm$http$Http$Sending({
			sent: event.loaded,
			size: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2(elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, elm$http$Http$Receiving({
			received: event.loaded,
			size: event.lengthComputable ? elm$core$Maybe$Just(event.total) : elm$core$Maybe$Nothing
		}))));
	});
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
	var tag = elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2(elm$json$Json$Decode$map, func, handler.a)
				:
			A3(elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				elm$json$Json$Decode$succeed(func),
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
			&& { passive: elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
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

		if (!elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = elm$virtual_dom$VirtualDom$toHandlerInt(handler);

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




// HELPERS


function _Debugger_unsafeCoerce(value)
{
	return value;
}



// PROGRAMS


var _Debugger_element = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		A3(elm$browser$Debugger$Main$wrapInit, _Json_wrap(debugMetadata), _Debugger_popout(), impl.init),
		elm$browser$Debugger$Main$wrapUpdate(impl.update),
		elm$browser$Debugger$Main$wrapSubs(impl.subscriptions),
		function(sendToApp, initialModel)
		{
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			var currNode = _VirtualDom_virtualize(domNode);
			var currBlocker = elm$browser$Debugger$Main$toBlockerType(initialModel);
			var currPopout;

			var cornerNode = _VirtualDom_doc.createElement('div');
			domNode.parentNode.insertBefore(cornerNode, domNode.nextSibling);
			var cornerCurr = _VirtualDom_virtualize(cornerNode);

			initialModel.popout.a = sendToApp;

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = A2(_VirtualDom_map, elm$browser$Debugger$Main$UserMsg, view(elm$browser$Debugger$Main$getUserModel(model)));
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;

				// update blocker

				var nextBlocker = elm$browser$Debugger$Main$toBlockerType(model);
				_Debugger_updateBlocker(currBlocker, nextBlocker);
				currBlocker = nextBlocker;

				// view corner

				if (!model.popout.b)
				{
					var cornerNext = elm$browser$Debugger$Main$cornerView(model);
					var cornerPatches = _VirtualDom_diff(cornerCurr, cornerNext);
					cornerNode = _VirtualDom_applyPatches(cornerNode, cornerCurr, cornerPatches, sendToApp);
					cornerCurr = cornerNext;
					currPopout = undefined;
					return;
				}

				// view popout

				_VirtualDom_doc = model.popout.b; // SWITCH TO POPOUT DOC
				currPopout || (currPopout = _VirtualDom_virtualize(model.popout.b));
				var nextPopout = elm$browser$Debugger$Main$popoutView(model);
				var popoutPatches = _VirtualDom_diff(currPopout, nextPopout);
				_VirtualDom_applyPatches(model.popout.b.body, currPopout, popoutPatches, sendToApp);
				currPopout = nextPopout;
				_VirtualDom_doc = document; // SWITCH BACK TO NORMAL DOC
			});
		}
	);
});


var _Debugger_document = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		A3(elm$browser$Debugger$Main$wrapInit, _Json_wrap(debugMetadata), _Debugger_popout(), impl.init),
		elm$browser$Debugger$Main$wrapUpdate(impl.update),
		elm$browser$Debugger$Main$wrapSubs(impl.subscriptions),
		function(sendToApp, initialModel)
		{
			var divertHrefToApp = impl.setup && impl.setup(function(x) { return sendToApp(elm$browser$Debugger$Main$UserMsg(x)); });
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			var currBlocker = elm$browser$Debugger$Main$toBlockerType(initialModel);
			var currPopout;

			initialModel.popout.a = sendToApp;

			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(elm$browser$Debugger$Main$getUserModel(model));
				var nextNode = _VirtualDom_node('body')(_List_Nil)(
					_Utils_ap(
						A2(elm$core$List$map, _VirtualDom_map(elm$browser$Debugger$Main$UserMsg), doc.body),
						_List_Cons(elm$browser$Debugger$Main$cornerView(model), _List_Nil)
					)
				);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);

				// update blocker

				var nextBlocker = elm$browser$Debugger$Main$toBlockerType(model);
				_Debugger_updateBlocker(currBlocker, nextBlocker);
				currBlocker = nextBlocker;

				// view popout

				if (!model.popout.b) { currPopout = undefined; return; }

				_VirtualDom_doc = model.popout.b; // SWITCH TO POPOUT DOC
				currPopout || (currPopout = _VirtualDom_virtualize(model.popout.b));
				var nextPopout = elm$browser$Debugger$Main$popoutView(model);
				var popoutPatches = _VirtualDom_diff(currPopout, nextPopout);
				_VirtualDom_applyPatches(model.popout.b.body, currPopout, popoutPatches, sendToApp);
				currPopout = nextPopout;
				_VirtualDom_doc = document; // SWITCH BACK TO NORMAL DOC
			});
		}
	);
});


function _Debugger_popout()
{
	return {
		b: undefined,
		a: undefined
	};
}

function _Debugger_isOpen(popout)
{
	return !!popout.b;
}

function _Debugger_open(popout)
{
	return _Scheduler_binding(function(callback)
	{
		_Debugger_openWindow(popout);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}

function _Debugger_openWindow(popout)
{
	var w = 900, h = 360, x = screen.width - w, y = screen.height - h;
	var debuggerWindow = window.open('', '', 'width=' + w + ',height=' + h + ',left=' + x + ',top=' + y);
	var doc = debuggerWindow.document;
	doc.title = 'Elm Debugger';

	// handle arrow keys
	doc.addEventListener('keydown', function(event) {
		event.metaKey && event.which === 82 && window.location.reload();
		event.which === 38 && (popout.a(elm$browser$Debugger$Main$Up), event.preventDefault());
		event.which === 40 && (popout.a(elm$browser$Debugger$Main$Down), event.preventDefault());
	});

	// handle window close
	window.addEventListener('unload', close);
	debuggerWindow.addEventListener('unload', function() {
		popout.b = undefined;
		popout.a(elm$browser$Debugger$Main$NoOp);
		window.removeEventListener('unload', close);
	});
	function close() {
		popout.b = undefined;
		popout.a(elm$browser$Debugger$Main$NoOp);
		debuggerWindow.close();
	}

	// register new window
	popout.b = doc;
}



// SCROLL


function _Debugger_scroll(popout)
{
	return _Scheduler_binding(function(callback)
	{
		if (popout.b)
		{
			var msgs = popout.b.getElementById('elm-debugger-sidebar');
			if (msgs)
			{
				msgs.scrollTop = msgs.scrollHeight;
			}
		}
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}



// UPLOAD


function _Debugger_upload()
{
	return _Scheduler_binding(function(callback)
	{
		var element = document.createElement('input');
		element.setAttribute('type', 'file');
		element.setAttribute('accept', 'text/json');
		element.style.display = 'none';
		element.addEventListener('change', function(event)
		{
			var fileReader = new FileReader();
			fileReader.onload = function(e)
			{
				callback(_Scheduler_succeed(e.target.result));
			};
			fileReader.readAsText(event.target.files[0]);
			document.body.removeChild(element);
		});
		document.body.appendChild(element);
		element.click();
	});
}



// DOWNLOAD


var _Debugger_download = F2(function(historyLength, json)
{
	return _Scheduler_binding(function(callback)
	{
		var fileName = 'history-' + historyLength + '.txt';
		var jsonString = JSON.stringify(json);
		var mime = 'text/plain;charset=utf-8';
		var done = _Scheduler_succeed(_Utils_Tuple0);

		// for IE10+
		if (navigator.msSaveBlob)
		{
			navigator.msSaveBlob(new Blob([jsonString], {type: mime}), fileName);
			return callback(done);
		}

		// for HTML5
		var element = document.createElement('a');
		element.setAttribute('href', 'data:' + mime + ',' + encodeURIComponent(jsonString));
		element.setAttribute('download', fileName);
		element.style.display = 'none';
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		callback(done);
	});
});



// POPOUT CONTENT


function _Debugger_messageToString(value)
{
	if (typeof value === 'boolean')
	{
		return value ? 'True' : 'False';
	}

	if (typeof value === 'number')
	{
		return value + '';
	}

	if (typeof value === 'string')
	{
		return '"' + _Debugger_addSlashes(value, false) + '"';
	}

	if (value instanceof String)
	{
		return "'" + _Debugger_addSlashes(value, true) + "'";
	}

	if (typeof value !== 'object' || value === null || !('$' in value))
	{
		return '…';
	}

	if (typeof value.$ === 'number')
	{
		return '…';
	}

	var code = value.$.charCodeAt(0);
	if (code === 0x23 /* # */ || /* a */ 0x61 <= code && code <= 0x7A /* z */)
	{
		return '…';
	}

	if (['Array_elm_builtin', 'Set_elm_builtin', 'RBNode_elm_builtin', 'RBEmpty_elm_builtin'].indexOf(value.$) >= 0)
	{
		return '…';
	}

	var keys = Object.keys(value);
	switch (keys.length)
	{
		case 1:
			return value.$;
		case 2:
			return value.$ + ' ' + _Debugger_messageToString(value.a);
		default:
			return value.$ + ' … ' + _Debugger_messageToString(value[keys[keys.length - 1]]);
	}
}


function _Debugger_init(value)
{
	if (typeof value === 'boolean')
	{
		return A3(elm$browser$Debugger$Expando$Constructor, elm$core$Maybe$Just(value ? 'True' : 'False'), true, _List_Nil);
	}

	if (typeof value === 'number')
	{
		return elm$browser$Debugger$Expando$Primitive(value + '');
	}

	if (typeof value === 'string')
	{
		return elm$browser$Debugger$Expando$S('"' + _Debugger_addSlashes(value, false) + '"');
	}

	if (value instanceof String)
	{
		return elm$browser$Debugger$Expando$S("'" + _Debugger_addSlashes(value, true) + "'");
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (tag === '::' || tag === '[]')
		{
			return A3(elm$browser$Debugger$Expando$Sequence, elm$browser$Debugger$Expando$ListSeq, true,
				A2(elm$core$List$map, _Debugger_init, value)
			);
		}

		if (tag === 'Set_elm_builtin')
		{
			return A3(elm$browser$Debugger$Expando$Sequence, elm$browser$Debugger$Expando$SetSeq, true,
				A3(elm$core$Set$foldr, _Debugger_initCons, _List_Nil, value)
			);
		}

		if (tag === 'RBNode_elm_builtin' || tag == 'RBEmpty_elm_builtin')
		{
			return A2(elm$browser$Debugger$Expando$Dictionary, true,
				A3(elm$core$Dict$foldr, _Debugger_initKeyValueCons, _List_Nil, value)
			);
		}

		if (tag === 'Array_elm_builtin')
		{
			return A3(elm$browser$Debugger$Expando$Sequence, elm$browser$Debugger$Expando$ArraySeq, true,
				A3(elm$core$Array$foldr, _Debugger_initCons, _List_Nil, value)
			);
		}

		if (typeof tag === 'number')
		{
			return elm$browser$Debugger$Expando$Primitive('<internals>');
		}

		var char = tag.charCodeAt(0);
		if (char === 35 || 65 <= char && char <= 90)
		{
			var list = _List_Nil;
			for (var i in value)
			{
				if (i === '$') continue;
				list = _List_Cons(_Debugger_init(value[i]), list);
			}
			return A3(elm$browser$Debugger$Expando$Constructor, char === 35 ? elm$core$Maybe$Nothing : elm$core$Maybe$Just(tag), true, elm$core$List$reverse(list));
		}

		return elm$browser$Debugger$Expando$Primitive('<internals>');
	}

	if (typeof value === 'object')
	{
		var dict = elm$core$Dict$empty;
		for (var i in value)
		{
			dict = A3(elm$core$Dict$insert, i, _Debugger_init(value[i]), dict);
		}
		return A2(elm$browser$Debugger$Expando$Record, true, dict);
	}

	return elm$browser$Debugger$Expando$Primitive('<internals>');
}

var _Debugger_initCons = F2(function initConsHelp(value, list)
{
	return _List_Cons(_Debugger_init(value), list);
});

var _Debugger_initKeyValueCons = F3(function(key, value, list)
{
	return _List_Cons(
		_Utils_Tuple2(_Debugger_init(key), _Debugger_init(value)),
		list
	);
});

function _Debugger_addSlashes(str, isChar)
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



// BLOCK EVENTS


function _Debugger_updateBlocker(oldBlocker, newBlocker)
{
	if (oldBlocker === newBlocker) return;

	var oldEvents = _Debugger_blockerToEvents(oldBlocker);
	var newEvents = _Debugger_blockerToEvents(newBlocker);

	// remove old blockers
	for (var i = 0; i < oldEvents.length; i++)
	{
		document.removeEventListener(oldEvents[i], _Debugger_blocker, true);
	}

	// add new blockers
	for (var i = 0; i < newEvents.length; i++)
	{
		document.addEventListener(newEvents[i], _Debugger_blocker, true);
	}
}


function _Debugger_blocker(event)
{
	if (event.type === 'keydown' && event.metaKey && event.which === 82)
	{
		return;
	}

	var isScroll = event.type === 'scroll' || event.type === 'wheel';
	for (var node = event.target; node; node = node.parentNode)
	{
		if (isScroll ? node.id === 'elm-debugger-details' : node.id === 'elm-debugger-overlay')
		{
			return;
		}
	}

	event.stopPropagation();
	event.preventDefault();
}

function _Debugger_blockerToEvents(blocker)
{
	return blocker === elm$browser$Debugger$Overlay$BlockNone
		? []
		: blocker === elm$browser$Debugger$Overlay$BlockMost
			? _Debugger_mostEvents
			: _Debugger_allEvents;
}

var _Debugger_mostEvents = [
	'click', 'dblclick', 'mousemove',
	'mouseup', 'mousedown', 'mouseenter', 'mouseleave',
	'touchstart', 'touchend', 'touchcancel', 'touchmove',
	'pointerdown', 'pointerup', 'pointerover', 'pointerout',
	'pointerenter', 'pointerleave', 'pointermove', 'pointercancel',
	'dragstart', 'drag', 'dragend', 'dragenter', 'dragover', 'dragleave', 'drop',
	'keyup', 'keydown', 'keypress',
	'input', 'change',
	'focus', 'blur'
];

var _Debugger_allEvents = _Debugger_mostEvents.concat('wheel', 'scroll');





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
					var next = elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? elm$browser$Browser$Internal(next)
							: elm$browser$Browser$External(href)
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
	return elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
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
	return elm$core$Result$isOk(result) ? elm$core$Maybe$Just(result.a) : elm$core$Maybe$Nothing;
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
				: _Scheduler_fail(elm$browser$Browser$Dom$NotFound(id))
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
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function(callback)
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
			A2(elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}
var author$project$Main$Link = function (a) {
	return {$: 'Link', a: a};
};
var author$project$Main$NewUrl = function (a) {
	return {$: 'NewUrl', a: a};
};
var author$project$AppData$TodoistCache = F3(
	function (syncToken, parentProjectID, activityProjectIDs) {
		return {activityProjectIDs: activityProjectIDs, parentProjectID: parentProjectID, syncToken: syncToken};
	});
var elm_community$intdict$IntDict$Empty = {$: 'Empty'};
var elm_community$intdict$IntDict$empty = elm_community$intdict$IntDict$Empty;
var author$project$AppData$emptyTodoistCache = A3(author$project$AppData$TodoistCache, '*', 1, elm_community$intdict$IntDict$empty);
var elm$core$Basics$EQ = {$: 'EQ'};
var elm$core$Basics$LT = {$: 'LT'};
var elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var elm$core$Array$foldr = F3(
	function (func, baseCase, _n0) {
		var tree = _n0.c;
		var tail = _n0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3(elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3(elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			elm$core$Elm$JsArray$foldr,
			helper,
			A3(elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var elm$core$List$cons = _List_cons;
var elm$core$Array$toList = function (array) {
	return A3(elm$core$Array$foldr, elm$core$List$cons, _List_Nil, array);
};
var elm$core$Basics$GT = {$: 'GT'};
var elm$core$Dict$foldr = F3(
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
					A3(elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var elm$core$Dict$toList = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var elm$core$Dict$keys = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2(elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var elm$core$Set$toList = function (_n0) {
	var dict = _n0.a;
	return elm$core$Dict$keys(dict);
};
var author$project$AppData$fromScratch = {activities: elm_community$intdict$IntDict$empty, errors: _List_Nil, tasks: elm_community$intdict$IntDict$empty, timeline: _List_Nil, todoist: author$project$AppData$emptyTodoistCache, uid: 0};
var author$project$AppData$saveError = F2(
	function (appData, error) {
		return _Utils_update(
			appData,
			{
				errors: A2(elm$core$List$cons, error, appData.errors)
			});
	});
var elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var elm$core$Basics$add = _Basics_add;
var elm$core$Basics$gt = _Utils_gt;
var elm$core$List$foldl = F3(
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
var elm$core$List$reverse = function (list) {
	return A3(elm$core$List$foldl, elm$core$List$cons, _List_Nil, list);
};
var elm$core$List$foldrHelper = F4(
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
							elm$core$List$foldl,
							fn,
							acc,
							elm$core$List$reverse(r4)) : A4(elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
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
var elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4(elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var elm$core$Maybe$Nothing = {$: 'Nothing'};
var elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var elm$core$String$trimRight = _String_trimRight;
var elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var elm$core$Basics$append = _Utils_append;
var elm$core$String$fromInt = _String_fromNumber;
var zwilias$json_decode_exploration$Json$Decode$Exploration$expectedTypeToString = function (expectedType) {
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
			return 'an array with index ' + elm$core$String$fromInt(idx);
		default:
			var aField = expectedType.a;
			return 'an object with a field \'' + (aField + '\'');
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$indent = elm$core$List$map(
	elm$core$Basics$append('  '));
var elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3(elm$core$List$foldr, elm$core$List$cons, ys, xs);
		}
	});
var elm$core$List$concat = function (lists) {
	return A3(elm$core$List$foldr, elm$core$List$append, _List_Nil, lists);
};
var elm$core$List$intersperse = F2(
	function (sep, xs) {
		if (!xs.b) {
			return _List_Nil;
		} else {
			var hd = xs.a;
			var tl = xs.b;
			var step = F2(
				function (x, rest) {
					return A2(
						elm$core$List$cons,
						sep,
						A2(elm$core$List$cons, x, rest));
				});
			var spersed = A3(elm$core$List$foldr, step, _List_Nil, tl);
			return A2(elm$core$List$cons, hd, spersed);
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$intercalateMap = F3(
	function (sep, toList, xs) {
		return elm$core$List$concat(
			A2(
				elm$core$List$intersperse,
				_List_fromArray(
					[sep]),
				A2(elm$core$List$map, toList, xs)));
	});
var elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var elm$core$String$lines = _String_lines;
var elm$core$Array$branchFactor = 32;
var elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var elm$core$Basics$ceiling = _Basics_ceiling;
var elm$core$Basics$fdiv = _Basics_fdiv;
var elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var elm$core$Basics$toFloat = _Basics_toFloat;
var elm$core$Array$shiftStep = elm$core$Basics$ceiling(
	A2(elm$core$Basics$logBase, 2, elm$core$Array$branchFactor));
var elm$core$Elm$JsArray$empty = _JsArray_empty;
var elm$core$Array$empty = A4(elm$core$Array$Array_elm_builtin, 0, elm$core$Array$shiftStep, elm$core$Elm$JsArray$empty, elm$core$Elm$JsArray$empty);
var elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _n0 = A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, nodes);
			var node = _n0.a;
			var remainingNodes = _n0.b;
			var newAcc = A2(
				elm$core$List$cons,
				elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var elm$core$Basics$eq = _Utils_equal;
var elm$core$Tuple$first = function (_n0) {
	var x = _n0.a;
	return x;
};
var elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = elm$core$Basics$ceiling(nodeListSize / elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2(elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var elm$core$Basics$floor = _Basics_floor;
var elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var elm$core$Basics$mul = _Basics_mul;
var elm$core$Basics$sub = _Basics_sub;
var elm$core$Elm$JsArray$length = _JsArray_length;
var elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.tail),
				elm$core$Array$shiftStep,
				elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * elm$core$Array$branchFactor;
			var depth = elm$core$Basics$floor(
				A2(elm$core$Basics$logBase, elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2(elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2(elm$core$Basics$max, 5, depth * elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var elm$core$Basics$False = {$: 'False'};
var elm$core$Basics$idiv = _Basics_idiv;
var elm$core$Basics$lt = _Utils_lt;
var elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = elm$core$Array$Leaf(
					A3(elm$core$Elm$JsArray$initialize, elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2(elm$core$List$cons, leaf, nodeList),
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
var elm$core$Basics$le = _Utils_le;
var elm$core$Basics$remainderBy = _Basics_remainderBy;
var elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return elm$core$Array$empty;
		} else {
			var tailLen = len % elm$core$Array$branchFactor;
			var tail = A3(elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - elm$core$Array$branchFactor;
			return A5(elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var elm$core$Basics$True = {$: 'True'};
var elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var elm$core$Basics$and = _Basics_and;
var elm$core$Basics$or = _Basics_or;
var elm$core$Char$toCode = _Char_toCode;
var elm$core$Char$isLower = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var elm$core$Char$isUpper = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var elm$core$Char$isAlpha = function (_char) {
	return elm$core$Char$isLower(_char) || elm$core$Char$isUpper(_char);
};
var elm$core$Char$isDigit = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var elm$core$Char$isAlphaNum = function (_char) {
	return elm$core$Char$isLower(_char) || (elm$core$Char$isUpper(_char) || elm$core$Char$isDigit(_char));
};
var elm$core$List$length = function (xs) {
	return A3(
		elm$core$List$foldl,
		F2(
			function (_n0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var elm$core$List$map2 = _List_map2;
var elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2(elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var elm$core$List$range = F2(
	function (lo, hi) {
		return A3(elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			elm$core$List$map2,
			f,
			A2(
				elm$core$List$range,
				0,
				elm$core$List$length(xs) - 1),
			xs);
	});
var elm$core$String$all = _String_all;
var elm$core$String$uncons = _String_uncons;
var elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var elm$json$Json$Decode$indent = function (str) {
	return A2(
		elm$core$String$join,
		'\n    ',
		A2(elm$core$String$split, '\n', str));
};
var elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + (elm$core$String$fromInt(i + 1) + (') ' + elm$json$Json$Decode$indent(
			elm$json$Json$Decode$errorToString(error))));
	});
var elm$json$Json$Decode$errorToString = function (error) {
	return A2(elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _n1 = elm$core$String$uncons(f);
						if (_n1.$ === 'Nothing') {
							return false;
						} else {
							var _n2 = _n1.a;
							var _char = _n2.a;
							var rest = _n2.b;
							return elm$core$Char$isAlpha(_char) && A2(elm$core$String$all, elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2(elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + (elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2(elm$core$List$cons, indexName, context);
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
									elm$core$String$join,
									'',
									elm$core$List$reverse(context));
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
										elm$core$String$join,
										'',
										elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + (elm$core$String$fromInt(
								elm$core$List$length(errors)) + ' ways:'));
							return A2(
								elm$core$String$join,
								'\n\n',
								A2(
									elm$core$List$cons,
									introduction,
									A2(elm$core$List$indexedMap, elm$json$Json$Decode$errorOneOf, errors)));
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
								elm$core$String$join,
								'',
								elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + (elm$json$Json$Decode$indent(
						A2(elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var elm$json$Json$Encode$encode = _Json_encode;
var zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines = A2(
	elm$core$Basics$composeR,
	elm$json$Json$Encode$encode(2),
	elm$core$String$lines);
var elm$core$List$concatMap = F2(
	function (f, list) {
		return elm$core$List$concat(
			A2(elm$core$List$map, f, list));
	});
var elm$core$Tuple$mapFirst = F2(
	function (func, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$flatten = function (located) {
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
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather, '/' + s, vals);
		default:
			var i = located.a;
			var vals = located.b;
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather,
				'/' + elm$core$String$fromInt(i),
				vals);
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather = F2(
	function (prefix, _n0) {
		var first = _n0.a;
		var rest = _n0.b;
		return A2(
			elm$core$List$map,
			elm$core$Tuple$mapFirst(
				elm$core$Basics$append(prefix)),
			A2(
				elm$core$List$concatMap,
				zwilias$json_decode_exploration$Json$Decode$Exploration$Located$flatten,
				A2(elm$core$List$cons, first, rest)));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$intercalate = F2(
	function (sep, lists) {
		return elm$core$List$concat(
			A2(
				elm$core$List$intersperse,
				_List_fromArray(
					[sep]),
				lists));
	});
var elm$core$String$isEmpty = function (string) {
	return string === '';
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$indent = elm$core$Basics$append('  ');
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$render = F3(
	function (itemToString, path, errors) {
		var formattedErrors = A2(
			elm$core$List$map,
			zwilias$json_decode_exploration$Json$Decode$Exploration$Located$indent,
			A2(elm$core$List$concatMap, itemToString, errors));
		return elm$core$String$isEmpty(path) ? formattedErrors : A2(
			elm$core$List$cons,
			'At path ' + path,
			A2(elm$core$List$cons, '', formattedErrors));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$toString = F2(
	function (itemToString, locatedItems) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Located$intercalate,
			'',
			A2(
				elm$core$List$map,
				function (_n0) {
					var x = _n0.a;
					var vals = _n0.b;
					return A3(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$render, itemToString, x, vals);
				},
				A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$gather, '', locatedItems)));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$errorToString = function (error) {
	switch (error.$) {
		case 'Failure':
			var failure = error.a;
			var json = error.b;
			if (json.$ === 'Just') {
				var val = json.a;
				return A2(
					elm$core$List$cons,
					failure,
					A2(
						elm$core$List$cons,
						'',
						zwilias$json_decode_exploration$Json$Decode$Exploration$indent(
							zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines(val))));
			} else {
				return _List_fromArray(
					[failure]);
			}
		case 'Expected':
			var expectedType = error.a;
			var actualValue = error.b;
			return A2(
				elm$core$List$cons,
				'I expected ' + (zwilias$json_decode_exploration$Json$Decode$Exploration$expectedTypeToString(expectedType) + ' here, but instead found this value:'),
				A2(
					elm$core$List$cons,
					'',
					zwilias$json_decode_exploration$Json$Decode$Exploration$indent(
						zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines(actualValue))));
		default:
			var errors = error.a;
			if (!errors.b) {
				return _List_fromArray(
					['I encountered a `oneOf` without any options.']);
			} else {
				return A2(
					elm$core$List$cons,
					'I encountered multiple issues:',
					A2(
						elm$core$List$cons,
						'',
						A3(zwilias$json_decode_exploration$Json$Decode$Exploration$intercalateMap, '', zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToStrings, errors)));
			}
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToStrings = function (errors) {
	return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$toString, zwilias$json_decode_exploration$Json$Decode$Exploration$errorToString, errors);
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString = function (errors) {
	return A2(
		elm$core$String$join,
		'\n',
		A2(
			elm$core$List$map,
			elm$core$String$trimRight,
			A2(
				elm$core$List$cons,
				'I encountered some errors while decoding this JSON:',
				A2(
					elm$core$List$cons,
					'',
					zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToStrings(errors)))));
};
var author$project$AppData$saveDecodeErrors = F2(
	function (appData, errors) {
		return A2(
			author$project$AppData$saveError,
			appData,
			zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString(errors));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$warningToString = function (warning) {
	var _n0 = function () {
		if (warning.$ === 'Warning') {
			var message_ = warning.a;
			var val_ = warning.b;
			return _Utils_Tuple2(message_, val_);
		} else {
			var val_ = warning.a;
			return _Utils_Tuple2('Unused value:', val_);
		}
	}();
	var message = _n0.a;
	var val = _n0.b;
	return A2(
		elm$core$List$cons,
		message,
		A2(
			elm$core$List$cons,
			'',
			zwilias$json_decode_exploration$Json$Decode$Exploration$indent(
				zwilias$json_decode_exploration$Json$Decode$Exploration$jsonLines(val))));
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToString = function (warnings) {
	return A2(
		elm$core$String$join,
		'\n',
		A2(
			elm$core$List$map,
			elm$core$String$trimRight,
			A2(
				elm$core$List$cons,
				'While I was able to decode this JSON successfully, I did produce one or more warnings:',
				A2(
					elm$core$List$cons,
					'',
					A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$toString, zwilias$json_decode_exploration$Json$Decode$Exploration$warningToString, warnings)))));
};
var author$project$AppData$saveWarnings = F2(
	function (appData, warnings) {
		return _Utils_update(
			appData,
			{
				errors: _Utils_ap(
					_List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToString(warnings)
						]),
					appData.errors)
			});
	});
var author$project$Main$SetZoneAndTime = F2(
	function (a, b) {
		return {$: 'SetZoneAndTime', a: a, b: b};
	});
var author$project$Activity$Activity$Customizations = function (names) {
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
											return {backgroundable: backgroundable, category: category, evidence: evidence, excusable: excusable, hidden: hidden, icon: icon, id: id, maxTime: maxTime, names: names, taskOptional: taskOptional, template: template};
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
var author$project$Activity$Activity$Communication = {$: 'Communication'};
var author$project$Activity$Activity$Entertainment = {$: 'Entertainment'};
var author$project$Activity$Activity$Hygiene = {$: 'Hygiene'};
var author$project$Activity$Activity$Slacking = {$: 'Slacking'};
var author$project$Activity$Activity$Transit = {$: 'Transit'};
var elm$core$Basics$identity = function (x) {
	return x;
};
var elm$core$Result$map = F2(
	function (func, ra) {
		if (ra.$ === 'Ok') {
			var a = ra.a;
			return elm$core$Result$Ok(
				func(a));
		} else {
			var e = ra.a;
			return elm$core$Result$Err(e);
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder = function (a) {
	return {$: 'Decoder', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$andThen = F2(
	function (toDecoderB, _n0) {
		var decoderFnA = _n0.a;
		return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				var _n1 = decoderFnA(json);
				if (_n1.$ === 'Ok') {
					var accA = _n1.a;
					var _n2 = toDecoderB(accA.value);
					var decoderFnB = _n2.a;
					return A2(
						elm$core$Result$map,
						function (accB) {
							return _Utils_update(
								accB,
								{
									warnings: _Utils_ap(accA.warnings, accB.warnings)
								});
						},
						decoderFnB(accA.json));
				} else {
					var e = _n1.a;
					return elm$core$Result$Err(e);
				}
			});
	});
var mgold$elm_nonempty_list$List$Nonempty$Nonempty = F2(
	function (a, b) {
		return {$: 'Nonempty', a: a, b: b};
	});
var mgold$elm_nonempty_list$List$Nonempty$fromElement = function (x) {
	return A2(mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, _List_Nil);
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var elm$core$Tuple$mapSecond = F2(
	function (func, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var elm$json$Json$Encode$bool = _Json_wrap;
var elm$json$Json$Encode$float = _Json_wrap;
var elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var elm$json$Json$Encode$null = _Json_encodeNull;
var elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			elm$core$List$foldl,
			F2(
				function (_n0, obj) {
					var k = _n0.a;
					var v = _n0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var elm$json$Json$Encode$string = _Json_wrap;
var zwilias$json_decode_exploration$Json$Decode$Exploration$encode = function (v) {
	switch (v.$) {
		case 'String':
			var val = v.b;
			return elm$json$Json$Encode$string(val);
		case 'Number':
			var val = v.b;
			return elm$json$Json$Encode$float(val);
		case 'Bool':
			var val = v.b;
			return elm$json$Json$Encode$bool(val);
		case 'Null':
			return elm$json$Json$Encode$null;
		case 'Array':
			var values = v.b;
			return A2(elm$json$Json$Encode$list, zwilias$json_decode_exploration$Json$Decode$Exploration$encode, values);
		default:
			var kvPairs = v.b;
			return elm$json$Json$Encode$object(
				A2(
					elm$core$List$map,
					elm$core$Tuple$mapSecond(zwilias$json_decode_exploration$Json$Decode$Exploration$encode),
					kvPairs));
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here = function (a) {
	return {$: 'Here', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$fail = function (message) {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			return elm$core$Result$Err(
				mgold$elm_nonempty_list$List$Nonempty$fromElement(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
						A2(
							zwilias$json_decode_exploration$Json$Decode$Exploration$Failure,
							message,
							elm$core$Maybe$Just(
								zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json))))));
		});
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TString = {$: 'TString'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Expected = F2(
	function (a, b) {
		return {$: 'Expected', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$expected = F2(
	function (expectedType, json) {
		return elm$core$Result$Err(
			mgold$elm_nonempty_list$List$Nonempty$fromElement(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
					A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Expected,
						expectedType,
						zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Array = F2(
	function (a, b) {
		return {$: 'Array', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Bool = F2(
	function (a, b) {
		return {$: 'Bool', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Null = function (a) {
	return {$: 'Null', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Number = F2(
	function (a, b) {
		return {$: 'Number', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Object = F2(
	function (a, b) {
		return {$: 'Object', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$String = F2(
	function (a, b) {
		return {$: 'String', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed = function (annotatedValue) {
	switch (annotatedValue.$) {
		case 'String':
			var val = annotatedValue.b;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$String, true, val);
		case 'Number':
			var val = annotatedValue.b;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Number, true, val);
		case 'Bool':
			var val = annotatedValue.b;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Bool, true, val);
		case 'Null':
			return zwilias$json_decode_exploration$Json$Decode$Exploration$Null(true);
		case 'Array':
			var values = annotatedValue.b;
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Array,
				true,
				A2(elm$core$List$map, zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed, values));
		default:
			var values = annotatedValue.b;
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Object,
				true,
				A2(
					elm$core$List$map,
					elm$core$Tuple$mapSecond(zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed),
					values));
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$ok = F2(
	function (json, val) {
		return elm$core$Result$Ok(
			{json: json, value: val, warnings: _List_Nil});
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$string = zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'String') {
			var val = json.b;
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				val);
		} else {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TString, json);
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$succeed = function (val) {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$ok, json, val);
		});
};
var author$project$Activity$Activity$decodeCategory = A2(
	zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
	function (string) {
		switch (string) {
			case 'Transit':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Transit);
			case 'Entertainment':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Entertainment);
			case 'Hygiene':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Hygiene);
			case 'Slacking':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Slacking);
			case 'Communication':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Communication);
			default:
				return zwilias$json_decode_exploration$Json$Decode$Exploration$fail('Invalid Category');
		}
	},
	zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var author$project$SmartTime$Duration$Duration = function (a) {
	return {$: 'Duration', a: a};
};
var author$project$SmartTime$Duration$fromInt = function (_int) {
	return author$project$SmartTime$Duration$Duration(_int);
};
var author$project$SmartTime$Duration$inMs = function (_n0) {
	var _int = _n0.a;
	return _int;
};
var author$project$SmartTime$Duration$millisecondLength = 1;
var author$project$SmartTime$Duration$secondLength = 1000 * author$project$SmartTime$Duration$millisecondLength;
var author$project$SmartTime$Duration$minuteLength = 60 * author$project$SmartTime$Duration$secondLength;
var author$project$SmartTime$Duration$hourLength = 60 * author$project$SmartTime$Duration$minuteLength;
var author$project$SmartTime$Duration$inWholeHours = function (duration) {
	return (author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$hourLength) | 0;
};
var author$project$SmartTime$Duration$inWholeMinutes = function (duration) {
	return (author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$minuteLength) | 0;
};
var author$project$SmartTime$Duration$inWholeSeconds = function (duration) {
	return (author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$secondLength) | 0;
};
var author$project$SmartTime$Human$Duration$Days = function (a) {
	return {$: 'Days', a: a};
};
var author$project$SmartTime$Human$Duration$Hours = function (a) {
	return {$: 'Hours', a: a};
};
var author$project$SmartTime$Human$Duration$Milliseconds = function (a) {
	return {$: 'Milliseconds', a: a};
};
var author$project$SmartTime$Human$Duration$Minutes = function (a) {
	return {$: 'Minutes', a: a};
};
var author$project$SmartTime$Human$Duration$Seconds = function (a) {
	return {$: 'Seconds', a: a};
};
var author$project$SmartTime$Duration$dayLength = 24 * author$project$SmartTime$Duration$hourLength;
var author$project$SmartTime$Duration$breakdown = function (duration) {
	var all = author$project$SmartTime$Duration$inMs(duration);
	var days = (all / author$project$SmartTime$Duration$dayLength) | 0;
	var withoutDays = all - (days * author$project$SmartTime$Duration$dayLength);
	var hours = (withoutDays / author$project$SmartTime$Duration$hourLength) | 0;
	var withoutHours = withoutDays - (hours * author$project$SmartTime$Duration$hourLength);
	var minutes = (withoutHours / author$project$SmartTime$Duration$minuteLength) | 0;
	var withoutMinutes = withoutHours - (minutes * author$project$SmartTime$Duration$minuteLength);
	var seconds = (withoutMinutes / author$project$SmartTime$Duration$secondLength) | 0;
	var withoutSeconds = withoutMinutes - (seconds * author$project$SmartTime$Duration$secondLength);
	return {days: days, hours: hours, milliseconds: withoutSeconds, minutes: minutes, seconds: seconds};
};
var author$project$SmartTime$Human$Duration$breakdownDHMSM = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var days = _n0.days;
	var hours = _n0.hours;
	var minutes = _n0.minutes;
	var seconds = _n0.seconds;
	var milliseconds = _n0.milliseconds;
	return _List_fromArray(
		[
			author$project$SmartTime$Human$Duration$Days(days),
			author$project$SmartTime$Human$Duration$Hours(hours),
			author$project$SmartTime$Human$Duration$Minutes(minutes),
			author$project$SmartTime$Human$Duration$Seconds(seconds),
			author$project$SmartTime$Human$Duration$Milliseconds(milliseconds)
		]);
};
var elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return elm$core$Maybe$Just(x);
	} else {
		return elm$core$Maybe$Nothing;
	}
};
var elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var author$project$SmartTime$Human$Duration$inLargestExactUnits = function (duration) {
	var partsSmallToBig = elm$core$List$reverse(
		author$project$SmartTime$Human$Duration$breakdownDHMSM(duration));
	var smallestPart = A2(
		elm$core$Maybe$withDefault,
		author$project$SmartTime$Human$Duration$Milliseconds(0),
		elm$core$List$head(partsSmallToBig));
	switch (smallestPart.$) {
		case 'Days':
			var days = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Days(days);
		case 'Hours':
			var hours = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Hours(
				author$project$SmartTime$Duration$inWholeHours(duration));
		case 'Minutes':
			var minutes = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Minutes(
				author$project$SmartTime$Duration$inWholeMinutes(duration));
		case 'Seconds':
			var seconds = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Seconds(
				author$project$SmartTime$Duration$inWholeSeconds(duration));
		default:
			var milliseconds = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Milliseconds(
				author$project$SmartTime$Duration$inMs(duration));
	}
};
var elm$core$Basics$round = _Basics_round;
var zwilias$json_decode_exploration$Json$Decode$Exploration$TInt = {$: 'TInt'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$int = zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Number') {
			var val = json.b;
			return _Utils_eq(
				elm$core$Basics$round(val),
				val) ? A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				elm$core$Basics$round(val)) : A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TInt, json);
		} else {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TInt, json);
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$mapAcc = F2(
	function (f, acc) {
		return {
			json: acc.json,
			value: f(acc.value),
			warnings: acc.warnings
		};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$map = F2(
	function (f, _n0) {
		var decoderFn = _n0.a;
		return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				return A2(
					elm$core$Result$map,
					zwilias$json_decode_exploration$Json$Decode$Exploration$mapAcc(f),
					decoderFn(json));
			});
	});
var author$project$Activity$Activity$decodeHumanDuration = function () {
	var convertAndNormalize = function (durationAsInt) {
		return author$project$SmartTime$Human$Duration$inLargestExactUnits(
			author$project$SmartTime$Duration$fromInt(durationAsInt));
	};
	return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, convertAndNormalize, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
}();
var elm$core$Tuple$second = function (_n0) {
	var y = _n0.b;
	return y;
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TArray = {$: 'TArray'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TArrayIndex = function (a) {
	return {$: 'TArrayIndex', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex = F2(
	function (a, b) {
		return {$: 'AtIndex', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$index = F2(
	function (idx, _n0) {
		var decoderFn = _n0.a;
		var finalize = F2(
			function (json, _n6) {
				var values = _n6.a;
				var warnings = _n6.b;
				var res = _n6.c;
				if (res.$ === 'Nothing') {
					return A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$expected,
						zwilias$json_decode_exploration$Json$Decode$Exploration$TArrayIndex(idx),
						json);
				} else {
					if (res.a.$ === 'Err') {
						var e = res.a.a;
						return elm$core$Result$Err(e);
					} else {
						var v = res.a.a;
						return elm$core$Result$Ok(
							{
								json: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, values),
								value: v,
								warnings: warnings
							});
					}
				}
			});
		var accumulate = F2(
			function (val, _n3) {
				var i = _n3.a;
				var _n4 = _n3.b;
				var acc = _n4.a;
				var warnings = _n4.b;
				var result = _n4.c;
				if (_Utils_eq(i, idx)) {
					var _n2 = decoderFn(val);
					if (_n2.$ === 'Err') {
						var e = _n2.a;
						return _Utils_Tuple2(
							i - 1,
							_Utils_Tuple3(
								A2(elm$core$List$cons, val, acc),
								warnings,
								elm$core$Maybe$Just(
									elm$core$Result$Err(
										mgold$elm_nonempty_list$List$Nonempty$fromElement(
											A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex, i, e))))));
					} else {
						var res = _n2.a;
						return _Utils_Tuple2(
							i - 1,
							_Utils_Tuple3(
								A2(elm$core$List$cons, res.json, acc),
								_Utils_ap(res.warnings, warnings),
								elm$core$Maybe$Just(
									elm$core$Result$Ok(res.value))));
					}
				} else {
					return _Utils_Tuple2(
						i - 1,
						_Utils_Tuple3(
							A2(elm$core$List$cons, val, acc),
							warnings,
							result));
				}
			});
		return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				if (json.$ === 'Array') {
					var values = json.b;
					return A2(
						finalize,
						json,
						A3(
							elm$core$List$foldr,
							accumulate,
							_Utils_Tuple2(
								elm$core$List$length(values) - 1,
								_Utils_Tuple3(_List_Nil, _List_Nil, elm$core$Maybe$Nothing)),
							values).b);
				} else {
					return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TArray, json);
				}
			});
	});
var author$project$Porting$arrayAsTuple2 = F2(
	function (a, b) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (aVal) {
				return A2(
					zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
					function (bVal) {
						return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
							_Utils_Tuple2(aVal, bVal));
					},
					A2(zwilias$json_decode_exploration$Json$Decode$Exploration$index, 1, b));
			},
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$index, 0, a));
	});
var author$project$Activity$Activity$decodeDurationPerPeriod = A2(author$project$Porting$arrayAsTuple2, author$project$Activity$Activity$decodeHumanDuration, author$project$Activity$Activity$decodeHumanDuration);
var author$project$Activity$Activity$Evidence = {$: 'Evidence'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$check = F3(
	function (checkDecoder, expectedVal, actualDecoder) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (actual) {
				return _Utils_eq(actual, expectedVal) ? actualDecoder : zwilias$json_decode_exploration$Json$Decode$Exploration$fail('Verification failed');
			},
			checkDecoder);
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$BadOneOf = function (a) {
	return {$: 'BadOneOf', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$oneOfHelp = F3(
	function (decoders, val, errorAcc) {
		oneOfHelp:
		while (true) {
			if (!decoders.b) {
				return elm$core$Result$Err(
					mgold$elm_nonempty_list$List$Nonempty$fromElement(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							zwilias$json_decode_exploration$Json$Decode$Exploration$BadOneOf(
								elm$core$List$reverse(errorAcc)))));
			} else {
				var decoderFn = decoders.a.a;
				var rest = decoders.b;
				var _n1 = decoderFn(val);
				if (_n1.$ === 'Ok') {
					var res = _n1.a;
					return elm$core$Result$Ok(res);
				} else {
					var e = _n1.a;
					var $temp$decoders = rest,
						$temp$val = val,
						$temp$errorAcc = A2(elm$core$List$cons, e, errorAcc);
					decoders = $temp$decoders;
					val = $temp$val;
					errorAcc = $temp$errorAcc;
					continue oneOfHelp;
				}
			}
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf = function (decoders) {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			return A3(zwilias$json_decode_exploration$Json$Decode$Exploration$oneOfHelp, decoders, json, _List_Nil);
		});
};
var author$project$Porting$decodeCustom = function (tagsWithDecoders) {
	var tryValues = function (_n0) {
		var tag = _n0.a;
		var decoder = _n0.b;
		return A3(zwilias$json_decode_exploration$Json$Decode$Exploration$check, zwilias$json_decode_exploration$Json$Decode$Exploration$string, tag, decoder);
	};
	return zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
		A2(elm$core$List$map, tryValues, tagsWithDecoders));
};
var author$project$Activity$Activity$decodeEvidence = author$project$Porting$decodeCustom(
	_List_fromArray(
		[
			_Utils_Tuple2(
			'Evidence',
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Evidence))
		]));
var author$project$Activity$Activity$IndefinitelyExcused = {$: 'IndefinitelyExcused'};
var author$project$Activity$Activity$NeverExcused = {$: 'NeverExcused'};
var author$project$Activity$Activity$TemporarilyExcused = function (a) {
	return {$: 'TemporarilyExcused', a: a};
};
var author$project$Activity$Activity$decodeExcusable = author$project$Porting$decodeCustom(
	_List_fromArray(
		[
			_Utils_Tuple2(
			'NeverExcused',
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$NeverExcused)),
			_Utils_Tuple2(
			'TemporarilyExcused',
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$Activity$Activity$TemporarilyExcused, author$project$Activity$Activity$decodeDurationPerPeriod)),
			_Utils_Tuple2(
			'IndefinitelyExcused',
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$IndefinitelyExcused))
		]));
var author$project$Activity$Activity$Ion = {$: 'Ion'};
var author$project$Activity$Activity$Other = {$: 'Other'};
var author$project$Activity$Activity$File = function (a) {
	return {$: 'File', a: a};
};
var author$project$Activity$Activity$decodeFile = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$Activity$Activity$File, zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var author$project$Activity$Activity$decodeIcon = author$project$Porting$decodeCustom(
	_List_fromArray(
		[
			_Utils_Tuple2('File', author$project$Activity$Activity$decodeFile),
			_Utils_Tuple2(
			'Ion',
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Ion)),
			_Utils_Tuple2(
			'Other',
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Activity$Activity$Other))
		]));
var author$project$Activity$Template$Apparel = {$: 'Apparel'};
var author$project$Activity$Template$Bedward = {$: 'Bedward'};
var author$project$Activity$Template$BrainTrain = {$: 'BrainTrain'};
var author$project$Activity$Template$Broadcast = {$: 'Broadcast'};
var author$project$Activity$Template$Browse = {$: 'Browse'};
var author$project$Activity$Template$Call = {$: 'Call'};
var author$project$Activity$Template$Children = {$: 'Children'};
var author$project$Activity$Template$Chores = {$: 'Chores'};
var author$project$Activity$Template$Cinema = {$: 'Cinema'};
var author$project$Activity$Template$Configure = {$: 'Configure'};
var author$project$Activity$Template$Course = {$: 'Course'};
var author$project$Activity$Template$Create = {$: 'Create'};
var author$project$Activity$Template$DillyDally = {$: 'DillyDally'};
var author$project$Activity$Template$Driving = {$: 'Driving'};
var author$project$Activity$Template$Email = {$: 'Email'};
var author$project$Activity$Template$Fiction = {$: 'Fiction'};
var author$project$Activity$Template$FilmWatching = {$: 'FilmWatching'};
var author$project$Activity$Template$Finance = {$: 'Finance'};
var author$project$Activity$Template$Flight = {$: 'Flight'};
var author$project$Activity$Template$Floss = {$: 'Floss'};
var author$project$Activity$Template$Grooming = {$: 'Grooming'};
var author$project$Activity$Template$Homework = {$: 'Homework'};
var author$project$Activity$Template$Housekeeping = {$: 'Housekeeping'};
var author$project$Activity$Template$Laundry = {$: 'Laundry'};
var author$project$Activity$Template$Learning = {$: 'Learning'};
var author$project$Activity$Template$Lover = {$: 'Lover'};
var author$project$Activity$Template$Meal = {$: 'Meal'};
var author$project$Activity$Template$MealPrep = {$: 'MealPrep'};
var author$project$Activity$Template$Meditate = {$: 'Meditate'};
var author$project$Activity$Template$Meeting = {$: 'Meeting'};
var author$project$Activity$Template$Messaging = {$: 'Messaging'};
var author$project$Activity$Template$Music = {$: 'Music'};
var author$project$Activity$Template$Networking = {$: 'Networking'};
var author$project$Activity$Template$Pacing = {$: 'Pacing'};
var author$project$Activity$Template$Parents = {$: 'Parents'};
var author$project$Activity$Template$Pet = {$: 'Pet'};
var author$project$Activity$Template$Plan = {$: 'Plan'};
var author$project$Activity$Template$Prepare = {$: 'Prepare'};
var author$project$Activity$Template$Presentation = {$: 'Presentation'};
var author$project$Activity$Template$Projects = {$: 'Projects'};
var author$project$Activity$Template$Restroom = {$: 'Restroom'};
var author$project$Activity$Template$Riding = {$: 'Riding'};
var author$project$Activity$Template$Series = {$: 'Series'};
var author$project$Activity$Template$Shopping = {$: 'Shopping'};
var author$project$Activity$Template$Shower = {$: 'Shower'};
var author$project$Activity$Template$Sleep = {$: 'Sleep'};
var author$project$Activity$Template$SocialMedia = {$: 'SocialMedia'};
var author$project$Activity$Template$Sport = {$: 'Sport'};
var author$project$Activity$Template$Supplements = {$: 'Supplements'};
var author$project$Activity$Template$Theatre = {$: 'Theatre'};
var author$project$Activity$Template$Toothbrush = {$: 'Toothbrush'};
var author$project$Activity$Template$VideoGaming = {$: 'VideoGaming'};
var author$project$Activity$Template$Wakeup = {$: 'Wakeup'};
var author$project$Activity$Template$Work = {$: 'Work'};
var author$project$Activity$Template$Workout = {$: 'Workout'};
var author$project$Porting$decodeCustomFlat = function (tags) {
	var justTag = elm$core$Tuple$mapSecond(zwilias$json_decode_exploration$Json$Decode$Exploration$succeed);
	return author$project$Porting$decodeCustom(
		A2(elm$core$List$map, justTag, tags));
};
var author$project$Activity$Template$decodeTemplate = author$project$Porting$decodeCustomFlat(
	_List_fromArray(
		[
			_Utils_Tuple2('DillyDally', author$project$Activity$Template$DillyDally),
			_Utils_Tuple2('Apparel', author$project$Activity$Template$Apparel),
			_Utils_Tuple2('Messaging', author$project$Activity$Template$Messaging),
			_Utils_Tuple2('Restroom', author$project$Activity$Template$Restroom),
			_Utils_Tuple2('Grooming', author$project$Activity$Template$Grooming),
			_Utils_Tuple2('Meal', author$project$Activity$Template$Meal),
			_Utils_Tuple2('Supplements', author$project$Activity$Template$Supplements),
			_Utils_Tuple2('Workout', author$project$Activity$Template$Workout),
			_Utils_Tuple2('Shower', author$project$Activity$Template$Shower),
			_Utils_Tuple2('Toothbrush', author$project$Activity$Template$Toothbrush),
			_Utils_Tuple2('Floss', author$project$Activity$Template$Floss),
			_Utils_Tuple2('Wakeup', author$project$Activity$Template$Wakeup),
			_Utils_Tuple2('Sleep', author$project$Activity$Template$Sleep),
			_Utils_Tuple2('Plan', author$project$Activity$Template$Plan),
			_Utils_Tuple2('Configure', author$project$Activity$Template$Configure),
			_Utils_Tuple2('Email', author$project$Activity$Template$Email),
			_Utils_Tuple2('Work', author$project$Activity$Template$Work),
			_Utils_Tuple2('Call', author$project$Activity$Template$Call),
			_Utils_Tuple2('Chores', author$project$Activity$Template$Chores),
			_Utils_Tuple2('Parents', author$project$Activity$Template$Parents),
			_Utils_Tuple2('Prepare', author$project$Activity$Template$Prepare),
			_Utils_Tuple2('Lover', author$project$Activity$Template$Lover),
			_Utils_Tuple2('Driving', author$project$Activity$Template$Driving),
			_Utils_Tuple2('Riding', author$project$Activity$Template$Riding),
			_Utils_Tuple2('SocialMedia', author$project$Activity$Template$SocialMedia),
			_Utils_Tuple2('Pacing', author$project$Activity$Template$Pacing),
			_Utils_Tuple2('Sport', author$project$Activity$Template$Sport),
			_Utils_Tuple2('Finance', author$project$Activity$Template$Finance),
			_Utils_Tuple2('Laundry', author$project$Activity$Template$Laundry),
			_Utils_Tuple2('Bedward', author$project$Activity$Template$Bedward),
			_Utils_Tuple2('Browse', author$project$Activity$Template$Browse),
			_Utils_Tuple2('Fiction', author$project$Activity$Template$Fiction),
			_Utils_Tuple2('Learning', author$project$Activity$Template$Learning),
			_Utils_Tuple2('BrainTrain', author$project$Activity$Template$BrainTrain),
			_Utils_Tuple2('Music', author$project$Activity$Template$Music),
			_Utils_Tuple2('Create', author$project$Activity$Template$Create),
			_Utils_Tuple2('Children', author$project$Activity$Template$Children),
			_Utils_Tuple2('Meeting', author$project$Activity$Template$Meeting),
			_Utils_Tuple2('Cinema', author$project$Activity$Template$Cinema),
			_Utils_Tuple2('FilmWatching', author$project$Activity$Template$FilmWatching),
			_Utils_Tuple2('Series', author$project$Activity$Template$Series),
			_Utils_Tuple2('Broadcast', author$project$Activity$Template$Broadcast),
			_Utils_Tuple2('Theatre', author$project$Activity$Template$Theatre),
			_Utils_Tuple2('Shopping', author$project$Activity$Template$Shopping),
			_Utils_Tuple2('VideoGaming', author$project$Activity$Template$VideoGaming),
			_Utils_Tuple2('Housekeeping', author$project$Activity$Template$Housekeeping),
			_Utils_Tuple2('MealPrep', author$project$Activity$Template$MealPrep),
			_Utils_Tuple2('Networking', author$project$Activity$Template$Networking),
			_Utils_Tuple2('Meditate', author$project$Activity$Template$Meditate),
			_Utils_Tuple2('Homework', author$project$Activity$Template$Homework),
			_Utils_Tuple2('Flight', author$project$Activity$Template$Flight),
			_Utils_Tuple2('Course', author$project$Activity$Template$Course),
			_Utils_Tuple2('Pet', author$project$Activity$Template$Pet),
			_Utils_Tuple2('Presentation', author$project$Activity$Template$Presentation),
			_Utils_Tuple2('Projects', author$project$Activity$Template$Projects)
		]));
var author$project$ID$ID = function (a) {
	return {$: 'ID', a: a};
};
var author$project$ID$decode = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$ID$ID, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var mgold$elm_nonempty_list$List$Nonempty$append = F2(
	function (_n0, _n1) {
		var x = _n0.a;
		var xs = _n0.b;
		var y = _n1.a;
		var ys = _n1.b;
		return A2(
			mgold$elm_nonempty_list$List$Nonempty$Nonempty,
			x,
			_Utils_ap(
				xs,
				A2(elm$core$List$cons, y, ys)));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$map2 = F3(
	function (f, _n0, _n1) {
		var decoderFnA = _n0.a;
		var decoderFnB = _n1.a;
		return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				var _n2 = decoderFnA(json);
				if (_n2.$ === 'Ok') {
					var accA = _n2.a;
					var _n3 = decoderFnB(accA.json);
					if (_n3.$ === 'Ok') {
						var accB = _n3.a;
						return elm$core$Result$Ok(
							{
								json: accB.json,
								value: A2(f, accA.value, accB.value),
								warnings: _Utils_ap(accA.warnings, accB.warnings)
							});
					} else {
						var e = _n3.a;
						return elm$core$Result$Err(e);
					}
				} else {
					var e = _n2.a;
					var _n4 = decoderFnB(json);
					if (_n4.$ === 'Ok') {
						return elm$core$Result$Err(e);
					} else {
						var e2 = _n4.a;
						return elm$core$Result$Err(
							A2(mgold$elm_nonempty_list$List$Nonempty$append, e, e2));
					}
				}
			});
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$andMap = zwilias$json_decode_exploration$Json$Decode$Exploration$map2(elm$core$Basics$apR);
var zwilias$json_decode_exploration$Json$Decode$Exploration$TObject = {$: 'TObject'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TObjectField = function (a) {
	return {$: 'TObjectField', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField = F2(
	function (a, b) {
		return {$: 'InField', a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$field = F2(
	function (fieldName, _n0) {
		var decoderFn = _n0.a;
		var finalize = F2(
			function (json, _n6) {
				var values = _n6.a;
				var warnings = _n6.b;
				var res = _n6.c;
				if (res.$ === 'Nothing') {
					return A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$expected,
						zwilias$json_decode_exploration$Json$Decode$Exploration$TObjectField(fieldName),
						json);
				} else {
					if (res.a.$ === 'Err') {
						var e = res.a.a;
						return elm$core$Result$Err(e);
					} else {
						var v = res.a.a;
						return elm$core$Result$Ok(
							{
								json: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, values),
								value: v,
								warnings: warnings
							});
					}
				}
			});
		var accumulate = F2(
			function (_n3, _n4) {
				var key = _n3.a;
				var val = _n3.b;
				var acc = _n4.a;
				var warnings = _n4.b;
				var result = _n4.c;
				if (_Utils_eq(key, fieldName)) {
					var _n2 = decoderFn(val);
					if (_n2.$ === 'Err') {
						var e = _n2.a;
						return _Utils_Tuple3(
							A2(
								elm$core$List$cons,
								_Utils_Tuple2(key, val),
								acc),
							warnings,
							elm$core$Maybe$Just(
								elm$core$Result$Err(
									mgold$elm_nonempty_list$List$Nonempty$fromElement(
										A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField, key, e)))));
					} else {
						var res = _n2.a;
						return _Utils_Tuple3(
							A2(
								elm$core$List$cons,
								_Utils_Tuple2(key, res.json),
								acc),
							_Utils_ap(
								A2(
									elm$core$List$map,
									A2(
										elm$core$Basics$composeR,
										mgold$elm_nonempty_list$List$Nonempty$fromElement,
										zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField(key)),
									res.warnings),
								warnings),
							elm$core$Maybe$Just(
								elm$core$Result$Ok(res.value)));
					}
				} else {
					return _Utils_Tuple3(
						A2(
							elm$core$List$cons,
							_Utils_Tuple2(key, val),
							acc),
						warnings,
						result);
				}
			});
		return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
			function (json) {
				if (json.$ === 'Object') {
					var kvPairs = json.b;
					return A2(
						finalize,
						json,
						A3(
							elm$core$List$foldr,
							accumulate,
							_Utils_Tuple3(_List_Nil, _List_Nil, elm$core$Maybe$Nothing),
							kvPairs));
				} else {
					return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TObject, json);
				}
			});
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$isObject = zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Object') {
			var pairs = json.b;
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, pairs),
				_Utils_Tuple0);
		} else {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TObject, json);
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$TNull = {$: 'TNull'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$null = function (val) {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			if (json.$ === 'Null') {
				return A2(
					zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
					zwilias$json_decode_exploration$Json$Decode$Exploration$Null(true),
					val);
			} else {
				return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TNull, json);
			}
		});
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$resolve = zwilias$json_decode_exploration$Json$Decode$Exploration$andThen(elm$core$Basics$identity);
var zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optionalField = F3(
	function (field, decoder, fallback) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (_n0) {
				return zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$resolve(
					zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
						_List_fromArray(
							[
								A2(
								zwilias$json_decode_exploration$Json$Decode$Exploration$field,
								field,
								zwilias$json_decode_exploration$Json$Decode$Exploration$null(
									zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(fallback))),
								A2(
								zwilias$json_decode_exploration$Json$Decode$Exploration$field,
								field,
								zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
									A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, field, decoder))),
								zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
								zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(fallback))
							])));
			},
			zwilias$json_decode_exploration$Json$Decode$Exploration$isObject);
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional = F4(
	function (key, valDecoder, fallback, decoder) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andMap,
			A3(zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optionalField, key, valDecoder, fallback),
			decoder);
	});
var author$project$Porting$ifPresent = F2(
	function (fieldName, decoder) {
		return A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			fieldName,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Maybe$Just, decoder),
			elm$core$Maybe$Nothing);
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$TBool = {$: 'TBool'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$bool = zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Bool') {
			var val = json.b;
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				val);
		} else {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TBool, json);
		}
	});
var mgold$elm_nonempty_list$List$Nonempty$cons = F2(
	function (y, _n0) {
		var x = _n0.a;
		var xs = _n0.b;
		return A2(
			mgold$elm_nonempty_list$List$Nonempty$Nonempty,
			y,
			A2(elm$core$List$cons, x, xs));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$list = function (_n0) {
	var decoderFn = _n0.a;
	var finalize = function (_n5) {
		var json = _n5.a;
		var warnings = _n5.b;
		var values = _n5.c;
		return {
			json: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, json),
			value: values,
			warnings: warnings
		};
	};
	var accumulate = F2(
		function (val, _n4) {
			var idx = _n4.a;
			var acc = _n4.b;
			var _n2 = _Utils_Tuple2(
				acc,
				decoderFn(val));
			if (_n2.a.$ === 'Err') {
				if (_n2.b.$ === 'Err') {
					var errors = _n2.a.a;
					var newErrors = _n2.b.a;
					return _Utils_Tuple2(
						idx - 1,
						elm$core$Result$Err(
							A2(
								mgold$elm_nonempty_list$List$Nonempty$cons,
								A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex, idx, newErrors),
								errors)));
				} else {
					var errors = _n2.a.a;
					return _Utils_Tuple2(
						idx - 1,
						elm$core$Result$Err(errors));
				}
			} else {
				if (_n2.b.$ === 'Err') {
					var errors = _n2.b.a;
					return _Utils_Tuple2(
						idx - 1,
						elm$core$Result$Err(
							mgold$elm_nonempty_list$List$Nonempty$fromElement(
								A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex, idx, errors))));
				} else {
					var _n3 = _n2.a.a;
					var jsonAcc = _n3.a;
					var warnAcc = _n3.b;
					var valAcc = _n3.c;
					var res = _n2.b.a;
					return _Utils_Tuple2(
						idx - 1,
						elm$core$Result$Ok(
							_Utils_Tuple3(
								A2(elm$core$List$cons, res.json, jsonAcc),
								_Utils_ap(res.warnings, warnAcc),
								A2(elm$core$List$cons, res.value, valAcc))));
				}
			}
		});
	return zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
		function (json) {
			if (json.$ === 'Array') {
				var values = json.b;
				return A2(
					elm$core$Result$map,
					finalize,
					A3(
						elm$core$List$foldr,
						accumulate,
						_Utils_Tuple2(
							elm$core$List$length(values) - 1,
							elm$core$Result$Ok(
								_Utils_Tuple3(_List_Nil, _List_Nil, _List_Nil))),
						values).b);
			} else {
				return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TArray, json);
			}
		});
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode = zwilias$json_decode_exploration$Json$Decode$Exploration$succeed;
var zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required = F3(
	function (key, valDecoder, decoder) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andMap,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, key, valDecoder),
			decoder);
	});
var author$project$Activity$Activity$decodeCustomizations = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'id',
	author$project$ID$decode,
	A3(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'template',
		author$project$Activity$Template$decodeTemplate,
		A3(
			author$project$Porting$ifPresent,
			'hidden',
			zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
			A3(
				author$project$Porting$ifPresent,
				'maxTime',
				author$project$Activity$Activity$decodeDurationPerPeriod,
				A3(
					author$project$Porting$ifPresent,
					'backgroundable',
					zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
					A3(
						author$project$Porting$ifPresent,
						'category',
						author$project$Activity$Activity$decodeCategory,
						A3(
							author$project$Porting$ifPresent,
							'evidence',
							zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Activity$Activity$decodeEvidence),
							A3(
								author$project$Porting$ifPresent,
								'taskOptional',
								zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
								A3(
									author$project$Porting$ifPresent,
									'excusable',
									author$project$Activity$Activity$decodeExcusable,
									A3(
										author$project$Porting$ifPresent,
										'icon',
										author$project$Activity$Activity$decodeIcon,
										A3(
											author$project$Porting$ifPresent,
											'names',
											zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$string),
											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Activity$Activity$Customizations))))))))))));
var elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var author$project$Porting$decodeTuple2 = F2(
	function (decoderA, decoderB) {
		return A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$map2,
			elm$core$Tuple$pair,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$index, 0, decoderA),
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$index, 1, decoderB));
	});
var elm$core$Basics$always = F2(
	function (a, _n0) {
		return a;
	});
var elm_community$intdict$IntDict$Inner = function (a) {
	return {$: 'Inner', a: a};
};
var elm_community$intdict$IntDict$size = function (dict) {
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
var elm_community$intdict$IntDict$inner = F3(
	function (p, l, r) {
		var _n0 = _Utils_Tuple2(l, r);
		if (_n0.a.$ === 'Empty') {
			var _n1 = _n0.a;
			return r;
		} else {
			if (_n0.b.$ === 'Empty') {
				var _n2 = _n0.b;
				return l;
			} else {
				return elm_community$intdict$IntDict$Inner(
					{
						left: l,
						prefix: p,
						right: r,
						size: elm_community$intdict$IntDict$size(l) + elm_community$intdict$IntDict$size(r)
					});
			}
		}
	});
var elm$core$Basics$neq = _Utils_notEqual;
var elm$core$Bitwise$and = _Bitwise_and;
var elm$core$Bitwise$xor = _Bitwise_xor;
var elm$core$Basics$negate = function (n) {
	return -n;
};
var elm$core$Bitwise$complement = _Bitwise_complement;
var elm$core$Bitwise$or = _Bitwise_or;
var elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var elm_community$intdict$IntDict$highestBitSet = function (n) {
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
var elm_community$intdict$IntDict$signBit = elm_community$intdict$IntDict$highestBitSet(-1);
var elm_community$intdict$IntDict$isBranchingBitSet = function (p) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Bitwise$xor(elm_community$intdict$IntDict$signBit),
		A2(
			elm$core$Basics$composeR,
			elm$core$Bitwise$and(p.branchingBit),
			elm$core$Basics$neq(0)));
};
var elm_community$intdict$IntDict$higherBitMask = function (branchingBit) {
	return branchingBit ^ (~(branchingBit - 1));
};
var elm_community$intdict$IntDict$lcp = F2(
	function (x, y) {
		var branchingBit = elm_community$intdict$IntDict$highestBitSet(x ^ y);
		var mask = elm_community$intdict$IntDict$higherBitMask(branchingBit);
		var prefixBits = x & mask;
		return {branchingBit: branchingBit, prefixBits: prefixBits};
	});
var elm_community$intdict$IntDict$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var elm_community$intdict$IntDict$leaf = F2(
	function (k, v) {
		return elm_community$intdict$IntDict$Leaf(
			{key: k, value: v});
	});
var elm_community$intdict$IntDict$prefixMatches = F2(
	function (p, n) {
		return _Utils_eq(
			n & elm_community$intdict$IntDict$higherBitMask(p.branchingBit),
			p.prefixBits);
	});
var elm_community$intdict$IntDict$update = F3(
	function (key, alter, dict) {
		var join = F2(
			function (_n2, _n3) {
				var k1 = _n2.a;
				var l = _n2.b;
				var k2 = _n3.a;
				var r = _n3.b;
				var prefix = A2(elm_community$intdict$IntDict$lcp, k1, k2);
				return A2(elm_community$intdict$IntDict$isBranchingBitSet, prefix, k2) ? A3(elm_community$intdict$IntDict$inner, prefix, l, r) : A3(elm_community$intdict$IntDict$inner, prefix, r, l);
			});
		var alteredNode = function (mv) {
			var _n1 = alter(mv);
			if (_n1.$ === 'Just') {
				var v = _n1.a;
				return A2(elm_community$intdict$IntDict$leaf, key, v);
			} else {
				return elm_community$intdict$IntDict$empty;
			}
		};
		switch (dict.$) {
			case 'Empty':
				return alteredNode(elm$core$Maybe$Nothing);
			case 'Leaf':
				var l = dict.a;
				return _Utils_eq(l.key, key) ? alteredNode(
					elm$core$Maybe$Just(l.value)) : A2(
					join,
					_Utils_Tuple2(
						key,
						alteredNode(elm$core$Maybe$Nothing)),
					_Utils_Tuple2(l.key, dict));
			default:
				var i = dict.a;
				return A2(elm_community$intdict$IntDict$prefixMatches, i.prefix, key) ? (A2(elm_community$intdict$IntDict$isBranchingBitSet, i.prefix, key) ? A3(
					elm_community$intdict$IntDict$inner,
					i.prefix,
					i.left,
					A3(elm_community$intdict$IntDict$update, key, alter, i.right)) : A3(
					elm_community$intdict$IntDict$inner,
					i.prefix,
					A3(elm_community$intdict$IntDict$update, key, alter, i.left),
					i.right)) : A2(
					join,
					_Utils_Tuple2(
						key,
						alteredNode(elm$core$Maybe$Nothing)),
					_Utils_Tuple2(i.prefix.prefixBits, dict));
		}
	});
var elm_community$intdict$IntDict$insert = F3(
	function (key, value, dict) {
		return A3(
			elm_community$intdict$IntDict$update,
			key,
			elm$core$Basics$always(
				elm$core$Maybe$Just(value)),
			dict);
	});
var elm_community$intdict$IntDict$fromList = function (pairs) {
	return A3(
		elm$core$List$foldl,
		function (_n0) {
			var a = _n0.a;
			var b = _n0.b;
			return A2(elm_community$intdict$IntDict$insert, a, b);
		},
		elm_community$intdict$IntDict$empty,
		pairs);
};
var author$project$Activity$Activity$decodeStoredActivities = A2(
	zwilias$json_decode_exploration$Json$Decode$Exploration$map,
	elm_community$intdict$IntDict$fromList,
	zwilias$json_decode_exploration$Json$Decode$Exploration$list(
		A2(author$project$Porting$decodeTuple2, zwilias$json_decode_exploration$Json$Decode$Exploration$int, author$project$Activity$Activity$decodeCustomizations)));
var author$project$Activity$Activity$Switch = F2(
	function (a, b) {
		return {$: 'Switch', a: a, b: b};
	});
var author$project$Porting$subtype2 = F5(
	function (tagger, fieldName1, subType1Decoder, fieldName2, subType2Decoder) {
		return A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$map2,
			tagger,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName1, subType1Decoder),
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName2, subType2Decoder));
	});
var author$project$SmartTime$Moment$Moment = function (a) {
	return {$: 'Moment', a: a};
};
var author$project$SmartTime$Moment$fromSmartInt = function (_int) {
	return author$project$SmartTime$Moment$Moment(
		author$project$SmartTime$Duration$fromInt(_int));
};
var author$project$Task$TaskMoment$decodeMoment = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$SmartTime$Moment$fromSmartInt, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var author$project$Activity$Activity$decodeSwitch = A5(author$project$Porting$subtype2, author$project$Activity$Activity$Switch, 'Time', author$project$Task$TaskMoment$decodeMoment, 'Activity', author$project$ID$decode);
var author$project$AppData$AppData = F6(
	function (uid, errors, tasks, activities, timeline, todoist) {
		return {activities: activities, errors: errors, tasks: tasks, timeline: timeline, todoist: todoist, uid: uid};
	});
var author$project$Porting$decodeIntDict = function (valueDecoder) {
	return A2(
		zwilias$json_decode_exploration$Json$Decode$Exploration$map,
		elm_community$intdict$IntDict$fromList,
		zwilias$json_decode_exploration$Json$Decode$Exploration$list(
			A2(author$project$Porting$decodeTuple2, zwilias$json_decode_exploration$Json$Decode$Exploration$int, valueDecoder)));
};
var author$project$AppData$decodeTodoistCache = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'activityProjectIDs',
	author$project$Porting$decodeIntDict(author$project$ID$decode),
	A3(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'parentProjectID',
		zwilias$json_decode_exploration$Json$Decode$Exploration$int,
		A4(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			'syncToken',
			zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			'*',
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$AppData$TodoistCache))));
var author$project$Porting$decodeDuration = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$SmartTime$Duration$fromInt, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var author$project$Task$Progress$Percent = {$: 'Percent'};
var author$project$Task$Progress$progressFromFloat = function (_float) {
	return _Utils_Tuple2(
		elm$core$Basics$round(_float),
		author$project$Task$Progress$Percent);
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TNumber = {$: 'TNumber'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$float = zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		if (json.$ === 'Number') {
			var val = json.b;
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
				val);
		} else {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TNumber, json);
		}
	});
var author$project$Task$Progress$decodeProgress = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$Task$Progress$progressFromFloat, zwilias$json_decode_exploration$Json$Decode$Exploration$float);
var author$project$Task$Task$Task = function (title) {
	return function (completion) {
		return function (id) {
			return function (minEffort) {
				return function (predictedEffort) {
					return function (maxEffort) {
						return function (history) {
							return function (parent) {
								return function (tags) {
									return function (activity) {
										return function (deadline) {
											return function (plannedStart) {
												return function (plannedFinish) {
													return function (relevanceStarts) {
														return function (relevanceEnds) {
															return function (importance) {
																return {activity: activity, completion: completion, deadline: deadline, history: history, id: id, importance: importance, maxEffort: maxEffort, minEffort: minEffort, parent: parent, plannedFinish: plannedFinish, plannedStart: plannedStart, predictedEffort: predictedEffort, relevanceEnds: relevanceEnds, relevanceStarts: relevanceStarts, tags: tags, title: title};
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
var author$project$Task$Task$decodeHistoryEntry = zwilias$json_decode_exploration$Json$Decode$Exploration$fail('womp');
var author$project$Porting$subtype = F3(
	function (tagger, fieldName, subTypeDecoder) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$map,
			tagger,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName, subTypeDecoder));
	});
var author$project$Task$TaskMoment$LocalDate = function (a) {
	return {$: 'LocalDate', a: a};
};
var author$project$Task$TaskMoment$Localized = function (a) {
	return {$: 'Localized', a: a};
};
var author$project$Task$TaskMoment$Universal = function (a) {
	return {$: 'Universal', a: a};
};
var author$project$Task$TaskMoment$Unset = {$: 'Unset'};
var justinmimbs$date$Date$RD = function (a) {
	return {$: 'RD', a: a};
};
var justinmimbs$date$Date$fromRataDie = function (rd) {
	return justinmimbs$date$Date$RD(rd);
};
var author$project$Task$TaskMoment$decodeDate = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, justinmimbs$date$Date$fromRataDie, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var author$project$SmartTime$Moment$utcFromLinear = function (num) {
	return num;
};
var elm$time$Time$Posix = function (a) {
	return {$: 'Posix', a: a};
};
var elm$time$Time$millisToPosix = elm$time$Time$Posix;
var author$project$SmartTime$Moment$toElmTime = function (_n0) {
	var dur = _n0.a;
	return elm$time$Time$millisToPosix(
		author$project$SmartTime$Moment$utcFromLinear(
			author$project$SmartTime$Duration$inMs(dur)));
};
var elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 'Zone', a: a, b: b};
	});
var elm$time$Time$utc = A2(elm$time$Time$Zone, 0, _List_Nil);
var author$project$Task$TaskMoment$zoneless = elm$time$Time$utc;
var elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var elm$time$Time$flooredDiv = F2(
	function (numerator, denominator) {
		return elm$core$Basics$floor(numerator / denominator);
	});
var elm$time$Time$posixToMillis = function (_n0) {
	var millis = _n0.a;
	return millis;
};
var elm$time$Time$toAdjustedMinutesHelp = F3(
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
var elm$time$Time$toAdjustedMinutes = F2(
	function (_n0, time) {
		var defaultOffset = _n0.a;
		var eras = _n0.b;
		return A3(
			elm$time$Time$toAdjustedMinutesHelp,
			defaultOffset,
			A2(
				elm$time$Time$flooredDiv,
				elm$time$Time$posixToMillis(time),
				60000),
			eras);
	});
var elm$core$Basics$ge = _Utils_ge;
var elm$time$Time$toCivil = function (minutes) {
	var rawDay = A2(elm$time$Time$flooredDiv, minutes, 60 * 24) + 719468;
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
var elm$time$Time$toDay = F2(
	function (zone, time) {
		return elm$time$Time$toCivil(
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).day;
	});
var elm$core$Basics$modBy = _Basics_modBy;
var elm$time$Time$toHour = F2(
	function (zone, time) {
		return A2(
			elm$core$Basics$modBy,
			24,
			A2(
				elm$time$Time$flooredDiv,
				A2(elm$time$Time$toAdjustedMinutes, zone, time),
				60));
	});
var elm$time$Time$toMillis = F2(
	function (_n0, time) {
		return A2(
			elm$core$Basics$modBy,
			1000,
			elm$time$Time$posixToMillis(time));
	});
var elm$time$Time$toMinute = F2(
	function (zone, time) {
		return A2(
			elm$core$Basics$modBy,
			60,
			A2(elm$time$Time$toAdjustedMinutes, zone, time));
	});
var elm$time$Time$Apr = {$: 'Apr'};
var elm$time$Time$Aug = {$: 'Aug'};
var elm$time$Time$Dec = {$: 'Dec'};
var elm$time$Time$Feb = {$: 'Feb'};
var elm$time$Time$Jan = {$: 'Jan'};
var elm$time$Time$Jul = {$: 'Jul'};
var elm$time$Time$Jun = {$: 'Jun'};
var elm$time$Time$Mar = {$: 'Mar'};
var elm$time$Time$May = {$: 'May'};
var elm$time$Time$Nov = {$: 'Nov'};
var elm$time$Time$Oct = {$: 'Oct'};
var elm$time$Time$Sep = {$: 'Sep'};
var elm$time$Time$toMonth = F2(
	function (zone, time) {
		var _n0 = elm$time$Time$toCivil(
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).month;
		switch (_n0) {
			case 1:
				return elm$time$Time$Jan;
			case 2:
				return elm$time$Time$Feb;
			case 3:
				return elm$time$Time$Mar;
			case 4:
				return elm$time$Time$Apr;
			case 5:
				return elm$time$Time$May;
			case 6:
				return elm$time$Time$Jun;
			case 7:
				return elm$time$Time$Jul;
			case 8:
				return elm$time$Time$Aug;
			case 9:
				return elm$time$Time$Sep;
			case 10:
				return elm$time$Time$Oct;
			case 11:
				return elm$time$Time$Nov;
			default:
				return elm$time$Time$Dec;
		}
	});
var elm$time$Time$toSecond = F2(
	function (_n0, time) {
		return A2(
			elm$core$Basics$modBy,
			60,
			A2(
				elm$time$Time$flooredDiv,
				elm$time$Time$posixToMillis(time),
				1000));
	});
var elm$time$Time$toYear = F2(
	function (zone, time) {
		return elm$time$Time$toCivil(
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).year;
	});
var justinmimbs$time_extra$Time$Extra$posixToParts = F2(
	function (zone, posix) {
		return {
			day: A2(elm$time$Time$toDay, zone, posix),
			hour: A2(elm$time$Time$toHour, zone, posix),
			millisecond: A2(elm$time$Time$toMillis, zone, posix),
			minute: A2(elm$time$Time$toMinute, zone, posix),
			month: A2(elm$time$Time$toMonth, zone, posix),
			second: A2(elm$time$Time$toSecond, zone, posix),
			year: A2(elm$time$Time$toYear, zone, posix)
		};
	});
var author$project$Task$TaskMoment$decodeParts = A2(
	zwilias$json_decode_exploration$Json$Decode$Exploration$map,
	A2(
		elm$core$Basics$composeL,
		justinmimbs$time_extra$Time$Extra$posixToParts(author$project$Task$TaskMoment$zoneless),
		author$project$SmartTime$Moment$toElmTime),
	author$project$Task$TaskMoment$decodeMoment);
var author$project$Task$TaskMoment$decodeTaskMoment = author$project$Porting$decodeCustom(
	_List_fromArray(
		[
			_Utils_Tuple2(
			'Unset',
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(author$project$Task$TaskMoment$Unset)),
			_Utils_Tuple2(
			'LocalDate',
			A3(author$project$Porting$subtype, author$project$Task$TaskMoment$LocalDate, 'Date', author$project$Task$TaskMoment$decodeDate)),
			_Utils_Tuple2(
			'Localized',
			A3(author$project$Porting$subtype, author$project$Task$TaskMoment$Localized, 'Parts', author$project$Task$TaskMoment$decodeParts)),
			_Utils_Tuple2(
			'Universal',
			A3(author$project$Porting$subtype, author$project$Task$TaskMoment$Universal, 'Moment', author$project$Task$TaskMoment$decodeMoment))
		]));
var zwilias$json_decode_exploration$Json$Decode$Exploration$nullable = function (decoder) {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
		_List_fromArray(
			[
				zwilias$json_decode_exploration$Json$Decode$Exploration$null(elm$core$Maybe$Nothing),
				A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Maybe$Just, decoder)
			]));
};
var author$project$Task$Task$decodeTask = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'importance',
	zwilias$json_decode_exploration$Json$Decode$Exploration$int,
	A3(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'relevanceEnds',
		author$project$Task$TaskMoment$decodeTaskMoment,
		A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'relevanceStarts',
			author$project$Task$TaskMoment$decodeTaskMoment,
			A3(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'plannedFinish',
				author$project$Task$TaskMoment$decodeTaskMoment,
				A3(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'plannedStart',
					author$project$Task$TaskMoment$decodeTaskMoment,
					A3(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
						'deadline',
						author$project$Task$TaskMoment$decodeTaskMoment,
						A3(
							zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
							'activity',
							zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$ID$decode),
							A3(
								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
								'tags',
								zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
								A3(
									zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
									'parent',
									zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
									A3(
										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'history',
										zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Task$Task$decodeHistoryEntry),
										A3(
											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
											'maxEffort',
											author$project$Porting$decodeDuration,
											A3(
												zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'predictedEffort',
												author$project$Porting$decodeDuration,
												A3(
													zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'minEffort',
													author$project$Porting$decodeDuration,
													A3(
														zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
														'id',
														zwilias$json_decode_exploration$Json$Decode$Exploration$int,
														A3(
															zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
															'completion',
															author$project$Task$Progress$decodeProgress,
															A3(
																zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																'title',
																zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Task$Task$Task)))))))))))))))));
var author$project$AppData$decodeAppData = A4(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
	'todoist',
	author$project$AppData$decodeTodoistCache,
	author$project$AppData$emptyTodoistCache,
	A4(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
		'timeline',
		zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Activity$Activity$decodeSwitch),
		_List_Nil,
		A4(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			'activities',
			author$project$Activity$Activity$decodeStoredActivities,
			elm_community$intdict$IntDict$empty,
			A4(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
				'tasks',
				author$project$Porting$decodeIntDict(author$project$Task$Task$decodeTask),
				elm_community$intdict$IntDict$empty,
				A4(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
					'errors',
					zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$string),
					_List_Nil,
					A3(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
						'uid',
						zwilias$json_decode_exploration$Json$Decode$Exploration$int,
						zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$AppData$AppData)))))));
var elm$json$Json$Decode$decodeString = _Json_runOnString;
var elm$json$Json$Decode$value = _Json_decodeValue;
var zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson = {$: 'BadJson'};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Errors = function (a) {
	return {$: 'Errors', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Success = function (a) {
	return {$: 'Success', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$WithWarnings = F2(
	function (a, b) {
		return {$: 'WithWarnings', a: a, b: b};
	});
var elm$json$Json$Decode$decodeValue = _Json_run;
var elm$json$Json$Decode$bool = _Json_decodeBool;
var elm$json$Json$Decode$float = _Json_decodeFloat;
var elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
var elm$json$Json$Decode$andThen = _Json_andThen;
var elm$json$Json$Decode$succeed = _Json_succeed;
var elm$json$Json$Decode$lazy = function (thunk) {
	return A2(
		elm$json$Json$Decode$andThen,
		thunk,
		elm$json$Json$Decode$succeed(_Utils_Tuple0));
};
var elm$json$Json$Decode$list = _Json_decodeList;
var elm$json$Json$Decode$map = _Json_map1;
var elm$json$Json$Decode$null = _Json_decodeNull;
var elm$json$Json$Decode$oneOf = _Json_oneOf;
var elm$json$Json$Decode$string = _Json_decodeString;
function zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder() {
	return elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2(
				elm$json$Json$Decode$map,
				zwilias$json_decode_exploration$Json$Decode$Exploration$String(false),
				elm$json$Json$Decode$string),
				A2(
				elm$json$Json$Decode$map,
				zwilias$json_decode_exploration$Json$Decode$Exploration$Number(false),
				elm$json$Json$Decode$float),
				A2(
				elm$json$Json$Decode$map,
				zwilias$json_decode_exploration$Json$Decode$Exploration$Bool(false),
				elm$json$Json$Decode$bool),
				elm$json$Json$Decode$null(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Null(false)),
				A2(
				elm$json$Json$Decode$map,
				zwilias$json_decode_exploration$Json$Decode$Exploration$Array(false),
				elm$json$Json$Decode$list(
					elm$json$Json$Decode$lazy(
						function (_n0) {
							return zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder();
						}))),
				A2(
				elm$json$Json$Decode$map,
				zwilias$json_decode_exploration$Json$Decode$Exploration$Object(false),
				elm$json$Json$Decode$keyValuePairs(
					elm$json$Json$Decode$lazy(
						function (_n1) {
							return zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder();
						})))
			]));
}
try {
	var zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder = zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder();
	zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder = function () {
		return zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder;
	};
} catch ($) {
throw 'Some top-level definitions from `Json.Decode.Exploration` are causing infinite recursion:\n\n  ┌─────┐\n  │    annotatedDecoder\n  └─────┘\n\nThese errors are very tricky, so read https://elm-lang.org/0.19.0/halting-problem to learn how to fix it!';}
var zwilias$json_decode_exploration$Json$Decode$Exploration$decode = elm$json$Json$Decode$decodeValue(zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder);
var zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue = function (a) {
	return {$: 'UnusedValue', a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings = function (json) {
	_n0$8:
	while (true) {
		switch (json.$) {
			case 'String':
				if (!json.a) {
					return _List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _n0$8;
				}
			case 'Number':
				if (!json.a) {
					return _List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _n0$8;
				}
			case 'Bool':
				if (!json.a) {
					return _List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _n0$8;
				}
			case 'Null':
				if (!json.a) {
					return _List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					break _n0$8;
				}
			case 'Array':
				if (!json.a) {
					return _List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					var values = json.b;
					return elm$core$List$concat(
						A2(
							elm$core$List$indexedMap,
							F2(
								function (idx, val) {
									var _n1 = zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(val);
									if (!_n1.b) {
										return _List_Nil;
									} else {
										var x = _n1.a;
										var xs = _n1.b;
										return _List_fromArray(
											[
												A2(
												zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex,
												idx,
												A2(mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs))
											]);
									}
								}),
							values));
				}
			default:
				if (!json.a) {
					return _List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
							zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue(
								zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json)))
						]);
				} else {
					var kvPairs = json.b;
					return A2(
						elm$core$List$concatMap,
						function (_n2) {
							var key = _n2.a;
							var val = _n2.b;
							var _n3 = zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(val);
							if (!_n3.b) {
								return _List_Nil;
							} else {
								var x = _n3.a;
								var xs = _n3.b;
								return _List_fromArray(
									[
										A2(
										zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField,
										key,
										A2(mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs))
									]);
							}
						},
						kvPairs);
				}
		}
	}
	return _List_Nil;
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue = F2(
	function (_n0, val) {
		var decoderFn = _n0.a;
		var _n1 = zwilias$json_decode_exploration$Json$Decode$Exploration$decode(val);
		if (_n1.$ === 'Err') {
			return zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson;
		} else {
			var json = _n1.a;
			var _n2 = decoderFn(json);
			if (_n2.$ === 'Err') {
				var errors = _n2.a;
				return zwilias$json_decode_exploration$Json$Decode$Exploration$Errors(errors);
			} else {
				var acc = _n2.a;
				var _n3 = _Utils_ap(
					acc.warnings,
					zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(acc.json));
				if (!_n3.b) {
					return zwilias$json_decode_exploration$Json$Decode$Exploration$Success(acc.value);
				} else {
					var x = _n3.a;
					var xs = _n3.b;
					return A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$WithWarnings,
						A2(mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs),
						acc.value);
				}
			}
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$decodeString = F2(
	function (decoder, jsonString) {
		var _n0 = A2(elm$json$Json$Decode$decodeString, elm$json$Json$Decode$value, jsonString);
		if (_n0.$ === 'Err') {
			return zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson;
		} else {
			var json = _n0.a;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue, decoder, json);
		}
	});
var author$project$Main$appDataFromJson = function (incomingJson) {
	return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$decodeString, author$project$AppData$decodeAppData, incomingJson);
};
var author$project$SmartTime$Human$Moment$utc = elm$time$Time$utc;
var author$project$SmartTime$Duration$zero = author$project$SmartTime$Duration$Duration(0);
var author$project$SmartTime$Moment$zero = author$project$SmartTime$Moment$Moment(author$project$SmartTime$Duration$zero);
var author$project$Environment$preInit = function (maybeKey) {
	return {navkey: maybeKey, time: author$project$SmartTime$Moment$zero, timeZone: author$project$SmartTime$Human$Moment$utc};
};
var elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return elm$core$Maybe$Just(
				f(value));
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm$core$String$length = _String_length;
var elm$core$String$slice = _String_slice;
var elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			elm$core$String$slice,
			n,
			elm$core$String$length(string),
			string);
	});
var elm$core$String$startsWith = _String_startsWith;
var elm$url$Url$Http = {$: 'Http'};
var elm$url$Url$Https = {$: 'Https'};
var elm$core$String$indexes = _String_indexes;
var elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3(elm$core$String$slice, 0, n, string);
	});
var elm$core$String$contains = _String_contains;
var elm$core$String$toInt = _String_toInt;
var elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if (elm$core$String$isEmpty(str) || A2(elm$core$String$contains, '@', str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, ':', str);
			if (!_n0.b) {
				return elm$core$Maybe$Just(
					A6(elm$url$Url$Url, protocol, str, elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_n0.b.b) {
					var i = _n0.a;
					var _n1 = elm$core$String$toInt(
						A2(elm$core$String$dropLeft, i + 1, str));
					if (_n1.$ === 'Nothing') {
						return elm$core$Maybe$Nothing;
					} else {
						var port_ = _n1;
						return elm$core$Maybe$Just(
							A6(
								elm$url$Url$Url,
								protocol,
								A2(elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return elm$core$Maybe$Nothing;
				}
			}
		}
	});
var elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '/', str);
			if (!_n0.b) {
				return A5(elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _n0.a;
				return A5(
					elm$url$Url$chompBeforePath,
					protocol,
					A2(elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '?', str);
			if (!_n0.b) {
				return A4(elm$url$Url$chompBeforeQuery, protocol, elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _n0.a;
				return A4(
					elm$url$Url$chompBeforeQuery,
					protocol,
					elm$core$Maybe$Just(
						A2(elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '#', str);
			if (!_n0.b) {
				return A3(elm$url$Url$chompBeforeFragment, protocol, elm$core$Maybe$Nothing, str);
			} else {
				var i = _n0.a;
				return A3(
					elm$url$Url$chompBeforeFragment,
					protocol,
					elm$core$Maybe$Just(
						A2(elm$core$String$dropLeft, i + 1, str)),
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$fromString = function (str) {
	return A2(elm$core$String$startsWith, 'http://', str) ? A2(
		elm$url$Url$chompAfterProtocol,
		elm$url$Url$Http,
		A2(elm$core$String$dropLeft, 7, str)) : (A2(elm$core$String$startsWith, 'https://', str) ? A2(
		elm$url$Url$chompAfterProtocol,
		elm$url$Url$Https,
		A2(elm$core$String$dropLeft, 8, str)) : elm$core$Maybe$Nothing);
};
var elm$url$Url$addPort = F2(
	function (maybePort, starter) {
		if (maybePort.$ === 'Nothing') {
			return starter;
		} else {
			var port_ = maybePort.a;
			return starter + (':' + elm$core$String$fromInt(port_));
		}
	});
var elm$url$Url$addPrefixed = F3(
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
var elm$url$Url$toString = function (url) {
	var http = function () {
		var _n0 = url.protocol;
		if (_n0.$ === 'Http') {
			return 'http://';
		} else {
			return 'https://';
		}
	}();
	return A3(
		elm$url$Url$addPrefixed,
		'#',
		url.fragment,
		A3(
			elm$url$Url$addPrefixed,
			'?',
			url.query,
			_Utils_ap(
				A2(
					elm$url$Url$addPort,
					url.port_,
					_Utils_ap(http, url.host)),
				url.path)));
};
var author$project$Main$bypassFakeFragment = function (url) {
	var _n0 = A2(elm$core$Maybe$map, elm$core$String$uncons, url.fragment);
	if (((_n0.$ === 'Just') && (_n0.a.$ === 'Just')) && ('/' === _n0.a.a.a.valueOf())) {
		var _n1 = _n0.a.a;
		var fakeFragment = _n1.b;
		var _n2 = A2(
			elm$core$String$split,
			'#',
			elm$url$Url$toString(url));
		if (_n2.b) {
			var front = _n2.a;
			return A2(
				elm$core$Maybe$withDefault,
				url,
				elm$url$Url$fromString(front + ('/' + fakeFragment)));
		} else {
			return url;
		}
	} else {
		return url;
	}
};
var author$project$Main$TimeTracker = function (a) {
	return {$: 'TimeTracker', a: a};
};
var author$project$Main$ViewState = F2(
	function (primaryView, uid) {
		return {primaryView: primaryView, uid: uid};
	});
var author$project$TimeTracker$Normal = {$: 'Normal'};
var author$project$TimeTracker$defaultView = author$project$TimeTracker$Normal;
var author$project$Main$defaultView = A2(
	author$project$Main$ViewState,
	author$project$Main$TimeTracker(author$project$TimeTracker$defaultView),
	0);
var author$project$Main$TaskList = function (a) {
	return {$: 'TaskList', a: a};
};
var author$project$Main$screenToViewState = function (screen) {
	return {primaryView: screen, uid: 0};
};
var author$project$TaskList$IncompleteTasksOnly = {$: 'IncompleteTasksOnly'};
var author$project$TaskList$Normal = F3(
	function (a, b, c) {
		return {$: 'Normal', a: a, b: b, c: c};
	});
var elm$url$Url$Parser$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var elm$url$Url$Parser$State = F5(
	function (visited, unvisited, params, frag, value) {
		return {frag: frag, params: params, unvisited: unvisited, value: value, visited: visited};
	});
var elm$url$Url$Parser$mapState = F2(
	function (func, _n0) {
		var visited = _n0.visited;
		var unvisited = _n0.unvisited;
		var params = _n0.params;
		var frag = _n0.frag;
		var value = _n0.value;
		return A5(
			elm$url$Url$Parser$State,
			visited,
			unvisited,
			params,
			frag,
			func(value));
	});
var elm$url$Url$Parser$map = F2(
	function (subValue, _n0) {
		var parseArg = _n0.a;
		return elm$url$Url$Parser$Parser(
			function (_n1) {
				var visited = _n1.visited;
				var unvisited = _n1.unvisited;
				var params = _n1.params;
				var frag = _n1.frag;
				var value = _n1.value;
				return A2(
					elm$core$List$map,
					elm$url$Url$Parser$mapState(value),
					parseArg(
						A5(elm$url$Url$Parser$State, visited, unvisited, params, frag, subValue)));
			});
	});
var elm$url$Url$Parser$s = function (str) {
	return elm$url$Url$Parser$Parser(
		function (_n0) {
			var visited = _n0.visited;
			var unvisited = _n0.unvisited;
			var params = _n0.params;
			var frag = _n0.frag;
			var value = _n0.value;
			if (!unvisited.b) {
				return _List_Nil;
			} else {
				var next = unvisited.a;
				var rest = unvisited.b;
				return _Utils_eq(next, str) ? _List_fromArray(
					[
						A5(
						elm$url$Url$Parser$State,
						A2(elm$core$List$cons, next, visited),
						rest,
						params,
						frag,
						value)
					]) : _List_Nil;
			}
		});
};
var author$project$TaskList$routeView = A2(
	elm$url$Url$Parser$map,
	A3(
		author$project$TaskList$Normal,
		_List_fromArray(
			[author$project$TaskList$IncompleteTasksOnly]),
		elm$core$Maybe$Nothing,
		'Test'),
	elm$url$Url$Parser$s('tasks'));
var author$project$TimeTracker$routeView = A2(
	elm$url$Url$Parser$map,
	author$project$TimeTracker$Normal,
	elm$url$Url$Parser$s('timetracker'));
var elm$url$Url$Parser$oneOf = function (parsers) {
	return elm$url$Url$Parser$Parser(
		function (state) {
			return A2(
				elm$core$List$concatMap,
				function (_n0) {
					var parser = _n0.a;
					return parser(state);
				},
				parsers);
		});
};
var author$project$Main$routeParser = function () {
	var wrapScreen = function (parser) {
		return A2(elm$url$Url$Parser$map, author$project$Main$screenToViewState, parser);
	};
	return elm$url$Url$Parser$oneOf(
		_List_fromArray(
			[
				wrapScreen(
				A2(elm$url$Url$Parser$map, author$project$Main$TaskList, author$project$TaskList$routeView)),
				wrapScreen(
				A2(elm$url$Url$Parser$map, author$project$Main$TimeTracker, author$project$TimeTracker$routeView))
			]));
}();
var elm$url$Url$Parser$getFirstMatch = function (states) {
	getFirstMatch:
	while (true) {
		if (!states.b) {
			return elm$core$Maybe$Nothing;
		} else {
			var state = states.a;
			var rest = states.b;
			var _n1 = state.unvisited;
			if (!_n1.b) {
				return elm$core$Maybe$Just(state.value);
			} else {
				if ((_n1.a === '') && (!_n1.b.b)) {
					return elm$core$Maybe$Just(state.value);
				} else {
					var $temp$states = rest;
					states = $temp$states;
					continue getFirstMatch;
				}
			}
		}
	}
};
var elm$url$Url$Parser$removeFinalEmpty = function (segments) {
	if (!segments.b) {
		return _List_Nil;
	} else {
		if ((segments.a === '') && (!segments.b.b)) {
			return _List_Nil;
		} else {
			var segment = segments.a;
			var rest = segments.b;
			return A2(
				elm$core$List$cons,
				segment,
				elm$url$Url$Parser$removeFinalEmpty(rest));
		}
	}
};
var elm$url$Url$Parser$preparePath = function (path) {
	var _n0 = A2(elm$core$String$split, '/', path);
	if (_n0.b && (_n0.a === '')) {
		var segments = _n0.b;
		return elm$url$Url$Parser$removeFinalEmpty(segments);
	} else {
		var segments = _n0;
		return elm$url$Url$Parser$removeFinalEmpty(segments);
	}
};
var elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var elm$core$Dict$empty = elm$core$Dict$RBEmpty_elm_builtin;
var elm$core$Basics$compare = _Utils_compare;
var elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _n1 = A2(elm$core$Basics$compare, targetKey, key);
				switch (_n1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return elm$core$Maybe$Just(value);
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
var elm$core$Dict$Black = {$: 'Black'};
var elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var elm$core$Dict$Red = {$: 'Red'};
var elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _n1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _n3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Red,
					key,
					value,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _n5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _n6 = left.d;
				var _n7 = _n6.a;
				var llK = _n6.b;
				var llV = _n6.c;
				var llLeft = _n6.d;
				var llRight = _n6.e;
				var lRight = left.e;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Red,
					lK,
					lV,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5(elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, key, value, elm$core$Dict$RBEmpty_elm_builtin, elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _n1 = A2(elm$core$Basics$compare, key, nKey);
			switch (_n1.$) {
				case 'LT':
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3(elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5(elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3(elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _n0 = A3(elm$core$Dict$insertHelp, key, value, dict);
		if ((_n0.$ === 'RBNode_elm_builtin') && (_n0.a.$ === 'Red')) {
			var _n1 = _n0.a;
			var k = _n0.b;
			var v = _n0.c;
			var l = _n0.d;
			var r = _n0.e;
			return A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _n0;
			return x;
		}
	});
var elm$core$Dict$getMin = function (dict) {
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
var elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.e.d.$ === 'RBNode_elm_builtin') && (dict.e.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n1 = dict.d;
			var lClr = _n1.a;
			var lK = _n1.b;
			var lV = _n1.c;
			var lLeft = _n1.d;
			var lRight = _n1.e;
			var _n2 = dict.e;
			var rClr = _n2.a;
			var rK = _n2.b;
			var rV = _n2.c;
			var rLeft = _n2.d;
			var _n3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _n2.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				elm$core$Dict$Red,
				rlK,
				rlV,
				A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Black,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, lK, lV, lLeft, lRight),
					rlL),
				A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n4 = dict.d;
			var lClr = _n4.a;
			var lK = _n4.b;
			var lV = _n4.c;
			var lLeft = _n4.d;
			var lRight = _n4.e;
			var _n5 = dict.e;
			var rClr = _n5.a;
			var rK = _n5.b;
			var rV = _n5.c;
			var rLeft = _n5.d;
			var rRight = _n5.e;
			if (clr.$ === 'Black') {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Black,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Black,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.d.d.$ === 'RBNode_elm_builtin') && (dict.d.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n1 = dict.d;
			var lClr = _n1.a;
			var lK = _n1.b;
			var lV = _n1.c;
			var _n2 = _n1.d;
			var _n3 = _n2.a;
			var llK = _n2.b;
			var llV = _n2.c;
			var llLeft = _n2.d;
			var llRight = _n2.e;
			var lRight = _n1.e;
			var _n4 = dict.e;
			var rClr = _n4.a;
			var rK = _n4.b;
			var rV = _n4.c;
			var rLeft = _n4.d;
			var rRight = _n4.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				elm$core$Dict$Red,
				lK,
				lV,
				A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, llK, llV, llLeft, llRight),
				A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Black,
					k,
					v,
					lRight,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n5 = dict.d;
			var lClr = _n5.a;
			var lK = _n5.b;
			var lV = _n5.c;
			var lLeft = _n5.d;
			var lRight = _n5.e;
			var _n6 = dict.e;
			var rClr = _n6.a;
			var rK = _n6.b;
			var rV = _n6.c;
			var rLeft = _n6.d;
			var rRight = _n6.e;
			if (clr.$ === 'Black') {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Black,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					elm$core$Dict$Black,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
			var _n1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Red, key, value, lRight, right));
		} else {
			_n2$2:
			while (true) {
				if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Black')) {
					if (right.d.$ === 'RBNode_elm_builtin') {
						if (right.d.a.$ === 'Black') {
							var _n3 = right.a;
							var _n4 = right.d;
							var _n5 = _n4.a;
							return elm$core$Dict$moveRedRight(dict);
						} else {
							break _n2$2;
						}
					} else {
						var _n6 = right.a;
						var _n7 = right.d;
						return elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _n2$2;
				}
			}
			return dict;
		}
	});
var elm$core$Dict$removeMin = function (dict) {
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
				var _n3 = lLeft.a;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					elm$core$Dict$removeMin(left),
					right);
			} else {
				var _n4 = elm$core$Dict$moveRedLeft(dict);
				if (_n4.$ === 'RBNode_elm_builtin') {
					var nColor = _n4.a;
					var nKey = _n4.b;
					var nValue = _n4.c;
					var nLeft = _n4.d;
					var nRight = _n4.e;
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Black')) {
					var _n4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
						var _n6 = lLeft.a;
						return A5(
							elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2(elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _n7 = elm$core$Dict$moveRedLeft(dict);
						if (_n7.$ === 'RBNode_elm_builtin') {
							var nColor = _n7.a;
							var nKey = _n7.b;
							var nValue = _n7.c;
							var nLeft = _n7.d;
							var nRight = _n7.e;
							return A5(
								elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2(elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2(elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7(elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBNode_elm_builtin') {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _n1 = elm$core$Dict$getMin(right);
				if (_n1.$ === 'RBNode_elm_builtin') {
					var minKey = _n1.b;
					var minValue = _n1.c;
					return A5(
						elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						elm$core$Dict$removeMin(right));
				} else {
					return elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2(elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var elm$core$Dict$remove = F2(
	function (key, dict) {
		var _n0 = A2(elm$core$Dict$removeHelp, key, dict);
		if ((_n0.$ === 'RBNode_elm_builtin') && (_n0.a.$ === 'Red')) {
			var _n1 = _n0.a;
			var k = _n0.b;
			var v = _n0.c;
			var l = _n0.d;
			var r = _n0.e;
			return A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _n0;
			return x;
		}
	});
var elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _n0 = alter(
			A2(elm$core$Dict$get, targetKey, dictionary));
		if (_n0.$ === 'Just') {
			var value = _n0.a;
			return A3(elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2(elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var elm$url$Url$percentDecode = _Url_percentDecode;
var elm$url$Url$Parser$addToParametersHelp = F2(
	function (value, maybeList) {
		if (maybeList.$ === 'Nothing') {
			return elm$core$Maybe$Just(
				_List_fromArray(
					[value]));
		} else {
			var list = maybeList.a;
			return elm$core$Maybe$Just(
				A2(elm$core$List$cons, value, list));
		}
	});
var elm$url$Url$Parser$addParam = F2(
	function (segment, dict) {
		var _n0 = A2(elm$core$String$split, '=', segment);
		if ((_n0.b && _n0.b.b) && (!_n0.b.b.b)) {
			var rawKey = _n0.a;
			var _n1 = _n0.b;
			var rawValue = _n1.a;
			var _n2 = elm$url$Url$percentDecode(rawKey);
			if (_n2.$ === 'Nothing') {
				return dict;
			} else {
				var key = _n2.a;
				var _n3 = elm$url$Url$percentDecode(rawValue);
				if (_n3.$ === 'Nothing') {
					return dict;
				} else {
					var value = _n3.a;
					return A3(
						elm$core$Dict$update,
						key,
						elm$url$Url$Parser$addToParametersHelp(value),
						dict);
				}
			}
		} else {
			return dict;
		}
	});
var elm$url$Url$Parser$prepareQuery = function (maybeQuery) {
	if (maybeQuery.$ === 'Nothing') {
		return elm$core$Dict$empty;
	} else {
		var qry = maybeQuery.a;
		return A3(
			elm$core$List$foldr,
			elm$url$Url$Parser$addParam,
			elm$core$Dict$empty,
			A2(elm$core$String$split, '&', qry));
	}
};
var elm$url$Url$Parser$parse = F2(
	function (_n0, url) {
		var parser = _n0.a;
		return elm$url$Url$Parser$getFirstMatch(
			parser(
				A5(
					elm$url$Url$Parser$State,
					_List_Nil,
					elm$url$Url$Parser$preparePath(url.path),
					elm$url$Url$Parser$prepareQuery(url.query),
					url.fragment,
					elm$core$Basics$identity)));
	});
var author$project$Main$viewUrl = function (url) {
	var finalUrl = author$project$Main$bypassFakeFragment(url);
	return A2(
		elm$core$Maybe$withDefault,
		author$project$Main$defaultView,
		A2(elm$url$Url$Parser$parse, author$project$Main$routeParser, finalUrl));
};
var author$project$Main$buildModel = F3(
	function (appData, url, maybeKey) {
		return {
			appData: appData,
			environment: author$project$Environment$preInit(maybeKey),
			viewState: author$project$Main$viewUrl(url)
		};
	});
var author$project$Main$Tick = function (a) {
	return {$: 'Tick', a: a};
};
var author$project$Main$Tock = F2(
	function (a, b) {
		return {$: 'Tock', a: a, b: b};
	});
var author$project$Activity$Activity$encodeCategory = function (v) {
	switch (v.$) {
		case 'Transit':
			return elm$json$Json$Encode$string('Transit');
		case 'Entertainment':
			return elm$json$Json$Encode$string('Entertainment');
		case 'Hygiene':
			return elm$json$Json$Encode$string('Hygiene');
		case 'Slacking':
			return elm$json$Json$Encode$string('Slacking');
		default:
			return elm$json$Json$Encode$string('Communication');
	}
};
var author$project$SmartTime$Duration$aDay = author$project$SmartTime$Duration$Duration(author$project$SmartTime$Duration$dayLength);
var author$project$SmartTime$Duration$aMillisecond = author$project$SmartTime$Duration$Duration(author$project$SmartTime$Duration$millisecondLength);
var author$project$SmartTime$Duration$aMinute = author$project$SmartTime$Duration$Duration(author$project$SmartTime$Duration$minuteLength);
var author$project$SmartTime$Duration$aSecond = author$project$SmartTime$Duration$Duration(author$project$SmartTime$Duration$secondLength);
var author$project$SmartTime$Duration$anHour = author$project$SmartTime$Duration$Duration(author$project$SmartTime$Duration$hourLength);
var author$project$SmartTime$Duration$scale = F2(
	function (_n0, scalar) {
		var dur = _n0.a;
		return author$project$SmartTime$Duration$Duration(
			elm$core$Basics$round(dur * scalar));
	});
var author$project$SmartTime$Human$Duration$toDuration = function (humanDuration) {
	switch (humanDuration.$) {
		case 'Days':
			var days = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aDay, days);
		case 'Hours':
			var hours = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$anHour, hours);
		case 'Minutes':
			var minutes = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aMinute, minutes);
		case 'Seconds':
			var seconds = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aSecond, seconds);
		default:
			var milliseconds = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aMillisecond, milliseconds);
	}
};
var author$project$SmartTime$Human$Duration$dur = author$project$SmartTime$Human$Duration$toDuration;
var elm$json$Json$Encode$int = _Json_wrap;
var author$project$Activity$Activity$encodeHumanDuration = function (humanDuration) {
	return elm$json$Json$Encode$int(
		author$project$SmartTime$Duration$inMs(
			author$project$SmartTime$Human$Duration$dur(humanDuration)));
};
var author$project$Porting$homogeneousTuple2AsArray = F2(
	function (encoder, _n0) {
		var a = _n0.a;
		var b = _n0.b;
		return A2(
			elm$json$Json$Encode$list,
			encoder,
			_List_fromArray(
				[a, b]));
	});
var author$project$Activity$Activity$encodeDurationPerPeriod = function (tuple) {
	return A2(author$project$Porting$homogeneousTuple2AsArray, author$project$Activity$Activity$encodeHumanDuration, tuple);
};
var author$project$Activity$Activity$encodeEvidence = function (v) {
	return elm$json$Json$Encode$string('Evidence');
};
var author$project$Activity$Activity$encodeExcusable = function (v) {
	switch (v.$) {
		case 'NeverExcused':
			return elm$json$Json$Encode$string('NeverExcused');
		case 'TemporarilyExcused':
			var dpp = v.a;
			return elm$json$Json$Encode$string('TemporarilyExcused');
		default:
			return elm$json$Json$Encode$string('IndefinitelyExcused');
	}
};
var author$project$Activity$Activity$encodeIcon = function (v) {
	switch (v.$) {
		case 'File':
			var path = v.a;
			return elm$json$Json$Encode$string('File');
		case 'Ion':
			return elm$json$Json$Encode$string('Ion');
		default:
			return elm$json$Json$Encode$string('Other');
	}
};
var author$project$Activity$Template$encodeTemplate = function (v) {
	switch (v.$) {
		case 'DillyDally':
			return elm$json$Json$Encode$string('DillyDally');
		case 'Apparel':
			return elm$json$Json$Encode$string('Apparel');
		case 'Messaging':
			return elm$json$Json$Encode$string('Messaging');
		case 'Restroom':
			return elm$json$Json$Encode$string('Restroom');
		case 'Grooming':
			return elm$json$Json$Encode$string('Grooming');
		case 'Meal':
			return elm$json$Json$Encode$string('Meal');
		case 'Supplements':
			return elm$json$Json$Encode$string('Supplements');
		case 'Workout':
			return elm$json$Json$Encode$string('Workout');
		case 'Shower':
			return elm$json$Json$Encode$string('Shower');
		case 'Toothbrush':
			return elm$json$Json$Encode$string('Toothbrush');
		case 'Floss':
			return elm$json$Json$Encode$string('Floss');
		case 'Wakeup':
			return elm$json$Json$Encode$string('Wakeup');
		case 'Sleep':
			return elm$json$Json$Encode$string('Sleep');
		case 'Plan':
			return elm$json$Json$Encode$string('Plan');
		case 'Configure':
			return elm$json$Json$Encode$string('Configure');
		case 'Email':
			return elm$json$Json$Encode$string('Email');
		case 'Work':
			return elm$json$Json$Encode$string('Work');
		case 'Call':
			return elm$json$Json$Encode$string('Call');
		case 'Chores':
			return elm$json$Json$Encode$string('Chores');
		case 'Parents':
			return elm$json$Json$Encode$string('Parents');
		case 'Prepare':
			return elm$json$Json$Encode$string('Prepare');
		case 'Lover':
			return elm$json$Json$Encode$string('Lover');
		case 'Driving':
			return elm$json$Json$Encode$string('Driving');
		case 'Riding':
			return elm$json$Json$Encode$string('Riding');
		case 'SocialMedia':
			return elm$json$Json$Encode$string('SocialMedia');
		case 'Pacing':
			return elm$json$Json$Encode$string('Pacing');
		case 'Sport':
			return elm$json$Json$Encode$string('Sport');
		case 'Finance':
			return elm$json$Json$Encode$string('Finance');
		case 'Laundry':
			return elm$json$Json$Encode$string('Laundry');
		case 'Bedward':
			return elm$json$Json$Encode$string('Bedward');
		case 'Browse':
			return elm$json$Json$Encode$string('Browse');
		case 'Fiction':
			return elm$json$Json$Encode$string('Fiction');
		case 'Learning':
			return elm$json$Json$Encode$string('Learning');
		case 'BrainTrain':
			return elm$json$Json$Encode$string('BrainTrain');
		case 'Music':
			return elm$json$Json$Encode$string('Music');
		case 'Create':
			return elm$json$Json$Encode$string('Create');
		case 'Children':
			return elm$json$Json$Encode$string('Children');
		case 'Meeting':
			return elm$json$Json$Encode$string('Meeting');
		case 'Cinema':
			return elm$json$Json$Encode$string('Cinema');
		case 'FilmWatching':
			return elm$json$Json$Encode$string('FilmWatching');
		case 'Series':
			return elm$json$Json$Encode$string('Series');
		case 'Broadcast':
			return elm$json$Json$Encode$string('Broadcast');
		case 'Theatre':
			return elm$json$Json$Encode$string('Theatre');
		case 'Shopping':
			return elm$json$Json$Encode$string('Shopping');
		case 'VideoGaming':
			return elm$json$Json$Encode$string('VideoGaming');
		case 'Housekeeping':
			return elm$json$Json$Encode$string('Housekeeping');
		case 'MealPrep':
			return elm$json$Json$Encode$string('MealPrep');
		case 'Networking':
			return elm$json$Json$Encode$string('Networking');
		case 'Meditate':
			return elm$json$Json$Encode$string('Meditate');
		case 'Homework':
			return elm$json$Json$Encode$string('Homework');
		case 'Flight':
			return elm$json$Json$Encode$string('Flight');
		case 'Course':
			return elm$json$Json$Encode$string('Course');
		case 'Pet':
			return elm$json$Json$Encode$string('Pet');
		case 'Presentation':
			return elm$json$Json$Encode$string('Presentation');
		default:
			return elm$json$Json$Encode$string('Projects');
	}
};
var author$project$ID$encode = function (_n0) {
	var _int = _n0.a;
	return elm$json$Json$Encode$int(_int);
};
var author$project$Porting$normal = elm$core$Maybe$Just;
var elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _n0 = f(mx);
		if (_n0.$ === 'Just') {
			var x = _n0.a;
			return A2(elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			elm$core$List$foldr,
			elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var author$project$Porting$omitNothings = elm$core$List$filterMap(elm$core$Basics$identity);
var author$project$Porting$omittable = function (_n0) {
	var name = _n0.a;
	var encoder = _n0.b;
	var fieldToCheck = _n0.c;
	return A2(
		elm$core$Maybe$map,
		function (field) {
			return _Utils_Tuple2(
				name,
				encoder(field));
		},
		fieldToCheck);
};
var author$project$Activity$Activity$encodeCustomizations = function (record) {
	return elm$json$Json$Encode$object(
		author$project$Porting$omitNothings(
			_List_fromArray(
				[
					author$project$Porting$normal(
					_Utils_Tuple2(
						'template',
						author$project$Activity$Template$encodeTemplate(record.template))),
					author$project$Porting$normal(
					_Utils_Tuple2(
						'stock',
						author$project$ID$encode(record.id))),
					author$project$Porting$omittable(
					_Utils_Tuple3(
						'names',
						elm$json$Json$Encode$list(elm$json$Json$Encode$string),
						record.names)),
					author$project$Porting$omittable(
					_Utils_Tuple3('icon', author$project$Activity$Activity$encodeIcon, record.icon)),
					author$project$Porting$omittable(
					_Utils_Tuple3('excusable', author$project$Activity$Activity$encodeExcusable, record.excusable)),
					author$project$Porting$omittable(
					_Utils_Tuple3('taskOptional', elm$json$Json$Encode$bool, record.taskOptional)),
					author$project$Porting$omittable(
					_Utils_Tuple3(
						'evidence',
						elm$json$Json$Encode$list(author$project$Activity$Activity$encodeEvidence),
						record.evidence)),
					author$project$Porting$omittable(
					_Utils_Tuple3('category', author$project$Activity$Activity$encodeCategory, record.category)),
					author$project$Porting$omittable(
					_Utils_Tuple3('backgroundable', elm$json$Json$Encode$bool, record.backgroundable)),
					author$project$Porting$omittable(
					_Utils_Tuple3('maxTime', author$project$Activity$Activity$encodeDurationPerPeriod, record.maxTime)),
					author$project$Porting$omittable(
					_Utils_Tuple3('hidden', elm$json$Json$Encode$bool, record.hidden))
				])));
};
var author$project$Porting$encodeTuple2 = F3(
	function (firstEncoder, secondEncoder, _n0) {
		var first = _n0.a;
		var second = _n0.b;
		return A2(
			elm$json$Json$Encode$list,
			elm$core$Basics$identity,
			_List_fromArray(
				[
					firstEncoder(first),
					secondEncoder(second)
				]));
	});
var elm_community$intdict$IntDict$foldr = F3(
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
						$temp$acc = A3(elm_community$intdict$IntDict$foldr, f, acc, i.right),
						$temp$dict = i.left;
					f = $temp$f;
					acc = $temp$acc;
					dict = $temp$dict;
					continue foldr;
			}
		}
	});
var elm_community$intdict$IntDict$toList = function (dict) {
	return A3(
		elm_community$intdict$IntDict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var author$project$Activity$Activity$encodeStoredActivities = function (value) {
	return A2(
		elm$json$Json$Encode$list,
		A2(author$project$Porting$encodeTuple2, elm$json$Json$Encode$int, author$project$Activity$Activity$encodeCustomizations),
		elm_community$intdict$IntDict$toList(value));
};
var author$project$SmartTime$Moment$toSmartInt = function (_n0) {
	var dur = _n0.a;
	return author$project$SmartTime$Duration$inMs(dur);
};
var author$project$Task$TaskMoment$encodeMoment = function (moment) {
	return elm$json$Json$Encode$int(
		author$project$SmartTime$Moment$toSmartInt(moment));
};
var author$project$Activity$Activity$encodeSwitch = function (_n0) {
	var time = _n0.a;
	var activityId = _n0.b;
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'Time',
				author$project$Task$TaskMoment$encodeMoment(time)),
				_Utils_Tuple2(
				'Activity',
				author$project$ID$encode(activityId))
			]));
};
var author$project$Porting$encodeIntDict = F2(
	function (valueEncoder, dict) {
		return A2(
			elm$json$Json$Encode$list,
			A2(author$project$Porting$encodeTuple2, elm$json$Json$Encode$int, valueEncoder),
			elm_community$intdict$IntDict$toList(dict));
	});
var author$project$AppData$encodeTodoistCache = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'syncToken',
				elm$json$Json$Encode$string(record.syncToken)),
				_Utils_Tuple2(
				'parentProjectID',
				elm$json$Json$Encode$int(record.parentProjectID)),
				_Utils_Tuple2(
				'activityProjectIDs',
				A2(author$project$Porting$encodeIntDict, author$project$ID$encode, record.activityProjectIDs))
			]));
};
var author$project$Porting$encodeDuration = function (dur) {
	return elm$json$Json$Encode$int(
		author$project$SmartTime$Duration$inMs(dur));
};
var author$project$Task$Progress$getPortion = function (_n0) {
	var part = _n0.a;
	return part;
};
var author$project$Task$Progress$encodeProgress = function (progress) {
	return elm$json$Json$Encode$int(
		author$project$Task$Progress$getPortion(progress));
};
var author$project$Task$Task$encodeHistoryEntry = function (record) {
	return elm$json$Json$Encode$object(_List_Nil);
};
var author$project$Task$TaskMoment$encodeTaskMoment = function (v) {
	switch (v.$) {
		case 'Unset':
			return elm$json$Json$Encode$string('Unset');
		case 'LocalDate':
			var date = v.a;
			return elm$json$Json$Encode$string('LocalDate');
		case 'Localized':
			var parts = v.a;
			return elm$json$Json$Encode$string('Localized');
		default:
			var moment = v.a;
			return elm$json$Json$Encode$string('Universal');
	}
};
var elm_community$json_extra$Json$Encode$Extra$maybe = function (encoder) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Maybe$map(encoder),
		elm$core$Maybe$withDefault(elm$json$Json$Encode$null));
};
var author$project$Task$Task$encodeTask = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				elm$json$Json$Encode$string(record.title)),
				_Utils_Tuple2(
				'completion',
				author$project$Task$Progress$encodeProgress(record.completion)),
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$int(record.id)),
				_Utils_Tuple2(
				'minEffort',
				author$project$Porting$encodeDuration(record.predictedEffort)),
				_Utils_Tuple2(
				'predictedEffort',
				author$project$Porting$encodeDuration(record.predictedEffort)),
				_Utils_Tuple2(
				'maxEffort',
				author$project$Porting$encodeDuration(record.predictedEffort)),
				_Utils_Tuple2(
				'history',
				A2(elm$json$Json$Encode$list, author$project$Task$Task$encodeHistoryEntry, record.history)),
				_Utils_Tuple2(
				'parent',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$int, record.parent)),
				_Utils_Tuple2(
				'tags',
				A2(elm$json$Json$Encode$list, elm$json$Json$Encode$int, record.tags)),
				_Utils_Tuple2(
				'activity',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$ID$encode, record.activity)),
				_Utils_Tuple2(
				'deadline',
				author$project$Task$TaskMoment$encodeTaskMoment(record.deadline)),
				_Utils_Tuple2(
				'plannedStart',
				author$project$Task$TaskMoment$encodeTaskMoment(record.plannedStart)),
				_Utils_Tuple2(
				'plannedFinish',
				author$project$Task$TaskMoment$encodeTaskMoment(record.plannedFinish)),
				_Utils_Tuple2(
				'relevanceStarts',
				author$project$Task$TaskMoment$encodeTaskMoment(record.relevanceStarts)),
				_Utils_Tuple2(
				'relevanceEnds',
				author$project$Task$TaskMoment$encodeTaskMoment(record.relevanceEnds)),
				_Utils_Tuple2(
				'importance',
				elm$json$Json$Encode$int(record.id))
			]));
};
var elm$core$List$takeReverse = F3(
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
						$temp$kept = A2(elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var elm$core$List$takeTailRec = F2(
	function (n, list) {
		return elm$core$List$reverse(
			A3(elm$core$List$takeReverse, n, list, _List_Nil));
	});
var elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _n0 = _Utils_Tuple2(n, list);
			_n0$1:
			while (true) {
				_n0$5:
				while (true) {
					if (!_n0.b.b) {
						return list;
					} else {
						if (_n0.b.b.b) {
							switch (_n0.a) {
								case 1:
									break _n0$1;
								case 2:
									var _n2 = _n0.b;
									var x = _n2.a;
									var _n3 = _n2.b;
									var y = _n3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_n0.b.b.b.b) {
										var _n4 = _n0.b;
										var x = _n4.a;
										var _n5 = _n4.b;
										var y = _n5.a;
										var _n6 = _n5.b;
										var z = _n6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _n0$5;
									}
								default:
									if (_n0.b.b.b.b && _n0.b.b.b.b.b) {
										var _n7 = _n0.b;
										var x = _n7.a;
										var _n8 = _n7.b;
										var y = _n8.a;
										var _n9 = _n8.b;
										var z = _n9.a;
										var _n10 = _n9.b;
										var w = _n10.a;
										var tl = _n10.b;
										return (ctr > 1000) ? A2(
											elm$core$List$cons,
											x,
											A2(
												elm$core$List$cons,
												y,
												A2(
													elm$core$List$cons,
													z,
													A2(
														elm$core$List$cons,
														w,
														A2(elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											elm$core$List$cons,
											x,
											A2(
												elm$core$List$cons,
												y,
												A2(
													elm$core$List$cons,
													z,
													A2(
														elm$core$List$cons,
														w,
														A3(elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _n0$5;
									}
							}
						} else {
							if (_n0.a === 1) {
								break _n0$1;
							} else {
								break _n0$5;
							}
						}
					}
				}
				return list;
			}
			var _n1 = _n0.b;
			var x = _n1.a;
			return _List_fromArray(
				[x]);
		}
	});
var elm$core$List$take = F2(
	function (n, list) {
		return A3(elm$core$List$takeFast, 0, n, list);
	});
var author$project$AppData$encodeAppData = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'tasks',
				A2(author$project$Porting$encodeIntDict, author$project$Task$Task$encodeTask, record.tasks)),
				_Utils_Tuple2(
				'activities',
				author$project$Activity$Activity$encodeStoredActivities(record.activities)),
				_Utils_Tuple2(
				'uid',
				elm$json$Json$Encode$int(record.uid)),
				_Utils_Tuple2(
				'errors',
				A2(
					elm$json$Json$Encode$list,
					elm$json$Json$Encode$string,
					A2(elm$core$List$take, 100, record.errors))),
				_Utils_Tuple2(
				'timeline',
				A2(elm$json$Json$Encode$list, author$project$Activity$Activity$encodeSwitch, record.timeline)),
				_Utils_Tuple2(
				'todoist',
				author$project$AppData$encodeTodoistCache(record.todoist))
			]));
};
var author$project$Main$appDataToJson = function (appData) {
	return A2(
		elm$json$Json$Encode$encode,
		0,
		author$project$AppData$encodeAppData(appData));
};
var author$project$Main$setStorage = _Platform_outgoingPort('setStorage', elm$json$Json$Encode$string);
var author$project$External$Tasker$flash = _Platform_outgoingPort('flash', elm$json$Json$Encode$string);
var author$project$External$Commands$toast = function (message) {
	return author$project$External$Tasker$flash(message);
};
var author$project$Activity$Activity$defaults = function (startWith) {
	switch (startWith.$) {
		case 'DillyDally':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('shrugging-attempt.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(0),
					author$project$SmartTime$Human$Duration$Hours(1)),
				names: _List_fromArray(
					['Nothing', 'Dilly-dally', 'Distracted']),
				taskOptional: true,
				template: startWith
			};
		case 'Apparel':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Hygiene,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(3))),
				hidden: false,
				icon: author$project$Activity$Activity$File('shirt.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Appareling', 'Dressing', 'Getting Dressed', 'Dressing Up']),
				taskOptional: true,
				template: startWith
			};
		case 'Messaging':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Communication,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(5),
						author$project$SmartTime$Human$Duration$Minutes(30))),
				hidden: false,
				icon: author$project$Activity$Activity$File('messaging.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Hours(5)),
				names: _List_fromArray(
					['Messaging', 'Texting', 'Chatting', 'Text Messaging']),
				taskOptional: true,
				template: startWith
			};
		case 'Restroom':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(15),
						author$project$SmartTime$Human$Duration$Hours(2))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(20),
					author$project$SmartTime$Human$Duration$Hours(2)),
				names: _List_fromArray(
					['Restroom', 'Toilet', 'WC', 'Washroom', 'Latrine', 'Lavatory', 'Water Closet']),
				taskOptional: true,
				template: startWith
			};
		case 'Grooming':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Grooming', 'Tending', 'Groom']),
				taskOptional: true,
				template: startWith
			};
		case 'Meal':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(3))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meal', 'Eating', 'Food', 'Lunch', 'Dinner', 'Breakfast']),
				taskOptional: true,
				template: startWith
			};
		case 'Supplements':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Supplements', 'Pills', 'Medication']),
				taskOptional: true,
				template: startWith
			};
		case 'Workout':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(3))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Workout', 'Working Out', 'Work Out']),
				taskOptional: true,
				template: startWith
			};
		case 'Shower':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(20),
						author$project$SmartTime$Human$Duration$Hours(18))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Shower', 'Bathing', 'Showering']),
				taskOptional: true,
				template: startWith
			};
		case 'Toothbrush':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Toothbrush', 'Teeth', 'Brushing Teeth', 'Teethbrushing']),
				taskOptional: true,
				template: startWith
			};
		case 'Floss':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Floss', 'Flossing']),
				taskOptional: true,
				template: startWith
			};
		case 'Wakeup':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(12),
						author$project$SmartTime$Human$Duration$Hours(15))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Wakeup', 'Waking Up', 'Wakeup Walk']),
				taskOptional: true,
				template: startWith
			};
		case 'Sleep':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$IndefinitelyExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Sleep', 'Sleeping']),
				taskOptional: true,
				template: startWith
			};
		case 'Plan':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(15),
						author$project$SmartTime$Human$Duration$Hours(2))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Plan', 'Planning', 'Plans']),
				taskOptional: true,
				template: startWith
			};
		case 'Configure':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Hours(5))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Configure', 'Configuring', 'Configuration']),
				taskOptional: true,
				template: startWith
			};
		case 'Email':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(2))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Email', 'E-Mail', 'E-mail', 'Emailing', 'E-mails', 'Emails', 'E-mailing']),
				taskOptional: true,
				template: startWith
			};
		case 'Work':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(12))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(8),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Work', 'Working', 'Listings Work']),
				taskOptional: true,
				template: startWith
			};
		case 'Call':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(4))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Call', 'Calling', 'Phone Call', 'Phone', 'Phone Calls', 'Calling', 'Voice Call', 'Voice Chat', 'Video Call']),
				taskOptional: true,
				template: startWith
			};
		case 'Chores':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Chore', 'Chores']),
				taskOptional: true,
				template: startWith
			};
		case 'Parents':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(12))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Parents', 'Parent']),
				taskOptional: true,
				template: startWith
			};
		case 'Prepare':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(30),
					author$project$SmartTime$Human$Duration$Hours(24)),
				names: _List_fromArray(
					['Prepare', 'Preparing', 'Preparation']),
				taskOptional: true,
				template: startWith
			};
		case 'Lover':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(2),
						author$project$SmartTime$Human$Duration$Hours(8))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Lover', 'S.O.', 'Partner']),
				taskOptional: true,
				template: startWith
			};
		case 'Driving':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Transit,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(6))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Driving', 'Drive']),
				taskOptional: true,
				template: startWith
			};
		case 'Riding':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Hours(8))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(30),
					author$project$SmartTime$Human$Duration$Hours(5)),
				names: _List_fromArray(
					['Riding', 'Ride', 'Passenger']),
				taskOptional: true,
				template: startWith
			};
		case 'SocialMedia':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(4))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Social Media']),
				taskOptional: true,
				template: startWith
			};
		case 'Pacing':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Pacing', 'Pace']),
				taskOptional: true,
				template: startWith
			};
		case 'Sport':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Sport', 'Sports', 'Playing Sports']),
				taskOptional: true,
				template: startWith
			};
		case 'Finance':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Finance', 'Financial']),
				taskOptional: true,
				template: startWith
			};
		case 'Laundry':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Laundry']),
				taskOptional: true,
				template: startWith
			};
		case 'Bedward':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Bedward', 'Bedward-bound', 'Going to Bed']),
				taskOptional: true,
				template: startWith
			};
		case 'Browse':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Browse', 'Browsing']),
				taskOptional: true,
				template: startWith
			};
		case 'Fiction':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Fiction', 'Reading Fiction']),
				taskOptional: true,
				template: startWith
			};
		case 'Learning':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Learn', 'Learning']),
				taskOptional: true,
				template: startWith
			};
		case 'BrainTrain':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Days(1))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Brain Training', 'Braining', 'Brain Train', 'Mental Math Practice']),
				taskOptional: true,
				template: startWith
			};
		case 'Music':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Music', 'Music Listening']),
				taskOptional: true,
				template: startWith
			};
		case 'Create':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Create', 'Creating', 'Creation', 'Making']),
				taskOptional: true,
				template: startWith
			};
		case 'Children':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Children', 'Kids']),
				taskOptional: true,
				template: startWith
			};
		case 'Meeting':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meeting', 'Meet', 'Meetings']),
				taskOptional: true,
				template: startWith
			};
		case 'Cinema':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Cinema', 'Movies', 'Movie Theatre', 'Movie Theater']),
				taskOptional: true,
				template: startWith
			};
		case 'FilmWatching':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Films', 'Film Watching', 'Watching Movies']),
				taskOptional: true,
				template: startWith
			};
		case 'Series':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Series', 'TV Shows', 'TV Series']),
				taskOptional: true,
				template: startWith
			};
		case 'Broadcast':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Broadcast']),
				taskOptional: true,
				template: startWith
			};
		case 'Theatre':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Theatre', 'Play', 'Play/Musical', 'Drama']),
				taskOptional: true,
				template: startWith
			};
		case 'Shopping':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Shopping', 'Shop']),
				taskOptional: true,
				template: startWith
			};
		case 'VideoGaming':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Video', 'Video Gaming', 'Gaming']),
				taskOptional: true,
				template: startWith
			};
		case 'Housekeeping':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Housekeeping']),
				taskOptional: true,
				template: startWith
			};
		case 'MealPrep':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(45),
						author$project$SmartTime$Human$Duration$Hours(3))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meal Prep', 'Cooking', 'Food making']),
				taskOptional: true,
				template: startWith
			};
		case 'Networking':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Networking']),
				taskOptional: true,
				template: startWith
			};
		case 'Meditate':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Meditate', 'Meditation', 'Meditating']),
				taskOptional: true,
				template: startWith
			};
		case 'Homework':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Homework', 'Schoolwork']),
				taskOptional: true,
				template: startWith
			};
		case 'Flight':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Flight', 'Aviation', 'Flying', 'Airport']),
				taskOptional: true,
				template: startWith
			};
		case 'Course':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Course', 'Courses', 'Classes', 'Class']),
				taskOptional: true,
				template: startWith
			};
		case 'Pet':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Pet', 'Pets', 'Pet Care']),
				taskOptional: true,
				template: startWith
			};
		case 'Presentation':
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$NeverExcused,
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Presentation', 'Presenting', 'Present']),
				taskOptional: true,
				template: startWith
			};
		default:
			return {
				backgroundable: false,
				category: author$project$Activity$Activity$Slacking,
				evidence: _List_Nil,
				excusable: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(45),
						author$project$SmartTime$Human$Duration$Hours(3))),
				hidden: false,
				icon: author$project$Activity$Activity$File('unknown.svg'),
				maxTime: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				names: _List_fromArray(
					['Project', 'Projects', 'Project Work', 'Fun Project']),
				taskOptional: true,
				template: startWith
			};
	}
};
var author$project$Activity$Activity$withTemplate = function (delta) {
	var over = F2(
		function (b, s) {
			return A2(elm$core$Maybe$withDefault, b, s);
		});
	var base = author$project$Activity$Activity$defaults(delta.template);
	return {
		backgroundable: A2(over, base.backgroundable, delta.backgroundable),
		category: A2(over, base.category, delta.category),
		evidence: A2(over, base.evidence, delta.evidence),
		excusable: A2(over, base.excusable, delta.excusable),
		hidden: A2(over, base.hidden, delta.hidden),
		icon: A2(over, base.icon, delta.icon),
		maxTime: A2(over, base.maxTime, delta.maxTime),
		names: A2(over, base.names, delta.names),
		taskOptional: A2(over, base.taskOptional, delta.taskOptional),
		template: delta.template
	};
};
var author$project$Activity$Template$stockActivities = _List_fromArray(
	[author$project$Activity$Template$DillyDally, author$project$Activity$Template$Apparel, author$project$Activity$Template$Messaging, author$project$Activity$Template$Restroom, author$project$Activity$Template$Grooming, author$project$Activity$Template$Meal, author$project$Activity$Template$Supplements, author$project$Activity$Template$Workout, author$project$Activity$Template$Shower, author$project$Activity$Template$Toothbrush, author$project$Activity$Template$Floss, author$project$Activity$Template$Wakeup, author$project$Activity$Template$Sleep, author$project$Activity$Template$Plan, author$project$Activity$Template$Configure, author$project$Activity$Template$Email, author$project$Activity$Template$Work, author$project$Activity$Template$Call, author$project$Activity$Template$Chores, author$project$Activity$Template$Parents, author$project$Activity$Template$Prepare, author$project$Activity$Template$Lover, author$project$Activity$Template$Driving, author$project$Activity$Template$Riding, author$project$Activity$Template$SocialMedia, author$project$Activity$Template$Pacing, author$project$Activity$Template$Sport, author$project$Activity$Template$Finance, author$project$Activity$Template$Laundry, author$project$Activity$Template$Bedward, author$project$Activity$Template$Browse, author$project$Activity$Template$Fiction, author$project$Activity$Template$Learning, author$project$Activity$Template$BrainTrain, author$project$Activity$Template$Music, author$project$Activity$Template$Create, author$project$Activity$Template$Children, author$project$Activity$Template$Meeting, author$project$Activity$Template$Cinema, author$project$Activity$Template$FilmWatching, author$project$Activity$Template$Series, author$project$Activity$Template$Broadcast, author$project$Activity$Template$Theatre, author$project$Activity$Template$Shopping, author$project$Activity$Template$VideoGaming, author$project$Activity$Template$Housekeeping, author$project$Activity$Template$MealPrep, author$project$Activity$Template$Networking, author$project$Activity$Template$Meditate, author$project$Activity$Template$Homework, author$project$Activity$Template$Flight, author$project$Activity$Template$Course, author$project$Activity$Template$Pet, author$project$Activity$Template$Presentation, author$project$Activity$Template$Projects]);
var elm_community$intdict$IntDict$map = F2(
	function (f, dict) {
		switch (dict.$) {
			case 'Empty':
				return elm_community$intdict$IntDict$empty;
			case 'Leaf':
				var l = dict.a;
				return A2(
					elm_community$intdict$IntDict$leaf,
					l.key,
					A2(f, l.key, l.value));
			default:
				var i = dict.a;
				return A3(
					elm_community$intdict$IntDict$inner,
					i.prefix,
					A2(elm_community$intdict$IntDict$map, f, i.left),
					A2(elm_community$intdict$IntDict$map, f, i.right));
		}
	});
var elm_community$intdict$IntDict$Disjunct = F2(
	function (a, b) {
		return {$: 'Disjunct', a: a, b: b};
	});
var elm_community$intdict$IntDict$Left = {$: 'Left'};
var elm_community$intdict$IntDict$Parent = F2(
	function (a, b) {
		return {$: 'Parent', a: a, b: b};
	});
var elm_community$intdict$IntDict$Right = {$: 'Right'};
var elm_community$intdict$IntDict$SamePrefix = {$: 'SamePrefix'};
var elm_community$intdict$IntDict$combineBits = F3(
	function (a, b, mask) {
		return (a & (~mask)) | (b & mask);
	});
var elm_community$intdict$IntDict$mostSignificantBranchingBit = F2(
	function (a, b) {
		return (_Utils_eq(a, elm_community$intdict$IntDict$signBit) || _Utils_eq(b, elm_community$intdict$IntDict$signBit)) ? elm_community$intdict$IntDict$signBit : A2(elm$core$Basics$max, a, b);
	});
var elm_community$intdict$IntDict$determineBranchRelation = F2(
	function (l, r) {
		var rp = r.prefix;
		var lp = l.prefix;
		var mask = elm_community$intdict$IntDict$highestBitSet(
			A2(elm_community$intdict$IntDict$mostSignificantBranchingBit, lp.branchingBit, rp.branchingBit));
		var modifiedRightPrefix = A3(elm_community$intdict$IntDict$combineBits, rp.prefixBits, ~lp.prefixBits, mask);
		var prefix = A2(elm_community$intdict$IntDict$lcp, lp.prefixBits, modifiedRightPrefix);
		var childEdge = F2(
			function (branchPrefix, c) {
				return A2(elm_community$intdict$IntDict$isBranchingBitSet, branchPrefix, c.prefix.prefixBits) ? elm_community$intdict$IntDict$Right : elm_community$intdict$IntDict$Left;
			});
		return _Utils_eq(lp, rp) ? elm_community$intdict$IntDict$SamePrefix : (_Utils_eq(prefix, lp) ? A2(
			elm_community$intdict$IntDict$Parent,
			elm_community$intdict$IntDict$Left,
			A2(childEdge, l.prefix, r)) : (_Utils_eq(prefix, rp) ? A2(
			elm_community$intdict$IntDict$Parent,
			elm_community$intdict$IntDict$Right,
			A2(childEdge, r.prefix, l)) : A2(
			elm_community$intdict$IntDict$Disjunct,
			prefix,
			A2(childEdge, prefix, l))));
	});
var elm_community$intdict$IntDict$uniteWith = F3(
	function (merger, l, r) {
		var mergeWith = F3(
			function (key, left, right) {
				var _n14 = _Utils_Tuple2(left, right);
				if (_n14.a.$ === 'Just') {
					if (_n14.b.$ === 'Just') {
						var l2 = _n14.a.a;
						var r2 = _n14.b.a;
						return elm$core$Maybe$Just(
							A3(merger, key, l2, r2));
					} else {
						return left;
					}
				} else {
					if (_n14.b.$ === 'Just') {
						return right;
					} else {
						var _n15 = _n14.a;
						var _n16 = _n14.b;
						return elm$core$Maybe$Nothing;
					}
				}
			});
		var _n0 = _Utils_Tuple2(l, r);
		_n0$1:
		while (true) {
			_n0$2:
			while (true) {
				switch (_n0.a.$) {
					case 'Empty':
						var _n1 = _n0.a;
						return r;
					case 'Leaf':
						switch (_n0.b.$) {
							case 'Empty':
								break _n0$1;
							case 'Leaf':
								break _n0$2;
							default:
								break _n0$2;
						}
					default:
						switch (_n0.b.$) {
							case 'Empty':
								break _n0$1;
							case 'Leaf':
								var r2 = _n0.b.a;
								return A3(
									elm_community$intdict$IntDict$update,
									r2.key,
									function (l_) {
										return A3(
											mergeWith,
											r2.key,
											l_,
											elm$core$Maybe$Just(r2.value));
									},
									l);
							default:
								var il = _n0.a.a;
								var ir = _n0.b.a;
								var _n3 = A2(elm_community$intdict$IntDict$determineBranchRelation, il, ir);
								switch (_n3.$) {
									case 'SamePrefix':
										return A3(
											elm_community$intdict$IntDict$inner,
											il.prefix,
											A3(elm_community$intdict$IntDict$uniteWith, merger, il.left, ir.left),
											A3(elm_community$intdict$IntDict$uniteWith, merger, il.right, ir.right));
									case 'Parent':
										if (_n3.a.$ === 'Left') {
											if (_n3.b.$ === 'Right') {
												var _n4 = _n3.a;
												var _n5 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													il.prefix,
													il.left,
													A3(elm_community$intdict$IntDict$uniteWith, merger, il.right, r));
											} else {
												var _n8 = _n3.a;
												var _n9 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													il.prefix,
													A3(elm_community$intdict$IntDict$uniteWith, merger, il.left, r),
													il.right);
											}
										} else {
											if (_n3.b.$ === 'Right') {
												var _n6 = _n3.a;
												var _n7 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													ir.prefix,
													ir.left,
													A3(elm_community$intdict$IntDict$uniteWith, merger, l, ir.right));
											} else {
												var _n10 = _n3.a;
												var _n11 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													ir.prefix,
													A3(elm_community$intdict$IntDict$uniteWith, merger, l, ir.left),
													ir.right);
											}
										}
									default:
										if (_n3.b.$ === 'Left') {
											var parentPrefix = _n3.a;
											var _n12 = _n3.b;
											return A3(elm_community$intdict$IntDict$inner, parentPrefix, l, r);
										} else {
											var parentPrefix = _n3.a;
											var _n13 = _n3.b;
											return A3(elm_community$intdict$IntDict$inner, parentPrefix, r, l);
										}
								}
						}
				}
			}
			var l2 = _n0.a.a;
			return A3(
				elm_community$intdict$IntDict$update,
				l2.key,
				function (r_) {
					return A3(
						mergeWith,
						l2.key,
						elm$core$Maybe$Just(l2.value),
						r_);
				},
				r);
		}
		var _n2 = _n0.b;
		return l;
	});
var elm_community$intdict$IntDict$union = elm_community$intdict$IntDict$uniteWith(
	F3(
		function (key, old, _new) {
			return old;
		}));
var author$project$Activity$Activity$allActivities = function (stored) {
	var stock = elm_community$intdict$IntDict$fromList(
		A2(
			elm$core$List$indexedMap,
			elm$core$Tuple$pair,
			A2(elm$core$List$map, author$project$Activity$Activity$defaults, author$project$Activity$Template$stockActivities)));
	var customized = A2(
		elm_community$intdict$IntDict$map,
		F2(
			function (_n0, v) {
				return author$project$Activity$Activity$withTemplate(v);
			}),
		stored);
	return A2(elm_community$intdict$IntDict$union, customized, stock);
};
var author$project$External$TodoistSync$describeSuccess = function (success) {
	return success.full_sync ? ('Did FULL Todoist sync: ' + (elm$core$String$fromInt(
		elm$core$List$length(success.items)) + (' items, ' + (elm$core$String$fromInt(
		elm$core$List$length(success.projects)) + 'projects retrieved!')))) : ('Incremental Todoist sync complete: Updated ' + (elm$core$String$fromInt(
		elm$core$List$length(success.items)) + (' items and ' + (elm$core$String$fromInt(
		elm$core$List$length(success.projects)) + 'projects.'))));
};
var author$project$ID$tag = function (_int) {
	return author$project$ID$ID(_int);
};
var elm_community$intdict$IntDict$foldl = F3(
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
						$temp$acc = A3(elm_community$intdict$IntDict$foldl, f, acc, i.left),
						$temp$dict = i.right;
					f = $temp$f;
					acc = $temp$acc;
					dict = $temp$dict;
					continue foldl;
			}
		}
	});
var author$project$IntDictExtra$filterMap = F2(
	function (f, dict) {
		return A3(
			elm_community$intdict$IntDict$foldl,
			F3(
				function (k, v, acc) {
					var _n0 = A2(f, k, v);
					if (_n0.$ === 'Just') {
						var newVal = _n0.a;
						return A3(elm_community$intdict$IntDict$insert, k, newVal, acc);
					} else {
						return acc;
					}
				}),
			elm_community$intdict$IntDict$empty,
			dict);
	});
var author$project$IntDictExtra$mapValues = F2(
	function (func, dict) {
		return A2(
			elm_community$intdict$IntDict$map,
			F2(
				function (_n0, v) {
					return func(v);
				}),
			dict);
	});
var elm$core$List$any = F2(
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
var elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var elm_community$intdict$IntDict$values = function (dict) {
	return A3(
		elm_community$intdict$IntDict$foldr,
		F3(
			function (key, value, valueList) {
				return A2(elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var author$project$External$TodoistSync$findActivityProjectIDs = F2(
	function (projects, activities) {
		var matchToID = F3(
			function (nameToTest, activityID, nameList) {
				return A2(elm$core$List$member, nameToTest, nameList) ? elm$core$Maybe$Just(
					author$project$ID$tag(activityID)) : elm$core$Maybe$Nothing;
			});
		var activityNamesDict = A2(
			author$project$IntDictExtra$mapValues,
			function ($) {
				return $.names;
			},
			activities);
		var activityNameMatches = function (nameToTest) {
			return A2(
				author$project$IntDictExtra$filterMap,
				matchToID(nameToTest),
				activityNamesDict);
		};
		var pickFirstMatch = function (nameToTest) {
			return elm$core$List$head(
				elm_community$intdict$IntDict$values(
					activityNameMatches(nameToTest)));
		};
		return A2(
			author$project$IntDictExtra$filterMap,
			F2(
				function (i, p) {
					return pickFirstMatch(p.name);
				}),
			projects);
	});
var elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 'Bad', a: a, b: b};
	});
var elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 'Good', a: a, b: b, c: c};
	});
var elm$parser$Parser$Advanced$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var elm$parser$Parser$Advanced$map2 = F3(
	function (func, _n0, _n1) {
		var parseA = _n0.a;
		var parseB = _n1.a;
		return elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _n2 = parseA(s0);
				if (_n2.$ === 'Bad') {
					var p = _n2.a;
					var x = _n2.b;
					return A2(elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _n2.a;
					var a = _n2.b;
					var s1 = _n2.c;
					var _n3 = parseB(s1);
					if (_n3.$ === 'Bad') {
						var p2 = _n3.a;
						var x = _n3.b;
						return A2(elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _n3.a;
						var b = _n3.b;
						var s2 = _n3.c;
						return A3(
							elm$parser$Parser$Advanced$Good,
							p1 || p2,
							A2(func, a, b),
							s2);
					}
				}
			});
	});
var elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3(elm$parser$Parser$Advanced$map2, elm$core$Basics$always, keepParser, ignoreParser);
	});
var elm$parser$Parser$ignorer = elm$parser$Parser$Advanced$ignorer;
var elm$parser$Parser$ExpectingInt = {$: 'ExpectingInt'};
var elm$parser$Parser$Advanced$consumeBase = _Parser_consumeBase;
var elm$parser$Parser$Advanced$consumeBase16 = _Parser_consumeBase16;
var elm$core$String$toFloat = _String_toFloat;
var elm$parser$Parser$Advanced$bumpOffset = F2(
	function (newOffset, s) {
		return {col: s.col + (newOffset - s.offset), context: s.context, indent: s.indent, offset: newOffset, row: s.row, src: s.src};
	});
var elm$parser$Parser$Advanced$chompBase10 = _Parser_chompBase10;
var elm$parser$Parser$Advanced$isAsciiCode = _Parser_isAsciiCode;
var elm$parser$Parser$Advanced$consumeExp = F2(
	function (offset, src) {
		if (A3(elm$parser$Parser$Advanced$isAsciiCode, 101, offset, src) || A3(elm$parser$Parser$Advanced$isAsciiCode, 69, offset, src)) {
			var eOffset = offset + 1;
			var expOffset = (A3(elm$parser$Parser$Advanced$isAsciiCode, 43, eOffset, src) || A3(elm$parser$Parser$Advanced$isAsciiCode, 45, eOffset, src)) ? (eOffset + 1) : eOffset;
			var newOffset = A2(elm$parser$Parser$Advanced$chompBase10, expOffset, src);
			return _Utils_eq(expOffset, newOffset) ? (-newOffset) : newOffset;
		} else {
			return offset;
		}
	});
var elm$parser$Parser$Advanced$consumeDotAndExp = F2(
	function (offset, src) {
		return A3(elm$parser$Parser$Advanced$isAsciiCode, 46, offset, src) ? A2(
			elm$parser$Parser$Advanced$consumeExp,
			A2(elm$parser$Parser$Advanced$chompBase10, offset + 1, src),
			src) : A2(elm$parser$Parser$Advanced$consumeExp, offset, src);
	});
var elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 'AddRight', a: a, b: b};
	});
var elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {col: col, contextStack: contextStack, problem: problem, row: row};
	});
var elm$parser$Parser$Advanced$Empty = {$: 'Empty'};
var elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			elm$parser$Parser$Advanced$AddRight,
			elm$parser$Parser$Advanced$Empty,
			A4(elm$parser$Parser$Advanced$DeadEnd, s.row, s.col, x, s.context));
	});
var elm$parser$Parser$Advanced$finalizeInt = F5(
	function (invalid, handler, startOffset, _n0, s) {
		var endOffset = _n0.a;
		var n = _n0.b;
		if (handler.$ === 'Err') {
			var x = handler.a;
			return A2(
				elm$parser$Parser$Advanced$Bad,
				true,
				A2(elm$parser$Parser$Advanced$fromState, s, x));
		} else {
			var toValue = handler.a;
			return _Utils_eq(startOffset, endOffset) ? A2(
				elm$parser$Parser$Advanced$Bad,
				_Utils_cmp(s.offset, startOffset) < 0,
				A2(elm$parser$Parser$Advanced$fromState, s, invalid)) : A3(
				elm$parser$Parser$Advanced$Good,
				true,
				toValue(n),
				A2(elm$parser$Parser$Advanced$bumpOffset, endOffset, s));
		}
	});
var elm$parser$Parser$Advanced$fromInfo = F4(
	function (row, col, x, context) {
		return A2(
			elm$parser$Parser$Advanced$AddRight,
			elm$parser$Parser$Advanced$Empty,
			A4(elm$parser$Parser$Advanced$DeadEnd, row, col, x, context));
	});
var elm$parser$Parser$Advanced$finalizeFloat = F6(
	function (invalid, expecting, intSettings, floatSettings, intPair, s) {
		var intOffset = intPair.a;
		var floatOffset = A2(elm$parser$Parser$Advanced$consumeDotAndExp, intOffset, s.src);
		if (floatOffset < 0) {
			return A2(
				elm$parser$Parser$Advanced$Bad,
				true,
				A4(elm$parser$Parser$Advanced$fromInfo, s.row, s.col - (floatOffset + s.offset), invalid, s.context));
		} else {
			if (_Utils_eq(s.offset, floatOffset)) {
				return A2(
					elm$parser$Parser$Advanced$Bad,
					false,
					A2(elm$parser$Parser$Advanced$fromState, s, expecting));
			} else {
				if (_Utils_eq(intOffset, floatOffset)) {
					return A5(elm$parser$Parser$Advanced$finalizeInt, invalid, intSettings, s.offset, intPair, s);
				} else {
					if (floatSettings.$ === 'Err') {
						var x = floatSettings.a;
						return A2(
							elm$parser$Parser$Advanced$Bad,
							true,
							A2(elm$parser$Parser$Advanced$fromState, s, invalid));
					} else {
						var toValue = floatSettings.a;
						var _n1 = elm$core$String$toFloat(
							A3(elm$core$String$slice, s.offset, floatOffset, s.src));
						if (_n1.$ === 'Nothing') {
							return A2(
								elm$parser$Parser$Advanced$Bad,
								true,
								A2(elm$parser$Parser$Advanced$fromState, s, invalid));
						} else {
							var n = _n1.a;
							return A3(
								elm$parser$Parser$Advanced$Good,
								true,
								toValue(n),
								A2(elm$parser$Parser$Advanced$bumpOffset, floatOffset, s));
						}
					}
				}
			}
		}
	});
var elm$parser$Parser$Advanced$number = function (c) {
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			if (A3(elm$parser$Parser$Advanced$isAsciiCode, 48, s.offset, s.src)) {
				var zeroOffset = s.offset + 1;
				var baseOffset = zeroOffset + 1;
				return A3(elm$parser$Parser$Advanced$isAsciiCode, 120, zeroOffset, s.src) ? A5(
					elm$parser$Parser$Advanced$finalizeInt,
					c.invalid,
					c.hex,
					baseOffset,
					A2(elm$parser$Parser$Advanced$consumeBase16, baseOffset, s.src),
					s) : (A3(elm$parser$Parser$Advanced$isAsciiCode, 111, zeroOffset, s.src) ? A5(
					elm$parser$Parser$Advanced$finalizeInt,
					c.invalid,
					c.octal,
					baseOffset,
					A3(elm$parser$Parser$Advanced$consumeBase, 8, baseOffset, s.src),
					s) : (A3(elm$parser$Parser$Advanced$isAsciiCode, 98, zeroOffset, s.src) ? A5(
					elm$parser$Parser$Advanced$finalizeInt,
					c.invalid,
					c.binary,
					baseOffset,
					A3(elm$parser$Parser$Advanced$consumeBase, 2, baseOffset, s.src),
					s) : A6(
					elm$parser$Parser$Advanced$finalizeFloat,
					c.invalid,
					c.expecting,
					c._int,
					c._float,
					_Utils_Tuple2(zeroOffset, 0),
					s)));
			} else {
				return A6(
					elm$parser$Parser$Advanced$finalizeFloat,
					c.invalid,
					c.expecting,
					c._int,
					c._float,
					A3(elm$parser$Parser$Advanced$consumeBase, 10, s.offset, s.src),
					s);
			}
		});
};
var elm$parser$Parser$Advanced$int = F2(
	function (expecting, invalid) {
		return elm$parser$Parser$Advanced$number(
			{
				binary: elm$core$Result$Err(invalid),
				expecting: expecting,
				_float: elm$core$Result$Err(invalid),
				hex: elm$core$Result$Err(invalid),
				_int: elm$core$Result$Ok(elm$core$Basics$identity),
				invalid: invalid,
				octal: elm$core$Result$Err(invalid)
			});
	});
var elm$parser$Parser$int = A2(elm$parser$Parser$Advanced$int, elm$parser$Parser$ExpectingInt, elm$parser$Parser$ExpectingInt);
var elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3(elm$parser$Parser$Advanced$map2, elm$core$Basics$apL, parseFunc, parseArg);
	});
var elm$parser$Parser$keeper = elm$parser$Parser$Advanced$keeper;
var elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var elm$parser$Parser$Advanced$chompWhileHelp = F5(
	function (isGood, offset, row, col, s0) {
		chompWhileHelp:
		while (true) {
			var newOffset = A3(elm$parser$Parser$Advanced$isSubChar, isGood, offset, s0.src);
			if (_Utils_eq(newOffset, -1)) {
				return A3(
					elm$parser$Parser$Advanced$Good,
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
var elm$parser$Parser$Advanced$chompWhile = function (isGood) {
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A5(elm$parser$Parser$Advanced$chompWhileHelp, isGood, s.offset, s.row, s.col, s);
		});
};
var elm$parser$Parser$Advanced$spaces = elm$parser$Parser$Advanced$chompWhile(
	function (c) {
		return _Utils_eq(
			c,
			_Utils_chr(' ')) || (_Utils_eq(
			c,
			_Utils_chr('\n')) || _Utils_eq(
			c,
			_Utils_chr('\r')));
	});
var elm$parser$Parser$spaces = elm$parser$Parser$Advanced$spaces;
var elm$parser$Parser$Advanced$succeed = function (a) {
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3(elm$parser$Parser$Advanced$Good, false, a, s);
		});
};
var elm$parser$Parser$succeed = elm$parser$Parser$Advanced$succeed;
var elm$parser$Parser$ExpectingSymbol = function (a) {
	return {$: 'ExpectingSymbol', a: a};
};
var elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 'Token', a: a, b: b};
	});
var elm$core$Basics$not = _Basics_not;
var elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var elm$parser$Parser$Advanced$token = function (_n0) {
	var str = _n0.a;
	var expecting = _n0.b;
	var progress = !elm$core$String$isEmpty(str);
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			var _n1 = A5(elm$parser$Parser$Advanced$isSubString, str, s.offset, s.row, s.col, s.src);
			var newOffset = _n1.a;
			var newRow = _n1.b;
			var newCol = _n1.c;
			return _Utils_eq(newOffset, -1) ? A2(
				elm$parser$Parser$Advanced$Bad,
				false,
				A2(elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
				elm$parser$Parser$Advanced$Good,
				progress,
				_Utils_Tuple0,
				{col: newCol, context: s.context, indent: s.indent, offset: newOffset, row: newRow, src: s.src});
		});
};
var elm$parser$Parser$Advanced$symbol = elm$parser$Parser$Advanced$token;
var elm$parser$Parser$symbol = function (str) {
	return elm$parser$Parser$Advanced$symbol(
		A2(
			elm$parser$Parser$Advanced$Token,
			str,
			elm$parser$Parser$ExpectingSymbol(str)));
};
var author$project$External$TodoistSync$timing = A2(
	elm$parser$Parser$keeper,
	A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$ignorer,
			A2(
				elm$parser$Parser$ignorer,
				elm$parser$Parser$succeed(elm$core$Tuple$pair),
				elm$parser$Parser$symbol('(')),
			elm$parser$Parser$spaces),
		A2(
			elm$parser$Parser$ignorer,
			elm$parser$Parser$int,
			elm$parser$Parser$symbol('-'))),
	A2(
		elm$parser$Parser$ignorer,
		A2(
			elm$parser$Parser$ignorer,
			A2(
				elm$parser$Parser$ignorer,
				elm$parser$Parser$int,
				elm$parser$Parser$symbol('m')),
			elm$parser$Parser$spaces),
		elm$parser$Parser$symbol(')')));
var elm$core$String$dropRight = F2(
	function (n, string) {
		return (n < 1) ? string : A3(elm$core$String$slice, 0, -n, string);
	});
var elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {col: col, problem: problem, row: row};
	});
var elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3(elm$parser$Parser$DeadEnd, p.row, p.col, p.problem);
};
var elm$parser$Parser$Advanced$bagToList = F2(
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
						$temp$list = A2(elm$core$List$cons, x, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
				default:
					var bag1 = bag.a;
					var bag2 = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2(elm$parser$Parser$Advanced$bagToList, bag2, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
			}
		}
	});
var elm$parser$Parser$Advanced$run = F2(
	function (_n0, src) {
		var parse = _n0.a;
		var _n1 = parse(
			{col: 1, context: _List_Nil, indent: 1, offset: 0, row: 1, src: src});
		if (_n1.$ === 'Good') {
			var value = _n1.b;
			return elm$core$Result$Ok(value);
		} else {
			var bag = _n1.b;
			return elm$core$Result$Err(
				A2(elm$parser$Parser$Advanced$bagToList, bag, _List_Nil));
		}
	});
var elm$parser$Parser$run = F2(
	function (parser, source) {
		var _n0 = A2(elm$parser$Parser$Advanced$run, parser, source);
		if (_n0.$ === 'Ok') {
			var a = _n0.a;
			return elm$core$Result$Ok(a);
		} else {
			var problems = _n0.a;
			return elm$core$Result$Err(
				A2(elm$core$List$map, elm$parser$Parser$problemToDeadEnd, problems));
		}
	});
var elm_community$list_extra$List$Extra$last = function (items) {
	last:
	while (true) {
		if (!items.b) {
			return elm$core$Maybe$Nothing;
		} else {
			if (!items.b.b) {
				var x = items.a;
				return elm$core$Maybe$Just(x);
			} else {
				var rest = items.b;
				var $temp$items = rest;
				items = $temp$items;
				continue last;
			}
		}
	}
};
var author$project$External$TodoistSync$extractTiming2 = function (input) {
	var _default = _Utils_Tuple2(
		input,
		_Utils_Tuple2(elm$core$Maybe$Nothing, elm$core$Maybe$Nothing));
	var chunk = function (start) {
		return A2(elm$core$String$dropLeft, start, input);
	};
	var withoutChunk = function (chunkStart) {
		return A2(
			elm$core$String$dropRight,
			elm$core$String$length(
				chunk(chunkStart)),
			chunk(chunkStart));
	};
	var _n0 = elm_community$list_extra$List$Extra$last(
		A2(elm$core$String$indexes, '(', input));
	if (_n0.$ === 'Nothing') {
		return _default;
	} else {
		var chunkStart = _n0.a;
		var _n1 = A2(
			elm$parser$Parser$run,
			author$project$External$TodoistSync$timing,
			chunk(chunkStart));
		if (_n1.$ === 'Err') {
			return _default;
		} else {
			var _n2 = _n1.a;
			var num1 = _n2.a;
			var num2 = _n2.b;
			return _Utils_Tuple2(
				withoutChunk(chunkStart),
				_Utils_Tuple2(
					elm$core$Maybe$Just(
						author$project$SmartTime$Human$Duration$Minutes(num1)),
					elm$core$Maybe$Just(
						author$project$SmartTime$Human$Duration$Minutes(num2))));
		}
	}
};
var author$project$External$TodoistSync$priorityToImportance = function (_n0) {
	var _int = _n0.a;
	return 0 - _int;
};
var author$project$Task$Progress$unitMax = function (unit) {
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
			var _n1 = unit.a;
			var customTarget = unit.b;
			return customTarget;
	}
};
var author$project$Task$Progress$maximize = function (_n0) {
	var unit = _n0.b;
	return _Utils_Tuple2(
		author$project$Task$Progress$unitMax(unit),
		unit);
};
var author$project$Task$Task$newTask = F2(
	function (description, id) {
		return {
			activity: elm$core$Maybe$Nothing,
			completion: _Utils_Tuple2(0, author$project$Task$Progress$Percent),
			deadline: author$project$Task$TaskMoment$Unset,
			history: _List_Nil,
			id: id,
			importance: 0,
			maxEffort: author$project$SmartTime$Duration$zero,
			minEffort: author$project$SmartTime$Duration$zero,
			parent: elm$core$Maybe$Nothing,
			plannedFinish: author$project$Task$TaskMoment$Unset,
			plannedStart: author$project$Task$TaskMoment$Unset,
			predictedEffort: author$project$SmartTime$Duration$zero,
			relevanceEnds: author$project$Task$TaskMoment$Unset,
			relevanceStarts: author$project$Task$TaskMoment$Unset,
			tags: _List_Nil,
			title: description
		};
	});
var author$project$External$TodoistSync$itemToTask = F2(
	function (activityID, item) {
		var _n0 = author$project$External$TodoistSync$extractTiming2(item.content);
		var newName = _n0.a;
		var _n1 = _n0.b;
		var minDur = _n1.a;
		var maxDur = _n1.b;
		var base = A2(author$project$Task$Task$newTask, newName, item.id);
		var _n2 = _Utils_Tuple2(
			A2(elm$core$Maybe$map, author$project$SmartTime$Human$Duration$toDuration, minDur),
			A2(elm$core$Maybe$map, author$project$SmartTime$Human$Duration$toDuration, maxDur));
		var finalMin = _n2.a;
		var finalMax = _n2.b;
		return _Utils_update(
			base,
			{
				activity: elm$core$Maybe$Just(activityID),
				completion: item.checked ? author$project$Task$Progress$maximize(base.completion) : base.completion,
				importance: author$project$External$TodoistSync$priorityToImportance(item.priority),
				maxEffort: A2(elm$core$Maybe$withDefault, base.maxEffort, finalMax),
				minEffort: A2(elm$core$Maybe$withDefault, base.minEffort, finalMin),
				tags: _List_Nil
			});
	});
var elm_community$intdict$IntDict$get = F2(
	function (key, dict) {
		get:
		while (true) {
			switch (dict.$) {
				case 'Empty':
					return elm$core$Maybe$Nothing;
				case 'Leaf':
					var l = dict.a;
					return _Utils_eq(l.key, key) ? elm$core$Maybe$Just(l.value) : elm$core$Maybe$Nothing;
				default:
					var i = dict.a;
					if (!A2(elm_community$intdict$IntDict$prefixMatches, i.prefix, key)) {
						return elm$core$Maybe$Nothing;
					} else {
						if (A2(elm_community$intdict$IntDict$isBranchingBitSet, i.prefix, key)) {
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
var author$project$External$TodoistSync$timetrackItemToTask = F2(
	function (lookup, item) {
		var _n0 = A2(elm_community$intdict$IntDict$get, item.project_id, lookup);
		if (_n0.$ === 'Just') {
			var act = _n0.a;
			return elm$core$Maybe$Just(
				A2(author$project$External$TodoistSync$itemToTask, act, item));
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm_community$intdict$IntDict$filter = F2(
	function (predicate, dict) {
		var add = F3(
			function (k, v, d) {
				return A2(predicate, k, v) ? A3(elm_community$intdict$IntDict$insert, k, v, d) : d;
			});
		return A3(elm_community$intdict$IntDict$foldl, add, elm_community$intdict$IntDict$empty, dict);
	});
var elm_community$intdict$IntDict$keys = function (dict) {
	return A3(
		elm_community$intdict$IntDict$foldr,
		F3(
			function (key, value, keyList) {
				return A2(elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var author$project$External$TodoistSync$handle = F2(
	function (_n0, app) {
		var result = _n0.a;
		var tasks = app.tasks;
		var activities = app.activities;
		var todoist = app.todoist;
		if (result.$ === 'Ok') {
			var success = result.a;
			var filledInActivities = author$project$Activity$Activity$allActivities(activities);
			var _n2 = success;
			var sync_token = _n2.sync_token;
			var full_sync = _n2.full_sync;
			var items = _n2.items;
			var projects = _n2.projects;
			var projectsDict = elm_community$intdict$IntDict$fromList(
				A2(
					elm$core$List$map,
					function (p) {
						return _Utils_Tuple2(p.id, p);
					},
					projects));
			var updatedTimetrackParent = elm$core$List$head(
				elm_community$intdict$IntDict$keys(
					A2(
						elm_community$intdict$IntDict$filter,
						F2(
							function (_n4, p) {
								return p.name === 'Timetrack';
							}),
						projectsDict)));
			var timetrackParent = A2(elm$core$Maybe$withDefault, todoist.parentProjectID, updatedTimetrackParent);
			var validActivityProjects = A2(
				elm_community$intdict$IntDict$filter,
				F2(
					function (_n3, p) {
						return _Utils_eq(p.parentId, timetrackParent);
					}),
				projectsDict);
			var activityLookupTable = A2(author$project$External$TodoistSync$findActivityProjectIDs, validActivityProjects, filledInActivities);
			var itemsInTimetrackToTasks = A2(
				elm$core$List$filterMap,
				author$project$External$TodoistSync$timetrackItemToTask(activityLookupTable),
				items);
			var generatedTasks = elm_community$intdict$IntDict$fromList(
				A2(
					elm$core$List$map,
					function (t) {
						return _Utils_Tuple2(t.id, t);
					},
					itemsInTimetrackToTasks));
			return _Utils_Tuple2(
				_Utils_update(
					app,
					{
						tasks: A2(elm_community$intdict$IntDict$union, generatedTasks, tasks),
						todoist: {
							activityProjectIDs: A2(elm_community$intdict$IntDict$union, activityLookupTable, todoist.activityProjectIDs),
							parentProjectID: timetrackParent,
							syncToken: sync_token
						}
					}),
				author$project$External$TodoistSync$describeSuccess(success));
		} else {
			var err = result.a;
			var handleError = function (description) {
				return _Utils_Tuple2(
					A2(author$project$AppData$saveError, app, description),
					description);
			};
			switch (err.$) {
				case 'BadUrl':
					var msg = err.a;
					return handleError(msg);
				case 'Timeout':
					return handleError('Timeout?');
				case 'NetworkError':
					return handleError('Network Error');
				case 'BadStatus':
					var status = err.a;
					return handleError(
						'Got Error code' + elm$core$String$fromInt(status));
				default:
					var string = err.a;
					return handleError(string);
			}
		}
	});
var author$project$External$TodoistSync$SyncResponded = function (a) {
	return {$: 'SyncResponded', a: a};
};
var author$project$External$TodoistSync$Response = F4(
	function (sync_token, full_sync, items, projects) {
		return {full_sync: full_sync, items: items, projects: projects, sync_token: sync_token};
	});
var author$project$External$TodoistSync$Item = function (id) {
	return function (user_id) {
		return function (project_id) {
			return function (content) {
				return function (due) {
					return function (indent) {
						return function (priority) {
							return function (parent_id) {
								return function (child_order) {
									return function (day_order) {
										return function (collapsed) {
											return function (children) {
												return function (labels) {
													return function (assigned_by_uid) {
														return function (responsible_uid) {
															return function (checked) {
																return function (in_history) {
																	return function (is_deleted) {
																		return function (is_archived) {
																			return function (date_added) {
																				return {assigned_by_uid: assigned_by_uid, checked: checked, child_order: child_order, children: children, collapsed: collapsed, content: content, date_added: date_added, day_order: day_order, due: due, id: id, in_history: in_history, indent: indent, is_archived: is_archived, is_deleted: is_deleted, labels: labels, parent_id: parent_id, priority: priority, project_id: project_id, responsible_uid: responsible_uid, user_id: user_id};
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
var author$project$External$TodoistSync$Due = F5(
	function (date, timezone, string, lang, isRecurring) {
		return {date: date, isRecurring: isRecurring, lang: lang, string: string, timezone: timezone};
	});
var author$project$External$TodoistSync$decodeDue = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'is_recurring',
	zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
	A3(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'lang',
		zwilias$json_decode_exploration$Json$Decode$Exploration$string,
		A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'string',
			zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			A3(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'timezone',
				zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(zwilias$json_decode_exploration$Json$Decode$Exploration$string),
				A3(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'date',
					zwilias$json_decode_exploration$Json$Decode$Exploration$string,
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$Due))))));
var author$project$External$TodoistSync$Priority = function (a) {
	return {$: 'Priority', a: a};
};
var author$project$External$TodoistSync$decodePriority = zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			4,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				author$project$External$TodoistSync$Priority(1))),
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			3,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				author$project$External$TodoistSync$Priority(2))),
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			2,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				author$project$External$TodoistSync$Priority(3))),
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			1,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				author$project$External$TodoistSync$Priority(4)))
		]));
var author$project$Porting$decodeBoolAsInt = zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			1,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(true)),
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			0,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(false))
		]));
var zwilias$json_decode_exploration$Json$Decode$Exploration$value = zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder(
	function (json) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
			zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
			zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json));
	});
var author$project$Porting$optionalIgnored = F2(
	function (field, pipeline) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (_n0) {
				return pipeline;
			},
			zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
				_List_fromArray(
					[
						A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, field, zwilias$json_decode_exploration$Json$Decode$Exploration$value),
						zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(elm$json$Json$Encode$null)
					])));
	});
var author$project$External$TodoistSync$decodeItem = A2(
	author$project$Porting$optionalIgnored,
	'section_id',
	A2(
		author$project$Porting$optionalIgnored,
		'has_more_notes',
		A2(
			author$project$Porting$optionalIgnored,
			'date_completed',
			A2(
				author$project$Porting$optionalIgnored,
				'sync_id',
				A2(
					author$project$Porting$optionalIgnored,
					'legacy_parent_id',
					A2(
						author$project$Porting$optionalIgnored,
						'legacy_project_id',
						A2(
							author$project$Porting$optionalIgnored,
							'legacy_id',
							A3(
								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
								'date_added',
								zwilias$json_decode_exploration$Json$Decode$Exploration$string,
								A4(
									zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
									'is_archived',
									author$project$Porting$decodeBoolAsInt,
									false,
									A3(
										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'is_deleted',
										author$project$Porting$decodeBoolAsInt,
										A3(
											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
											'in_history',
											author$project$Porting$decodeBoolAsInt,
											A3(
												zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'checked',
												author$project$Porting$decodeBoolAsInt,
												A3(
													zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'responsible_uid',
													zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
													A4(
														zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
														'assigned_by_uid',
														zwilias$json_decode_exploration$Json$Decode$Exploration$int,
														0,
														A3(
															zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
															'labels',
															zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
															A4(
																zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																'children',
																zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
																_List_Nil,
																A3(
																	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																	'collapsed',
																	author$project$Porting$decodeBoolAsInt,
																	A3(
																		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																		'day_order',
																		zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																		A3(
																			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																			'child_order',
																			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																			A3(
																				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																				'parent_id',
																				zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
																				A3(
																					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																					'priority',
																					author$project$External$TodoistSync$decodePriority,
																					A4(
																						zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																						'indent',
																						zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																						0,
																						A3(
																							zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																							'due',
																							zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$External$TodoistSync$decodeDue),
																							A3(
																								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																								'content',
																								zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																								A3(
																									zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																									'project_id',
																									zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																									A3(
																										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																										'user_id',
																										zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																										A3(
																											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																											'id',
																											zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$Item))))))))))))))))))))))))))));
var author$project$External$TodoistSync$Project = function (id) {
	return function (name) {
		return function (color) {
			return function (parentId) {
				return function (childOrder) {
					return function (collapsed) {
						return function (shared) {
							return function (isDeleted) {
								return function (isArchived) {
									return function (isFavorite) {
										return {childOrder: childOrder, collapsed: collapsed, color: color, id: id, isArchived: isArchived, isDeleted: isDeleted, isFavorite: isFavorite, name: name, parentId: parentId, shared: shared};
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
var author$project$External$TodoistSync$decodeProjectChanges = A2(
	author$project$Porting$optionalIgnored,
	'inbox_project',
	A2(
		author$project$Porting$optionalIgnored,
		'has_more_notes',
		A2(
			author$project$Porting$optionalIgnored,
			'legacy_id',
			A2(
				author$project$Porting$optionalIgnored,
				'legacy_parent_id',
				A3(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'is_favorite',
					zwilias$json_decode_exploration$Json$Decode$Exploration$int,
					A3(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
						'is_archived',
						zwilias$json_decode_exploration$Json$Decode$Exploration$int,
						A3(
							zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
							'is_deleted',
							zwilias$json_decode_exploration$Json$Decode$Exploration$int,
							A3(
								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
								'shared',
								zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
								A3(
									zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
									'collapsed',
									zwilias$json_decode_exploration$Json$Decode$Exploration$int,
									A3(
										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'child_order',
										zwilias$json_decode_exploration$Json$Decode$Exploration$int,
										A4(
											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
											'parent_id',
											zwilias$json_decode_exploration$Json$Decode$Exploration$int,
											0,
											A3(
												zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'color',
												zwilias$json_decode_exploration$Json$Decode$Exploration$int,
												A3(
													zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'name',
													zwilias$json_decode_exploration$Json$Decode$Exploration$string,
													A3(
														zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
														'id',
														zwilias$json_decode_exploration$Json$Decode$Exploration$int,
														zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$Project)))))))))))))));
var author$project$External$TodoistSync$decodeResponse = A2(
	author$project$Porting$optionalIgnored,
	'tooltips',
	A2(
		author$project$Porting$optionalIgnored,
		'locations',
		A2(
			author$project$Porting$optionalIgnored,
			'stats',
			A2(
				author$project$Porting$optionalIgnored,
				'incomplete_item_ids',
				A2(
					author$project$Porting$optionalIgnored,
					'incomplete_project_ids',
					A2(
						author$project$Porting$optionalIgnored,
						'day_orders_timestamp',
						A2(
							author$project$Porting$optionalIgnored,
							'due_exceptions',
							A2(
								author$project$Porting$optionalIgnored,
								'sections',
								A2(
									author$project$Porting$optionalIgnored,
									'user_settings',
									A2(
										author$project$Porting$optionalIgnored,
										'user',
										A2(
											author$project$Porting$optionalIgnored,
											'temp_id_mapping',
											A2(
												author$project$Porting$optionalIgnored,
												'settings_notifications',
												A2(
													author$project$Porting$optionalIgnored,
													'reminders',
													A2(
														author$project$Porting$optionalIgnored,
														'project_notes',
														A2(
															author$project$Porting$optionalIgnored,
															'notes',
															A2(
																author$project$Porting$optionalIgnored,
																'live_notifications_last_read_id',
																A2(
																	author$project$Porting$optionalIgnored,
																	'live_notifications',
																	A2(
																		author$project$Porting$optionalIgnored,
																		'labels',
																		A2(
																			author$project$Porting$optionalIgnored,
																			'filters',
																			A2(
																				author$project$Porting$optionalIgnored,
																				'day_orders',
																				A2(
																					author$project$Porting$optionalIgnored,
																					'collaborator_states',
																					A2(
																						author$project$Porting$optionalIgnored,
																						'collaborators',
																						A4(
																							zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																							'projects',
																							zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$External$TodoistSync$decodeProjectChanges),
																							_List_Nil,
																							A4(
																								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																								'items',
																								zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$External$TodoistSync$decodeItem),
																								_List_Nil,
																								A3(
																									zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																									'full_sync',
																									zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																									A3(
																										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																										'sync_token',
																										zwilias$json_decode_exploration$Json$Decode$Exploration$string,
																										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$Response)))))))))))))))))))))))))));
var elm$core$String$concat = function (strings) {
	return A2(elm$core$String$join, '', strings);
};
var author$project$External$TodoistSync$syncUrl = function (incrementalSyncToken) {
	var someResources = '[%22items%22,%22projects%22]';
	var devSecret = '0bdc5149510737ab941485bace8135c60e2d812b';
	var query = elm$core$String$concat(
		A2(
			elm$core$List$intersperse,
			'&',
			_List_fromArray(
				['token=' + devSecret, 'sync_token=' + incrementalSyncToken, 'resource_types=' + someResources])));
	var allResources = '[%22all%22]';
	return {
		fragment: elm$core$Maybe$Nothing,
		host: 'todoist.com',
		path: '/api/v8/sync',
		port_: elm$core$Maybe$Nothing,
		protocol: elm$url$Url$Https,
		query: elm$core$Maybe$Just(query)
	};
};
var elm$core$Result$mapError = F2(
	function (f, result) {
		if (result.$ === 'Ok') {
			var v = result.a;
			return elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return elm$core$Result$Err(
				f(e));
		}
	});
var elm$json$Json$Decode$fail = _Json_fail;
var elm_community$json_extra$Json$Decode$Extra$fromResult = function (result) {
	if (result.$ === 'Ok') {
		var successValue = result.a;
		return elm$json$Json$Decode$succeed(successValue);
	} else {
		var errorMessage = result.a;
		return elm$json$Json$Decode$fail(errorMessage);
	}
};
var mgold$elm_nonempty_list$List$Nonempty$map = F2(
	function (f, _n0) {
		var x = _n0.a;
		var xs = _n0.b;
		return A2(
			mgold$elm_nonempty_list$List$Nonempty$Nonempty,
			f(x),
			A2(elm$core$List$map, f, xs));
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$warningToError = function (warning) {
	if (warning.$ === 'UnusedValue') {
		var v = warning.a;
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Failure,
			'Unused value',
			elm$core$Maybe$Just(v));
	} else {
		var w = warning.a;
		var v = warning.b;
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Failure,
			w,
			elm$core$Maybe$Just(v));
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map = F2(
	function (op, located) {
		switch (located.$) {
			case 'InField':
				var f = located.a;
				var val = located.b;
				return A2(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField,
					f,
					A2(
						mgold$elm_nonempty_list$List$Nonempty$map,
						zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map(op),
						val));
			case 'AtIndex':
				var i = located.a;
				var val = located.b;
				return A2(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex,
					i,
					A2(
						mgold$elm_nonempty_list$List$Nonempty$map,
						zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map(op),
						val));
			default:
				var v = located.a;
				return zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
					op(v));
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToErrors = mgold$elm_nonempty_list$List$Nonempty$map(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map(zwilias$json_decode_exploration$Json$Decode$Exploration$warningToError));
var zwilias$json_decode_exploration$Json$Decode$Exploration$strict = function (res) {
	switch (res.$) {
		case 'Errors':
			var e = res.a;
			return elm$core$Result$Err(e);
		case 'BadJson':
			return elm$core$Result$Err(
				mgold$elm_nonempty_list$List$Nonempty$fromElement(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
						A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Failure, 'Invalid JSON', elm$core$Maybe$Nothing))));
		case 'WithWarnings':
			var w = res.a;
			return elm$core$Result$Err(
				zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToErrors(w));
		default:
			var v = res.a;
			return elm$core$Result$Ok(v);
	}
};
var author$project$Porting$toClassic = function (decoder) {
	var runRealDecoder = function (value) {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue, decoder, value);
	};
	var convertToNormalResult = function (fancyResult) {
		return A2(elm$core$Result$mapError, zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString, fancyResult);
	};
	var asResult = function (value) {
		return zwilias$json_decode_exploration$Json$Decode$Exploration$strict(
			runRealDecoder(value));
	};
	var _final = function (value) {
		return convertToNormalResult(
			asResult(value));
	};
	return A2(
		elm$json$Json$Decode$andThen,
		A2(elm$core$Basics$composeL, elm_community$json_extra$Json$Decode$Extra$fromResult, _final),
		elm$json$Json$Decode$value);
};
var elm$core$Maybe$isJust = function (maybe) {
	if (maybe.$ === 'Just') {
		return true;
	} else {
		return false;
	}
};
var elm$core$Platform$sendToApp = _Platform_sendToApp;
var elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 'BadStatus_', a: a, b: b};
	});
var elm$http$Http$BadUrl_ = function (a) {
	return {$: 'BadUrl_', a: a};
};
var elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 'GoodStatus_', a: a, b: b};
	});
var elm$http$Http$NetworkError_ = {$: 'NetworkError_'};
var elm$http$Http$Receiving = function (a) {
	return {$: 'Receiving', a: a};
};
var elm$http$Http$Sending = function (a) {
	return {$: 'Sending', a: a};
};
var elm$http$Http$Timeout_ = {$: 'Timeout_'};
var elm$http$Http$expectStringResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'',
			elm$core$Basics$identity,
			A2(elm$core$Basics$composeR, toResult, toMsg));
	});
var elm$http$Http$BadBody = function (a) {
	return {$: 'BadBody', a: a};
};
var elm$http$Http$BadStatus = function (a) {
	return {$: 'BadStatus', a: a};
};
var elm$http$Http$BadUrl = function (a) {
	return {$: 'BadUrl', a: a};
};
var elm$http$Http$NetworkError = {$: 'NetworkError'};
var elm$http$Http$Timeout = {$: 'Timeout'};
var elm$http$Http$resolve = F2(
	function (toResult, response) {
		switch (response.$) {
			case 'BadUrl_':
				var url = response.a;
				return elm$core$Result$Err(
					elm$http$Http$BadUrl(url));
			case 'Timeout_':
				return elm$core$Result$Err(elm$http$Http$Timeout);
			case 'NetworkError_':
				return elm$core$Result$Err(elm$http$Http$NetworkError);
			case 'BadStatus_':
				var metadata = response.a;
				return elm$core$Result$Err(
					elm$http$Http$BadStatus(metadata.statusCode));
			default:
				var body = response.b;
				return A2(
					elm$core$Result$mapError,
					elm$http$Http$BadBody,
					toResult(body));
		}
	});
var elm$http$Http$expectJson = F2(
	function (toMsg, decoder) {
		return A2(
			elm$http$Http$expectStringResponse,
			toMsg,
			elm$http$Http$resolve(
				function (string) {
					return A2(
						elm$core$Result$mapError,
						elm$json$Json$Decode$errorToString,
						A2(elm$json$Json$Decode$decodeString, decoder, string));
				}));
	});
var elm$http$Http$emptyBody = _Http_emptyBody;
var elm$http$Http$Request = function (a) {
	return {$: 'Request', a: a};
};
var elm$core$Task$succeed = _Scheduler_succeed;
var elm$http$Http$State = F2(
	function (reqs, subs) {
		return {reqs: reqs, subs: subs};
	});
var elm$http$Http$init = elm$core$Task$succeed(
	A2(elm$http$Http$State, elm$core$Dict$empty, _List_Nil));
var elm$core$Task$andThen = _Scheduler_andThen;
var elm$core$Process$kill = _Scheduler_kill;
var elm$core$Process$spawn = _Scheduler_spawn;
var elm$http$Http$updateReqs = F3(
	function (router, cmds, reqs) {
		updateReqs:
		while (true) {
			if (!cmds.b) {
				return elm$core$Task$succeed(reqs);
			} else {
				var cmd = cmds.a;
				var otherCmds = cmds.b;
				if (cmd.$ === 'Cancel') {
					var tracker = cmd.a;
					var _n2 = A2(elm$core$Dict$get, tracker, reqs);
					if (_n2.$ === 'Nothing') {
						var $temp$router = router,
							$temp$cmds = otherCmds,
							$temp$reqs = reqs;
						router = $temp$router;
						cmds = $temp$cmds;
						reqs = $temp$reqs;
						continue updateReqs;
					} else {
						var pid = _n2.a;
						return A2(
							elm$core$Task$andThen,
							function (_n3) {
								return A3(
									elm$http$Http$updateReqs,
									router,
									otherCmds,
									A2(elm$core$Dict$remove, tracker, reqs));
							},
							elm$core$Process$kill(pid));
					}
				} else {
					var req = cmd.a;
					return A2(
						elm$core$Task$andThen,
						function (pid) {
							var _n4 = req.tracker;
							if (_n4.$ === 'Nothing') {
								return A3(elm$http$Http$updateReqs, router, otherCmds, reqs);
							} else {
								var tracker = _n4.a;
								return A3(
									elm$http$Http$updateReqs,
									router,
									otherCmds,
									A3(elm$core$Dict$insert, tracker, pid, reqs));
							}
						},
						elm$core$Process$spawn(
							A3(
								_Http_toTask,
								router,
								elm$core$Platform$sendToApp(router),
								req)));
				}
			}
		}
	});
var elm$http$Http$onEffects = F4(
	function (router, cmds, subs, state) {
		return A2(
			elm$core$Task$andThen,
			function (reqs) {
				return elm$core$Task$succeed(
					A2(elm$http$Http$State, reqs, subs));
			},
			A3(elm$http$Http$updateReqs, router, cmds, state.reqs));
	});
var elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			elm$core$Task$andThen,
			function (a) {
				return A2(
					elm$core$Task$andThen,
					function (b) {
						return elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var elm$core$Task$sequence = function (tasks) {
	return A3(
		elm$core$List$foldr,
		elm$core$Task$map2(elm$core$List$cons),
		elm$core$Task$succeed(_List_Nil),
		tasks);
};
var elm$http$Http$maybeSend = F4(
	function (router, desiredTracker, progress, _n0) {
		var actualTracker = _n0.a;
		var toMsg = _n0.b;
		return _Utils_eq(desiredTracker, actualTracker) ? elm$core$Maybe$Just(
			A2(
				elm$core$Platform$sendToApp,
				router,
				toMsg(progress))) : elm$core$Maybe$Nothing;
	});
var elm$http$Http$onSelfMsg = F3(
	function (router, _n0, state) {
		var tracker = _n0.a;
		var progress = _n0.b;
		return A2(
			elm$core$Task$andThen,
			function (_n1) {
				return elm$core$Task$succeed(state);
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$filterMap,
					A3(elm$http$Http$maybeSend, router, tracker, progress),
					state.subs)));
	});
var elm$http$Http$Cancel = function (a) {
	return {$: 'Cancel', a: a};
};
var elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (cmd.$ === 'Cancel') {
			var tracker = cmd.a;
			return elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return elm$http$Http$Request(
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
var elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 'MySub', a: a, b: b};
	});
var elm$http$Http$subMap = F2(
	function (func, _n0) {
		var tracker = _n0.a;
		var toMsg = _n0.b;
		return A2(
			elm$http$Http$MySub,
			tracker,
			A2(elm$core$Basics$composeR, toMsg, func));
	});
_Platform_effectManagers['Http'] = _Platform_createManager(elm$http$Http$init, elm$http$Http$onEffects, elm$http$Http$onSelfMsg, elm$http$Http$cmdMap, elm$http$Http$subMap);
var elm$http$Http$command = _Platform_leaf('Http');
var elm$http$Http$subscription = _Platform_leaf('Http');
var elm$http$Http$request = function (r) {
	return elm$http$Http$command(
		elm$http$Http$Request(
			{allowCookiesFromOtherDomains: false, body: r.body, expect: r.expect, headers: r.headers, method: r.method, timeout: r.timeout, tracker: r.tracker, url: r.url}));
};
var elm$http$Http$get = function (r) {
	return elm$http$Http$request(
		{body: elm$http$Http$emptyBody, expect: r.expect, headers: _List_Nil, method: 'GET', timeout: elm$core$Maybe$Nothing, tracker: elm$core$Maybe$Nothing, url: r.url});
};
var author$project$External$TodoistSync$sync = function (incrementalSyncToken) {
	return elm$http$Http$get(
		{
			expect: A2(
				elm$http$Http$expectJson,
				author$project$External$TodoistSync$SyncResponded,
				author$project$Porting$toClassic(author$project$External$TodoistSync$decodeResponse)),
			url: elm$url$Url$toString(
				author$project$External$TodoistSync$syncUrl(incrementalSyncToken))
		});
};
var author$project$Main$Model = F3(
	function (viewState, appData, environment) {
		return {appData: appData, environment: environment, viewState: viewState};
	});
var author$project$Main$SyncTodoist = {$: 'SyncTodoist'};
var author$project$Main$TaskListMsg = function (a) {
	return {$: 'TaskListMsg', a: a};
};
var author$project$Main$TimeTrackerMsg = function (a) {
	return {$: 'TimeTrackerMsg', a: a};
};
var author$project$Main$TodoistServerResponse = function (a) {
	return {$: 'TodoistServerResponse', a: a};
};
var author$project$Task$Progress$getWhole = function (_n0) {
	var unit = _n0.b;
	return author$project$Task$Progress$unitMax(unit);
};
var author$project$Task$Progress$isMax = function (progress) {
	return _Utils_eq(
		author$project$Task$Progress$getPortion(progress),
		author$project$Task$Progress$getWhole(progress));
};
var author$project$Task$Task$completed = function (task) {
	return author$project$Task$Progress$isMax(
		function ($) {
			return $.completion;
		}(task));
};
var author$project$TaskList$NoOp = {$: 'NoOp'};
var elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var elm$core$Basics$never = function (_n0) {
	never:
	while (true) {
		var nvr = _n0.a;
		var $temp$_n0 = nvr;
		_n0 = $temp$_n0;
		continue never;
	}
};
var elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var elm$core$Task$init = elm$core$Task$succeed(_Utils_Tuple0);
var elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			elm$core$Task$andThen,
			function (a) {
				return elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var elm$core$Task$spawnCmd = F2(
	function (router, _n0) {
		var task = _n0.a;
		return _Scheduler_spawn(
			A2(
				elm$core$Task$andThen,
				elm$core$Platform$sendToApp(router),
				task));
	});
var elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			elm$core$Task$map,
			function (_n0) {
				return _Utils_Tuple0;
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$map,
					elm$core$Task$spawnCmd(router),
					commands)));
	});
var elm$core$Task$onSelfMsg = F3(
	function (_n0, _n1, _n2) {
		return elm$core$Task$succeed(_Utils_Tuple0);
	});
var elm$core$Task$cmdMap = F2(
	function (tagger, _n0) {
		var task = _n0.a;
		return elm$core$Task$Perform(
			A2(elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager(elm$core$Task$init, elm$core$Task$onEffects, elm$core$Task$onSelfMsg, elm$core$Task$cmdMap);
var elm$core$Task$command = _Platform_leaf('Task');
var elm$core$Task$perform = F2(
	function (toMessage, task) {
		return elm$core$Task$command(
			elm$core$Task$Perform(
				A2(elm$core$Task$map, toMessage, task)));
	});
var elm$browser$Debugger$Expando$ArraySeq = {$: 'ArraySeq'};
var elm$browser$Debugger$Expando$Constructor = F3(
	function (a, b, c) {
		return {$: 'Constructor', a: a, b: b, c: c};
	});
var elm$browser$Debugger$Expando$Dictionary = F2(
	function (a, b) {
		return {$: 'Dictionary', a: a, b: b};
	});
var elm$browser$Debugger$Expando$ListSeq = {$: 'ListSeq'};
var elm$browser$Debugger$Expando$Primitive = function (a) {
	return {$: 'Primitive', a: a};
};
var elm$browser$Debugger$Expando$Record = F2(
	function (a, b) {
		return {$: 'Record', a: a, b: b};
	});
var elm$browser$Debugger$Expando$S = function (a) {
	return {$: 'S', a: a};
};
var elm$browser$Debugger$Expando$Sequence = F3(
	function (a, b, c) {
		return {$: 'Sequence', a: a, b: b, c: c};
	});
var elm$browser$Debugger$Expando$SetSeq = {$: 'SetSeq'};
var elm$browser$Debugger$Main$Down = {$: 'Down'};
var elm$browser$Debugger$Main$NoOp = {$: 'NoOp'};
var elm$browser$Debugger$Main$Up = {$: 'Up'};
var elm$browser$Debugger$Main$UserMsg = function (a) {
	return {$: 'UserMsg', a: a};
};
var elm$browser$Debugger$History$size = function (history) {
	return history.numMessages;
};
var elm$browser$Debugger$Main$Export = {$: 'Export'};
var elm$browser$Debugger$Main$Import = {$: 'Import'};
var elm$browser$Debugger$Main$Open = {$: 'Open'};
var elm$browser$Debugger$Main$OverlayMsg = function (a) {
	return {$: 'OverlayMsg', a: a};
};
var elm$browser$Debugger$Main$Resume = {$: 'Resume'};
var elm$browser$Debugger$Main$isPaused = function (state) {
	if (state.$ === 'Running') {
		return false;
	} else {
		return true;
	}
};
var elm$browser$Debugger$Overlay$Accept = function (a) {
	return {$: 'Accept', a: a};
};
var elm$browser$Debugger$Overlay$Choose = F2(
	function (a, b) {
		return {$: 'Choose', a: a, b: b};
	});
var elm$browser$Debugger$Overlay$goodNews1 = '\nThe good news is that having values like this in your message type is not\nso great in the long run. You are better off using simpler data, like\n';
var elm$browser$Debugger$Overlay$goodNews2 = '\nfunction can pattern match on that data and call whatever functions, JSON\ndecoders, etc. you need. This makes the code much more explicit and easy to\nfollow for other readers (or you in a few months!)\n';
var elm$json$Json$Decode$map2 = _Json_map2;
var elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
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
var elm$html$Html$code = _VirtualDom_node('code');
var elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var elm$html$Html$text = elm$virtual_dom$VirtualDom$text;
var elm$browser$Debugger$Overlay$viewCode = function (name) {
	return A2(
		elm$html$Html$code,
		_List_Nil,
		_List_fromArray(
			[
				elm$html$Html$text(name)
			]));
};
var elm$browser$Debugger$Overlay$addCommas = function (items) {
	if (!items.b) {
		return '';
	} else {
		if (!items.b.b) {
			var item = items.a;
			return item;
		} else {
			if (!items.b.b.b) {
				var item1 = items.a;
				var _n1 = items.b;
				var item2 = _n1.a;
				return item1 + (' and ' + item2);
			} else {
				var lastItem = items.a;
				var otherItems = items.b;
				return A2(
					elm$core$String$join,
					', ',
					_Utils_ap(
						otherItems,
						_List_fromArray(
							[' and ' + lastItem])));
			}
		}
	}
};
var elm$browser$Debugger$Overlay$problemToString = function (problem) {
	switch (problem.$) {
		case 'Function':
			return 'functions';
		case 'Decoder':
			return 'JSON decoders';
		case 'Task':
			return 'tasks';
		case 'Process':
			return 'processes';
		case 'Socket':
			return 'web sockets';
		case 'Request':
			return 'HTTP requests';
		case 'Program':
			return 'programs';
		default:
			return 'virtual DOM values';
	}
};
var elm$html$Html$li = _VirtualDom_node('li');
var elm$browser$Debugger$Overlay$viewProblemType = function (_n0) {
	var name = _n0.name;
	var problems = _n0.problems;
	return A2(
		elm$html$Html$li,
		_List_Nil,
		_List_fromArray(
			[
				elm$browser$Debugger$Overlay$viewCode(name),
				elm$html$Html$text(
				' can contain ' + (elm$browser$Debugger$Overlay$addCommas(
					A2(elm$core$List$map, elm$browser$Debugger$Overlay$problemToString, problems)) + '.'))
			]));
};
var elm$html$Html$a = _VirtualDom_node('a');
var elm$html$Html$p = _VirtualDom_node('p');
var elm$html$Html$ul = _VirtualDom_node('ul');
var elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			elm$json$Json$Encode$string(string));
	});
var elm$html$Html$Attributes$href = function (url) {
	return A2(
		elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var elm$browser$Debugger$Overlay$viewBadMetadata = function (_n0) {
	var message = _n0.message;
	var problems = _n0.problems;
	return _List_fromArray(
		[
			A2(
			elm$html$Html$p,
			_List_Nil,
			_List_fromArray(
				[
					elm$html$Html$text('The '),
					elm$browser$Debugger$Overlay$viewCode(message),
					elm$html$Html$text(' type of your program cannot be reliably serialized for history files.')
				])),
			A2(
			elm$html$Html$p,
			_List_Nil,
			_List_fromArray(
				[
					elm$html$Html$text('Functions cannot be serialized, nor can values that contain functions. This is a problem in these places:')
				])),
			A2(
			elm$html$Html$ul,
			_List_Nil,
			A2(elm$core$List$map, elm$browser$Debugger$Overlay$viewProblemType, problems)),
			A2(
			elm$html$Html$p,
			_List_Nil,
			_List_fromArray(
				[
					elm$html$Html$text(elm$browser$Debugger$Overlay$goodNews1),
					A2(
					elm$html$Html$a,
					_List_fromArray(
						[
							elm$html$Html$Attributes$href('https://guide.elm-lang.org/types/union_types.html')
						]),
					_List_fromArray(
						[
							elm$html$Html$text('union types')
						])),
					elm$html$Html$text(', in your messages. From there, your '),
					elm$browser$Debugger$Overlay$viewCode('update'),
					elm$html$Html$text(elm$browser$Debugger$Overlay$goodNews2)
				]))
		]);
};
var elm$browser$Debugger$Overlay$Cancel = {$: 'Cancel'};
var elm$browser$Debugger$Overlay$Proceed = {$: 'Proceed'};
var elm$html$Html$button = _VirtualDom_node('button');
var elm$html$Html$div = _VirtualDom_node('div');
var elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var elm$html$Html$Attributes$style = elm$virtual_dom$VirtualDom$style;
var elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 'Normal', a: a};
};
var elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			elm$virtual_dom$VirtualDom$on,
			event,
			elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var elm$html$Html$Events$onClick = function (msg) {
	return A2(
		elm$html$Html$Events$on,
		'click',
		elm$json$Json$Decode$succeed(msg));
};
var elm$browser$Debugger$Overlay$viewButtons = function (buttons) {
	var btn = F2(
		function (msg, string) {
			return A2(
				elm$html$Html$button,
				_List_fromArray(
					[
						A2(elm$html$Html$Attributes$style, 'margin-right', '20px'),
						elm$html$Html$Events$onClick(msg)
					]),
				_List_fromArray(
					[
						elm$html$Html$text(string)
					]));
		});
	var buttonNodes = function () {
		if (buttons.$ === 'Accept') {
			var proceed = buttons.a;
			return _List_fromArray(
				[
					A2(btn, elm$browser$Debugger$Overlay$Proceed, proceed)
				]);
		} else {
			var cancel = buttons.a;
			var proceed = buttons.b;
			return _List_fromArray(
				[
					A2(btn, elm$browser$Debugger$Overlay$Cancel, cancel),
					A2(btn, elm$browser$Debugger$Overlay$Proceed, proceed)
				]);
		}
	}();
	return A2(
		elm$html$Html$div,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'height', '60px'),
				A2(elm$html$Html$Attributes$style, 'line-height', '60px'),
				A2(elm$html$Html$Attributes$style, 'text-align', 'right'),
				A2(elm$html$Html$Attributes$style, 'background-color', 'rgb(50, 50, 50)')
			]),
		buttonNodes);
};
var elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var elm$html$Html$map = elm$virtual_dom$VirtualDom$map;
var elm$html$Html$Attributes$id = elm$html$Html$Attributes$stringProperty('id');
var elm$browser$Debugger$Overlay$viewMessage = F4(
	function (config, title, details, buttons) {
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					elm$html$Html$Attributes$id('elm-debugger-overlay'),
					A2(elm$html$Html$Attributes$style, 'position', 'fixed'),
					A2(elm$html$Html$Attributes$style, 'top', '0'),
					A2(elm$html$Html$Attributes$style, 'left', '0'),
					A2(elm$html$Html$Attributes$style, 'width', '100%'),
					A2(elm$html$Html$Attributes$style, 'height', '100%'),
					A2(elm$html$Html$Attributes$style, 'color', 'white'),
					A2(elm$html$Html$Attributes$style, 'pointer-events', 'none'),
					A2(elm$html$Html$Attributes$style, 'font-family', '\'Trebuchet MS\', \'Lucida Grande\', \'Bitstream Vera Sans\', \'Helvetica Neue\', sans-serif'),
					A2(elm$html$Html$Attributes$style, 'z-index', '2147483647')
				]),
			_List_fromArray(
				[
					A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							A2(elm$html$Html$Attributes$style, 'position', 'absolute'),
							A2(elm$html$Html$Attributes$style, 'width', '600px'),
							A2(elm$html$Html$Attributes$style, 'height', '100%'),
							A2(elm$html$Html$Attributes$style, 'padding-left', 'calc(50% - 300px)'),
							A2(elm$html$Html$Attributes$style, 'padding-right', 'calc(50% - 300px)'),
							A2(elm$html$Html$Attributes$style, 'background-color', 'rgba(200, 200, 200, 0.7)'),
							A2(elm$html$Html$Attributes$style, 'pointer-events', 'auto')
						]),
					_List_fromArray(
						[
							A2(
							elm$html$Html$div,
							_List_fromArray(
								[
									A2(elm$html$Html$Attributes$style, 'font-size', '36px'),
									A2(elm$html$Html$Attributes$style, 'height', '80px'),
									A2(elm$html$Html$Attributes$style, 'background-color', 'rgb(50, 50, 50)'),
									A2(elm$html$Html$Attributes$style, 'padding-left', '22px'),
									A2(elm$html$Html$Attributes$style, 'vertical-align', 'middle'),
									A2(elm$html$Html$Attributes$style, 'line-height', '80px')
								]),
							_List_fromArray(
								[
									elm$html$Html$text(title)
								])),
							A2(
							elm$html$Html$div,
							_List_fromArray(
								[
									elm$html$Html$Attributes$id('elm-debugger-details'),
									A2(elm$html$Html$Attributes$style, 'padding', ' 8px 20px'),
									A2(elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
									A2(elm$html$Html$Attributes$style, 'max-height', 'calc(100% - 156px)'),
									A2(elm$html$Html$Attributes$style, 'background-color', 'rgb(61, 61, 61)')
								]),
							details),
							A2(
							elm$html$Html$map,
							config.wrap,
							elm$browser$Debugger$Overlay$viewButtons(buttons))
						]))
				]));
	});
var elm$html$Html$span = _VirtualDom_node('span');
var elm$browser$Debugger$Overlay$button = F2(
	function (msg, label) {
		return A2(
			elm$html$Html$span,
			_List_fromArray(
				[
					elm$html$Html$Events$onClick(msg),
					A2(elm$html$Html$Attributes$style, 'cursor', 'pointer')
				]),
			_List_fromArray(
				[
					elm$html$Html$text(label)
				]));
	});
var elm$browser$Debugger$Overlay$viewImportExport = F3(
	function (props, importMsg, exportMsg) {
		return A2(
			elm$html$Html$div,
			props,
			_List_fromArray(
				[
					A2(elm$browser$Debugger$Overlay$button, importMsg, 'Import'),
					elm$html$Html$text(' / '),
					A2(elm$browser$Debugger$Overlay$button, exportMsg, 'Export')
				]));
	});
var elm$browser$Debugger$Overlay$viewMiniControls = F2(
	function (config, numMsgs) {
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					A2(elm$html$Html$Attributes$style, 'position', 'fixed'),
					A2(elm$html$Html$Attributes$style, 'bottom', '0'),
					A2(elm$html$Html$Attributes$style, 'right', '6px'),
					A2(elm$html$Html$Attributes$style, 'border-radius', '4px'),
					A2(elm$html$Html$Attributes$style, 'background-color', 'rgb(61, 61, 61)'),
					A2(elm$html$Html$Attributes$style, 'color', 'white'),
					A2(elm$html$Html$Attributes$style, 'font-family', 'monospace'),
					A2(elm$html$Html$Attributes$style, 'pointer-events', 'auto'),
					A2(elm$html$Html$Attributes$style, 'z-index', '2147483647')
				]),
			_List_fromArray(
				[
					A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							A2(elm$html$Html$Attributes$style, 'padding', '6px'),
							A2(elm$html$Html$Attributes$style, 'cursor', 'pointer'),
							A2(elm$html$Html$Attributes$style, 'text-align', 'center'),
							A2(elm$html$Html$Attributes$style, 'min-width', '24ch'),
							elm$html$Html$Events$onClick(config.open)
						]),
					_List_fromArray(
						[
							elm$html$Html$text(
							'Explore History (' + (elm$core$String$fromInt(numMsgs) + ')'))
						])),
					A3(
					elm$browser$Debugger$Overlay$viewImportExport,
					_List_fromArray(
						[
							A2(elm$html$Html$Attributes$style, 'padding', '4px 0'),
							A2(elm$html$Html$Attributes$style, 'font-size', '0.8em'),
							A2(elm$html$Html$Attributes$style, 'text-align', 'center'),
							A2(elm$html$Html$Attributes$style, 'background-color', 'rgb(50, 50, 50)')
						]),
					config.importHistory,
					config.exportHistory)
				]));
	});
var elm$browser$Debugger$Overlay$explanationBad = '\nThe messages in this history do not match the messages handled by your\nprogram. I noticed changes in the following types:\n';
var elm$browser$Debugger$Overlay$explanationRisky = '\nThis history seems old. It will work with this program, but some\nmessages have been added since the history was created:\n';
var elm$browser$Debugger$Overlay$viewMention = F2(
	function (tags, verbed) {
		var _n0 = A2(
			elm$core$List$map,
			elm$browser$Debugger$Overlay$viewCode,
			elm$core$List$reverse(tags));
		if (!_n0.b) {
			return elm$html$Html$text('');
		} else {
			if (!_n0.b.b) {
				var tag = _n0.a;
				return A2(
					elm$html$Html$li,
					_List_Nil,
					_List_fromArray(
						[
							elm$html$Html$text(verbed),
							tag,
							elm$html$Html$text('.')
						]));
			} else {
				if (!_n0.b.b.b) {
					var tag2 = _n0.a;
					var _n1 = _n0.b;
					var tag1 = _n1.a;
					return A2(
						elm$html$Html$li,
						_List_Nil,
						_List_fromArray(
							[
								elm$html$Html$text(verbed),
								tag1,
								elm$html$Html$text(' and '),
								tag2,
								elm$html$Html$text('.')
							]));
				} else {
					var lastTag = _n0.a;
					var otherTags = _n0.b;
					return A2(
						elm$html$Html$li,
						_List_Nil,
						A2(
							elm$core$List$cons,
							elm$html$Html$text(verbed),
							_Utils_ap(
								A2(
									elm$core$List$intersperse,
									elm$html$Html$text(', '),
									elm$core$List$reverse(otherTags)),
								_List_fromArray(
									[
										elm$html$Html$text(', and '),
										lastTag,
										elm$html$Html$text('.')
									]))));
				}
			}
		}
	});
var elm$browser$Debugger$Overlay$viewChange = function (change) {
	return A2(
		elm$html$Html$li,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'margin', '8px 0')
			]),
		function () {
			if (change.$ === 'AliasChange') {
				var name = change.a;
				return _List_fromArray(
					[
						A2(
						elm$html$Html$span,
						_List_fromArray(
							[
								A2(elm$html$Html$Attributes$style, 'font-size', '1.5em')
							]),
						_List_fromArray(
							[
								elm$browser$Debugger$Overlay$viewCode(name)
							]))
					]);
			} else {
				var name = change.a;
				var removed = change.b.removed;
				var changed = change.b.changed;
				var added = change.b.added;
				var argsMatch = change.b.argsMatch;
				return _List_fromArray(
					[
						A2(
						elm$html$Html$span,
						_List_fromArray(
							[
								A2(elm$html$Html$Attributes$style, 'font-size', '1.5em')
							]),
						_List_fromArray(
							[
								elm$browser$Debugger$Overlay$viewCode(name)
							])),
						A2(
						elm$html$Html$ul,
						_List_fromArray(
							[
								A2(elm$html$Html$Attributes$style, 'list-style-type', 'disc'),
								A2(elm$html$Html$Attributes$style, 'padding-left', '2em')
							]),
						_List_fromArray(
							[
								A2(elm$browser$Debugger$Overlay$viewMention, removed, 'Removed '),
								A2(elm$browser$Debugger$Overlay$viewMention, changed, 'Changed '),
								A2(elm$browser$Debugger$Overlay$viewMention, added, 'Added ')
							])),
						argsMatch ? elm$html$Html$text('') : elm$html$Html$text('This may be due to the fact that the type variable names changed.')
					]);
			}
		}());
};
var elm$browser$Debugger$Overlay$viewReport = F2(
	function (isBad, report) {
		switch (report.$) {
			case 'CorruptHistory':
				return _List_fromArray(
					[
						elm$html$Html$text('Looks like this history file is corrupt. I cannot understand it.')
					]);
			case 'VersionChanged':
				var old = report.a;
				var _new = report.b;
				return _List_fromArray(
					[
						elm$html$Html$text('This history was created with Elm ' + (old + (', but you are using Elm ' + (_new + ' right now.'))))
					]);
			case 'MessageChanged':
				var old = report.a;
				var _new = report.b;
				return _List_fromArray(
					[
						elm$html$Html$text('To import some other history, the overall message type must' + ' be the same. The old history has '),
						elm$browser$Debugger$Overlay$viewCode(old),
						elm$html$Html$text(' messages, but the new program works with '),
						elm$browser$Debugger$Overlay$viewCode(_new),
						elm$html$Html$text(' messages.')
					]);
			default:
				var changes = report.a;
				return _List_fromArray(
					[
						A2(
						elm$html$Html$p,
						_List_Nil,
						_List_fromArray(
							[
								elm$html$Html$text(
								isBad ? elm$browser$Debugger$Overlay$explanationBad : elm$browser$Debugger$Overlay$explanationRisky)
							])),
						A2(
						elm$html$Html$ul,
						_List_fromArray(
							[
								A2(elm$html$Html$Attributes$style, 'list-style-type', 'none'),
								A2(elm$html$Html$Attributes$style, 'padding-left', '20px')
							]),
						A2(elm$core$List$map, elm$browser$Debugger$Overlay$viewChange, changes))
					]);
		}
	});
var elm$browser$Debugger$Overlay$view = F5(
	function (config, isPaused, isOpen, numMsgs, state) {
		switch (state.$) {
			case 'None':
				return isOpen ? elm$html$Html$text('') : (isPaused ? A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							A2(elm$html$Html$Attributes$style, 'width', '100%'),
							A2(elm$html$Html$Attributes$style, 'height', '100%'),
							A2(elm$html$Html$Attributes$style, 'cursor', 'pointer'),
							A2(elm$html$Html$Attributes$style, 'text-align', 'center'),
							A2(elm$html$Html$Attributes$style, 'pointer-events', 'auto'),
							A2(elm$html$Html$Attributes$style, 'background-color', 'rgba(200, 200, 200, 0.7)'),
							A2(elm$html$Html$Attributes$style, 'color', 'white'),
							A2(elm$html$Html$Attributes$style, 'font-family', '\'Trebuchet MS\', \'Lucida Grande\', \'Bitstream Vera Sans\', \'Helvetica Neue\', sans-serif'),
							A2(elm$html$Html$Attributes$style, 'z-index', '2147483646'),
							elm$html$Html$Events$onClick(config.resume)
						]),
					_List_fromArray(
						[
							A2(
							elm$html$Html$div,
							_List_fromArray(
								[
									A2(elm$html$Html$Attributes$style, 'position', 'absolute'),
									A2(elm$html$Html$Attributes$style, 'top', 'calc(50% - 40px)'),
									A2(elm$html$Html$Attributes$style, 'font-size', '80px'),
									A2(elm$html$Html$Attributes$style, 'line-height', '80px'),
									A2(elm$html$Html$Attributes$style, 'height', '80px'),
									A2(elm$html$Html$Attributes$style, 'width', '100%')
								]),
							_List_fromArray(
								[
									elm$html$Html$text('Click to Resume')
								])),
							A2(elm$browser$Debugger$Overlay$viewMiniControls, config, numMsgs)
						])) : A2(elm$browser$Debugger$Overlay$viewMiniControls, config, numMsgs));
			case 'BadMetadata':
				var badMetadata_ = state.a;
				return A4(
					elm$browser$Debugger$Overlay$viewMessage,
					config,
					'Cannot use Import or Export',
					elm$browser$Debugger$Overlay$viewBadMetadata(badMetadata_),
					elm$browser$Debugger$Overlay$Accept('Ok'));
			case 'BadImport':
				var report = state.a;
				return A4(
					elm$browser$Debugger$Overlay$viewMessage,
					config,
					'Cannot Import History',
					A2(elm$browser$Debugger$Overlay$viewReport, true, report),
					elm$browser$Debugger$Overlay$Accept('Ok'));
			default:
				var report = state.a;
				return A4(
					elm$browser$Debugger$Overlay$viewMessage,
					config,
					'Warning',
					A2(elm$browser$Debugger$Overlay$viewReport, false, report),
					A2(elm$browser$Debugger$Overlay$Choose, 'Cancel', 'Import Anyway'));
		}
	});
var elm$browser$Debugger$Main$cornerView = function (model) {
	return A5(
		elm$browser$Debugger$Overlay$view,
		{exportHistory: elm$browser$Debugger$Main$Export, importHistory: elm$browser$Debugger$Main$Import, open: elm$browser$Debugger$Main$Open, resume: elm$browser$Debugger$Main$Resume, wrap: elm$browser$Debugger$Main$OverlayMsg},
		elm$browser$Debugger$Main$isPaused(model.state),
		_Debugger_isOpen(model.popout),
		elm$browser$Debugger$History$size(model.history),
		model.overlay);
};
var elm$browser$Debugger$Main$getCurrentModel = function (state) {
	if (state.$ === 'Running') {
		var model = state.a;
		return model;
	} else {
		var model = state.b;
		return model;
	}
};
var elm$browser$Debugger$Main$getUserModel = function (model) {
	return elm$browser$Debugger$Main$getCurrentModel(model.state);
};
var elm$browser$Debugger$Expando$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var elm$browser$Debugger$Expando$Index = F3(
	function (a, b, c) {
		return {$: 'Index', a: a, b: b, c: c};
	});
var elm$browser$Debugger$Expando$Key = {$: 'Key'};
var elm$browser$Debugger$Expando$None = {$: 'None'};
var elm$browser$Debugger$Expando$Toggle = {$: 'Toggle'};
var elm$browser$Debugger$Expando$Value = {$: 'Value'};
var elm$browser$Debugger$Expando$blue = A2(elm$html$Html$Attributes$style, 'color', 'rgb(28, 0, 207)');
var elm$browser$Debugger$Expando$leftPad = function (maybeKey) {
	if (maybeKey.$ === 'Nothing') {
		return _List_Nil;
	} else {
		return _List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'padding-left', '4ch')
			]);
	}
};
var elm$browser$Debugger$Expando$makeArrow = function (arrow) {
	return A2(
		elm$html$Html$span,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'color', '#777'),
				A2(elm$html$Html$Attributes$style, 'padding-left', '2ch'),
				A2(elm$html$Html$Attributes$style, 'width', '2ch'),
				A2(elm$html$Html$Attributes$style, 'display', 'inline-block')
			]),
		_List_fromArray(
			[
				elm$html$Html$text(arrow)
			]));
};
var elm$browser$Debugger$Expando$purple = A2(elm$html$Html$Attributes$style, 'color', 'rgb(136, 19, 145)');
var elm$browser$Debugger$Expando$lineStarter = F3(
	function (maybeKey, maybeIsClosed, description) {
		var arrow = function () {
			if (maybeIsClosed.$ === 'Nothing') {
				return elm$browser$Debugger$Expando$makeArrow('');
			} else {
				if (maybeIsClosed.a) {
					return elm$browser$Debugger$Expando$makeArrow('▸');
				} else {
					return elm$browser$Debugger$Expando$makeArrow('▾');
				}
			}
		}();
		if (maybeKey.$ === 'Nothing') {
			return A2(elm$core$List$cons, arrow, description);
		} else {
			var key = maybeKey.a;
			return A2(
				elm$core$List$cons,
				arrow,
				A2(
					elm$core$List$cons,
					A2(
						elm$html$Html$span,
						_List_fromArray(
							[elm$browser$Debugger$Expando$purple]),
						_List_fromArray(
							[
								elm$html$Html$text(key)
							])),
					A2(
						elm$core$List$cons,
						elm$html$Html$text(' = '),
						description)));
		}
	});
var elm$browser$Debugger$Expando$red = A2(elm$html$Html$Attributes$style, 'color', 'rgb(196, 26, 22)');
var elm$browser$Debugger$Expando$seqTypeToString = F2(
	function (n, seqType) {
		switch (seqType.$) {
			case 'ListSeq':
				return 'List(' + (elm$core$String$fromInt(n) + ')');
			case 'SetSeq':
				return 'Set(' + (elm$core$String$fromInt(n) + ')');
			default:
				return 'Array(' + (elm$core$String$fromInt(n) + ')');
		}
	});
var elm$core$String$right = F2(
	function (n, string) {
		return (n < 1) ? '' : A3(
			elm$core$String$slice,
			-n,
			elm$core$String$length(string),
			string);
	});
var elm$browser$Debugger$Expando$elideMiddle = function (str) {
	return (elm$core$String$length(str) <= 18) ? str : (A2(elm$core$String$left, 8, str) + ('...' + A2(elm$core$String$right, 8, str)));
};
var elm$browser$Debugger$Expando$viewExtraTinyRecord = F3(
	function (length, starter, entries) {
		if (!entries.b) {
			return _Utils_Tuple2(
				length + 1,
				_List_fromArray(
					[
						elm$html$Html$text('}')
					]));
		} else {
			var field = entries.a;
			var rest = entries.b;
			var nextLength = (length + elm$core$String$length(field)) + 1;
			if (nextLength > 18) {
				return _Utils_Tuple2(
					length + 2,
					_List_fromArray(
						[
							elm$html$Html$text('…}')
						]));
			} else {
				var _n1 = A3(elm$browser$Debugger$Expando$viewExtraTinyRecord, nextLength, ',', rest);
				var finalLength = _n1.a;
				var otherHtmls = _n1.b;
				return _Utils_Tuple2(
					finalLength,
					A2(
						elm$core$List$cons,
						elm$html$Html$text(starter),
						A2(
							elm$core$List$cons,
							A2(
								elm$html$Html$span,
								_List_fromArray(
									[elm$browser$Debugger$Expando$purple]),
								_List_fromArray(
									[
										elm$html$Html$text(field)
									])),
							otherHtmls)));
			}
		}
	});
var elm$browser$Debugger$Expando$viewTinyHelp = function (str) {
	return _Utils_Tuple2(
		elm$core$String$length(str),
		_List_fromArray(
			[
				elm$html$Html$text(str)
			]));
};
var elm$core$Dict$isEmpty = function (dict) {
	if (dict.$ === 'RBEmpty_elm_builtin') {
		return true;
	} else {
		return false;
	}
};
var elm$browser$Debugger$Expando$viewExtraTiny = function (value) {
	if (value.$ === 'Record') {
		var record = value.b;
		return A3(
			elm$browser$Debugger$Expando$viewExtraTinyRecord,
			0,
			'{',
			elm$core$Dict$keys(record));
	} else {
		return elm$browser$Debugger$Expando$viewTiny(value);
	}
};
var elm$browser$Debugger$Expando$viewTiny = function (value) {
	switch (value.$) {
		case 'S':
			var stringRep = value.a;
			var str = elm$browser$Debugger$Expando$elideMiddle(stringRep);
			return _Utils_Tuple2(
				elm$core$String$length(str),
				_List_fromArray(
					[
						A2(
						elm$html$Html$span,
						_List_fromArray(
							[elm$browser$Debugger$Expando$red]),
						_List_fromArray(
							[
								elm$html$Html$text(str)
							]))
					]));
		case 'Primitive':
			var stringRep = value.a;
			return _Utils_Tuple2(
				elm$core$String$length(stringRep),
				_List_fromArray(
					[
						A2(
						elm$html$Html$span,
						_List_fromArray(
							[elm$browser$Debugger$Expando$blue]),
						_List_fromArray(
							[
								elm$html$Html$text(stringRep)
							]))
					]));
		case 'Sequence':
			var seqType = value.a;
			var valueList = value.c;
			return elm$browser$Debugger$Expando$viewTinyHelp(
				A2(
					elm$browser$Debugger$Expando$seqTypeToString,
					elm$core$List$length(valueList),
					seqType));
		case 'Dictionary':
			var keyValuePairs = value.b;
			return elm$browser$Debugger$Expando$viewTinyHelp(
				'Dict(' + (elm$core$String$fromInt(
					elm$core$List$length(keyValuePairs)) + ')'));
		case 'Record':
			var record = value.b;
			return elm$browser$Debugger$Expando$viewTinyRecord(record);
		default:
			if (!value.c.b) {
				var maybeName = value.a;
				return elm$browser$Debugger$Expando$viewTinyHelp(
					A2(elm$core$Maybe$withDefault, 'Unit', maybeName));
			} else {
				var maybeName = value.a;
				var valueList = value.c;
				return elm$browser$Debugger$Expando$viewTinyHelp(
					function () {
						if (maybeName.$ === 'Nothing') {
							return 'Tuple(' + (elm$core$String$fromInt(
								elm$core$List$length(valueList)) + ')');
						} else {
							var name = maybeName.a;
							return name + ' …';
						}
					}());
			}
	}
};
var elm$browser$Debugger$Expando$viewTinyRecord = function (record) {
	return elm$core$Dict$isEmpty(record) ? _Utils_Tuple2(
		2,
		_List_fromArray(
			[
				elm$html$Html$text('{}')
			])) : A3(
		elm$browser$Debugger$Expando$viewTinyRecordHelp,
		0,
		'{ ',
		elm$core$Dict$toList(record));
};
var elm$browser$Debugger$Expando$viewTinyRecordHelp = F3(
	function (length, starter, entries) {
		if (!entries.b) {
			return _Utils_Tuple2(
				length + 2,
				_List_fromArray(
					[
						elm$html$Html$text(' }')
					]));
		} else {
			var _n1 = entries.a;
			var field = _n1.a;
			var value = _n1.b;
			var rest = entries.b;
			var fieldLen = elm$core$String$length(field);
			var _n2 = elm$browser$Debugger$Expando$viewExtraTiny(value);
			var valueLen = _n2.a;
			var valueHtmls = _n2.b;
			var newLength = ((length + fieldLen) + valueLen) + 5;
			if (newLength > 60) {
				return _Utils_Tuple2(
					length + 4,
					_List_fromArray(
						[
							elm$html$Html$text(', … }')
						]));
			} else {
				var _n3 = A3(elm$browser$Debugger$Expando$viewTinyRecordHelp, newLength, ', ', rest);
				var finalLength = _n3.a;
				var otherHtmls = _n3.b;
				return _Utils_Tuple2(
					finalLength,
					A2(
						elm$core$List$cons,
						elm$html$Html$text(starter),
						A2(
							elm$core$List$cons,
							A2(
								elm$html$Html$span,
								_List_fromArray(
									[elm$browser$Debugger$Expando$purple]),
								_List_fromArray(
									[
										elm$html$Html$text(field)
									])),
							A2(
								elm$core$List$cons,
								elm$html$Html$text(' = '),
								A2(
									elm$core$List$cons,
									A2(elm$html$Html$span, _List_Nil, valueHtmls),
									otherHtmls)))));
			}
		}
	});
var elm$browser$Debugger$Expando$view = F2(
	function (maybeKey, expando) {
		switch (expando.$) {
			case 'S':
				var stringRep = expando.a;
				return A2(
					elm$html$Html$div,
					elm$browser$Debugger$Expando$leftPad(maybeKey),
					A3(
						elm$browser$Debugger$Expando$lineStarter,
						maybeKey,
						elm$core$Maybe$Nothing,
						_List_fromArray(
							[
								A2(
								elm$html$Html$span,
								_List_fromArray(
									[elm$browser$Debugger$Expando$red]),
								_List_fromArray(
									[
										elm$html$Html$text(stringRep)
									]))
							])));
			case 'Primitive':
				var stringRep = expando.a;
				return A2(
					elm$html$Html$div,
					elm$browser$Debugger$Expando$leftPad(maybeKey),
					A3(
						elm$browser$Debugger$Expando$lineStarter,
						maybeKey,
						elm$core$Maybe$Nothing,
						_List_fromArray(
							[
								A2(
								elm$html$Html$span,
								_List_fromArray(
									[elm$browser$Debugger$Expando$blue]),
								_List_fromArray(
									[
										elm$html$Html$text(stringRep)
									]))
							])));
			case 'Sequence':
				var seqType = expando.a;
				var isClosed = expando.b;
				var valueList = expando.c;
				return A4(elm$browser$Debugger$Expando$viewSequence, maybeKey, seqType, isClosed, valueList);
			case 'Dictionary':
				var isClosed = expando.a;
				var keyValuePairs = expando.b;
				return A3(elm$browser$Debugger$Expando$viewDictionary, maybeKey, isClosed, keyValuePairs);
			case 'Record':
				var isClosed = expando.a;
				var valueDict = expando.b;
				return A3(elm$browser$Debugger$Expando$viewRecord, maybeKey, isClosed, valueDict);
			default:
				var maybeName = expando.a;
				var isClosed = expando.b;
				var valueList = expando.c;
				return A4(elm$browser$Debugger$Expando$viewConstructor, maybeKey, maybeName, isClosed, valueList);
		}
	});
var elm$browser$Debugger$Expando$viewConstructor = F4(
	function (maybeKey, maybeName, isClosed, valueList) {
		var tinyArgs = A2(
			elm$core$List$map,
			A2(elm$core$Basics$composeL, elm$core$Tuple$second, elm$browser$Debugger$Expando$viewExtraTiny),
			valueList);
		var description = function () {
			var _n7 = _Utils_Tuple2(maybeName, tinyArgs);
			if (_n7.a.$ === 'Nothing') {
				if (!_n7.b.b) {
					var _n8 = _n7.a;
					return _List_fromArray(
						[
							elm$html$Html$text('()')
						]);
				} else {
					var _n9 = _n7.a;
					var _n10 = _n7.b;
					var x = _n10.a;
					var xs = _n10.b;
					return A2(
						elm$core$List$cons,
						elm$html$Html$text('( '),
						A2(
							elm$core$List$cons,
							A2(elm$html$Html$span, _List_Nil, x),
							A3(
								elm$core$List$foldr,
								F2(
									function (args, rest) {
										return A2(
											elm$core$List$cons,
											elm$html$Html$text(', '),
											A2(
												elm$core$List$cons,
												A2(elm$html$Html$span, _List_Nil, args),
												rest));
									}),
								_List_fromArray(
									[
										elm$html$Html$text(' )')
									]),
								xs)));
				}
			} else {
				if (!_n7.b.b) {
					var name = _n7.a.a;
					return _List_fromArray(
						[
							elm$html$Html$text(name)
						]);
				} else {
					var name = _n7.a.a;
					var _n11 = _n7.b;
					var x = _n11.a;
					var xs = _n11.b;
					return A2(
						elm$core$List$cons,
						elm$html$Html$text(name + ' '),
						A2(
							elm$core$List$cons,
							A2(elm$html$Html$span, _List_Nil, x),
							A3(
								elm$core$List$foldr,
								F2(
									function (args, rest) {
										return A2(
											elm$core$List$cons,
											elm$html$Html$text(' '),
											A2(
												elm$core$List$cons,
												A2(elm$html$Html$span, _List_Nil, args),
												rest));
									}),
								_List_Nil,
								xs)));
				}
			}
		}();
		var _n4 = function () {
			if (!valueList.b) {
				return _Utils_Tuple2(
					elm$core$Maybe$Nothing,
					A2(elm$html$Html$div, _List_Nil, _List_Nil));
			} else {
				if (!valueList.b.b) {
					var entry = valueList.a;
					switch (entry.$) {
						case 'S':
							return _Utils_Tuple2(
								elm$core$Maybe$Nothing,
								A2(elm$html$Html$div, _List_Nil, _List_Nil));
						case 'Primitive':
							return _Utils_Tuple2(
								elm$core$Maybe$Nothing,
								A2(elm$html$Html$div, _List_Nil, _List_Nil));
						case 'Sequence':
							var subValueList = entry.c;
							return _Utils_Tuple2(
								elm$core$Maybe$Just(isClosed),
								isClosed ? A2(elm$html$Html$div, _List_Nil, _List_Nil) : A2(
									elm$html$Html$map,
									A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$None, 0),
									elm$browser$Debugger$Expando$viewSequenceOpen(subValueList)));
						case 'Dictionary':
							var keyValuePairs = entry.b;
							return _Utils_Tuple2(
								elm$core$Maybe$Just(isClosed),
								isClosed ? A2(elm$html$Html$div, _List_Nil, _List_Nil) : A2(
									elm$html$Html$map,
									A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$None, 0),
									elm$browser$Debugger$Expando$viewDictionaryOpen(keyValuePairs)));
						case 'Record':
							var record = entry.b;
							return _Utils_Tuple2(
								elm$core$Maybe$Just(isClosed),
								isClosed ? A2(elm$html$Html$div, _List_Nil, _List_Nil) : A2(
									elm$html$Html$map,
									A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$None, 0),
									elm$browser$Debugger$Expando$viewRecordOpen(record)));
						default:
							var subValueList = entry.c;
							return _Utils_Tuple2(
								elm$core$Maybe$Just(isClosed),
								isClosed ? A2(elm$html$Html$div, _List_Nil, _List_Nil) : A2(
									elm$html$Html$map,
									A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$None, 0),
									elm$browser$Debugger$Expando$viewConstructorOpen(subValueList)));
					}
				} else {
					return _Utils_Tuple2(
						elm$core$Maybe$Just(isClosed),
						isClosed ? A2(elm$html$Html$div, _List_Nil, _List_Nil) : elm$browser$Debugger$Expando$viewConstructorOpen(valueList));
				}
			}
		}();
		var maybeIsClosed = _n4.a;
		var openHtml = _n4.b;
		return A2(
			elm$html$Html$div,
			elm$browser$Debugger$Expando$leftPad(maybeKey),
			_List_fromArray(
				[
					A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							elm$html$Html$Events$onClick(elm$browser$Debugger$Expando$Toggle)
						]),
					A3(elm$browser$Debugger$Expando$lineStarter, maybeKey, maybeIsClosed, description)),
					openHtml
				]));
	});
var elm$browser$Debugger$Expando$viewConstructorEntry = F2(
	function (index, value) {
		return A2(
			elm$html$Html$map,
			A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$None, index),
			A2(
				elm$browser$Debugger$Expando$view,
				elm$core$Maybe$Just(
					elm$core$String$fromInt(index)),
				value));
	});
var elm$browser$Debugger$Expando$viewConstructorOpen = function (valueList) {
	return A2(
		elm$html$Html$div,
		_List_Nil,
		A2(elm$core$List$indexedMap, elm$browser$Debugger$Expando$viewConstructorEntry, valueList));
};
var elm$browser$Debugger$Expando$viewDictionary = F3(
	function (maybeKey, isClosed, keyValuePairs) {
		var starter = 'Dict(' + (elm$core$String$fromInt(
			elm$core$List$length(keyValuePairs)) + ')');
		return A2(
			elm$html$Html$div,
			elm$browser$Debugger$Expando$leftPad(maybeKey),
			_List_fromArray(
				[
					A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							elm$html$Html$Events$onClick(elm$browser$Debugger$Expando$Toggle)
						]),
					A3(
						elm$browser$Debugger$Expando$lineStarter,
						maybeKey,
						elm$core$Maybe$Just(isClosed),
						_List_fromArray(
							[
								elm$html$Html$text(starter)
							]))),
					isClosed ? elm$html$Html$text('') : elm$browser$Debugger$Expando$viewDictionaryOpen(keyValuePairs)
				]));
	});
var elm$browser$Debugger$Expando$viewDictionaryEntry = F2(
	function (index, _n2) {
		var key = _n2.a;
		var value = _n2.b;
		switch (key.$) {
			case 'S':
				var stringRep = key.a;
				return A2(
					elm$html$Html$map,
					A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$Value, index),
					A2(
						elm$browser$Debugger$Expando$view,
						elm$core$Maybe$Just(stringRep),
						value));
			case 'Primitive':
				var stringRep = key.a;
				return A2(
					elm$html$Html$map,
					A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$Value, index),
					A2(
						elm$browser$Debugger$Expando$view,
						elm$core$Maybe$Just(stringRep),
						value));
			default:
				return A2(
					elm$html$Html$div,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							elm$html$Html$map,
							A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$Key, index),
							A2(
								elm$browser$Debugger$Expando$view,
								elm$core$Maybe$Just('key'),
								key)),
							A2(
							elm$html$Html$map,
							A2(elm$browser$Debugger$Expando$Index, elm$browser$Debugger$Expando$Value, index),
							A2(
								elm$browser$Debugger$Expando$view,
								elm$core$Maybe$Just('value'),
								value))
						]));
		}
	});
var elm$browser$Debugger$Expando$viewDictionaryOpen = function (keyValuePairs) {
	return A2(
		elm$html$Html$div,
		_List_Nil,
		A2(elm$core$List$indexedMap, elm$browser$Debugger$Expando$viewDictionaryEntry, keyValuePairs));
};
var elm$browser$Debugger$Expando$viewRecord = F3(
	function (maybeKey, isClosed, record) {
		var _n1 = isClosed ? _Utils_Tuple3(
			elm$browser$Debugger$Expando$viewTinyRecord(record).b,
			elm$html$Html$text(''),
			elm$html$Html$text('')) : _Utils_Tuple3(
			_List_fromArray(
				[
					elm$html$Html$text('{')
				]),
			elm$browser$Debugger$Expando$viewRecordOpen(record),
			A2(
				elm$html$Html$div,
				elm$browser$Debugger$Expando$leftPad(
					elm$core$Maybe$Just(_Utils_Tuple0)),
				_List_fromArray(
					[
						elm$html$Html$text('}')
					])));
		var start = _n1.a;
		var middle = _n1.b;
		var end = _n1.c;
		return A2(
			elm$html$Html$div,
			elm$browser$Debugger$Expando$leftPad(maybeKey),
			_List_fromArray(
				[
					A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							elm$html$Html$Events$onClick(elm$browser$Debugger$Expando$Toggle)
						]),
					A3(
						elm$browser$Debugger$Expando$lineStarter,
						maybeKey,
						elm$core$Maybe$Just(isClosed),
						start)),
					middle,
					end
				]));
	});
var elm$browser$Debugger$Expando$viewRecordEntry = function (_n0) {
	var field = _n0.a;
	var value = _n0.b;
	return A2(
		elm$html$Html$map,
		elm$browser$Debugger$Expando$Field(field),
		A2(
			elm$browser$Debugger$Expando$view,
			elm$core$Maybe$Just(field),
			value));
};
var elm$browser$Debugger$Expando$viewRecordOpen = function (record) {
	return A2(
		elm$html$Html$div,
		_List_Nil,
		A2(
			elm$core$List$map,
			elm$browser$Debugger$Expando$viewRecordEntry,
			elm$core$Dict$toList(record)));
};
var elm$browser$Debugger$Expando$viewSequence = F4(
	function (maybeKey, seqType, isClosed, valueList) {
		var starter = A2(
			elm$browser$Debugger$Expando$seqTypeToString,
			elm$core$List$length(valueList),
			seqType);
		return A2(
			elm$html$Html$div,
			elm$browser$Debugger$Expando$leftPad(maybeKey),
			_List_fromArray(
				[
					A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							elm$html$Html$Events$onClick(elm$browser$Debugger$Expando$Toggle)
						]),
					A3(
						elm$browser$Debugger$Expando$lineStarter,
						maybeKey,
						elm$core$Maybe$Just(isClosed),
						_List_fromArray(
							[
								elm$html$Html$text(starter)
							]))),
					isClosed ? elm$html$Html$text('') : elm$browser$Debugger$Expando$viewSequenceOpen(valueList)
				]));
	});
var elm$browser$Debugger$Expando$viewSequenceOpen = function (values) {
	return A2(
		elm$html$Html$div,
		_List_Nil,
		A2(elm$core$List$indexedMap, elm$browser$Debugger$Expando$viewConstructorEntry, values));
};
var elm$browser$Debugger$Main$ExpandoMsg = function (a) {
	return {$: 'ExpandoMsg', a: a};
};
var elm$html$Html$Attributes$class = elm$html$Html$Attributes$stringProperty('className');
var elm$html$Html$Attributes$title = elm$html$Html$Attributes$stringProperty('title');
var elm$browser$Debugger$History$viewMessage = F3(
	function (currentIndex, index, msg) {
		var messageName = _Debugger_messageToString(msg);
		var className = _Utils_eq(currentIndex, index) ? 'elm-debugger-entry elm-debugger-entry-selected' : 'elm-debugger-entry';
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					elm$html$Html$Attributes$class(className),
					elm$html$Html$Events$onClick(index)
				]),
			_List_fromArray(
				[
					A2(
					elm$html$Html$span,
					_List_fromArray(
						[
							elm$html$Html$Attributes$title(messageName),
							elm$html$Html$Attributes$class('elm-debugger-entry-content')
						]),
					_List_fromArray(
						[
							elm$html$Html$text(messageName)
						])),
					A2(
					elm$html$Html$span,
					_List_fromArray(
						[
							elm$html$Html$Attributes$class('elm-debugger-entry-index')
						]),
					_List_fromArray(
						[
							elm$html$Html$text(
							elm$core$String$fromInt(index))
						]))
				]));
	});
var elm$virtual_dom$VirtualDom$lazy3 = _VirtualDom_lazy3;
var elm$html$Html$Lazy$lazy3 = elm$virtual_dom$VirtualDom$lazy3;
var elm$browser$Debugger$History$consMsg = F3(
	function (currentIndex, msg, _n0) {
		var index = _n0.a;
		var rest = _n0.b;
		return _Utils_Tuple2(
			index - 1,
			A2(
				elm$core$List$cons,
				A4(elm$html$Html$Lazy$lazy3, elm$browser$Debugger$History$viewMessage, currentIndex, index, msg),
				rest));
	});
var elm$virtual_dom$VirtualDom$node = function (tag) {
	return _VirtualDom_node(
		_VirtualDom_noScript(tag));
};
var elm$html$Html$node = elm$virtual_dom$VirtualDom$node;
var elm$browser$Debugger$History$styles = A3(
	elm$html$Html$node,
	'style',
	_List_Nil,
	_List_fromArray(
		[
			elm$html$Html$text('\n\n.elm-debugger-entry {\n  cursor: pointer;\n  width: 100%;\n}\n\n.elm-debugger-entry:hover {\n  background-color: rgb(41, 41, 41);\n}\n\n.elm-debugger-entry-selected, .elm-debugger-entry-selected:hover {\n  background-color: rgb(10, 10, 10);\n}\n\n.elm-debugger-entry-content {\n  width: calc(100% - 7ch);\n  padding-top: 4px;\n  padding-bottom: 4px;\n  padding-left: 1ch;\n  text-overflow: ellipsis;\n  white-space: nowrap;\n  overflow: hidden;\n  display: inline-block;\n}\n\n.elm-debugger-entry-index {\n  color: #666;\n  width: 5ch;\n  padding-top: 4px;\n  padding-bottom: 4px;\n  padding-right: 1ch;\n  text-align: right;\n  display: block;\n  float: right;\n}\n\n')
		]));
var elm$browser$Debugger$History$maxSnapshotSize = 64;
var elm$core$Elm$JsArray$foldl = _JsArray_foldl;
var elm$core$Array$foldl = F3(
	function (func, baseCase, _n0) {
		var tree = _n0.c;
		var tail = _n0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3(elm$core$Elm$JsArray$foldl, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3(elm$core$Elm$JsArray$foldl, func, acc, values);
				}
			});
		return A3(
			elm$core$Elm$JsArray$foldl,
			func,
			A3(elm$core$Elm$JsArray$foldl, helper, baseCase, tree),
			tail);
	});
var elm$browser$Debugger$History$viewSnapshot = F3(
	function (currentIndex, index, _n0) {
		var messages = _n0.messages;
		return A2(
			elm$html$Html$div,
			_List_Nil,
			A3(
				elm$core$Array$foldl,
				elm$browser$Debugger$History$consMsg(currentIndex),
				_Utils_Tuple2(index - 1, _List_Nil),
				messages).b);
	});
var elm$browser$Debugger$History$consSnapshot = F3(
	function (currentIndex, snapshot, _n0) {
		var index = _n0.a;
		var rest = _n0.b;
		var nextIndex = index - elm$browser$Debugger$History$maxSnapshotSize;
		var currentIndexHelp = ((_Utils_cmp(nextIndex, currentIndex) < 1) && (_Utils_cmp(currentIndex, index) < 0)) ? currentIndex : (-1);
		return _Utils_Tuple2(
			index - elm$browser$Debugger$History$maxSnapshotSize,
			A2(
				elm$core$List$cons,
				A4(elm$html$Html$Lazy$lazy3, elm$browser$Debugger$History$viewSnapshot, currentIndexHelp, index, snapshot),
				rest));
	});
var elm$core$Array$length = function (_n0) {
	var len = _n0.a;
	return len;
};
var elm$browser$Debugger$History$viewSnapshots = F2(
	function (currentIndex, snapshots) {
		var highIndex = elm$browser$Debugger$History$maxSnapshotSize * elm$core$Array$length(snapshots);
		return A2(
			elm$html$Html$div,
			_List_Nil,
			A3(
				elm$core$Array$foldr,
				elm$browser$Debugger$History$consSnapshot(currentIndex),
				_Utils_Tuple2(highIndex, _List_Nil),
				snapshots).b);
	});
var elm$virtual_dom$VirtualDom$lazy2 = _VirtualDom_lazy2;
var elm$html$Html$Lazy$lazy2 = elm$virtual_dom$VirtualDom$lazy2;
var elm$browser$Debugger$History$view = F2(
	function (maybeIndex, _n0) {
		var snapshots = _n0.snapshots;
		var recent = _n0.recent;
		var numMessages = _n0.numMessages;
		var _n1 = function () {
			if (maybeIndex.$ === 'Nothing') {
				return _Utils_Tuple2(-1, 'calc(100% - 24px)');
			} else {
				var i = maybeIndex.a;
				return _Utils_Tuple2(i, 'calc(100% - 54px)');
			}
		}();
		var index = _n1.a;
		var height = _n1.b;
		var newStuff = A3(
			elm$core$List$foldl,
			elm$browser$Debugger$History$consMsg(index),
			_Utils_Tuple2(numMessages - 1, _List_Nil),
			recent.messages).b;
		var oldStuff = A3(elm$html$Html$Lazy$lazy2, elm$browser$Debugger$History$viewSnapshots, index, snapshots);
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					elm$html$Html$Attributes$id('elm-debugger-sidebar'),
					A2(elm$html$Html$Attributes$style, 'width', '100%'),
					A2(elm$html$Html$Attributes$style, 'overflow-y', 'auto'),
					A2(elm$html$Html$Attributes$style, 'height', height)
				]),
			A2(
				elm$core$List$cons,
				elm$browser$Debugger$History$styles,
				A2(elm$core$List$cons, oldStuff, newStuff)));
	});
var elm$browser$Debugger$Main$Jump = function (a) {
	return {$: 'Jump', a: a};
};
var elm$browser$Debugger$Main$resumeStyle = '\n\n.elm-debugger-resume {\n  width: 100%;\n  height: 30px;\n  line-height: 30px;\n  cursor: pointer;\n}\n\n.elm-debugger-resume:hover {\n  background-color: rgb(41, 41, 41);\n}\n\n';
var elm$browser$Debugger$Main$viewResumeButton = function (maybeIndex) {
	if (maybeIndex.$ === 'Nothing') {
		return elm$html$Html$text('');
	} else {
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					elm$html$Html$Events$onClick(elm$browser$Debugger$Main$Resume),
					elm$html$Html$Attributes$class('elm-debugger-resume')
				]),
			_List_fromArray(
				[
					elm$html$Html$text('Resume'),
					A3(
					elm$html$Html$node,
					'style',
					_List_Nil,
					_List_fromArray(
						[
							elm$html$Html$text(elm$browser$Debugger$Main$resumeStyle)
						]))
				]));
	}
};
var elm$browser$Debugger$Main$viewTextButton = F2(
	function (msg, label) {
		return A2(
			elm$html$Html$span,
			_List_fromArray(
				[
					elm$html$Html$Events$onClick(msg),
					A2(elm$html$Html$Attributes$style, 'cursor', 'pointer')
				]),
			_List_fromArray(
				[
					elm$html$Html$text(label)
				]));
	});
var elm$browser$Debugger$Main$playButton = function (maybeIndex) {
	return A2(
		elm$html$Html$div,
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'width', '100%'),
				A2(elm$html$Html$Attributes$style, 'text-align', 'center'),
				A2(elm$html$Html$Attributes$style, 'background-color', 'rgb(50, 50, 50)')
			]),
		_List_fromArray(
			[
				elm$browser$Debugger$Main$viewResumeButton(maybeIndex),
				A2(
				elm$html$Html$div,
				_List_fromArray(
					[
						A2(elm$html$Html$Attributes$style, 'width', '100%'),
						A2(elm$html$Html$Attributes$style, 'height', '24px'),
						A2(elm$html$Html$Attributes$style, 'line-height', '24px'),
						A2(elm$html$Html$Attributes$style, 'font-size', '12px')
					]),
				_List_fromArray(
					[
						A2(elm$browser$Debugger$Main$viewTextButton, elm$browser$Debugger$Main$Import, 'Import'),
						elm$html$Html$text(' / '),
						A2(elm$browser$Debugger$Main$viewTextButton, elm$browser$Debugger$Main$Export, 'Export')
					]))
			]));
};
var elm$browser$Debugger$Main$viewSidebar = F2(
	function (state, history) {
		var maybeIndex = function () {
			if (state.$ === 'Running') {
				return elm$core$Maybe$Nothing;
			} else {
				var index = state.a;
				return elm$core$Maybe$Just(index);
			}
		}();
		return A2(
			elm$html$Html$div,
			_List_fromArray(
				[
					A2(elm$html$Html$Attributes$style, 'display', 'block'),
					A2(elm$html$Html$Attributes$style, 'float', 'left'),
					A2(elm$html$Html$Attributes$style, 'width', '30ch'),
					A2(elm$html$Html$Attributes$style, 'height', '100%'),
					A2(elm$html$Html$Attributes$style, 'color', 'white'),
					A2(elm$html$Html$Attributes$style, 'background-color', 'rgb(61, 61, 61)')
				]),
			_List_fromArray(
				[
					A2(
					elm$html$Html$map,
					elm$browser$Debugger$Main$Jump,
					A2(elm$browser$Debugger$History$view, maybeIndex, history)),
					elm$browser$Debugger$Main$playButton(maybeIndex)
				]));
	});
var elm$browser$Debugger$Main$popoutView = function (_n0) {
	var history = _n0.history;
	var state = _n0.state;
	var expando = _n0.expando;
	return A3(
		elm$html$Html$node,
		'body',
		_List_fromArray(
			[
				A2(elm$html$Html$Attributes$style, 'margin', '0'),
				A2(elm$html$Html$Attributes$style, 'padding', '0'),
				A2(elm$html$Html$Attributes$style, 'width', '100%'),
				A2(elm$html$Html$Attributes$style, 'height', '100%'),
				A2(elm$html$Html$Attributes$style, 'font-family', 'monospace'),
				A2(elm$html$Html$Attributes$style, 'overflow', 'auto')
			]),
		_List_fromArray(
			[
				A2(elm$browser$Debugger$Main$viewSidebar, state, history),
				A2(
				elm$html$Html$map,
				elm$browser$Debugger$Main$ExpandoMsg,
				A2(
					elm$html$Html$div,
					_List_fromArray(
						[
							A2(elm$html$Html$Attributes$style, 'display', 'block'),
							A2(elm$html$Html$Attributes$style, 'float', 'left'),
							A2(elm$html$Html$Attributes$style, 'height', '100%'),
							A2(elm$html$Html$Attributes$style, 'width', 'calc(100% - 30ch)'),
							A2(elm$html$Html$Attributes$style, 'margin', '0'),
							A2(elm$html$Html$Attributes$style, 'overflow', 'auto'),
							A2(elm$html$Html$Attributes$style, 'cursor', 'default')
						]),
					_List_fromArray(
						[
							A2(elm$browser$Debugger$Expando$view, elm$core$Maybe$Nothing, expando)
						])))
			]));
};
var elm$browser$Debugger$Overlay$BlockAll = {$: 'BlockAll'};
var elm$browser$Debugger$Overlay$BlockMost = {$: 'BlockMost'};
var elm$browser$Debugger$Overlay$BlockNone = {$: 'BlockNone'};
var elm$browser$Debugger$Overlay$toBlockerType = F2(
	function (isPaused, state) {
		switch (state.$) {
			case 'None':
				return isPaused ? elm$browser$Debugger$Overlay$BlockAll : elm$browser$Debugger$Overlay$BlockNone;
			case 'BadMetadata':
				return elm$browser$Debugger$Overlay$BlockMost;
			case 'BadImport':
				return elm$browser$Debugger$Overlay$BlockMost;
			default:
				return elm$browser$Debugger$Overlay$BlockMost;
		}
	});
var elm$browser$Debugger$Main$toBlockerType = function (model) {
	return A2(
		elm$browser$Debugger$Overlay$toBlockerType,
		elm$browser$Debugger$Main$isPaused(model.state),
		model.overlay);
};
var elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2(elm$core$Dict$map, func, left),
				A2(elm$core$Dict$map, func, right));
		}
	});
var elm$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var left = dict.d;
				var right = dict.e;
				var $temp$n = A2(elm$core$Dict$sizeHelp, n + 1, right),
					$temp$dict = left;
				n = $temp$n;
				dict = $temp$dict;
				continue sizeHelp;
			}
		}
	});
var elm$core$Dict$size = function (dict) {
	return A2(elm$core$Dict$sizeHelp, 0, dict);
};
var elm$browser$Debugger$Expando$initHelp = F2(
	function (isOuter, expando) {
		switch (expando.$) {
			case 'S':
				return expando;
			case 'Primitive':
				return expando;
			case 'Sequence':
				var seqType = expando.a;
				var isClosed = expando.b;
				var items = expando.c;
				return isOuter ? A3(
					elm$browser$Debugger$Expando$Sequence,
					seqType,
					false,
					A2(
						elm$core$List$map,
						elm$browser$Debugger$Expando$initHelp(false),
						items)) : ((elm$core$List$length(items) <= 8) ? A3(elm$browser$Debugger$Expando$Sequence, seqType, false, items) : expando);
			case 'Dictionary':
				var isClosed = expando.a;
				var keyValuePairs = expando.b;
				return isOuter ? A2(
					elm$browser$Debugger$Expando$Dictionary,
					false,
					A2(
						elm$core$List$map,
						function (_n1) {
							var k = _n1.a;
							var v = _n1.b;
							return _Utils_Tuple2(
								k,
								A2(elm$browser$Debugger$Expando$initHelp, false, v));
						},
						keyValuePairs)) : ((elm$core$List$length(keyValuePairs) <= 8) ? A2(elm$browser$Debugger$Expando$Dictionary, false, keyValuePairs) : expando);
			case 'Record':
				var isClosed = expando.a;
				var entries = expando.b;
				return isOuter ? A2(
					elm$browser$Debugger$Expando$Record,
					false,
					A2(
						elm$core$Dict$map,
						F2(
							function (_n2, v) {
								return A2(elm$browser$Debugger$Expando$initHelp, false, v);
							}),
						entries)) : ((elm$core$Dict$size(entries) <= 4) ? A2(elm$browser$Debugger$Expando$Record, false, entries) : expando);
			default:
				var maybeName = expando.a;
				var isClosed = expando.b;
				var args = expando.c;
				return isOuter ? A3(
					elm$browser$Debugger$Expando$Constructor,
					maybeName,
					false,
					A2(
						elm$core$List$map,
						elm$browser$Debugger$Expando$initHelp(false),
						args)) : ((elm$core$List$length(args) <= 4) ? A3(elm$browser$Debugger$Expando$Constructor, maybeName, false, args) : expando);
		}
	});
var elm$browser$Debugger$Expando$init = function (value) {
	return A2(
		elm$browser$Debugger$Expando$initHelp,
		true,
		_Debugger_init(value));
};
var elm$browser$Debugger$History$History = F3(
	function (snapshots, recent, numMessages) {
		return {numMessages: numMessages, recent: recent, snapshots: snapshots};
	});
var elm$browser$Debugger$History$RecentHistory = F3(
	function (model, messages, numMessages) {
		return {messages: messages, model: model, numMessages: numMessages};
	});
var elm$browser$Debugger$History$empty = function (model) {
	return A3(
		elm$browser$Debugger$History$History,
		elm$core$Array$empty,
		A3(elm$browser$Debugger$History$RecentHistory, model, _List_Nil, 0),
		0);
};
var elm$browser$Debugger$Main$Running = function (a) {
	return {$: 'Running', a: a};
};
var elm$browser$Debugger$Metadata$Error = F2(
	function (message, problems) {
		return {message: message, problems: problems};
	});
var elm$browser$Debugger$Metadata$Metadata = F2(
	function (versions, types) {
		return {types: types, versions: versions};
	});
var elm$browser$Debugger$Metadata$Types = F3(
	function (message, aliases, unions) {
		return {aliases: aliases, message: message, unions: unions};
	});
var elm$browser$Debugger$Metadata$Alias = F2(
	function (args, tipe) {
		return {args: args, tipe: tipe};
	});
var elm$json$Json$Decode$field = _Json_decodeField;
var elm$browser$Debugger$Metadata$decodeAlias = A3(
	elm$json$Json$Decode$map2,
	elm$browser$Debugger$Metadata$Alias,
	A2(
		elm$json$Json$Decode$field,
		'args',
		elm$json$Json$Decode$list(elm$json$Json$Decode$string)),
	A2(elm$json$Json$Decode$field, 'type', elm$json$Json$Decode$string));
var elm$browser$Debugger$Metadata$Union = F2(
	function (args, tags) {
		return {args: args, tags: tags};
	});
var elm$core$Dict$fromList = function (assocs) {
	return A3(
		elm$core$List$foldl,
		F2(
			function (_n0, dict) {
				var key = _n0.a;
				var value = _n0.b;
				return A3(elm$core$Dict$insert, key, value, dict);
			}),
		elm$core$Dict$empty,
		assocs);
};
var elm$json$Json$Decode$dict = function (decoder) {
	return A2(
		elm$json$Json$Decode$map,
		elm$core$Dict$fromList,
		elm$json$Json$Decode$keyValuePairs(decoder));
};
var elm$browser$Debugger$Metadata$decodeUnion = A3(
	elm$json$Json$Decode$map2,
	elm$browser$Debugger$Metadata$Union,
	A2(
		elm$json$Json$Decode$field,
		'args',
		elm$json$Json$Decode$list(elm$json$Json$Decode$string)),
	A2(
		elm$json$Json$Decode$field,
		'tags',
		elm$json$Json$Decode$dict(
			elm$json$Json$Decode$list(elm$json$Json$Decode$string))));
var elm$json$Json$Decode$map3 = _Json_map3;
var elm$browser$Debugger$Metadata$decodeTypes = A4(
	elm$json$Json$Decode$map3,
	elm$browser$Debugger$Metadata$Types,
	A2(elm$json$Json$Decode$field, 'message', elm$json$Json$Decode$string),
	A2(
		elm$json$Json$Decode$field,
		'aliases',
		elm$json$Json$Decode$dict(elm$browser$Debugger$Metadata$decodeAlias)),
	A2(
		elm$json$Json$Decode$field,
		'unions',
		elm$json$Json$Decode$dict(elm$browser$Debugger$Metadata$decodeUnion)));
var elm$browser$Debugger$Metadata$Versions = function (elm) {
	return {elm: elm};
};
var elm$browser$Debugger$Metadata$decodeVersions = A2(
	elm$json$Json$Decode$map,
	elm$browser$Debugger$Metadata$Versions,
	A2(elm$json$Json$Decode$field, 'elm', elm$json$Json$Decode$string));
var elm$browser$Debugger$Metadata$decoder = A3(
	elm$json$Json$Decode$map2,
	elm$browser$Debugger$Metadata$Metadata,
	A2(elm$json$Json$Decode$field, 'versions', elm$browser$Debugger$Metadata$decodeVersions),
	A2(elm$json$Json$Decode$field, 'types', elm$browser$Debugger$Metadata$decodeTypes));
var elm$browser$Debugger$Metadata$ProblemType = F2(
	function (name, problems) {
		return {name: name, problems: problems};
	});
var elm$browser$Debugger$Metadata$hasProblem = F2(
	function (tipe, _n0) {
		var problem = _n0.a;
		var token = _n0.b;
		return A2(elm$core$String$contains, token, tipe) ? elm$core$Maybe$Just(problem) : elm$core$Maybe$Nothing;
	});
var elm$browser$Debugger$Metadata$Decoder = {$: 'Decoder'};
var elm$browser$Debugger$Metadata$Function = {$: 'Function'};
var elm$browser$Debugger$Metadata$Process = {$: 'Process'};
var elm$browser$Debugger$Metadata$Program = {$: 'Program'};
var elm$browser$Debugger$Metadata$Request = {$: 'Request'};
var elm$browser$Debugger$Metadata$Socket = {$: 'Socket'};
var elm$browser$Debugger$Metadata$Task = {$: 'Task'};
var elm$browser$Debugger$Metadata$VirtualDom = {$: 'VirtualDom'};
var elm$browser$Debugger$Metadata$problemTable = _List_fromArray(
	[
		_Utils_Tuple2(elm$browser$Debugger$Metadata$Function, '->'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$Decoder, 'Json.Decode.Decoder'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$Task, 'Task.Task'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$Process, 'Process.Id'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$Socket, 'WebSocket.LowLevel.WebSocket'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$Request, 'Http.Request'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$Program, 'Platform.Program'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$VirtualDom, 'VirtualDom.Node'),
		_Utils_Tuple2(elm$browser$Debugger$Metadata$VirtualDom, 'VirtualDom.Attribute')
	]);
var elm$browser$Debugger$Metadata$findProblems = function (tipe) {
	return A2(
		elm$core$List$filterMap,
		elm$browser$Debugger$Metadata$hasProblem(tipe),
		elm$browser$Debugger$Metadata$problemTable);
};
var elm$browser$Debugger$Metadata$collectBadAliases = F3(
	function (name, _n0, list) {
		var tipe = _n0.tipe;
		var _n1 = elm$browser$Debugger$Metadata$findProblems(tipe);
		if (!_n1.b) {
			return list;
		} else {
			var problems = _n1;
			return A2(
				elm$core$List$cons,
				A2(elm$browser$Debugger$Metadata$ProblemType, name, problems),
				list);
		}
	});
var elm$core$Dict$values = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2(elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var elm$browser$Debugger$Metadata$collectBadUnions = F3(
	function (name, _n0, list) {
		var tags = _n0.tags;
		var _n1 = A2(
			elm$core$List$concatMap,
			elm$browser$Debugger$Metadata$findProblems,
			elm$core$List$concat(
				elm$core$Dict$values(tags)));
		if (!_n1.b) {
			return list;
		} else {
			var problems = _n1;
			return A2(
				elm$core$List$cons,
				A2(elm$browser$Debugger$Metadata$ProblemType, name, problems),
				list);
		}
	});
var elm$core$Dict$foldl = F3(
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
					A3(elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var elm$browser$Debugger$Metadata$isPortable = function (_n0) {
	var types = _n0.types;
	var badAliases = A3(elm$core$Dict$foldl, elm$browser$Debugger$Metadata$collectBadAliases, _List_Nil, types.aliases);
	var _n1 = A3(elm$core$Dict$foldl, elm$browser$Debugger$Metadata$collectBadUnions, badAliases, types.unions);
	if (!_n1.b) {
		return elm$core$Maybe$Nothing;
	} else {
		var problems = _n1;
		return elm$core$Maybe$Just(
			A2(elm$browser$Debugger$Metadata$Error, types.message, problems));
	}
};
var elm$browser$Debugger$Metadata$decode = function (value) {
	var _n0 = A2(elm$json$Json$Decode$decodeValue, elm$browser$Debugger$Metadata$decoder, value);
	if (_n0.$ === 'Err') {
		return elm$core$Result$Err(
			A2(elm$browser$Debugger$Metadata$Error, 'The compiler is generating bad metadata. This is a compiler bug!', _List_Nil));
	} else {
		var metadata = _n0.a;
		var _n1 = elm$browser$Debugger$Metadata$isPortable(metadata);
		if (_n1.$ === 'Nothing') {
			return elm$core$Result$Ok(metadata);
		} else {
			var error = _n1.a;
			return elm$core$Result$Err(error);
		}
	}
};
var elm$browser$Debugger$Overlay$None = {$: 'None'};
var elm$browser$Debugger$Overlay$none = elm$browser$Debugger$Overlay$None;
var elm$core$Platform$Cmd$map = _Platform_map;
var elm$browser$Debugger$Main$wrapInit = F4(
	function (metadata, popout, init, flags) {
		var _n0 = init(flags);
		var userModel = _n0.a;
		var userCommands = _n0.b;
		return _Utils_Tuple2(
			{
				expando: elm$browser$Debugger$Expando$init(userModel),
				history: elm$browser$Debugger$History$empty(userModel),
				metadata: elm$browser$Debugger$Metadata$decode(metadata),
				overlay: elm$browser$Debugger$Overlay$none,
				popout: popout,
				state: elm$browser$Debugger$Main$Running(userModel)
			},
			A2(elm$core$Platform$Cmd$map, elm$browser$Debugger$Main$UserMsg, userCommands));
	});
var elm$browser$Debugger$Main$getLatestModel = function (state) {
	if (state.$ === 'Running') {
		var model = state.a;
		return model;
	} else {
		var model = state.c;
		return model;
	}
};
var elm$core$Platform$Sub$map = _Platform_map;
var elm$browser$Debugger$Main$wrapSubs = F2(
	function (subscriptions, model) {
		return A2(
			elm$core$Platform$Sub$map,
			elm$browser$Debugger$Main$UserMsg,
			subscriptions(
				elm$browser$Debugger$Main$getLatestModel(model.state)));
	});
var elm$browser$Debugger$Expando$mergeDictHelp = F3(
	function (oldDict, key, value) {
		var _n12 = A2(elm$core$Dict$get, key, oldDict);
		if (_n12.$ === 'Nothing') {
			return value;
		} else {
			var oldValue = _n12.a;
			return A2(elm$browser$Debugger$Expando$mergeHelp, oldValue, value);
		}
	});
var elm$browser$Debugger$Expando$mergeHelp = F2(
	function (old, _new) {
		var _n3 = _Utils_Tuple2(old, _new);
		_n3$6:
		while (true) {
			switch (_n3.b.$) {
				case 'S':
					return _new;
				case 'Primitive':
					return _new;
				case 'Sequence':
					if (_n3.a.$ === 'Sequence') {
						var _n4 = _n3.a;
						var isClosed = _n4.b;
						var oldValues = _n4.c;
						var _n5 = _n3.b;
						var seqType = _n5.a;
						var newValues = _n5.c;
						return A3(
							elm$browser$Debugger$Expando$Sequence,
							seqType,
							isClosed,
							A2(elm$browser$Debugger$Expando$mergeListHelp, oldValues, newValues));
					} else {
						break _n3$6;
					}
				case 'Dictionary':
					if (_n3.a.$ === 'Dictionary') {
						var _n6 = _n3.a;
						var isClosed = _n6.a;
						var _n7 = _n3.b;
						var keyValuePairs = _n7.b;
						return A2(elm$browser$Debugger$Expando$Dictionary, isClosed, keyValuePairs);
					} else {
						break _n3$6;
					}
				case 'Record':
					if (_n3.a.$ === 'Record') {
						var _n8 = _n3.a;
						var isClosed = _n8.a;
						var oldDict = _n8.b;
						var _n9 = _n3.b;
						var newDict = _n9.b;
						return A2(
							elm$browser$Debugger$Expando$Record,
							isClosed,
							A2(
								elm$core$Dict$map,
								elm$browser$Debugger$Expando$mergeDictHelp(oldDict),
								newDict));
					} else {
						break _n3$6;
					}
				default:
					if (_n3.a.$ === 'Constructor') {
						var _n10 = _n3.a;
						var isClosed = _n10.b;
						var oldValues = _n10.c;
						var _n11 = _n3.b;
						var maybeName = _n11.a;
						var newValues = _n11.c;
						return A3(
							elm$browser$Debugger$Expando$Constructor,
							maybeName,
							isClosed,
							A2(elm$browser$Debugger$Expando$mergeListHelp, oldValues, newValues));
					} else {
						break _n3$6;
					}
			}
		}
		return _new;
	});
var elm$browser$Debugger$Expando$mergeListHelp = F2(
	function (olds, news) {
		var _n0 = _Utils_Tuple2(olds, news);
		if (!_n0.a.b) {
			return news;
		} else {
			if (!_n0.b.b) {
				return news;
			} else {
				var _n1 = _n0.a;
				var x = _n1.a;
				var xs = _n1.b;
				var _n2 = _n0.b;
				var y = _n2.a;
				var ys = _n2.b;
				return A2(
					elm$core$List$cons,
					A2(elm$browser$Debugger$Expando$mergeHelp, x, y),
					A2(elm$browser$Debugger$Expando$mergeListHelp, xs, ys));
			}
		}
	});
var elm$browser$Debugger$Expando$merge = F2(
	function (value, expando) {
		return A2(
			elm$browser$Debugger$Expando$mergeHelp,
			expando,
			_Debugger_init(value));
	});
var elm$browser$Debugger$Expando$updateIndex = F3(
	function (n, func, list) {
		if (!list.b) {
			return _List_Nil;
		} else {
			var x = list.a;
			var xs = list.b;
			return (n <= 0) ? A2(
				elm$core$List$cons,
				func(x),
				xs) : A2(
				elm$core$List$cons,
				x,
				A3(elm$browser$Debugger$Expando$updateIndex, n - 1, func, xs));
		}
	});
var elm$browser$Debugger$Expando$update = F2(
	function (msg, value) {
		switch (value.$) {
			case 'S':
				return value;
			case 'Primitive':
				return value;
			case 'Sequence':
				var seqType = value.a;
				var isClosed = value.b;
				var valueList = value.c;
				switch (msg.$) {
					case 'Toggle':
						return A3(elm$browser$Debugger$Expando$Sequence, seqType, !isClosed, valueList);
					case 'Index':
						if (msg.a.$ === 'None') {
							var _n3 = msg.a;
							var index = msg.b;
							var subMsg = msg.c;
							return A3(
								elm$browser$Debugger$Expando$Sequence,
								seqType,
								isClosed,
								A3(
									elm$browser$Debugger$Expando$updateIndex,
									index,
									elm$browser$Debugger$Expando$update(subMsg),
									valueList));
						} else {
							return value;
						}
					default:
						return value;
				}
			case 'Dictionary':
				var isClosed = value.a;
				var keyValuePairs = value.b;
				switch (msg.$) {
					case 'Toggle':
						return A2(elm$browser$Debugger$Expando$Dictionary, !isClosed, keyValuePairs);
					case 'Index':
						var redirect = msg.a;
						var index = msg.b;
						var subMsg = msg.c;
						switch (redirect.$) {
							case 'None':
								return value;
							case 'Key':
								return A2(
									elm$browser$Debugger$Expando$Dictionary,
									isClosed,
									A3(
										elm$browser$Debugger$Expando$updateIndex,
										index,
										function (_n6) {
											var k = _n6.a;
											var v = _n6.b;
											return _Utils_Tuple2(
												A2(elm$browser$Debugger$Expando$update, subMsg, k),
												v);
										},
										keyValuePairs));
							default:
								return A2(
									elm$browser$Debugger$Expando$Dictionary,
									isClosed,
									A3(
										elm$browser$Debugger$Expando$updateIndex,
										index,
										function (_n7) {
											var k = _n7.a;
											var v = _n7.b;
											return _Utils_Tuple2(
												k,
												A2(elm$browser$Debugger$Expando$update, subMsg, v));
										},
										keyValuePairs));
						}
					default:
						return value;
				}
			case 'Record':
				var isClosed = value.a;
				var valueDict = value.b;
				switch (msg.$) {
					case 'Toggle':
						return A2(elm$browser$Debugger$Expando$Record, !isClosed, valueDict);
					case 'Index':
						return value;
					default:
						var field = msg.a;
						var subMsg = msg.b;
						return A2(
							elm$browser$Debugger$Expando$Record,
							isClosed,
							A3(
								elm$core$Dict$update,
								field,
								elm$browser$Debugger$Expando$updateField(subMsg),
								valueDict));
				}
			default:
				var maybeName = value.a;
				var isClosed = value.b;
				var valueList = value.c;
				switch (msg.$) {
					case 'Toggle':
						return A3(elm$browser$Debugger$Expando$Constructor, maybeName, !isClosed, valueList);
					case 'Index':
						if (msg.a.$ === 'None') {
							var _n10 = msg.a;
							var index = msg.b;
							var subMsg = msg.c;
							return A3(
								elm$browser$Debugger$Expando$Constructor,
								maybeName,
								isClosed,
								A3(
									elm$browser$Debugger$Expando$updateIndex,
									index,
									elm$browser$Debugger$Expando$update(subMsg),
									valueList));
						} else {
							return value;
						}
					default:
						return value;
				}
		}
	});
var elm$browser$Debugger$Expando$updateField = F2(
	function (msg, maybeExpando) {
		if (maybeExpando.$ === 'Nothing') {
			return maybeExpando;
		} else {
			var expando = maybeExpando.a;
			return elm$core$Maybe$Just(
				A2(elm$browser$Debugger$Expando$update, msg, expando));
		}
	});
var elm$browser$Debugger$History$Snapshot = F2(
	function (model, messages) {
		return {messages: messages, model: model};
	});
var elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _n0 = A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, list);
			var jsArray = _n0.a;
			var remainingItems = _n0.b;
			if (_Utils_cmp(
				elm$core$Elm$JsArray$length(jsArray),
				elm$core$Array$branchFactor) < 0) {
				return A2(
					elm$core$Array$builderToArray,
					true,
					{nodeList: nodeList, nodeListSize: nodeListSize, tail: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					elm$core$List$cons,
					elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return elm$core$Array$empty;
	} else {
		return A3(elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var elm$browser$Debugger$History$addRecent = F3(
	function (msg, newModel, _n0) {
		var model = _n0.model;
		var messages = _n0.messages;
		var numMessages = _n0.numMessages;
		return _Utils_eq(numMessages, elm$browser$Debugger$History$maxSnapshotSize) ? _Utils_Tuple2(
			elm$core$Maybe$Just(
				A2(
					elm$browser$Debugger$History$Snapshot,
					model,
					elm$core$Array$fromList(messages))),
			A3(
				elm$browser$Debugger$History$RecentHistory,
				newModel,
				_List_fromArray(
					[msg]),
				1)) : _Utils_Tuple2(
			elm$core$Maybe$Nothing,
			A3(
				elm$browser$Debugger$History$RecentHistory,
				model,
				A2(elm$core$List$cons, msg, messages),
				numMessages + 1));
	});
var elm$core$Array$bitMask = 4294967295 >>> (32 - elm$core$Array$shiftStep);
var elm$core$Elm$JsArray$push = _JsArray_push;
var elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var elm$core$Array$insertTailInTree = F4(
	function (shift, index, tail, tree) {
		var pos = elm$core$Array$bitMask & (index >>> shift);
		if (_Utils_cmp(
			pos,
			elm$core$Elm$JsArray$length(tree)) > -1) {
			if (shift === 5) {
				return A2(
					elm$core$Elm$JsArray$push,
					elm$core$Array$Leaf(tail),
					tree);
			} else {
				var newSub = elm$core$Array$SubTree(
					A4(elm$core$Array$insertTailInTree, shift - elm$core$Array$shiftStep, index, tail, elm$core$Elm$JsArray$empty));
				return A2(elm$core$Elm$JsArray$push, newSub, tree);
			}
		} else {
			var value = A2(elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (value.$ === 'SubTree') {
				var subTree = value.a;
				var newSub = elm$core$Array$SubTree(
					A4(elm$core$Array$insertTailInTree, shift - elm$core$Array$shiftStep, index, tail, subTree));
				return A3(elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			} else {
				var newSub = elm$core$Array$SubTree(
					A4(
						elm$core$Array$insertTailInTree,
						shift - elm$core$Array$shiftStep,
						index,
						tail,
						elm$core$Elm$JsArray$singleton(value)));
				return A3(elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			}
		}
	});
var elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var elm$core$Array$unsafeReplaceTail = F2(
	function (newTail, _n0) {
		var len = _n0.a;
		var startShift = _n0.b;
		var tree = _n0.c;
		var tail = _n0.d;
		var originalTailLen = elm$core$Elm$JsArray$length(tail);
		var newTailLen = elm$core$Elm$JsArray$length(newTail);
		var newArrayLen = len + (newTailLen - originalTailLen);
		if (_Utils_eq(newTailLen, elm$core$Array$branchFactor)) {
			var overflow = _Utils_cmp(newArrayLen >>> elm$core$Array$shiftStep, 1 << startShift) > 0;
			if (overflow) {
				var newShift = startShift + elm$core$Array$shiftStep;
				var newTree = A4(
					elm$core$Array$insertTailInTree,
					newShift,
					len,
					newTail,
					elm$core$Elm$JsArray$singleton(
						elm$core$Array$SubTree(tree)));
				return A4(elm$core$Array$Array_elm_builtin, newArrayLen, newShift, newTree, elm$core$Elm$JsArray$empty);
			} else {
				return A4(
					elm$core$Array$Array_elm_builtin,
					newArrayLen,
					startShift,
					A4(elm$core$Array$insertTailInTree, startShift, len, newTail, tree),
					elm$core$Elm$JsArray$empty);
			}
		} else {
			return A4(elm$core$Array$Array_elm_builtin, newArrayLen, startShift, tree, newTail);
		}
	});
var elm$core$Array$push = F2(
	function (a, array) {
		var tail = array.d;
		return A2(
			elm$core$Array$unsafeReplaceTail,
			A2(elm$core$Elm$JsArray$push, a, tail),
			array);
	});
var elm$browser$Debugger$History$add = F3(
	function (msg, model, _n0) {
		var snapshots = _n0.snapshots;
		var recent = _n0.recent;
		var numMessages = _n0.numMessages;
		var _n1 = A3(elm$browser$Debugger$History$addRecent, msg, model, recent);
		if (_n1.a.$ === 'Just') {
			var snapshot = _n1.a.a;
			var newRecent = _n1.b;
			return A3(
				elm$browser$Debugger$History$History,
				A2(elm$core$Array$push, snapshot, snapshots),
				newRecent,
				numMessages + 1);
		} else {
			var _n2 = _n1.a;
			var newRecent = _n1.b;
			return A3(elm$browser$Debugger$History$History, snapshots, newRecent, numMessages + 1);
		}
	});
var elm$browser$Debugger$History$Stepping = F2(
	function (a, b) {
		return {$: 'Stepping', a: a, b: b};
	});
var elm$browser$Debugger$History$Done = F2(
	function (a, b) {
		return {$: 'Done', a: a, b: b};
	});
var elm$browser$Debugger$History$getHelp = F3(
	function (update, msg, getResult) {
		if (getResult.$ === 'Done') {
			return getResult;
		} else {
			var n = getResult.a;
			var model = getResult.b;
			return (!n) ? A2(
				elm$browser$Debugger$History$Done,
				msg,
				A2(update, msg, model).a) : A2(
				elm$browser$Debugger$History$Stepping,
				n - 1,
				A2(update, msg, model).a);
		}
	});
var elm$browser$Debugger$History$undone = function (getResult) {
	undone:
	while (true) {
		if (getResult.$ === 'Done') {
			var msg = getResult.a;
			var model = getResult.b;
			return _Utils_Tuple2(model, msg);
		} else {
			var $temp$getResult = getResult;
			getResult = $temp$getResult;
			continue undone;
		}
	}
};
var elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = elm$core$Array$bitMask & (index >>> shift);
			var _n0 = A2(elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (_n0.$ === 'SubTree') {
				var subTree = _n0.a;
				var $temp$shift = shift - elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _n0.a;
				return A2(elm$core$Elm$JsArray$unsafeGet, elm$core$Array$bitMask & index, values);
			}
		}
	});
var elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var elm$core$Array$get = F2(
	function (index, _n0) {
		var len = _n0.a;
		var startShift = _n0.b;
		var tree = _n0.c;
		var tail = _n0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			elm$core$Array$tailIndex(len)) > -1) ? elm$core$Maybe$Just(
			A2(elm$core$Elm$JsArray$unsafeGet, elm$core$Array$bitMask & index, tail)) : elm$core$Maybe$Just(
			A3(elm$core$Array$getHelp, startShift, index, tree)));
	});
var elm$browser$Debugger$History$get = F3(
	function (update, index, history) {
		get:
		while (true) {
			var recent = history.recent;
			var snapshotMax = history.numMessages - recent.numMessages;
			if (_Utils_cmp(index, snapshotMax) > -1) {
				return elm$browser$Debugger$History$undone(
					A3(
						elm$core$List$foldr,
						elm$browser$Debugger$History$getHelp(update),
						A2(elm$browser$Debugger$History$Stepping, index - snapshotMax, recent.model),
						recent.messages));
			} else {
				var _n0 = A2(elm$core$Array$get, (index / elm$browser$Debugger$History$maxSnapshotSize) | 0, history.snapshots);
				if (_n0.$ === 'Nothing') {
					var $temp$update = update,
						$temp$index = index,
						$temp$history = history;
					update = $temp$update;
					index = $temp$index;
					history = $temp$history;
					continue get;
				} else {
					var model = _n0.a.model;
					var messages = _n0.a.messages;
					return elm$browser$Debugger$History$undone(
						A3(
							elm$core$Array$foldr,
							elm$browser$Debugger$History$getHelp(update),
							A2(elm$browser$Debugger$History$Stepping, index % elm$browser$Debugger$History$maxSnapshotSize, model),
							messages));
				}
			}
		}
	});
var elm$browser$Debugger$Main$Paused = F3(
	function (a, b, c) {
		return {$: 'Paused', a: a, b: b, c: c};
	});
var elm$browser$Debugger$History$elmToJs = _Debugger_unsafeCoerce;
var elm$browser$Debugger$History$encodeHelp = F2(
	function (snapshot, allMessages) {
		return A3(elm$core$Array$foldl, elm$core$List$cons, allMessages, snapshot.messages);
	});
var elm$browser$Debugger$History$encode = function (_n0) {
	var snapshots = _n0.snapshots;
	var recent = _n0.recent;
	return A2(
		elm$json$Json$Encode$list,
		elm$browser$Debugger$History$elmToJs,
		A3(
			elm$core$Array$foldr,
			elm$browser$Debugger$History$encodeHelp,
			elm$core$List$reverse(recent.messages),
			snapshots));
};
var elm$browser$Debugger$Metadata$encodeAlias = function (_n0) {
	var args = _n0.args;
	var tipe = _n0.tipe;
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'args',
				A2(elm$json$Json$Encode$list, elm$json$Json$Encode$string, args)),
				_Utils_Tuple2(
				'type',
				elm$json$Json$Encode$string(tipe))
			]));
};
var elm$browser$Debugger$Metadata$encodeDict = F2(
	function (f, dict) {
		return elm$json$Json$Encode$object(
			elm$core$Dict$toList(
				A2(
					elm$core$Dict$map,
					F2(
						function (key, value) {
							return f(value);
						}),
					dict)));
	});
var elm$browser$Debugger$Metadata$encodeUnion = function (_n0) {
	var args = _n0.args;
	var tags = _n0.tags;
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'args',
				A2(elm$json$Json$Encode$list, elm$json$Json$Encode$string, args)),
				_Utils_Tuple2(
				'tags',
				A2(
					elm$browser$Debugger$Metadata$encodeDict,
					elm$json$Json$Encode$list(elm$json$Json$Encode$string),
					tags))
			]));
};
var elm$browser$Debugger$Metadata$encodeTypes = function (_n0) {
	var message = _n0.message;
	var unions = _n0.unions;
	var aliases = _n0.aliases;
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'message',
				elm$json$Json$Encode$string(message)),
				_Utils_Tuple2(
				'aliases',
				A2(elm$browser$Debugger$Metadata$encodeDict, elm$browser$Debugger$Metadata$encodeAlias, aliases)),
				_Utils_Tuple2(
				'unions',
				A2(elm$browser$Debugger$Metadata$encodeDict, elm$browser$Debugger$Metadata$encodeUnion, unions))
			]));
};
var elm$browser$Debugger$Metadata$encodeVersions = function (_n0) {
	var elm = _n0.elm;
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'elm',
				elm$json$Json$Encode$string(elm))
			]));
};
var elm$browser$Debugger$Metadata$encode = function (_n0) {
	var versions = _n0.versions;
	var types = _n0.types;
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'versions',
				elm$browser$Debugger$Metadata$encodeVersions(versions)),
				_Utils_Tuple2(
				'types',
				elm$browser$Debugger$Metadata$encodeTypes(types))
			]));
};
var elm$browser$Debugger$Main$download = F2(
	function (metadata, history) {
		var json = elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'metadata',
					elm$browser$Debugger$Metadata$encode(metadata)),
					_Utils_Tuple2(
					'history',
					elm$browser$Debugger$History$encode(history))
				]));
		var historyLength = elm$browser$Debugger$History$size(history);
		return A2(
			elm$core$Task$perform,
			function (_n0) {
				return elm$browser$Debugger$Main$NoOp;
			},
			A2(_Debugger_download, historyLength, json));
	});
var elm$browser$Debugger$History$jsToElm = _Debugger_unsafeCoerce;
var elm$browser$Debugger$History$decoder = F2(
	function (initialModel, update) {
		var addMessage = F2(
			function (rawMsg, _n0) {
				var model = _n0.a;
				var history = _n0.b;
				var msg = elm$browser$Debugger$History$jsToElm(rawMsg);
				return _Utils_Tuple2(
					A2(update, msg, model),
					A3(elm$browser$Debugger$History$add, msg, model, history));
			});
		var updateModel = function (rawMsgs) {
			return A3(
				elm$core$List$foldl,
				addMessage,
				_Utils_Tuple2(
					initialModel,
					elm$browser$Debugger$History$empty(initialModel)),
				rawMsgs);
		};
		return A2(
			elm$json$Json$Decode$map,
			updateModel,
			elm$json$Json$Decode$list(elm$json$Json$Decode$value));
	});
var elm$browser$Debugger$History$getInitialModel = function (_n0) {
	var snapshots = _n0.snapshots;
	var recent = _n0.recent;
	var _n1 = A2(elm$core$Array$get, 0, snapshots);
	if (_n1.$ === 'Just') {
		var model = _n1.a.model;
		return model;
	} else {
		return recent.model;
	}
};
var elm$browser$Debugger$Overlay$BadImport = function (a) {
	return {$: 'BadImport', a: a};
};
var elm$browser$Debugger$Report$CorruptHistory = {$: 'CorruptHistory'};
var elm$browser$Debugger$Overlay$corruptImport = elm$browser$Debugger$Overlay$BadImport(elm$browser$Debugger$Report$CorruptHistory);
var elm$core$Platform$Cmd$batch = _Platform_batch;
var elm$core$Platform$Cmd$none = elm$core$Platform$Cmd$batch(_List_Nil);
var elm$browser$Debugger$Main$loadNewHistory = F3(
	function (rawHistory, update, model) {
		var pureUserUpdate = F2(
			function (msg, userModel) {
				return A2(update, msg, userModel).a;
			});
		var initialUserModel = elm$browser$Debugger$History$getInitialModel(model.history);
		var decoder = A2(elm$browser$Debugger$History$decoder, initialUserModel, pureUserUpdate);
		var _n0 = A2(elm$json$Json$Decode$decodeValue, decoder, rawHistory);
		if (_n0.$ === 'Err') {
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{overlay: elm$browser$Debugger$Overlay$corruptImport}),
				elm$core$Platform$Cmd$none);
		} else {
			var _n1 = _n0.a;
			var latestUserModel = _n1.a;
			var newHistory = _n1.b;
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{
						expando: elm$browser$Debugger$Expando$init(latestUserModel),
						history: newHistory,
						overlay: elm$browser$Debugger$Overlay$none,
						state: elm$browser$Debugger$Main$Running(latestUserModel)
					}),
				elm$core$Platform$Cmd$none);
		}
	});
var elm$browser$Debugger$Main$scroll = function (popout) {
	return A2(
		elm$core$Task$perform,
		elm$core$Basics$always(elm$browser$Debugger$Main$NoOp),
		_Debugger_scroll(popout));
};
var elm$browser$Debugger$Main$Upload = function (a) {
	return {$: 'Upload', a: a};
};
var elm$browser$Debugger$Main$upload = A2(
	elm$core$Task$perform,
	elm$browser$Debugger$Main$Upload,
	_Debugger_upload(_Utils_Tuple0));
var elm$browser$Debugger$Overlay$BadMetadata = function (a) {
	return {$: 'BadMetadata', a: a};
};
var elm$browser$Debugger$Overlay$badMetadata = elm$browser$Debugger$Overlay$BadMetadata;
var elm$browser$Debugger$Main$withGoodMetadata = F2(
	function (model, func) {
		var _n0 = model.metadata;
		if (_n0.$ === 'Ok') {
			var metadata = _n0.a;
			return func(metadata);
		} else {
			var error = _n0.a;
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{
						overlay: elm$browser$Debugger$Overlay$badMetadata(error)
					}),
				elm$core$Platform$Cmd$none);
		}
	});
var elm$browser$Debugger$Report$AliasChange = function (a) {
	return {$: 'AliasChange', a: a};
};
var elm$browser$Debugger$Metadata$checkAlias = F4(
	function (name, old, _new, changes) {
		return (_Utils_eq(old.tipe, _new.tipe) && _Utils_eq(old.args, _new.args)) ? changes : A2(
			elm$core$List$cons,
			elm$browser$Debugger$Report$AliasChange(name),
			changes);
	});
var elm$browser$Debugger$Metadata$addTag = F3(
	function (tag, _n0, changes) {
		return _Utils_update(
			changes,
			{
				added: A2(elm$core$List$cons, tag, changes.added)
			});
	});
var elm$browser$Debugger$Metadata$checkTag = F4(
	function (tag, old, _new, changes) {
		return _Utils_eq(old, _new) ? changes : _Utils_update(
			changes,
			{
				changed: A2(elm$core$List$cons, tag, changes.changed)
			});
	});
var elm$browser$Debugger$Metadata$removeTag = F3(
	function (tag, _n0, changes) {
		return _Utils_update(
			changes,
			{
				removed: A2(elm$core$List$cons, tag, changes.removed)
			});
	});
var elm$browser$Debugger$Report$UnionChange = F2(
	function (a, b) {
		return {$: 'UnionChange', a: a, b: b};
	});
var elm$browser$Debugger$Report$TagChanges = F4(
	function (removed, changed, added, argsMatch) {
		return {added: added, argsMatch: argsMatch, changed: changed, removed: removed};
	});
var elm$browser$Debugger$Report$emptyTagChanges = function (argsMatch) {
	return A4(elm$browser$Debugger$Report$TagChanges, _List_Nil, _List_Nil, _List_Nil, argsMatch);
};
var elm$browser$Debugger$Report$hasTagChanges = function (tagChanges) {
	return _Utils_eq(
		tagChanges,
		A4(elm$browser$Debugger$Report$TagChanges, _List_Nil, _List_Nil, _List_Nil, true));
};
var elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _n0) {
				stepState:
				while (true) {
					var list = _n0.a;
					var result = _n0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _n2 = list.a;
						var lKey = _n2.a;
						var lValue = _n2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_n0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_n0 = $temp$_n0;
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
		var _n3 = A3(
			elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _n3.a;
		var intermediateResult = _n3.b;
		return A3(
			elm$core$List$foldl,
			F2(
				function (_n4, result) {
					var k = _n4.a;
					var v = _n4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var elm$browser$Debugger$Metadata$checkUnion = F4(
	function (name, old, _new, changes) {
		var tagChanges = A6(
			elm$core$Dict$merge,
			elm$browser$Debugger$Metadata$removeTag,
			elm$browser$Debugger$Metadata$checkTag,
			elm$browser$Debugger$Metadata$addTag,
			old.tags,
			_new.tags,
			elm$browser$Debugger$Report$emptyTagChanges(
				_Utils_eq(old.args, _new.args)));
		return elm$browser$Debugger$Report$hasTagChanges(tagChanges) ? changes : A2(
			elm$core$List$cons,
			A2(elm$browser$Debugger$Report$UnionChange, name, tagChanges),
			changes);
	});
var elm$browser$Debugger$Metadata$ignore = F3(
	function (key, value, report) {
		return report;
	});
var elm$browser$Debugger$Report$MessageChanged = F2(
	function (a, b) {
		return {$: 'MessageChanged', a: a, b: b};
	});
var elm$browser$Debugger$Report$SomethingChanged = function (a) {
	return {$: 'SomethingChanged', a: a};
};
var elm$browser$Debugger$Metadata$checkTypes = F2(
	function (old, _new) {
		return (!_Utils_eq(old.message, _new.message)) ? A2(elm$browser$Debugger$Report$MessageChanged, old.message, _new.message) : elm$browser$Debugger$Report$SomethingChanged(
			A6(
				elm$core$Dict$merge,
				elm$browser$Debugger$Metadata$ignore,
				elm$browser$Debugger$Metadata$checkUnion,
				elm$browser$Debugger$Metadata$ignore,
				old.unions,
				_new.unions,
				A6(elm$core$Dict$merge, elm$browser$Debugger$Metadata$ignore, elm$browser$Debugger$Metadata$checkAlias, elm$browser$Debugger$Metadata$ignore, old.aliases, _new.aliases, _List_Nil)));
	});
var elm$browser$Debugger$Report$VersionChanged = F2(
	function (a, b) {
		return {$: 'VersionChanged', a: a, b: b};
	});
var elm$browser$Debugger$Metadata$check = F2(
	function (old, _new) {
		return (!_Utils_eq(old.versions.elm, _new.versions.elm)) ? A2(elm$browser$Debugger$Report$VersionChanged, old.versions.elm, _new.versions.elm) : A2(elm$browser$Debugger$Metadata$checkTypes, old.types, _new.types);
	});
var elm$browser$Debugger$Overlay$RiskyImport = F2(
	function (a, b) {
		return {$: 'RiskyImport', a: a, b: b};
	});
var elm$browser$Debugger$Overlay$uploadDecoder = A3(
	elm$json$Json$Decode$map2,
	F2(
		function (x, y) {
			return _Utils_Tuple2(x, y);
		}),
	A2(elm$json$Json$Decode$field, 'metadata', elm$browser$Debugger$Metadata$decoder),
	A2(elm$json$Json$Decode$field, 'history', elm$json$Json$Decode$value));
var elm$browser$Debugger$Report$Fine = {$: 'Fine'};
var elm$browser$Debugger$Report$Impossible = {$: 'Impossible'};
var elm$browser$Debugger$Report$Risky = {$: 'Risky'};
var elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var elm$browser$Debugger$Report$some = function (list) {
	return !elm$core$List$isEmpty(list);
};
var elm$browser$Debugger$Report$evaluateChange = function (change) {
	if (change.$ === 'AliasChange') {
		return elm$browser$Debugger$Report$Impossible;
	} else {
		var removed = change.b.removed;
		var changed = change.b.changed;
		var added = change.b.added;
		var argsMatch = change.b.argsMatch;
		return ((!argsMatch) || (elm$browser$Debugger$Report$some(changed) || elm$browser$Debugger$Report$some(removed))) ? elm$browser$Debugger$Report$Impossible : (elm$browser$Debugger$Report$some(added) ? elm$browser$Debugger$Report$Risky : elm$browser$Debugger$Report$Fine);
	}
};
var elm$browser$Debugger$Report$worstCase = F2(
	function (status, statusList) {
		worstCase:
		while (true) {
			if (!statusList.b) {
				return status;
			} else {
				switch (statusList.a.$) {
					case 'Impossible':
						var _n1 = statusList.a;
						return elm$browser$Debugger$Report$Impossible;
					case 'Risky':
						var _n2 = statusList.a;
						var rest = statusList.b;
						var $temp$status = elm$browser$Debugger$Report$Risky,
							$temp$statusList = rest;
						status = $temp$status;
						statusList = $temp$statusList;
						continue worstCase;
					default:
						var _n3 = statusList.a;
						var rest = statusList.b;
						var $temp$status = status,
							$temp$statusList = rest;
						status = $temp$status;
						statusList = $temp$statusList;
						continue worstCase;
				}
			}
		}
	});
var elm$browser$Debugger$Report$evaluate = function (report) {
	switch (report.$) {
		case 'CorruptHistory':
			return elm$browser$Debugger$Report$Impossible;
		case 'VersionChanged':
			return elm$browser$Debugger$Report$Impossible;
		case 'MessageChanged':
			return elm$browser$Debugger$Report$Impossible;
		default:
			var changes = report.a;
			return A2(
				elm$browser$Debugger$Report$worstCase,
				elm$browser$Debugger$Report$Fine,
				A2(elm$core$List$map, elm$browser$Debugger$Report$evaluateChange, changes));
	}
};
var elm$browser$Debugger$Overlay$assessImport = F2(
	function (metadata, jsonString) {
		var _n0 = A2(elm$json$Json$Decode$decodeString, elm$browser$Debugger$Overlay$uploadDecoder, jsonString);
		if (_n0.$ === 'Err') {
			return elm$core$Result$Err(elm$browser$Debugger$Overlay$corruptImport);
		} else {
			var _n1 = _n0.a;
			var foreignMetadata = _n1.a;
			var rawHistory = _n1.b;
			var report = A2(elm$browser$Debugger$Metadata$check, foreignMetadata, metadata);
			var _n2 = elm$browser$Debugger$Report$evaluate(report);
			switch (_n2.$) {
				case 'Impossible':
					return elm$core$Result$Err(
						elm$browser$Debugger$Overlay$BadImport(report));
				case 'Risky':
					return elm$core$Result$Err(
						A2(elm$browser$Debugger$Overlay$RiskyImport, report, rawHistory));
				default:
					return elm$core$Result$Ok(rawHistory);
			}
		}
	});
var elm$browser$Debugger$Overlay$close = F2(
	function (msg, state) {
		switch (state.$) {
			case 'None':
				return elm$core$Maybe$Nothing;
			case 'BadMetadata':
				return elm$core$Maybe$Nothing;
			case 'BadImport':
				return elm$core$Maybe$Nothing;
			default:
				var rawHistory = state.b;
				if (msg.$ === 'Cancel') {
					return elm$core$Maybe$Nothing;
				} else {
					return elm$core$Maybe$Just(rawHistory);
				}
		}
	});
var elm$browser$Debugger$Main$wrapUpdate = F3(
	function (update, msg, model) {
		wrapUpdate:
		while (true) {
			switch (msg.$) {
				case 'NoOp':
					return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
				case 'UserMsg':
					var userMsg = msg.a;
					var userModel = elm$browser$Debugger$Main$getLatestModel(model.state);
					var newHistory = A3(elm$browser$Debugger$History$add, userMsg, userModel, model.history);
					var _n1 = A2(update, userMsg, userModel);
					var newUserModel = _n1.a;
					var userCmds = _n1.b;
					var commands = A2(elm$core$Platform$Cmd$map, elm$browser$Debugger$Main$UserMsg, userCmds);
					var _n2 = model.state;
					if (_n2.$ === 'Running') {
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									expando: A2(elm$browser$Debugger$Expando$merge, newUserModel, model.expando),
									history: newHistory,
									state: elm$browser$Debugger$Main$Running(newUserModel)
								}),
							elm$core$Platform$Cmd$batch(
								_List_fromArray(
									[
										commands,
										elm$browser$Debugger$Main$scroll(model.popout)
									])));
					} else {
						var index = _n2.a;
						var indexModel = _n2.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									history: newHistory,
									state: A3(elm$browser$Debugger$Main$Paused, index, indexModel, newUserModel)
								}),
							commands);
					}
				case 'ExpandoMsg':
					var eMsg = msg.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								expando: A2(elm$browser$Debugger$Expando$update, eMsg, model.expando)
							}),
						elm$core$Platform$Cmd$none);
				case 'Resume':
					var _n3 = model.state;
					if (_n3.$ === 'Running') {
						return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
					} else {
						var userModel = _n3.c;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									expando: A2(elm$browser$Debugger$Expando$merge, userModel, model.expando),
									state: elm$browser$Debugger$Main$Running(userModel)
								}),
							elm$browser$Debugger$Main$scroll(model.popout));
					}
				case 'Jump':
					var index = msg.a;
					var _n4 = A3(elm$browser$Debugger$History$get, update, index, model.history);
					var indexModel = _n4.a;
					var indexMsg = _n4.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								expando: A2(elm$browser$Debugger$Expando$merge, indexModel, model.expando),
								state: A3(
									elm$browser$Debugger$Main$Paused,
									index,
									indexModel,
									elm$browser$Debugger$Main$getLatestModel(model.state))
							}),
						elm$core$Platform$Cmd$none);
				case 'Open':
					return _Utils_Tuple2(
						model,
						A2(
							elm$core$Task$perform,
							function (_n5) {
								return elm$browser$Debugger$Main$NoOp;
							},
							_Debugger_open(model.popout)));
				case 'Up':
					var index = function () {
						var _n6 = model.state;
						if (_n6.$ === 'Paused') {
							var i = _n6.a;
							return i;
						} else {
							return elm$browser$Debugger$History$size(model.history);
						}
					}();
					if (index > 0) {
						var $temp$update = update,
							$temp$msg = elm$browser$Debugger$Main$Jump(index - 1),
							$temp$model = model;
						update = $temp$update;
						msg = $temp$msg;
						model = $temp$model;
						continue wrapUpdate;
					} else {
						return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
					}
				case 'Down':
					var _n7 = model.state;
					if (_n7.$ === 'Running') {
						return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
					} else {
						var index = _n7.a;
						var userModel = _n7.c;
						if (_Utils_eq(
							index,
							elm$browser$Debugger$History$size(model.history) - 1)) {
							var $temp$update = update,
								$temp$msg = elm$browser$Debugger$Main$Resume,
								$temp$model = model;
							update = $temp$update;
							msg = $temp$msg;
							model = $temp$model;
							continue wrapUpdate;
						} else {
							var $temp$update = update,
								$temp$msg = elm$browser$Debugger$Main$Jump(index + 1),
								$temp$model = model;
							update = $temp$update;
							msg = $temp$msg;
							model = $temp$model;
							continue wrapUpdate;
						}
					}
				case 'Import':
					return A2(
						elm$browser$Debugger$Main$withGoodMetadata,
						model,
						function (_n8) {
							return _Utils_Tuple2(model, elm$browser$Debugger$Main$upload);
						});
				case 'Export':
					return A2(
						elm$browser$Debugger$Main$withGoodMetadata,
						model,
						function (metadata) {
							return _Utils_Tuple2(
								model,
								A2(elm$browser$Debugger$Main$download, metadata, model.history));
						});
				case 'Upload':
					var jsonString = msg.a;
					return A2(
						elm$browser$Debugger$Main$withGoodMetadata,
						model,
						function (metadata) {
							var _n9 = A2(elm$browser$Debugger$Overlay$assessImport, metadata, jsonString);
							if (_n9.$ === 'Err') {
								var newOverlay = _n9.a;
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{overlay: newOverlay}),
									elm$core$Platform$Cmd$none);
							} else {
								var rawHistory = _n9.a;
								return A3(elm$browser$Debugger$Main$loadNewHistory, rawHistory, update, model);
							}
						});
				default:
					var overlayMsg = msg.a;
					var _n10 = A2(elm$browser$Debugger$Overlay$close, overlayMsg, model.overlay);
					if (_n10.$ === 'Nothing') {
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{overlay: elm$browser$Debugger$Overlay$none}),
							elm$core$Platform$Cmd$none);
					} else {
						var rawHistory = _n10.a;
						return A3(elm$browser$Debugger$Main$loadNewHistory, rawHistory, update, model);
					}
			}
		}
	});
var elm$core$Set$foldr = F3(
	function (func, initialState, _n0) {
		var dict = _n0.a;
		return A3(
			elm$core$Dict$foldr,
			F3(
				function (key, _n1, state) {
					return A2(func, key, state);
				}),
			initialState,
			dict);
	});
var elm$browser$Browser$Dom$focus = _Browser_call('focus');
var elm$core$Task$onError = _Scheduler_onError;
var elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return elm$core$Task$command(
			elm$core$Task$Perform(
				A2(
					elm$core$Task$onError,
					A2(
						elm$core$Basics$composeL,
						A2(elm$core$Basics$composeL, elm$core$Task$succeed, resultToMessage),
						elm$core$Result$Err),
					A2(
						elm$core$Task$andThen,
						A2(
							elm$core$Basics$composeL,
							A2(elm$core$Basics$composeL, elm$core$Task$succeed, resultToMessage),
							elm$core$Result$Ok),
						task))));
	});
var elm_community$intdict$IntDict$remove = F2(
	function (key, dict) {
		return A3(
			elm_community$intdict$IntDict$update,
			key,
			elm$core$Basics$always(elm$core$Maybe$Nothing),
			dict);
	});
var author$project$TaskList$update = F4(
	function (msg, state, app, env) {
		switch (msg.$) {
			case 'Add':
				if (state.c === '') {
					var filters = state.a;
					return _Utils_Tuple3(
						A3(author$project$TaskList$Normal, filters, elm$core$Maybe$Nothing, ''),
						app,
						elm$core$Platform$Cmd$none);
				} else {
					var filters = state.a;
					var newTaskTitle = state.c;
					return _Utils_Tuple3(
						A3(author$project$TaskList$Normal, filters, elm$core$Maybe$Nothing, ''),
						_Utils_update(
							app,
							{
								tasks: A3(
									elm_community$intdict$IntDict$insert,
									author$project$SmartTime$Moment$toSmartInt(env.time),
									A2(
										author$project$Task$Task$newTask,
										newTaskTitle,
										author$project$SmartTime$Moment$toSmartInt(env.time)),
									app.tasks)
							}),
						elm$core$Platform$Cmd$none);
				}
			case 'UpdateNewEntryField':
				var typedSoFar = msg.a;
				return _Utils_Tuple3(
					function () {
						var _n2 = state;
						var filters = _n2.a;
						var expanded = _n2.b;
						return A3(author$project$TaskList$Normal, filters, expanded, typedSoFar);
					}(),
					app,
					elm$core$Platform$Cmd$none);
			case 'EditingTitle':
				var id = msg.a;
				var isEditing = msg.b;
				var updateTask = function (t) {
					return t;
				};
				var focus = elm$browser$Browser$Dom$focus(
					'task-' + elm$core$String$fromInt(id));
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							tasks: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTask),
								app.tasks)
						}),
					A2(
						elm$core$Task$attempt,
						function (_n3) {
							return author$project$TaskList$NoOp;
						},
						focus));
			case 'UpdateTask':
				var id = msg.a;
				var task = msg.b;
				var updateTask = function (t) {
					return _Utils_update(
						t,
						{title: task});
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							tasks: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTask),
								app.tasks)
						}),
					elm$core$Platform$Cmd$none);
			case 'UpdateTaskDate':
				var id = msg.a;
				var field = msg.b;
				var date = msg.c;
				var updateTask = function (t) {
					return _Utils_update(
						t,
						{deadline: date});
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							tasks: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTask),
								app.tasks)
						}),
					elm$core$Platform$Cmd$none);
			case 'Delete':
				var id = msg.a;
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							tasks: A2(elm_community$intdict$IntDict$remove, id, app.tasks)
						}),
					elm$core$Platform$Cmd$none);
			case 'DeleteComplete':
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							tasks: A2(
								elm_community$intdict$IntDict$filter,
								F2(
									function (_n4, t) {
										return !author$project$Task$Task$completed(t);
									}),
								app.tasks)
						}),
					elm$core$Platform$Cmd$none);
			case 'UpdateProgress':
				var id = msg.a;
				var new_completion = msg.b;
				var updateTask = function (t) {
					return _Utils_update(
						t,
						{completion: new_completion});
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							tasks: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTask),
								app.tasks)
						}),
					elm$core$Platform$Cmd$none);
			case 'FocusSlider':
				var task = msg.a;
				var focused = msg.b;
				return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
		}
	});
var author$project$Activity$Activity$latestSwitch = function (timeline) {
	return A2(
		elm$core$Maybe$withDefault,
		A2(
			author$project$Activity$Activity$Switch,
			author$project$SmartTime$Moment$zero,
			author$project$ID$tag(0)),
		elm$core$List$head(timeline));
};
var author$project$Activity$Activity$currentActivityID = function (switchList) {
	var getId = function (_n0) {
		var activityId = _n0.b;
		return activityId;
	};
	return getId(
		author$project$Activity$Activity$latestSwitch(switchList));
};
var author$project$Activity$Switching$currentActivityFromApp = function (app) {
	return author$project$Activity$Activity$currentActivityID(app.timeline);
};
var author$project$ID$read = function (_n0) {
	var _int = _n0.a;
	return _int;
};
var author$project$Activity$Activity$getActivity = F2(
	function (activityId, activities) {
		var _n0 = A2(
			elm_community$intdict$IntDict$get,
			author$project$ID$read(activityId),
			activities);
		if (_n0.$ === 'Just') {
			var activity = _n0.a;
			return activity;
		} else {
			return author$project$Activity$Activity$defaults(author$project$Activity$Template$DillyDally);
		}
	});
var author$project$Activity$Activity$getName = function (activity) {
	return A2(
		elm$core$Maybe$withDefault,
		'?',
		elm$core$List$head(activity.names));
};
var author$project$Activity$Activity$excusableFor = function (activity) {
	var _n0 = activity.excusable;
	switch (_n0.$) {
		case 'NeverExcused':
			return _Utils_Tuple2(
				author$project$SmartTime$Human$Duration$Minutes(0),
				author$project$SmartTime$Human$Duration$Minutes(0));
		case 'TemporarilyExcused':
			var durationPerPeriod = _n0.a;
			return durationPerPeriod;
		default:
			return _Utils_Tuple2(
				author$project$SmartTime$Human$Duration$Hours(24),
				author$project$SmartTime$Human$Duration$Hours(24));
	}
};
var author$project$Activity$Measure$excusableLimit = function (activity) {
	return author$project$SmartTime$Human$Duration$dur(
		author$project$Activity$Activity$excusableFor(activity).a);
};
var author$project$SmartTime$Duration$subtract = F2(
	function (_n0, _n1) {
		var int1 = _n0.a;
		var int2 = _n1.a;
		return author$project$SmartTime$Duration$Duration(int1 - int2);
	});
var author$project$SmartTime$Moment$past = F2(
	function (_n0, duration) {
		var time = _n0.a;
		return author$project$SmartTime$Moment$Moment(
			A2(author$project$SmartTime$Duration$subtract, time, duration));
	});
var author$project$Activity$Measure$lookBack = F2(
	function (present, humanDuration) {
		return A2(
			author$project$SmartTime$Moment$past,
			present,
			author$project$SmartTime$Human$Duration$dur(humanDuration));
	});
var author$project$Activity$Activity$dummy = author$project$ID$tag(0);
var author$project$SmartTime$Moment$compare = F2(
	function (_n0, _n1) {
		var time1 = _n0.a;
		var time2 = _n1.a;
		return A2(
			elm$core$Basics$compare,
			author$project$SmartTime$Duration$inMs(time1),
			author$project$SmartTime$Duration$inMs(time2));
	});
var elm$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _n0) {
				var trues = _n0.a;
				var falses = _n0.b;
				return pred(x) ? _Utils_Tuple2(
					A2(elm$core$List$cons, x, trues),
					falses) : _Utils_Tuple2(
					trues,
					A2(elm$core$List$cons, x, falses));
			});
		return A3(
			elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, _List_Nil),
			list);
	});
var author$project$Activity$Measure$timelineLimit = F3(
	function (timeline, now, pastLimit) {
		var switchActivityID = function (_n2) {
			var id = _n2.b;
			return id;
		};
		var recentEnough = function (_n1) {
			var moment = _n1.a;
			return _Utils_eq(
				A2(author$project$SmartTime$Moment$compare, moment, pastLimit),
				elm$core$Basics$GT);
		};
		var _n0 = A2(elm$core$List$partition, recentEnough, timeline);
		var pass = _n0.a;
		var fail = _n0.b;
		var justMissedId = A2(
			elm$core$Maybe$withDefault,
			author$project$Activity$Activity$dummy,
			A2(
				elm$core$Maybe$map,
				switchActivityID,
				elm$core$List$head(fail)));
		var fakeEndSwitch = A2(author$project$Activity$Activity$Switch, pastLimit, justMissedId);
		return _Utils_ap(
			pass,
			_List_fromArray(
				[fakeEndSwitch]));
	});
var author$project$Activity$Measure$relevantTimeline = F3(
	function (timeline, now, duration) {
		return A3(
			author$project$Activity$Measure$timelineLimit,
			timeline,
			now,
			A2(author$project$Activity$Measure$lookBack, now, duration));
	});
var elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var author$project$SmartTime$Duration$difference = F2(
	function (_n0, _n1) {
		var int1 = _n0.a;
		var int2 = _n1.a;
		return author$project$SmartTime$Duration$Duration(
			elm$core$Basics$abs(int1 - int2));
	});
var author$project$SmartTime$Moment$difference = F2(
	function (_n0, _n1) {
		var time1 = _n0.a;
		var time2 = _n1.a;
		return A2(author$project$SmartTime$Duration$difference, time1, time2);
	});
var author$project$Activity$Measure$session = F2(
	function (_n0, _n1) {
		var newer = _n0.a;
		var older = _n1.a;
		var activityId = _n1.b;
		return _Utils_Tuple2(
			activityId,
			A2(author$project$SmartTime$Moment$difference, newer, older));
	});
var elm$core$List$drop = F2(
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
var author$project$Activity$Measure$allSessions = function (switchList) {
	var offsetList = A2(elm$core$List$drop, 1, switchList);
	return A3(elm$core$List$map2, author$project$Activity$Measure$session, switchList, offsetList);
};
var author$project$Activity$Measure$isMatchingDuration = F2(
	function (targetId, _n0) {
		var itemId = _n0.a;
		var dur = _n0.b;
		return _Utils_eq(itemId, targetId) ? elm$core$Maybe$Just(dur) : elm$core$Maybe$Nothing;
	});
var author$project$Activity$Measure$sessions = F2(
	function (switchList, activityId) {
		var all = author$project$Activity$Measure$allSessions(switchList);
		return A2(
			elm$core$List$filterMap,
			author$project$Activity$Measure$isMatchingDuration(activityId),
			all);
	});
var author$project$SmartTime$Duration$add = F2(
	function (_n0, _n1) {
		var int1 = _n0.a;
		var int2 = _n1.a;
		return author$project$SmartTime$Duration$Duration(int1 + int2);
	});
var author$project$SmartTime$Duration$combine = function (durationList) {
	return A3(
		elm$core$List$foldl,
		author$project$SmartTime$Duration$add,
		author$project$SmartTime$Duration$Duration(0),
		durationList);
};
var author$project$Activity$Measure$totalLive = F3(
	function (now, switchList, activityId) {
		var fakeSwitch = A2(author$project$Activity$Activity$Switch, now, activityId);
		return author$project$SmartTime$Duration$combine(
			A2(
				author$project$Activity$Measure$sessions,
				A2(elm$core$List$cons, fakeSwitch, switchList),
				activityId));
	});
var author$project$Activity$Measure$excusedUsage = F3(
	function (timeline, now, _n0) {
		var activityID = _n0.a;
		var activity = _n0.b;
		var lastPeriod = A3(
			author$project$Activity$Measure$relevantTimeline,
			timeline,
			now,
			author$project$Activity$Activity$excusableFor(activity).a);
		return A3(author$project$Activity$Measure$totalLive, now, lastPeriod, activityID);
	});
var author$project$SmartTime$Duration$inSecondsRounded = function (duration) {
	return elm$core$Basics$round(
		author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$secondLength);
};
var author$project$Activity$Measure$exportExcusedUsageSeconds = F3(
	function (app, now, _n0) {
		var activityID = _n0.a;
		var activity = _n0.b;
		return elm$core$String$fromInt(
			author$project$SmartTime$Duration$inSecondsRounded(
				A3(
					author$project$Activity$Measure$excusedUsage,
					app.timeline,
					now,
					_Utils_Tuple2(activityID, activity))));
	});
var author$project$SmartTime$Duration$inMinutesRounded = function (duration) {
	return elm$core$Basics$round(
		author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$minuteLength);
};
var author$project$Activity$Measure$exportLastSession = F2(
	function (app, old) {
		var timeSpent = A2(
			elm$core$Maybe$withDefault,
			author$project$SmartTime$Duration$zero,
			elm$core$List$head(
				A2(author$project$Activity$Measure$sessions, app.timeline, old)));
		return elm$core$String$fromInt(
			author$project$SmartTime$Duration$inMinutesRounded(timeSpent));
	});
var author$project$SmartTime$Human$Duration$breakdownMS = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var seconds = _n0.seconds;
	return _List_fromArray(
		[
			author$project$SmartTime$Human$Duration$Minutes(
			author$project$SmartTime$Duration$inWholeMinutes(duration)),
			author$project$SmartTime$Human$Duration$Seconds(seconds)
		]);
};
var author$project$SmartTime$Human$Duration$withLetter = function (unit) {
	switch (unit.$) {
		case 'Milliseconds':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'ms';
		case 'Seconds':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 's';
		case 'Minutes':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'm';
		case 'Hours':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'h';
		default:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'd';
	}
};
var author$project$SmartTime$Human$Duration$singleLetterSpaced = function (humanDurationList) {
	return elm$core$String$concat(
		A2(
			elm$core$List$intersperse,
			' ',
			A2(elm$core$List$map, author$project$SmartTime$Human$Duration$withLetter, humanDurationList)));
};
var author$project$Activity$Switching$switchPopup = F4(
	function (timeline, env, newKV, _n0) {
		var newID = newKV.a;
		var _new = newKV.b;
		var oldID = _n0.a;
		var old = _n0.b;
		var timeSpentString = function (dur) {
			return author$project$SmartTime$Human$Duration$singleLetterSpaced(
				author$project$SmartTime$Human$Duration$breakdownMS(dur));
		};
		var timeSpentLastSession = A2(
			elm$core$Maybe$withDefault,
			author$project$SmartTime$Duration$zero,
			elm$core$List$head(
				A2(author$project$Activity$Measure$sessions, timeline, oldID)));
		return timeSpentString(timeSpentLastSession) + (' spent on ' + (author$project$Activity$Activity$getName(old) + ('\n' + (author$project$Activity$Activity$getName(old) + (' ➤ ' + (author$project$Activity$Activity$getName(_new) + ('\n' + ('Starting from ' + timeSpentString(
			A3(author$project$Activity$Measure$excusedUsage, timeline, env.time, newKV))))))))));
	});
var author$project$External$Tasker$variableOut = _Platform_outgoingPort(
	'variableOut',
	function ($) {
		var a = $.a;
		var b = $.b;
		return A2(
			elm$json$Json$Encode$list,
			elm$core$Basics$identity,
			_List_fromArray(
				[
					elm$json$Json$Encode$string(a),
					elm$json$Json$Encode$string(b)
				]));
	});
var author$project$External$Commands$changeActivity = F4(
	function (newName, newTotal, newMax, oldTotal) {
		return elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('OnTaskTotalSec', newTotal)),
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('ExcusedTotalSec', newTotal)),
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('ExcusedMaxSec', newMax)),
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('ElmSelected', newName)),
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('PreviousSessionTotal', oldTotal))
				]));
	});
var author$project$External$Tasker$exit = _Platform_outgoingPort(
	'exit',
	function ($) {
		return elm$json$Json$Encode$null;
	});
var author$project$External$Commands$hideWindow = author$project$External$Tasker$exit(_Utils_Tuple0);
var author$project$Activity$Switching$sameActivity = F3(
	function (activityID, app, env) {
		var activity = A2(
			author$project$Activity$Activity$getActivity,
			activityID,
			author$project$Activity$Activity$allActivities(app.activities));
		return _Utils_Tuple2(
			app,
			elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						author$project$External$Commands$toast(
						A4(
							author$project$Activity$Switching$switchPopup,
							app.timeline,
							env,
							_Utils_Tuple2(activityID, activity),
							_Utils_Tuple2(activityID, activity))),
						A4(
						author$project$External$Commands$changeActivity,
						author$project$Activity$Activity$getName(activity),
						A3(
							author$project$Activity$Measure$exportExcusedUsageSeconds,
							app,
							env.time,
							_Utils_Tuple2(activityID, activity)),
						elm$core$String$fromInt(
							author$project$SmartTime$Duration$inSecondsRounded(
								author$project$Activity$Measure$excusableLimit(activity))),
						A2(author$project$Activity$Measure$exportLastSession, app, activityID)),
						author$project$External$Commands$hideWindow
					])));
	});
var author$project$Activity$Measure$excusedLeft = F3(
	function (timeline, now, _n0) {
		var activityID = _n0.a;
		var activity = _n0.b;
		return A2(
			author$project$SmartTime$Duration$difference,
			author$project$Activity$Measure$excusableLimit(activity),
			A3(
				author$project$Activity$Measure$excusedUsage,
				timeline,
				now,
				_Utils_Tuple2(activityID, activity)));
	});
var author$project$SmartTime$Duration$isZero = function (_n0) {
	var _int = _n0.a;
	return !_int;
};
var author$project$SmartTime$Human$Duration$withAbbreviation = function (unit) {
	switch (unit.$) {
		case 'Milliseconds':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'ms';
		case 'Seconds':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'sec';
		case 'Minutes':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'min';
		case 'Hours':
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'hr';
		default:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'd';
	}
};
var author$project$SmartTime$Human$Duration$abbreviatedSpaced = function (humanDurationList) {
	return elm$core$String$concat(
		A2(
			elm$core$List$intersperse,
			' ',
			A2(elm$core$List$map, author$project$SmartTime$Human$Duration$withAbbreviation, humanDurationList)));
};
var author$project$SmartTime$Human$Duration$breakdownHM = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var minutes = _n0.minutes;
	return _List_fromArray(
		[
			author$project$SmartTime$Human$Duration$Hours(
			author$project$SmartTime$Duration$inWholeHours(duration)),
			author$project$SmartTime$Human$Duration$Minutes(minutes)
		]);
};
var author$project$SmartTime$Moment$future = F2(
	function (_n0, duration) {
		var time = _n0.a;
		return author$project$SmartTime$Moment$Moment(
			A2(author$project$SmartTime$Duration$add, time, duration));
	});
var elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2(elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var author$project$Activity$Reminder$scheduleExcusedReminders = F3(
	function (now, maxExcused, timeLeft) {
		var yetToPass = function (reminder) {
			return _Utils_eq(
				A2(author$project$SmartTime$Moment$compare, reminder.scheduledFor, now),
				elm$core$Basics$GT);
		};
		var write = function (durLeft) {
			return author$project$SmartTime$Human$Duration$abbreviatedSpaced(
				author$project$SmartTime$Human$Duration$breakdownHM(durLeft));
		};
		var thirdLeft = A2(author$project$SmartTime$Duration$scale, maxExcused, 2 / 3);
		var quarterLeft = A2(author$project$SmartTime$Duration$scale, maxExcused, 3 / 4);
		var halfLeft = A2(author$project$SmartTime$Duration$scale, maxExcused, 1 / 2);
		var fifthLeft = A2(author$project$SmartTime$Duration$scale, maxExcused, 4 / 5);
		return (!author$project$SmartTime$Duration$isZero(timeLeft)) ? A2(
			elm$core$List$filter,
			yetToPass,
			_List_fromArray(
				[
					{
					actions: _List_Nil,
					scheduledFor: A2(author$project$SmartTime$Moment$future, now, halfLeft),
					subtitle: write(halfLeft) + ' left',
					title: 'Half Time!'
				},
					{
					actions: _List_Nil,
					scheduledFor: A2(author$project$SmartTime$Moment$future, now, thirdLeft),
					subtitle: 'Only one third left',
					title: 'Excused for ' + (write(thirdLeft) + ' more')
				},
					{
					actions: _List_Nil,
					scheduledFor: A2(author$project$SmartTime$Moment$future, now, quarterLeft),
					subtitle: 'Only one quarter left',
					title: 'Excused for ' + (write(quarterLeft) + ' more')
				},
					{
					actions: _List_Nil,
					scheduledFor: A2(author$project$SmartTime$Moment$future, now, fifthLeft),
					subtitle: 'Only one fifth left',
					title: 'Excused for ' + (write(fifthLeft) + ' more')
				},
					{
					actions: _List_Nil,
					scheduledFor: A2(
						author$project$SmartTime$Moment$future,
						now,
						author$project$SmartTime$Human$Duration$toDuration(
							author$project$SmartTime$Human$Duration$Minutes(5))),
					subtitle: 'Can you get back on task now?',
					title: '5 minutes left!'
				},
					{
					actions: _List_Nil,
					scheduledFor: A2(
						author$project$SmartTime$Moment$future,
						now,
						author$project$SmartTime$Human$Duration$toDuration(
							author$project$SmartTime$Human$Duration$Minutes(1))),
					subtitle: 'Stop now. You can come back to this later.',
					title: '1 minute left!'
				}
				])) : _List_Nil;
	});
var author$project$External$Commands$compileList = function (reminderList) {
	return elm$core$String$concat(
		A2(elm$core$List$intersperse, '§', reminderList));
};
var author$project$SmartTime$Duration$inSeconds = function (duration) {
	return author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$secondLength;
};
var author$project$SmartTime$Moment$toUnixTime = function (_n0) {
	var dur = _n0.a;
	return author$project$SmartTime$Moment$utcFromLinear(
		author$project$SmartTime$Duration$inSeconds(dur));
};
var elm$core$Basics$truncate = _Basics_truncate;
var author$project$SmartTime$Moment$toUnixTimeInt = function (mo) {
	return author$project$SmartTime$Moment$toUnixTime(mo) | 0;
};
var author$project$External$Commands$taskerEncodeNotification = function (reminder) {
	return elm$core$String$concat(
		A2(
			elm$core$List$intersperse,
			';',
			_List_fromArray(
				[
					elm$core$String$fromInt(
					author$project$SmartTime$Moment$toUnixTimeInt(reminder.scheduledFor)),
					reminder.title,
					reminder.subtitle
				])));
};
var author$project$External$Commands$scheduleNotify = function (reminderList) {
	return author$project$External$Tasker$variableOut(
		_Utils_Tuple2(
			'Scheduled',
			author$project$External$Commands$compileList(
				A2(elm$core$List$map, author$project$External$Commands$taskerEncodeNotification, reminderList))));
};
var author$project$Activity$Switching$switchActivity = F3(
	function (activityID, app, env) {
		var updatedApp = _Utils_update(
			app,
			{
				timeline: A2(
					elm$core$List$cons,
					A2(author$project$Activity$Activity$Switch, env.time, activityID),
					app.timeline)
			});
		var oldActivityID = author$project$Activity$Switching$currentActivityFromApp(app);
		var oldActivity = A2(
			author$project$Activity$Activity$getActivity,
			oldActivityID,
			author$project$Activity$Activity$allActivities(app.activities));
		var newActivity = A2(
			author$project$Activity$Activity$getActivity,
			activityID,
			author$project$Activity$Activity$allActivities(app.activities));
		return _Utils_Tuple2(
			updatedApp,
			elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						author$project$External$Commands$toast(
						A4(
							author$project$Activity$Switching$switchPopup,
							updatedApp.timeline,
							env,
							_Utils_Tuple2(activityID, newActivity),
							_Utils_Tuple2(oldActivityID, oldActivity))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'ExcusedTotalSec',
							A3(
								author$project$Activity$Measure$exportExcusedUsageSeconds,
								app,
								env.time,
								_Utils_Tuple2(activityID, newActivity)))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'OnTaskTotalSec',
							A3(
								author$project$Activity$Measure$exportExcusedUsageSeconds,
								app,
								env.time,
								_Utils_Tuple2(activityID, newActivity)))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'ActivityTotal',
							elm$core$String$fromInt(
								author$project$SmartTime$Duration$inMinutesRounded(
									A3(
										author$project$Activity$Measure$excusedUsage,
										app.timeline,
										env.time,
										_Utils_Tuple2(activityID, newActivity)))))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'ExcusedMaxSec',
							elm$core$String$fromInt(
								author$project$SmartTime$Duration$inSecondsRounded(
									author$project$Activity$Measure$excusableLimit(newActivity))))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'ElmSelected',
							author$project$Activity$Activity$getName(newActivity))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'PreviousSessionTotal',
							A2(author$project$Activity$Measure$exportLastSession, updatedApp, oldActivityID))),
						author$project$External$Commands$hideWindow,
						author$project$External$Commands$scheduleNotify(
						A3(
							author$project$Activity$Reminder$scheduleExcusedReminders,
							env.time,
							author$project$SmartTime$Human$Duration$toDuration(
								author$project$Activity$Activity$excusableFor(newActivity).b),
							A3(
								author$project$Activity$Measure$excusedLeft,
								updatedApp.timeline,
								env.time,
								_Utils_Tuple2(activityID, newActivity))))
					])));
	});
var author$project$TimeTracker$update = F4(
	function (msg, state, app, env) {
		if (msg.$ === 'NoOp') {
			return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
		} else {
			var activityId = msg.a;
			var _n1 = _Utils_eq(
				activityId,
				author$project$Activity$Switching$currentActivityFromApp(app)) ? A3(author$project$Activity$Switching$sameActivity, activityId, app, env) : A3(author$project$Activity$Switching$switchActivity, activityId, app, env);
			var updatedApp = _n1.a;
			var cmds = _n1.b;
			return _Utils_Tuple3(state, updatedApp, cmds);
		}
	});
var author$project$TimeTracker$NoOp = {$: 'NoOp'};
var author$project$TimeTracker$StartTracking = function (a) {
	return {$: 'StartTracking', a: a};
};
var elm$core$String$toLower = _String_toLower;
var author$project$TimeTracker$urlTriggers = function (app) {
	var entriesPerActivity = function (_n0) {
		var id = _n0.a;
		var activity = _n0.b;
		return _Utils_ap(
			A2(
				elm$core$List$map,
				function (nm) {
					return _Utils_Tuple2(
						nm,
						author$project$TimeTracker$StartTracking(
							author$project$ID$tag(id)));
				},
				activity.names),
			A2(
				elm$core$List$map,
				function (nm) {
					return _Utils_Tuple2(
						elm$core$String$toLower(nm),
						author$project$TimeTracker$StartTracking(
							author$project$ID$tag(id)));
				},
				activity.names));
	};
	var activitiesWithNames = elm$core$List$concat(
		A2(
			elm$core$List$map,
			entriesPerActivity,
			elm_community$intdict$IntDict$toList(
				author$project$Activity$Activity$allActivities(app.activities))));
	return _List_fromArray(
		[
			_Utils_Tuple2(
			'start',
			elm$core$Dict$fromList(activitiesWithNames)),
			_Utils_Tuple2(
			'stop',
			elm$core$Dict$fromList(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'stop',
						author$project$TimeTracker$StartTracking(author$project$Activity$Activity$dummy))
					]))),
			_Utils_Tuple2(
			'noop',
			elm$core$Dict$fromList(
				_List_fromArray(
					[
						_Utils_Tuple2('noop', author$project$TimeTracker$NoOp)
					])))
		]);
};
var elm$browser$Browser$Navigation$load = _Browser_load;
var elm$browser$Browser$Navigation$pushUrl = _Browser_pushUrl;
var elm$browser$Browser$Navigation$replaceUrl = _Browser_replaceUrl;
var elm$url$Url$Parser$query = function (_n0) {
	var queryParser = _n0.a;
	return elm$url$Url$Parser$Parser(
		function (_n1) {
			var visited = _n1.visited;
			var unvisited = _n1.unvisited;
			var params = _n1.params;
			var frag = _n1.frag;
			var value = _n1.value;
			return _List_fromArray(
				[
					A5(
					elm$url$Url$Parser$State,
					visited,
					unvisited,
					params,
					frag,
					value(
						queryParser(params)))
				]);
		});
};
var elm$url$Url$Parser$Internal$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var elm$url$Url$Parser$Query$custom = F2(
	function (key, func) {
		return elm$url$Url$Parser$Internal$Parser(
			function (dict) {
				return func(
					A2(
						elm$core$Maybe$withDefault,
						_List_Nil,
						A2(elm$core$Dict$get, key, dict)));
			});
	});
var elm$url$Url$Parser$Query$enum = F2(
	function (key, dict) {
		return A2(
			elm$url$Url$Parser$Query$custom,
			key,
			function (stringList) {
				if (stringList.b && (!stringList.b.b)) {
					var str = stringList.a;
					return A2(elm$core$Dict$get, str, dict);
				} else {
					return elm$core$Maybe$Nothing;
				}
			});
	});
var author$project$Main$handleUrlTriggers = F2(
	function (rawUrl, model) {
		var appData = model.appData;
		var environment = model.environment;
		var wrapMsgs = F2(
			function (tagger, _n23) {
				var key = _n23.a;
				var dict = _n23.b;
				return _Utils_Tuple2(
					key,
					A2(
						elm$core$Dict$map,
						F2(
							function (_n22, msg) {
								return tagger(msg);
							}),
						dict));
			});
		var url = author$project$Main$bypassFakeFragment(rawUrl);
		var removeTriggersFromUrl = function () {
			var _n21 = environment.navkey;
			if (_n21.$ === 'Just') {
				var navkey = _n21.a;
				return A2(
					elm$browser$Browser$Navigation$replaceUrl,
					navkey,
					elm$url$Url$toString(
						_Utils_update(
							url,
							{query: elm$core$Maybe$Nothing})));
			} else {
				return elm$core$Platform$Cmd$none;
			}
		}();
		var normalizedUrl = _Utils_update(
			url,
			{path: ''});
		var fancyRecursiveParse = function (checkList) {
			fancyRecursiveParse:
			while (true) {
				if (checkList.b) {
					var _n10 = checkList.a;
					var triggerName = _n10.a;
					var triggerValues = _n10.b;
					var rest = checkList.b;
					var _n11 = A2(
						elm$url$Url$Parser$parse,
						elm$url$Url$Parser$query(
							A2(elm$url$Url$Parser$Query$enum, triggerName, triggerValues)),
						normalizedUrl);
					if (_n11.$ === 'Nothing') {
						var $temp$checkList = rest;
						checkList = $temp$checkList;
						continue fancyRecursiveParse;
					} else {
						if (_n11.a.$ === 'Nothing') {
							var _n12 = _n11.a;
							var $temp$checkList = rest;
							checkList = $temp$checkList;
							continue fancyRecursiveParse;
						} else {
							var match = _n11.a;
							return elm$core$Maybe$Just(match);
						}
					}
				} else {
					return elm$core$Maybe$Nothing;
				}
			}
		};
		var createQueryParsers = function (_n20) {
			var key = _n20.a;
			var values = _n20.b;
			return A2(elm$url$Url$Parser$Query$enum, key, values);
		};
		var allTriggers = _Utils_ap(
			A2(
				elm$core$List$map,
				wrapMsgs(author$project$Main$TimeTrackerMsg),
				author$project$TimeTracker$urlTriggers(appData)),
			_List_fromArray(
				[
					_Utils_Tuple2(
					'sync',
					elm$core$Dict$fromList(
						_List_fromArray(
							[
								_Utils_Tuple2('todoist', author$project$Main$SyncTodoist)
							]))),
					_Utils_Tuple2(
					'blowup',
					elm$core$Dict$fromList(
						_List_fromArray(
							[
								_Utils_Tuple2('yes', author$project$Main$SyncTodoist)
							])))
				]));
		var parseList = A2(
			elm$core$List$map,
			elm$url$Url$Parser$query,
			A2(elm$core$List$map, createQueryParsers, allTriggers));
		var parsed = A2(
			elm$url$Url$Parser$parse,
			elm$url$Url$Parser$oneOf(parseList),
			normalizedUrl);
		var _n13 = fancyRecursiveParse(allTriggers);
		if (_n13.$ === 'Just') {
			var parsedUrlSuccessfully = _n13.a;
			var _n14 = _Utils_Tuple2(parsedUrlSuccessfully, normalizedUrl.query);
			if (_n14.a.$ === 'Just') {
				if (_n14.b.$ === 'Just') {
					var triggerMsg = _n14.a.a;
					var _n15 = A2(author$project$Main$update, triggerMsg, model);
					var newModel = _n15.a;
					var newCmd = _n15.b;
					var newCmdWithUrlCleaner = elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[newCmd, removeTriggersFromUrl]));
					return _Utils_Tuple2(newModel, newCmdWithUrlCleaner);
				} else {
					var triggerMsg = _n14.a.a;
					var _n17 = _n14.b;
					var problemText = 'Handle URL Triggers: impossible situation. No query (Nothing) but we still successfully parsed it!';
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								appData: A2(author$project$AppData$saveError, appData, problemText)
							}),
						author$project$External$Commands$toast(problemText));
				}
			} else {
				if (_n14.b.$ === 'Just') {
					var _n16 = _n14.a;
					var query = _n14.b.a;
					var problemText = 'Handle URL Triggers: none of  ' + (elm$core$String$fromInt(
						elm$core$List$length(parseList)) + (' parsers matched key and value: ' + query));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								appData: A2(author$project$AppData$saveError, appData, problemText)
							}),
						author$project$External$Commands$toast(problemText));
				} else {
					var _n18 = _n14.a;
					var _n19 = _n14.b;
					return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
				}
			}
		} else {
			var problemText = 'Handle URL Triggers: failed to parse URL ' + elm$url$Url$toString(normalizedUrl);
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{
						appData: A2(author$project$AppData$saveError, appData, problemText)
					}),
				author$project$External$Commands$toast(problemText));
		}
	});
var author$project$Main$update = F2(
	function (msg, model) {
		var viewState = model.viewState;
		var appData = model.appData;
		var environment = model.environment;
		var justSetEnv = function (newEnv) {
			return _Utils_Tuple2(
				A3(author$project$Main$Model, viewState, appData, newEnv),
				elm$core$Platform$Cmd$none);
		};
		var justRunCommand = function (command) {
			return _Utils_Tuple2(model, command);
		};
		var _n0 = _Utils_Tuple2(msg, viewState.primaryView);
		_n0$7:
		while (true) {
			switch (_n0.a.$) {
				case 'ClearErrors':
					var _n1 = _n0.a;
					return _Utils_Tuple2(
						A3(
							author$project$Main$Model,
							viewState,
							_Utils_update(
								appData,
								{errors: _List_Nil}),
							environment),
						elm$core$Platform$Cmd$none);
				case 'SyncTodoist':
					var _n2 = _n0.a;
					return justRunCommand(
						A2(
							elm$core$Platform$Cmd$map,
							author$project$Main$TodoistServerResponse,
							author$project$External$TodoistSync$sync(appData.todoist.syncToken)));
				case 'TodoistServerResponse':
					var response = _n0.a.a;
					var _n3 = A2(author$project$External$TodoistSync$handle, response, appData);
					var newAppData = _n3.a;
					var whatHappened = _n3.b;
					return _Utils_Tuple2(
						A3(author$project$Main$Model, viewState, newAppData, environment),
						author$project$External$Commands$toast(whatHappened));
				case 'Link':
					var urlRequest = _n0.a.a;
					if (urlRequest.$ === 'Internal') {
						var url = urlRequest.a;
						var _n5 = environment.navkey;
						if (_n5.$ === 'Just') {
							var navkey = _n5.a;
							return justRunCommand(
								A2(
									elm$browser$Browser$Navigation$pushUrl,
									navkey,
									elm$url$Url$toString(url)));
						} else {
							return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
						}
					} else {
						var href = urlRequest.a;
						return justRunCommand(
							elm$browser$Browser$Navigation$load(href));
					}
				case 'NewUrl':
					var url = _n0.a.a;
					var _n6 = A2(author$project$Main$handleUrlTriggers, url, model);
					var modelAfter = _n6.a;
					var effectsAfter = _n6.b;
					return _Utils_Tuple2(
						_Utils_update(
							modelAfter,
							{
								viewState: author$project$Main$viewUrl(url)
							}),
						effectsAfter);
				case 'TaskListMsg':
					if (_n0.b.$ === 'TaskList') {
						var subMsg = _n0.a.a;
						var subViewState = _n0.b.a;
						var _n7 = A4(author$project$TaskList$update, subMsg, subViewState, appData, environment);
						var newState = _n7.a;
						var newApp = _n7.b;
						var newCommand = _n7.c;
						return _Utils_Tuple2(
							A3(
								author$project$Main$Model,
								A2(
									author$project$Main$ViewState,
									author$project$Main$TaskList(newState),
									0),
								newApp,
								environment),
							A2(elm$core$Platform$Cmd$map, author$project$Main$TaskListMsg, newCommand));
					} else {
						break _n0$7;
					}
				case 'TimeTrackerMsg':
					if (_n0.b.$ === 'TimeTracker') {
						var subMsg = _n0.a.a;
						var subViewState = _n0.b.a;
						var _n8 = A4(author$project$TimeTracker$update, subMsg, subViewState, appData, environment);
						var newState = _n8.a;
						var newApp = _n8.b;
						var newCommand = _n8.c;
						return _Utils_Tuple2(
							A3(
								author$project$Main$Model,
								A2(
									author$project$Main$ViewState,
									author$project$Main$TimeTracker(newState),
									0),
								newApp,
								environment),
							A2(elm$core$Platform$Cmd$map, author$project$Main$TimeTrackerMsg, newCommand));
					} else {
						break _n0$7;
					}
				default:
					break _n0$7;
			}
		}
		return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
	});
var author$project$Main$updateWithStorage = F2(
	function (msg, model) {
		var _n0 = A2(author$project$Main$update, msg, model);
		var newModel = _n0.a;
		var cmds = _n0.b;
		return _Utils_Tuple2(
			newModel,
			elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						author$project$Main$setStorage(
						author$project$Main$appDataToJson(newModel.appData)),
						cmds
					])));
	});
var author$project$SmartTime$Moment$UTC = {$: 'UTC'};
var author$project$SmartTime$Moment$epochOffset = F2(
	function (_n0, _int) {
		var epochDur = _n0.a;
		return 0;
	});
var author$project$SmartTime$Moment$linearFromUTC = function (num) {
	return num;
};
var author$project$SmartTime$Moment$moment = F3(
	function (timeScale, epoch, duration) {
		var input = author$project$SmartTime$Duration$inMs(duration);
		var create = function (ms) {
			return author$project$SmartTime$Moment$Moment(
				author$project$SmartTime$Duration$fromInt(
					A2(author$project$SmartTime$Moment$epochOffset, epoch, ms)));
		};
		switch (timeScale.$) {
			case 'TAI':
				return create(input);
			case 'UTC':
				return create(
					author$project$SmartTime$Moment$linearFromUTC(input));
			case 'GPS':
				return create(input + 1900);
			default:
				return create(input - 32184);
		}
	});
var author$project$SmartTime$Moment$unixEpoch = author$project$SmartTime$Moment$Moment(
	author$project$SmartTime$Duration$fromInt(0));
var author$project$SmartTime$Moment$fromElmInt = function (intMsUtc) {
	return A3(
		author$project$SmartTime$Moment$moment,
		author$project$SmartTime$Moment$UTC,
		author$project$SmartTime$Moment$unixEpoch,
		author$project$SmartTime$Duration$fromInt(intMsUtc));
};
var author$project$SmartTime$Moment$fromElmTime = function (intMsUtc) {
	return author$project$SmartTime$Moment$fromElmInt(
		elm$time$Time$posixToMillis(intMsUtc));
};
var elm$time$Time$Name = function (a) {
	return {$: 'Name', a: a};
};
var elm$time$Time$Offset = function (a) {
	return {$: 'Offset', a: a};
};
var elm$time$Time$customZone = elm$time$Time$Zone;
var elm$time$Time$now = _Time_now(elm$time$Time$millisToPosix);
var author$project$SmartTime$Moment$now = A2(elm$core$Task$map, author$project$SmartTime$Moment$fromElmTime, elm$time$Time$now);
var author$project$Main$updateWithTime = F2(
	function (msg, model) {
		updateWithTime:
		while (true) {
			var environment = model.environment;
			switch (msg.$) {
				case 'NoOp':
					return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
				case 'Tick':
					var submsg = msg.a;
					return _Utils_Tuple2(
						model,
						A2(
							elm$core$Task$perform,
							author$project$Main$Tock(submsg),
							author$project$SmartTime$Moment$now));
				case 'Tock':
					var submsg = msg.a;
					var time = msg.b;
					var newEnv = _Utils_update(
						environment,
						{time: time});
					return A2(
						author$project$Main$updateWithStorage,
						submsg,
						_Utils_update(
							model,
							{environment: newEnv}));
				case 'SetZoneAndTime':
					var zone = msg.a;
					var time = msg.b;
					var newEnv = _Utils_update(
						environment,
						{time: time, timeZone: zone});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{environment: newEnv}),
						elm$core$Platform$Cmd$none);
				default:
					var otherMsg = msg;
					var $temp$msg = author$project$Main$Tick(msg),
						$temp$model = model;
					msg = $temp$msg;
					model = $temp$model;
					continue updateWithTime;
			}
		}
	});
var elm$time$Time$here = _Time_here(_Utils_Tuple0);
var author$project$SmartTime$Human$Moment$localZone = elm$time$Time$here;
var author$project$Main$init = F3(
	function (maybeJson, url, maybeKey) {
		var startingModel = function () {
			if (maybeJson.$ === 'Just') {
				var jsonAppDatabase = maybeJson.a;
				var _n2 = author$project$Main$appDataFromJson(jsonAppDatabase);
				switch (_n2.$) {
					case 'Success':
						var savedAppData = _n2.a;
						return A3(author$project$Main$buildModel, savedAppData, url, maybeKey);
					case 'WithWarnings':
						var warnings = _n2.a;
						var savedAppData = _n2.b;
						return A3(
							author$project$Main$buildModel,
							A2(author$project$AppData$saveWarnings, savedAppData, warnings),
							url,
							maybeKey);
					case 'Errors':
						var errors = _n2.a;
						return A3(
							author$project$Main$buildModel,
							A2(author$project$AppData$saveDecodeErrors, author$project$AppData$fromScratch, errors),
							url,
							maybeKey);
					default:
						return A3(author$project$Main$buildModel, author$project$AppData$fromScratch, url, maybeKey);
				}
			} else {
				return A3(author$project$Main$buildModel, author$project$AppData$fromScratch, url, maybeKey);
			}
		}();
		var _n0 = A2(
			author$project$Main$updateWithTime,
			author$project$Main$NewUrl(url),
			startingModel);
		var modelWithFirstUpdate = _n0.a;
		var firstEffects = _n0.b;
		var effects = _List_fromArray(
			[
				A2(
				elm$core$Task$perform,
				elm$core$Basics$identity,
				A3(elm$core$Task$map2, author$project$Main$SetZoneAndTime, author$project$SmartTime$Human$Moment$localZone, author$project$SmartTime$Moment$now)),
				firstEffects
			]);
		return _Utils_Tuple2(
			modelWithFirstUpdate,
			elm$core$Platform$Cmd$batch(effects));
	});
var author$project$Main$initGraphical = F3(
	function (maybeJson, url, key) {
		return A3(
			author$project$Main$init,
			maybeJson,
			url,
			elm$core$Maybe$Just(key));
	});
var author$project$Main$NoOp = {$: 'NoOp'};
var elm$time$Time$Every = F2(
	function (a, b) {
		return {$: 'Every', a: a, b: b};
	});
var elm$time$Time$State = F2(
	function (taggers, processes) {
		return {processes: processes, taggers: taggers};
	});
var elm$time$Time$init = elm$core$Task$succeed(
	A2(elm$time$Time$State, elm$core$Dict$empty, elm$core$Dict$empty));
var elm$time$Time$addMySub = F2(
	function (_n0, state) {
		var interval = _n0.a;
		var tagger = _n0.b;
		var _n1 = A2(elm$core$Dict$get, interval, state);
		if (_n1.$ === 'Nothing') {
			return A3(
				elm$core$Dict$insert,
				interval,
				_List_fromArray(
					[tagger]),
				state);
		} else {
			var taggers = _n1.a;
			return A3(
				elm$core$Dict$insert,
				interval,
				A2(elm$core$List$cons, tagger, taggers),
				state);
		}
	});
var elm$time$Time$setInterval = _Time_setInterval;
var elm$time$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		if (!intervals.b) {
			return elm$core$Task$succeed(processes);
		} else {
			var interval = intervals.a;
			var rest = intervals.b;
			var spawnTimer = elm$core$Process$spawn(
				A2(
					elm$time$Time$setInterval,
					interval,
					A2(elm$core$Platform$sendToSelf, router, interval)));
			var spawnRest = function (id) {
				return A3(
					elm$time$Time$spawnHelp,
					router,
					rest,
					A3(elm$core$Dict$insert, interval, id, processes));
			};
			return A2(elm$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var elm$time$Time$onEffects = F3(
	function (router, subs, _n0) {
		var processes = _n0.processes;
		var rightStep = F3(
			function (_n6, id, _n7) {
				var spawns = _n7.a;
				var existing = _n7.b;
				var kills = _n7.c;
				return _Utils_Tuple3(
					spawns,
					existing,
					A2(
						elm$core$Task$andThen,
						function (_n5) {
							return kills;
						},
						elm$core$Process$kill(id)));
			});
		var newTaggers = A3(elm$core$List$foldl, elm$time$Time$addMySub, elm$core$Dict$empty, subs);
		var leftStep = F3(
			function (interval, taggers, _n4) {
				var spawns = _n4.a;
				var existing = _n4.b;
				var kills = _n4.c;
				return _Utils_Tuple3(
					A2(elm$core$List$cons, interval, spawns),
					existing,
					kills);
			});
		var bothStep = F4(
			function (interval, taggers, id, _n3) {
				var spawns = _n3.a;
				var existing = _n3.b;
				var kills = _n3.c;
				return _Utils_Tuple3(
					spawns,
					A3(elm$core$Dict$insert, interval, id, existing),
					kills);
			});
		var _n1 = A6(
			elm$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			processes,
			_Utils_Tuple3(
				_List_Nil,
				elm$core$Dict$empty,
				elm$core$Task$succeed(_Utils_Tuple0)));
		var spawnList = _n1.a;
		var existingDict = _n1.b;
		var killTask = _n1.c;
		return A2(
			elm$core$Task$andThen,
			function (newProcesses) {
				return elm$core$Task$succeed(
					A2(elm$time$Time$State, newTaggers, newProcesses));
			},
			A2(
				elm$core$Task$andThen,
				function (_n2) {
					return A3(elm$time$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var elm$time$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _n0 = A2(elm$core$Dict$get, interval, state.taggers);
		if (_n0.$ === 'Nothing') {
			return elm$core$Task$succeed(state);
		} else {
			var taggers = _n0.a;
			var tellTaggers = function (time) {
				return elm$core$Task$sequence(
					A2(
						elm$core$List$map,
						function (tagger) {
							return A2(
								elm$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						taggers));
			};
			return A2(
				elm$core$Task$andThen,
				function (_n1) {
					return elm$core$Task$succeed(state);
				},
				A2(elm$core$Task$andThen, tellTaggers, elm$time$Time$now));
		}
	});
var elm$time$Time$subMap = F2(
	function (f, _n0) {
		var interval = _n0.a;
		var tagger = _n0.b;
		return A2(
			elm$time$Time$Every,
			interval,
			A2(elm$core$Basics$composeL, f, tagger));
	});
_Platform_effectManagers['Time'] = _Platform_createManager(elm$time$Time$init, elm$time$Time$onEffects, elm$time$Time$onSelfMsg, 0, elm$time$Time$subMap);
var elm$time$Time$subscription = _Platform_leaf('Time');
var elm$time$Time$every = F2(
	function (interval, tagger) {
		return elm$time$Time$subscription(
			A2(elm$time$Time$Every, interval, tagger));
	});
var author$project$SmartTime$Moment$every = F2(
	function (interval, tagger) {
		var convertedTagger = function (elmTime) {
			return tagger(
				author$project$SmartTime$Moment$fromElmTime(elmTime));
		};
		return A2(
			elm$time$Time$every,
			author$project$SmartTime$Duration$inMs(interval),
			convertedTagger);
	});
var elm$browser$Browser$Events$Document = {$: 'Document'};
var elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 'MySub', a: a, b: b, c: c};
	});
var elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {pids: pids, subs: subs};
	});
var elm$browser$Browser$Events$init = elm$core$Task$succeed(
	A2(elm$browser$Browser$Events$State, _List_Nil, elm$core$Dict$empty));
var elm$browser$Browser$Events$nodeToKey = function (node) {
	if (node.$ === 'Document') {
		return 'd_';
	} else {
		return 'w_';
	}
};
var elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {event: event, key: key};
	});
var elm$browser$Browser$Events$spawn = F3(
	function (router, key, _n0) {
		var node = _n0.a;
		var name = _n0.b;
		var actualNode = function () {
			if (node.$ === 'Document') {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						elm$core$Platform$sendToSelf,
						router,
						A2(elm$browser$Browser$Events$Event, key, event));
				}));
	});
var elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3(elm$core$Dict$foldl, elm$core$Dict$insert, t2, t1);
	});
var elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _n6) {
				var deads = _n6.a;
				var lives = _n6.b;
				var news = _n6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						elm$core$List$cons,
						A3(elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_n4, pid, _n5) {
				var deads = _n5.a;
				var lives = _n5.b;
				var news = _n5.c;
				return _Utils_Tuple3(
					A2(elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _n2, _n3) {
				var deads = _n3.a;
				var lives = _n3.b;
				var news = _n3.c;
				return _Utils_Tuple3(
					deads,
					A3(elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2(elm$core$List$map, elm$browser$Browser$Events$addKey, subs);
		var _n0 = A6(
			elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.pids,
			elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, elm$core$Dict$empty, _List_Nil));
		var deadPids = _n0.a;
		var livePids = _n0.b;
		var makeNewPids = _n0.c;
		return A2(
			elm$core$Task$andThen,
			function (pids) {
				return elm$core$Task$succeed(
					A2(
						elm$browser$Browser$Events$State,
						newSubs,
						A2(
							elm$core$Dict$union,
							livePids,
							elm$core$Dict$fromList(pids))));
			},
			A2(
				elm$core$Task$andThen,
				function (_n1) {
					return elm$core$Task$sequence(makeNewPids);
				},
				elm$core$Task$sequence(
					A2(elm$core$List$map, elm$core$Process$kill, deadPids))));
	});
var elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _n0, state) {
		var key = _n0.key;
		var event = _n0.event;
		var toMessage = function (_n2) {
			var subKey = _n2.a;
			var _n3 = _n2.b;
			var node = _n3.a;
			var name = _n3.b;
			var decoder = _n3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : elm$core$Maybe$Nothing;
		};
		var messages = A2(elm$core$List$filterMap, toMessage, state.subs);
		return A2(
			elm$core$Task$andThen,
			function (_n1) {
				return elm$core$Task$succeed(state);
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$map,
					elm$core$Platform$sendToApp(router),
					messages)));
	});
var elm$browser$Browser$Events$subMap = F2(
	function (func, _n0) {
		var node = _n0.a;
		var name = _n0.b;
		var decoder = _n0.c;
		return A3(
			elm$browser$Browser$Events$MySub,
			node,
			name,
			A2(elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager(elm$browser$Browser$Events$init, elm$browser$Browser$Events$onEffects, elm$browser$Browser$Events$onSelfMsg, 0, elm$browser$Browser$Events$subMap);
var elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return elm$browser$Browser$Events$subscription(
			A3(elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var elm$browser$Browser$Events$Hidden = {$: 'Hidden'};
var elm$browser$Browser$Events$Visible = {$: 'Visible'};
var elm$browser$Browser$Events$withHidden = F2(
	function (func, isHidden) {
		return func(
			isHidden ? elm$browser$Browser$Events$Hidden : elm$browser$Browser$Events$Visible);
	});
var elm$browser$Browser$Events$onVisibilityChange = function (func) {
	var info = _Browser_visibilityInfo(_Utils_Tuple0);
	return A3(
		elm$browser$Browser$Events$on,
		elm$browser$Browser$Events$Document,
		info.change,
		A2(
			elm$json$Json$Decode$map,
			elm$browser$Browser$Events$withHidden(func),
			A2(
				elm$json$Json$Decode$field,
				'target',
				A2(elm$json$Json$Decode$field, info.hidden, elm$json$Json$Decode$bool))));
};
var elm$core$Platform$Sub$batch = _Platform_batch;
var author$project$Main$subscriptions = function (model) {
	var appData = model.appData;
	var environment = model.environment;
	return elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				A2(
				author$project$SmartTime$Moment$every,
				author$project$SmartTime$Human$Duration$dur(
					author$project$SmartTime$Human$Duration$Minutes(1)),
				author$project$Main$Tock(author$project$Main$NoOp)),
				elm$browser$Browser$Events$onVisibilityChange(
				function (_n0) {
					return author$project$Main$Tick(author$project$Main$NoOp);
				})
			]));
};
var author$project$Main$ClearErrors = {$: 'ClearErrors'};
var rtfeldman$elm_css$VirtualDom$Styled$Node = F3(
	function (a, b, c) {
		return {$: 'Node', a: a, b: b, c: c};
	});
var rtfeldman$elm_css$VirtualDom$Styled$node = rtfeldman$elm_css$VirtualDom$Styled$Node;
var rtfeldman$elm_css$Html$Styled$node = rtfeldman$elm_css$VirtualDom$Styled$node;
var rtfeldman$elm_css$Html$Styled$div = rtfeldman$elm_css$Html$Styled$node('div');
var rtfeldman$elm_css$Html$Styled$li = rtfeldman$elm_css$Html$Styled$node('li');
var rtfeldman$elm_css$Html$Styled$ol = rtfeldman$elm_css$Html$Styled$node('ol');
var rtfeldman$elm_css$VirtualDom$Styled$Unstyled = function (a) {
	return {$: 'Unstyled', a: a};
};
var rtfeldman$elm_css$VirtualDom$Styled$text = function (str) {
	return rtfeldman$elm_css$VirtualDom$Styled$Unstyled(
		elm$virtual_dom$VirtualDom$text(str));
};
var rtfeldman$elm_css$Html$Styled$text = rtfeldman$elm_css$VirtualDom$Styled$text;
var elm$virtual_dom$VirtualDom$property = F2(
	function (key, value) {
		return A2(
			_VirtualDom_property,
			_VirtualDom_noInnerHtmlOrFormAction(key),
			_VirtualDom_noJavaScriptOrHtmlUri(value));
	});
var rtfeldman$elm_css$VirtualDom$Styled$Attribute = F3(
	function (a, b, c) {
		return {$: 'Attribute', a: a, b: b, c: c};
	});
var rtfeldman$elm_css$VirtualDom$Styled$property = F2(
	function (key, value) {
		return A3(
			rtfeldman$elm_css$VirtualDom$Styled$Attribute,
			A2(elm$virtual_dom$VirtualDom$property, key, value),
			_List_Nil,
			'');
	});
var rtfeldman$elm_css$Html$Styled$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			rtfeldman$elm_css$VirtualDom$Styled$property,
			key,
			elm$json$Json$Encode$string(string));
	});
var rtfeldman$elm_css$Html$Styled$Attributes$class = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('className');
var rtfeldman$elm_css$VirtualDom$Styled$on = F2(
	function (eventName, handler) {
		return A3(
			rtfeldman$elm_css$VirtualDom$Styled$Attribute,
			A2(elm$virtual_dom$VirtualDom$on, eventName, handler),
			_List_Nil,
			'');
	});
var rtfeldman$elm_css$Html$Styled$Events$on = F2(
	function (event, decoder) {
		return A2(
			rtfeldman$elm_css$VirtualDom$Styled$on,
			event,
			elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var rtfeldman$elm_css$Html$Styled$Events$onDoubleClick = function (msg) {
	return A2(
		rtfeldman$elm_css$Html$Styled$Events$on,
		'dblclick',
		elm$json$Json$Decode$succeed(msg));
};
var author$project$Main$errorList = function (stringList) {
	var descWithBreaks = function (desc) {
		return A2(elm$core$String$split, '\n', desc);
	};
	var asP = function (sub) {
		return A2(
			rtfeldman$elm_css$Html$Styled$div,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Attributes$class('error-line')
				]),
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$text(sub)
				]));
	};
	var asLi = function (desc) {
		return A2(
			rtfeldman$elm_css$Html$Styled$li,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Events$onDoubleClick(author$project$Main$ClearErrors)
				]),
			A2(
				elm$core$List$map,
				asP,
				descWithBreaks(desc)));
	};
	return A2(
		rtfeldman$elm_css$Html$Styled$ol,
		_List_Nil,
		A2(elm$core$List$map, asLi, stringList));
};
var rtfeldman$elm_css$Html$Styled$a = rtfeldman$elm_css$Html$Styled$node('a');
var rtfeldman$elm_css$Html$Styled$footer = rtfeldman$elm_css$Html$Styled$node('footer');
var rtfeldman$elm_css$Html$Styled$p = rtfeldman$elm_css$Html$Styled$node('p');
var rtfeldman$elm_css$Html$Styled$Attributes$href = function (url) {
	return A2(rtfeldman$elm_css$Html$Styled$Attributes$stringProperty, 'href', url);
};
var author$project$Main$infoFooter = A2(
	rtfeldman$elm_css$Html$Styled$footer,
	_List_fromArray(
		[
			rtfeldman$elm_css$Html$Styled$Attributes$class('info')
		]),
	_List_fromArray(
		[
			A2(
			rtfeldman$elm_css$Html$Styled$p,
			_List_Nil,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$text('Here we go! Deployment is instant now!')
				])),
			A2(
			rtfeldman$elm_css$Html$Styled$p,
			_List_Nil,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$text('Written by '),
					A2(
					rtfeldman$elm_css$Html$Styled$a,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$href('https://github.com/Erudition')
						]),
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$text('Erudition')
						]))
				])),
			A2(
			rtfeldman$elm_css$Html$Styled$p,
			_List_Nil,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$text('(Increasingly more distant) fork of Evan\'s elm '),
					A2(
					rtfeldman$elm_css$Html$Styled$a,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$href('http://todomvc.com')
						]),
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$text('TodoMVC')
						]))
				]))
		]));
var author$project$SmartTime$Duration$inMinutes = function (duration) {
	return author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$minuteLength;
};
var elm$core$List$sortBy = _List_sortBy;
var author$project$Task$Task$prioritize = function (taskList) {
	var priorityAlgorithm = function (task) {
		return (task.importance * 10) + author$project$SmartTime$Duration$inMinutes(task.maxEffort);
	};
	return A2(elm$core$List$sortBy, priorityAlgorithm, taskList);
};
var author$project$TaskList$AllTasks = {$: 'AllTasks'};
var author$project$TaskList$DeleteComplete = {$: 'DeleteComplete'};
var rtfeldman$elm_css$Html$Styled$button = rtfeldman$elm_css$Html$Styled$node('button');
var rtfeldman$elm_css$Html$Styled$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			rtfeldman$elm_css$VirtualDom$Styled$property,
			key,
			elm$json$Json$Encode$bool(bool));
	});
var rtfeldman$elm_css$Html$Styled$Attributes$hidden = rtfeldman$elm_css$Html$Styled$Attributes$boolProperty('hidden');
var rtfeldman$elm_css$Html$Styled$Events$onClick = function (msg) {
	return A2(
		rtfeldman$elm_css$Html$Styled$Events$on,
		'click',
		elm$json$Json$Decode$succeed(msg));
};
var author$project$TaskList$viewControlsClear = function (tasksCompleted) {
	return A2(
		rtfeldman$elm_css$Html$Styled$button,
		_List_fromArray(
			[
				rtfeldman$elm_css$Html$Styled$Attributes$class('clear-completed'),
				rtfeldman$elm_css$Html$Styled$Attributes$hidden(!tasksCompleted),
				rtfeldman$elm_css$Html$Styled$Events$onClick(author$project$TaskList$DeleteComplete)
			]),
		_List_fromArray(
			[
				rtfeldman$elm_css$Html$Styled$text(
				'Clear completed (' + (elm$core$String$fromInt(tasksCompleted) + ')'))
			]));
};
var rtfeldman$elm_css$Html$Styled$span = rtfeldman$elm_css$Html$Styled$node('span');
var rtfeldman$elm_css$Html$Styled$strong = rtfeldman$elm_css$Html$Styled$node('strong');
var author$project$TaskList$viewControlsCount = function (tasksLeft) {
	var item_ = (tasksLeft === 1) ? ' item' : ' items';
	return A2(
		rtfeldman$elm_css$Html$Styled$span,
		_List_fromArray(
			[
				rtfeldman$elm_css$Html$Styled$Attributes$class('task-count')
			]),
		_List_fromArray(
			[
				A2(
				rtfeldman$elm_css$Html$Styled$strong,
				_List_Nil,
				_List_fromArray(
					[
						rtfeldman$elm_css$Html$Styled$text(
						elm$core$String$fromInt(tasksLeft))
					])),
				rtfeldman$elm_css$Html$Styled$text(item_ + ' left')
			]));
};
var author$project$TaskList$CompleteTasksOnly = {$: 'CompleteTasksOnly'};
var author$project$TaskList$filterName = function (filter) {
	switch (filter.$) {
		case 'AllTasks':
			return 'All';
		case 'CompleteTasksOnly':
			return 'Complete';
		default:
			return 'Remaining';
	}
};
var rtfeldman$elm_css$Html$Styled$Attributes$classList = function (classes) {
	return rtfeldman$elm_css$Html$Styled$Attributes$class(
		A2(
			elm$core$String$join,
			' ',
			A2(
				elm$core$List$map,
				elm$core$Tuple$first,
				A2(elm$core$List$filter, elm$core$Tuple$second, classes))));
};
var author$project$TaskList$visibilitySwap = F3(
	function (uri, visibilityToDisplay, actualVisibility) {
		return A2(
			rtfeldman$elm_css$Html$Styled$li,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					rtfeldman$elm_css$Html$Styled$a,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$href(uri),
							rtfeldman$elm_css$Html$Styled$Attributes$classList(
							_List_fromArray(
								[
									_Utils_Tuple2(
									'selected',
									A2(elm$core$List$member, visibilityToDisplay, actualVisibility))
								]))
						]),
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$text(
							author$project$TaskList$filterName(visibilityToDisplay))
						]))
				]));
	});
var rtfeldman$elm_css$Html$Styled$ul = rtfeldman$elm_css$Html$Styled$node('ul');
var author$project$TaskList$viewControlsFilters = function (visibilityFilters) {
	return A2(
		rtfeldman$elm_css$Html$Styled$ul,
		_List_fromArray(
			[
				rtfeldman$elm_css$Html$Styled$Attributes$class('filters')
			]),
		_List_fromArray(
			[
				A3(author$project$TaskList$visibilitySwap, '#/', author$project$TaskList$AllTasks, visibilityFilters),
				rtfeldman$elm_css$Html$Styled$text(' '),
				A3(author$project$TaskList$visibilitySwap, '#/active', author$project$TaskList$IncompleteTasksOnly, visibilityFilters),
				rtfeldman$elm_css$Html$Styled$text(' '),
				A3(author$project$TaskList$visibilitySwap, '#/completed', author$project$TaskList$CompleteTasksOnly, visibilityFilters)
			]));
};
var elm$virtual_dom$VirtualDom$keyedNode = function (tag) {
	return _VirtualDom_keyedNode(
		_VirtualDom_noScript(tag));
};
var elm$virtual_dom$VirtualDom$keyedNodeNS = F2(
	function (namespace, tag) {
		return A2(
			_VirtualDom_keyedNodeNS,
			namespace,
			_VirtualDom_noScript(tag));
	});
var elm$virtual_dom$VirtualDom$nodeNS = function (tag) {
	return _VirtualDom_nodeNS(
		_VirtualDom_noScript(tag));
};
var rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles = F2(
	function (_n0, styles) {
		var newStyles = _n0.b;
		var classname = _n0.c;
		return elm$core$List$isEmpty(newStyles) ? styles : A3(elm$core$Dict$insert, classname, newStyles, styles);
	});
var rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute = function (_n0) {
	var val = _n0.a;
	return val;
};
var rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml = F2(
	function (_n6, _n7) {
		var key = _n6.a;
		var html = _n6.b;
		var pairs = _n7.a;
		var styles = _n7.b;
		switch (html.$) {
			case 'Unstyled':
				var vdom = html.a;
				return _Utils_Tuple2(
					A2(
						elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					styles);
			case 'Node':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n9 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n9.a;
				var finalStyles = _n9.b;
				var vdom = A3(
					elm$virtual_dom$VirtualDom$node,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
			case 'NodeNS':
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n10 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n10.a;
				var finalStyles = _n10.b;
				var vdom = A4(
					elm$virtual_dom$VirtualDom$nodeNS,
					ns,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
			case 'KeyedNode':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n11 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n11.a;
				var finalStyles = _n11.b;
				var vdom = A3(
					elm$virtual_dom$VirtualDom$keyedNode,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
			default:
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n12 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n12.a;
				var finalStyles = _n12.b;
				var vdom = A4(
					elm$virtual_dom$VirtualDom$keyedNodeNS,
					ns,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(
						elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					finalStyles);
		}
	});
var rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml = F2(
	function (html, _n0) {
		var nodes = _n0.a;
		var styles = _n0.b;
		switch (html.$) {
			case 'Unstyled':
				var vdomNode = html.a;
				return _Utils_Tuple2(
					A2(elm$core$List$cons, vdomNode, nodes),
					styles);
			case 'Node':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n2 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n2.a;
				var finalStyles = _n2.b;
				var vdomNode = A3(
					elm$virtual_dom$VirtualDom$node,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(elm$core$List$cons, vdomNode, nodes),
					finalStyles);
			case 'NodeNS':
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n3 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n3.a;
				var finalStyles = _n3.b;
				var vdomNode = A4(
					elm$virtual_dom$VirtualDom$nodeNS,
					ns,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(elm$core$List$cons, vdomNode, nodes),
					finalStyles);
			case 'KeyedNode':
				var elemType = html.a;
				var properties = html.b;
				var children = html.c;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n4 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n4.a;
				var finalStyles = _n4.b;
				var vdomNode = A3(
					elm$virtual_dom$VirtualDom$keyedNode,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(elm$core$List$cons, vdomNode, nodes),
					finalStyles);
			default:
				var ns = html.a;
				var elemType = html.b;
				var properties = html.c;
				var children = html.d;
				var combinedStyles = A3(elm$core$List$foldl, rtfeldman$elm_css$VirtualDom$Styled$accumulateStyles, styles, properties);
				var _n5 = A3(
					elm$core$List$foldl,
					rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
					_Utils_Tuple2(_List_Nil, combinedStyles),
					children);
				var childNodes = _n5.a;
				var finalStyles = _n5.b;
				var vdomNode = A4(
					elm$virtual_dom$VirtualDom$keyedNodeNS,
					ns,
					elemType,
					A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties),
					elm$core$List$reverse(childNodes));
				return _Utils_Tuple2(
					A2(elm$core$List$cons, vdomNode, nodes),
					finalStyles);
		}
	});
var elm$core$Dict$singleton = F2(
	function (key, value) {
		return A5(elm$core$Dict$RBNode_elm_builtin, elm$core$Dict$Black, key, value, elm$core$Dict$RBEmpty_elm_builtin, elm$core$Dict$RBEmpty_elm_builtin);
	});
var rtfeldman$elm_css$VirtualDom$Styled$stylesFromPropertiesHelp = F2(
	function (candidate, properties) {
		stylesFromPropertiesHelp:
		while (true) {
			if (!properties.b) {
				return candidate;
			} else {
				var _n1 = properties.a;
				var styles = _n1.b;
				var classname = _n1.c;
				var rest = properties.b;
				if (elm$core$String$isEmpty(classname)) {
					var $temp$candidate = candidate,
						$temp$properties = rest;
					candidate = $temp$candidate;
					properties = $temp$properties;
					continue stylesFromPropertiesHelp;
				} else {
					var $temp$candidate = elm$core$Maybe$Just(
						_Utils_Tuple2(classname, styles)),
						$temp$properties = rest;
					candidate = $temp$candidate;
					properties = $temp$properties;
					continue stylesFromPropertiesHelp;
				}
			}
		}
	});
var rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties = function (properties) {
	var _n0 = A2(rtfeldman$elm_css$VirtualDom$Styled$stylesFromPropertiesHelp, elm$core$Maybe$Nothing, properties);
	if (_n0.$ === 'Nothing') {
		return elm$core$Dict$empty;
	} else {
		var _n1 = _n0.a;
		var classname = _n1.a;
		var styles = _n1.b;
		return A2(elm$core$Dict$singleton, classname, styles);
	}
};
var elm$core$List$singleton = function (value) {
	return _List_fromArray(
		[value]);
};
var rtfeldman$elm_css$Css$Preprocess$stylesheet = function (snippets) {
	return {charset: elm$core$Maybe$Nothing, imports: _List_Nil, namespaces: _List_Nil, snippets: snippets};
};
var rtfeldman$elm_css$Css$Preprocess$unwrapSnippet = function (_n0) {
	var declarations = _n0.a;
	return declarations;
};
var elm$core$List$tail = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return elm$core$Maybe$Just(xs);
	} else {
		return elm$core$Maybe$Nothing;
	}
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors = function (declarations) {
	collectSelectors:
	while (true) {
		if (!declarations.b) {
			return _List_Nil;
		} else {
			if (declarations.a.$ === 'StyleBlockDeclaration') {
				var _n1 = declarations.a.a;
				var firstSelector = _n1.a;
				var otherSelectors = _n1.b;
				var rest = declarations.b;
				return _Utils_ap(
					A2(elm$core$List$cons, firstSelector, otherSelectors),
					rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors(rest));
			} else {
				var rest = declarations.b;
				var $temp$declarations = rest;
				declarations = $temp$declarations;
				continue collectSelectors;
			}
		}
	}
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$last = function (list) {
	last:
	while (true) {
		if (!list.b) {
			return elm$core$Maybe$Nothing;
		} else {
			if (!list.b.b) {
				var singleton = list.a;
				return elm$core$Maybe$Just(singleton);
			} else {
				var rest = list.b;
				var $temp$list = rest;
				list = $temp$list;
				continue last;
			}
		}
	}
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$lastDeclaration = function (declarations) {
	lastDeclaration:
	while (true) {
		if (!declarations.b) {
			return elm$core$Maybe$Nothing;
		} else {
			if (!declarations.b.b) {
				var x = declarations.a;
				return elm$core$Maybe$Just(
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
var rtfeldman$elm_css$Css$Preprocess$Resolve$oneOf = function (maybes) {
	oneOf:
	while (true) {
		if (!maybes.b) {
			return elm$core$Maybe$Nothing;
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
var rtfeldman$elm_css$Css$Structure$FontFeatureValues = function (a) {
	return {$: 'FontFeatureValues', a: a};
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$resolveFontFeatureValues = function (tuples) {
	var expandTuples = function (tuplesToExpand) {
		if (!tuplesToExpand.b) {
			return _List_Nil;
		} else {
			var properties = tuplesToExpand.a;
			var rest = tuplesToExpand.b;
			return A2(
				elm$core$List$cons,
				properties,
				expandTuples(rest));
		}
	};
	var newTuples = expandTuples(tuples);
	return _List_fromArray(
		[
			rtfeldman$elm_css$Css$Structure$FontFeatureValues(newTuples)
		]);
};
var rtfeldman$elm_css$Css$Structure$DocumentRule = F5(
	function (a, b, c, d, e) {
		return {$: 'DocumentRule', a: a, b: b, c: c, d: d, e: e};
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule = F5(
	function (str1, str2, str3, str4, declaration) {
		if (declaration.$ === 'StyleBlockDeclaration') {
			var structureStyleBlock = declaration.a;
			return A5(rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4, structureStyleBlock);
		} else {
			return declaration;
		}
	});
var rtfeldman$elm_css$Css$Structure$MediaRule = F2(
	function (a, b) {
		return {$: 'MediaRule', a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$SupportsRule = F2(
	function (a, b) {
		return {$: 'SupportsRule', a: a, b: b};
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule = F2(
	function (mediaQueries, declaration) {
		switch (declaration.$) {
			case 'StyleBlockDeclaration':
				var structureStyleBlock = declaration.a;
				return A2(
					rtfeldman$elm_css$Css$Structure$MediaRule,
					mediaQueries,
					_List_fromArray(
						[structureStyleBlock]));
			case 'MediaRule':
				var newMediaQueries = declaration.a;
				var structureStyleBlocks = declaration.b;
				return A2(
					rtfeldman$elm_css$Css$Structure$MediaRule,
					_Utils_ap(mediaQueries, newMediaQueries),
					structureStyleBlocks);
			case 'SupportsRule':
				var str = declaration.a;
				var declarations = declaration.b;
				return A2(
					rtfeldman$elm_css$Css$Structure$SupportsRule,
					str,
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule(mediaQueries),
						declarations));
			case 'DocumentRule':
				var str1 = declaration.a;
				var str2 = declaration.b;
				var str3 = declaration.c;
				var str4 = declaration.d;
				var structureStyleBlock = declaration.e;
				return A5(rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4, structureStyleBlock);
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
var rtfeldman$elm_css$Css$Structure$CounterStyle = function (a) {
	return {$: 'CounterStyle', a: a};
};
var rtfeldman$elm_css$Css$Structure$FontFace = function (a) {
	return {$: 'FontFace', a: a};
};
var rtfeldman$elm_css$Css$Structure$Keyframes = function (a) {
	return {$: 'Keyframes', a: a};
};
var rtfeldman$elm_css$Css$Structure$PageRule = F2(
	function (a, b) {
		return {$: 'PageRule', a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$Selector = F3(
	function (a, b, c) {
		return {$: 'Selector', a: a, b: b, c: c};
	});
var rtfeldman$elm_css$Css$Structure$StyleBlock = F3(
	function (a, b, c) {
		return {$: 'StyleBlock', a: a, b: b, c: c};
	});
var rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration = function (a) {
	return {$: 'StyleBlockDeclaration', a: a};
};
var rtfeldman$elm_css$Css$Structure$Viewport = function (a) {
	return {$: 'Viewport', a: a};
};
var rtfeldman$elm_css$Css$Structure$mapLast = F2(
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
					elm$core$List$cons,
					first,
					A2(rtfeldman$elm_css$Css$Structure$mapLast, update, rest));
			}
		}
	});
var rtfeldman$elm_css$Css$Structure$withPropertyAppended = F2(
	function (property, _n0) {
		var firstSelector = _n0.a;
		var otherSelectors = _n0.b;
		var properties = _n0.c;
		return A3(
			rtfeldman$elm_css$Css$Structure$StyleBlock,
			firstSelector,
			otherSelectors,
			_Utils_ap(
				properties,
				_List_fromArray(
					[property])));
	});
var rtfeldman$elm_css$Css$Structure$appendProperty = F2(
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
								rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
								A2(rtfeldman$elm_css$Css$Structure$withPropertyAppended, property, styleBlock))
							]);
					case 'MediaRule':
						var _n1 = declarations.a;
						var mediaQueries = _n1.a;
						var styleBlocks = _n1.b;
						return _List_fromArray(
							[
								A2(
								rtfeldman$elm_css$Css$Structure$MediaRule,
								mediaQueries,
								A2(
									rtfeldman$elm_css$Css$Structure$mapLast,
									rtfeldman$elm_css$Css$Structure$withPropertyAppended(property),
									styleBlocks))
							]);
					default:
						return declarations;
				}
			} else {
				var first = declarations.a;
				var rest = declarations.b;
				return A2(
					elm$core$List$cons,
					first,
					A2(rtfeldman$elm_css$Css$Structure$appendProperty, property, rest));
			}
		}
	});
var rtfeldman$elm_css$Css$Structure$appendToLastSelector = F2(
	function (f, styleBlock) {
		if (!styleBlock.b.b) {
			var only = styleBlock.a;
			var properties = styleBlock.c;
			return _List_fromArray(
				[
					A3(rtfeldman$elm_css$Css$Structure$StyleBlock, only, _List_Nil, properties),
					A3(
					rtfeldman$elm_css$Css$Structure$StyleBlock,
					f(only),
					_List_Nil,
					_List_Nil)
				]);
		} else {
			var first = styleBlock.a;
			var rest = styleBlock.b;
			var properties = styleBlock.c;
			var newRest = A2(elm$core$List$map, f, rest);
			var newFirst = f(first);
			return _List_fromArray(
				[
					A3(rtfeldman$elm_css$Css$Structure$StyleBlock, first, rest, properties),
					A3(rtfeldman$elm_css$Css$Structure$StyleBlock, newFirst, newRest, _List_Nil)
				]);
		}
	});
var rtfeldman$elm_css$Css$Structure$applyPseudoElement = F2(
	function (pseudo, _n0) {
		var sequence = _n0.a;
		var selectors = _n0.b;
		return A3(
			rtfeldman$elm_css$Css$Structure$Selector,
			sequence,
			selectors,
			elm$core$Maybe$Just(pseudo));
	});
var rtfeldman$elm_css$Css$Structure$appendPseudoElementToLastSelector = F2(
	function (pseudo, styleBlock) {
		return A2(
			rtfeldman$elm_css$Css$Structure$appendToLastSelector,
			rtfeldman$elm_css$Css$Structure$applyPseudoElement(pseudo),
			styleBlock);
	});
var rtfeldman$elm_css$Css$Structure$CustomSelector = F2(
	function (a, b) {
		return {$: 'CustomSelector', a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$TypeSelectorSequence = F2(
	function (a, b) {
		return {$: 'TypeSelectorSequence', a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence = function (a) {
	return {$: 'UniversalSelectorSequence', a: a};
};
var rtfeldman$elm_css$Css$Structure$appendRepeatable = F2(
	function (selector, sequence) {
		switch (sequence.$) {
			case 'TypeSelectorSequence':
				var typeSelector = sequence.a;
				var list = sequence.b;
				return A2(
					rtfeldman$elm_css$Css$Structure$TypeSelectorSequence,
					typeSelector,
					_Utils_ap(
						list,
						_List_fromArray(
							[selector])));
			case 'UniversalSelectorSequence':
				var list = sequence.a;
				return rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence(
					_Utils_ap(
						list,
						_List_fromArray(
							[selector])));
			default:
				var str = sequence.a;
				var list = sequence.b;
				return A2(
					rtfeldman$elm_css$Css$Structure$CustomSelector,
					str,
					_Utils_ap(
						list,
						_List_fromArray(
							[selector])));
		}
	});
var rtfeldman$elm_css$Css$Structure$appendRepeatableWithCombinator = F2(
	function (selector, list) {
		if (!list.b) {
			return _List_Nil;
		} else {
			if (!list.b.b) {
				var _n1 = list.a;
				var combinator = _n1.a;
				var sequence = _n1.b;
				return _List_fromArray(
					[
						_Utils_Tuple2(
						combinator,
						A2(rtfeldman$elm_css$Css$Structure$appendRepeatable, selector, sequence))
					]);
			} else {
				var first = list.a;
				var rest = list.b;
				return A2(
					elm$core$List$cons,
					first,
					A2(rtfeldman$elm_css$Css$Structure$appendRepeatableWithCombinator, selector, rest));
			}
		}
	});
var rtfeldman$elm_css$Css$Structure$appendRepeatableSelector = F2(
	function (repeatableSimpleSelector, selector) {
		if (!selector.b.b) {
			var sequence = selector.a;
			var pseudoElement = selector.c;
			return A3(
				rtfeldman$elm_css$Css$Structure$Selector,
				A2(rtfeldman$elm_css$Css$Structure$appendRepeatable, repeatableSimpleSelector, sequence),
				_List_Nil,
				pseudoElement);
		} else {
			var firstSelector = selector.a;
			var tuples = selector.b;
			var pseudoElement = selector.c;
			return A3(
				rtfeldman$elm_css$Css$Structure$Selector,
				firstSelector,
				A2(rtfeldman$elm_css$Css$Structure$appendRepeatableWithCombinator, repeatableSimpleSelector, tuples),
				pseudoElement);
		}
	});
var rtfeldman$elm_css$Css$Structure$appendRepeatableToLastSelector = F2(
	function (selector, styleBlock) {
		return A2(
			rtfeldman$elm_css$Css$Structure$appendToLastSelector,
			rtfeldman$elm_css$Css$Structure$appendRepeatableSelector(selector),
			styleBlock);
	});
var rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock = F2(
	function (update, declarations) {
		_n0$12:
		while (true) {
			if (!declarations.b) {
				return declarations;
			} else {
				if (!declarations.b.b) {
					switch (declarations.a.$) {
						case 'StyleBlockDeclaration':
							var styleBlock = declarations.a.a;
							return A2(
								elm$core$List$map,
								rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration,
								update(styleBlock));
						case 'MediaRule':
							if (declarations.a.b.b) {
								if (!declarations.a.b.b.b) {
									var _n1 = declarations.a;
									var mediaQueries = _n1.a;
									var _n2 = _n1.b;
									var styleBlock = _n2.a;
									return _List_fromArray(
										[
											A2(
											rtfeldman$elm_css$Css$Structure$MediaRule,
											mediaQueries,
											update(styleBlock))
										]);
								} else {
									var _n3 = declarations.a;
									var mediaQueries = _n3.a;
									var _n4 = _n3.b;
									var first = _n4.a;
									var rest = _n4.b;
									var _n5 = A2(
										rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock,
										update,
										_List_fromArray(
											[
												A2(rtfeldman$elm_css$Css$Structure$MediaRule, mediaQueries, rest)
											]));
									if ((_n5.b && (_n5.a.$ === 'MediaRule')) && (!_n5.b.b)) {
										var _n6 = _n5.a;
										var newMediaQueries = _n6.a;
										var newStyleBlocks = _n6.b;
										return _List_fromArray(
											[
												A2(
												rtfeldman$elm_css$Css$Structure$MediaRule,
												newMediaQueries,
												A2(elm$core$List$cons, first, newStyleBlocks))
											]);
									} else {
										var newDeclarations = _n5;
										return newDeclarations;
									}
								}
							} else {
								break _n0$12;
							}
						case 'SupportsRule':
							var _n7 = declarations.a;
							var str = _n7.a;
							var nestedDeclarations = _n7.b;
							return _List_fromArray(
								[
									A2(
									rtfeldman$elm_css$Css$Structure$SupportsRule,
									str,
									A2(rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock, update, nestedDeclarations))
								]);
						case 'DocumentRule':
							var _n8 = declarations.a;
							var str1 = _n8.a;
							var str2 = _n8.b;
							var str3 = _n8.c;
							var str4 = _n8.d;
							var styleBlock = _n8.e;
							return A2(
								elm$core$List$map,
								A4(rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4),
								update(styleBlock));
						case 'PageRule':
							var _n9 = declarations.a;
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
					break _n0$12;
				}
			}
		}
		var first = declarations.a;
		var rest = declarations.b;
		return A2(
			elm$core$List$cons,
			first,
			A2(rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock, update, rest));
	});
var rtfeldman$elm_css$Css$Structure$styleBlockToMediaRule = F2(
	function (mediaQueries, declaration) {
		if (declaration.$ === 'StyleBlockDeclaration') {
			var styleBlock = declaration.a;
			return A2(
				rtfeldman$elm_css$Css$Structure$MediaRule,
				mediaQueries,
				_List_fromArray(
					[styleBlock]));
		} else {
			return declaration;
		}
	});
var Skinney$murmur3$Murmur3$HashData = F4(
	function (shift, seed, hash, charsProcessed) {
		return {charsProcessed: charsProcessed, hash: hash, seed: seed, shift: shift};
	});
var Skinney$murmur3$Murmur3$c1 = 3432918353;
var Skinney$murmur3$Murmur3$c2 = 461845907;
var Skinney$murmur3$Murmur3$multiplyBy = F2(
	function (b, a) {
		return ((a & 65535) * b) + ((((a >>> 16) * b) & 65535) << 16);
	});
var Skinney$murmur3$Murmur3$rotlBy = F2(
	function (b, a) {
		return (a << b) | (a >>> (32 - b));
	});
var Skinney$murmur3$Murmur3$finalize = function (data) {
	var acc = data.hash ? (data.seed ^ A2(
		Skinney$murmur3$Murmur3$multiplyBy,
		Skinney$murmur3$Murmur3$c2,
		A2(
			Skinney$murmur3$Murmur3$rotlBy,
			15,
			A2(Skinney$murmur3$Murmur3$multiplyBy, Skinney$murmur3$Murmur3$c1, data.hash)))) : data.seed;
	var h0 = acc ^ data.charsProcessed;
	var h1 = A2(Skinney$murmur3$Murmur3$multiplyBy, 2246822507, h0 ^ (h0 >>> 16));
	var h2 = A2(Skinney$murmur3$Murmur3$multiplyBy, 3266489909, h1 ^ (h1 >>> 13));
	return (h2 ^ (h2 >>> 16)) >>> 0;
};
var Skinney$murmur3$Murmur3$mix = F2(
	function (h1, k1) {
		return A2(
			Skinney$murmur3$Murmur3$multiplyBy,
			5,
			A2(
				Skinney$murmur3$Murmur3$rotlBy,
				13,
				h1 ^ A2(
					Skinney$murmur3$Murmur3$multiplyBy,
					Skinney$murmur3$Murmur3$c2,
					A2(
						Skinney$murmur3$Murmur3$rotlBy,
						15,
						A2(Skinney$murmur3$Murmur3$multiplyBy, Skinney$murmur3$Murmur3$c1, k1))))) + 3864292196;
	});
var Skinney$murmur3$Murmur3$hashFold = F2(
	function (c, data) {
		var res = data.hash | ((255 & elm$core$Char$toCode(c)) << data.shift);
		var _n0 = data.shift;
		if (_n0 === 24) {
			return {
				charsProcessed: data.charsProcessed + 1,
				hash: 0,
				seed: A2(Skinney$murmur3$Murmur3$mix, data.seed, res),
				shift: 0
			};
		} else {
			return {charsProcessed: data.charsProcessed + 1, hash: res, seed: data.seed, shift: data.shift + 8};
		}
	});
var elm$core$String$foldl = _String_foldl;
var Skinney$murmur3$Murmur3$hashString = F2(
	function (seed, str) {
		return Skinney$murmur3$Murmur3$finalize(
			A3(
				elm$core$String$foldl,
				Skinney$murmur3$Murmur3$hashFold,
				A4(Skinney$murmur3$Murmur3$HashData, 0, seed, 0, 0),
				str));
	});
var elm$core$String$cons = _String_cons;
var rtfeldman$elm_css$Hash$murmurSeed = 15739;
var elm$core$String$fromList = _String_fromList;
var rtfeldman$elm_hex$Hex$unsafeToDigit = function (num) {
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
var rtfeldman$elm_hex$Hex$unsafePositiveToDigits = F2(
	function (digits, num) {
		unsafePositiveToDigits:
		while (true) {
			if (num < 16) {
				return A2(
					elm$core$List$cons,
					rtfeldman$elm_hex$Hex$unsafeToDigit(num),
					digits);
			} else {
				var $temp$digits = A2(
					elm$core$List$cons,
					rtfeldman$elm_hex$Hex$unsafeToDigit(
						A2(elm$core$Basics$modBy, 16, num)),
					digits),
					$temp$num = (num / 16) | 0;
				digits = $temp$digits;
				num = $temp$num;
				continue unsafePositiveToDigits;
			}
		}
	});
var rtfeldman$elm_hex$Hex$toString = function (num) {
	return elm$core$String$fromList(
		(num < 0) ? A2(
			elm$core$List$cons,
			_Utils_chr('-'),
			A2(rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, -num)) : A2(rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, num));
};
var rtfeldman$elm_css$Hash$fromString = function (str) {
	return A2(
		elm$core$String$cons,
		_Utils_chr('_'),
		rtfeldman$elm_hex$Hex$toString(
			A2(Skinney$murmur3$Murmur3$hashString, rtfeldman$elm_css$Hash$murmurSeed, str)));
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$applyNestedStylesToLast = F4(
	function (nestedStyles, rest, f, declarations) {
		var withoutParent = function (decls) {
			return A2(
				elm$core$Maybe$withDefault,
				_List_Nil,
				elm$core$List$tail(decls));
		};
		var nextResult = A2(
			rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
			rest,
			A2(
				elm$core$Maybe$withDefault,
				_List_Nil,
				rtfeldman$elm_css$Css$Preprocess$Resolve$lastDeclaration(declarations)));
		var newDeclarations = function () {
			var _n14 = _Utils_Tuple2(
				elm$core$List$head(nextResult),
				rtfeldman$elm_css$Css$Preprocess$Resolve$last(declarations));
			if ((_n14.a.$ === 'Just') && (_n14.b.$ === 'Just')) {
				var nextResultParent = _n14.a.a;
				var originalParent = _n14.b.a;
				return _Utils_ap(
					A2(
						elm$core$List$take,
						elm$core$List$length(declarations) - 1,
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
			return elm$core$List$concat(
				A2(
					rtfeldman$elm_css$Css$Structure$mapLast,
					rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles(nestedStyles),
					A2(
						elm$core$List$map,
						elm$core$List$singleton,
						A2(rtfeldman$elm_css$Css$Structure$concatMapLastStyleBlock, f, lastDecl))));
		};
		var initialResult = A2(
			elm$core$Maybe$withDefault,
			_List_Nil,
			A2(
				elm$core$Maybe$map,
				insertStylesToNestedDecl,
				rtfeldman$elm_css$Css$Preprocess$Resolve$lastDeclaration(declarations)));
		return _Utils_ap(
			newDeclarations,
			_Utils_ap(
				withoutParent(initialResult),
				withoutParent(nextResult)));
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles = F2(
	function (styles, declarations) {
		if (!styles.b) {
			return declarations;
		} else {
			switch (styles.a.$) {
				case 'AppendProperty':
					var property = styles.a.a;
					var rest = styles.b;
					return A2(
						rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
						rest,
						A2(rtfeldman$elm_css$Css$Structure$appendProperty, property, declarations));
				case 'ExtendSelector':
					var _n4 = styles.a;
					var selector = _n4.a;
					var nestedStyles = _n4.b;
					var rest = styles.b;
					return A4(
						rtfeldman$elm_css$Css$Preprocess$Resolve$applyNestedStylesToLast,
						nestedStyles,
						rest,
						rtfeldman$elm_css$Css$Structure$appendRepeatableToLastSelector(selector),
						declarations);
				case 'NestSnippet':
					var _n5 = styles.a;
					var selectorCombinator = _n5.a;
					var snippets = _n5.b;
					var rest = styles.b;
					var chain = F2(
						function (_n9, _n10) {
							var originalSequence = _n9.a;
							var originalTuples = _n9.b;
							var originalPseudoElement = _n9.c;
							var newSequence = _n10.a;
							var newTuples = _n10.b;
							var newPseudoElement = _n10.c;
							return A3(
								rtfeldman$elm_css$Css$Structure$Selector,
								originalSequence,
								_Utils_ap(
									originalTuples,
									A2(
										elm$core$List$cons,
										_Utils_Tuple2(selectorCombinator, newSequence),
										newTuples)),
								rtfeldman$elm_css$Css$Preprocess$Resolve$oneOf(
									_List_fromArray(
										[newPseudoElement, originalPseudoElement])));
						});
					var expandDeclaration = function (declaration) {
						switch (declaration.$) {
							case 'StyleBlockDeclaration':
								var _n7 = declaration.a;
								var firstSelector = _n7.a;
								var otherSelectors = _n7.b;
								var nestedStyles = _n7.c;
								var newSelectors = A2(
									elm$core$List$concatMap,
									function (originalSelector) {
										return A2(
											elm$core$List$map,
											chain(originalSelector),
											A2(elm$core$List$cons, firstSelector, otherSelectors));
									},
									rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors(declarations));
								var newDeclarations = function () {
									if (!newSelectors.b) {
										return _List_Nil;
									} else {
										var first = newSelectors.a;
										var remainder = newSelectors.b;
										return _List_fromArray(
											[
												rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
												A3(rtfeldman$elm_css$Css$Structure$StyleBlock, first, remainder, _List_Nil))
											]);
									}
								}();
								return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles, nestedStyles, newDeclarations);
							case 'MediaRule':
								var mediaQueries = declaration.a;
								var styleBlocks = declaration.b;
								return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule, mediaQueries, styleBlocks);
							case 'SupportsRule':
								var str = declaration.a;
								var otherSnippets = declaration.b;
								return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule, str, otherSnippets);
							case 'DocumentRule':
								var str1 = declaration.a;
								var str2 = declaration.b;
								var str3 = declaration.c;
								var str4 = declaration.d;
								var styleBlock = declaration.e;
								return A2(
									elm$core$List$map,
									A4(rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule, str1, str2, str3, str4),
									rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
							case 'PageRule':
								var str = declaration.a;
								var properties = declaration.b;
								return _List_fromArray(
									[
										A2(rtfeldman$elm_css$Css$Structure$PageRule, str, properties)
									]);
							case 'FontFace':
								var properties = declaration.a;
								return _List_fromArray(
									[
										rtfeldman$elm_css$Css$Structure$FontFace(properties)
									]);
							case 'Viewport':
								var properties = declaration.a;
								return _List_fromArray(
									[
										rtfeldman$elm_css$Css$Structure$Viewport(properties)
									]);
							case 'CounterStyle':
								var properties = declaration.a;
								return _List_fromArray(
									[
										rtfeldman$elm_css$Css$Structure$CounterStyle(properties)
									]);
							default:
								var tuples = declaration.a;
								return rtfeldman$elm_css$Css$Preprocess$Resolve$resolveFontFeatureValues(tuples);
						}
					};
					return elm$core$List$concat(
						_Utils_ap(
							_List_fromArray(
								[
									A2(rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles, rest, declarations)
								]),
							A2(
								elm$core$List$map,
								expandDeclaration,
								A2(elm$core$List$concatMap, rtfeldman$elm_css$Css$Preprocess$unwrapSnippet, snippets))));
				case 'WithPseudoElement':
					var _n11 = styles.a;
					var pseudoElement = _n11.a;
					var nestedStyles = _n11.b;
					var rest = styles.b;
					return A4(
						rtfeldman$elm_css$Css$Preprocess$Resolve$applyNestedStylesToLast,
						nestedStyles,
						rest,
						rtfeldman$elm_css$Css$Structure$appendPseudoElementToLastSelector(pseudoElement),
						declarations);
				case 'WithKeyframes':
					var str = styles.a.a;
					var rest = styles.b;
					var name = rtfeldman$elm_css$Hash$fromString(str);
					var newProperty = 'animation-name:' + name;
					var newDeclarations = A2(
						rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
						rest,
						A2(rtfeldman$elm_css$Css$Structure$appendProperty, newProperty, declarations));
					return A2(
						elm$core$List$append,
						newDeclarations,
						_List_fromArray(
							[
								rtfeldman$elm_css$Css$Structure$Keyframes(
								{declaration: str, name: name})
							]));
				case 'WithMedia':
					var _n12 = styles.a;
					var mediaQueries = _n12.a;
					var nestedStyles = _n12.b;
					var rest = styles.b;
					var extraDeclarations = function () {
						var _n13 = rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors(declarations);
						if (!_n13.b) {
							return _List_Nil;
						} else {
							var firstSelector = _n13.a;
							var otherSelectors = _n13.b;
							return A2(
								elm$core$List$map,
								rtfeldman$elm_css$Css$Structure$styleBlockToMediaRule(mediaQueries),
								A2(
									rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
									nestedStyles,
									elm$core$List$singleton(
										rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
											A3(rtfeldman$elm_css$Css$Structure$StyleBlock, firstSelector, otherSelectors, _List_Nil)))));
						}
					}();
					return _Utils_ap(
						A2(rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles, rest, declarations),
						extraDeclarations);
				default:
					var otherStyles = styles.a.a;
					var rest = styles.b;
					return A2(
						rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
						_Utils_ap(otherStyles, rest),
						declarations);
			}
		}
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock = function (_n2) {
	var firstSelector = _n2.a;
	var otherSelectors = _n2.b;
	var styles = _n2.c;
	return A2(
		rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
		styles,
		_List_fromArray(
			[
				rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
				A3(rtfeldman$elm_css$Css$Structure$StyleBlock, firstSelector, otherSelectors, _List_Nil))
			]));
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$extract = function (snippetDeclarations) {
	if (!snippetDeclarations.b) {
		return _List_Nil;
	} else {
		var first = snippetDeclarations.a;
		var rest = snippetDeclarations.b;
		return _Utils_ap(
			rtfeldman$elm_css$Css$Preprocess$Resolve$toDeclarations(first),
			rtfeldman$elm_css$Css$Preprocess$Resolve$extract(rest));
	}
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule = F2(
	function (mediaQueries, styleBlocks) {
		var handleStyleBlock = function (styleBlock) {
			return A2(
				elm$core$List$map,
				rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule(mediaQueries),
				rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
		};
		return A2(elm$core$List$concatMap, handleStyleBlock, styleBlocks);
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule = F2(
	function (str, snippets) {
		var declarations = rtfeldman$elm_css$Css$Preprocess$Resolve$extract(
			A2(elm$core$List$concatMap, rtfeldman$elm_css$Css$Preprocess$unwrapSnippet, snippets));
		return _List_fromArray(
			[
				A2(rtfeldman$elm_css$Css$Structure$SupportsRule, str, declarations)
			]);
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$toDeclarations = function (snippetDeclaration) {
	switch (snippetDeclaration.$) {
		case 'StyleBlockDeclaration':
			var styleBlock = snippetDeclaration.a;
			return rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock);
		case 'MediaRule':
			var mediaQueries = snippetDeclaration.a;
			var styleBlocks = snippetDeclaration.b;
			return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule, mediaQueries, styleBlocks);
		case 'SupportsRule':
			var str = snippetDeclaration.a;
			var snippets = snippetDeclaration.b;
			return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule, str, snippets);
		case 'DocumentRule':
			var str1 = snippetDeclaration.a;
			var str2 = snippetDeclaration.b;
			var str3 = snippetDeclaration.c;
			var str4 = snippetDeclaration.d;
			var styleBlock = snippetDeclaration.e;
			return A2(
				elm$core$List$map,
				A4(rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule, str1, str2, str3, str4),
				rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
		case 'PageRule':
			var str = snippetDeclaration.a;
			var properties = snippetDeclaration.b;
			return _List_fromArray(
				[
					A2(rtfeldman$elm_css$Css$Structure$PageRule, str, properties)
				]);
		case 'FontFace':
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					rtfeldman$elm_css$Css$Structure$FontFace(properties)
				]);
		case 'Viewport':
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					rtfeldman$elm_css$Css$Structure$Viewport(properties)
				]);
		case 'CounterStyle':
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					rtfeldman$elm_css$Css$Structure$CounterStyle(properties)
				]);
		default:
			var tuples = snippetDeclaration.a;
			return rtfeldman$elm_css$Css$Preprocess$Resolve$resolveFontFeatureValues(tuples);
	}
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$toStructure = function (_n0) {
	var charset = _n0.charset;
	var imports = _n0.imports;
	var namespaces = _n0.namespaces;
	var snippets = _n0.snippets;
	var declarations = rtfeldman$elm_css$Css$Preprocess$Resolve$extract(
		A2(elm$core$List$concatMap, rtfeldman$elm_css$Css$Preprocess$unwrapSnippet, snippets));
	return {charset: charset, declarations: declarations, imports: imports, namespaces: namespaces};
};
var elm$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			elm$core$List$any,
			A2(elm$core$Basics$composeL, elm$core$Basics$not, isOkay),
			list);
	});
var rtfeldman$elm_css$Css$Structure$compactHelp = F2(
	function (declaration, _n0) {
		var keyframesByName = _n0.a;
		var declarations = _n0.b;
		switch (declaration.$) {
			case 'StyleBlockDeclaration':
				var _n2 = declaration.a;
				var properties = _n2.c;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 'MediaRule':
				var styleBlocks = declaration.b;
				return A2(
					elm$core$List$all,
					function (_n3) {
						var properties = _n3.c;
						return elm$core$List$isEmpty(properties);
					},
					styleBlocks) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 'SupportsRule':
				var otherDeclarations = declaration.b;
				return elm$core$List$isEmpty(otherDeclarations) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 'DocumentRule':
				return _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 'PageRule':
				var properties = declaration.b;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 'FontFace':
				var properties = declaration.a;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 'Keyframes':
				var record = declaration.a;
				return elm$core$String$isEmpty(record.declaration) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					A3(elm$core$Dict$insert, record.name, record.declaration, keyframesByName),
					declarations);
			case 'Viewport':
				var properties = declaration.a;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 'CounterStyle':
				var properties = declaration.a;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			default:
				var tuples = declaration.a;
				return A2(
					elm$core$List$all,
					function (_n4) {
						var properties = _n4.b;
						return elm$core$List$isEmpty(properties);
					},
					tuples) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
		}
	});
var rtfeldman$elm_css$Css$Structure$withKeyframeDeclarations = F2(
	function (keyframesByName, compactedDeclarations) {
		return A2(
			elm$core$List$append,
			A2(
				elm$core$List$map,
				function (_n0) {
					var name = _n0.a;
					var decl = _n0.b;
					return rtfeldman$elm_css$Css$Structure$Keyframes(
						{declaration: decl, name: name});
				},
				elm$core$Dict$toList(keyframesByName)),
			compactedDeclarations);
	});
var rtfeldman$elm_css$Css$Structure$compactStylesheet = function (_n0) {
	var charset = _n0.charset;
	var imports = _n0.imports;
	var namespaces = _n0.namespaces;
	var declarations = _n0.declarations;
	var _n1 = A3(
		elm$core$List$foldr,
		rtfeldman$elm_css$Css$Structure$compactHelp,
		_Utils_Tuple2(elm$core$Dict$empty, _List_Nil),
		declarations);
	var keyframesByName = _n1.a;
	var compactedDeclarations = _n1.b;
	var finalDeclarations = A2(rtfeldman$elm_css$Css$Structure$withKeyframeDeclarations, keyframesByName, compactedDeclarations);
	return {charset: charset, declarations: finalDeclarations, imports: imports, namespaces: namespaces};
};
var rtfeldman$elm_css$Css$Structure$Output$charsetToString = function (charset) {
	return A2(
		elm$core$Maybe$withDefault,
		'',
		A2(
			elm$core$Maybe$map,
			function (str) {
				return '@charset \"' + (str + '\"');
			},
			charset));
};
var rtfeldman$elm_css$Css$Structure$Output$mediaExpressionToString = function (expression) {
	return '(' + (expression.feature + (A2(
		elm$core$Maybe$withDefault,
		'',
		A2(
			elm$core$Maybe$map,
			elm$core$Basics$append(': '),
			expression.value)) + ')'));
};
var rtfeldman$elm_css$Css$Structure$Output$mediaTypeToString = function (mediaType) {
	switch (mediaType.$) {
		case 'Print':
			return 'print';
		case 'Screen':
			return 'screen';
		default:
			return 'speech';
	}
};
var rtfeldman$elm_css$Css$Structure$Output$mediaQueryToString = function (mediaQuery) {
	var prefixWith = F3(
		function (str, mediaType, expressions) {
			return str + (' ' + A2(
				elm$core$String$join,
				' and ',
				A2(
					elm$core$List$cons,
					rtfeldman$elm_css$Css$Structure$Output$mediaTypeToString(mediaType),
					A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$mediaExpressionToString, expressions))));
		});
	switch (mediaQuery.$) {
		case 'AllQuery':
			var expressions = mediaQuery.a;
			return A2(
				elm$core$String$join,
				' and ',
				A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$mediaExpressionToString, expressions));
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
var rtfeldman$elm_css$Css$Structure$Output$importMediaQueryToString = F2(
	function (name, mediaQuery) {
		return '@import \"' + (name + (rtfeldman$elm_css$Css$Structure$Output$mediaQueryToString(mediaQuery) + '\"'));
	});
var rtfeldman$elm_css$Css$Structure$Output$importToString = function (_n0) {
	var name = _n0.a;
	var mediaQueries = _n0.b;
	return A2(
		elm$core$String$join,
		'\n',
		A2(
			elm$core$List$map,
			rtfeldman$elm_css$Css$Structure$Output$importMediaQueryToString(name),
			mediaQueries));
};
var rtfeldman$elm_css$Css$Structure$Output$namespaceToString = function (_n0) {
	var prefix = _n0.a;
	var str = _n0.b;
	return '@namespace ' + (prefix + ('\"' + (str + '\"')));
};
var rtfeldman$elm_css$Css$Structure$Output$spaceIndent = '    ';
var rtfeldman$elm_css$Css$Structure$Output$indent = function (str) {
	return _Utils_ap(rtfeldman$elm_css$Css$Structure$Output$spaceIndent, str);
};
var rtfeldman$elm_css$Css$Structure$Output$noIndent = '';
var rtfeldman$elm_css$Css$Structure$Output$emitProperty = function (str) {
	return str + ';';
};
var rtfeldman$elm_css$Css$Structure$Output$emitProperties = function (properties) {
	return A2(
		elm$core$String$join,
		'\n',
		A2(
			elm$core$List$map,
			A2(elm$core$Basics$composeL, rtfeldman$elm_css$Css$Structure$Output$indent, rtfeldman$elm_css$Css$Structure$Output$emitProperty),
			properties));
};
var elm$core$String$append = _String_append;
var rtfeldman$elm_css$Css$Structure$Output$pseudoElementToString = function (_n0) {
	var str = _n0.a;
	return '::' + str;
};
var rtfeldman$elm_css$Css$Structure$Output$combinatorToString = function (combinator) {
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
var rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString = function (repeatableSimpleSelector) {
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
var rtfeldman$elm_css$Css$Structure$Output$simpleSelectorSequenceToString = function (simpleSelectorSequence) {
	switch (simpleSelectorSequence.$) {
		case 'TypeSelectorSequence':
			var str = simpleSelectorSequence.a.a;
			var repeatableSimpleSelectors = simpleSelectorSequence.b;
			return A2(
				elm$core$String$join,
				'',
				A2(
					elm$core$List$cons,
					str,
					A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString, repeatableSimpleSelectors)));
		case 'UniversalSelectorSequence':
			var repeatableSimpleSelectors = simpleSelectorSequence.a;
			return elm$core$List$isEmpty(repeatableSimpleSelectors) ? '*' : A2(
				elm$core$String$join,
				'',
				A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString, repeatableSimpleSelectors));
		default:
			var str = simpleSelectorSequence.a;
			var repeatableSimpleSelectors = simpleSelectorSequence.b;
			return A2(
				elm$core$String$join,
				'',
				A2(
					elm$core$List$cons,
					str,
					A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString, repeatableSimpleSelectors)));
	}
};
var rtfeldman$elm_css$Css$Structure$Output$selectorChainToString = function (_n0) {
	var combinator = _n0.a;
	var sequence = _n0.b;
	return A2(
		elm$core$String$join,
		' ',
		_List_fromArray(
			[
				rtfeldman$elm_css$Css$Structure$Output$combinatorToString(combinator),
				rtfeldman$elm_css$Css$Structure$Output$simpleSelectorSequenceToString(sequence)
			]));
};
var rtfeldman$elm_css$Css$Structure$Output$selectorToString = function (_n0) {
	var simpleSelectorSequence = _n0.a;
	var chain = _n0.b;
	var pseudoElement = _n0.c;
	var segments = A2(
		elm$core$List$cons,
		rtfeldman$elm_css$Css$Structure$Output$simpleSelectorSequenceToString(simpleSelectorSequence),
		A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$selectorChainToString, chain));
	var pseudoElementsString = A2(
		elm$core$String$join,
		'',
		_List_fromArray(
			[
				A2(
				elm$core$Maybe$withDefault,
				'',
				A2(elm$core$Maybe$map, rtfeldman$elm_css$Css$Structure$Output$pseudoElementToString, pseudoElement))
			]));
	return A2(
		elm$core$String$append,
		A2(
			elm$core$String$join,
			' ',
			A2(
				elm$core$List$filter,
				A2(elm$core$Basics$composeL, elm$core$Basics$not, elm$core$String$isEmpty),
				segments)),
		pseudoElementsString);
};
var rtfeldman$elm_css$Css$Structure$Output$prettyPrintStyleBlock = F2(
	function (indentLevel, _n0) {
		var firstSelector = _n0.a;
		var otherSelectors = _n0.b;
		var properties = _n0.c;
		var selectorStr = A2(
			elm$core$String$join,
			', ',
			A2(
				elm$core$List$map,
				rtfeldman$elm_css$Css$Structure$Output$selectorToString,
				A2(elm$core$List$cons, firstSelector, otherSelectors)));
		return A2(
			elm$core$String$join,
			'',
			_List_fromArray(
				[
					selectorStr,
					' {\n',
					indentLevel,
					rtfeldman$elm_css$Css$Structure$Output$emitProperties(properties),
					'\n',
					indentLevel,
					'}'
				]));
	});
var rtfeldman$elm_css$Css$Structure$Output$prettyPrintDeclaration = function (decl) {
	switch (decl.$) {
		case 'StyleBlockDeclaration':
			var styleBlock = decl.a;
			return A2(rtfeldman$elm_css$Css$Structure$Output$prettyPrintStyleBlock, rtfeldman$elm_css$Css$Structure$Output$noIndent, styleBlock);
		case 'MediaRule':
			var mediaQueries = decl.a;
			var styleBlocks = decl.b;
			var query = A2(
				elm$core$String$join,
				',\n',
				A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$mediaQueryToString, mediaQueries));
			var blocks = A2(
				elm$core$String$join,
				'\n\n',
				A2(
					elm$core$List$map,
					A2(
						elm$core$Basics$composeL,
						rtfeldman$elm_css$Css$Structure$Output$indent,
						rtfeldman$elm_css$Css$Structure$Output$prettyPrintStyleBlock(rtfeldman$elm_css$Css$Structure$Output$spaceIndent)),
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
var rtfeldman$elm_css$Css$Structure$Output$prettyPrint = function (_n0) {
	var charset = _n0.charset;
	var imports = _n0.imports;
	var namespaces = _n0.namespaces;
	var declarations = _n0.declarations;
	return A2(
		elm$core$String$join,
		'\n\n',
		A2(
			elm$core$List$filter,
			A2(elm$core$Basics$composeL, elm$core$Basics$not, elm$core$String$isEmpty),
			_List_fromArray(
				[
					rtfeldman$elm_css$Css$Structure$Output$charsetToString(charset),
					A2(
					elm$core$String$join,
					'\n',
					A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$importToString, imports)),
					A2(
					elm$core$String$join,
					'\n',
					A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$namespaceToString, namespaces)),
					A2(
					elm$core$String$join,
					'\n\n',
					A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$prettyPrintDeclaration, declarations))
				])));
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$compileHelp = function (sheet) {
	return rtfeldman$elm_css$Css$Structure$Output$prettyPrint(
		rtfeldman$elm_css$Css$Structure$compactStylesheet(
			rtfeldman$elm_css$Css$Preprocess$Resolve$toStructure(sheet)));
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$compile = function (styles) {
	return A2(
		elm$core$String$join,
		'\n\n',
		A2(elm$core$List$map, rtfeldman$elm_css$Css$Preprocess$Resolve$compileHelp, styles));
};
var rtfeldman$elm_css$Css$Structure$ClassSelector = function (a) {
	return {$: 'ClassSelector', a: a};
};
var rtfeldman$elm_css$Css$Preprocess$Snippet = function (a) {
	return {$: 'Snippet', a: a};
};
var rtfeldman$elm_css$Css$Preprocess$StyleBlock = F3(
	function (a, b, c) {
		return {$: 'StyleBlock', a: a, b: b, c: c};
	});
var rtfeldman$elm_css$Css$Preprocess$StyleBlockDeclaration = function (a) {
	return {$: 'StyleBlockDeclaration', a: a};
};
var rtfeldman$elm_css$VirtualDom$Styled$makeSnippet = F2(
	function (styles, sequence) {
		var selector = A3(rtfeldman$elm_css$Css$Structure$Selector, sequence, _List_Nil, elm$core$Maybe$Nothing);
		return rtfeldman$elm_css$Css$Preprocess$Snippet(
			_List_fromArray(
				[
					rtfeldman$elm_css$Css$Preprocess$StyleBlockDeclaration(
					A3(rtfeldman$elm_css$Css$Preprocess$StyleBlock, selector, _List_Nil, styles))
				]));
	});
var rtfeldman$elm_css$VirtualDom$Styled$snippetFromPair = function (_n0) {
	var classname = _n0.a;
	var styles = _n0.b;
	return A2(
		rtfeldman$elm_css$VirtualDom$Styled$makeSnippet,
		styles,
		rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence(
			_List_fromArray(
				[
					rtfeldman$elm_css$Css$Structure$ClassSelector(classname)
				])));
};
var rtfeldman$elm_css$VirtualDom$Styled$toDeclaration = function (dict) {
	return rtfeldman$elm_css$Css$Preprocess$Resolve$compile(
		elm$core$List$singleton(
			rtfeldman$elm_css$Css$Preprocess$stylesheet(
				A2(
					elm$core$List$map,
					rtfeldman$elm_css$VirtualDom$Styled$snippetFromPair,
					elm$core$Dict$toList(dict)))));
};
var rtfeldman$elm_css$VirtualDom$Styled$toStyleNode = function (styles) {
	return A3(
		elm$virtual_dom$VirtualDom$node,
		'style',
		_List_Nil,
		elm$core$List$singleton(
			elm$virtual_dom$VirtualDom$text(
				rtfeldman$elm_css$VirtualDom$Styled$toDeclaration(styles))));
};
var rtfeldman$elm_css$VirtualDom$Styled$unstyle = F3(
	function (elemType, properties, children) {
		var unstyledProperties = A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _n0 = A3(
			elm$core$List$foldl,
			rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			children);
		var childNodes = _n0.a;
		var styles = _n0.b;
		var styleNode = rtfeldman$elm_css$VirtualDom$Styled$toStyleNode(styles);
		return A3(
			elm$virtual_dom$VirtualDom$node,
			elemType,
			unstyledProperties,
			A2(
				elm$core$List$cons,
				styleNode,
				elm$core$List$reverse(childNodes)));
	});
var rtfeldman$elm_css$VirtualDom$Styled$containsKey = F2(
	function (key, pairs) {
		containsKey:
		while (true) {
			if (!pairs.b) {
				return false;
			} else {
				var _n1 = pairs.a;
				var str = _n1.a;
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
var rtfeldman$elm_css$VirtualDom$Styled$getUnusedKey = F2(
	function (_default, pairs) {
		getUnusedKey:
		while (true) {
			if (!pairs.b) {
				return _default;
			} else {
				var _n1 = pairs.a;
				var firstKey = _n1.a;
				var rest = pairs.b;
				var newKey = '_' + firstKey;
				if (A2(rtfeldman$elm_css$VirtualDom$Styled$containsKey, newKey, rest)) {
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
var rtfeldman$elm_css$VirtualDom$Styled$toKeyedStyleNode = F2(
	function (allStyles, keyedChildNodes) {
		var styleNodeKey = A2(rtfeldman$elm_css$VirtualDom$Styled$getUnusedKey, '_', keyedChildNodes);
		var finalNode = rtfeldman$elm_css$VirtualDom$Styled$toStyleNode(allStyles);
		return _Utils_Tuple2(styleNodeKey, finalNode);
	});
var rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyed = F3(
	function (elemType, properties, keyedChildren) {
		var unstyledProperties = A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _n0 = A3(
			elm$core$List$foldl,
			rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			keyedChildren);
		var keyedChildNodes = _n0.a;
		var styles = _n0.b;
		var keyedStyleNode = A2(rtfeldman$elm_css$VirtualDom$Styled$toKeyedStyleNode, styles, keyedChildNodes);
		return A3(
			elm$virtual_dom$VirtualDom$keyedNode,
			elemType,
			unstyledProperties,
			A2(
				elm$core$List$cons,
				keyedStyleNode,
				elm$core$List$reverse(keyedChildNodes)));
	});
var rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyedNS = F4(
	function (ns, elemType, properties, keyedChildren) {
		var unstyledProperties = A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _n0 = A3(
			elm$core$List$foldl,
			rtfeldman$elm_css$VirtualDom$Styled$accumulateKeyedStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			keyedChildren);
		var keyedChildNodes = _n0.a;
		var styles = _n0.b;
		var keyedStyleNode = A2(rtfeldman$elm_css$VirtualDom$Styled$toKeyedStyleNode, styles, keyedChildNodes);
		return A4(
			elm$virtual_dom$VirtualDom$keyedNodeNS,
			ns,
			elemType,
			unstyledProperties,
			A2(
				elm$core$List$cons,
				keyedStyleNode,
				elm$core$List$reverse(keyedChildNodes)));
	});
var rtfeldman$elm_css$VirtualDom$Styled$unstyleNS = F4(
	function (ns, elemType, properties, children) {
		var unstyledProperties = A2(elm$core$List$map, rtfeldman$elm_css$VirtualDom$Styled$extractUnstyledAttribute, properties);
		var initialStyles = rtfeldman$elm_css$VirtualDom$Styled$stylesFromProperties(properties);
		var _n0 = A3(
			elm$core$List$foldl,
			rtfeldman$elm_css$VirtualDom$Styled$accumulateStyledHtml,
			_Utils_Tuple2(_List_Nil, initialStyles),
			children);
		var childNodes = _n0.a;
		var styles = _n0.b;
		var styleNode = rtfeldman$elm_css$VirtualDom$Styled$toStyleNode(styles);
		return A4(
			elm$virtual_dom$VirtualDom$nodeNS,
			ns,
			elemType,
			unstyledProperties,
			A2(
				elm$core$List$cons,
				styleNode,
				elm$core$List$reverse(childNodes)));
	});
var rtfeldman$elm_css$VirtualDom$Styled$toUnstyled = function (vdom) {
	switch (vdom.$) {
		case 'Unstyled':
			var plainNode = vdom.a;
			return plainNode;
		case 'Node':
			var elemType = vdom.a;
			var properties = vdom.b;
			var children = vdom.c;
			return A3(rtfeldman$elm_css$VirtualDom$Styled$unstyle, elemType, properties, children);
		case 'NodeNS':
			var ns = vdom.a;
			var elemType = vdom.b;
			var properties = vdom.c;
			var children = vdom.d;
			return A4(rtfeldman$elm_css$VirtualDom$Styled$unstyleNS, ns, elemType, properties, children);
		case 'KeyedNode':
			var elemType = vdom.a;
			var properties = vdom.b;
			var children = vdom.c;
			return A3(rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyed, elemType, properties, children);
		default:
			var ns = vdom.a;
			var elemType = vdom.b;
			var properties = vdom.c;
			var children = vdom.d;
			return A4(rtfeldman$elm_css$VirtualDom$Styled$unstyleKeyedNS, ns, elemType, properties, children);
	}
};
var rtfeldman$elm_css$VirtualDom$Styled$lazyHelp = F2(
	function (fn, arg) {
		return rtfeldman$elm_css$VirtualDom$Styled$toUnstyled(
			fn(arg));
	});
var rtfeldman$elm_css$VirtualDom$Styled$lazy = F2(
	function (fn, arg) {
		return rtfeldman$elm_css$VirtualDom$Styled$Unstyled(
			A3(elm$virtual_dom$VirtualDom$lazy2, rtfeldman$elm_css$VirtualDom$Styled$lazyHelp, fn, arg));
	});
var rtfeldman$elm_css$Html$Styled$Lazy$lazy = rtfeldman$elm_css$VirtualDom$Styled$lazy;
var author$project$TaskList$viewControls = F2(
	function (visibilityFilters, tasks) {
		var tasksCompleted = elm$core$List$length(
			A2(elm$core$List$filter, author$project$Task$Task$completed, tasks));
		var tasksLeft = elm$core$List$length(tasks) - tasksCompleted;
		return A2(
			rtfeldman$elm_css$Html$Styled$footer,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Attributes$class('footer'),
					rtfeldman$elm_css$Html$Styled$Attributes$hidden(
					elm$core$List$isEmpty(tasks))
				]),
			_List_fromArray(
				[
					A2(rtfeldman$elm_css$Html$Styled$Lazy$lazy, author$project$TaskList$viewControlsCount, tasksLeft),
					A2(rtfeldman$elm_css$Html$Styled$Lazy$lazy, author$project$TaskList$viewControlsFilters, visibilityFilters),
					A2(rtfeldman$elm_css$Html$Styled$Lazy$lazy, author$project$TaskList$viewControlsClear, tasksCompleted)
				]));
	});
var author$project$TaskList$Add = {$: 'Add'};
var author$project$TaskList$UpdateNewEntryField = function (a) {
	return {$: 'UpdateNewEntryField', a: a};
};
var elm$json$Json$Decode$int = _Json_decodeInt;
var rtfeldman$elm_css$Html$Styled$Events$keyCode = A2(elm$json$Json$Decode$field, 'keyCode', elm$json$Json$Decode$int);
var author$project$TaskList$onEnter = function (msg) {
	var isEnter = function (code) {
		return (code === 13) ? elm$json$Json$Decode$succeed(msg) : elm$json$Json$Decode$fail('not ENTER');
	};
	return A2(
		rtfeldman$elm_css$Html$Styled$Events$on,
		'keydown',
		A2(elm$json$Json$Decode$andThen, isEnter, rtfeldman$elm_css$Html$Styled$Events$keyCode));
};
var rtfeldman$elm_css$Html$Styled$h1 = rtfeldman$elm_css$Html$Styled$node('h1');
var rtfeldman$elm_css$Html$Styled$header = rtfeldman$elm_css$Html$Styled$node('header');
var rtfeldman$elm_css$Html$Styled$input = rtfeldman$elm_css$Html$Styled$node('input');
var rtfeldman$elm_css$Html$Styled$Attributes$autofocus = rtfeldman$elm_css$Html$Styled$Attributes$boolProperty('autofocus');
var rtfeldman$elm_css$Html$Styled$Attributes$name = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('name');
var rtfeldman$elm_css$Html$Styled$Attributes$placeholder = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('placeholder');
var rtfeldman$elm_css$Html$Styled$Attributes$value = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('value');
var rtfeldman$elm_css$Html$Styled$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 'MayStopPropagation', a: a};
};
var rtfeldman$elm_css$Html$Styled$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			rtfeldman$elm_css$VirtualDom$Styled$on,
			event,
			elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3(elm$core$List$foldr, elm$json$Json$Decode$field, decoder, fields);
	});
var rtfeldman$elm_css$Html$Styled$Events$targetValue = A2(
	elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	elm$json$Json$Decode$string);
var rtfeldman$elm_css$Html$Styled$Events$onInput = function (tagger) {
	return A2(
		rtfeldman$elm_css$Html$Styled$Events$stopPropagationOn,
		'input',
		A2(
			elm$json$Json$Decode$map,
			rtfeldman$elm_css$Html$Styled$Events$alwaysStop,
			A2(elm$json$Json$Decode$map, tagger, rtfeldman$elm_css$Html$Styled$Events$targetValue)));
};
var author$project$TaskList$viewInput = function (task) {
	return A2(
		rtfeldman$elm_css$Html$Styled$header,
		_List_fromArray(
			[
				rtfeldman$elm_css$Html$Styled$Attributes$class('header')
			]),
		_List_fromArray(
			[
				A2(
				rtfeldman$elm_css$Html$Styled$h1,
				_List_Nil,
				_List_fromArray(
					[
						rtfeldman$elm_css$Html$Styled$text('docket')
					])),
				A2(
				rtfeldman$elm_css$Html$Styled$input,
				_List_fromArray(
					[
						rtfeldman$elm_css$Html$Styled$Attributes$class('new-task'),
						rtfeldman$elm_css$Html$Styled$Attributes$placeholder('What needs to be done?'),
						rtfeldman$elm_css$Html$Styled$Attributes$autofocus(true),
						rtfeldman$elm_css$Html$Styled$Attributes$value(task),
						rtfeldman$elm_css$Html$Styled$Attributes$name('newTask'),
						rtfeldman$elm_css$Html$Styled$Events$onInput(author$project$TaskList$UpdateNewEntryField),
						author$project$TaskList$onEnter(author$project$TaskList$Add)
					]),
				_List_Nil)
			]));
};
var author$project$Task$Progress$setPortion = F2(
	function (_n0, newpart) {
		var part = _n0.a;
		var unit = _n0.b;
		return _Utils_Tuple2(newpart, unit);
	});
var author$project$TaskList$Delete = function (a) {
	return {$: 'Delete', a: a};
};
var author$project$TaskList$EditingTitle = F2(
	function (a, b) {
		return {$: 'EditingTitle', a: a, b: b};
	});
var author$project$TaskList$FocusSlider = F2(
	function (a, b) {
		return {$: 'FocusSlider', a: a, b: b};
	});
var author$project$TaskList$UpdateProgress = F2(
	function (a, b) {
		return {$: 'UpdateProgress', a: a, b: b};
	});
var author$project$TaskList$UpdateTask = F2(
	function (a, b) {
		return {$: 'UpdateTask', a: a, b: b};
	});
var author$project$TaskList$UpdateTaskDate = F3(
	function (a, b, c) {
		return {$: 'UpdateTaskDate', a: a, b: b, c: c};
	});
var elm$parser$Parser$Advanced$andThen = F2(
	function (callback, _n0) {
		var parseA = _n0.a;
		return elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _n1 = parseA(s0);
				if (_n1.$ === 'Bad') {
					var p = _n1.a;
					var x = _n1.b;
					return A2(elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _n1.a;
					var a = _n1.b;
					var s1 = _n1.c;
					var _n2 = callback(a);
					var parseB = _n2.a;
					var _n3 = parseB(s1);
					if (_n3.$ === 'Bad') {
						var p2 = _n3.a;
						var x = _n3.b;
						return A2(elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _n3.a;
						var b = _n3.b;
						var s2 = _n3.c;
						return A3(elm$parser$Parser$Advanced$Good, p1 || p2, b, s2);
					}
				}
			});
	});
var elm$parser$Parser$andThen = elm$parser$Parser$Advanced$andThen;
var elm$parser$Parser$UnexpectedChar = {$: 'UnexpectedChar'};
var elm$parser$Parser$Advanced$chompIf = F2(
	function (isGood, expecting) {
		return elm$parser$Parser$Advanced$Parser(
			function (s) {
				var newOffset = A3(elm$parser$Parser$Advanced$isSubChar, isGood, s.offset, s.src);
				return _Utils_eq(newOffset, -1) ? A2(
					elm$parser$Parser$Advanced$Bad,
					false,
					A2(elm$parser$Parser$Advanced$fromState, s, expecting)) : (_Utils_eq(newOffset, -2) ? A3(
					elm$parser$Parser$Advanced$Good,
					true,
					_Utils_Tuple0,
					{col: 1, context: s.context, indent: s.indent, offset: s.offset + 1, row: s.row + 1, src: s.src}) : A3(
					elm$parser$Parser$Advanced$Good,
					true,
					_Utils_Tuple0,
					{col: s.col + 1, context: s.context, indent: s.indent, offset: newOffset, row: s.row, src: s.src}));
			});
	});
var elm$parser$Parser$chompIf = function (isGood) {
	return A2(elm$parser$Parser$Advanced$chompIf, isGood, elm$parser$Parser$UnexpectedChar);
};
var elm$parser$Parser$ExpectingEnd = {$: 'ExpectingEnd'};
var elm$parser$Parser$Advanced$end = function (x) {
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			return _Utils_eq(
				elm$core$String$length(s.src),
				s.offset) ? A3(elm$parser$Parser$Advanced$Good, false, _Utils_Tuple0, s) : A2(
				elm$parser$Parser$Advanced$Bad,
				false,
				A2(elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var elm$parser$Parser$end = elm$parser$Parser$Advanced$end(elm$parser$Parser$ExpectingEnd);
var elm$parser$Parser$Advanced$map = F2(
	function (func, _n0) {
		var parse = _n0.a;
		return elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _n1 = parse(s0);
				if (_n1.$ === 'Good') {
					var p = _n1.a;
					var a = _n1.b;
					var s1 = _n1.c;
					return A3(
						elm$parser$Parser$Advanced$Good,
						p,
						func(a),
						s1);
				} else {
					var p = _n1.a;
					var x = _n1.b;
					return A2(elm$parser$Parser$Advanced$Bad, p, x);
				}
			});
	});
var elm$parser$Parser$map = elm$parser$Parser$Advanced$map;
var elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 'Append', a: a, b: b};
	});
var elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2(elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a.a;
				var remainingParsers = parsers.b;
				var _n1 = parse(s0);
				if (_n1.$ === 'Good') {
					var step = _n1;
					return step;
				} else {
					var step = _n1;
					var p = step.a;
					var x = step.b;
					if (p) {
						return step;
					} else {
						var $temp$s0 = s0,
							$temp$bag = A2(elm$parser$Parser$Advanced$Append, bag, x),
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
var elm$parser$Parser$Advanced$oneOf = function (parsers) {
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3(elm$parser$Parser$Advanced$oneOfHelp, s, elm$parser$Parser$Advanced$Empty, parsers);
		});
};
var elm$parser$Parser$oneOf = elm$parser$Parser$Advanced$oneOf;
var justinmimbs$date$Date$deadEndToString = function (_n0) {
	var problem = _n0.problem;
	if (problem.$ === 'Problem') {
		var message = problem.a;
		return message;
	} else {
		return 'Expected a date in ISO 8601 format';
	}
};
var elm$parser$Parser$Advanced$backtrackable = function (_n0) {
	var parse = _n0.a;
	return elm$parser$Parser$Advanced$Parser(
		function (s0) {
			var _n1 = parse(s0);
			if (_n1.$ === 'Bad') {
				var x = _n1.b;
				return A2(elm$parser$Parser$Advanced$Bad, false, x);
			} else {
				var a = _n1.b;
				var s1 = _n1.c;
				return A3(elm$parser$Parser$Advanced$Good, false, a, s1);
			}
		});
};
var elm$parser$Parser$backtrackable = elm$parser$Parser$Advanced$backtrackable;
var elm$parser$Parser$Advanced$commit = function (a) {
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3(elm$parser$Parser$Advanced$Good, true, a, s);
		});
};
var elm$parser$Parser$commit = elm$parser$Parser$Advanced$commit;
var elm$parser$Parser$Expecting = function (a) {
	return {$: 'Expecting', a: a};
};
var elm$parser$Parser$toToken = function (str) {
	return A2(
		elm$parser$Parser$Advanced$Token,
		str,
		elm$parser$Parser$Expecting(str));
};
var elm$parser$Parser$token = function (str) {
	return elm$parser$Parser$Advanced$token(
		elm$parser$Parser$toToken(str));
};
var justinmimbs$date$Date$MonthAndDay = F2(
	function (a, b) {
		return {$: 'MonthAndDay', a: a, b: b};
	});
var justinmimbs$date$Date$OrdinalDay = function (a) {
	return {$: 'OrdinalDay', a: a};
};
var justinmimbs$date$Date$WeekAndWeekday = F2(
	function (a, b) {
		return {$: 'WeekAndWeekday', a: a, b: b};
	});
var elm$parser$Parser$Advanced$mapChompedString = F2(
	function (func, _n0) {
		var parse = _n0.a;
		return elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _n1 = parse(s0);
				if (_n1.$ === 'Bad') {
					var p = _n1.a;
					var x = _n1.b;
					return A2(elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p = _n1.a;
					var a = _n1.b;
					var s1 = _n1.c;
					return A3(
						elm$parser$Parser$Advanced$Good,
						p,
						A2(
							func,
							A3(elm$core$String$slice, s0.offset, s1.offset, s0.src),
							a),
						s1);
				}
			});
	});
var elm$parser$Parser$mapChompedString = elm$parser$Parser$Advanced$mapChompedString;
var justinmimbs$date$Date$int1 = A2(
	elm$parser$Parser$mapChompedString,
	F2(
		function (str, _n0) {
			return A2(
				elm$core$Maybe$withDefault,
				0,
				elm$core$String$toInt(str));
		}),
	elm$parser$Parser$chompIf(elm$core$Char$isDigit));
var justinmimbs$date$Date$int2 = A2(
	elm$parser$Parser$mapChompedString,
	F2(
		function (str, _n0) {
			return A2(
				elm$core$Maybe$withDefault,
				0,
				elm$core$String$toInt(str));
		}),
	A2(
		elm$parser$Parser$ignorer,
		A2(
			elm$parser$Parser$ignorer,
			elm$parser$Parser$succeed(_Utils_Tuple0),
			elm$parser$Parser$chompIf(elm$core$Char$isDigit)),
		elm$parser$Parser$chompIf(elm$core$Char$isDigit)));
var justinmimbs$date$Date$int3 = A2(
	elm$parser$Parser$mapChompedString,
	F2(
		function (str, _n0) {
			return A2(
				elm$core$Maybe$withDefault,
				0,
				elm$core$String$toInt(str));
		}),
	A2(
		elm$parser$Parser$ignorer,
		A2(
			elm$parser$Parser$ignorer,
			A2(
				elm$parser$Parser$ignorer,
				elm$parser$Parser$succeed(_Utils_Tuple0),
				elm$parser$Parser$chompIf(elm$core$Char$isDigit)),
			elm$parser$Parser$chompIf(elm$core$Char$isDigit)),
		elm$parser$Parser$chompIf(elm$core$Char$isDigit)));
var justinmimbs$date$Date$dayOfYear = elm$parser$Parser$oneOf(
	_List_fromArray(
		[
			A2(
			elm$parser$Parser$keeper,
			A2(
				elm$parser$Parser$ignorer,
				elm$parser$Parser$succeed(elm$core$Basics$identity),
				elm$parser$Parser$token('-')),
			elm$parser$Parser$oneOf(
				_List_fromArray(
					[
						elm$parser$Parser$backtrackable(
						A2(
							elm$parser$Parser$andThen,
							elm$parser$Parser$commit,
							A2(elm$parser$Parser$map, justinmimbs$date$Date$OrdinalDay, justinmimbs$date$Date$int3))),
						A2(
						elm$parser$Parser$keeper,
						A2(
							elm$parser$Parser$keeper,
							elm$parser$Parser$succeed(justinmimbs$date$Date$MonthAndDay),
							justinmimbs$date$Date$int2),
						elm$parser$Parser$oneOf(
							_List_fromArray(
								[
									A2(
									elm$parser$Parser$keeper,
									A2(
										elm$parser$Parser$ignorer,
										elm$parser$Parser$succeed(elm$core$Basics$identity),
										elm$parser$Parser$token('-')),
									justinmimbs$date$Date$int2),
									elm$parser$Parser$succeed(1)
								]))),
						A2(
						elm$parser$Parser$keeper,
						A2(
							elm$parser$Parser$keeper,
							A2(
								elm$parser$Parser$ignorer,
								elm$parser$Parser$succeed(justinmimbs$date$Date$WeekAndWeekday),
								elm$parser$Parser$token('W')),
							justinmimbs$date$Date$int2),
						elm$parser$Parser$oneOf(
							_List_fromArray(
								[
									A2(
									elm$parser$Parser$keeper,
									A2(
										elm$parser$Parser$ignorer,
										elm$parser$Parser$succeed(elm$core$Basics$identity),
										elm$parser$Parser$token('-')),
									justinmimbs$date$Date$int1),
									elm$parser$Parser$succeed(1)
								])))
					]))),
			elm$parser$Parser$backtrackable(
			A2(
				elm$parser$Parser$andThen,
				elm$parser$Parser$commit,
				A2(
					elm$parser$Parser$keeper,
					A2(
						elm$parser$Parser$keeper,
						elm$parser$Parser$succeed(justinmimbs$date$Date$MonthAndDay),
						justinmimbs$date$Date$int2),
					elm$parser$Parser$oneOf(
						_List_fromArray(
							[
								justinmimbs$date$Date$int2,
								elm$parser$Parser$succeed(1)
							]))))),
			A2(elm$parser$Parser$map, justinmimbs$date$Date$OrdinalDay, justinmimbs$date$Date$int3),
			A2(
			elm$parser$Parser$keeper,
			A2(
				elm$parser$Parser$keeper,
				A2(
					elm$parser$Parser$ignorer,
					elm$parser$Parser$succeed(justinmimbs$date$Date$WeekAndWeekday),
					elm$parser$Parser$token('W')),
				justinmimbs$date$Date$int2),
			elm$parser$Parser$oneOf(
				_List_fromArray(
					[
						justinmimbs$date$Date$int1,
						elm$parser$Parser$succeed(1)
					]))),
			elm$parser$Parser$succeed(
			justinmimbs$date$Date$OrdinalDay(1))
		]));
var justinmimbs$date$Date$isLeapYear = function (y) {
	return ((!A2(elm$core$Basics$modBy, 4, y)) && A2(elm$core$Basics$modBy, 100, y)) || (!A2(elm$core$Basics$modBy, 400, y));
};
var justinmimbs$date$Date$daysBeforeMonth = F2(
	function (y, m) {
		var leapDays = justinmimbs$date$Date$isLeapYear(y) ? 1 : 0;
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
var justinmimbs$date$Date$floorDiv = F2(
	function (a, b) {
		return elm$core$Basics$floor(a / b);
	});
var justinmimbs$date$Date$daysBeforeYear = function (y1) {
	var y = y1 - 1;
	var leapYears = (A2(justinmimbs$date$Date$floorDiv, y, 4) - A2(justinmimbs$date$Date$floorDiv, y, 100)) + A2(justinmimbs$date$Date$floorDiv, y, 400);
	return (365 * y) + leapYears;
};
var justinmimbs$date$Date$daysInMonth = F2(
	function (y, m) {
		switch (m.$) {
			case 'Jan':
				return 31;
			case 'Feb':
				return justinmimbs$date$Date$isLeapYear(y) ? 29 : 28;
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
var justinmimbs$date$Date$isBetweenInt = F3(
	function (a, b, x) {
		return (_Utils_cmp(a, x) < 1) && (_Utils_cmp(x, b) < 1);
	});
var justinmimbs$date$Date$numberToMonth = function (mn) {
	var _n0 = A2(elm$core$Basics$max, 1, mn);
	switch (_n0) {
		case 1:
			return elm$time$Time$Jan;
		case 2:
			return elm$time$Time$Feb;
		case 3:
			return elm$time$Time$Mar;
		case 4:
			return elm$time$Time$Apr;
		case 5:
			return elm$time$Time$May;
		case 6:
			return elm$time$Time$Jun;
		case 7:
			return elm$time$Time$Jul;
		case 8:
			return elm$time$Time$Aug;
		case 9:
			return elm$time$Time$Sep;
		case 10:
			return elm$time$Time$Oct;
		case 11:
			return elm$time$Time$Nov;
		default:
			return elm$time$Time$Dec;
	}
};
var justinmimbs$date$Date$fromCalendarParts = F3(
	function (y, mn, d) {
		return (A3(justinmimbs$date$Date$isBetweenInt, 1, 12, mn) && A3(
			justinmimbs$date$Date$isBetweenInt,
			1,
			A2(
				justinmimbs$date$Date$daysInMonth,
				y,
				justinmimbs$date$Date$numberToMonth(mn)),
			d)) ? elm$core$Result$Ok(
			justinmimbs$date$Date$RD(
				(justinmimbs$date$Date$daysBeforeYear(y) + A2(
					justinmimbs$date$Date$daysBeforeMonth,
					y,
					justinmimbs$date$Date$numberToMonth(mn))) + d)) : elm$core$Result$Err(
			'Invalid calendar date (' + (elm$core$String$fromInt(y) + (', ' + (elm$core$String$fromInt(mn) + (', ' + (elm$core$String$fromInt(d) + ')'))))));
	});
var justinmimbs$date$Date$fromOrdinalParts = F2(
	function (y, od) {
		return (A3(justinmimbs$date$Date$isBetweenInt, 1, 365, od) || ((od === 366) && justinmimbs$date$Date$isLeapYear(y))) ? elm$core$Result$Ok(
			justinmimbs$date$Date$RD(
				justinmimbs$date$Date$daysBeforeYear(y) + od)) : elm$core$Result$Err(
			'Invalid ordinal date (' + (elm$core$String$fromInt(y) + (', ' + (elm$core$String$fromInt(od) + ')'))));
	});
var justinmimbs$date$Date$weekdayNumber = function (_n0) {
	var rd = _n0.a;
	var _n1 = A2(elm$core$Basics$modBy, 7, rd);
	if (!_n1) {
		return 7;
	} else {
		var n = _n1;
		return n;
	}
};
var justinmimbs$date$Date$daysBeforeWeekYear = function (y) {
	var jan4 = justinmimbs$date$Date$daysBeforeYear(y) + 4;
	return jan4 - justinmimbs$date$Date$weekdayNumber(
		justinmimbs$date$Date$RD(jan4));
};
var justinmimbs$date$Date$firstOfYear = function (y) {
	return justinmimbs$date$Date$RD(
		justinmimbs$date$Date$daysBeforeYear(y) + 1);
};
var justinmimbs$date$Date$is53WeekYear = function (y) {
	var wdnJan1 = justinmimbs$date$Date$weekdayNumber(
		justinmimbs$date$Date$firstOfYear(y));
	return (wdnJan1 === 4) || ((wdnJan1 === 3) && justinmimbs$date$Date$isLeapYear(y));
};
var justinmimbs$date$Date$fromWeekParts = F3(
	function (wy, wn, wdn) {
		return (A3(justinmimbs$date$Date$isBetweenInt, 1, 7, wdn) && (A3(justinmimbs$date$Date$isBetweenInt, 1, 52, wn) || ((wn === 53) && justinmimbs$date$Date$is53WeekYear(wy)))) ? elm$core$Result$Ok(
			justinmimbs$date$Date$RD(
				(justinmimbs$date$Date$daysBeforeWeekYear(wy) + ((wn - 1) * 7)) + wdn)) : elm$core$Result$Err(
			'Invalid week date (' + (elm$core$String$fromInt(wy) + (', ' + (elm$core$String$fromInt(wn) + (', ' + (elm$core$String$fromInt(wdn) + ')'))))));
	});
var justinmimbs$date$Date$fromYearAndDayOfYear = function (_n0) {
	var y = _n0.a;
	var doy = _n0.b;
	switch (doy.$) {
		case 'MonthAndDay':
			var mn = doy.a;
			var d = doy.b;
			return A3(justinmimbs$date$Date$fromCalendarParts, y, mn, d);
		case 'WeekAndWeekday':
			var wn = doy.a;
			var wdn = doy.b;
			return A3(justinmimbs$date$Date$fromWeekParts, y, wn, wdn);
		default:
			var od = doy.a;
			return A2(justinmimbs$date$Date$fromOrdinalParts, y, od);
	}
};
var justinmimbs$date$Date$int4 = A2(
	elm$parser$Parser$mapChompedString,
	F2(
		function (str, _n0) {
			return A2(
				elm$core$Maybe$withDefault,
				0,
				elm$core$String$toInt(str));
		}),
	A2(
		elm$parser$Parser$ignorer,
		A2(
			elm$parser$Parser$ignorer,
			A2(
				elm$parser$Parser$ignorer,
				A2(
					elm$parser$Parser$ignorer,
					A2(
						elm$parser$Parser$ignorer,
						elm$parser$Parser$succeed(_Utils_Tuple0),
						elm$parser$Parser$oneOf(
							_List_fromArray(
								[
									elm$parser$Parser$chompIf(
									function (c) {
										return _Utils_eq(
											c,
											_Utils_chr('-'));
									}),
									elm$parser$Parser$succeed(_Utils_Tuple0)
								]))),
					elm$parser$Parser$chompIf(elm$core$Char$isDigit)),
				elm$parser$Parser$chompIf(elm$core$Char$isDigit)),
			elm$parser$Parser$chompIf(elm$core$Char$isDigit)),
		elm$parser$Parser$chompIf(elm$core$Char$isDigit)));
var elm$parser$Parser$Problem = function (a) {
	return {$: 'Problem', a: a};
};
var elm$parser$Parser$Advanced$problem = function (x) {
	return elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A2(
				elm$parser$Parser$Advanced$Bad,
				false,
				A2(elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var elm$parser$Parser$problem = function (msg) {
	return elm$parser$Parser$Advanced$problem(
		elm$parser$Parser$Problem(msg));
};
var justinmimbs$date$Date$resultToParser = function (result) {
	if (result.$ === 'Ok') {
		var x = result.a;
		return elm$parser$Parser$succeed(x);
	} else {
		var message = result.a;
		return elm$parser$Parser$problem(message);
	}
};
var justinmimbs$date$Date$parser = A2(
	elm$parser$Parser$andThen,
	A2(elm$core$Basics$composeR, justinmimbs$date$Date$fromYearAndDayOfYear, justinmimbs$date$Date$resultToParser),
	A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$keeper,
			elm$parser$Parser$succeed(elm$core$Tuple$pair),
			justinmimbs$date$Date$int4),
		justinmimbs$date$Date$dayOfYear));
var justinmimbs$date$Date$fromIsoString = A2(
	elm$core$Basics$composeR,
	elm$parser$Parser$run(
		A2(
			elm$parser$Parser$keeper,
			elm$parser$Parser$succeed(elm$core$Basics$identity),
			A2(
				elm$parser$Parser$ignorer,
				justinmimbs$date$Date$parser,
				A2(
					elm$parser$Parser$andThen,
					justinmimbs$date$Date$resultToParser,
					elm$parser$Parser$oneOf(
						_List_fromArray(
							[
								A2(elm$parser$Parser$map, elm$core$Result$Ok, elm$parser$Parser$end),
								A2(
								elm$parser$Parser$map,
								elm$core$Basics$always(
									elm$core$Result$Err('Expected a date only, not a date and time')),
								elm$parser$Parser$chompIf(
									elm$core$Basics$eq(
										_Utils_chr('T')))),
								elm$parser$Parser$succeed(
								elm$core$Result$Err('Expected a date only'))
							])))))),
	elm$core$Result$mapError(
		A2(
			elm$core$Basics$composeR,
			elm$core$List$map(justinmimbs$date$Date$deadEndToString),
			elm$core$String$join('; '))));
var author$project$TaskList$extractDate = F3(
	function (task, field, input) {
		var _n0 = justinmimbs$date$Date$fromIsoString(input);
		if (_n0.$ === 'Ok') {
			var date = _n0.a;
			return A3(
				author$project$TaskList$UpdateTaskDate,
				task,
				field,
				author$project$Task$TaskMoment$LocalDate(date));
		} else {
			var msg = _n0.a;
			return author$project$TaskList$NoOp;
		}
	});
var author$project$Task$Progress$getNormalizedPortion = function (_n0) {
	var part = _n0.a;
	var unit = _n0.b;
	return part / author$project$Task$Progress$unitMax(unit);
};
var author$project$Task$Progress$getUnits = function (_n0) {
	var unit = _n0.b;
	return unit;
};
var author$project$Task$Progress$isDiscrete = function (_n0) {
	return false;
};
var elm$core$String$fromFloat = _String_fromNumber;
var rtfeldman$elm_css$Css$Structure$Compatible = {$: 'Compatible'};
var rtfeldman$elm_css$Css$angleConverter = F2(
	function (suffix, angleVal) {
		return {
			angle: rtfeldman$elm_css$Css$Structure$Compatible,
			angleOrDirection: rtfeldman$elm_css$Css$Structure$Compatible,
			value: _Utils_ap(
				elm$core$String$fromFloat(angleVal),
				suffix)
		};
	});
var rtfeldman$elm_css$Css$deg = rtfeldman$elm_css$Css$angleConverter('deg');
var rtfeldman$elm_css$Css$Preprocess$ExtendSelector = F2(
	function (a, b) {
		return {$: 'ExtendSelector', a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$PseudoClassSelector = function (a) {
	return {$: 'PseudoClassSelector', a: a};
};
var rtfeldman$elm_css$Css$pseudoClass = function (_class) {
	return rtfeldman$elm_css$Css$Preprocess$ExtendSelector(
		rtfeldman$elm_css$Css$Structure$PseudoClassSelector(_class));
};
var rtfeldman$elm_css$Css$focus = rtfeldman$elm_css$Css$pseudoClass('focus');
var rtfeldman$elm_css$Css$Preprocess$WithPseudoElement = F2(
	function (a, b) {
		return {$: 'WithPseudoElement', a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$PseudoElement = function (a) {
	return {$: 'PseudoElement', a: a};
};
var rtfeldman$elm_css$Css$pseudoElement = function (element) {
	return rtfeldman$elm_css$Css$Preprocess$WithPseudoElement(
		rtfeldman$elm_css$Css$Structure$PseudoElement(element));
};
var rtfeldman$elm_css$Css$PxUnits = {$: 'PxUnits'};
var rtfeldman$elm_css$Css$Internal$lengthConverter = F3(
	function (units, unitLabel, numericValue) {
		return {
			absoluteLength: rtfeldman$elm_css$Css$Structure$Compatible,
			calc: rtfeldman$elm_css$Css$Structure$Compatible,
			flexBasis: rtfeldman$elm_css$Css$Structure$Compatible,
			fontSize: rtfeldman$elm_css$Css$Structure$Compatible,
			length: rtfeldman$elm_css$Css$Structure$Compatible,
			lengthOrAuto: rtfeldman$elm_css$Css$Structure$Compatible,
			lengthOrAutoOrCoverOrContain: rtfeldman$elm_css$Css$Structure$Compatible,
			lengthOrMinMaxDimension: rtfeldman$elm_css$Css$Structure$Compatible,
			lengthOrNone: rtfeldman$elm_css$Css$Structure$Compatible,
			lengthOrNoneOrMinMaxDimension: rtfeldman$elm_css$Css$Structure$Compatible,
			lengthOrNumber: rtfeldman$elm_css$Css$Structure$Compatible,
			lengthOrNumberOrAutoOrNoneOrContent: rtfeldman$elm_css$Css$Structure$Compatible,
			numericValue: numericValue,
			textIndent: rtfeldman$elm_css$Css$Structure$Compatible,
			unitLabel: unitLabel,
			units: units,
			value: _Utils_ap(
				elm$core$String$fromFloat(numericValue),
				unitLabel)
		};
	});
var rtfeldman$elm_css$Css$px = A2(rtfeldman$elm_css$Css$Internal$lengthConverter, rtfeldman$elm_css$Css$PxUnits, 'px');
var rtfeldman$elm_css$Css$cssFunction = F2(
	function (funcName, args) {
		return funcName + ('(' + (A2(elm$core$String$join, ', ', args) + ')'));
	});
var rtfeldman$elm_css$Css$rotate = function (_n0) {
	var value = _n0.value;
	return {
		transform: rtfeldman$elm_css$Css$Structure$Compatible,
		value: A2(
			rtfeldman$elm_css$Css$cssFunction,
			'rotate',
			_List_fromArray(
				[value]))
	};
};
var rtfeldman$elm_css$Css$Preprocess$AppendProperty = function (a) {
	return {$: 'AppendProperty', a: a};
};
var rtfeldman$elm_css$Css$property = F2(
	function (key, value) {
		return rtfeldman$elm_css$Css$Preprocess$AppendProperty(key + (':' + value));
	});
var rtfeldman$elm_css$Css$prop1 = F2(
	function (key, arg) {
		return A2(rtfeldman$elm_css$Css$property, key, arg.value);
	});
var rtfeldman$elm_css$Css$valuesOrNone = function (list) {
	return elm$core$List$isEmpty(list) ? {value: 'none'} : {
		value: A2(
			elm$core$String$join,
			' ',
			A2(
				elm$core$List$map,
				function ($) {
					return $.value;
				},
				list))
	};
};
var rtfeldman$elm_css$Css$transforms = A2(
	elm$core$Basics$composeL,
	rtfeldman$elm_css$Css$prop1('transform'),
	rtfeldman$elm_css$Css$valuesOrNone);
var rtfeldman$elm_css$Css$translateY = function (_n0) {
	var value = _n0.value;
	return {
		transform: rtfeldman$elm_css$Css$Structure$Compatible,
		value: A2(
			rtfeldman$elm_css$Css$cssFunction,
			'translateY',
			_List_fromArray(
				[value]))
	};
};
var rtfeldman$elm_css$VirtualDom$Styled$murmurSeed = 15739;
var rtfeldman$elm_css$VirtualDom$Styled$getClassname = function (styles) {
	return elm$core$List$isEmpty(styles) ? 'unstyled' : A2(
		elm$core$String$cons,
		_Utils_chr('_'),
		rtfeldman$elm_hex$Hex$toString(
			A2(
				Skinney$murmur3$Murmur3$hashString,
				rtfeldman$elm_css$VirtualDom$Styled$murmurSeed,
				rtfeldman$elm_css$Css$Preprocess$Resolve$compile(
					elm$core$List$singleton(
						rtfeldman$elm_css$Css$Preprocess$stylesheet(
							elm$core$List$singleton(
								A2(
									rtfeldman$elm_css$VirtualDom$Styled$makeSnippet,
									styles,
									rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence(_List_Nil)))))))));
};
var rtfeldman$elm_css$Html$Styled$Internal$css = function (styles) {
	var classname = rtfeldman$elm_css$VirtualDom$Styled$getClassname(styles);
	var classProperty = A2(
		elm$virtual_dom$VirtualDom$property,
		'className',
		elm$json$Json$Encode$string(classname));
	return A3(rtfeldman$elm_css$VirtualDom$Styled$Attribute, classProperty, styles, classname);
};
var rtfeldman$elm_css$Html$Styled$Attributes$css = rtfeldman$elm_css$Html$Styled$Internal$css;
var author$project$TaskList$dynamicSliderThumbCss = function (portion) {
	var _n0 = _Utils_Tuple2(
		portion * (-90),
		elm$core$Basics$abs((portion - 0.5) * 5));
	var angle = _n0.a;
	var offset = _n0.b;
	return rtfeldman$elm_css$Html$Styled$Attributes$css(
		_List_fromArray(
			[
				rtfeldman$elm_css$Css$focus(
				_List_fromArray(
					[
						A2(
						rtfeldman$elm_css$Css$pseudoElement,
						'-moz-range-thumb',
						_List_fromArray(
							[
								rtfeldman$elm_css$Css$transforms(
								_List_fromArray(
									[
										rtfeldman$elm_css$Css$translateY(
										rtfeldman$elm_css$Css$px((-50) + offset)),
										rtfeldman$elm_css$Css$rotate(
										rtfeldman$elm_css$Css$deg(angle))
									]))
							]))
					]))
			]));
};
var author$project$TaskList$extractSliderInput = F2(
	function (task, input) {
		return A2(
			author$project$TaskList$UpdateProgress,
			task.id,
			A2(
				author$project$Task$Progress$setPortion,
				task.completion,
				A2(
					elm$core$Maybe$withDefault,
					0,
					elm$core$String$toInt(input))));
	});
var rtfeldman$elm_css$Html$Styled$Attributes$max = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('max');
var rtfeldman$elm_css$Html$Styled$Attributes$min = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('min');
var rtfeldman$elm_css$Html$Styled$Attributes$step = function (n) {
	return A2(rtfeldman$elm_css$Html$Styled$Attributes$stringProperty, 'step', n);
};
var rtfeldman$elm_css$Html$Styled$Attributes$type_ = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('type');
var rtfeldman$elm_css$Html$Styled$Events$onBlur = function (msg) {
	return A2(
		rtfeldman$elm_css$Html$Styled$Events$on,
		'blur',
		elm$json$Json$Decode$succeed(msg));
};
var rtfeldman$elm_css$Html$Styled$Events$onFocus = function (msg) {
	return A2(
		rtfeldman$elm_css$Html$Styled$Events$on,
		'focus',
		elm$json$Json$Decode$succeed(msg));
};
var author$project$TaskList$progressSlider = function (task) {
	return A2(
		rtfeldman$elm_css$Html$Styled$input,
		_List_fromArray(
			[
				rtfeldman$elm_css$Html$Styled$Attributes$class('task-progress'),
				rtfeldman$elm_css$Html$Styled$Attributes$type_('range'),
				rtfeldman$elm_css$Html$Styled$Attributes$value(
				elm$core$String$fromInt(
					author$project$Task$Progress$getPortion(task.completion))),
				rtfeldman$elm_css$Html$Styled$Attributes$min('0'),
				rtfeldman$elm_css$Html$Styled$Attributes$max(
				elm$core$String$fromInt(
					author$project$Task$Progress$getWhole(task.completion))),
				rtfeldman$elm_css$Html$Styled$Attributes$step(
				author$project$Task$Progress$isDiscrete(
					author$project$Task$Progress$getUnits(task.completion)) ? '1' : 'any'),
				rtfeldman$elm_css$Html$Styled$Events$onInput(
				author$project$TaskList$extractSliderInput(task)),
				rtfeldman$elm_css$Html$Styled$Events$onDoubleClick(
				A2(author$project$TaskList$EditingTitle, task.id, true)),
				rtfeldman$elm_css$Html$Styled$Events$onFocus(
				A2(author$project$TaskList$FocusSlider, task.id, true)),
				rtfeldman$elm_css$Html$Styled$Events$onBlur(
				A2(author$project$TaskList$FocusSlider, task.id, false)),
				author$project$TaskList$dynamicSliderThumbCss(
				author$project$Task$Progress$getNormalizedPortion(task.completion))
			]),
		_List_Nil);
};
var author$project$Task$TaskMoment$userTimeZonePlaceholder = elm$time$Time$utc;
var justinmimbs$date$Date$Days = {$: 'Days'};
var justinmimbs$date$Date$monthToNumber = function (m) {
	switch (m.$) {
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
var justinmimbs$date$Date$toCalendarDateHelp = F3(
	function (y, m, d) {
		toCalendarDateHelp:
		while (true) {
			var monthDays = A2(justinmimbs$date$Date$daysInMonth, y, m);
			var mn = justinmimbs$date$Date$monthToNumber(m);
			if ((mn < 12) && (_Utils_cmp(d, monthDays) > 0)) {
				var $temp$y = y,
					$temp$m = justinmimbs$date$Date$numberToMonth(mn + 1),
					$temp$d = d - monthDays;
				y = $temp$y;
				m = $temp$m;
				d = $temp$d;
				continue toCalendarDateHelp;
			} else {
				return {day: d, month: m, year: y};
			}
		}
	});
var justinmimbs$date$Date$divWithRemainder = F2(
	function (a, b) {
		return _Utils_Tuple2(
			A2(justinmimbs$date$Date$floorDiv, a, b),
			A2(elm$core$Basics$modBy, b, a));
	});
var justinmimbs$date$Date$year = function (_n0) {
	var rd = _n0.a;
	var _n1 = A2(justinmimbs$date$Date$divWithRemainder, rd, 146097);
	var n400 = _n1.a;
	var r400 = _n1.b;
	var _n2 = A2(justinmimbs$date$Date$divWithRemainder, r400, 36524);
	var n100 = _n2.a;
	var r100 = _n2.b;
	var _n3 = A2(justinmimbs$date$Date$divWithRemainder, r100, 1461);
	var n4 = _n3.a;
	var r4 = _n3.b;
	var _n4 = A2(justinmimbs$date$Date$divWithRemainder, r4, 365);
	var n1 = _n4.a;
	var r1 = _n4.b;
	var n = (!r1) ? 0 : 1;
	return ((((n400 * 400) + (n100 * 100)) + (n4 * 4)) + n1) + n;
};
var justinmimbs$date$Date$toOrdinalDate = function (_n0) {
	var rd = _n0.a;
	var y = justinmimbs$date$Date$year(
		justinmimbs$date$Date$RD(rd));
	return {
		ordinalDay: rd - justinmimbs$date$Date$daysBeforeYear(y),
		year: y
	};
};
var justinmimbs$date$Date$toCalendarDate = function (_n0) {
	var rd = _n0.a;
	var date = justinmimbs$date$Date$toOrdinalDate(
		justinmimbs$date$Date$RD(rd));
	return A3(justinmimbs$date$Date$toCalendarDateHelp, date.year, elm$time$Time$Jan, date.ordinalDay);
};
var justinmimbs$date$Date$toMonths = function (rd) {
	var date = justinmimbs$date$Date$toCalendarDate(
		justinmimbs$date$Date$RD(rd));
	var wholeMonths = (12 * (date.year - 1)) + (justinmimbs$date$Date$monthToNumber(date.month) - 1);
	return wholeMonths + (date.day / 100);
};
var justinmimbs$date$Date$diff = F3(
	function (unit, _n0, _n1) {
		var rd1 = _n0.a;
		var rd2 = _n1.a;
		switch (unit.$) {
			case 'Years':
				return (((justinmimbs$date$Date$toMonths(rd2) - justinmimbs$date$Date$toMonths(rd1)) | 0) / 12) | 0;
			case 'Months':
				return (justinmimbs$date$Date$toMonths(rd2) - justinmimbs$date$Date$toMonths(rd1)) | 0;
			case 'Weeks':
				return ((rd2 - rd1) / 7) | 0;
			default:
				return rd2 - rd1;
		}
	});
var elm$core$Basics$clamp = F3(
	function (low, high, number) {
		return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
	});
var justinmimbs$date$Date$fromCalendarDate = F3(
	function (y, m, d) {
		return justinmimbs$date$Date$RD(
			(justinmimbs$date$Date$daysBeforeYear(y) + A2(justinmimbs$date$Date$daysBeforeMonth, y, m)) + A3(
				elm$core$Basics$clamp,
				1,
				A2(justinmimbs$date$Date$daysInMonth, y, m),
				d));
	});
var justinmimbs$date$Date$fromPosix = F2(
	function (zone, posix) {
		return A3(
			justinmimbs$date$Date$fromCalendarDate,
			A2(elm$time$Time$toYear, zone, posix),
			A2(elm$time$Time$toMonth, zone, posix),
			A2(elm$time$Time$toDay, zone, posix));
	});
var justinmimbs$date$Date$toRataDie = function (_n0) {
	var rd = _n0.a;
	return rd;
};
var justinmimbs$time_extra$Time$Extra$dateToMillis = function (date) {
	var daysSinceEpoch = justinmimbs$date$Date$toRataDie(date) - 719163;
	return daysSinceEpoch * 86400000;
};
var justinmimbs$time_extra$Time$Extra$timeFromClock = F4(
	function (hour, minute, second, millisecond) {
		return (((hour * 3600000) + (minute * 60000)) + (second * 1000)) + millisecond;
	});
var justinmimbs$time_extra$Time$Extra$timeFromPosix = F2(
	function (zone, posix) {
		return A4(
			justinmimbs$time_extra$Time$Extra$timeFromClock,
			A2(elm$time$Time$toHour, zone, posix),
			A2(elm$time$Time$toMinute, zone, posix),
			A2(elm$time$Time$toSecond, zone, posix),
			A2(elm$time$Time$toMillis, zone, posix));
	});
var justinmimbs$time_extra$Time$Extra$toOffset = F2(
	function (zone, posix) {
		var millis = elm$time$Time$posixToMillis(posix);
		var localMillis = justinmimbs$time_extra$Time$Extra$dateToMillis(
			A2(justinmimbs$date$Date$fromPosix, zone, posix)) + A2(justinmimbs$time_extra$Time$Extra$timeFromPosix, zone, posix);
		return ((localMillis - millis) / 60000) | 0;
	});
var justinmimbs$time_extra$Time$Extra$posixFromDateTime = F3(
	function (zone, date, time) {
		var millis = justinmimbs$time_extra$Time$Extra$dateToMillis(date) + time;
		var offset0 = A2(
			justinmimbs$time_extra$Time$Extra$toOffset,
			zone,
			elm$time$Time$millisToPosix(millis));
		var posix1 = elm$time$Time$millisToPosix(millis - (offset0 * 60000));
		var offset1 = A2(justinmimbs$time_extra$Time$Extra$toOffset, zone, posix1);
		if (_Utils_eq(offset0, offset1)) {
			return posix1;
		} else {
			var posix2 = elm$time$Time$millisToPosix(millis - (offset1 * 60000));
			var offset2 = A2(justinmimbs$time_extra$Time$Extra$toOffset, zone, posix2);
			return _Utils_eq(offset1, offset2) ? posix2 : posix1;
		}
	});
var justinmimbs$time_extra$Time$Extra$partsToPosix = F2(
	function (zone, _n0) {
		var year = _n0.year;
		var month = _n0.month;
		var day = _n0.day;
		var hour = _n0.hour;
		var minute = _n0.minute;
		var second = _n0.second;
		var millisecond = _n0.millisecond;
		return A3(
			justinmimbs$time_extra$Time$Extra$posixFromDateTime,
			zone,
			A3(justinmimbs$date$Date$fromCalendarDate, year, month, day),
			A4(
				justinmimbs$time_extra$Time$Extra$timeFromClock,
				A3(elm$core$Basics$clamp, 0, 23, hour),
				A3(elm$core$Basics$clamp, 0, 59, minute),
				A3(elm$core$Basics$clamp, 0, 59, second),
				A3(elm$core$Basics$clamp, 0, 999, millisecond)));
	});
var sporto$time_distance$Time$Distance$second = 1000;
var sporto$time_distance$Time$Distance$minute = sporto$time_distance$Time$Distance$second * 60;
var sporto$time_distance$Time$Distance$hour = sporto$time_distance$Time$Distance$minute * 60;
var sporto$time_distance$Time$Distance$day = sporto$time_distance$Time$Distance$hour * 24;
var sporto$time_distance$Time$Distance$month = sporto$time_distance$Time$Distance$day * 30;
var sporto$time_distance$Time$Distance$toS = elm$core$String$fromInt;
var sporto$time_distance$Time$Distance$year = sporto$time_distance$Time$Distance$day * 365;
var sporto$time_distance$Time$Distance$inWords = F2(
	function (posix1, posix2) {
		var time2 = elm$time$Time$posixToMillis(posix2);
		var time1 = elm$time$Time$posixToMillis(posix1);
		var diff = time1 - time2;
		var absDiff = elm$core$Basics$abs(diff);
		var diffInDays = (absDiff / sporto$time_distance$Time$Distance$day) | 0;
		var diffInHours = (absDiff / sporto$time_distance$Time$Distance$hour) | 0;
		var diffInMinutes = (absDiff / sporto$time_distance$Time$Distance$minute) | 0;
		var diffInMonths = (absDiff / sporto$time_distance$Time$Distance$month) | 0;
		var diffInSeconds = (absDiff / sporto$time_distance$Time$Distance$second) | 0;
		var diffInYear = (absDiff / sporto$time_distance$Time$Distance$year) | 0;
		var diffInYearFloat = absDiff / sporto$time_distance$Time$Distance$year;
		if (diffInSeconds < 25) {
			return 'less than ' + (sporto$time_distance$Time$Distance$toS(diffInSeconds) + ' seconds');
		} else {
			if (diffInSeconds < 35) {
				return 'half a minute';
			} else {
				if (diffInSeconds < 60) {
					return 'less than a minute';
				} else {
					if (diffInSeconds < 120) {
						return '1 minute';
					} else {
						if (diffInMinutes < 60) {
							return sporto$time_distance$Time$Distance$toS(diffInMinutes) + ' minutes';
						} else {
							if (diffInMinutes < 91) {
								return 'about 1 hour';
							} else {
								if (diffInMinutes < 120) {
									return 'about 2 hours';
								} else {
									if (diffInHours < 24) {
										return 'about ' + (sporto$time_distance$Time$Distance$toS(diffInHours) + ' hours');
									} else {
										if (diffInHours < 40) {
											return '1 day';
										} else {
											if (diffInDays < 30) {
												return sporto$time_distance$Time$Distance$toS(diffInDays) + ' days';
											} else {
												if (diffInDays < 60) {
													return 'about 1 month';
												} else {
													if (diffInMonths < 12) {
														return 'about ' + (sporto$time_distance$Time$Distance$toS(diffInMonths) + ' months');
													} else {
														if (diffInMonths < 21) {
															return 'about 1 year';
														} else {
															var sinceStartOfYear = absDiff % sporto$time_distance$Time$Distance$year;
															var monthsSinceStartOfYear = (sinceStartOfYear / sporto$time_distance$Time$Distance$month) | 0;
															return (monthsSinceStartOfYear < 3) ? ('about ' + (sporto$time_distance$Time$Distance$toS(diffInYear) + ' years')) : ((monthsSinceStartOfYear < 9) ? ('over ' + (sporto$time_distance$Time$Distance$toS(diffInYear) + ' years')) : ('almost ' + (sporto$time_distance$Time$Distance$toS(diffInYear + 1) + ' years')));
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	});
var author$project$Task$TaskMoment$describeTaskMoment = F2(
	function (now, target) {
		switch (target.$) {
			case 'Unset':
				return '';
			case 'LocalDate':
				var date = target.a;
				return 'in ' + (elm$core$String$fromInt(
					A3(
						justinmimbs$date$Date$diff,
						justinmimbs$date$Date$Days,
						date,
						A2(
							justinmimbs$date$Date$fromPosix,
							author$project$Task$TaskMoment$userTimeZonePlaceholder,
							author$project$SmartTime$Moment$toElmTime(now)))) + ' days');
			case 'Localized':
				var moment = target.a;
				return A2(
					sporto$time_distance$Time$Distance$inWords,
					author$project$SmartTime$Moment$toElmTime(now),
					A2(justinmimbs$time_extra$Time$Extra$partsToPosix, author$project$Task$TaskMoment$userTimeZonePlaceholder, moment));
			default:
				var moment = target.a;
				return A2(
					sporto$time_distance$Time$Distance$inWords,
					author$project$SmartTime$Moment$toElmTime(now),
					author$project$SmartTime$Moment$toElmTime(moment));
		}
	});
var author$project$TaskList$timingInfo = F2(
	function (time, task) {
		return rtfeldman$elm_css$Html$Styled$text(
			A2(author$project$Task$TaskMoment$describeTaskMoment, time, task.deadline));
	});
var rtfeldman$elm_css$Html$Styled$label = rtfeldman$elm_css$Html$Styled$node('label');
var rtfeldman$elm_css$Html$Styled$Attributes$checked = rtfeldman$elm_css$Html$Styled$Attributes$boolProperty('checked');
var rtfeldman$elm_css$Html$Styled$Attributes$for = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('htmlFor');
var rtfeldman$elm_css$Html$Styled$Attributes$id = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('id');
var rtfeldman$elm_css$Html$Styled$Attributes$pattern = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('pattern');
var author$project$TaskList$viewTask = F2(
	function (now, task) {
		return A2(
			rtfeldman$elm_css$Html$Styled$li,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Attributes$class('task-entry'),
					rtfeldman$elm_css$Html$Styled$Attributes$classList(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'completed',
							author$project$Task$Task$completed(task)),
							_Utils_Tuple2('editing', false)
						]))
				]),
			_List_fromArray(
				[
					author$project$TaskList$progressSlider(task),
					A2(
					rtfeldman$elm_css$Html$Styled$div,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('view')
						]),
					_List_fromArray(
						[
							A2(
							rtfeldman$elm_css$Html$Styled$input,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$class('toggle'),
									rtfeldman$elm_css$Html$Styled$Attributes$type_('checkbox'),
									rtfeldman$elm_css$Html$Styled$Attributes$checked(
									author$project$Task$Task$completed(task)),
									rtfeldman$elm_css$Html$Styled$Events$onClick(
									A2(
										author$project$TaskList$UpdateProgress,
										task.id,
										(!author$project$Task$Task$completed(task)) ? author$project$Task$Progress$maximize(task.completion) : A2(author$project$Task$Progress$setPortion, task.completion, 0)))
								]),
							_List_Nil),
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Events$onDoubleClick(
									A2(author$project$TaskList$EditingTitle, task.id, true)),
									rtfeldman$elm_css$Html$Styled$Events$onClick(
									A2(author$project$TaskList$FocusSlider, task.id, true))
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text(task.title)
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$div,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$class('timing-info')
								]),
							_List_fromArray(
								[
									A2(author$project$TaskList$timingInfo, now, task)
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$button,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$class('destroy'),
									rtfeldman$elm_css$Html$Styled$Events$onClick(
									author$project$TaskList$Delete(task.id))
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text('×')
								]))
						])),
					A2(
					rtfeldman$elm_css$Html$Styled$input,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('edit'),
							rtfeldman$elm_css$Html$Styled$Attributes$value(task.title),
							rtfeldman$elm_css$Html$Styled$Attributes$name('title'),
							rtfeldman$elm_css$Html$Styled$Attributes$id(
							'task-' + elm$core$String$fromInt(task.id)),
							rtfeldman$elm_css$Html$Styled$Events$onInput(
							author$project$TaskList$UpdateTask(task.id)),
							rtfeldman$elm_css$Html$Styled$Events$onBlur(
							A2(author$project$TaskList$EditingTitle, task.id, false)),
							author$project$TaskList$onEnter(
							A2(author$project$TaskList$EditingTitle, task.id, false))
						]),
					_List_Nil),
					A2(
					rtfeldman$elm_css$Html$Styled$div,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('task-drawer'),
							rtfeldman$elm_css$Html$Styled$Attributes$hidden(false)
						]),
					_List_fromArray(
						[
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$for('readyDate')
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text('Ready')
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$input,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$type_('date'),
									rtfeldman$elm_css$Html$Styled$Attributes$name('readyDate'),
									rtfeldman$elm_css$Html$Styled$Events$onInput(
									A2(author$project$TaskList$extractDate, task.id, 'Ready')),
									rtfeldman$elm_css$Html$Styled$Attributes$pattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')
								]),
							_List_Nil),
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$for('startDate')
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text('Start')
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$input,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$type_('date'),
									rtfeldman$elm_css$Html$Styled$Attributes$name('startDate'),
									rtfeldman$elm_css$Html$Styled$Events$onInput(
									A2(author$project$TaskList$extractDate, task.id, 'Start')),
									rtfeldman$elm_css$Html$Styled$Attributes$pattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')
								]),
							_List_Nil),
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$for('finishDate')
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text('Finish')
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$input,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$type_('date'),
									rtfeldman$elm_css$Html$Styled$Attributes$name('finishDate'),
									rtfeldman$elm_css$Html$Styled$Events$onInput(
									A2(author$project$TaskList$extractDate, task.id, 'Finish')),
									rtfeldman$elm_css$Html$Styled$Attributes$pattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')
								]),
							_List_Nil),
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$for('deadlineDate')
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text('Deadline')
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$input,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$type_('date'),
									rtfeldman$elm_css$Html$Styled$Attributes$name('deadlineDate'),
									rtfeldman$elm_css$Html$Styled$Events$onInput(
									A2(author$project$TaskList$extractDate, task.id, 'Deadline')),
									rtfeldman$elm_css$Html$Styled$Attributes$pattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')
								]),
							_List_Nil),
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$for('expiresDate')
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text('Expires')
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$input,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$type_('date'),
									rtfeldman$elm_css$Html$Styled$Attributes$name('expiresDate'),
									rtfeldman$elm_css$Html$Styled$Events$onInput(
									A2(author$project$TaskList$extractDate, task.id, 'Expires')),
									rtfeldman$elm_css$Html$Styled$Attributes$pattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')
								]),
							_List_Nil)
						]))
				]));
	});
var rtfeldman$elm_css$VirtualDom$Styled$lazyHelp2 = F3(
	function (fn, arg1, arg2) {
		return rtfeldman$elm_css$VirtualDom$Styled$toUnstyled(
			A2(fn, arg1, arg2));
	});
var rtfeldman$elm_css$VirtualDom$Styled$lazy2 = F3(
	function (fn, arg1, arg2) {
		return rtfeldman$elm_css$VirtualDom$Styled$Unstyled(
			A4(elm$virtual_dom$VirtualDom$lazy3, rtfeldman$elm_css$VirtualDom$Styled$lazyHelp2, fn, arg1, arg2));
	});
var rtfeldman$elm_css$Html$Styled$Lazy$lazy2 = rtfeldman$elm_css$VirtualDom$Styled$lazy2;
var author$project$TaskList$viewKeyedTask = F2(
	function (now, task) {
		return _Utils_Tuple2(
			elm$core$String$fromInt(task.id),
			A3(rtfeldman$elm_css$Html$Styled$Lazy$lazy2, author$project$TaskList$viewTask, now, task));
	});
var rtfeldman$elm_css$Html$Styled$section = rtfeldman$elm_css$Html$Styled$node('section');
var rtfeldman$elm_css$VirtualDom$Styled$KeyedNode = F3(
	function (a, b, c) {
		return {$: 'KeyedNode', a: a, b: b, c: c};
	});
var rtfeldman$elm_css$VirtualDom$Styled$keyedNode = rtfeldman$elm_css$VirtualDom$Styled$KeyedNode;
var rtfeldman$elm_css$Html$Styled$Keyed$node = rtfeldman$elm_css$VirtualDom$Styled$keyedNode;
var rtfeldman$elm_css$Html$Styled$Keyed$ul = rtfeldman$elm_css$Html$Styled$Keyed$node('ul');
var author$project$TaskList$viewTasks = F3(
	function (now, filter, tasks) {
		var isVisible = function (task) {
			switch (filter.$) {
				case 'CompleteTasksOnly':
					return author$project$Task$Task$completed(task);
				case 'IncompleteTasksOnly':
					return !author$project$Task$Task$completed(task);
				default:
					return true;
			}
		};
		var allCompleted = A2(elm$core$List$all, author$project$Task$Task$completed, tasks);
		return A2(
			rtfeldman$elm_css$Html$Styled$section,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Attributes$class('main')
				]),
			_List_fromArray(
				[
					A2(
					rtfeldman$elm_css$Html$Styled$input,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('toggle-all'),
							rtfeldman$elm_css$Html$Styled$Attributes$type_('checkbox'),
							rtfeldman$elm_css$Html$Styled$Attributes$name('toggle'),
							rtfeldman$elm_css$Html$Styled$Attributes$checked(allCompleted)
						]),
					_List_Nil),
					A2(
					rtfeldman$elm_css$Html$Styled$label,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$for('toggle-all')
						]),
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$text('Mark all as complete')
						])),
					A2(
					rtfeldman$elm_css$Html$Styled$Keyed$ul,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('task-list')
						]),
					A2(
						elm$core$List$map,
						author$project$TaskList$viewKeyedTask(now),
						A2(elm$core$List$filter, isVisible, tasks)))
				]));
	});
var rtfeldman$elm_css$Css$hidden = {borderStyle: rtfeldman$elm_css$Css$Structure$Compatible, overflow: rtfeldman$elm_css$Css$Structure$Compatible, value: 'hidden', visibility: rtfeldman$elm_css$Css$Structure$Compatible};
var rtfeldman$elm_css$Css$UnitlessFloat = {$: 'UnitlessFloat'};
var rtfeldman$elm_css$Css$num = function (val) {
	return {
		lengthOrNumber: rtfeldman$elm_css$Css$Structure$Compatible,
		lengthOrNumberOrAutoOrNoneOrContent: rtfeldman$elm_css$Css$Structure$Compatible,
		number: rtfeldman$elm_css$Css$Structure$Compatible,
		numericValue: val,
		unitLabel: '',
		units: rtfeldman$elm_css$Css$UnitlessFloat,
		value: elm$core$String$fromFloat(val)
	};
};
var rtfeldman$elm_css$Css$opacity = rtfeldman$elm_css$Css$prop1('opacity');
var rtfeldman$elm_css$Css$visibility = rtfeldman$elm_css$Css$prop1('visibility');
var elm$virtual_dom$VirtualDom$lazy4 = _VirtualDom_lazy4;
var rtfeldman$elm_css$VirtualDom$Styled$lazyHelp3 = F4(
	function (fn, arg1, arg2, arg3) {
		return rtfeldman$elm_css$VirtualDom$Styled$toUnstyled(
			A3(fn, arg1, arg2, arg3));
	});
var rtfeldman$elm_css$VirtualDom$Styled$lazy3 = F4(
	function (fn, arg1, arg2, arg3) {
		return rtfeldman$elm_css$VirtualDom$Styled$Unstyled(
			A5(elm$virtual_dom$VirtualDom$lazy4, rtfeldman$elm_css$VirtualDom$Styled$lazyHelp3, fn, arg1, arg2, arg3));
	});
var rtfeldman$elm_css$Html$Styled$Lazy$lazy3 = rtfeldman$elm_css$VirtualDom$Styled$lazy3;
var author$project$TaskList$view = F3(
	function (state, app, env) {
		var filters = state.a;
		var expanded = state.b;
		var field = state.c;
		return A2(
			rtfeldman$elm_css$Html$Styled$div,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Attributes$class('todomvc-wrapper'),
					rtfeldman$elm_css$Html$Styled$Attributes$css(
					_List_fromArray(
						[
							rtfeldman$elm_css$Css$visibility(rtfeldman$elm_css$Css$hidden)
						]))
				]),
			_List_fromArray(
				[
					A2(
					rtfeldman$elm_css$Html$Styled$section,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('todoapp')
						]),
					_List_fromArray(
						[
							A2(rtfeldman$elm_css$Html$Styled$Lazy$lazy, author$project$TaskList$viewInput, field),
							A4(
							rtfeldman$elm_css$Html$Styled$Lazy$lazy3,
							author$project$TaskList$viewTasks,
							env.time,
							A2(
								elm$core$Maybe$withDefault,
								author$project$TaskList$AllTasks,
								elm$core$List$head(filters)),
							author$project$Task$Task$prioritize(
								elm_community$intdict$IntDict$values(app.tasks))),
							A3(
							rtfeldman$elm_css$Html$Styled$Lazy$lazy2,
							author$project$TaskList$viewControls,
							filters,
							elm_community$intdict$IntDict$values(app.tasks))
						])),
					A2(
					rtfeldman$elm_css$Html$Styled$section,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$css(
							_List_fromArray(
								[
									rtfeldman$elm_css$Css$opacity(
									rtfeldman$elm_css$Css$num(0.1))
								]))
						]),
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$text('Everything working well? Good.')
						]))
				]));
	});
var author$project$Activity$Activity$showing = function (activity) {
	return !activity.hidden;
};
var author$project$IntDictExtra$filterValues = F2(
	function (func, dict) {
		return A2(
			elm_community$intdict$IntDict$filter,
			F2(
				function (_n0, v) {
					return func(v);
				}),
			dict);
	});
var author$project$Activity$Measure$inHoursMinutes = function (duration) {
	var hour = 3600000;
	var durationInMs = author$project$SmartTime$Duration$inMs(duration);
	var wholeHours = (durationInMs / hour) | 0;
	var hoursString = elm$core$String$fromInt(wholeHours) + 'h';
	var wholeMinutes = ((durationInMs - (wholeHours * hour)) / 60000) | 0;
	var minutesString = elm$core$String$fromInt(wholeMinutes) + 'm';
	var _n0 = _Utils_Tuple2(wholeHours, wholeMinutes);
	if (!_n0.a) {
		if (!_n0.b) {
			return minutesString;
		} else {
			return minutesString;
		}
	} else {
		if (!_n0.b) {
			return hoursString;
		} else {
			return hoursString + (' ' + minutesString);
		}
	}
};
var rtfeldman$elm_css$Css$Internal$property = F2(
	function (key, value) {
		return rtfeldman$elm_css$Css$Preprocess$AppendProperty(key + (':' + value));
	});
var rtfeldman$elm_css$Css$Preprocess$ApplyStyles = function (a) {
	return {$: 'ApplyStyles', a: a};
};
var rtfeldman$elm_css$Css$Internal$getOverloadedProperty = F3(
	function (functionName, desiredKey, style) {
		getOverloadedProperty:
		while (true) {
			switch (style.$) {
				case 'AppendProperty':
					var str = style.a;
					var key = A2(
						elm$core$Maybe$withDefault,
						'',
						elm$core$List$head(
							A2(elm$core$String$split, ':', str)));
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, key);
				case 'ExtendSelector':
					var selector = style.a;
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-selector'));
				case 'NestSnippet':
					var combinator = style.a;
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-combinator'));
				case 'WithPseudoElement':
					var pseudoElement = style.a;
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-pseudo-element setter'));
				case 'WithMedia':
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-media-query'));
				case 'WithKeyframes':
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-keyframes'));
				default:
					if (!style.a.b) {
						return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-empty-Style'));
					} else {
						if (!style.a.b.b) {
							var _n1 = style.a;
							var only = _n1.a;
							var $temp$functionName = functionName,
								$temp$desiredKey = desiredKey,
								$temp$style = only;
							functionName = $temp$functionName;
							desiredKey = $temp$desiredKey;
							style = $temp$style;
							continue getOverloadedProperty;
						} else {
							var _n2 = style.a;
							var first = _n2.a;
							var rest = _n2.b;
							var $temp$functionName = functionName,
								$temp$desiredKey = desiredKey,
								$temp$style = rtfeldman$elm_css$Css$Preprocess$ApplyStyles(rest);
							functionName = $temp$functionName;
							desiredKey = $temp$desiredKey;
							style = $temp$style;
							continue getOverloadedProperty;
						}
					}
			}
		}
	});
var rtfeldman$elm_css$Css$Internal$IncompatibleUnits = {$: 'IncompatibleUnits'};
var rtfeldman$elm_css$Css$Internal$lengthForOverloadedProperty = A3(rtfeldman$elm_css$Css$Internal$lengthConverter, rtfeldman$elm_css$Css$Internal$IncompatibleUnits, '', 0);
var rtfeldman$elm_css$Css$float = function (fn) {
	return A3(
		rtfeldman$elm_css$Css$Internal$getOverloadedProperty,
		'float',
		'float',
		fn(rtfeldman$elm_css$Css$Internal$lengthForOverloadedProperty));
};
var rtfeldman$elm_css$Css$left = rtfeldman$elm_css$Css$prop1('left');
var rtfeldman$elm_css$Html$Styled$img = rtfeldman$elm_css$Html$Styled$node('img');
var rtfeldman$elm_css$Html$Styled$Attributes$src = function (url) {
	return A2(rtfeldman$elm_css$Html$Styled$Attributes$stringProperty, 'src', url);
};
var author$project$TimeTracker$viewIcon = function (icon) {
	switch (icon.$) {
		case 'File':
			var svgPath = icon.a;
			return A2(
				rtfeldman$elm_css$Html$Styled$img,
				_List_fromArray(
					[
						rtfeldman$elm_css$Html$Styled$Attributes$class('activity-icon'),
						rtfeldman$elm_css$Html$Styled$Attributes$src('media/icons/' + svgPath),
						rtfeldman$elm_css$Html$Styled$Attributes$css(
						_List_fromArray(
							[
								rtfeldman$elm_css$Css$float(rtfeldman$elm_css$Css$left)
							]))
					]),
				_List_Nil);
		case 'Ion':
			return rtfeldman$elm_css$Html$Styled$text('');
		default:
			return rtfeldman$elm_css$Html$Styled$text('');
	}
};
var justinmimbs$time_extra$Time$Extra$Day = {$: 'Day'};
var justinmimbs$date$Date$Day = {$: 'Day'};
var justinmimbs$date$Date$Friday = {$: 'Friday'};
var justinmimbs$date$Date$Monday = {$: 'Monday'};
var justinmimbs$date$Date$Month = {$: 'Month'};
var justinmimbs$date$Date$Quarter = {$: 'Quarter'};
var justinmimbs$date$Date$Saturday = {$: 'Saturday'};
var justinmimbs$date$Date$Sunday = {$: 'Sunday'};
var justinmimbs$date$Date$Thursday = {$: 'Thursday'};
var justinmimbs$date$Date$Tuesday = {$: 'Tuesday'};
var justinmimbs$date$Date$Wednesday = {$: 'Wednesday'};
var justinmimbs$date$Date$Week = {$: 'Week'};
var justinmimbs$date$Date$Year = {$: 'Year'};
var elm$time$Time$Fri = {$: 'Fri'};
var elm$time$Time$Mon = {$: 'Mon'};
var elm$time$Time$Sat = {$: 'Sat'};
var elm$time$Time$Sun = {$: 'Sun'};
var elm$time$Time$Thu = {$: 'Thu'};
var elm$time$Time$Tue = {$: 'Tue'};
var elm$time$Time$Wed = {$: 'Wed'};
var justinmimbs$date$Date$weekdayToNumber = function (wd) {
	switch (wd.$) {
		case 'Mon':
			return 1;
		case 'Tue':
			return 2;
		case 'Wed':
			return 3;
		case 'Thu':
			return 4;
		case 'Fri':
			return 5;
		case 'Sat':
			return 6;
		default:
			return 7;
	}
};
var justinmimbs$date$Date$daysSincePreviousWeekday = F2(
	function (wd, date) {
		return A2(
			elm$core$Basics$modBy,
			7,
			(justinmimbs$date$Date$weekdayNumber(date) + 7) - justinmimbs$date$Date$weekdayToNumber(wd));
	});
var justinmimbs$date$Date$firstOfMonth = F2(
	function (y, m) {
		return justinmimbs$date$Date$RD(
			(justinmimbs$date$Date$daysBeforeYear(y) + A2(justinmimbs$date$Date$daysBeforeMonth, y, m)) + 1);
	});
var justinmimbs$date$Date$month = A2(
	elm$core$Basics$composeR,
	justinmimbs$date$Date$toCalendarDate,
	function ($) {
		return $.month;
	});
var justinmimbs$date$Date$monthToQuarter = function (m) {
	return ((justinmimbs$date$Date$monthToNumber(m) + 2) / 3) | 0;
};
var justinmimbs$date$Date$quarter = A2(elm$core$Basics$composeR, justinmimbs$date$Date$month, justinmimbs$date$Date$monthToQuarter);
var justinmimbs$date$Date$quarterToMonth = function (q) {
	return justinmimbs$date$Date$numberToMonth((q * 3) - 2);
};
var justinmimbs$date$Date$floor = F2(
	function (interval, date) {
		var rd = date.a;
		switch (interval.$) {
			case 'Year':
				return justinmimbs$date$Date$firstOfYear(
					justinmimbs$date$Date$year(date));
			case 'Quarter':
				return A2(
					justinmimbs$date$Date$firstOfMonth,
					justinmimbs$date$Date$year(date),
					justinmimbs$date$Date$quarterToMonth(
						justinmimbs$date$Date$quarter(date)));
			case 'Month':
				return A2(
					justinmimbs$date$Date$firstOfMonth,
					justinmimbs$date$Date$year(date),
					justinmimbs$date$Date$month(date));
			case 'Week':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Mon, date));
			case 'Monday':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Mon, date));
			case 'Tuesday':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Tue, date));
			case 'Wednesday':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Wed, date));
			case 'Thursday':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Thu, date));
			case 'Friday':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Fri, date));
			case 'Saturday':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Sat, date));
			case 'Sunday':
				return justinmimbs$date$Date$RD(
					rd - A2(justinmimbs$date$Date$daysSincePreviousWeekday, elm$time$Time$Sun, date));
			default:
				return date;
		}
	});
var justinmimbs$time_extra$Time$Extra$floorDate = F3(
	function (dateInterval, zone, posix) {
		return A3(
			justinmimbs$time_extra$Time$Extra$posixFromDateTime,
			zone,
			A2(
				justinmimbs$date$Date$floor,
				dateInterval,
				A2(justinmimbs$date$Date$fromPosix, zone, posix)),
			0);
	});
var justinmimbs$time_extra$Time$Extra$floor = F3(
	function (interval, zone, posix) {
		switch (interval.$) {
			case 'Millisecond':
				return posix;
			case 'Second':
				return A3(
					justinmimbs$time_extra$Time$Extra$posixFromDateTime,
					zone,
					A2(justinmimbs$date$Date$fromPosix, zone, posix),
					A4(
						justinmimbs$time_extra$Time$Extra$timeFromClock,
						A2(elm$time$Time$toHour, zone, posix),
						A2(elm$time$Time$toMinute, zone, posix),
						A2(elm$time$Time$toSecond, zone, posix),
						0));
			case 'Minute':
				return A3(
					justinmimbs$time_extra$Time$Extra$posixFromDateTime,
					zone,
					A2(justinmimbs$date$Date$fromPosix, zone, posix),
					A4(
						justinmimbs$time_extra$Time$Extra$timeFromClock,
						A2(elm$time$Time$toHour, zone, posix),
						A2(elm$time$Time$toMinute, zone, posix),
						0,
						0));
			case 'Hour':
				return A3(
					justinmimbs$time_extra$Time$Extra$posixFromDateTime,
					zone,
					A2(justinmimbs$date$Date$fromPosix, zone, posix),
					A4(
						justinmimbs$time_extra$Time$Extra$timeFromClock,
						A2(elm$time$Time$toHour, zone, posix),
						0,
						0,
						0));
			case 'Day':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Day, zone, posix);
			case 'Month':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Month, zone, posix);
			case 'Year':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Year, zone, posix);
			case 'Quarter':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Quarter, zone, posix);
			case 'Week':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Week, zone, posix);
			case 'Monday':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Monday, zone, posix);
			case 'Tuesday':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Tuesday, zone, posix);
			case 'Wednesday':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Wednesday, zone, posix);
			case 'Thursday':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Thursday, zone, posix);
			case 'Friday':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Friday, zone, posix);
			case 'Saturday':
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Saturday, zone, posix);
			default:
				return A3(justinmimbs$time_extra$Time$Extra$floorDate, justinmimbs$date$Date$Sunday, zone, posix);
		}
	});
var author$project$Activity$Measure$justToday = F2(
	function (timeline, _n0) {
		var now = _n0.a;
		var zone = _n0.b;
		var lastMidnight = author$project$SmartTime$Moment$fromElmTime(
			A3(
				justinmimbs$time_extra$Time$Extra$floor,
				justinmimbs$time_extra$Time$Extra$Day,
				zone,
				author$project$SmartTime$Moment$toElmTime(now)));
		return A3(author$project$Activity$Measure$timelineLimit, timeline, now, lastMidnight);
	});
var author$project$Activity$Measure$justTodayTotal = F3(
	function (timeline, env, activityID) {
		var lastPeriod = A2(
			author$project$Activity$Measure$justToday,
			timeline,
			_Utils_Tuple2(env.time, env.timeZone));
		return A3(author$project$Activity$Measure$totalLive, env.time, lastPeriod, activityID);
	});
var author$project$TimeTracker$writeActivityToday = F3(
	function (app, env, activityID) {
		return author$project$Activity$Measure$inHoursMinutes(
			A3(author$project$Activity$Measure$justTodayTotal, app.timeline, env, activityID));
	});
var author$project$TimeTracker$writeActivityUsage = F3(
	function (app, env, _n0) {
		var activityID = _n0.a;
		var activity = _n0.b;
		var period = activity.maxTime.b;
		var lastPeriod = A3(author$project$Activity$Measure$relevantTimeline, app.timeline, env.time, period);
		var total = A3(author$project$Activity$Measure$totalLive, env.time, lastPeriod, activityID);
		var totalMinutes = author$project$SmartTime$Duration$inMinutesRounded(total);
		return (author$project$SmartTime$Duration$inMs(total) > 0) ? (elm$core$String$fromInt(totalMinutes) + ('/' + (elm$core$String$fromInt(
			author$project$SmartTime$Duration$inMinutesRounded(
				author$project$SmartTime$Human$Duration$toDuration(period))) + 'm'))) : '';
	});
var rtfeldman$elm_css$Html$Styled$Attributes$title = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('title');
var author$project$TimeTracker$viewActivity = F3(
	function (app, env, _n0) {
		var activityID = _n0.a;
		var activity = _n0.b;
		var describeSession = function (sesh) {
			return author$project$Activity$Measure$inHoursMinutes(sesh) + '\n';
		};
		return A2(
			rtfeldman$elm_css$Html$Styled$li,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Attributes$class('activity')
				]),
			_List_fromArray(
				[
					A2(
					rtfeldman$elm_css$Html$Styled$button,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('activity-button'),
							rtfeldman$elm_css$Html$Styled$Attributes$classList(
							_List_fromArray(
								[
									_Utils_Tuple2(
									'current',
									_Utils_eq(
										author$project$Activity$Switching$currentActivityFromApp(app),
										activityID))
								])),
							rtfeldman$elm_css$Html$Styled$Events$onClick(
							author$project$TimeTracker$StartTracking(activityID)),
							rtfeldman$elm_css$Html$Styled$Attributes$title(
							A3(
								elm$core$List$foldl,
								elm$core$Basics$append,
								'',
								A2(
									elm$core$List$map,
									describeSession,
									A2(author$project$Activity$Measure$sessions, app.timeline, activityID))))
						]),
					_List_fromArray(
						[
							author$project$TimeTracker$viewIcon(activity.icon),
							A2(
							rtfeldman$elm_css$Html$Styled$div,
							_List_Nil,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text(
									A3(
										author$project$TimeTracker$writeActivityUsage,
										app,
										env,
										_Utils_Tuple2(activityID, activity)))
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$div,
							_List_Nil,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text(
									A3(author$project$TimeTracker$writeActivityToday, app, env, activityID))
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_Nil,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text(
									author$project$Activity$Activity$getName(activity))
								]))
						]))
				]));
	});
var author$project$TimeTracker$viewActivities = F2(
	function (env, app) {
		return A2(
			rtfeldman$elm_css$Html$Styled$section,
			_List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$Attributes$class('main')
				]),
			_List_fromArray(
				[
					A2(
					rtfeldman$elm_css$Html$Styled$ul,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('activity-list')
						]),
					elm_community$intdict$IntDict$values(
						A2(
							elm_community$intdict$IntDict$map,
							F2(
								function (k, v) {
									return A3(
										author$project$TimeTracker$viewActivity,
										app,
										env,
										_Utils_Tuple2(
											author$project$ID$tag(k),
											v));
								}),
							A2(
								author$project$IntDictExtra$filterValues,
								author$project$Activity$Activity$showing,
								author$project$Activity$Activity$allActivities(app.activities)))))
				]));
	});
var author$project$TimeTracker$view = F3(
	function (state, app, env) {
		return A2(
			rtfeldman$elm_css$Html$Styled$div,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					rtfeldman$elm_css$Html$Styled$section,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$class('activity-screen')
						]),
					_List_fromArray(
						[
							A3(rtfeldman$elm_css$Html$Styled$Lazy$lazy2, author$project$TimeTracker$viewActivities, env, app)
						])),
					A2(
					rtfeldman$elm_css$Html$Styled$section,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$css(
							_List_fromArray(
								[
									rtfeldman$elm_css$Css$opacity(
									rtfeldman$elm_css$Css$num(0.1))
								]))
						]),
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$text('Quite Ambitious.')
						]))
				]));
	});
var rtfeldman$elm_css$VirtualDom$Styled$KeyedNodeNS = F4(
	function (a, b, c, d) {
		return {$: 'KeyedNodeNS', a: a, b: b, c: c, d: d};
	});
var rtfeldman$elm_css$VirtualDom$Styled$NodeNS = F4(
	function (a, b, c, d) {
		return {$: 'NodeNS', a: a, b: b, c: c, d: d};
	});
var elm$virtual_dom$VirtualDom$mapAttribute = _VirtualDom_mapAttribute;
var rtfeldman$elm_css$VirtualDom$Styled$mapAttribute = F2(
	function (transform, _n0) {
		var prop = _n0.a;
		var styles = _n0.b;
		var classname = _n0.c;
		return A3(
			rtfeldman$elm_css$VirtualDom$Styled$Attribute,
			A2(elm$virtual_dom$VirtualDom$mapAttribute, transform, prop),
			styles,
			classname);
	});
var rtfeldman$elm_css$VirtualDom$Styled$map = F2(
	function (transform, vdomNode) {
		switch (vdomNode.$) {
			case 'Node':
				var elemType = vdomNode.a;
				var properties = vdomNode.b;
				var children = vdomNode.c;
				return A3(
					rtfeldman$elm_css$VirtualDom$Styled$Node,
					elemType,
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$VirtualDom$Styled$mapAttribute(transform),
						properties),
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$VirtualDom$Styled$map(transform),
						children));
			case 'NodeNS':
				var ns = vdomNode.a;
				var elemType = vdomNode.b;
				var properties = vdomNode.c;
				var children = vdomNode.d;
				return A4(
					rtfeldman$elm_css$VirtualDom$Styled$NodeNS,
					ns,
					elemType,
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$VirtualDom$Styled$mapAttribute(transform),
						properties),
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$VirtualDom$Styled$map(transform),
						children));
			case 'KeyedNode':
				var elemType = vdomNode.a;
				var properties = vdomNode.b;
				var children = vdomNode.c;
				return A3(
					rtfeldman$elm_css$VirtualDom$Styled$KeyedNode,
					elemType,
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$VirtualDom$Styled$mapAttribute(transform),
						properties),
					A2(
						elm$core$List$map,
						function (_n1) {
							var key = _n1.a;
							var child = _n1.b;
							return _Utils_Tuple2(
								key,
								A2(rtfeldman$elm_css$VirtualDom$Styled$map, transform, child));
						},
						children));
			case 'KeyedNodeNS':
				var ns = vdomNode.a;
				var elemType = vdomNode.b;
				var properties = vdomNode.c;
				var children = vdomNode.d;
				return A4(
					rtfeldman$elm_css$VirtualDom$Styled$KeyedNodeNS,
					ns,
					elemType,
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$VirtualDom$Styled$mapAttribute(transform),
						properties),
					A2(
						elm$core$List$map,
						function (_n2) {
							var key = _n2.a;
							var child = _n2.b;
							return _Utils_Tuple2(
								key,
								A2(rtfeldman$elm_css$VirtualDom$Styled$map, transform, child));
						},
						children));
			default:
				var vdom = vdomNode.a;
				return rtfeldman$elm_css$VirtualDom$Styled$Unstyled(
					A2(elm$virtual_dom$VirtualDom$map, transform, vdom));
		}
	});
var rtfeldman$elm_css$Html$Styled$map = rtfeldman$elm_css$VirtualDom$Styled$map;
var rtfeldman$elm_css$Html$Styled$toUnstyled = rtfeldman$elm_css$VirtualDom$Styled$toUnstyled;
var author$project$Main$view = function (_n0) {
	var viewState = _n0.viewState;
	var appData = _n0.appData;
	var environment = _n0.environment;
	if (_Utils_eq(environment.time, author$project$SmartTime$Moment$zero)) {
		return {
			body: _List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$toUnstyled(
					A2(
						rtfeldman$elm_css$Html$Styled$map,
						function (_n1) {
							return author$project$Main$NoOp;
						},
						rtfeldman$elm_css$Html$Styled$text('Loading')))
				]),
			title: 'Loading...'
		};
	} else {
		var _n2 = viewState.primaryView;
		switch (_n2.$) {
			case 'TaskList':
				var subState = _n2.a;
				return {
					body: A2(
						elm$core$List$map,
						rtfeldman$elm_css$Html$Styled$toUnstyled,
						_List_fromArray(
							[
								A2(
								rtfeldman$elm_css$Html$Styled$map,
								author$project$Main$TaskListMsg,
								A3(author$project$TaskList$view, subState, appData, environment)),
								author$project$Main$infoFooter,
								author$project$Main$errorList(appData.errors)
							])),
					title: 'Docket - Task List'
				};
			case 'TimeTracker':
				var subState = _n2.a;
				return {
					body: A2(
						elm$core$List$map,
						rtfeldman$elm_css$Html$Styled$toUnstyled,
						_List_fromArray(
							[
								A2(
								rtfeldman$elm_css$Html$Styled$map,
								author$project$Main$TimeTrackerMsg,
								A3(author$project$TimeTracker$view, subState, appData, environment)),
								author$project$Main$infoFooter,
								author$project$Main$errorList(appData.errors)
							])),
					title: 'Docket Time Tracker'
				};
			default:
				return {
					body: A2(
						elm$core$List$map,
						rtfeldman$elm_css$Html$Styled$toUnstyled,
						_List_fromArray(
							[author$project$Main$infoFooter])),
					title: 'TODO Some other page'
				};
		}
	}
};
var elm$browser$Browser$application = _Browser_application;
var author$project$Main$main = elm$browser$Browser$application(
	{init: author$project$Main$initGraphical, onUrlChange: author$project$Main$NewUrl, onUrlRequest: author$project$Main$Link, subscriptions: author$project$Main$subscriptions, update: author$project$Main$updateWithTime, view: author$project$Main$view});
var author$project$Headless$headlessMsg = _Platform_incomingPort('headlessMsg', elm$json$Json$Decode$string);
var author$project$Headless$fallbackUrl = {fragment: elm$core$Maybe$Nothing, host: 'headless.docket.com', path: '', port_: elm$core$Maybe$Nothing, protocol: elm$url$Url$Http, query: elm$core$Maybe$Nothing};
var author$project$Headless$urlOrElse = function (urlAsString) {
	return A2(
		elm$core$Maybe$withDefault,
		author$project$Headless$fallbackUrl,
		elm$url$Url$fromString(urlAsString));
};
var author$project$Headless$headlessSubscriptions = function (model) {
	var appData = model.appData;
	var environment = model.environment;
	return elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				author$project$Headless$headlessMsg(
				function (s) {
					return author$project$Main$NewUrl(
						author$project$Headless$urlOrElse(s));
				})
			]));
};
var author$project$Headless$initHeadless = function (_n0) {
	var urlAsString = _n0.a;
	var maybeJson = _n0.b;
	return A3(
		author$project$Main$init,
		maybeJson,
		author$project$Headless$urlOrElse(urlAsString),
		elm$core$Maybe$Nothing);
};
var elm$core$Platform$worker = _Platform_worker;
var elm$json$Json$Decode$index = _Json_decodeIndex;
var author$project$Headless$main = elm$core$Platform$worker(
	{init: author$project$Headless$initHeadless, subscriptions: author$project$Headless$headlessSubscriptions, update: author$project$Main$updateWithTime});
_Platform_export({'Headless':{'init':author$project$Headless$main(
	A2(
		elm$json$Json$Decode$andThen,
		function (x0) {
			return A2(
				elm$json$Json$Decode$andThen,
				function (x1) {
					return elm$json$Json$Decode$succeed(
						_Utils_Tuple2(x0, x1));
				},
				A2(
					elm$json$Json$Decode$index,
					1,
					elm$json$Json$Decode$oneOf(
						_List_fromArray(
							[
								elm$json$Json$Decode$null(elm$core$Maybe$Nothing),
								A2(elm$json$Json$Decode$map, elm$core$Maybe$Just, elm$json$Json$Decode$string)
							]))));
		},
		A2(elm$json$Json$Decode$index, 0, elm$json$Json$Decode$string)))({"versions":{"elm":"0.19.0"},"types":{"message":"Main.Msg","aliases":{"SmartTime.Human.Moment.Zone":{"args":[],"type":"Time.Zone"},"Url.Url":{"args":[],"type":"{ protocol : Url.Protocol, host : String.String, port_ : Maybe.Maybe Basics.Int, path : String.String, query : Maybe.Maybe String.String, fragment : Maybe.Maybe String.String }"},"Activity.Activity.Activity":{"args":[],"type":"{ names : List.List String.String, icon : Activity.Activity.Icon, excusable : Activity.Activity.Excusable, taskOptional : Basics.Bool, evidence : List.List Activity.Activity.Evidence, category : Activity.Activity.Category, backgroundable : Basics.Bool, maxTime : Activity.Activity.DurationPerPeriod, hidden : Basics.Bool, template : Activity.Template.Template }"},"Activity.Activity.ActivityID":{"args":[],"type":"ID.ID Activity.Activity.Activity"},"Activity.Activity.DurationPerPeriod":{"args":[],"type":"( SmartTime.Human.Duration.HumanDuration, SmartTime.Human.Duration.HumanDuration )"},"External.TodoistSync.Due":{"args":[],"type":"{ date : String.String, timezone : Maybe.Maybe String.String, string : String.String, lang : String.String, isRecurring : Basics.Bool }"},"External.TodoistSync.ISODateString":{"args":[],"type":"String.String"},"External.TodoistSync.Item":{"args":[],"type":"{ id : External.TodoistSync.ItemID, user_id : External.TodoistSync.UserID, project_id : Basics.Int, content : String.String, due : Maybe.Maybe External.TodoistSync.Due, indent : Basics.Int, priority : External.TodoistSync.Priority, parent_id : Maybe.Maybe External.TodoistSync.ItemID, child_order : Basics.Int, day_order : Basics.Int, collapsed : Basics.Bool, children : List.List External.TodoistSync.ItemID, labels : List.List External.TodoistSync.LabelID, assigned_by_uid : External.TodoistSync.UserID, responsible_uid : Maybe.Maybe External.TodoistSync.UserID, checked : Basics.Bool, in_history : Basics.Bool, is_deleted : Basics.Bool, is_archived : Basics.Bool, date_added : External.TodoistSync.ISODateString }"},"External.TodoistSync.ItemID":{"args":[],"type":"Basics.Int"},"External.TodoistSync.LabelID":{"args":[],"type":"Basics.Int"},"External.TodoistSync.Project":{"args":[],"type":"{ id : Basics.Int, name : String.String, color : Basics.Int, parentId : Basics.Int, childOrder : Basics.Int, collapsed : Basics.Int, shared : Basics.Bool, isDeleted : Basics.Int, isArchived : Basics.Int, isFavorite : Basics.Int }"},"External.TodoistSync.Response":{"args":[],"type":"{ sync_token : String.String, full_sync : Basics.Bool, items : List.List External.TodoistSync.Item, projects : List.List External.TodoistSync.Project }"},"External.TodoistSync.UserID":{"args":[],"type":"Basics.Int"},"Task.Progress.Portion":{"args":[],"type":"Basics.Int"},"Task.Progress.Progress":{"args":[],"type":"( Task.Progress.Portion, Task.Progress.Unit )"},"Task.Task.TaskId":{"args":[],"type":"Basics.Int"},"Time.Era":{"args":[],"type":"{ start : Basics.Int, offset : Basics.Int }"},"Activity.Activity.SvgPath":{"args":[],"type":"String.String"},"Time.Extra.Parts":{"args":[],"type":"{ year : Basics.Int, month : Time.Month, day : Basics.Int, hour : Basics.Int, minute : Basics.Int, second : Basics.Int, millisecond : Basics.Int }"},"Date.RataDie":{"args":[],"type":"Basics.Int"}},"unions":{"Main.Msg":{"args":[],"tags":{"NoOp":[],"Tick":["Main.Msg"],"Tock":["Main.Msg","SmartTime.Moment.Moment"],"SetZoneAndTime":["SmartTime.Human.Moment.Zone","SmartTime.Moment.Moment"],"ClearErrors":[],"SyncTodoist":[],"TodoistServerResponse":["External.TodoistSync.TodoistMsg"],"Link":["Browser.UrlRequest"],"NewUrl":["Url.Url"],"TaskListMsg":["TaskList.Msg"],"TimeTrackerMsg":["TimeTracker.Msg"]}},"External.TodoistSync.TodoistMsg":{"args":[],"tags":{"SyncResponded":["Result.Result Http.Error External.TodoistSync.Response"]}},"SmartTime.Moment.Moment":{"args":[],"tags":{"Moment":["SmartTime.Duration.Duration"]}},"TaskList.Msg":{"args":[],"tags":{"EditingTitle":["Task.Task.TaskId","Basics.Bool"],"UpdateTask":["Task.Task.TaskId","String.String"],"Add":[],"Delete":["Task.Task.TaskId"],"DeleteComplete":[],"UpdateProgress":["Task.Task.TaskId","Task.Progress.Progress"],"FocusSlider":["Task.Task.TaskId","Basics.Bool"],"UpdateTaskDate":["Task.Task.TaskId","String.String","Task.TaskMoment.TaskMoment"],"UpdateNewEntryField":["String.String"],"NoOp":[]}},"TimeTracker.Msg":{"args":[],"tags":{"NoOp":[],"StartTracking":["Activity.Activity.ActivityID"]}},"Browser.UrlRequest":{"args":[],"tags":{"Internal":["Url.Url"],"External":["String.String"]}},"Basics.Int":{"args":[],"tags":{"Int":[]}},"Maybe.Maybe":{"args":["a"],"tags":{"Just":["a"],"Nothing":[]}},"String.String":{"args":[],"tags":{"String":[]}},"Time.Zone":{"args":[],"tags":{"Zone":["Basics.Int","List.List Time.Era"]}},"Url.Protocol":{"args":[],"tags":{"Http":[],"Https":[]}},"Activity.Activity.Category":{"args":[],"tags":{"Transit":[],"Entertainment":[],"Hygiene":[],"Slacking":[],"Communication":[]}},"Activity.Activity.Evidence":{"args":[],"tags":{"Evidence":[]}},"Activity.Activity.Excusable":{"args":[],"tags":{"NeverExcused":[],"TemporarilyExcused":["Activity.Activity.DurationPerPeriod"],"IndefinitelyExcused":[]}},"Activity.Activity.Icon":{"args":[],"tags":{"File":["Activity.Activity.SvgPath"],"Ion":[],"Other":[]}},"Activity.Template.Template":{"args":[],"tags":{"DillyDally":[],"Apparel":[],"Messaging":[],"Restroom":[],"Grooming":[],"Meal":[],"Supplements":[],"Workout":[],"Shower":[],"Toothbrush":[],"Floss":[],"Wakeup":[],"Sleep":[],"Plan":[],"Configure":[],"Email":[],"Work":[],"Call":[],"Chores":[],"Parents":[],"Prepare":[],"Lover":[],"Driving":[],"Riding":[],"SocialMedia":[],"Pacing":[],"Sport":[],"Finance":[],"Laundry":[],"Bedward":[],"Browse":[],"Fiction":[],"Learning":[],"BrainTrain":[],"Music":[],"Create":[],"Children":[],"Meeting":[],"Cinema":[],"FilmWatching":[],"Series":[],"Broadcast":[],"Theatre":[],"Shopping":[],"VideoGaming":[],"Housekeeping":[],"MealPrep":[],"Networking":[],"Meditate":[],"Homework":[],"Flight":[],"Course":[],"Pet":[],"Presentation":[],"Projects":[]}},"External.TodoistSync.Priority":{"args":[],"tags":{"Priority":["Basics.Int"]}},"ID.ID":{"args":["userType"],"tags":{"ID":["Basics.Int"]}},"SmartTime.Duration.Duration":{"args":[],"tags":{"Duration":["Basics.Int"]}},"SmartTime.Human.Duration.HumanDuration":{"args":[],"tags":{"Milliseconds":["Basics.Int"],"Seconds":["Basics.Int"],"Minutes":["Basics.Int"],"Hours":["Basics.Int"],"Days":["Basics.Int"]}},"Task.Progress.Unit":{"args":[],"tags":{"None":[],"Permille":[],"Percent":[],"Word":["Basics.Int"],"Minute":["Basics.Int"],"CustomUnit":["( String.String, String.String )","Basics.Int"]}},"Task.TaskMoment.TaskMoment":{"args":[],"tags":{"Unset":[],"LocalDate":["Date.Date"],"Localized":["Time.Extra.Parts"],"Universal":["SmartTime.Moment.Moment"]}},"Basics.Bool":{"args":[],"tags":{"True":[],"False":[]}},"List.List":{"args":["a"],"tags":{}},"Result.Result":{"args":["error","value"],"tags":{"Ok":["value"],"Err":["error"]}},"Http.Error":{"args":[],"tags":{"BadUrl":["String.String"],"Timeout":[],"NetworkError":[],"BadStatus":["Basics.Int"],"BadBody":["String.String"]}},"Time.Month":{"args":[],"tags":{"Jan":[],"Feb":[],"Mar":[],"Apr":[],"May":[],"Jun":[],"Jul":[],"Aug":[],"Sep":[],"Oct":[],"Nov":[],"Dec":[]}},"Date.Date":{"args":[],"tags":{"RD":["Date.RataDie"]}}}}})},'Main':{'init':author$project$Main$main(
	elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				elm$json$Json$Decode$null(elm$core$Maybe$Nothing),
				A2(elm$json$Json$Decode$map, elm$core$Maybe$Just, elm$json$Json$Decode$string)
			])))({"versions":{"elm":"0.19.0"},"types":{"message":"Main.Msg","aliases":{"SmartTime.Human.Moment.Zone":{"args":[],"type":"Time.Zone"},"Url.Url":{"args":[],"type":"{ protocol : Url.Protocol, host : String.String, port_ : Maybe.Maybe Basics.Int, path : String.String, query : Maybe.Maybe String.String, fragment : Maybe.Maybe String.String }"},"Activity.Activity.Activity":{"args":[],"type":"{ names : List.List String.String, icon : Activity.Activity.Icon, excusable : Activity.Activity.Excusable, taskOptional : Basics.Bool, evidence : List.List Activity.Activity.Evidence, category : Activity.Activity.Category, backgroundable : Basics.Bool, maxTime : Activity.Activity.DurationPerPeriod, hidden : Basics.Bool, template : Activity.Template.Template }"},"Activity.Activity.ActivityID":{"args":[],"type":"ID.ID Activity.Activity.Activity"},"Activity.Activity.DurationPerPeriod":{"args":[],"type":"( SmartTime.Human.Duration.HumanDuration, SmartTime.Human.Duration.HumanDuration )"},"External.TodoistSync.Due":{"args":[],"type":"{ date : String.String, timezone : Maybe.Maybe String.String, string : String.String, lang : String.String, isRecurring : Basics.Bool }"},"External.TodoistSync.ISODateString":{"args":[],"type":"String.String"},"External.TodoistSync.Item":{"args":[],"type":"{ id : External.TodoistSync.ItemID, user_id : External.TodoistSync.UserID, project_id : Basics.Int, content : String.String, due : Maybe.Maybe External.TodoistSync.Due, indent : Basics.Int, priority : External.TodoistSync.Priority, parent_id : Maybe.Maybe External.TodoistSync.ItemID, child_order : Basics.Int, day_order : Basics.Int, collapsed : Basics.Bool, children : List.List External.TodoistSync.ItemID, labels : List.List External.TodoistSync.LabelID, assigned_by_uid : External.TodoistSync.UserID, responsible_uid : Maybe.Maybe External.TodoistSync.UserID, checked : Basics.Bool, in_history : Basics.Bool, is_deleted : Basics.Bool, is_archived : Basics.Bool, date_added : External.TodoistSync.ISODateString }"},"External.TodoistSync.ItemID":{"args":[],"type":"Basics.Int"},"External.TodoistSync.LabelID":{"args":[],"type":"Basics.Int"},"External.TodoistSync.Project":{"args":[],"type":"{ id : Basics.Int, name : String.String, color : Basics.Int, parentId : Basics.Int, childOrder : Basics.Int, collapsed : Basics.Int, shared : Basics.Bool, isDeleted : Basics.Int, isArchived : Basics.Int, isFavorite : Basics.Int }"},"External.TodoistSync.Response":{"args":[],"type":"{ sync_token : String.String, full_sync : Basics.Bool, items : List.List External.TodoistSync.Item, projects : List.List External.TodoistSync.Project }"},"External.TodoistSync.UserID":{"args":[],"type":"Basics.Int"},"Task.Progress.Portion":{"args":[],"type":"Basics.Int"},"Task.Progress.Progress":{"args":[],"type":"( Task.Progress.Portion, Task.Progress.Unit )"},"Task.Task.TaskId":{"args":[],"type":"Basics.Int"},"Time.Era":{"args":[],"type":"{ start : Basics.Int, offset : Basics.Int }"},"Activity.Activity.SvgPath":{"args":[],"type":"String.String"},"Time.Extra.Parts":{"args":[],"type":"{ year : Basics.Int, month : Time.Month, day : Basics.Int, hour : Basics.Int, minute : Basics.Int, second : Basics.Int, millisecond : Basics.Int }"},"Date.RataDie":{"args":[],"type":"Basics.Int"}},"unions":{"Main.Msg":{"args":[],"tags":{"NoOp":[],"Tick":["Main.Msg"],"Tock":["Main.Msg","SmartTime.Moment.Moment"],"SetZoneAndTime":["SmartTime.Human.Moment.Zone","SmartTime.Moment.Moment"],"ClearErrors":[],"SyncTodoist":[],"TodoistServerResponse":["External.TodoistSync.TodoistMsg"],"Link":["Browser.UrlRequest"],"NewUrl":["Url.Url"],"TaskListMsg":["TaskList.Msg"],"TimeTrackerMsg":["TimeTracker.Msg"]}},"External.TodoistSync.TodoistMsg":{"args":[],"tags":{"SyncResponded":["Result.Result Http.Error External.TodoistSync.Response"]}},"SmartTime.Moment.Moment":{"args":[],"tags":{"Moment":["SmartTime.Duration.Duration"]}},"TaskList.Msg":{"args":[],"tags":{"EditingTitle":["Task.Task.TaskId","Basics.Bool"],"UpdateTask":["Task.Task.TaskId","String.String"],"Add":[],"Delete":["Task.Task.TaskId"],"DeleteComplete":[],"UpdateProgress":["Task.Task.TaskId","Task.Progress.Progress"],"FocusSlider":["Task.Task.TaskId","Basics.Bool"],"UpdateTaskDate":["Task.Task.TaskId","String.String","Task.TaskMoment.TaskMoment"],"UpdateNewEntryField":["String.String"],"NoOp":[]}},"TimeTracker.Msg":{"args":[],"tags":{"NoOp":[],"StartTracking":["Activity.Activity.ActivityID"]}},"Browser.UrlRequest":{"args":[],"tags":{"Internal":["Url.Url"],"External":["String.String"]}},"Basics.Int":{"args":[],"tags":{"Int":[]}},"Maybe.Maybe":{"args":["a"],"tags":{"Just":["a"],"Nothing":[]}},"String.String":{"args":[],"tags":{"String":[]}},"Time.Zone":{"args":[],"tags":{"Zone":["Basics.Int","List.List Time.Era"]}},"Url.Protocol":{"args":[],"tags":{"Http":[],"Https":[]}},"Activity.Activity.Category":{"args":[],"tags":{"Transit":[],"Entertainment":[],"Hygiene":[],"Slacking":[],"Communication":[]}},"Activity.Activity.Evidence":{"args":[],"tags":{"Evidence":[]}},"Activity.Activity.Excusable":{"args":[],"tags":{"NeverExcused":[],"TemporarilyExcused":["Activity.Activity.DurationPerPeriod"],"IndefinitelyExcused":[]}},"Activity.Activity.Icon":{"args":[],"tags":{"File":["Activity.Activity.SvgPath"],"Ion":[],"Other":[]}},"Activity.Template.Template":{"args":[],"tags":{"DillyDally":[],"Apparel":[],"Messaging":[],"Restroom":[],"Grooming":[],"Meal":[],"Supplements":[],"Workout":[],"Shower":[],"Toothbrush":[],"Floss":[],"Wakeup":[],"Sleep":[],"Plan":[],"Configure":[],"Email":[],"Work":[],"Call":[],"Chores":[],"Parents":[],"Prepare":[],"Lover":[],"Driving":[],"Riding":[],"SocialMedia":[],"Pacing":[],"Sport":[],"Finance":[],"Laundry":[],"Bedward":[],"Browse":[],"Fiction":[],"Learning":[],"BrainTrain":[],"Music":[],"Create":[],"Children":[],"Meeting":[],"Cinema":[],"FilmWatching":[],"Series":[],"Broadcast":[],"Theatre":[],"Shopping":[],"VideoGaming":[],"Housekeeping":[],"MealPrep":[],"Networking":[],"Meditate":[],"Homework":[],"Flight":[],"Course":[],"Pet":[],"Presentation":[],"Projects":[]}},"External.TodoistSync.Priority":{"args":[],"tags":{"Priority":["Basics.Int"]}},"ID.ID":{"args":["userType"],"tags":{"ID":["Basics.Int"]}},"SmartTime.Duration.Duration":{"args":[],"tags":{"Duration":["Basics.Int"]}},"SmartTime.Human.Duration.HumanDuration":{"args":[],"tags":{"Milliseconds":["Basics.Int"],"Seconds":["Basics.Int"],"Minutes":["Basics.Int"],"Hours":["Basics.Int"],"Days":["Basics.Int"]}},"Task.Progress.Unit":{"args":[],"tags":{"None":[],"Permille":[],"Percent":[],"Word":["Basics.Int"],"Minute":["Basics.Int"],"CustomUnit":["( String.String, String.String )","Basics.Int"]}},"Task.TaskMoment.TaskMoment":{"args":[],"tags":{"Unset":[],"LocalDate":["Date.Date"],"Localized":["Time.Extra.Parts"],"Universal":["SmartTime.Moment.Moment"]}},"Basics.Bool":{"args":[],"tags":{"True":[],"False":[]}},"List.List":{"args":["a"],"tags":{}},"Result.Result":{"args":["error","value"],"tags":{"Ok":["value"],"Err":["error"]}},"Http.Error":{"args":[],"tags":{"BadUrl":["String.String"],"Timeout":[],"NetworkError":[],"BadStatus":["Basics.Int"],"BadBody":["String.String"]}},"Time.Month":{"args":[],"tags":{"Jan":[],"Feb":[],"Mar":[],"Apr":[],"May":[],"Jun":[],"Jul":[],"Aug":[],"Sep":[],"Oct":[],"Nov":[],"Dec":[]}},"Date.Date":{"args":[],"tags":{"RD":["Date.RataDie"]}}}}})}});}(this));