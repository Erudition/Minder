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

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
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

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
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


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
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
	if (region.cA.a4 === region.db.a4)
	{
		return 'on line ' + region.cA.a4;
	}
	return 'on lines ' + region.cA.a4 + ' through ' + region.db.a4;
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

	/**_UNUSED/
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

	/**/
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

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
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

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


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



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


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



/**_UNUSED/
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

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

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
		impl.eI,
		impl.cM,
		impl.e5,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
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


function _Platform_export(exports)
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


function _Platform_export_UNUSED(exports)
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
			callback(toTask(request.ez.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done(elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done(elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.ez.b, xhr)); });
		elm$core$Maybe$isJust(request.M) && _Http_track(router, xhr, request.M.a);

		try {
			xhr.open(request.K, request.cN, true);
		} catch (e) {
			return done(elm$http$Http$BadUrl_(request.cN));
		}

		_Http_configureRequest(xhr, request);

		request.bi.a && xhr.setRequestHeader('Content-Type', request.bi.a);
		xhr.send(request.bi.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.H; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.cI.a || 0;
	xhr.responseType = request.ez.d;
	xhr.withCredentials = request.aw;
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
		cN: xhr.responseURL,
		d3: xhr.status,
		e3: xhr.statusText,
		H: _Http_parseHeaders(xhr.getAllResponseHeaders())
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
			e2: event.loaded,
			cy: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2(elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, elm$http$Http$Receiving({
			eY: event.loaded,
			cy: event.lengthComputable ? elm$core$Maybe$Just(event.total) : elm$core$Maybe$Nothing
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

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
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

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
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
		ae: func(record.ae),
		cD: record.cD,
		co: record.co
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
		var message = !tag ? value : tag < 3 ? value.a : value.ae;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.cD;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.co) && event.preventDefault(),
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




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.eI,
		impl.cM,
		impl.e5,
		function(sendToApp, initialModel) {
			var view = impl.fb;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
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
		impl.eI,
		impl.cM,
		impl.e5,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.a7 && impl.a7(sendToApp)
			var view = impl.fb;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.bi);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.ba) && (_VirtualDom_doc.title = title = doc.ba);
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
	var onUrlChange = impl.eT;
	var onUrlRequest = impl.eU;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		a7: function(sendToApp)
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
							&& curr.dR === next.dR
							&& curr.dj === next.dj
							&& curr.dK.a === next.dK.a
						)
							? elm$browser$Browser$Internal(next)
							: elm$browser$Browser$External(href)
					));
				}
			});
		},
		eI: function(flags)
		{
			return A3(impl.eI, flags, _Browser_getUrl(), key);
		},
		fb: impl.fb,
		cM: impl.cM,
		e5: impl.e5
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
		? { b: 'hidden', eq: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { b: 'mozHidden', eq: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { b: 'msHidden', eq: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { b: 'webkitHidden', eq: 'webkitvisibilitychange' }
		: { b: 'hidden', eq: 'visibilitychange' };
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
		dZ: _Browser_getScene(),
		eg: {
			bF: _Browser_window.pageXOffset,
			bG: _Browser_window.pageYOffset,
			aZ: _Browser_doc.documentElement.clientWidth,
			aJ: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		aZ: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		aJ: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
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
			dZ: {
				aZ: node.scrollWidth,
				aJ: node.scrollHeight
			},
			eg: {
				bF: node.scrollLeft,
				bG: node.scrollTop,
				aZ: node.clientWidth,
				aJ: node.clientHeight
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
			dZ: _Browser_getScene(),
			eg: {
				bF: x,
				bG: y,
				aZ: _Browser_doc.documentElement.clientWidth,
				aJ: _Browser_doc.documentElement.clientHeight
			},
			ew: {
				bF: x + rect.left,
				bG: y + rect.top,
				aZ: rect.width,
				aJ: rect.height
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
	return {$: 7, a: a};
};
var author$project$Main$NewUrl = function (a) {
	return {$: 8, a: a};
};
var author$project$Incubator$Todoist$IncrementalSyncToken = elm$core$Basics$identity;
var elm$core$Basics$identity = function (x) {
	return x;
};
var elm$core$Basics$EQ = 1;
var elm$core$Basics$LT = 0;
var elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var elm$core$Array$foldr = F3(
	function (func, baseCase, _n0) {
		var tree = _n0.c;
		var tail = _n0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
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
var elm$core$Basics$GT = 2;
var elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
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
	var dict = _n0;
	return elm$core$Dict$keys(dict);
};
var elm_community$intdict$IntDict$Empty = {$: 0};
var elm_community$intdict$IntDict$empty = elm_community$intdict$IntDict$Empty;
var author$project$Incubator$Todoist$emptyCache = {P: elm_community$intdict$IntDict$empty, ap: '*', by: _List_Nil, T: elm_community$intdict$IntDict$empty};
var elm$core$Maybe$Nothing = {$: 1};
var author$project$AppData$emptyTodoistIntegrationData = {bI: elm_community$intdict$IntDict$empty, bN: author$project$Incubator$Todoist$emptyCache, cf: elm$core$Maybe$Nothing};
var author$project$AppData$fromScratch = {bH: elm_community$intdict$IntDict$empty, aj: _List_Nil, e8: elm_community$intdict$IntDict$empty, cH: _List_Nil, cK: author$project$AppData$emptyTodoistIntegrationData, cL: 0};
var author$project$AppData$saveError = F2(
	function (appData, error) {
		return _Utils_update(
			appData,
			{
				aj: A2(elm$core$List$cons, error, appData.aj)
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
	return {$: 0, a: a};
};
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
		case 0:
			return 'a string';
		case 2:
			return 'an integer number';
		case 3:
			return 'a number';
		case 8:
			return 'null';
		case 1:
			return 'a boolean';
		case 4:
			return 'an array';
		case 5:
			return 'an object';
		case 6:
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
		return {$: 0, a: a, b: b, c: c, d: d};
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
	return {$: 1, a: a};
};
var elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
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
		if (!builder.B) {
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.E),
				elm$core$Array$shiftStep,
				elm$core$Elm$JsArray$empty,
				builder.E);
		} else {
			var treeLen = builder.B * elm$core$Array$branchFactor;
			var depth = elm$core$Basics$floor(
				A2(elm$core$Basics$logBase, elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? elm$core$List$reverse(builder.F) : builder.F;
			var tree = A2(elm$core$Array$treeFromBuilder, correctNodeList, builder.B);
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.E) + treeLen,
				A2(elm$core$Basics$max, 5, depth * elm$core$Array$shiftStep),
				tree,
				builder.E);
		}
	});
var elm$core$Basics$False = 1;
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
					{F: nodeList, B: (len / elm$core$Array$branchFactor) | 0, E: tail});
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
	return {$: 1, a: a};
};
var elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var elm$core$Basics$True = 0;
var elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
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
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _n1 = elm$core$String$uncons(f);
						if (_n1.$ === 1) {
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
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + (elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2(elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
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
		case 2:
			var v = located.a;
			return _List_fromArray(
				[
					_Utils_Tuple2(
					'',
					_List_fromArray(
						[v]))
				]);
		case 0:
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
		case 2:
			var failure = error.a;
			var json = error.b;
			if (!json.$) {
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
		case 1:
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
		if (warning.$ === 1) {
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
				aj: _Utils_ap(
					_List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToString(warnings)
						]),
					appData.aj)
			});
	});
var author$project$Main$SetZoneAndTime = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
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
											return {d: backgroundable, e: category, f: evidence, a: excusable, b: hidden, g: icon, dl: id, h: maxTime, c: names, i: taskOptional, j: template};
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
var author$project$Activity$Activity$Communication = 4;
var author$project$Activity$Activity$Entertainment = 1;
var author$project$Activity$Activity$Hygiene = 2;
var author$project$Activity$Activity$Slacking = 3;
var author$project$Activity$Activity$Transit = 0;
var elm$core$Result$map = F2(
	function (func, ra) {
		if (!ra.$) {
			var a = ra.a;
			return elm$core$Result$Ok(
				func(a));
		} else {
			var e = ra.a;
			return elm$core$Result$Err(e);
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Decoder = elm$core$Basics$identity;
var zwilias$json_decode_exploration$Json$Decode$Exploration$andThen = F2(
	function (toDecoderB, _n0) {
		var decoderFnA = _n0;
		return function (json) {
			var _n1 = decoderFnA(json);
			if (!_n1.$) {
				var accA = _n1.a;
				var _n2 = toDecoderB(accA.X);
				var decoderFnB = _n2;
				return A2(
					elm$core$Result$map,
					function (accB) {
						return _Utils_update(
							accB,
							{
								z: _Utils_ap(accA.z, accB.z)
							});
					},
					decoderFnB(accA.C));
			} else {
				var e = _n1.a;
				return elm$core$Result$Err(e);
			}
		};
	});
var mgold$elm_nonempty_list$List$Nonempty$Nonempty = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var mgold$elm_nonempty_list$List$Nonempty$fromElement = function (x) {
	return A2(mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, _List_Nil);
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Failure = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
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
				_Json_emptyArray(0),
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
			_Json_emptyObject(0),
			pairs));
};
var elm$json$Json$Encode$string = _Json_wrap;
var zwilias$json_decode_exploration$Json$Decode$Exploration$encode = function (v) {
	switch (v.$) {
		case 0:
			var val = v.b;
			return elm$json$Json$Encode$string(val);
		case 1:
			var val = v.b;
			return elm$json$Json$Encode$float(val);
		case 2:
			var val = v.b;
			return elm$json$Json$Encode$bool(val);
		case 3:
			return elm$json$Json$Encode$null;
		case 4:
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
	return {$: 2, a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$fail = function (message) {
	return function (json) {
		return elm$core$Result$Err(
			mgold$elm_nonempty_list$List$Nonempty$fromElement(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
					A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Failure,
						message,
						elm$core$Maybe$Just(
							zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json))))));
	};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TString = {$: 0};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Expected = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
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
		return {$: 4, a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Bool = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Null = function (a) {
	return {$: 3, a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Number = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$Object = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$String = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed = function (annotatedValue) {
	switch (annotatedValue.$) {
		case 0:
			var val = annotatedValue.b;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$String, true, val);
		case 1:
			var val = annotatedValue.b;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Number, true, val);
		case 2:
			var val = annotatedValue.b;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Bool, true, val);
		case 3:
			return zwilias$json_decode_exploration$Json$Decode$Exploration$Null(true);
		case 4:
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
			{C: json, X: val, z: _List_Nil});
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$string = function (json) {
	if (!json.$) {
		var val = json.b;
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
			zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
			val);
	} else {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TString, json);
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$succeed = function (val) {
	return function (json) {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$ok, json, val);
	};
};
var author$project$Activity$Activity$decodeCategory = A2(
	zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
	function (string) {
		switch (string) {
			case 'Transit':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(0);
			case 'Entertainment':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(1);
			case 'Hygiene':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(2);
			case 'Slacking':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(3);
			case 'Communication':
				return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(4);
			default:
				return zwilias$json_decode_exploration$Json$Decode$Exploration$fail('Invalid Category');
		}
	},
	zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var author$project$SmartTime$Duration$Duration = elm$core$Basics$identity;
var author$project$SmartTime$Duration$fromInt = function (_int) {
	return _int;
};
var author$project$SmartTime$Duration$inMs = function (_n0) {
	var _int = _n0;
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
	return {$: 4, a: a};
};
var author$project$SmartTime$Human$Duration$Hours = function (a) {
	return {$: 3, a: a};
};
var author$project$SmartTime$Human$Duration$Milliseconds = function (a) {
	return {$: 0, a: a};
};
var author$project$SmartTime$Human$Duration$Minutes = function (a) {
	return {$: 2, a: a};
};
var author$project$SmartTime$Human$Duration$Seconds = function (a) {
	return {$: 1, a: a};
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
	return {da: days, dk: hours, dB: withoutSeconds, dD: minutes, d_: seconds};
};
var author$project$SmartTime$Human$Duration$breakdownDHMSM = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var days = _n0.da;
	var hours = _n0.dk;
	var minutes = _n0.dD;
	var seconds = _n0.d_;
	var milliseconds = _n0.dB;
	return _List_fromArray(
		[
			author$project$SmartTime$Human$Duration$Days(days),
			author$project$SmartTime$Human$Duration$Hours(hours),
			author$project$SmartTime$Human$Duration$Minutes(minutes),
			author$project$SmartTime$Human$Duration$Seconds(seconds),
			author$project$SmartTime$Human$Duration$Milliseconds(milliseconds)
		]);
};
var elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
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
var author$project$SmartTime$Human$Duration$inLargestExactUnits = function (duration) {
	var smallestPartMaybe = elm_community$list_extra$List$Extra$last(
		author$project$SmartTime$Human$Duration$breakdownDHMSM(duration));
	var smallestPart = A2(
		elm$core$Maybe$withDefault,
		author$project$SmartTime$Human$Duration$Milliseconds(0),
		smallestPartMaybe);
	switch (smallestPart.$) {
		case 4:
			var days = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Days(days);
		case 3:
			var hours = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Hours(
				author$project$SmartTime$Duration$inWholeHours(duration));
		case 2:
			var minutes = smallestPart.a;
			return author$project$SmartTime$Human$Duration$Minutes(
				author$project$SmartTime$Duration$inWholeMinutes(duration));
		case 1:
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
var zwilias$json_decode_exploration$Json$Decode$Exploration$TInt = {$: 2};
var zwilias$json_decode_exploration$Json$Decode$Exploration$int = function (json) {
	if (json.$ === 1) {
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
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$mapAcc = F2(
	function (f, acc) {
		return {
			C: acc.C,
			X: f(acc.X),
			z: acc.z
		};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$map = F2(
	function (f, _n0) {
		var decoderFn = _n0;
		return function (json) {
			return A2(
				elm$core$Result$map,
				zwilias$json_decode_exploration$Json$Decode$Exploration$mapAcc(f),
				decoderFn(json));
		};
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
var zwilias$json_decode_exploration$Json$Decode$Exploration$TArray = {$: 4};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TArrayIndex = function (a) {
	return {$: 6, a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$AtIndex = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$index = F2(
	function (idx, _n0) {
		var decoderFn = _n0;
		var finalize = F2(
			function (json, _n6) {
				var values = _n6.a;
				var warnings = _n6.b;
				var res = _n6.c;
				if (res.$ === 1) {
					return A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$expected,
						zwilias$json_decode_exploration$Json$Decode$Exploration$TArrayIndex(idx),
						json);
				} else {
					if (res.a.$ === 1) {
						var e = res.a.a;
						return elm$core$Result$Err(e);
					} else {
						var v = res.a.a;
						return elm$core$Result$Ok(
							{
								C: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, values),
								X: v,
								z: warnings
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
					if (_n2.$ === 1) {
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
								A2(elm$core$List$cons, res.C, acc),
								_Utils_ap(res.z, warnings),
								elm$core$Maybe$Just(
									elm$core$Result$Ok(res.X))));
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
		return function (json) {
			if (json.$ === 4) {
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
		};
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
var author$project$Activity$Activity$Evidence = 0;
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
	return {$: 0, a: a};
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
				var decoderFn = decoders.a;
				var rest = decoders.b;
				var _n1 = decoderFn(val);
				if (!_n1.$) {
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
	return function (json) {
		return A3(zwilias$json_decode_exploration$Json$Decode$Exploration$oneOfHelp, decoders, json, _List_Nil);
	};
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
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(0))
		]));
var author$project$Activity$Activity$IndefinitelyExcused = {$: 2};
var author$project$Activity$Activity$NeverExcused = {$: 0};
var author$project$Activity$Activity$TemporarilyExcused = function (a) {
	return {$: 1, a: a};
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
var author$project$Activity$Activity$Ion = {$: 1};
var author$project$Activity$Activity$Other = {$: 2};
var author$project$Activity$Activity$File = function (a) {
	return {$: 0, a: a};
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
var author$project$Activity$Template$Apparel = 1;
var author$project$Activity$Template$Bedward = 29;
var author$project$Activity$Template$BrainTrain = 33;
var author$project$Activity$Template$Broadcast = 41;
var author$project$Activity$Template$Browse = 30;
var author$project$Activity$Template$Call = 17;
var author$project$Activity$Template$Children = 36;
var author$project$Activity$Template$Chores = 18;
var author$project$Activity$Template$Cinema = 38;
var author$project$Activity$Template$Configure = 14;
var author$project$Activity$Template$Course = 51;
var author$project$Activity$Template$Create = 35;
var author$project$Activity$Template$DillyDally = 0;
var author$project$Activity$Template$Driving = 22;
var author$project$Activity$Template$Email = 15;
var author$project$Activity$Template$Fiction = 31;
var author$project$Activity$Template$FilmWatching = 39;
var author$project$Activity$Template$Finance = 27;
var author$project$Activity$Template$Flight = 50;
var author$project$Activity$Template$Floss = 10;
var author$project$Activity$Template$Grooming = 4;
var author$project$Activity$Template$Homework = 49;
var author$project$Activity$Template$Housekeeping = 45;
var author$project$Activity$Template$Laundry = 28;
var author$project$Activity$Template$Learning = 32;
var author$project$Activity$Template$Lover = 21;
var author$project$Activity$Template$Meal = 5;
var author$project$Activity$Template$MealPrep = 46;
var author$project$Activity$Template$Meditate = 48;
var author$project$Activity$Template$Meeting = 37;
var author$project$Activity$Template$Messaging = 2;
var author$project$Activity$Template$Music = 34;
var author$project$Activity$Template$Networking = 47;
var author$project$Activity$Template$Pacing = 25;
var author$project$Activity$Template$Parents = 19;
var author$project$Activity$Template$Pet = 52;
var author$project$Activity$Template$Plan = 13;
var author$project$Activity$Template$Prepare = 20;
var author$project$Activity$Template$Presentation = 53;
var author$project$Activity$Template$Projects = 54;
var author$project$Activity$Template$Restroom = 3;
var author$project$Activity$Template$Riding = 23;
var author$project$Activity$Template$Series = 40;
var author$project$Activity$Template$Shopping = 43;
var author$project$Activity$Template$Shower = 8;
var author$project$Activity$Template$Sleep = 12;
var author$project$Activity$Template$SocialMedia = 24;
var author$project$Activity$Template$Sport = 26;
var author$project$Activity$Template$Supplements = 6;
var author$project$Activity$Template$Theatre = 42;
var author$project$Activity$Template$Toothbrush = 9;
var author$project$Activity$Template$VideoGaming = 44;
var author$project$Activity$Template$Wakeup = 11;
var author$project$Activity$Template$Work = 16;
var author$project$Activity$Template$Workout = 7;
var author$project$Porting$decodeCustomFlat = function (tags) {
	var justTag = elm$core$Tuple$mapSecond(zwilias$json_decode_exploration$Json$Decode$Exploration$succeed);
	return author$project$Porting$decodeCustom(
		A2(elm$core$List$map, justTag, tags));
};
var author$project$Activity$Template$decodeTemplate = author$project$Porting$decodeCustomFlat(
	_List_fromArray(
		[
			_Utils_Tuple2('DillyDally', 0),
			_Utils_Tuple2('Apparel', 1),
			_Utils_Tuple2('Messaging', 2),
			_Utils_Tuple2('Restroom', 3),
			_Utils_Tuple2('Grooming', 4),
			_Utils_Tuple2('Meal', 5),
			_Utils_Tuple2('Supplements', 6),
			_Utils_Tuple2('Workout', 7),
			_Utils_Tuple2('Shower', 8),
			_Utils_Tuple2('Toothbrush', 9),
			_Utils_Tuple2('Floss', 10),
			_Utils_Tuple2('Wakeup', 11),
			_Utils_Tuple2('Sleep', 12),
			_Utils_Tuple2('Plan', 13),
			_Utils_Tuple2('Configure', 14),
			_Utils_Tuple2('Email', 15),
			_Utils_Tuple2('Work', 16),
			_Utils_Tuple2('Call', 17),
			_Utils_Tuple2('Chores', 18),
			_Utils_Tuple2('Parents', 19),
			_Utils_Tuple2('Prepare', 20),
			_Utils_Tuple2('Lover', 21),
			_Utils_Tuple2('Driving', 22),
			_Utils_Tuple2('Riding', 23),
			_Utils_Tuple2('SocialMedia', 24),
			_Utils_Tuple2('Pacing', 25),
			_Utils_Tuple2('Sport', 26),
			_Utils_Tuple2('Finance', 27),
			_Utils_Tuple2('Laundry', 28),
			_Utils_Tuple2('Bedward', 29),
			_Utils_Tuple2('Browse', 30),
			_Utils_Tuple2('Fiction', 31),
			_Utils_Tuple2('Learning', 32),
			_Utils_Tuple2('BrainTrain', 33),
			_Utils_Tuple2('Music', 34),
			_Utils_Tuple2('Create', 35),
			_Utils_Tuple2('Children', 36),
			_Utils_Tuple2('Meeting', 37),
			_Utils_Tuple2('Cinema', 38),
			_Utils_Tuple2('FilmWatching', 39),
			_Utils_Tuple2('Series', 40),
			_Utils_Tuple2('Broadcast', 41),
			_Utils_Tuple2('Theatre', 42),
			_Utils_Tuple2('Shopping', 43),
			_Utils_Tuple2('VideoGaming', 44),
			_Utils_Tuple2('Housekeeping', 45),
			_Utils_Tuple2('MealPrep', 46),
			_Utils_Tuple2('Networking', 47),
			_Utils_Tuple2('Meditate', 48),
			_Utils_Tuple2('Homework', 49),
			_Utils_Tuple2('Flight', 50),
			_Utils_Tuple2('Course', 51),
			_Utils_Tuple2('Pet', 52),
			_Utils_Tuple2('Presentation', 53),
			_Utils_Tuple2('Projects', 54)
		]));
var author$project$ID$ID = elm$core$Basics$identity;
var author$project$ID$decode = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Basics$identity, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
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
		var decoderFnA = _n0;
		var decoderFnB = _n1;
		return function (json) {
			var _n2 = decoderFnA(json);
			if (!_n2.$) {
				var accA = _n2.a;
				var _n3 = decoderFnB(accA.C);
				if (!_n3.$) {
					var accB = _n3.a;
					return elm$core$Result$Ok(
						{
							C: accB.C,
							X: A2(f, accA.X, accB.X),
							z: _Utils_ap(accA.z, accB.z)
						});
				} else {
					var e = _n3.a;
					return elm$core$Result$Err(e);
				}
			} else {
				var e = _n2.a;
				var _n4 = decoderFnB(json);
				if (!_n4.$) {
					return elm$core$Result$Err(e);
				} else {
					var e2 = _n4.a;
					return elm$core$Result$Err(
						A2(mgold$elm_nonempty_list$List$Nonempty$append, e, e2));
				}
			}
		};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$andMap = zwilias$json_decode_exploration$Json$Decode$Exploration$map2(elm$core$Basics$apR);
var zwilias$json_decode_exploration$Json$Decode$Exploration$TObject = {$: 5};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TObjectField = function (a) {
	return {$: 7, a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$field = F2(
	function (fieldName, _n0) {
		var decoderFn = _n0;
		var finalize = F2(
			function (json, _n6) {
				var values = _n6.a;
				var warnings = _n6.b;
				var res = _n6.c;
				if (res.$ === 1) {
					return A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$expected,
						zwilias$json_decode_exploration$Json$Decode$Exploration$TObjectField(fieldName),
						json);
				} else {
					if (res.a.$ === 1) {
						var e = res.a.a;
						return elm$core$Result$Err(e);
					} else {
						var v = res.a.a;
						return elm$core$Result$Ok(
							{
								C: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, values),
								X: v,
								z: warnings
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
					if (_n2.$ === 1) {
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
								_Utils_Tuple2(key, res.C),
								acc),
							_Utils_ap(
								A2(
									elm$core$List$map,
									A2(
										elm$core$Basics$composeR,
										mgold$elm_nonempty_list$List$Nonempty$fromElement,
										zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField(key)),
									res.z),
								warnings),
							elm$core$Maybe$Just(
								elm$core$Result$Ok(res.X)));
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
		return function (json) {
			if (json.$ === 5) {
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
		};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$isObject = function (json) {
	if (json.$ === 5) {
		var pairs = json.b;
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, pairs),
			0);
	} else {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TObject, json);
	}
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TNull = {$: 8};
var zwilias$json_decode_exploration$Json$Decode$Exploration$null = function (val) {
	return function (json) {
		if (json.$ === 3) {
			return A2(
				zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
				zwilias$json_decode_exploration$Json$Decode$Exploration$Null(true),
				val);
		} else {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TNull, json);
		}
	};
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
var author$project$Porting$withPresence = F2(
	function (fieldName, decoder) {
		return A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			fieldName,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Maybe$Just, decoder),
			elm$core$Maybe$Nothing);
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$TBool = {$: 1};
var zwilias$json_decode_exploration$Json$Decode$Exploration$bool = function (json) {
	if (json.$ === 2) {
		var val = json.b;
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
			zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
			val);
	} else {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TBool, json);
	}
};
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
	var decoderFn = _n0;
	var finalize = function (_n5) {
		var json = _n5.a;
		var warnings = _n5.b;
		var values = _n5.c;
		return {
			C: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, json),
			X: values,
			z: warnings
		};
	};
	var accumulate = F2(
		function (val, _n4) {
			var idx = _n4.a;
			var acc = _n4.b;
			var _n2 = _Utils_Tuple2(
				acc,
				decoderFn(val));
			if (_n2.a.$ === 1) {
				if (_n2.b.$ === 1) {
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
				if (_n2.b.$ === 1) {
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
								A2(elm$core$List$cons, res.C, jsonAcc),
								_Utils_ap(res.z, warnAcc),
								A2(elm$core$List$cons, res.X, valAcc))));
				}
			}
		});
	return function (json) {
		if (json.$ === 4) {
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
	};
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
			author$project$Porting$withPresence,
			'hidden',
			zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
			A3(
				author$project$Porting$withPresence,
				'maxTime',
				author$project$Activity$Activity$decodeDurationPerPeriod,
				A3(
					author$project$Porting$withPresence,
					'backgroundable',
					zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
					A3(
						author$project$Porting$withPresence,
						'category',
						author$project$Activity$Activity$decodeCategory,
						A3(
							author$project$Porting$withPresence,
							'evidence',
							zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Activity$Activity$decodeEvidence),
							A3(
								author$project$Porting$withPresence,
								'taskOptional',
								zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
								A3(
									author$project$Porting$withPresence,
									'excusable',
									author$project$Activity$Activity$decodeExcusable,
									A3(
										author$project$Porting$withPresence,
										'icon',
										author$project$Activity$Activity$decodeIcon,
										A3(
											author$project$Porting$withPresence,
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
	return {$: 2, a: a};
};
var elm_community$intdict$IntDict$size = function (dict) {
	switch (dict.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		default:
			var i = dict.a;
			return i.cy;
	}
};
var elm_community$intdict$IntDict$inner = F3(
	function (p, l, r) {
		var _n0 = _Utils_Tuple2(l, r);
		if (!_n0.a.$) {
			var _n1 = _n0.a;
			return r;
		} else {
			if (!_n0.b.$) {
				var _n2 = _n0.b;
				return l;
			} else {
				return elm_community$intdict$IntDict$Inner(
					{
						o: l,
						s: p,
						p: r,
						cy: elm_community$intdict$IntDict$size(l) + elm_community$intdict$IntDict$size(r)
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
			elm$core$Bitwise$and(p.az),
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
		return {az: branchingBit, S: prefixBits};
	});
var elm_community$intdict$IntDict$Leaf = function (a) {
	return {$: 1, a: a};
};
var elm_community$intdict$IntDict$leaf = F2(
	function (k, v) {
		return elm_community$intdict$IntDict$Leaf(
			{dz: k, X: v});
	});
var elm_community$intdict$IntDict$prefixMatches = F2(
	function (p, n) {
		return _Utils_eq(
			n & elm_community$intdict$IntDict$higherBitMask(p.az),
			p.S);
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
			if (!_n1.$) {
				var v = _n1.a;
				return A2(elm_community$intdict$IntDict$leaf, key, v);
			} else {
				return elm_community$intdict$IntDict$empty;
			}
		};
		switch (dict.$) {
			case 0:
				return alteredNode(elm$core$Maybe$Nothing);
			case 1:
				var l = dict.a;
				return _Utils_eq(l.dz, key) ? alteredNode(
					elm$core$Maybe$Just(l.X)) : A2(
					join,
					_Utils_Tuple2(
						key,
						alteredNode(elm$core$Maybe$Nothing)),
					_Utils_Tuple2(l.dz, dict));
			default:
				var i = dict.a;
				return A2(elm_community$intdict$IntDict$prefixMatches, i.s, key) ? (A2(elm_community$intdict$IntDict$isBranchingBitSet, i.s, key) ? A3(
					elm_community$intdict$IntDict$inner,
					i.s,
					i.o,
					A3(elm_community$intdict$IntDict$update, key, alter, i.p)) : A3(
					elm_community$intdict$IntDict$inner,
					i.s,
					A3(elm_community$intdict$IntDict$update, key, alter, i.o),
					i.p)) : A2(
					join,
					_Utils_Tuple2(
						key,
						alteredNode(elm$core$Maybe$Nothing)),
					_Utils_Tuple2(i.s.S, dict));
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
		return {$: 0, a: a, b: b};
	});
var author$project$SmartTime$Moment$Moment = elm$core$Basics$identity;
var author$project$SmartTime$Moment$fromSmartInt = function (_int) {
	return author$project$SmartTime$Duration$fromInt(_int);
};
var author$project$Porting$decodeMoment = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$SmartTime$Moment$fromSmartInt, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var author$project$Porting$subtype2 = F5(
	function (tagger, fieldName1, subType1Decoder, fieldName2, subType2Decoder) {
		return A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$map2,
			tagger,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName1, subType1Decoder),
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName2, subType2Decoder));
	});
var author$project$Activity$Activity$decodeSwitch = A5(author$project$Porting$subtype2, author$project$Activity$Activity$Switch, 'Time', author$project$Porting$decodeMoment, 'Activity', author$project$ID$decode);
var author$project$AppData$AppData = F6(
	function (uid, errors, tasks, activities, timeline, todoist) {
		return {bH: activities, aj: errors, e8: tasks, cH: timeline, cK: todoist, cL: uid};
	});
var author$project$AppData$TodoistIntegrationData = F3(
	function (cache, parentProjectID, activityProjectIDs) {
		return {bI: activityProjectIDs, bN: cache, cf: parentProjectID};
	});
var author$project$Incubator$Todoist$Cache = F4(
	function (nextSync, items, projects, pendingCommands) {
		return {P: items, ap: nextSync, by: pendingCommands, T: projects};
	});
var author$project$Incubator$Todoist$decodeIncrementalSyncToken = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Basics$identity, zwilias$json_decode_exploration$Json$Decode$Exploration$string);
var author$project$Incubator$Todoist$Item$Item = function (id) {
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
																		return {cV: assigned_by_uid, c5: checked, _: child_order, c6: children, aB: collapsed, bl: content, c8: date_added, bm: day_order, aD: due, dl: id, dn: in_history, dt: is_archived, bY: is_deleted, bx: parent_id, cp: priority, dN: project_id, dY: responsible_uid, ef: user_id};
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
var author$project$Incubator$Todoist$Item$Due = F5(
	function (date, timezone, string, lang, isRecurring) {
		return {c7: date, ds: isRecurring, dA: lang, d4: string, eb: timezone};
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$nullable = function (decoder) {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
		_List_fromArray(
			[
				zwilias$json_decode_exploration$Json$Decode$Exploration$null(elm$core$Maybe$Nothing),
				A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Maybe$Just, decoder)
			]));
};
var author$project$Incubator$Todoist$Item$decodeDue = A3(
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
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Incubator$Todoist$Item$Due))))));
var author$project$Incubator$Todoist$Item$Priority = elm$core$Basics$identity;
var author$project$Incubator$Todoist$Item$decodePriority = zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			4,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(1)),
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			3,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(2)),
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			2,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(3)),
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			1,
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(4))
		]));
var author$project$Porting$decodeBoolFromInt = zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
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
var zwilias$json_decode_exploration$Json$Decode$Exploration$value = function (json) {
	return A2(
		zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
		zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
		zwilias$json_decode_exploration$Json$Decode$Exploration$encode(json));
};
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
var author$project$Incubator$Todoist$Item$decodeItem = A2(
	author$project$Porting$optionalIgnored,
	'due_is_recurring',
	A2(
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
								A2(
									author$project$Porting$optionalIgnored,
									'indent',
									A3(
										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'date_added',
										zwilias$json_decode_exploration$Json$Decode$Exploration$string,
										A4(
											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
											'is_archived',
											author$project$Porting$decodeBoolFromInt,
											false,
											A3(
												zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'is_deleted',
												author$project$Porting$decodeBoolFromInt,
												A3(
													zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'in_history',
													author$project$Porting$decodeBoolFromInt,
													A3(
														zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
														'checked',
														author$project$Porting$decodeBoolFromInt,
														A3(
															zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
															'responsible_uid',
															zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
															A4(
																zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																'assigned_by_uid',
																zwilias$json_decode_exploration$Json$Decode$Exploration$int,
																0,
																A2(
																	author$project$Porting$optionalIgnored,
																	'labels',
																	A4(
																		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																		'children',
																		zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
																		_List_Nil,
																		A3(
																			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																			'collapsed',
																			author$project$Porting$decodeBoolFromInt,
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
																							author$project$Incubator$Todoist$Item$decodePriority,
																							A3(
																								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																								'due',
																								zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$Incubator$Todoist$Item$decodeDue),
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
																												zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Incubator$Todoist$Item$Item)))))))))))))))))))))))))))));
var author$project$Incubator$Todoist$Project$Project = function (id) {
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
												return {_: child_order, aB: collapsed, bk: color, dl: id, $7: inbox_project, dt: is_archived, bY: is_deleted, br: is_favorite, bu: name, bx: parent_id, d0: shared, d8: team_inbox};
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
var author$project$Incubator$Todoist$Project$decodeProject = A2(
	author$project$Porting$optionalIgnored,
	'has_more_notes',
	A2(
		author$project$Porting$optionalIgnored,
		'legacy_id',
		A2(
			author$project$Porting$optionalIgnored,
			'legacy_parent_id',
			A4(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
				'team_inbox',
				zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
				false,
				A4(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
					'inbox_project',
					zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
					false,
					A3(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
						'is_favorite',
						author$project$Porting$decodeBoolFromInt,
						A3(
							zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
							'is_archived',
							author$project$Porting$decodeBoolFromInt,
							A3(
								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
								'is_deleted',
								author$project$Porting$decodeBoolFromInt,
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
											A3(
												zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'parent_id',
												zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
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
															zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Incubator$Todoist$Project$Project))))))))))))))));
var author$project$Porting$decodeIntDict = function (valueDecoder) {
	return A2(
		zwilias$json_decode_exploration$Json$Decode$Exploration$map,
		elm_community$intdict$IntDict$fromList,
		zwilias$json_decode_exploration$Json$Decode$Exploration$list(
			A2(author$project$Porting$decodeTuple2, zwilias$json_decode_exploration$Json$Decode$Exploration$int, valueDecoder)));
};
var author$project$Incubator$Todoist$decodeCache = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'pendingCommands',
	zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$string),
	A3(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'projects',
		author$project$Porting$decodeIntDict(author$project$Incubator$Todoist$Project$decodeProject),
		A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'items',
			author$project$Porting$decodeIntDict(author$project$Incubator$Todoist$Item$decodeItem),
			A4(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
				'nextSync',
				author$project$Incubator$Todoist$decodeIncrementalSyncToken,
				author$project$Incubator$Todoist$emptyCache.ap,
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Incubator$Todoist$Cache)))));
var author$project$AppData$decodeTodoistIntegrationData = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'activityProjectIDs',
	author$project$Porting$decodeIntDict(author$project$ID$decode),
	A3(
		author$project$Porting$withPresence,
		'parentProjectID',
		zwilias$json_decode_exploration$Json$Decode$Exploration$int,
		A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'cache',
			author$project$Incubator$Todoist$decodeCache,
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$AppData$TodoistIntegrationData))));
var author$project$Porting$decodeDuration = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$SmartTime$Duration$fromInt, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var author$project$Task$Progress$Percent = {$: 2};
var author$project$Task$Progress$progressFromFloat = function (_float) {
	return _Utils_Tuple2(
		elm$core$Basics$round(_float),
		author$project$Task$Progress$Percent);
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$TNumber = {$: 3};
var zwilias$json_decode_exploration$Json$Decode$Exploration$float = function (json) {
	if (json.$ === 1) {
		var val = json.b;
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$ok,
			zwilias$json_decode_exploration$Json$Decode$Exploration$markUsed(json),
			val);
	} else {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TNumber, json);
	}
};
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
																return {ek: activity, bQ: completion, et: deadline, a2: history, dl: id, eG: importance, eN: maxEffort, dC: minEffort, ce: parent, cl: plannedFinish, cm: plannedStart, cn: predictedEffort, cv: relevanceEnds, cw: relevanceStarts, e7: tags, ba: title};
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
var author$project$Porting$customDecoder = F2(
	function (primitiveDecoder, customDecoderFunction) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (a) {
				var _n0 = customDecoderFunction(a);
				if (!_n0.$) {
					var b = _n0.a;
					return zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(b);
				} else {
					var err = _n0.a;
					return zwilias$json_decode_exploration$Json$Decode$Exploration$fail(err);
				}
			},
			primitiveDecoder);
	});
var author$project$ParserExtra$problemToString = function (p) {
	switch (p.$) {
		case 0:
			var s = p.a;
			return 'expecting \'' + (s + '\'');
		case 1:
			return 'expecting int';
		case 2:
			return 'expecting hex';
		case 3:
			return 'expecting octal';
		case 4:
			return 'expecting binary';
		case 5:
			return 'expecting float';
		case 6:
			return 'expecting number';
		case 7:
			return 'expecting variable';
		case 8:
			var s = p.a;
			return 'expecting symbol \'' + (s + '\'');
		case 9:
			var s = p.a;
			return 'expecting keyword \'' + (s + '\'');
		case 10:
			return 'expecting end';
		case 11:
			return 'unexpected char';
		case 12:
			var s = p.a;
			return 'Problem parsing: ' + s;
		default:
			return 'bad repeat';
	}
};
var author$project$ParserExtra$deadEndToString = function (deadend) {
	return author$project$ParserExtra$problemToString(deadend.eX) + (' at row ' + (elm$core$String$fromInt(deadend.e$) + (', col ' + elm$core$String$fromInt(deadend.er))));
};
var elm$core$String$concat = function (strings) {
	return A2(elm$core$String$join, '', strings);
};
var author$project$ParserExtra$deadEndsToString = function (deadEnds) {
	return elm$core$String$concat(
		A2(
			elm$core$List$intersperse,
			'; ',
			A2(elm$core$List$map, author$project$ParserExtra$deadEndToString, deadEnds)));
};
var author$project$ParserExtra$realDeadEndsToString = author$project$ParserExtra$deadEndsToString;
var author$project$SmartTime$Human$Calendar$CalendarDate = elm$core$Basics$identity;
var author$project$SmartTime$Human$Calendar$Month$dayToInt = function (_n0) {
	var day = _n0;
	return day;
};
var elm$core$Basics$modBy = _Basics_modBy;
var elm$core$Basics$not = _Basics_not;
var author$project$SmartTime$Human$Calendar$Year$isLeapYear = function (_n0) {
	var _int = _n0;
	return (!A2(elm$core$Basics$modBy, 4, _int)) && ((!A2(elm$core$Basics$modBy, 400, _int)) || (!(!A2(elm$core$Basics$modBy, 100, _int))));
};
var author$project$SmartTime$Human$Calendar$Month$daysBefore = F2(
	function (givenYear, m) {
		var leapDays = author$project$SmartTime$Human$Calendar$Year$isLeapYear(givenYear) ? 1 : 0;
		switch (m) {
			case 0:
				return 0;
			case 1:
				return 31;
			case 2:
				return 59 + leapDays;
			case 3:
				return 90 + leapDays;
			case 4:
				return 120 + leapDays;
			case 5:
				return 151 + leapDays;
			case 6:
				return 181 + leapDays;
			case 7:
				return 212 + leapDays;
			case 8:
				return 243 + leapDays;
			case 9:
				return 273 + leapDays;
			case 10:
				return 304 + leapDays;
			default:
				return 334 + leapDays;
		}
	});
var author$project$SmartTime$Human$Calendar$Year$daysBefore = function (_n0) {
	var givenYearInt = _n0;
	var yearFromZero = givenYearInt - 1;
	var leapYears = (((yearFromZero / 4) | 0) - ((yearFromZero / 100) | 0)) + ((yearFromZero / 400) | 0);
	return (365 * yearFromZero) + leapYears;
};
var author$project$SmartTime$Human$Calendar$fromPartsTrusted = function (given) {
	return (author$project$SmartTime$Human$Calendar$Year$daysBefore(given.t) + A2(author$project$SmartTime$Human$Calendar$Month$daysBefore, given.t, given.x)) + author$project$SmartTime$Human$Calendar$Month$dayToInt(given.y);
};
var author$project$SmartTime$Human$Calendar$Month$Feb = 1;
var author$project$SmartTime$Human$Calendar$Month$DayOfMonth = elm$core$Basics$identity;
var author$project$SmartTime$Human$Calendar$Month$lastDay = F2(
	function (givenYear, givenMonth) {
		switch (givenMonth) {
			case 0:
				return 31;
			case 1:
				return author$project$SmartTime$Human$Calendar$Year$isLeapYear(givenYear) ? 29 : 28;
			case 2:
				return 31;
			case 3:
				return 30;
			case 4:
				return 31;
			case 5:
				return 30;
			case 6:
				return 31;
			case 7:
				return 31;
			case 8:
				return 30;
			case 9:
				return 31;
			case 10:
				return 30;
			default:
				return 31;
		}
	});
var elm$core$Basics$compare = _Utils_compare;
var author$project$SmartTime$Human$Calendar$Month$dayOfMonthValidFor = F3(
	function (givenYear, givenMonth, day) {
		var maxValidDay = author$project$SmartTime$Human$Calendar$Month$dayToInt(
			A2(author$project$SmartTime$Human$Calendar$Month$lastDay, givenYear, givenMonth));
		return ((day > 0) && (A2(elm$core$Basics$compare, day, maxValidDay) !== 2)) ? elm$core$Maybe$Just(day) : elm$core$Maybe$Nothing;
	});
var author$project$SmartTime$Human$Calendar$Month$length = F2(
	function (givenYear, m) {
		switch (m) {
			case 0:
				return 31;
			case 1:
				return author$project$SmartTime$Human$Calendar$Year$isLeapYear(givenYear) ? 29 : 28;
			case 2:
				return 31;
			case 3:
				return 30;
			case 4:
				return 31;
			case 5:
				return 30;
			case 6:
				return 31;
			case 7:
				return 31;
			case 8:
				return 30;
			case 9:
				return 31;
			case 10:
				return 30;
			default:
				return 31;
		}
	});
var author$project$SmartTime$Human$Calendar$Month$toName = function (m) {
	switch (m) {
		case 0:
			return 'January';
		case 1:
			return 'February';
		case 2:
			return 'March';
		case 3:
			return 'April';
		case 4:
			return 'May';
		case 5:
			return 'June';
		case 6:
			return 'July';
		case 7:
			return 'August';
		case 8:
			return 'September';
		case 9:
			return 'October';
		case 10:
			return 'November';
		default:
			return 'December';
	}
};
var author$project$SmartTime$Human$Calendar$Year$isBeforeCommonEra = function (_n0) {
	var y = _n0;
	return y <= 0;
};
var author$project$SmartTime$Human$Calendar$Year$toBCEYear = function (_n0) {
	var negativeYear = _n0;
	return (-negativeYear) + 1;
};
var author$project$SmartTime$Human$Calendar$Year$toString = function (year) {
	var yearInt = year;
	return author$project$SmartTime$Human$Calendar$Year$isBeforeCommonEra(year) ? (elm$core$String$fromInt(
		author$project$SmartTime$Human$Calendar$Year$toBCEYear(year)) + ' BCE') : elm$core$String$fromInt(yearInt);
};
var author$project$SmartTime$Human$Calendar$fromParts = function (given) {
	var _n0 = given.y;
	var dayInt = _n0;
	var _n1 = A3(author$project$SmartTime$Human$Calendar$Month$dayOfMonthValidFor, given.t, given.x, dayInt);
	if (!_n1.$) {
		return elm$core$Result$Ok(
			author$project$SmartTime$Human$Calendar$fromPartsTrusted(given));
	} else {
		var dayString = elm$core$String$fromInt(dayInt);
		var _n2 = given.y;
		var rawDay = _n2;
		return (dayInt < 1) ? elm$core$Result$Err('You gave me a DayOfMonth of ' + (dayString + '. Non-positive values for DayOfMonth are never valid! The day should be between 1 and 31.')) : ((dayInt > 31) ? elm$core$Result$Err('You gave me a DayOfMonth of ' + (dayString + '. No months have more than 31 days!')) : (((given.x === 1) && ((dayInt === 29) && (!author$project$SmartTime$Human$Calendar$Year$isLeapYear(given.t)))) ? elm$core$Result$Err(
			'Sorry, but ' + (author$project$SmartTime$Human$Calendar$Year$toString(given.t) + ' isn\'t a leap year, so that February doesn\'t have 29 days!')) : ((_Utils_cmp(
			dayInt,
			A2(author$project$SmartTime$Human$Calendar$Month$length, given.t, given.x)) > 0) ? elm$core$Result$Err(
			'You gave me a DayOfMonth of ' + (dayString + (', but ' + (author$project$SmartTime$Human$Calendar$Month$toName(given.x) + (' only has ' + (elm$core$String$fromInt(
				A2(author$project$SmartTime$Human$Calendar$Month$length, given.t, given.x)) + ' days!')))))) : elm$core$Result$Err('The date was invalid, but I\'m not sure why. Please report this issue!'))));
	}
};
var author$project$SmartTime$Human$Calendar$Parts = F3(
	function (year, month, day) {
		return {y: day, x: month, t: year};
	});
var elm$parser$Parser$Problem = function (a) {
	return {$: 12, a: a};
};
var elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$parser$Parser$Advanced$Parser = elm$core$Basics$identity;
var elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {er: col, es: contextStack, eX: problem, e$: row};
	});
var elm$parser$Parser$Advanced$Empty = {$: 0};
var elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			elm$parser$Parser$Advanced$AddRight,
			elm$parser$Parser$Advanced$Empty,
			A4(elm$parser$Parser$Advanced$DeadEnd, s.e$, s.er, x, s.r));
	});
var elm$parser$Parser$Advanced$problem = function (x) {
	return function (s) {
		return A2(
			elm$parser$Parser$Advanced$Bad,
			false,
			A2(elm$parser$Parser$Advanced$fromState, s, x));
	};
};
var elm$parser$Parser$problem = function (msg) {
	return elm$parser$Parser$Advanced$problem(
		elm$parser$Parser$Problem(msg));
};
var author$project$ParserExtra$impossibleIntFailure = elm$parser$Parser$problem('This should be impossible: a string of digits (verified with Char.isDigit) could not be converted to a valid `Int` (with String.fromInt).');
var elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return elm$core$Maybe$Just(
				f(value));
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm$core$String$toInt = _String_toInt;
var elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm$parser$Parser$Advanced$succeed = function (a) {
	return function (s) {
		return A3(elm$parser$Parser$Advanced$Good, false, a, s);
	};
};
var elm$parser$Parser$succeed = elm$parser$Parser$Advanced$succeed;
var author$project$ParserExtra$digitStringToInt = function (numbers) {
	return A2(
		elm$core$Maybe$withDefault,
		author$project$ParserExtra$impossibleIntFailure,
		A2(
			elm$core$Maybe$map,
			elm$parser$Parser$succeed,
			elm$core$String$toInt(numbers)));
};
var elm$parser$Parser$Advanced$andThen = F2(
	function (callback, _n0) {
		var parseA = _n0;
		return function (s0) {
			var _n1 = parseA(s0);
			if (_n1.$ === 1) {
				var p = _n1.a;
				var x = _n1.b;
				return A2(elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p1 = _n1.a;
				var a = _n1.b;
				var s1 = _n1.c;
				var _n2 = callback(a);
				var parseB = _n2;
				var _n3 = parseB(s1);
				if (_n3.$ === 1) {
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
		};
	});
var elm$parser$Parser$andThen = elm$parser$Parser$Advanced$andThen;
var elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var elm$parser$Parser$Advanced$chompWhileHelp = F5(
	function (isGood, offset, row, col, s0) {
		chompWhileHelp:
		while (true) {
			var newOffset = A3(elm$parser$Parser$Advanced$isSubChar, isGood, offset, s0.k);
			if (_Utils_eq(newOffset, -1)) {
				return A3(
					elm$parser$Parser$Advanced$Good,
					_Utils_cmp(s0.l, offset) < 0,
					0,
					{er: col, r: s0.r, u: s0.u, l: offset, e$: row, k: s0.k});
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
	return function (s) {
		return A5(elm$parser$Parser$Advanced$chompWhileHelp, isGood, s.l, s.e$, s.er, s);
	};
};
var elm$parser$Parser$chompWhile = elm$parser$Parser$Advanced$chompWhile;
var elm$core$String$slice = _String_slice;
var elm$parser$Parser$Advanced$mapChompedString = F2(
	function (func, _n0) {
		var parse = _n0;
		return function (s0) {
			var _n1 = parse(s0);
			if (_n1.$ === 1) {
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
						A3(elm$core$String$slice, s0.l, s1.l, s0.k),
						a),
					s1);
			}
		};
	});
var elm$parser$Parser$Advanced$getChompedString = function (parser) {
	return A2(elm$parser$Parser$Advanced$mapChompedString, elm$core$Basics$always, parser);
};
var elm$parser$Parser$getChompedString = elm$parser$Parser$Advanced$getChompedString;
var author$project$ParserExtra$paddedInt = A2(
	elm$parser$Parser$andThen,
	author$project$ParserExtra$digitStringToInt,
	elm$parser$Parser$getChompedString(
		elm$parser$Parser$chompWhile(elm$core$Char$isDigit)));
var elm$parser$Parser$Advanced$map = F2(
	function (func, _n0) {
		var parse = _n0;
		return function (s0) {
			var _n1 = parse(s0);
			if (!_n1.$) {
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
		};
	});
var elm$parser$Parser$map = elm$parser$Parser$Advanced$map;
var author$project$SmartTime$Human$Calendar$Month$parseDayOfMonth = A2(elm$parser$Parser$map, elm$core$Basics$identity, author$project$ParserExtra$paddedInt);
var author$project$SmartTime$Human$Calendar$Month$Apr = 3;
var author$project$SmartTime$Human$Calendar$Month$Aug = 7;
var author$project$SmartTime$Human$Calendar$Month$Dec = 11;
var author$project$SmartTime$Human$Calendar$Month$Jan = 0;
var author$project$SmartTime$Human$Calendar$Month$Jul = 6;
var author$project$SmartTime$Human$Calendar$Month$Jun = 5;
var author$project$SmartTime$Human$Calendar$Month$Mar = 2;
var author$project$SmartTime$Human$Calendar$Month$May = 4;
var author$project$SmartTime$Human$Calendar$Month$Nov = 10;
var author$project$SmartTime$Human$Calendar$Month$Oct = 9;
var author$project$SmartTime$Human$Calendar$Month$Sep = 8;
var author$project$SmartTime$Human$Calendar$Month$fromInt = function (n) {
	var _n0 = A2(elm$core$Basics$max, 1, n);
	switch (_n0) {
		case 1:
			return 0;
		case 2:
			return 1;
		case 3:
			return 2;
		case 4:
			return 3;
		case 5:
			return 4;
		case 6:
			return 5;
		case 7:
			return 6;
		case 8:
			return 7;
		case 9:
			return 8;
		case 10:
			return 9;
		case 11:
			return 10;
		default:
			return 11;
	}
};
var elm$core$Basics$ge = _Utils_ge;
var author$project$SmartTime$Human$Calendar$Month$parseMonthInt = function () {
	var checkMonth = function (givenInt) {
		return ((givenInt >= 1) && (givenInt <= 12)) ? elm$parser$Parser$succeed(
			author$project$SmartTime$Human$Calendar$Month$fromInt(givenInt)) : elm$parser$Parser$problem(
			'A month number should be from 1 to 12, but I got ' + (elm$core$String$fromInt(givenInt) + ' instead?'));
	};
	return A2(elm$parser$Parser$andThen, checkMonth, author$project$ParserExtra$paddedInt);
}();
var elm$core$String$length = _String_length;
var author$project$ParserExtra$strictPaddedInt = function (minLength) {
	var checkSize = function (digits) {
		return (_Utils_cmp(
			elm$core$String$length(digits),
			minLength) > -1) ? elm$parser$Parser$succeed(digits) : elm$parser$Parser$problem(
			'Found number: ' + (digits + (' but it was not padded to a minimum of ' + (elm$core$String$fromInt(minLength) + ' digits long.'))));
	};
	return A2(
		elm$parser$Parser$andThen,
		author$project$ParserExtra$digitStringToInt,
		A2(
			elm$parser$Parser$andThen,
			checkSize,
			elm$parser$Parser$getChompedString(
				elm$parser$Parser$chompWhile(elm$core$Char$isDigit))));
};
var author$project$SmartTime$Human$Calendar$Year$Year = elm$core$Basics$identity;
var author$project$SmartTime$Human$Calendar$Year$parse4DigitYear = function () {
	var toYearNum = function (num) {
		return elm$parser$Parser$succeed(num);
	};
	return A2(
		elm$parser$Parser$andThen,
		toYearNum,
		author$project$ParserExtra$strictPaddedInt(4));
}();
var elm$parser$Parser$Advanced$backtrackable = function (_n0) {
	var parse = _n0;
	return function (s0) {
		var _n1 = parse(s0);
		if (_n1.$ === 1) {
			var x = _n1.b;
			return A2(elm$parser$Parser$Advanced$Bad, false, x);
		} else {
			var a = _n1.b;
			var s1 = _n1.c;
			return A3(elm$parser$Parser$Advanced$Good, false, a, s1);
		}
	};
};
var elm$parser$Parser$backtrackable = elm$parser$Parser$Advanced$backtrackable;
var elm$parser$Parser$Advanced$map2 = F3(
	function (func, _n0, _n1) {
		var parseA = _n0;
		var parseB = _n1;
		return function (s0) {
			var _n2 = parseA(s0);
			if (_n2.$ === 1) {
				var p = _n2.a;
				var x = _n2.b;
				return A2(elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p1 = _n2.a;
				var a = _n2.b;
				var s1 = _n2.c;
				var _n3 = parseB(s1);
				if (_n3.$ === 1) {
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
		};
	});
var elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3(elm$parser$Parser$Advanced$map2, elm$core$Basics$always, keepParser, ignoreParser);
	});
var elm$parser$Parser$ignorer = elm$parser$Parser$Advanced$ignorer;
var elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3(elm$parser$Parser$Advanced$map2, elm$core$Basics$apL, parseFunc, parseArg);
	});
var elm$parser$Parser$keeper = elm$parser$Parser$Advanced$keeper;
var elm$parser$Parser$Advanced$spaces = elm$parser$Parser$Advanced$chompWhile(
	function (c) {
		return (c === ' ') || ((c === '\n') || (c === '\r'));
	});
var elm$parser$Parser$spaces = elm$parser$Parser$Advanced$spaces;
var elm$parser$Parser$ExpectingSymbol = function (a) {
	return {$: 8, a: a};
};
var elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var elm$parser$Parser$Advanced$token = function (_n0) {
	var str = _n0.a;
	var expecting = _n0.b;
	var progress = !elm$core$String$isEmpty(str);
	return function (s) {
		var _n1 = A5(elm$parser$Parser$Advanced$isSubString, str, s.l, s.e$, s.er, s.k);
		var newOffset = _n1.a;
		var newRow = _n1.b;
		var newCol = _n1.c;
		return _Utils_eq(newOffset, -1) ? A2(
			elm$parser$Parser$Advanced$Bad,
			false,
			A2(elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
			elm$parser$Parser$Advanced$Good,
			progress,
			0,
			{er: newCol, r: s.r, u: s.u, l: newOffset, e$: newRow, k: s.k});
	};
};
var elm$parser$Parser$Advanced$symbol = elm$parser$Parser$Advanced$token;
var elm$parser$Parser$symbol = function (str) {
	return elm$parser$Parser$Advanced$symbol(
		A2(
			elm$parser$Parser$Advanced$Token,
			str,
			elm$parser$Parser$ExpectingSymbol(str)));
};
var author$project$SmartTime$Human$Calendar$separatedYMD = function (separator) {
	return A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$keeper,
			A2(
				elm$parser$Parser$keeper,
				A2(
					elm$parser$Parser$ignorer,
					elm$parser$Parser$succeed(author$project$SmartTime$Human$Calendar$Parts),
					elm$parser$Parser$spaces),
				A2(
					elm$parser$Parser$ignorer,
					elm$parser$Parser$backtrackable(author$project$SmartTime$Human$Calendar$Year$parse4DigitYear),
					elm$parser$Parser$symbol(separator))),
			A2(
				elm$parser$Parser$ignorer,
				author$project$SmartTime$Human$Calendar$Month$parseMonthInt,
				elm$parser$Parser$symbol(separator))),
		author$project$SmartTime$Human$Calendar$Month$parseDayOfMonth);
};
var elm$core$Result$andThen = F2(
	function (callback, result) {
		if (!result.$) {
			var value = result.a;
			return callback(value);
		} else {
			var msg = result.a;
			return elm$core$Result$Err(msg);
		}
	});
var elm$core$Result$mapError = F2(
	function (f, result) {
		if (!result.$) {
			var v = result.a;
			return elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return elm$core$Result$Err(
				f(e));
		}
	});
var elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2(elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a;
				var remainingParsers = parsers.b;
				var _n1 = parse(s0);
				if (!_n1.$) {
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
	return function (s) {
		return A3(elm$parser$Parser$Advanced$oneOfHelp, s, elm$parser$Parser$Advanced$Empty, parsers);
	};
};
var elm$parser$Parser$oneOf = elm$parser$Parser$Advanced$oneOf;
var elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {er: col, eX: problem, e$: row};
	});
var elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3(elm$parser$Parser$DeadEnd, p.e$, p.er, p.eX);
};
var elm$parser$Parser$Advanced$bagToList = F2(
	function (bag, list) {
		bagToList:
		while (true) {
			switch (bag.$) {
				case 0:
					return list;
				case 1:
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
		var parse = _n0;
		var _n1 = parse(
			{er: 1, r: _List_Nil, u: 1, l: 0, e$: 1, k: src});
		if (!_n1.$) {
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
		if (!_n0.$) {
			var a = _n0.a;
			return elm$core$Result$Ok(a);
		} else {
			var problems = _n0.a;
			return elm$core$Result$Err(
				A2(elm$core$List$map, elm$parser$Parser$problemToDeadEnd, problems));
		}
	});
var author$project$SmartTime$Human$Calendar$fromNumberString = function (input) {
	var parserResult = A2(
		elm$parser$Parser$run,
		elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					author$project$SmartTime$Human$Calendar$separatedYMD('-'),
					author$project$SmartTime$Human$Calendar$separatedYMD('/'),
					author$project$SmartTime$Human$Calendar$separatedYMD('.'),
					author$project$SmartTime$Human$Calendar$separatedYMD(' ')
				])),
		input);
	var stringErrorResult = A2(elm$core$Result$mapError, author$project$ParserExtra$realDeadEndsToString, parserResult);
	return A2(elm$core$Result$andThen, author$project$SmartTime$Human$Calendar$fromParts, stringErrorResult);
};
var author$project$SmartTime$Human$Moment$DateOnly = function (a) {
	return {$: 2, a: a};
};
var author$project$SmartTime$Human$Moment$Floating = function (a) {
	return {$: 1, a: a};
};
var author$project$SmartTime$Human$Moment$Global = function (a) {
	return {$: 0, a: a};
};
var author$project$SmartTime$Duration$aDay = author$project$SmartTime$Duration$dayLength;
var author$project$SmartTime$Duration$aMillisecond = author$project$SmartTime$Duration$millisecondLength;
var author$project$SmartTime$Duration$aMinute = author$project$SmartTime$Duration$minuteLength;
var author$project$SmartTime$Duration$aSecond = author$project$SmartTime$Duration$secondLength;
var author$project$SmartTime$Duration$anHour = author$project$SmartTime$Duration$hourLength;
var author$project$SmartTime$Duration$scale = F2(
	function (_n0, scalar) {
		var dur = _n0;
		return elm$core$Basics$round(dur * scalar);
	});
var author$project$SmartTime$Human$Duration$toDuration = function (humanDuration) {
	switch (humanDuration.$) {
		case 4:
			var days = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aDay, days);
		case 3:
			var hours = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$anHour, hours);
		case 2:
			var minutes = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aMinute, minutes);
		case 1:
			var seconds = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aSecond, seconds);
		default:
			var milliseconds = humanDuration.a;
			return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aMillisecond, milliseconds);
	}
};
var author$project$SmartTime$Human$Duration$normalize = function (human) {
	return author$project$SmartTime$Duration$inMs(
		author$project$SmartTime$Human$Duration$toDuration(human));
};
var elm$core$List$sum = function (numbers) {
	return A3(elm$core$List$foldl, elm$core$Basics$add, 0, numbers);
};
var author$project$SmartTime$Human$Duration$build = function (list) {
	return author$project$SmartTime$Duration$fromInt(
		elm$core$List$sum(
			A2(elm$core$List$map, author$project$SmartTime$Human$Duration$normalize, list)));
};
var author$project$SmartTime$Human$Clock$clock = F4(
	function (hh, mm, ss, ms) {
		return author$project$SmartTime$Human$Duration$build(
			_List_fromArray(
				[
					author$project$SmartTime$Human$Duration$Hours(hh),
					author$project$SmartTime$Human$Duration$Minutes(mm),
					author$project$SmartTime$Human$Duration$Seconds(ss),
					author$project$SmartTime$Human$Duration$Milliseconds(ms)
				]));
	});
var elm$parser$Parser$ExpectingFloat = {$: 5};
var elm$parser$Parser$Advanced$consumeBase = _Parser_consumeBase;
var elm$parser$Parser$Advanced$consumeBase16 = _Parser_consumeBase16;
var elm$core$String$toFloat = _String_toFloat;
var elm$parser$Parser$Advanced$bumpOffset = F2(
	function (newOffset, s) {
		return {er: s.er + (newOffset - s.l), r: s.r, u: s.u, l: newOffset, e$: s.e$, k: s.k};
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
var elm$parser$Parser$Advanced$finalizeInt = F5(
	function (invalid, handler, startOffset, _n0, s) {
		var endOffset = _n0.a;
		var n = _n0.b;
		if (handler.$ === 1) {
			var x = handler.a;
			return A2(
				elm$parser$Parser$Advanced$Bad,
				true,
				A2(elm$parser$Parser$Advanced$fromState, s, x));
		} else {
			var toValue = handler.a;
			return _Utils_eq(startOffset, endOffset) ? A2(
				elm$parser$Parser$Advanced$Bad,
				_Utils_cmp(s.l, startOffset) < 0,
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
		var floatOffset = A2(elm$parser$Parser$Advanced$consumeDotAndExp, intOffset, s.k);
		if (floatOffset < 0) {
			return A2(
				elm$parser$Parser$Advanced$Bad,
				true,
				A4(elm$parser$Parser$Advanced$fromInfo, s.e$, s.er - (floatOffset + s.l), invalid, s.r));
		} else {
			if (_Utils_eq(s.l, floatOffset)) {
				return A2(
					elm$parser$Parser$Advanced$Bad,
					false,
					A2(elm$parser$Parser$Advanced$fromState, s, expecting));
			} else {
				if (_Utils_eq(intOffset, floatOffset)) {
					return A5(elm$parser$Parser$Advanced$finalizeInt, invalid, intSettings, s.l, intPair, s);
				} else {
					if (floatSettings.$ === 1) {
						var x = floatSettings.a;
						return A2(
							elm$parser$Parser$Advanced$Bad,
							true,
							A2(elm$parser$Parser$Advanced$fromState, s, invalid));
					} else {
						var toValue = floatSettings.a;
						var _n1 = elm$core$String$toFloat(
							A3(elm$core$String$slice, s.l, floatOffset, s.k));
						if (_n1.$ === 1) {
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
	return function (s) {
		if (A3(elm$parser$Parser$Advanced$isAsciiCode, 48, s.l, s.k)) {
			var zeroOffset = s.l + 1;
			var baseOffset = zeroOffset + 1;
			return A3(elm$parser$Parser$Advanced$isAsciiCode, 120, zeroOffset, s.k) ? A5(
				elm$parser$Parser$Advanced$finalizeInt,
				c.eJ,
				c.di,
				baseOffset,
				A2(elm$parser$Parser$Advanced$consumeBase16, baseOffset, s.k),
				s) : (A3(elm$parser$Parser$Advanced$isAsciiCode, 111, zeroOffset, s.k) ? A5(
				elm$parser$Parser$Advanced$finalizeInt,
				c.eJ,
				c.dH,
				baseOffset,
				A3(elm$parser$Parser$Advanced$consumeBase, 8, baseOffset, s.k),
				s) : (A3(elm$parser$Parser$Advanced$isAsciiCode, 98, zeroOffset, s.k) ? A5(
				elm$parser$Parser$Advanced$finalizeInt,
				c.eJ,
				c.cZ,
				baseOffset,
				A3(elm$parser$Parser$Advanced$consumeBase, 2, baseOffset, s.k),
				s) : A6(
				elm$parser$Parser$Advanced$finalizeFloat,
				c.eJ,
				c.dd,
				c.dr,
				c.df,
				_Utils_Tuple2(zeroOffset, 0),
				s)));
		} else {
			return A6(
				elm$parser$Parser$Advanced$finalizeFloat,
				c.eJ,
				c.dd,
				c.dr,
				c.df,
				A3(elm$parser$Parser$Advanced$consumeBase, 10, s.l, s.k),
				s);
		}
	};
};
var elm$parser$Parser$Advanced$float = F2(
	function (expecting, invalid) {
		return elm$parser$Parser$Advanced$number(
			{
				cZ: elm$core$Result$Err(invalid),
				dd: expecting,
				df: elm$core$Result$Ok(elm$core$Basics$identity),
				di: elm$core$Result$Err(invalid),
				dr: elm$core$Result$Ok(elm$core$Basics$toFloat),
				eJ: invalid,
				dH: elm$core$Result$Err(invalid)
			});
	});
var elm$parser$Parser$float = A2(elm$parser$Parser$Advanced$float, elm$parser$Parser$ExpectingFloat, elm$parser$Parser$ExpectingFloat);
var author$project$SmartTime$Human$Clock$parseHMS = function () {
	var secsFracToMs = function (frac) {
		return elm$core$Basics$round(frac * 1000);
	};
	var decimalOptional = elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				elm$parser$Parser$float,
				elm$parser$Parser$succeed(0)
			]));
	return A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$keeper,
			A2(
				elm$parser$Parser$keeper,
				A2(
					elm$parser$Parser$keeper,
					elm$parser$Parser$succeed(author$project$SmartTime$Human$Clock$clock),
					A2(
						elm$parser$Parser$ignorer,
						elm$parser$Parser$backtrackable(author$project$ParserExtra$paddedInt),
						elm$parser$Parser$symbol(':'))),
				A2(
					elm$parser$Parser$ignorer,
					author$project$ParserExtra$paddedInt,
					elm$parser$Parser$symbol(':'))),
			author$project$ParserExtra$paddedInt),
		A2(elm$parser$Parser$map, secsFracToMs, decimalOptional));
}();
var author$project$SmartTime$Duration$add = F2(
	function (_n0, _n1) {
		var int1 = _n0;
		var int2 = _n1;
		return int1 + int2;
	});
var author$project$SmartTime$Human$Calendar$toRataDie = function (_n0) {
	var _int = _n0;
	return _int;
};
var author$project$SmartTime$Duration$subtract = F2(
	function (_n0, _n1) {
		var int1 = _n0;
		var int2 = _n1;
		return int1 - int2;
	});
var author$project$SmartTime$Moment$Earlier = 1;
var author$project$SmartTime$Moment$Coincident = 2;
var author$project$SmartTime$Moment$Later = 0;
var author$project$SmartTime$Moment$compare = F2(
	function (_n0, _n1) {
		var time1 = _n0;
		var time2 = _n1;
		var _n2 = A2(
			elm$core$Basics$compare,
			author$project$SmartTime$Duration$inMs(time1),
			author$project$SmartTime$Duration$inMs(time2));
		switch (_n2) {
			case 2:
				return 0;
			case 0:
				return 1;
			default:
				return 2;
		}
	});
var author$project$SmartTime$Human$Moment$searchRemainingZoneHistory = F3(
	function (moment, fallback, history) {
		searchRemainingZoneHistory:
		while (true) {
			if (!history.b) {
				return fallback;
			} else {
				var _n1 = history.a;
				var zoneChange = _n1.a;
				var offsetAtThatTime = _n1.b;
				var remainingHistory = history.b;
				if (A2(author$project$SmartTime$Moment$compare, moment, zoneChange) !== 1) {
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
var author$project$SmartTime$Human$Moment$getOffset = F2(
	function (referencePoint, zone) {
		return A3(author$project$SmartTime$Human$Moment$searchRemainingZoneHistory, referencePoint, zone.a0, zone.a2);
	});
var author$project$SmartTime$Moment$UTC = 0;
var author$project$SmartTime$Moment$commonEraStart = author$project$SmartTime$Duration$fromInt(0);
var author$project$SmartTime$Duration$fromMs = function (_float) {
	return elm$core$Basics$round(_float);
};
var author$project$SmartTime$Duration$fromSeconds = function (_float) {
	return elm$core$Basics$round(_float * author$project$SmartTime$Duration$secondLength);
};
var author$project$SmartTime$Moment$TAI = 1;
var author$project$SmartTime$Moment$nineteen00 = author$project$SmartTime$Duration$fromInt(0);
var elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var elm_community$list_extra$List$Extra$takeWhileRight = function (p) {
	var step = F2(
		function (x, _n0) {
			var xs = _n0.a;
			var free = _n0.b;
			return (p(x) && free) ? _Utils_Tuple2(
				A2(elm$core$List$cons, x, xs),
				true) : _Utils_Tuple2(xs, false);
		});
	return A2(
		elm$core$Basics$composeL,
		elm$core$Tuple$first,
		A2(
			elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, true)));
};
var author$project$SmartTime$Moment$linearFromUTC = function (momentAsDur) {
	return A2(
		author$project$SmartTime$Duration$add,
		momentAsDur,
		author$project$SmartTime$Moment$utcOffset(momentAsDur));
};
var author$project$SmartTime$Moment$moment = F3(
	function (timeScale, _n2, inputDuration) {
		var epochDur = _n2;
		var input = A2(author$project$SmartTime$Duration$add, inputDuration, epochDur);
		switch (timeScale) {
			case 1:
				return input;
			case 0:
				return author$project$SmartTime$Moment$linearFromUTC(input);
			case 2:
				return A2(
					author$project$SmartTime$Duration$add,
					input,
					author$project$SmartTime$Duration$fromSeconds(19));
			default:
				return A2(
					author$project$SmartTime$Duration$add,
					input,
					author$project$SmartTime$Duration$fromMs(32184));
		}
	});
var author$project$SmartTime$Moment$utcOffset = function (rawUTCMomentAsDur) {
	var ntpEpoch = author$project$SmartTime$Moment$nineteen00;
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
			author$project$SmartTime$Moment$moment,
			1,
			ntpEpoch,
			author$project$SmartTime$Duration$fromSeconds(num));
	};
	var fromTableItem = function (_n1) {
		var ntpTime = _n1.a;
		var leaps = _n1.b;
		return _Utils_Tuple2(
			fromNTPtime(ntpTime),
			author$project$SmartTime$Duration$fromSeconds(leaps));
	};
	var leapSeconds = A2(elm$core$List$map, fromTableItem, leapSecondsTable);
	var oldest = fromTableItem(
		_Utils_Tuple2(2272060800, 10));
	var fakeMoment = A3(author$project$SmartTime$Moment$moment, 1, author$project$SmartTime$Moment$commonEraStart, rawUTCMomentAsDur);
	var periodStartsEarlier = function (_n0) {
		var periodStartMoment = _n0.a;
		return A2(author$project$SmartTime$Moment$compare, periodStartMoment, fakeMoment) === 1;
	};
	var goBackThroughTime = A2(elm_community$list_extra$List$Extra$takeWhileRight, periodStartsEarlier, leapSeconds);
	var relevantPeriod = A2(
		elm$core$Maybe$withDefault,
		oldest,
		elm_community$list_extra$List$Extra$last(goBackThroughTime));
	var offsetAtThatTime = relevantPeriod.b;
	return offsetAtThatTime;
};
var author$project$SmartTime$Human$Moment$toTAIAndUnlocalize = F2(
	function (zone, localMomentDur) {
		var toMoment = function (duration) {
			return A3(author$project$SmartTime$Moment$moment, 0, author$project$SmartTime$Moment$commonEraStart, duration);
		};
		var zoneOffset = A2(
			author$project$SmartTime$Human$Moment$getOffset,
			toMoment(localMomentDur),
			zone);
		return toMoment(
			A2(author$project$SmartTime$Duration$subtract, localMomentDur, zoneOffset));
	});
var author$project$SmartTime$Human$Moment$fromDateAndTime = F3(
	function (zone, date, timeOfDay) {
		var woleDaysBefore = A2(
			author$project$SmartTime$Duration$scale,
			author$project$SmartTime$Duration$aDay,
			author$project$SmartTime$Human$Calendar$toRataDie(date));
		var total = A2(author$project$SmartTime$Duration$add, timeOfDay, woleDaysBefore);
		return A2(author$project$SmartTime$Human$Moment$toTAIAndUnlocalize, zone, total);
	});
var author$project$SmartTime$Duration$fromMinutes = function (_float) {
	return elm$core$Basics$round(_float * author$project$SmartTime$Duration$minuteLength);
};
var author$project$SmartTime$Human$Moment$utc = {
	a0: author$project$SmartTime$Duration$fromMinutes(0),
	a2: _List_Nil,
	bu: 'Universal'
};
var author$project$SmartTime$Human$Moment$fromStringHelper = F2(
	function (givenParser, input) {
		var parserResult = A2(elm$parser$Parser$run, givenParser, input);
		var withNiceErrors = A2(elm$core$Result$mapError, author$project$ParserExtra$realDeadEndsToString, parserResult);
		var combiner = F2(
			function (d, t) {
				return A3(author$project$SmartTime$Human$Moment$fromDateAndTime, author$project$SmartTime$Human$Moment$utc, d, t);
			});
		var fromAll = function (_n0) {
			var dateparts = _n0.a;
			var time = _n0.b;
			return A2(
				elm$core$Result$map,
				function (d) {
					return A2(combiner, d, time);
				},
				author$project$SmartTime$Human$Calendar$fromParts(dateparts));
		};
		return A2(elm$core$Result$andThen, fromAll, withNiceErrors);
	});
var elm$parser$Parser$ExpectingEnd = {$: 10};
var elm$parser$Parser$Advanced$end = function (x) {
	return function (s) {
		return _Utils_eq(
			elm$core$String$length(s.k),
			s.l) ? A3(elm$parser$Parser$Advanced$Good, false, 0, s) : A2(
			elm$parser$Parser$Advanced$Bad,
			false,
			A2(elm$parser$Parser$Advanced$fromState, s, x));
	};
};
var elm$parser$Parser$end = elm$parser$Parser$Advanced$end(elm$parser$Parser$ExpectingEnd);
var author$project$SmartTime$Human$Moment$fromStandardString = function (input) {
	var combinedParser = A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$keeper,
			elm$parser$Parser$succeed(elm$core$Tuple$pair),
			A2(
				elm$parser$Parser$ignorer,
				author$project$SmartTime$Human$Calendar$separatedYMD('-'),
				elm$parser$Parser$symbol('T'))),
		A2(
			elm$parser$Parser$ignorer,
			A2(
				elm$parser$Parser$ignorer,
				author$project$SmartTime$Human$Clock$parseHMS,
				elm$parser$Parser$symbol('Z')),
			elm$parser$Parser$end));
	return A2(author$project$SmartTime$Human$Moment$fromStringHelper, combinedParser, input);
};
var author$project$SmartTime$Human$Moment$fromStandardStringLoose = function (input) {
	var combinedParser = A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$keeper,
			elm$parser$Parser$succeed(elm$core$Tuple$pair),
			A2(
				elm$parser$Parser$ignorer,
				author$project$SmartTime$Human$Calendar$separatedYMD('-'),
				elm$parser$Parser$symbol('T'))),
		author$project$SmartTime$Human$Clock$parseHMS);
	return A2(author$project$SmartTime$Human$Moment$fromStringHelper, combinedParser, input);
};
var author$project$SmartTime$Duration$fromDays = function (_float) {
	return elm$core$Basics$round(_float * author$project$SmartTime$Duration$dayLength);
};
var author$project$SmartTime$Duration$inWholeDays = function (duration) {
	return (author$project$SmartTime$Duration$inMs(duration) / author$project$SmartTime$Duration$dayLength) | 0;
};
var author$project$SmartTime$Human$Calendar$fromRataDie = elm$core$Basics$identity;
var author$project$SmartTime$Moment$utcFromLinear = function (momentAsDur) {
	return A2(
		author$project$SmartTime$Duration$subtract,
		momentAsDur,
		author$project$SmartTime$Moment$utcOffset(momentAsDur));
};
var author$project$SmartTime$Moment$toInt = F3(
	function (_n0, timeScale, _n1) {
		var inputTAI = _n0;
		var epochDur = _n1;
		var newScale = function () {
			switch (timeScale) {
				case 1:
					return inputTAI;
				case 0:
					return author$project$SmartTime$Moment$utcFromLinear(inputTAI);
				case 2:
					return A2(
						author$project$SmartTime$Duration$subtract,
						inputTAI,
						author$project$SmartTime$Duration$fromSeconds(19));
				default:
					return A2(
						author$project$SmartTime$Duration$subtract,
						inputTAI,
						author$project$SmartTime$Duration$fromMs(32184));
			}
		}();
		return author$project$SmartTime$Duration$inMs(
			A2(author$project$SmartTime$Duration$subtract, newScale, epochDur));
	});
var author$project$SmartTime$Human$Moment$toUTCAndLocalize = F2(
	function (zone, moment) {
		var momentAsDur = author$project$SmartTime$Duration$fromInt(
			A3(author$project$SmartTime$Moment$toInt, moment, 0, author$project$SmartTime$Moment$commonEraStart));
		return A2(
			author$project$SmartTime$Duration$add,
			momentAsDur,
			A2(author$project$SmartTime$Human$Moment$getOffset, moment, zone));
	});
var author$project$SmartTime$Human$Moment$humanize = F2(
	function (zone, moment) {
		var localMomentDur = A2(author$project$SmartTime$Human$Moment$toUTCAndLocalize, zone, moment);
		var daysSinceEpoch = author$project$SmartTime$Duration$inWholeDays(localMomentDur);
		var remaining = A2(
			author$project$SmartTime$Duration$subtract,
			localMomentDur,
			author$project$SmartTime$Duration$fromDays(daysSinceEpoch));
		return _Utils_Tuple2(
			author$project$SmartTime$Human$Calendar$fromRataDie(daysSinceEpoch),
			remaining);
	});
var elm$core$String$contains = _String_contains;
var elm$core$String$endsWith = _String_endsWith;
var author$project$SmartTime$Human$Moment$fuzzyFromString = function (givenString) {
	return A2(elm$core$String$endsWith, 'Z', givenString) ? A2(
		elm$core$Result$map,
		author$project$SmartTime$Human$Moment$Global,
		author$project$SmartTime$Human$Moment$fromStandardString(givenString)) : (A2(elm$core$String$contains, 'T', givenString) ? A2(
		elm$core$Result$map,
		A2(
			elm$core$Basics$composeL,
			author$project$SmartTime$Human$Moment$Floating,
			author$project$SmartTime$Human$Moment$humanize(author$project$SmartTime$Human$Moment$utc)),
		author$project$SmartTime$Human$Moment$fromStandardStringLoose(givenString)) : A2(
		elm$core$Result$map,
		author$project$SmartTime$Human$Moment$DateOnly,
		author$project$SmartTime$Human$Calendar$fromNumberString(givenString)));
};
var author$project$Task$Task$decodeTaskMoment = A2(author$project$Porting$customDecoder, zwilias$json_decode_exploration$Json$Decode$Exploration$string, author$project$SmartTime$Human$Moment$fuzzyFromString);
var author$project$Task$Task$decodeTask = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'importance',
	zwilias$json_decode_exploration$Json$Decode$Exploration$float,
	A3(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
		'relevanceEnds',
		zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$Task$Task$decodeTaskMoment),
		A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
			'relevanceStarts',
			zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$Task$Task$decodeTaskMoment),
			A3(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'plannedFinish',
				zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$Task$Task$decodeTaskMoment),
				A3(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'plannedStart',
					zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$Task$Task$decodeTaskMoment),
					A3(
						zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
						'deadline',
						zwilias$json_decode_exploration$Json$Decode$Exploration$nullable(author$project$Task$Task$decodeTaskMoment),
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
	author$project$AppData$decodeTodoistIntegrationData,
	author$project$AppData$emptyTodoistIntegrationData,
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
var zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson = {$: 0};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Errors = function (a) {
	return {$: 1, a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$Success = function (a) {
	return {$: 3, a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$WithWarnings = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
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
		elm$json$Json$Decode$succeed(0));
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
var zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder = zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder();
zwilias$json_decode_exploration$Json$Decode$Exploration$cyclic$annotatedDecoder = function () {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder;
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$decode = elm$json$Json$Decode$decodeValue(zwilias$json_decode_exploration$Json$Decode$Exploration$annotatedDecoder);
var zwilias$json_decode_exploration$Json$Decode$Exploration$UnusedValue = function (a) {
	return {$: 0, a: a};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings = function (json) {
	_n0$8:
	while (true) {
		switch (json.$) {
			case 0:
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
			case 1:
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
			case 2:
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
			case 3:
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
			case 4:
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
		var decoderFn = _n0;
		var _n1 = zwilias$json_decode_exploration$Json$Decode$Exploration$decode(val);
		if (_n1.$ === 1) {
			return zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson;
		} else {
			var json = _n1.a;
			var _n2 = decoderFn(json);
			if (_n2.$ === 1) {
				var errors = _n2.a;
				return zwilias$json_decode_exploration$Json$Decode$Exploration$Errors(errors);
			} else {
				var acc = _n2.a;
				var _n3 = _Utils_ap(
					acc.z,
					zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(acc.C));
				if (!_n3.b) {
					return zwilias$json_decode_exploration$Json$Decode$Exploration$Success(acc.X);
				} else {
					var x = _n3.a;
					var xs = _n3.b;
					return A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$WithWarnings,
						A2(mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs),
						acc.X);
				}
			}
		}
	});
var zwilias$json_decode_exploration$Json$Decode$Exploration$decodeString = F2(
	function (decoder, jsonString) {
		var _n0 = A2(elm$json$Json$Decode$decodeString, elm$json$Json$Decode$value, jsonString);
		if (_n0.$ === 1) {
			return zwilias$json_decode_exploration$Json$Decode$Exploration$BadJson;
		} else {
			var json = _n0.a;
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue, decoder, json);
		}
	});
var author$project$Main$appDataFromJson = function (incomingJson) {
	return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$decodeString, author$project$AppData$decodeAppData, incomingJson);
};
var author$project$SmartTime$Duration$zero = 0;
var author$project$SmartTime$Moment$zero = author$project$SmartTime$Duration$zero;
var author$project$Environment$preInit = function (maybeKey) {
	return {dG: maybeKey, ea: author$project$SmartTime$Moment$zero, e9: author$project$SmartTime$Human$Moment$utc};
};
var elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			elm$core$String$slice,
			n,
			elm$core$String$length(string),
			string);
	});
var elm$core$String$startsWith = _String_startsWith;
var elm$url$Url$Http = 0;
var elm$url$Url$Https = 1;
var elm$core$String$indexes = _String_indexes;
var elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3(elm$core$String$slice, 0, n, string);
	});
var elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {eC: fragment, dj: host, dI: path, dK: port_, dR: protocol, cu: query};
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
					if (_n1.$ === 1) {
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
		0,
		A2(elm$core$String$dropLeft, 7, str)) : (A2(elm$core$String$startsWith, 'https://', str) ? A2(
		elm$url$Url$chompAfterProtocol,
		1,
		A2(elm$core$String$dropLeft, 8, str)) : elm$core$Maybe$Nothing);
};
var elm$url$Url$addPort = F2(
	function (maybePort, starter) {
		if (maybePort.$ === 1) {
			return starter;
		} else {
			var port_ = maybePort.a;
			return starter + (':' + elm$core$String$fromInt(port_));
		}
	});
var elm$url$Url$addPrefixed = F3(
	function (prefix, maybeSegment, starter) {
		if (maybeSegment.$ === 1) {
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
		var _n0 = url.dR;
		if (!_n0) {
			return 'http://';
		} else {
			return 'https://';
		}
	}();
	return A3(
		elm$url$Url$addPrefixed,
		'#',
		url.eC,
		A3(
			elm$url$Url$addPrefixed,
			'?',
			url.cu,
			_Utils_ap(
				A2(
					elm$url$Url$addPort,
					url.dK,
					_Utils_ap(http, url.dj)),
				url.dI)));
};
var author$project$Main$bypassFakeFragment = function (url) {
	var _n0 = A2(elm$core$Maybe$map, elm$core$String$uncons, url.eC);
	if (((!_n0.$) && (!_n0.a.$)) && ('/' === _n0.a.a.a)) {
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
				elm$url$Url$fromString(
					_Utils_ap(front, fakeFragment)));
		} else {
			return url;
		}
	} else {
		return url;
	}
};
var author$project$Main$TimeTracker = function (a) {
	return {$: 1, a: a};
};
var author$project$Main$ViewState = F2(
	function (primaryView, uid) {
		return {aP: primaryView, cL: uid};
	});
var author$project$TimeTracker$Normal = 0;
var author$project$TimeTracker$defaultView = 0;
var author$project$Main$defaultView = A2(
	author$project$Main$ViewState,
	author$project$Main$TimeTracker(author$project$TimeTracker$defaultView),
	0);
var author$project$Main$TaskList = function (a) {
	return {$: 0, a: a};
};
var author$project$Main$screenToViewState = function (screen) {
	return {aP: screen, cL: 0};
};
var author$project$TaskList$IncompleteTasksOnly = 1;
var author$project$TaskList$Normal = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm$url$Url$Parser$Parser = elm$core$Basics$identity;
var elm$url$Url$Parser$State = F5(
	function (visited, unvisited, params, frag, value) {
		return {al: frag, aq: params, ah: unvisited, X: value, au: visited};
	});
var elm$url$Url$Parser$mapState = F2(
	function (func, _n0) {
		var visited = _n0.au;
		var unvisited = _n0.ah;
		var params = _n0.aq;
		var frag = _n0.al;
		var value = _n0.X;
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
		var parseArg = _n0;
		return function (_n1) {
			var visited = _n1.au;
			var unvisited = _n1.ah;
			var params = _n1.aq;
			var frag = _n1.al;
			var value = _n1.X;
			return A2(
				elm$core$List$map,
				elm$url$Url$Parser$mapState(value),
				parseArg(
					A5(elm$url$Url$Parser$State, visited, unvisited, params, frag, subValue)));
		};
	});
var elm$url$Url$Parser$s = function (str) {
	return function (_n0) {
		var visited = _n0.au;
		var unvisited = _n0.ah;
		var params = _n0.aq;
		var frag = _n0.al;
		var value = _n0.X;
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
	};
};
var author$project$TaskList$routeView = A2(
	elm$url$Url$Parser$map,
	A3(
		author$project$TaskList$Normal,
		_List_fromArray(
			[1]),
		elm$core$Maybe$Nothing,
		''),
	elm$url$Url$Parser$s('tasks'));
var author$project$TimeTracker$routeView = A2(
	elm$url$Url$Parser$map,
	0,
	elm$url$Url$Parser$s('timetracker'));
var elm$url$Url$Parser$oneOf = function (parsers) {
	return function (state) {
		return A2(
			elm$core$List$concatMap,
			function (_n0) {
				var parser = _n0;
				return parser(state);
			},
			parsers);
	};
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
			var _n1 = state.ah;
			if (!_n1.b) {
				return elm$core$Maybe$Just(state.X);
			} else {
				if ((_n1.a === '') && (!_n1.b.b)) {
					return elm$core$Maybe$Just(state.X);
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
var elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var elm$core$Dict$empty = elm$core$Dict$RBEmpty_elm_builtin;
var elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _n1 = A2(elm$core$Basics$compare, targetKey, key);
				switch (_n1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
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
var elm$core$Dict$Black = 1;
var elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var elm$core$Dict$Red = 0;
var elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _n1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _n3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5(elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
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
					0,
					lK,
					lV,
					A5(elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5(elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, elm$core$Dict$RBEmpty_elm_builtin, elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _n1 = A2(elm$core$Basics$compare, key, nKey);
			switch (_n1) {
				case 0:
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3(elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
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
		if ((_n0.$ === -1) && (!_n0.a)) {
			var _n1 = _n0.a;
			var k = _n0.b;
			var v = _n0.c;
			var l = _n0.d;
			var r = _n0.e;
			return A5(elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _n0;
			return x;
		}
	});
var elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
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
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
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
				0,
				rlK,
				rlV,
				A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5(elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
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
			if (clr === 1) {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
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
				0,
				lK,
				lV,
				A5(elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
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
			if (clr === 1) {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
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
				A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_n2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
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
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
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
				if (_n4.$ === -1) {
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
		if (dict.$ === -2) {
			return elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _n4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
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
						if (_n7.$ === -1) {
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
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _n1 = elm$core$Dict$getMin(right);
				if (_n1.$ === -1) {
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
		if ((_n0.$ === -1) && (!_n0.a)) {
			var _n1 = _n0.a;
			var k = _n0.b;
			var v = _n0.c;
			var l = _n0.d;
			var r = _n0.e;
			return A5(elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _n0;
			return x;
		}
	});
var elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _n0 = alter(
			A2(elm$core$Dict$get, targetKey, dictionary));
		if (!_n0.$) {
			var value = _n0.a;
			return A3(elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2(elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var elm$url$Url$percentDecode = _Url_percentDecode;
var elm$url$Url$Parser$addToParametersHelp = F2(
	function (value, maybeList) {
		if (maybeList.$ === 1) {
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
			if (_n2.$ === 1) {
				return dict;
			} else {
				var key = _n2.a;
				var _n3 = elm$url$Url$percentDecode(rawValue);
				if (_n3.$ === 1) {
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
	if (maybeQuery.$ === 1) {
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
		var parser = _n0;
		return elm$url$Url$Parser$getFirstMatch(
			parser(
				A5(
					elm$url$Url$Parser$State,
					_List_Nil,
					elm$url$Url$Parser$preparePath(url.dI),
					elm$url$Url$Parser$prepareQuery(url.cu),
					url.eC,
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
			N: appData,
			O: author$project$Environment$preInit(maybeKey),
			be: author$project$Main$viewUrl(url)
		};
	});
var author$project$Main$NoOp = {$: 0};
var author$project$Main$Tick = function (a) {
	return {$: 1, a: a};
};
var author$project$Main$Tock = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var author$project$External$Tasker$flash = _Platform_outgoingPort('flash', elm$json$Json$Encode$string);
var author$project$External$Commands$toast = function (message) {
	return author$project$External$Tasker$flash(message);
};
var author$project$Incubator$Todoist$Items = 1;
var author$project$Incubator$Todoist$Projects = 0;
var author$project$Incubator$Todoist$SyncResponded = elm$core$Basics$identity;
var author$project$Incubator$Todoist$Response = F5(
	function (sync_token, sync_status, full_sync, items, projects) {
		return {dh: full_sync, P: items, T: projects, e6: sync_status, d6: sync_token};
	});
var author$project$Incubator$Todoist$Command$CommandError = F2(
	function (error_code, error) {
		return {ex: error, ey: error_code};
	});
var author$project$Incubator$Todoist$Command$decodeCommandError = A2(
	author$project$Porting$optionalIgnored,
	'error_extra',
	A2(
		author$project$Porting$optionalIgnored,
		'http_code',
		A2(
			author$project$Porting$optionalIgnored,
			'error_tag',
			A3(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
				'error',
				zwilias$json_decode_exploration$Json$Decode$Exploration$string,
				A3(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'error_code',
					zwilias$json_decode_exploration$Json$Decode$Exploration$int,
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Incubator$Todoist$Command$CommandError))))));
var author$project$Incubator$Todoist$Command$decodeCommandResult = zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$check,
			zwilias$json_decode_exploration$Json$Decode$Exploration$string,
			'ok',
			zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(
				elm$core$Result$Ok(0))),
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Result$Err, author$project$Incubator$Todoist$Command$decodeCommandError)
		]));
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
var zwilias$json_decode_exploration$Json$Decode$Exploration$keyValuePairs = function (_n0) {
	var decoderFn = _n0;
	var finalize = function (_n5) {
		var json = _n5.a;
		var warnings = _n5.b;
		var val = _n5.c;
		return {
			C: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, json),
			X: val,
			z: warnings
		};
	};
	var accumulate = F2(
		function (_n4, acc) {
			var key = _n4.a;
			var val = _n4.b;
			var _n2 = _Utils_Tuple2(
				acc,
				decoderFn(val));
			if (_n2.a.$ === 1) {
				if (_n2.b.$ === 1) {
					var e = _n2.a.a;
					var _new = _n2.b.a;
					return elm$core$Result$Err(
						A2(
							mgold$elm_nonempty_list$List$Nonempty$cons,
							A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField, key, _new),
							e));
				} else {
					var e = _n2.a.a;
					return elm$core$Result$Err(e);
				}
			} else {
				if (_n2.b.$ === 1) {
					var e = _n2.b.a;
					return elm$core$Result$Err(
						mgold$elm_nonempty_list$List$Nonempty$fromElement(
							A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField, key, e)));
				} else {
					var _n3 = _n2.a.a;
					var jsonAcc = _n3.a;
					var warningsAcc = _n3.b;
					var accAcc = _n3.c;
					var res = _n2.b.a;
					return elm$core$Result$Ok(
						_Utils_Tuple3(
							A2(
								elm$core$List$cons,
								_Utils_Tuple2(key, res.C),
								jsonAcc),
							_Utils_ap(
								A2(
									elm$core$List$map,
									A2(
										elm$core$Basics$composeR,
										mgold$elm_nonempty_list$List$Nonempty$fromElement,
										zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField(key)),
									res.z),
								warningsAcc),
							A2(
								elm$core$List$cons,
								_Utils_Tuple2(key, res.X),
								accAcc)));
				}
			}
		});
	return function (json) {
		if (json.$ === 5) {
			var kvPairs = json.b;
			return A2(
				elm$core$Result$map,
				finalize,
				A3(
					elm$core$List$foldr,
					accumulate,
					elm$core$Result$Ok(
						_Utils_Tuple3(_List_Nil, _List_Nil, _List_Nil)),
					kvPairs));
		} else {
			return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$expected, zwilias$json_decode_exploration$Json$Decode$Exploration$TObject, json);
		}
	};
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$dict = function (decoder) {
	return A2(
		zwilias$json_decode_exploration$Json$Decode$Exploration$map,
		elm$core$Dict$fromList,
		zwilias$json_decode_exploration$Json$Decode$Exploration$keyValuePairs(decoder));
};
var author$project$Incubator$Todoist$decodeResponse = A2(
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
																							zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Incubator$Todoist$Project$decodeProject),
																							_List_Nil,
																							A4(
																								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																								'items',
																								zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Incubator$Todoist$Item$decodeItem),
																								_List_Nil,
																								A3(
																									zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
																									'full_sync',
																									zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
																									A4(
																										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																										'sync_status',
																										zwilias$json_decode_exploration$Json$Decode$Exploration$dict(author$project$Incubator$Todoist$Command$decodeCommandResult),
																										elm$core$Dict$empty,
																										A4(
																											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
																											'sync_token',
																											A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Maybe$Just, author$project$Incubator$Todoist$decodeIncrementalSyncToken),
																											elm$core$Maybe$Nothing,
																											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Incubator$Todoist$Response))))))))))))))))))))))))))));
var author$project$Incubator$Todoist$encodeResources = function (resource) {
	switch (resource) {
		case 0:
			return elm$json$Json$Encode$string('projects');
		case 1:
			return elm$json$Json$Encode$string('items');
		default:
			return elm$json$Json$Encode$string('user');
	}
};
var elm$json$Json$Encode$int = _Json_wrap;
var author$project$Incubator$Todoist$Command$encodeItemID = function (realOrTemp) {
	if (!realOrTemp.$) {
		var intID = realOrTemp.a;
		return elm$json$Json$Encode$int(intID);
	} else {
		var tempID = realOrTemp.a;
		return elm$json$Json$Encode$string(tempID);
	}
};
var elm_community$json_extra$Json$Encode$Extra$maybe = function (encoder) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Maybe$map(encoder),
		elm$core$Maybe$withDefault(elm$json$Json$Encode$null));
};
var author$project$Incubator$Todoist$Item$encodeDue = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'date',
				elm$json$Json$Encode$string(record.c7)),
				_Utils_Tuple2(
				'timezone',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$string, record.eb)),
				_Utils_Tuple2(
				'string',
				elm$json$Json$Encode$string(record.d4)),
				_Utils_Tuple2(
				'lang',
				elm$json$Json$Encode$string(record.dA)),
				_Utils_Tuple2(
				'is_recurring',
				elm$json$Json$Encode$bool(record.ds))
			]));
};
var author$project$Incubator$Todoist$Item$encodePriority = function (priority) {
	switch (priority) {
		case 1:
			return elm$json$Json$Encode$int(4);
		case 2:
			return elm$json$Json$Encode$int(3);
		case 3:
			return elm$json$Json$Encode$int(2);
		default:
			return elm$json$Json$Encode$int(1);
	}
};
var author$project$Porting$encodeBoolToInt = function (bool) {
	if (bool) {
		return elm$json$Json$Encode$int(1);
	} else {
		return elm$json$Json$Encode$int(0);
	}
};
var elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _n0 = f(mx);
		if (!_n0.$) {
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
var author$project$Porting$encodeObjectWithoutNothings = A2(
	elm$core$Basics$composeL,
	elm$json$Json$Encode$object,
	elm$core$List$filterMap(elm$core$Basics$identity));
var author$project$Porting$normal = elm$core$Maybe$Just;
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
var author$project$Incubator$Todoist$Command$encodeItemChanges = function (item) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$normal(
				_Utils_Tuple2(
					'id',
					author$project$Incubator$Todoist$Command$encodeItemID(item.dl))),
				author$project$Porting$omittable(
				_Utils_Tuple3('content', elm$json$Json$Encode$string, item.bl)),
				author$project$Porting$omittable(
				_Utils_Tuple3('due', author$project$Incubator$Todoist$Item$encodeDue, item.aD)),
				author$project$Porting$omittable(
				_Utils_Tuple3('priority', author$project$Incubator$Todoist$Item$encodePriority, item.cp)),
				author$project$Porting$omittable(
				_Utils_Tuple3('day_order', elm$json$Json$Encode$int, item.bm)),
				author$project$Porting$omittable(
				_Utils_Tuple3('collapsed', author$project$Porting$encodeBoolToInt, item.aB))
			]));
};
var author$project$Incubator$Todoist$Command$encodeItemCompletion = function (item) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$normal(
				_Utils_Tuple2(
					'id',
					author$project$Incubator$Todoist$Command$encodeItemID(item.dl))),
				author$project$Porting$omittable(
				_Utils_Tuple3('date_completed', elm$json$Json$Encode$string, item.c9)),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'force_history',
					elm$json$Json$Encode$bool(item.dg)))
			]));
};
var author$project$Incubator$Todoist$Command$encodeItemOrder = function (order) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$int(order.dl)),
				_Utils_Tuple2(
				'child_order',
				elm$json$Json$Encode$int(order._))
			]));
};
var author$project$Incubator$Todoist$Command$encodeProjectID = function (realOrTemp) {
	if (!realOrTemp.$) {
		var intID = realOrTemp.a;
		return elm$json$Json$Encode$int(intID);
	} else {
		var tempID = realOrTemp.a;
		return elm$json$Json$Encode$string(tempID);
	}
};
var author$project$Incubator$Todoist$Command$encodeNewItem = function (_new) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$omittable(
				_Utils_Tuple3('temp_id', elm$json$Json$Encode$string, _new.aT)),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'content',
					elm$json$Json$Encode$string(_new.bl))),
				author$project$Porting$omittable(
				_Utils_Tuple3('project_id', author$project$Incubator$Todoist$Command$encodeProjectID, _new.dN)),
				author$project$Porting$omittable(
				_Utils_Tuple3('due', author$project$Incubator$Todoist$Item$encodeDue, _new.aD)),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'priority',
					author$project$Incubator$Todoist$Item$encodePriority(_new.cp))),
				author$project$Porting$omittable(
				_Utils_Tuple3('parent_id', author$project$Incubator$Todoist$Command$encodeItemID, _new.bx)),
				author$project$Porting$omittable(
				_Utils_Tuple3('child_order', elm$json$Json$Encode$int, _new._)),
				author$project$Porting$omittable(
				_Utils_Tuple3('day_order', elm$json$Json$Encode$int, _new.bm)),
				author$project$Porting$omittable(
				_Utils_Tuple3('collapsed', author$project$Porting$encodeBoolToInt, _new.aB)),
				author$project$Porting$omittable(
				_Utils_Tuple3('auto_reminder', elm$json$Json$Encode$bool, _new.cW))
			]));
};
var author$project$Incubator$Todoist$Command$encodeNewProject = function (_new) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$omittable(
				_Utils_Tuple3('temp_id', elm$json$Json$Encode$string, _new.aT)),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'name',
					elm$json$Json$Encode$string(_new.bu))),
				author$project$Porting$omittable(
				_Utils_Tuple3('color', elm$json$Json$Encode$int, _new.bk)),
				author$project$Porting$omittable(
				_Utils_Tuple3('parent_id', elm$json$Json$Encode$int, _new.bx)),
				author$project$Porting$omittable(
				_Utils_Tuple3('child_order', elm$json$Json$Encode$int, _new._)),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'is_favorite',
					elm$json$Json$Encode$bool(_new.br)))
			]));
};
var author$project$Incubator$Todoist$Command$encodeProjectChanges = function (_new) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$omittable(
				_Utils_Tuple3('temp_id', elm$json$Json$Encode$string, _new.aT)),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'name',
					elm$json$Json$Encode$string(_new.bu))),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'color',
					elm$json$Json$Encode$int(_new.bk))),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'collapsed',
					elm$json$Json$Encode$bool(_new.aB))),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'is_favorite',
					elm$json$Json$Encode$bool(_new.br)))
			]));
};
var author$project$Incubator$Todoist$Command$encodeProjectOrder = function (v) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$int(v.dl)),
				_Utils_Tuple2(
				'child_order',
				elm$json$Json$Encode$int(v._))
			]));
};
var author$project$Incubator$Todoist$Command$encodeRecurringItemCompletion = function (item) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$normal(
				_Utils_Tuple2(
					'id',
					author$project$Incubator$Todoist$Command$encodeItemID(item.dl))),
				author$project$Porting$omittable(
				_Utils_Tuple3('due', elm$json$Json$Encode$string, item.aD))
			]));
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
				case 0:
					return acc;
				case 1:
					var l = dict.a;
					return A3(f, l.dz, l.X, acc);
				default:
					var i = dict.a;
					var $temp$f = f,
						$temp$acc = A3(elm_community$intdict$IntDict$foldr, f, acc, i.p),
						$temp$dict = i.o;
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
var author$project$Porting$encodeIntDict = F2(
	function (valueEncoder, dict) {
		return A2(
			elm$json$Json$Encode$list,
			A2(author$project$Porting$encodeTuple2, elm$json$Json$Encode$int, valueEncoder),
			elm_community$intdict$IntDict$toList(dict));
	});
var author$project$Incubator$Todoist$Command$encodeCommandInstance = function (_n0) {
	var uuid = _n0.a;
	var command = _n0.b;
	var encodeWrapper = F2(
		function (typeName, args) {
			return author$project$Porting$encodeObjectWithoutNothings(
				_List_fromArray(
					[
						author$project$Porting$normal(
						_Utils_Tuple2(
							'type',
							elm$json$Json$Encode$string(typeName))),
						author$project$Porting$normal(
						_Utils_Tuple2('args', args)),
						author$project$Porting$normal(
						_Utils_Tuple2(
							'uuid',
							elm$json$Json$Encode$string(uuid))),
						author$project$Porting$omittable(
						_Utils_Tuple3('temp_id', elm$json$Json$Encode$string, elm$core$Maybe$Nothing))
					]));
		});
	switch (command.$) {
		case 0:
			var _new = command.a;
			return A2(
				encodeWrapper,
				'project_add',
				author$project$Incubator$Todoist$Command$encodeNewProject(_new));
		case 3:
			var _new = command.a;
			return A2(
				encodeWrapper,
				'project_update',
				author$project$Incubator$Todoist$Command$encodeProjectChanges(_new));
		case 1:
			var id = command.a;
			var newParent = command.b;
			return A2(
				encodeWrapper,
				'project_move',
				author$project$Porting$encodeObjectWithoutNothings(
					_List_fromArray(
						[
							author$project$Porting$normal(
							_Utils_Tuple2(
								'id',
								author$project$Incubator$Todoist$Command$encodeProjectID(id))),
							author$project$Porting$omittable(
							_Utils_Tuple3('parent_id', author$project$Incubator$Todoist$Command$encodeProjectID, newParent))
						])));
		case 2:
			var id = command.a;
			return A2(
				encodeWrapper,
				'project_delete',
				elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							author$project$Incubator$Todoist$Command$encodeProjectID(id))
						])));
		case 4:
			var orderList = command.a;
			return A2(
				encodeWrapper,
				'project_reorder',
				A2(elm$json$Json$Encode$list, author$project$Incubator$Todoist$Command$encodeProjectOrder, orderList));
		case 5:
			var dayOrdersDict = command.a;
			return A2(
				encodeWrapper,
				'item_update_day_orders',
				A2(author$project$Porting$encodeIntDict, elm$json$Json$Encode$int, dayOrdersDict));
		case 6:
			var _new = command.a;
			return A2(
				encodeWrapper,
				'item_add',
				author$project$Incubator$Todoist$Command$encodeNewItem(_new));
		case 7:
			var id = command.a;
			var newProject = command.b;
			return A2(
				encodeWrapper,
				'item_move',
				author$project$Porting$encodeObjectWithoutNothings(
					_List_fromArray(
						[
							author$project$Porting$normal(
							_Utils_Tuple2(
								'id',
								author$project$Incubator$Todoist$Command$encodeItemID(id))),
							author$project$Porting$omittable(
							_Utils_Tuple3('parent_id', author$project$Incubator$Todoist$Command$encodeProjectID, newProject))
						])));
		case 8:
			var id = command.a;
			var newParentItem = command.b;
			return A2(
				encodeWrapper,
				'item_move',
				author$project$Porting$encodeObjectWithoutNothings(
					_List_fromArray(
						[
							author$project$Porting$normal(
							_Utils_Tuple2(
								'id',
								author$project$Incubator$Todoist$Command$encodeItemID(id))),
							author$project$Porting$omittable(
							_Utils_Tuple3('project_id', author$project$Incubator$Todoist$Command$encodeItemID, newParentItem))
						])));
		case 9:
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_delete',
				elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 10:
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_close',
				elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 11:
			var completionDetails = command.a;
			return A2(
				encodeWrapper,
				'item_complete',
				author$project$Incubator$Todoist$Command$encodeItemCompletion(completionDetails));
		case 12:
			var completionDetails = command.a;
			return A2(
				encodeWrapper,
				'item_update_date_complete',
				author$project$Incubator$Todoist$Command$encodeRecurringItemCompletion(completionDetails));
		case 13:
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_uncomplete',
				elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 14:
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_archive',
				elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 15:
			var id = command.a;
			return A2(
				encodeWrapper,
				'item_unarchive',
				elm$json$Json$Encode$object(
					_List_fromArray(
						[
							_Utils_Tuple2(
							'id',
							author$project$Incubator$Todoist$Command$encodeItemID(id))
						])));
		case 16:
			var changes = command.a;
			return A2(
				encodeWrapper,
				'item_update',
				author$project$Incubator$Todoist$Command$encodeItemChanges(changes));
		default:
			var orderList = command.a;
			return A2(
				encodeWrapper,
				'item_reorder',
				A2(elm$json$Json$Encode$list, author$project$Incubator$Todoist$Command$encodeItemOrder, orderList));
	}
};
var elm$url$Url$Builder$toQueryPair = function (_n0) {
	var key = _n0.a;
	var value = _n0.b;
	return key + ('=' + value);
};
var elm$url$Url$Builder$toQuery = function (parameters) {
	if (!parameters.b) {
		return '';
	} else {
		return '?' + A2(
			elm$core$String$join,
			'&',
			A2(elm$core$List$map, elm$url$Url$Builder$toQueryPair, parameters));
	}
};
var elm$url$Url$Builder$crossOrigin = F3(
	function (prePath, pathSegments, parameters) {
		return prePath + ('/' + (A2(elm$core$String$join, '/', pathSegments) + elm$url$Url$Builder$toQuery(parameters)));
	});
var elm$url$Url$percentEncode = _Url_percentEncode;
var elm$url$Url$Builder$QueryParameter = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$url$Url$Builder$string = F2(
	function (key, value) {
		return A2(
			elm$url$Url$Builder$QueryParameter,
			elm$url$Url$percentEncode(key),
			elm$url$Url$percentEncode(value));
	});
var author$project$Incubator$Todoist$serverUrl = F4(
	function (secret, resourceList, commandList, _n0) {
		var syncToken = _n0;
		var resources = A2(elm$json$Json$Encode$list, author$project$Incubator$Todoist$encodeResources, resourceList);
		var withRead = (elm$core$List$length(resourceList) > 0) ? _List_fromArray(
			[
				A2(elm$url$Url$Builder$string, 'sync_token', syncToken),
				A2(
				elm$url$Url$Builder$string,
				'resource_types',
				A2(elm$json$Json$Encode$encode, 0, resources))
			]) : _List_Nil;
		var commands = A2(elm$json$Json$Encode$list, author$project$Incubator$Todoist$Command$encodeCommandInstance, commandList);
		var withWrite = (elm$core$List$length(commandList) > 0) ? _List_fromArray(
			[
				A2(
				elm$url$Url$Builder$string,
				'commands',
				A2(elm$json$Json$Encode$encode, 0, commands))
			]) : _List_Nil;
		var chosenResources = '[%22items%22,%22projects%22]';
		return A3(
			elm$url$Url$Builder$crossOrigin,
			'https://todoist.com',
			_List_fromArray(
				['api', 'v8', 'sync']),
			_Utils_ap(
				_List_fromArray(
					[
						A2(elm$url$Url$Builder$string, 'token', secret)
					]),
				_Utils_ap(withRead, withWrite)));
	});
var elm$json$Json$Decode$fail = _Json_fail;
var elm_community$json_extra$Json$Decode$Extra$fromResult = function (result) {
	if (!result.$) {
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
	if (!warning.$) {
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
			case 0:
				var f = located.a;
				var val = located.b;
				return A2(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField,
					f,
					A2(
						mgold$elm_nonempty_list$List$Nonempty$map,
						zwilias$json_decode_exploration$Json$Decode$Exploration$Located$map(op),
						val));
			case 1:
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
		case 1:
			var e = res.a;
			return elm$core$Result$Err(e);
		case 0:
			return elm$core$Result$Err(
				mgold$elm_nonempty_list$List$Nonempty$fromElement(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Located$Here(
						A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Failure, 'Invalid JSON', elm$core$Maybe$Nothing))));
		case 2:
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
	if (!maybe.$) {
		return true;
	} else {
		return false;
	}
};
var elm$core$Platform$sendToApp = _Platform_sendToApp;
var elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var elm$http$Http$BadUrl_ = function (a) {
	return {$: 0, a: a};
};
var elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var elm$http$Http$NetworkError_ = {$: 2};
var elm$http$Http$Receiving = function (a) {
	return {$: 1, a: a};
};
var elm$http$Http$Sending = function (a) {
	return {$: 0, a: a};
};
var elm$http$Http$Timeout_ = {$: 1};
var elm$http$Http$emptyBody = _Http_emptyBody;
var elm$http$Http$expectStringResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'',
			elm$core$Basics$identity,
			A2(elm$core$Basics$composeR, toResult, toMsg));
	});
var elm$http$Http$BadBody = function (a) {
	return {$: 4, a: a};
};
var elm$http$Http$BadStatus = function (a) {
	return {$: 3, a: a};
};
var elm$http$Http$BadUrl = function (a) {
	return {$: 0, a: a};
};
var elm$http$Http$NetworkError = {$: 2};
var elm$http$Http$Timeout = {$: 1};
var elm$http$Http$resolve = F2(
	function (toResult, response) {
		switch (response.$) {
			case 0:
				var url = response.a;
				return elm$core$Result$Err(
					elm$http$Http$BadUrl(url));
			case 1:
				return elm$core$Result$Err(elm$http$Http$Timeout);
			case 2:
				return elm$core$Result$Err(elm$http$Http$NetworkError);
			case 3:
				var metadata = response.a;
				return elm$core$Result$Err(
					elm$http$Http$BadStatus(metadata.d3));
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
var elm$http$Http$Request = function (a) {
	return {$: 1, a: a};
};
var elm$core$Task$succeed = _Scheduler_succeed;
var elm$http$Http$State = F2(
	function (reqs, subs) {
		return {dU: reqs, d5: subs};
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
				if (!cmd.$) {
					var tracker = cmd.a;
					var _n2 = A2(elm$core$Dict$get, tracker, reqs);
					if (_n2.$ === 1) {
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
							var _n4 = req.M;
							if (_n4.$ === 1) {
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
			A3(elm$http$Http$updateReqs, router, cmds, state.dU));
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
					state.d5)));
	});
var elm$http$Http$Cancel = function (a) {
	return {$: 0, a: a};
};
var elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (!cmd.$) {
			var tracker = cmd.a;
			return elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return elm$http$Http$Request(
				{
					aw: r.aw,
					bi: r.bi,
					ez: A2(_Http_mapExpect, func, r.ez),
					H: r.H,
					K: r.K,
					cI: r.cI,
					M: r.M,
					cN: r.cN
				});
		}
	});
var elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
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
			{aw: false, bi: r.bi, ez: r.ez, H: r.H, K: r.K, cI: r.cI, M: r.M, cN: r.cN}));
};
var elm$http$Http$post = function (r) {
	return elm$http$Http$request(
		{bi: r.bi, ez: r.ez, H: _List_Nil, K: 'POST', cI: elm$core$Maybe$Nothing, M: elm$core$Maybe$Nothing, cN: r.cN});
};
var author$project$Incubator$Todoist$sync = F4(
	function (cache, secret, resourceList, commandList) {
		return elm$http$Http$post(
			{
				bi: elm$http$Http$emptyBody,
				ez: A2(
					elm$http$Http$expectJson,
					elm$core$Basics$identity,
					author$project$Porting$toClassic(author$project$Incubator$Todoist$decodeResponse)),
				cN: A4(author$project$Incubator$Todoist$serverUrl, secret, resourceList, commandList, cache.ap)
			});
	});
var author$project$Integrations$Todoist$devSecret = '0bdc5149510737ab941485bace8135c60e2d812b';
var author$project$Integrations$Todoist$fetchUpdates = function (localData) {
	return A4(
		author$project$Incubator$Todoist$sync,
		localData.bN,
		author$project$Integrations$Todoist$devSecret,
		_List_fromArray(
			[1, 0]),
		_List_Nil);
};
var elm_community$intdict$IntDict$foldl = F3(
	function (f, acc, dict) {
		foldl:
		while (true) {
			switch (dict.$) {
				case 0:
					return acc;
				case 1:
					var l = dict.a;
					return A3(f, l.dz, l.X, acc);
				default:
					var i = dict.a;
					var $temp$f = f,
						$temp$acc = A3(elm_community$intdict$IntDict$foldl, f, acc, i.o),
						$temp$dict = i.p;
					f = $temp$f;
					acc = $temp$acc;
					dict = $temp$dict;
					continue foldl;
			}
		}
	});
var author$project$Incubator$IntDict$Extra$filterMapValues = F2(
	function (f, dict) {
		return A3(
			elm_community$intdict$IntDict$foldl,
			F3(
				function (k, v, acc) {
					var _n0 = f(v);
					if (!_n0.$) {
						var newVal = _n0.a;
						return A3(elm_community$intdict$IntDict$insert, k, newVal, acc);
					} else {
						return acc;
					}
				}),
			elm_community$intdict$IntDict$empty,
			dict);
	});
var author$project$Incubator$Todoist$describeError = function (error) {
	switch (error.$) {
		case 0:
			var msg = error.a;
			return 'For some reason we were told the URL is bad. This should never happen, it\'s a perfectly tested working URL! The error: ' + msg;
		case 1:
			return 'Timed out. Try again later?';
		case 2:
			return 'Couldn\'t get on the network. Are you offline?';
		case 3:
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
					return 'Got HTTP Error code ' + (elm$core$String$fromInt(other) + ', not sure what that means in this case. Sorry!');
			}
		default:
			var string = error.a;
			return 'I successfully talked with Todoist servers, but the response had some weird parts I was never trained for. Either Todoist changed something recently, or you\'ve found a weird edge case the developer didn\'t know about. Either way, please report this! \n' + string;
	}
};
var elm_community$intdict$IntDict$filter = F2(
	function (predicate, dict) {
		var add = F3(
			function (k, v, d) {
				return A2(predicate, k, v) ? A3(elm_community$intdict$IntDict$insert, k, v, d) : d;
			});
		return A3(elm_community$intdict$IntDict$foldl, add, elm_community$intdict$IntDict$empty, dict);
	});
var author$project$Incubator$IntDict$Extra$filterValues = F2(
	function (func, dict) {
		return A2(
			elm_community$intdict$IntDict$filter,
			F2(
				function (_n0, v) {
					return func(v);
				}),
			dict);
	});
var author$project$Incubator$Todoist$pruneDeleted = function (items) {
	return A2(
		author$project$Incubator$IntDict$Extra$filterValues,
		A2(
			elm$core$Basics$composeL,
			elm$core$Basics$not,
			function ($) {
				return $.bY;
			}),
		items);
};
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
var elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
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
var elm$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			elm$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2(elm$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});
var elm$core$Set$Set_elm_builtin = elm$core$Basics$identity;
var elm$core$Set$diff = F2(
	function (_n0, _n1) {
		var dict1 = _n0;
		var dict2 = _n1;
		return A2(elm$core$Dict$diff, dict1, dict2);
	});
var elm$core$Dict$filter = F2(
	function (isGood, dict) {
		return A3(
			elm$core$Dict$foldl,
			F3(
				function (k, v, d) {
					return A2(isGood, k, v) ? A3(elm$core$Dict$insert, k, v, d) : d;
				}),
			elm$core$Dict$empty,
			dict);
	});
var elm$core$Set$filter = F2(
	function (isGood, _n0) {
		var dict = _n0;
		return A2(
			elm$core$Dict$filter,
			F2(
				function (key, _n1) {
					return isGood(key);
				}),
			dict);
	});
var elm$core$Set$empty = elm$core$Dict$empty;
var elm$core$Set$insert = F2(
	function (key, _n0) {
		var dict = _n0;
		return A3(elm$core$Dict$insert, key, 0, dict);
	});
var elm$core$Set$fromList = function (list) {
	return A3(elm$core$List$foldl, elm$core$Set$insert, elm$core$Set$empty, list);
};
var elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3(elm$core$Dict$foldl, elm$core$Dict$insert, t2, t1);
	});
var elm$core$Set$union = F2(
	function (_n0, _n1) {
		var dict1 = _n0;
		var dict2 = _n1;
		return A2(elm$core$Dict$union, dict1, dict2);
	});
var elm_community$intdict$IntDict$get = F2(
	function (key, dict) {
		get:
		while (true) {
			switch (dict.$) {
				case 0:
					return elm$core$Maybe$Nothing;
				case 1:
					var l = dict.a;
					return _Utils_eq(l.dz, key) ? elm$core$Maybe$Just(l.X) : elm$core$Maybe$Nothing;
				default:
					var i = dict.a;
					if (!A2(elm_community$intdict$IntDict$prefixMatches, i.s, key)) {
						return elm$core$Maybe$Nothing;
					} else {
						if (A2(elm_community$intdict$IntDict$isBranchingBitSet, i.s, key)) {
							var $temp$key = key,
								$temp$dict = i.p;
							key = $temp$key;
							dict = $temp$dict;
							continue get;
						} else {
							var $temp$key = key,
								$temp$dict = i.o;
							key = $temp$key;
							dict = $temp$dict;
							continue get;
						}
					}
			}
		}
	});
var elm_community$intdict$IntDict$member = F2(
	function (key, dict) {
		var _n0 = A2(elm_community$intdict$IntDict$get, key, dict);
		if (!_n0.$) {
			return true;
		} else {
			return false;
		}
	});
var author$project$Incubator$Todoist$summarizeChanges = F2(
	function (oldCache, _new) {
		var toIDSet = function (list) {
			return elm$core$Set$fromList(
				A2(
					elm$core$List$map,
					function ($) {
						return $.dl;
					},
					list));
		};
		var _n0 = _Utils_Tuple2(
			toIDSet(
				A2(
					elm$core$List$filter,
					function ($) {
						return $.bY;
					},
					_new.P)),
			toIDSet(
				A2(
					elm$core$List$filter,
					function ($) {
						return $.bY;
					},
					_new.T)));
		var deletedItemIDs = _n0.a;
		var deletedProjectIDs = _n0.b;
		var _n1 = _Utils_Tuple2(
			toIDSet(_new.P),
			toIDSet(_new.T));
		var allChangedItemIDs = _n1.a;
		var allChangedProjectIDs = _n1.b;
		var _n2 = _Utils_Tuple2(
			A2(
				elm$core$Set$filter,
				function (id) {
					return !A2(elm_community$intdict$IntDict$member, id, oldCache.P);
				},
				allChangedItemIDs),
			A2(
				elm$core$Set$filter,
				function (id) {
					return !A2(elm_community$intdict$IntDict$member, id, oldCache.T);
				},
				allChangedProjectIDs));
		var newlyAddedItemIDs = _n2.a;
		var newlyAddedProjectIDs = _n2.b;
		var _n3 = _Utils_Tuple2(
			A2(
				elm$core$Set$diff,
				allChangedItemIDs,
				A2(elm$core$Set$union, newlyAddedItemIDs, deletedItemIDs)),
			A2(
				elm$core$Set$diff,
				allChangedProjectIDs,
				A2(elm$core$Set$union, newlyAddedProjectIDs, deletedProjectIDs)));
		var remainingItemIDs = _n3.a;
		var remainingProjectIDs = _n3.b;
		return {dv: newlyAddedItemIDs, dw: remainingItemIDs, dx: deletedItemIDs, dO: newlyAddedProjectIDs, dP: remainingProjectIDs, dQ: deletedProjectIDs};
	});
var elm_community$intdict$IntDict$Disjunct = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var elm_community$intdict$IntDict$Left = 0;
var elm_community$intdict$IntDict$Parent = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm_community$intdict$IntDict$Right = 1;
var elm_community$intdict$IntDict$SamePrefix = {$: 0};
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
		var rp = r.s;
		var lp = l.s;
		var mask = elm_community$intdict$IntDict$highestBitSet(
			A2(elm_community$intdict$IntDict$mostSignificantBranchingBit, lp.az, rp.az));
		var modifiedRightPrefix = A3(elm_community$intdict$IntDict$combineBits, rp.S, ~lp.S, mask);
		var prefix = A2(elm_community$intdict$IntDict$lcp, lp.S, modifiedRightPrefix);
		var childEdge = F2(
			function (branchPrefix, c) {
				return A2(elm_community$intdict$IntDict$isBranchingBitSet, branchPrefix, c.s.S) ? 1 : 0;
			});
		return _Utils_eq(lp, rp) ? elm_community$intdict$IntDict$SamePrefix : (_Utils_eq(prefix, lp) ? A2(
			elm_community$intdict$IntDict$Parent,
			0,
			A2(childEdge, l.s, r)) : (_Utils_eq(prefix, rp) ? A2(
			elm_community$intdict$IntDict$Parent,
			1,
			A2(childEdge, r.s, l)) : A2(
			elm_community$intdict$IntDict$Disjunct,
			prefix,
			A2(childEdge, prefix, l))));
	});
var elm_community$intdict$IntDict$uniteWith = F3(
	function (merger, l, r) {
		var mergeWith = F3(
			function (key, left, right) {
				var _n14 = _Utils_Tuple2(left, right);
				if (!_n14.a.$) {
					if (!_n14.b.$) {
						var l2 = _n14.a.a;
						var r2 = _n14.b.a;
						return elm$core$Maybe$Just(
							A3(merger, key, l2, r2));
					} else {
						return left;
					}
				} else {
					if (!_n14.b.$) {
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
					case 0:
						var _n1 = _n0.a;
						return r;
					case 1:
						switch (_n0.b.$) {
							case 0:
								break _n0$1;
							case 1:
								break _n0$2;
							default:
								break _n0$2;
						}
					default:
						switch (_n0.b.$) {
							case 0:
								break _n0$1;
							case 1:
								var r2 = _n0.b.a;
								return A3(
									elm_community$intdict$IntDict$update,
									r2.dz,
									function (l_) {
										return A3(
											mergeWith,
											r2.dz,
											l_,
											elm$core$Maybe$Just(r2.X));
									},
									l);
							default:
								var il = _n0.a.a;
								var ir = _n0.b.a;
								var _n3 = A2(elm_community$intdict$IntDict$determineBranchRelation, il, ir);
								switch (_n3.$) {
									case 0:
										return A3(
											elm_community$intdict$IntDict$inner,
											il.s,
											A3(elm_community$intdict$IntDict$uniteWith, merger, il.o, ir.o),
											A3(elm_community$intdict$IntDict$uniteWith, merger, il.p, ir.p));
									case 1:
										if (!_n3.a) {
											if (_n3.b === 1) {
												var _n4 = _n3.a;
												var _n5 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													il.s,
													il.o,
													A3(elm_community$intdict$IntDict$uniteWith, merger, il.p, r));
											} else {
												var _n8 = _n3.a;
												var _n9 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													il.s,
													A3(elm_community$intdict$IntDict$uniteWith, merger, il.o, r),
													il.p);
											}
										} else {
											if (_n3.b === 1) {
												var _n6 = _n3.a;
												var _n7 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													ir.s,
													ir.o,
													A3(elm_community$intdict$IntDict$uniteWith, merger, l, ir.p));
											} else {
												var _n10 = _n3.a;
												var _n11 = _n3.b;
												return A3(
													elm_community$intdict$IntDict$inner,
													ir.s,
													A3(elm_community$intdict$IntDict$uniteWith, merger, l, ir.o),
													ir.p);
											}
										}
									default:
										if (!_n3.b) {
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
				l2.dz,
				function (r_) {
					return A3(
						mergeWith,
						l2.dz,
						elm$core$Maybe$Just(l2.X),
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
var author$project$Incubator$Todoist$handleResponse = F2(
	function (_n0, oldCache) {
		var response = _n0;
		if (!response.$) {
			var newStuff = response.a;
			var prune = function (inputDict) {
				return (!newStuff.dh) ? author$project$Incubator$Todoist$pruneDeleted(inputDict) : inputDict;
			};
			var _n2 = _Utils_Tuple2(
				elm_community$intdict$IntDict$fromList(
					A2(
						elm$core$List$map,
						function (i) {
							return _Utils_Tuple2(i.dl, i);
						},
						newStuff.P)),
				elm_community$intdict$IntDict$fromList(
					A2(
						elm$core$List$map,
						function (p) {
							return _Utils_Tuple2(p.dl, p);
						},
						newStuff.T)));
			var itemsDict = _n2.a;
			var projectsDict = _n2.b;
			return elm$core$Result$Ok(
				_Utils_Tuple2(
					{
						P: prune(
							A2(elm_community$intdict$IntDict$union, itemsDict, oldCache.P)),
						ap: A2(elm$core$Maybe$withDefault, oldCache.ap, newStuff.d6),
						by: _List_Nil,
						T: prune(
							A2(elm_community$intdict$IntDict$union, projectsDict, oldCache.T))
					},
					A2(author$project$Incubator$Todoist$summarizeChanges, oldCache, newStuff)));
		} else {
			var err = response.a;
			return elm$core$Result$Err(err);
		}
	});
var elm$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			if (dict.$ === -2) {
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
var elm$core$Set$size = function (_n0) {
	var dict = _n0;
	return elm$core$Dict$size(dict);
};
var author$project$Integrations$Todoist$describeSuccess = function (report) {
	var _n0 = _Utils_Tuple3(
		elm$core$Set$size(report.dO),
		elm$core$Set$size(report.dQ),
		elm$core$Set$size(report.dP));
	var projectsAdded = _n0.a;
	var projectsDeleted = _n0.b;
	var projectsModified = _n0.c;
	var totalProjectChanges = (projectsAdded + projectsDeleted) + projectsModified;
	var projectReport = (totalProjectChanges > 0) ? elm$core$Maybe$Just(
		elm$core$String$fromInt(totalProjectChanges) + (' projects updated (' + (elm$core$String$fromInt(projectsAdded) + (' created, ' + (elm$core$String$fromInt(projectsDeleted) + ' deleted)'))))) : elm$core$Maybe$Nothing;
	var _n1 = _Utils_Tuple3(
		elm$core$Set$size(report.dv),
		elm$core$Set$size(report.dx),
		elm$core$Set$size(report.dw));
	var itemsAdded = _n1.a;
	var itemsDeleted = _n1.b;
	var itemsModified = _n1.c;
	var totalItemChanges = (itemsAdded + itemsDeleted) + itemsModified;
	var itemReport = (totalItemChanges > 0) ? elm$core$Maybe$Just(
		elm$core$String$fromInt(totalItemChanges) + (' items updated (' + (elm$core$String$fromInt(itemsAdded) + (' created, ' + (elm$core$String$fromInt(itemsDeleted) + ' deleted)'))))) : elm$core$Maybe$Nothing;
	var reportList = A2(
		elm$core$List$filterMap,
		elm$core$Basics$identity,
		_List_fromArray(
			[itemReport, projectReport]));
	return 'Todoist sync complete: ' + ((!(totalProjectChanges + totalItemChanges)) ? 'Nothing changed since last sync.' : (elm$core$String$concat(
		A2(elm$core$List$intersperse, ' and ', reportList)) + '.'));
};
var author$project$Activity$Activity$defaults = function (startWith) {
	switch (startWith) {
		case 0:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('shrugging-attempt.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(0),
					author$project$SmartTime$Human$Duration$Hours(1)),
				c: _List_fromArray(
					['Nothing', 'Dilly-dally', 'Distracted']),
				i: true,
				j: startWith
			};
		case 1:
			return {
				d: false,
				e: 2,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(5),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				g: author$project$Activity$Activity$File('shirt.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Appareling', 'Dressing', 'Getting Dressed', 'Dressing Up']),
				i: true,
				j: startWith
			};
		case 2:
			return {
				d: false,
				e: 4,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(7),
						author$project$SmartTime$Human$Duration$Minutes(30))),
				b: false,
				g: author$project$Activity$Activity$File('messaging.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Hours(5)),
				c: _List_fromArray(
					['Messaging', 'Texting', 'Chatting', 'Text Messaging']),
				i: true,
				j: startWith
			};
		case 3:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(12),
						author$project$SmartTime$Human$Duration$Hours(2))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(20),
					author$project$SmartTime$Human$Duration$Hours(2)),
				c: _List_fromArray(
					['Restroom', 'Toilet', 'WC', 'Washroom', 'Latrine', 'Lavatory', 'Water Closet']),
				i: true,
				j: startWith
			};
		case 4:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Grooming', 'Tending', 'Groom']),
				i: true,
				j: startWith
			};
		case 5:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Meal', 'Eating', 'Food', 'Lunch', 'Dinner', 'Breakfast']),
				i: true,
				j: startWith
			};
		case 6:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Supplements', 'Pills', 'Medication']),
				i: true,
				j: startWith
			};
		case 7:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Workout', 'Working Out', 'Work Out']),
				i: true,
				j: startWith
			};
		case 8:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(20),
						author$project$SmartTime$Human$Duration$Hours(18))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Shower', 'Bathing', 'Showering']),
				i: true,
				j: startWith
			};
		case 9:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Toothbrush', 'Teeth', 'Brushing Teeth', 'Teethbrushing']),
				i: true,
				j: startWith
			};
		case 10:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Floss', 'Flossing']),
				i: true,
				j: startWith
			};
		case 11:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(12),
						author$project$SmartTime$Human$Duration$Hours(15))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Wakeup', 'Waking Up', 'Wakeup Walk']),
				i: true,
				j: startWith
			};
		case 12:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$IndefinitelyExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Sleep', 'Sleeping']),
				i: true,
				j: startWith
			};
		case 13:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(20),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Plan', 'Planning', 'Plans']),
				i: true,
				j: startWith
			};
		case 14:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(25),
						author$project$SmartTime$Human$Duration$Hours(5))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Configure', 'Configuring', 'Configuration']),
				i: true,
				j: startWith
			};
		case 15:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(15),
						author$project$SmartTime$Human$Duration$Hours(4))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Email', 'E-Mail', 'E-mail', 'Emailing', 'E-mails', 'Emails', 'E-mailing']),
				i: true,
				j: startWith
			};
		case 16:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(12))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(8),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Work', 'Working', 'Listings Work']),
				i: true,
				j: startWith
			};
		case 17:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(4))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Call', 'Calling', 'Phone Call', 'Phone', 'Phone Calls', 'Calling', 'Voice Call', 'Voice Chat', 'Video Call']),
				i: true,
				j: startWith
			};
		case 18:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(25),
						author$project$SmartTime$Human$Duration$Hours(4))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Chore', 'Chores']),
				i: true,
				j: startWith
			};
		case 19:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(12))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Parents', 'Parent']),
				i: true,
				j: startWith
			};
		case 20:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(30),
					author$project$SmartTime$Human$Duration$Hours(24)),
				c: _List_fromArray(
					['Prepare', 'Preparing', 'Preparation']),
				i: true,
				j: startWith
			};
		case 21:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(2),
						author$project$SmartTime$Human$Duration$Hours(8))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Lover', 'S.O.', 'Partner']),
				i: true,
				j: startWith
			};
		case 22:
			return {
				d: false,
				e: 0,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(6))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Driving', 'Drive']),
				i: true,
				j: startWith
			};
		case 23:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Hours(8))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(30),
					author$project$SmartTime$Human$Duration$Hours(5)),
				c: _List_fromArray(
					['Riding', 'Ride', 'Passenger']),
				i: true,
				j: startWith
			};
		case 24:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(20),
						author$project$SmartTime$Human$Duration$Hours(4))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Social Media']),
				i: true,
				j: startWith
			};
		case 25:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Pacing', 'Pace']),
				i: true,
				j: startWith
			};
		case 26:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Sport', 'Sports', 'Playing Sports']),
				i: true,
				j: startWith
			};
		case 27:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(20),
						author$project$SmartTime$Human$Duration$Hours(16))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Finance', 'Financial', 'Finances']),
				i: true,
				j: startWith
			};
		case 28:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Laundry']),
				i: true,
				j: startWith
			};
		case 29:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Bedward', 'Bedward-bound', 'Going to Bed']),
				i: true,
				j: startWith
			};
		case 30:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Browse', 'Browsing']),
				i: true,
				j: startWith
			};
		case 31:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Fiction', 'Reading Fiction']),
				i: true,
				j: startWith
			};
		case 32:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(15),
						author$project$SmartTime$Human$Duration$Hours(10))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Learn', 'Learning', 'Reading', 'Read', 'Book', 'Books']),
				i: true,
				j: startWith
			};
		case 33:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Hours(20))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Brain Training', 'Braining', 'Brain Train', 'Mental Math Practice']),
				i: true,
				j: startWith
			};
		case 34:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Music', 'Music Listening']),
				i: true,
				j: startWith
			};
		case 35:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(16))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Create', 'Creating', 'Creation', 'Making']),
				i: true,
				j: startWith
			};
		case 36:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Children', 'Kids']),
				i: true,
				j: startWith
			};
		case 37:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(8))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Meeting', 'Meet', 'Meetings']),
				i: true,
				j: startWith
			};
		case 38:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Cinema', 'Movies', 'Movie Theatre', 'Movie Theater']),
				i: true,
				j: startWith
			};
		case 39:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Films', 'Film Watching', 'Watching Movies']),
				i: true,
				j: startWith
			};
		case 40:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Series', 'TV Shows', 'TV Series']),
				i: true,
				j: startWith
			};
		case 41:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Broadcast']),
				i: true,
				j: startWith
			};
		case 42:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Theatre', 'Play', 'Play/Musical', 'Drama']),
				i: true,
				j: startWith
			};
		case 43:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Shopping', 'Shop']),
				i: true,
				j: startWith
			};
		case 44:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Video', 'Video Gaming', 'Gaming']),
				i: true,
				j: startWith
			};
		case 45:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(20),
						author$project$SmartTime$Human$Duration$Hours(6))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Housekeeping']),
				i: true,
				j: startWith
			};
		case 46:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(45),
						author$project$SmartTime$Human$Duration$Hours(6))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Meal Prep', 'Cooking', 'Food making']),
				i: true,
				j: startWith
			};
		case 47:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Networking']),
				i: true,
				j: startWith
			};
		case 48:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Meditate', 'Meditation', 'Meditating']),
				i: true,
				j: startWith
			};
		case 49:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Homework', 'Schoolwork']),
				i: true,
				j: startWith
			};
		case 50:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Flight', 'Aviation', 'Flying', 'Airport']),
				i: true,
				j: startWith
			};
		case 51:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Course', 'Courses', 'Classes', 'Class']),
				i: true,
				j: startWith
			};
		case 52:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Pet', 'Pets', 'Pet Care']),
				i: true,
				j: startWith
			};
		case 53:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Presentation', 'Presenting', 'Present']),
				i: true,
				j: startWith
			};
		case 54:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(45),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Project', 'Projects', 'Project Work', 'Fun Project']),
				i: true,
				j: startWith
			};
		default:
			return {
				d: false,
				e: 3,
				f: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				g: author$project$Activity$Activity$File('unknown.svg'),
				h: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(6),
					author$project$SmartTime$Human$Duration$Days(1)),
				c: _List_fromArray(
					['Research', 'Researching', 'Looking Stuff Up', 'Evaluating']),
				i: true,
				j: startWith
			};
	}
};
var author$project$Activity$Activity$withTemplate = function (delta) {
	var over = F2(
		function (b, s) {
			return A2(elm$core$Maybe$withDefault, b, s);
		});
	var base = author$project$Activity$Activity$defaults(delta.j);
	return {
		d: A2(over, base.d, delta.d),
		e: A2(over, base.e, delta.e),
		f: A2(over, base.f, delta.f),
		a: A2(over, base.a, delta.a),
		b: A2(over, base.b, delta.b),
		g: A2(over, base.g, delta.g),
		h: A2(over, base.h, delta.h),
		c: A2(over, base.c, delta.c),
		i: A2(over, base.i, delta.i),
		j: delta.j
	};
};
var author$project$Activity$Template$Research = 55;
var author$project$Activity$Template$stockActivities = _List_fromArray(
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55]);
var elm_community$intdict$IntDict$map = F2(
	function (f, dict) {
		switch (dict.$) {
			case 0:
				return elm_community$intdict$IntDict$empty;
			case 1:
				var l = dict.a;
				return A2(
					elm_community$intdict$IntDict$leaf,
					l.dz,
					A2(f, l.dz, l.X));
			default:
				var i = dict.a;
				return A3(
					elm_community$intdict$IntDict$inner,
					i.s,
					A2(elm_community$intdict$IntDict$map, f, i.o),
					A2(elm_community$intdict$IntDict$map, f, i.p));
		}
	});
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
var author$project$ID$tag = function (_int) {
	return _int;
};
var author$project$Incubator$IntDict$Extra$filterMap = F2(
	function (f, dict) {
		return A3(
			elm_community$intdict$IntDict$foldl,
			F3(
				function (k, v, acc) {
					var _n0 = A2(f, k, v);
					if (!_n0.$) {
						var newVal = _n0.a;
						return A3(elm_community$intdict$IntDict$insert, k, newVal, acc);
					} else {
						return acc;
					}
				}),
			elm_community$intdict$IntDict$empty,
			dict);
	});
var author$project$Incubator$IntDict$Extra$mapValues = F2(
	function (func, dict) {
		return A2(
			elm_community$intdict$IntDict$map,
			F2(
				function (_n0, v) {
					return func(v);
				}),
			dict);
	});
var elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return elm$core$Maybe$Just(x);
	} else {
		return elm$core$Maybe$Nothing;
	}
};
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
var author$project$Integrations$Todoist$filterActivityProjects = F2(
	function (projects, activities) {
		var matchToID = F3(
			function (nameToTest, activityID, nameList) {
				return A2(elm$core$List$member, nameToTest, nameList) ? elm$core$Maybe$Just(
					author$project$ID$tag(activityID)) : elm$core$Maybe$Nothing;
			});
		var activityNamesDict = A2(
			author$project$Incubator$IntDict$Extra$mapValues,
			function ($) {
				return $.c;
			},
			activities);
		var activityNameMatches = function (nameToTest) {
			return A2(
				author$project$Incubator$IntDict$Extra$filterMap,
				matchToID(nameToTest),
				activityNamesDict);
		};
		var pickFirstMatch = function (nameToTest) {
			return elm$core$List$head(
				elm_community$intdict$IntDict$values(
					activityNameMatches(nameToTest)));
		};
		return A2(
			author$project$Incubator$IntDict$Extra$filterMap,
			F2(
				function (i, p) {
					return pickFirstMatch(p.bu);
				}),
			projects);
	});
var elm_community$maybe_extra$Maybe$Extra$unwrap = F3(
	function (d, f, m) {
		if (m.$ === 1) {
			return d;
		} else {
			var a = m.a;
			return f(a);
		}
	});
var author$project$Integrations$Todoist$detectActivityProjects = F3(
	function (maybeParent, app, cache) {
		if (maybeParent.$ === 1) {
			return elm_community$intdict$IntDict$empty;
		} else {
			var parentProjectID = maybeParent.a;
			var oldActivityLookupTable = app.cK.bI;
			var hasTimetrackAsParent = function (p) {
				return A3(
					elm_community$maybe_extra$Maybe$Extra$unwrap,
					false,
					elm$core$Basics$eq(parentProjectID),
					p.bx);
			};
			var validActivityProjects = A2(author$project$Incubator$IntDict$Extra$filterValues, hasTimetrackAsParent, cache.T);
			var activities = author$project$Activity$Activity$allActivities(app.bH);
			var newActivityLookupTable = A2(author$project$Integrations$Todoist$filterActivityProjects, validActivityProjects, activities);
			return A2(elm_community$intdict$IntDict$union, newActivityLookupTable, oldActivityLookupTable);
		}
	});
var elm$core$Result$toMaybe = function (result) {
	if (!result.$) {
		var v = result.a;
		return elm$core$Maybe$Just(v);
	} else {
		return elm$core$Maybe$Nothing;
	}
};
var author$project$Incubator$Todoist$Item$fromRFC3339Date = A2(elm$core$Basics$composeL, elm$core$Result$toMaybe, author$project$SmartTime$Human$Moment$fuzzyFromString);
var author$project$Integrations$Todoist$calcImportance = function (_n0) {
	var priority = _n0.cp;
	var day_order = _n0.bm;
	var orderingFactor = _Utils_eq(day_order, -1) ? 0 : ((0 - (day_order * 1.0e-2)) + 0.99);
	var _n1 = priority;
	var _int = _n1;
	var priorityFactor = (0 - _int) + 4;
	return priorityFactor + orderingFactor;
};
var author$project$Integrations$Todoist$timing = A2(
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
			elm$parser$Parser$float,
			elm$parser$Parser$symbol('-'))),
	A2(
		elm$parser$Parser$ignorer,
		A2(
			elm$parser$Parser$ignorer,
			A2(
				elm$parser$Parser$ignorer,
				elm$parser$Parser$float,
				elm$parser$Parser$symbol('m')),
			elm$parser$Parser$spaces),
		elm$parser$Parser$symbol(')')));
var elm$core$String$dropRight = F2(
	function (n, string) {
		return (n < 1) ? string : A3(elm$core$String$slice, 0, -n, string);
	});
var author$project$Integrations$Todoist$extractTiming2 = function (input) {
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
			input);
	};
	var _n0 = elm_community$list_extra$List$Extra$last(
		A2(elm$core$String$indexes, '(', input));
	if (_n0.$ === 1) {
		return _default;
	} else {
		var chunkStart = _n0.a;
		var _n1 = A2(
			elm$parser$Parser$run,
			author$project$Integrations$Todoist$timing,
			chunk(chunkStart));
		if (_n1.$ === 1) {
			return _default;
		} else {
			var _n2 = _n1.a;
			var num1 = _n2.a;
			var num2 = _n2.b;
			return _Utils_Tuple2(
				withoutChunk(chunkStart),
				_Utils_Tuple2(
					elm$core$Maybe$Just(
						author$project$SmartTime$Duration$fromMinutes(num1)),
					elm$core$Maybe$Just(
						author$project$SmartTime$Duration$fromMinutes(num2))));
		}
	}
};
var author$project$Task$Progress$unitMax = function (unit) {
	switch (unit.$) {
		case 0:
			return 1;
		case 2:
			return 100;
		case 1:
			return 1000;
		case 3:
			var wordTarget = unit.a;
			return wordTarget;
		case 4:
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
			ek: elm$core$Maybe$Nothing,
			bQ: _Utils_Tuple2(0, author$project$Task$Progress$Percent),
			et: elm$core$Maybe$Nothing,
			a2: _List_Nil,
			dl: id,
			eG: 0,
			eN: author$project$SmartTime$Duration$zero,
			dC: author$project$SmartTime$Duration$zero,
			ce: elm$core$Maybe$Nothing,
			cl: elm$core$Maybe$Nothing,
			cm: elm$core$Maybe$Nothing,
			cn: author$project$SmartTime$Duration$zero,
			cv: elm$core$Maybe$Nothing,
			cw: elm$core$Maybe$Nothing,
			e7: _List_Nil,
			ba: description
		};
	});
var elm$core$String$trim = _String_trim;
var author$project$Task$Task$normalizeTitle = function (newTaskTitle) {
	return elm$core$String$trim(newTaskTitle);
};
var elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var author$project$Integrations$Todoist$itemToTask = F2(
	function (activityID, item) {
		var getDueDate = function (due) {
			return author$project$Incubator$Todoist$Item$fromRFC3339Date(due.c7);
		};
		var _n0 = author$project$Integrations$Todoist$extractTiming2(item.bl);
		var newName = _n0.a;
		var _n1 = _n0.b;
		var minDur = _n1.a;
		var maxDur = _n1.b;
		var base = A2(
			author$project$Task$Task$newTask,
			author$project$Task$Task$normalizeTitle(newName),
			item.dl);
		return _Utils_update(
			base,
			{
				ek: elm$core$Maybe$Just(activityID),
				bQ: item.c5 ? author$project$Task$Progress$maximize(base.bQ) : base.bQ,
				et: A2(elm$core$Maybe$andThen, getDueDate, item.aD),
				eG: author$project$Integrations$Todoist$calcImportance(item),
				eN: A2(elm$core$Maybe$withDefault, base.eN, maxDur),
				dC: A2(elm$core$Maybe$withDefault, base.dC, minDur),
				e7: _List_Nil
			});
	});
var author$project$Integrations$Todoist$timetrackItemToTask = F2(
	function (lookup, item) {
		var _n0 = A2(elm_community$intdict$IntDict$get, item.dN, lookup);
		if (!_n0.$) {
			var act = _n0.a;
			return elm$core$Maybe$Just(
				A2(author$project$Integrations$Todoist$itemToTask, act, item));
		} else {
			return elm$core$Maybe$Nothing;
		}
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
var author$project$Integrations$Todoist$tryGetTimetrackParentProject = F2(
	function (localData, cache) {
		var _n0 = localData.cf;
		if (!_n0.$) {
			var parentProjectID = _n0.a;
			return elm$core$Maybe$Just(parentProjectID);
		} else {
			return elm$core$List$head(
				elm_community$intdict$IntDict$keys(
					A2(
						elm_community$intdict$IntDict$filter,
						F2(
							function (_n1, p) {
								return p.bu === 'Timetrack';
							}),
						cache.T)));
		}
	});
var author$project$Integrations$Todoist$handle = F2(
	function (msg, app) {
		var _n0 = A2(author$project$Incubator$Todoist$handleResponse, msg, app.cK.bN);
		if (!_n0.$) {
			var _n1 = _n0.a;
			var newCache = _n1.a;
			var changes = _n1.b;
			var newMaybeParent = A2(author$project$Integrations$Todoist$tryGetTimetrackParentProject, app.cK, newCache);
			var projectToActivityMapping = A3(author$project$Integrations$Todoist$detectActivityProjects, newMaybeParent, app, newCache);
			var newTodoistData = {bI: projectToActivityMapping, bN: newCache, cf: newMaybeParent};
			var convertItemsToTasks = A2(
				author$project$Incubator$IntDict$Extra$filterMapValues,
				author$project$Integrations$Todoist$timetrackItemToTask(projectToActivityMapping),
				newCache.P);
			return _Utils_Tuple2(
				_Utils_update(
					app,
					{
						e8: A2(elm_community$intdict$IntDict$union, convertItemsToTasks, app.e8),
						cK: newTodoistData
					}),
				author$project$Integrations$Todoist$describeSuccess(changes));
		} else {
			var err = _n0.a;
			var description = author$project$Incubator$Todoist$describeError(err);
			return _Utils_Tuple2(
				A2(author$project$AppData$saveError, app, description),
				description);
		}
	});
var author$project$Main$Model = F3(
	function (viewState, appData, environment) {
		return {N: appData, O: environment, be: viewState};
	});
var author$project$Main$SyncTodoist = {$: 5};
var author$project$Main$TaskListMsg = function (a) {
	return {$: 9, a: a};
};
var author$project$Main$TimeTrackerMsg = function (a) {
	return {$: 10, a: a};
};
var author$project$Main$TodoistServerResponse = function (a) {
	return {$: 6, a: a};
};
var author$project$TaskList$AllTasks = 0;
var author$project$TaskList$defaultView = A3(
	author$project$TaskList$Normal,
	_List_fromArray(
		[0]),
	elm$core$Maybe$Nothing,
	'');
var author$project$Incubator$Todoist$Command$ItemClose = function (a) {
	return {$: 10, a: a};
};
var author$project$Incubator$Todoist$Command$RealItem = function (a) {
	return {$: 0, a: a};
};
var author$project$Integrations$Todoist$sendChanges = F2(
	function (localData, changeList) {
		return A4(
			author$project$Incubator$Todoist$sync,
			localData.bN,
			author$project$Integrations$Todoist$devSecret,
			_List_fromArray(
				[1, 0]),
			changeList);
	});
var author$project$SmartTime$Human$Calendar$Month$next = function (givenMonth) {
	switch (givenMonth) {
		case 0:
			return 1;
		case 1:
			return 2;
		case 2:
			return 3;
		case 3:
			return 4;
		case 4:
			return 5;
		case 5:
			return 6;
		case 6:
			return 7;
		case 7:
			return 8;
		case 8:
			return 9;
		case 9:
			return 10;
		case 10:
			return 11;
		default:
			return 0;
	}
};
var author$project$SmartTime$Human$Calendar$calculate = F3(
	function (givenYear, givenMonth, dayCounter) {
		calculate:
		while (true) {
			var monthsLeftToGo = givenMonth !== 11;
			var monthSize = A2(author$project$SmartTime$Human$Calendar$Month$length, givenYear, givenMonth);
			var monthOverFlow = _Utils_cmp(dayCounter, monthSize) > 0;
			if (monthsLeftToGo && monthOverFlow) {
				var remainingDaysToCount = dayCounter - monthSize;
				var nextMonthToCheck = author$project$SmartTime$Human$Calendar$Month$next(givenMonth);
				var $temp$givenYear = givenYear,
					$temp$givenMonth = nextMonthToCheck,
					$temp$dayCounter = remainingDaysToCount;
				givenYear = $temp$givenYear;
				givenMonth = $temp$givenMonth;
				dayCounter = $temp$dayCounter;
				continue calculate;
			} else {
				return {y: dayCounter, x: givenMonth, t: givenYear};
			}
		}
	});
var author$project$SmartTime$Human$Calendar$divWithRemainder = F2(
	function (a, b) {
		return _Utils_Tuple2(
			(a / b) | 0,
			A2(elm$core$Basics$modBy, b, a));
	});
var author$project$SmartTime$Human$Calendar$year = function (_n0) {
	var givenDays = _n0;
	var daysInYear = 365;
	var daysInLeapCycle = 146097;
	var daysInFourYears = 1461;
	var daysInCentury = 36524;
	var _n1 = A2(author$project$SmartTime$Human$Calendar$divWithRemainder, givenDays, daysInLeapCycle);
	var leapCyclesPassed = _n1.a;
	var daysWithoutLeapCycles = _n1.b;
	var yearsFromLeapCycles = leapCyclesPassed * 400;
	var _n2 = A2(author$project$SmartTime$Human$Calendar$divWithRemainder, daysWithoutLeapCycles, daysInCentury);
	var centuriesPassed = _n2.a;
	var daysWithoutCenturies = _n2.b;
	var yearsFromCenturies = centuriesPassed * 100;
	var _n3 = A2(author$project$SmartTime$Human$Calendar$divWithRemainder, daysWithoutCenturies, daysInFourYears);
	var fourthYearsPassed = _n3.a;
	var daysWithoutFourthYears = _n3.b;
	var _n4 = A2(author$project$SmartTime$Human$Calendar$divWithRemainder, daysWithoutFourthYears, daysInYear);
	var wholeYears = _n4.a;
	var daysWithoutYears = _n4.b;
	var newYear = (!daysWithoutYears) ? 0 : 1;
	var yearsFromFourYearBlocks = fourthYearsPassed * 4;
	var totalYears = (((yearsFromLeapCycles + yearsFromCenturies) + yearsFromFourYearBlocks) + wholeYears) + newYear;
	return totalYears;
};
var author$project$SmartTime$Human$Calendar$toOrdinalDate = function (_n0) {
	var rd = _n0;
	var givenYear = author$project$SmartTime$Human$Calendar$year(rd);
	return {
		cc: rd - author$project$SmartTime$Human$Calendar$Year$daysBefore(givenYear),
		t: givenYear
	};
};
var author$project$SmartTime$Human$Calendar$toParts = function (_n0) {
	var rd = _n0;
	var date = author$project$SmartTime$Human$Calendar$toOrdinalDate(rd);
	return A3(author$project$SmartTime$Human$Calendar$calculate, date.t, 0, date.cc);
};
var author$project$SmartTime$Human$Calendar$dayOfMonth = A2(
	elm$core$Basics$composeR,
	author$project$SmartTime$Human$Calendar$toParts,
	function ($) {
		return $.y;
	});
var author$project$SmartTime$Human$Calendar$month = A2(
	elm$core$Basics$composeR,
	author$project$SmartTime$Human$Calendar$toParts,
	function ($) {
		return $.x;
	});
var elm$core$Basics$clamp = F3(
	function (low, high, number) {
		return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
	});
var elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
var elm$core$String$repeatHelp = F3(
	function (n, chunk, result) {
		return (n <= 0) ? result : A3(
			elm$core$String$repeatHelp,
			n >> 1,
			_Utils_ap(chunk, chunk),
			(!(n & 1)) ? result : _Utils_ap(result, chunk));
	});
var elm$core$String$repeat = F2(
	function (n, chunk) {
		return A3(elm$core$String$repeatHelp, n, chunk, '');
	});
var author$project$SmartTime$Human$Calendar$padNumber = F2(
	function (targetLength, numString) {
		var minLength = A3(elm$core$Basics$clamp, 1, targetLength, targetLength);
		var zerosToAdd = minLength - elm$core$String$length(numString);
		return _Utils_ap(
			A2(elm$core$String$repeat, zerosToAdd, '0'),
			numString);
	});
var author$project$SmartTime$Human$Calendar$Month$toInt = function (givenMonth) {
	switch (givenMonth) {
		case 0:
			return 1;
		case 1:
			return 2;
		case 2:
			return 3;
		case 3:
			return 4;
		case 4:
			return 5;
		case 5:
			return 6;
		case 6:
			return 7;
		case 7:
			return 8;
		case 8:
			return 9;
		case 9:
			return 10;
		case 10:
			return 11;
		default:
			return 12;
	}
};
var author$project$SmartTime$Human$Calendar$Year$toAstronomicalString = function (year) {
	var yearInt = year;
	return elm$core$String$fromInt(yearInt);
};
var author$project$SmartTime$Human$Calendar$toStandardString = function (givenDate) {
	var yearPart = A2(
		author$project$SmartTime$Human$Calendar$padNumber,
		4,
		author$project$SmartTime$Human$Calendar$Year$toAstronomicalString(
			author$project$SmartTime$Human$Calendar$year(givenDate)));
	var monthPart = A2(
		author$project$SmartTime$Human$Calendar$padNumber,
		2,
		elm$core$String$fromInt(
			author$project$SmartTime$Human$Calendar$Month$toInt(
				author$project$SmartTime$Human$Calendar$month(givenDate))));
	var dayPart = A2(
		author$project$SmartTime$Human$Calendar$padNumber,
		2,
		elm$core$String$fromInt(
			author$project$SmartTime$Human$Calendar$Month$dayToInt(
				author$project$SmartTime$Human$Calendar$dayOfMonth(givenDate))));
	return yearPart + ('-' + (monthPart + ('-' + dayPart)));
};
var author$project$SmartTime$Human$Duration$breakdownHMSM = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var days = _n0.da;
	var hours = _n0.dk;
	var minutes = _n0.dD;
	var seconds = _n0.d_;
	var milliseconds = _n0.dB;
	return _List_fromArray(
		[
			author$project$SmartTime$Human$Duration$Hours(
			author$project$SmartTime$Duration$inWholeHours(duration)),
			author$project$SmartTime$Human$Duration$Minutes(minutes),
			author$project$SmartTime$Human$Duration$Seconds(seconds),
			author$project$SmartTime$Human$Duration$Milliseconds(milliseconds)
		]);
};
var author$project$SmartTime$Human$Duration$padNumber = F2(
	function (targetLength, numString) {
		var minLength = A3(elm$core$Basics$clamp, 1, targetLength, targetLength);
		var zerosToAdd = minLength - elm$core$String$length(numString);
		return _Utils_ap(
			A2(elm$core$String$repeat, zerosToAdd, '0'),
			numString);
	});
var author$project$SmartTime$Human$Duration$justNumberPadded = function (unit) {
	switch (unit.$) {
		case 0:
			var _int = unit.a;
			return A2(
				author$project$SmartTime$Human$Duration$padNumber,
				3,
				elm$core$String$fromInt(_int));
		case 1:
			var _int = unit.a;
			return A2(
				author$project$SmartTime$Human$Duration$padNumber,
				2,
				elm$core$String$fromInt(_int));
		case 2:
			var _int = unit.a;
			return A2(
				author$project$SmartTime$Human$Duration$padNumber,
				2,
				elm$core$String$fromInt(_int));
		case 3:
			var _int = unit.a;
			return A2(
				author$project$SmartTime$Human$Duration$padNumber,
				2,
				elm$core$String$fromInt(_int));
		default:
			var _int = unit.a;
			return A2(
				author$project$SmartTime$Human$Duration$padNumber,
				2,
				elm$core$String$fromInt(_int));
	}
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
var elm_community$list_extra$List$Extra$init = function (items) {
	if (!items.b) {
		return elm$core$Maybe$Nothing;
	} else {
		var nonEmptyList = items;
		return A2(
			elm$core$Maybe$map,
			elm$core$List$reverse,
			elm$core$List$tail(
				elm$core$List$reverse(nonEmptyList)));
	}
};
var author$project$SmartTime$Human$Duration$colonSeparated = function (breakdownList) {
	var separate = function (list) {
		return elm$core$String$concat(
			A2(
				elm$core$List$intersperse,
				':',
				A2(elm$core$List$map, author$project$SmartTime$Human$Duration$justNumberPadded, list)));
	};
	var _n0 = elm_community$list_extra$List$Extra$last(breakdownList);
	if ((!_n0.$) && (!_n0.a.$)) {
		var ms = _n0.a.a;
		var withoutLast = A2(
			elm$core$Maybe$withDefault,
			_List_Nil,
			elm_community$list_extra$List$Extra$init(breakdownList));
		return separate(withoutLast) + ('.' + A2(
			author$project$SmartTime$Human$Duration$padNumber,
			3,
			elm$core$String$fromInt(ms)));
	} else {
		return separate(breakdownList);
	}
};
var author$project$SmartTime$Human$Clock$toStandardString = function (timeOfDay) {
	return author$project$SmartTime$Human$Duration$colonSeparated(
		author$project$SmartTime$Human$Duration$breakdownHMSM(timeOfDay));
};
var author$project$SmartTime$Human$Moment$toStandardString = function (moment) {
	var _n0 = A2(author$project$SmartTime$Human$Moment$humanize, author$project$SmartTime$Human$Moment$utc, moment);
	var date = _n0.a;
	var time = _n0.b;
	return author$project$SmartTime$Human$Calendar$toStandardString(date) + ('T' + (author$project$SmartTime$Human$Clock$toStandardString(time) + 'Z'));
};
var author$project$SmartTime$Moment$toSmartInt = function (_n0) {
	var dur = _n0;
	return author$project$SmartTime$Duration$inMs(dur);
};
var author$project$Task$Progress$getPortion = function (_n0) {
	var part = _n0.a;
	return part;
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
			return $.bQ;
		}(task));
};
var author$project$TaskList$NoOp = {$: 10};
var author$project$TaskList$TodoistServerResponse = function (a) {
	return {$: 11, a: a};
};
var elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var elm$browser$Browser$Dom$NotFound = elm$core$Basics$identity;
var elm$core$Basics$never = function (_n0) {
	never:
	while (true) {
		var nvr = _n0;
		var $temp$_n0 = nvr;
		_n0 = $temp$_n0;
		continue never;
	}
};
var elm$core$Task$Perform = elm$core$Basics$identity;
var elm$core$Task$init = elm$core$Task$succeed(0);
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
		var task = _n0;
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
				return 0;
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$map,
					elm$core$Task$spawnCmd(router),
					commands)));
	});
var elm$core$Task$onSelfMsg = F3(
	function (_n0, _n1, _n2) {
		return elm$core$Task$succeed(0);
	});
var elm$core$Task$cmdMap = F2(
	function (tagger, _n0) {
		var task = _n0;
		return A2(elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager(elm$core$Task$init, elm$core$Task$onEffects, elm$core$Task$onSelfMsg, elm$core$Task$cmdMap);
var elm$core$Task$command = _Platform_leaf('Task');
var elm$core$Task$perform = F2(
	function (toMessage, task) {
		return elm$core$Task$command(
			A2(elm$core$Task$map, toMessage, task));
	});
var elm$json$Json$Decode$map2 = _Json_map2;
var elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
var elm$browser$Browser$Dom$focus = _Browser_call('focus');
var elm$core$Platform$Cmd$batch = _Platform_batch;
var elm$core$Platform$Cmd$map = _Platform_map;
var elm$core$Platform$Cmd$none = elm$core$Platform$Cmd$batch(_List_Nil);
var elm$core$Task$onError = _Scheduler_onError;
var elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return elm$core$Task$command(
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
					task)));
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
			case 3:
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
								e8: A3(
									elm_community$intdict$IntDict$insert,
									author$project$SmartTime$Moment$toSmartInt(env.ea),
									A2(
										author$project$Task$Task$newTask,
										author$project$Task$Task$normalizeTitle(newTaskTitle),
										author$project$SmartTime$Moment$toSmartInt(env.ea)),
									app.e8)
							}),
						elm$core$Platform$Cmd$none);
				}
			case 9:
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
			case 1:
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
							e8: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTask),
								app.e8)
						}),
					A2(
						elm$core$Task$attempt,
						function (_n3) {
							return author$project$TaskList$NoOp;
						},
						focus));
			case 2:
				var id = msg.a;
				var task = msg.b;
				var updateTitle = function (t) {
					return _Utils_update(
						t,
						{ba: task});
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							e8: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTitle),
								app.e8)
						}),
					elm$core$Platform$Cmd$none);
			case 8:
				var id = msg.a;
				var field = msg.b;
				var date = msg.c;
				var updateTask = function (t) {
					return _Utils_update(
						t,
						{et: date});
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							e8: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTask),
								app.e8)
						}),
					elm$core$Platform$Cmd$none);
			case 4:
				var id = msg.a;
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							e8: A2(elm_community$intdict$IntDict$remove, id, app.e8)
						}),
					elm$core$Platform$Cmd$none);
			case 5:
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							e8: A2(
								elm_community$intdict$IntDict$filter,
								F2(
									function (_n4, t) {
										return !author$project$Task$Task$completed(t);
									}),
								app.e8)
						}),
					elm$core$Platform$Cmd$none);
			case 6:
				var id = msg.a;
				var new_completion = msg.b;
				var updateTask = function (t) {
					return _Utils_update(
						t,
						{bQ: new_completion});
				};
				var maybeTaskTitle = A2(
					elm$core$Maybe$map,
					function ($) {
						return $.ba;
					},
					A2(elm_community$intdict$IntDict$get, id, app.e8));
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							e8: A3(
								elm_community$intdict$IntDict$update,
								id,
								elm$core$Maybe$map(updateTask),
								app.e8)
						}),
					author$project$Task$Progress$isMax(new_completion) ? elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[
								author$project$External$Commands$toast(
								'Marked as complete: ' + A2(elm$core$Maybe$withDefault, 'unknown task', maybeTaskTitle)),
								A2(
								elm$core$Platform$Cmd$map,
								author$project$TaskList$TodoistServerResponse,
								A2(
									author$project$Integrations$Todoist$sendChanges,
									app.cK,
									_List_fromArray(
										[
											_Utils_Tuple2(
											author$project$SmartTime$Human$Moment$toStandardString(env.ea),
											author$project$Incubator$Todoist$Command$ItemClose(
												author$project$Incubator$Todoist$Command$RealItem(id)))
										])))
							])) : elm$core$Platform$Cmd$none);
			case 7:
				var task = msg.a;
				var focused = msg.b;
				return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
			case 10:
				return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
			case 11:
				var response = msg.a;
				var _n5 = A2(author$project$Integrations$Todoist$handle, response, app);
				var newAppData = _n5.a;
				var whatHappened = _n5.b;
				return _Utils_Tuple3(
					state,
					newAppData,
					author$project$External$Commands$toast(whatHappened));
			default:
				var newList = msg.a;
				return _Utils_Tuple3(
					function () {
						var filterList = state.a;
						var expandedTaskMaybe = state.b;
						var newTaskField = state.c;
						return A3(author$project$TaskList$Normal, newList, expandedTaskMaybe, newTaskField);
					}(),
					app,
					elm$core$Platform$Cmd$none);
		}
	});
var author$project$SmartTime$Human$Clock$endOfDay = author$project$SmartTime$Duration$aDay;
var author$project$SmartTime$Human$Calendar$compareBasic = F2(
	function (_n0, _n1) {
		var a = _n0;
		var b = _n1;
		return A2(elm$core$Basics$compare, a, b);
	});
var author$project$SmartTime$Human$Moment$fromFuzzyWithDefaultTime = F3(
	function (zone, defaultTime, fuzzy) {
		switch (fuzzy.$) {
			case 2:
				var date = fuzzy.a;
				return A3(author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, defaultTime);
			case 1:
				var _n1 = fuzzy.a;
				var date = _n1.a;
				var time = _n1.b;
				return A3(author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, time);
			default:
				var moment = fuzzy.a;
				return moment;
		}
	});
var author$project$SmartTime$Moment$compareBasic = F2(
	function (_n0, _n1) {
		var time1 = _n0;
		var time2 = _n1;
		return A2(
			elm$core$Basics$compare,
			author$project$SmartTime$Duration$inMs(time1),
			author$project$SmartTime$Duration$inMs(time2));
	});
var author$project$SmartTime$Human$Moment$compareFuzzyBasic = F4(
	function (zone, defaultTime, fuzzyA, fuzzyB) {
		var _n0 = _Utils_Tuple2(fuzzyA, fuzzyB);
		if ((_n0.a.$ === 2) && (_n0.b.$ === 2)) {
			var dateA = _n0.a.a;
			var dateB = _n0.b.a;
			return A2(author$project$SmartTime$Human$Calendar$compareBasic, dateA, dateB);
		} else {
			return A2(
				author$project$SmartTime$Moment$compareBasic,
				A3(author$project$SmartTime$Human$Moment$fromFuzzyWithDefaultTime, zone, defaultTime, fuzzyA),
				A3(author$project$SmartTime$Human$Moment$fromFuzzyWithDefaultTime, zone, defaultTime, fuzzyB));
		}
	});
var author$project$Task$Task$compareSoonness = F3(
	function (zone, taskA, taskB) {
		var _n0 = _Utils_Tuple2(taskA.et, taskB.et);
		if (!_n0.a.$) {
			if (!_n0.b.$) {
				var fuzzyMomentA = _n0.a.a;
				var fuzzyMomentB = _n0.b.a;
				return A4(author$project$SmartTime$Human$Moment$compareFuzzyBasic, zone, author$project$SmartTime$Human$Clock$endOfDay, fuzzyMomentA, fuzzyMomentB);
			} else {
				var _n3 = _n0.b;
				return 0;
			}
		} else {
			if (_n0.b.$ === 1) {
				var _n1 = _n0.a;
				var _n2 = _n0.b;
				return 1;
			} else {
				var _n4 = _n0.a;
				return 2;
			}
		}
	});
var elm$core$List$sortWith = _List_sortWith;
var author$project$Task$Task$deepSort = F2(
	function (compareFuncs, listToSort) {
		var deepCompare = F3(
			function (funcs, a, b) {
				deepCompare:
				while (true) {
					if (!funcs.b) {
						return 1;
					} else {
						var nextCompareFunc = funcs.a;
						var laterCompareFuncs = funcs.b;
						var check = A2(nextCompareFunc, a, b);
						if (check === 1) {
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
			elm$core$List$sortWith,
			deepCompare(compareFuncs),
			listToSort);
	});
var author$project$Task$Task$prioritize = F3(
	function (now, zone, taskList) {
		var comparePropInverted = F3(
			function (prop, a, b) {
				return A2(
					elm$core$Basics$compare,
					prop(b),
					prop(a));
			});
		var compareProp = F3(
			function (prop, a, b) {
				return A2(
					elm$core$Basics$compare,
					prop(a),
					prop(b));
			});
		return A2(
			author$project$Task$Task$deepSort,
			_List_fromArray(
				[
					author$project$Task$Task$compareSoonness(zone),
					comparePropInverted(
					function ($) {
						return $.eG;
					})
				]),
			taskList);
	});
var author$project$Activity$Switching$determineNextTask = F2(
	function (app, env) {
		return elm$core$List$head(
			A3(
				author$project$Task$Task$prioritize,
				env.ea,
				env.e9,
				A2(
					elm$core$List$filter,
					A2(elm$core$Basics$composeR, author$project$Task$Task$completed, elm$core$Basics$not),
					elm_community$intdict$IntDict$values(app.e8))));
	});
var author$project$TaskList$UpdateProgress = F2(
	function (a, b) {
		return {$: 6, a: a, b: b};
	});
var author$project$TaskList$urlTriggers = F2(
	function (app, env) {
		var normalizedEntry = function (_n0) {
			var id = _n0.a;
			var task = _n0.b;
			return _Utils_Tuple2(
				task.ba,
				A2(
					author$project$TaskList$UpdateProgress,
					id,
					author$project$Task$Progress$maximize(task.bQ)));
		};
		var tasksWithNames = A2(
			elm$core$List$map,
			normalizedEntry,
			elm_community$intdict$IntDict$toList(app.e8));
		var noNextTaskEntry = _List_fromArray(
			[
				_Utils_Tuple2('next', author$project$TaskList$NoOp)
			]);
		var buildNextTaskEntry = function (next) {
			return _List_fromArray(
				[
					_Utils_Tuple2(
					'next',
					A2(
						author$project$TaskList$UpdateProgress,
						next.dl,
						author$project$Task$Progress$maximize(next.bQ)))
				]);
		};
		var nextTaskEntry = A2(
			elm$core$Maybe$map,
			buildNextTaskEntry,
			A2(author$project$Activity$Switching$determineNextTask, app, env));
		var allEntries = _Utils_ap(
			A2(elm$core$Maybe$withDefault, noNextTaskEntry, nextTaskEntry),
			tasksWithNames);
		return _List_fromArray(
			[
				_Utils_Tuple2(
				'complete',
				elm$core$Dict$fromList(allEntries))
			]);
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
	return author$project$Activity$Activity$currentActivityID(app.cH);
};
var author$project$ID$read = function (_n0) {
	var _int = _n0;
	return _int;
};
var author$project$Activity$Activity$getActivity = F2(
	function (activityId, activities) {
		var _n0 = A2(
			elm_community$intdict$IntDict$get,
			author$project$ID$read(activityId),
			activities);
		if (!_n0.$) {
			var activity = _n0.a;
			return activity;
		} else {
			return author$project$Activity$Activity$defaults(0);
		}
	});
var author$project$Activity$Activity$getName = function (activity) {
	return A2(
		elm$core$Maybe$withDefault,
		'?',
		elm$core$List$head(activity.c));
};
var author$project$SmartTime$Duration$isPositive = function (_n0) {
	var _int = _n0;
	return _int > 0;
};
var author$project$SmartTime$Human$Duration$withAbbreviation = function (unit) {
	switch (unit.$) {
		case 0:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'ms';
		case 1:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'sec';
		case 2:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'min';
		case 3:
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
var author$project$SmartTime$Human$Duration$breakdownNonzero = function (duration) {
	var makeOptional = function (_n1) {
		var tagger = _n1.a;
		var amount = _n1.b;
		return (amount > 0) ? elm$core$Maybe$Just(
			tagger(amount)) : elm$core$Maybe$Nothing;
	};
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var days = _n0.da;
	var hours = _n0.dk;
	var minutes = _n0.dD;
	var seconds = _n0.d_;
	var milliseconds = _n0.dB;
	var maybeList = A2(
		elm$core$List$map,
		makeOptional,
		_List_fromArray(
			[
				_Utils_Tuple2(author$project$SmartTime$Human$Duration$Days, days),
				_Utils_Tuple2(author$project$SmartTime$Human$Duration$Hours, hours),
				_Utils_Tuple2(author$project$SmartTime$Human$Duration$Minutes, minutes),
				_Utils_Tuple2(author$project$SmartTime$Human$Duration$Seconds, seconds),
				_Utils_Tuple2(author$project$SmartTime$Human$Duration$Milliseconds, milliseconds)
			]));
	return A2(elm$core$List$filterMap, elm$core$Basics$identity, maybeList);
};
var author$project$SmartTime$Human$Duration$say = A2(elm$core$Basics$composeR, author$project$SmartTime$Human$Duration$breakdownNonzero, author$project$SmartTime$Human$Duration$abbreviatedSpaced);
var author$project$Activity$Activity$statusToString = function (onTaskStatus) {
	switch (onTaskStatus.$) {
		case 0:
			var _for = onTaskStatus.a;
			return 'On Task, for the next ' + author$project$SmartTime$Human$Duration$say(_for);
		case 1:
			var excusedLeft = onTaskStatus.a;
			return author$project$SmartTime$Duration$isPositive(excusedLeft) ? ('Excused, for the next ' + author$project$SmartTime$Human$Duration$say(excusedLeft)) : 'Off Task';
		default:
			return 'Done';
	}
};
var author$project$Activity$Activity$excusableFor = function (activity) {
	var _n0 = activity.a;
	switch (_n0.$) {
		case 0:
			return _Utils_Tuple2(
				author$project$SmartTime$Human$Duration$Minutes(0),
				author$project$SmartTime$Human$Duration$Minutes(0));
		case 1:
			var durationPerPeriod = _n0.a;
			return durationPerPeriod;
		default:
			return _Utils_Tuple2(
				author$project$SmartTime$Human$Duration$Hours(24),
				author$project$SmartTime$Human$Duration$Hours(24));
	}
};
var author$project$SmartTime$Human$Duration$dur = author$project$SmartTime$Human$Duration$toDuration;
var author$project$Activity$Measure$excusableLimit = function (activity) {
	return author$project$SmartTime$Human$Duration$dur(
		author$project$Activity$Activity$excusableFor(activity).a);
};
var author$project$SmartTime$Moment$past = F2(
	function (_n0, duration) {
		var time = _n0;
		return A2(author$project$SmartTime$Duration$subtract, time, duration);
	});
var author$project$Activity$Measure$lookBack = F2(
	function (present, humanDuration) {
		return A2(
			author$project$SmartTime$Moment$past,
			present,
			author$project$SmartTime$Human$Duration$dur(humanDuration));
	});
var author$project$Activity$Activity$dummy = author$project$ID$tag(0);
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
			return !A2(author$project$SmartTime$Moment$compare, moment, pastLimit);
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
		var int1 = _n0;
		var int2 = _n1;
		return elm$core$Basics$abs(int1 - int2);
	});
var author$project$SmartTime$Moment$difference = F2(
	function (_n0, _n1) {
		var time1 = _n0;
		var time2 = _n1;
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
var author$project$SmartTime$Duration$combine = function (durationList) {
	return A3(elm$core$List$foldl, author$project$SmartTime$Duration$add, 0, durationList);
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
					app.cH,
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
				A2(author$project$Activity$Measure$sessions, app.cH, old)));
		return elm$core$String$fromInt(
			author$project$SmartTime$Duration$inMinutesRounded(timeSpent));
	});
var author$project$Activity$Activity$AllDone = {$: 2};
var author$project$Activity$Activity$OffTask = function (a) {
	return {$: 1, a: a};
};
var author$project$Activity$Activity$OnTask = function (a) {
	return {$: 0, a: a};
};
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
var author$project$Activity$Switching$determineOnTask = F3(
	function (activityID, app, env) {
		var current = A2(
			author$project$Activity$Activity$getActivity,
			activityID,
			author$project$Activity$Activity$allActivities(app.bH));
		var excusedLeft = A3(
			author$project$Activity$Measure$excusedLeft,
			app.cH,
			env.ea,
			_Utils_Tuple2(activityID, current));
		var _n0 = A2(author$project$Activity$Switching$determineNextTask, app, env);
		if (_n0.$ === 1) {
			return author$project$Activity$Activity$AllDone;
		} else {
			var nextTask = _n0.a;
			var _n1 = nextTask.ek;
			if (_n1.$ === 1) {
				return author$project$Activity$Activity$OffTask(excusedLeft);
			} else {
				var nextActivity = _n1.a;
				return _Utils_eq(nextActivity, activityID) ? author$project$Activity$Activity$OnTask(nextTask.eN) : author$project$Activity$Activity$OffTask(excusedLeft);
			}
		}
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
var author$project$Activity$Switching$exportNextTask = F2(
	function (app, env) {
		var next = A2(author$project$Activity$Switching$determineNextTask, app, env);
		var _export = function (task) {
			return author$project$External$Tasker$variableOut(
				_Utils_Tuple2('NextTaskTitle', task.ba));
		};
		return A2(
			elm$core$Maybe$withDefault,
			elm$core$Platform$Cmd$none,
			A2(elm$core$Maybe$map, _export, next));
	});
var author$project$Activity$Reminder$Notify = function (a) {
	return {$: 0, a: a};
};
var author$project$External$Notification$Default = 0;
var author$project$External$Notification$New = 0;
var author$project$External$Notification$NoBadge = 0;
var author$project$External$Notification$Number = function (a) {
	return {$: 0, a: a};
};
var author$project$External$Notification$Public = {$: 0};
var author$project$External$Notification$blank = {
	bK: '',
	bL: 0,
	bi: '',
	bM: '',
	e: '',
	bO: false,
	bP: false,
	bR: false,
	bT: author$project$External$Notification$Number(0),
	bU: false,
	g: '',
	dl: '',
	b_: '',
	b$: author$project$SmartTime$Duration$fromMs(1000),
	b0: author$project$SmartTime$Duration$fromMs(1000),
	b1: elm$core$Maybe$Nothing,
	b2: false,
	b9: '',
	ca: '',
	cb: '',
	cg: false,
	ch: false,
	ci: '',
	cj: '',
	ck: false,
	cp: 0,
	cq: author$project$External$Notification$Public,
	cr: 0,
	cs: false,
	ct: 0,
	cz: '',
	cB: '',
	cC: 0,
	cE: '',
	cG: '',
	ea: elm$core$Maybe$Nothing,
	cI: author$project$SmartTime$Duration$zero,
	ba: '',
	cJ: '',
	cM: 0,
	cN: '',
	cO: false,
	cP: _List_Nil
};
var author$project$External$Notification$basic = F2(
	function (title, body) {
		return _Utils_update(
			author$project$External$Notification$blank,
			{bi: body, ba: title});
	});
var author$project$Activity$Reminder$reminder = function (_n0) {
	var scheduledFor = _n0.a6;
	var title = _n0.ba;
	var subtitle = _n0.a8;
	return {
		bg: _List_fromArray(
			[
				author$project$Activity$Reminder$Notify(
				A2(author$project$External$Notification$basic, title, subtitle))
			]),
		bC: scheduledFor
	};
};
var author$project$SmartTime$Duration$compare = F2(
	function (_n0, _n1) {
		var int1 = _n0;
		var int2 = _n1;
		return A2(elm$core$Basics$compare, int1, int2);
	});
var author$project$SmartTime$Human$Duration$breakdownHM = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var minutes = _n0.dD;
	return _List_fromArray(
		[
			author$project$SmartTime$Human$Duration$Hours(
			author$project$SmartTime$Duration$inWholeHours(duration)),
			author$project$SmartTime$Human$Duration$Minutes(minutes)
		]);
};
var author$project$SmartTime$Moment$future = F2(
	function (_n0, duration) {
		var time = _n0;
		return A2(author$project$SmartTime$Duration$add, time, duration);
	});
var elm_community$list_extra$List$Extra$takeWhile = function (predicate) {
	var takeWhileMemo = F2(
		function (memo, list) {
			takeWhileMemo:
			while (true) {
				if (!list.b) {
					return elm$core$List$reverse(memo);
				} else {
					var x = list.a;
					var xs = list.b;
					if (predicate(x)) {
						var $temp$memo = A2(elm$core$List$cons, x, memo),
							$temp$list = xs;
						memo = $temp$memo;
						list = $temp$list;
						continue takeWhileMemo;
					} else {
						return elm$core$List$reverse(memo);
					}
				}
			}
		});
	return takeWhileMemo(_List_Nil);
};
var author$project$Activity$Reminder$scheduleExcusedReminders = F3(
	function (now, excusedLimit, timeLeft) {
		var write = function (durLeft) {
			return author$project$SmartTime$Human$Duration$abbreviatedSpaced(
				author$project$SmartTime$Human$Duration$breakdownHM(durLeft));
		};
		var timesUp = A2(author$project$SmartTime$Moment$future, now, timeLeft);
		var interimReminders = _List_fromArray(
			[
				author$project$Activity$Reminder$reminder(
				{
					a6: A2(
						author$project$SmartTime$Moment$future,
						now,
						author$project$SmartTime$Human$Duration$dur(
							author$project$SmartTime$Human$Duration$Minutes(10))),
					a8: 'Get back on task as soon as possible - do this later!',
					ba: 'Distraction taken care of?'
				}),
				author$project$Activity$Reminder$reminder(
				{
					a6: A2(
						author$project$SmartTime$Moment$future,
						now,
						author$project$SmartTime$Human$Duration$dur(
							author$project$SmartTime$Human$Duration$Minutes(20))),
					a8: 'You have important goals to meet!',
					ba: 'Ready to get back on task?'
				}),
				author$project$Activity$Reminder$reminder(
				{
					a6: A2(
						author$project$SmartTime$Moment$future,
						now,
						author$project$SmartTime$Human$Duration$dur(
							author$project$SmartTime$Human$Duration$Minutes(30))),
					a8: 'Why not put this in your task list for later?',
					ba: 'Can this wait?'
				})
			]);
		var halfLeftThisSession = A2(author$project$SmartTime$Duration$scale, timeLeft, 1 / 2);
		var firstIsLess = F2(
			function (first, last) {
				return !A2(author$project$SmartTime$Duration$compare, first, last);
			});
		var firstIsGreater = F2(
			function (first, last) {
				return A2(author$project$SmartTime$Duration$compare, first, last) === 2;
			});
		var gettingCloseList = A2(
			elm_community$list_extra$List$Extra$takeWhile,
			firstIsGreater(halfLeftThisSession),
			_List_fromArray(
				[
					author$project$SmartTime$Human$Duration$dur(
					author$project$SmartTime$Human$Duration$Minutes(1)),
					author$project$SmartTime$Human$Duration$dur(
					author$project$SmartTime$Human$Duration$Minutes(2)),
					author$project$SmartTime$Human$Duration$dur(
					author$project$SmartTime$Human$Duration$Minutes(3)),
					author$project$SmartTime$Human$Duration$dur(
					author$project$SmartTime$Human$Duration$Minutes(5)),
					author$project$SmartTime$Human$Duration$dur(
					author$project$SmartTime$Human$Duration$Minutes(10)),
					author$project$SmartTime$Human$Duration$dur(
					author$project$SmartTime$Human$Duration$Minutes(30))
				]));
		var substantialTimeLeft = A2(
			firstIsGreater,
			timeLeft,
			author$project$SmartTime$Duration$fromSeconds(30.0));
		var beforeTimesUp = function (timeBefore) {
			return A2(author$project$SmartTime$Moment$past, timesUp, timeBefore);
		};
		var buildGettingCloseReminder = function (amountLeft) {
			return author$project$Activity$Reminder$reminder(
				{
					a6: beforeTimesUp(amountLeft),
					a8: 'Excused for up to ' + write(excusedLimit),
					ba: 'Finish up! Only ' + (write(amountLeft) + ' left!')
				});
		};
		return substantialTimeLeft ? A2(elm$core$List$map, buildGettingCloseReminder, gettingCloseList) : _List_Nil;
	});
var author$project$Activity$Reminder$reminder3 = F3(
	function (scheduledFor, title, subtitle) {
		return {
			bg: _List_fromArray(
				[
					author$project$Activity$Reminder$Notify(
					A2(author$project$External$Notification$basic, title, subtitle))
				]),
			bC: scheduledFor
		};
	});
var author$project$Activity$Reminder$scheduleOffTaskReminders = function (now) {
	return _List_fromArray(
		[
			A3(author$project$Activity$Reminder$reminder3, now, 'Get back on task now!', 'Off task, not excused!')
		]);
};
var author$project$Activity$Reminder$scheduleOnTaskReminders = F2(
	function (now, fromNow) {
		var fractionLeft = function (denom) {
			return A2(
				author$project$SmartTime$Moment$future,
				now,
				A2(
					author$project$SmartTime$Duration$subtract,
					fromNow,
					A2(author$project$SmartTime$Duration$scale, fromNow, 1 / denom)));
		};
		return _List_fromArray(
			[
				A3(
				author$project$Activity$Reminder$reminder3,
				fractionLeft(2),
				'Half-way done!',
				'1/2 time left for activity.'),
				A3(
				author$project$Activity$Reminder$reminder3,
				fractionLeft(3),
				'Two-thirds done!',
				'1/3 time left for activity.'),
				A3(
				author$project$Activity$Reminder$reminder3,
				fractionLeft(4),
				'Three-Quarters done!',
				'1/4 time left for activity.'),
				A3(
				author$project$Activity$Reminder$reminder3,
				A2(author$project$SmartTime$Moment$future, now, fromNow),
				'Time\'s up!',
				'Reached maximum time allowed for this.')
			]);
	});
var author$project$Activity$Switching$scheduleReminders = F4(
	function (env, timeline, onTaskStatus, _n0) {
		var activityID = _n0.a;
		var newActivity = _n0.b;
		switch (onTaskStatus.$) {
			case 0:
				var timeLeft = onTaskStatus.a;
				return A2(author$project$Activity$Reminder$scheduleOnTaskReminders, env.ea, timeLeft);
			case 1:
				var excusedLeft = onTaskStatus.a;
				return author$project$SmartTime$Duration$isPositive(excusedLeft) ? A3(
					author$project$Activity$Reminder$scheduleExcusedReminders,
					env.ea,
					author$project$Activity$Measure$excusableLimit(newActivity),
					excusedLeft) : author$project$Activity$Reminder$scheduleOffTaskReminders(env.ea);
			default:
				return _List_Nil;
		}
	});
var author$project$SmartTime$Human$Duration$breakdownMS = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var seconds = _n0.d_;
	return _List_fromArray(
		[
			author$project$SmartTime$Human$Duration$Minutes(
			author$project$SmartTime$Duration$inWholeMinutes(duration)),
			author$project$SmartTime$Human$Duration$Seconds(seconds)
		]);
};
var author$project$SmartTime$Human$Duration$withLetter = function (unit) {
	switch (unit.$) {
		case 0:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'ms';
		case 1:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 's';
		case 2:
			var _int = unit.a;
			return elm$core$String$fromInt(_int) + 'm';
		case 3:
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
			A3(author$project$Activity$Measure$excusedUsage, timeline, env.ea, newKV))))))))));
	});
var author$project$External$Tasker$exit = _Platform_outgoingPort(
	'exit',
	function ($) {
		return elm$json$Json$Encode$null;
	});
var author$project$External$Commands$hideWindow = author$project$External$Tasker$exit(0);
var author$project$External$Notification$encodeDuration = function (dur) {
	return elm$json$Json$Encode$int(
		author$project$SmartTime$Duration$inMs(dur));
};
var author$project$External$Notification$encodeMediaInfo = function (v) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				elm$json$Json$Encode$string(v.ba))
			]));
};
var author$project$External$Notification$encodePriority = function (v) {
	switch (v) {
		case 0:
			return elm$json$Json$Encode$int(0);
		case 1:
			return elm$json$Json$Encode$int(-1);
		case 2:
			return elm$json$Json$Encode$int(1);
		case 3:
			return elm$json$Json$Encode$int(-2);
		default:
			return elm$json$Json$Encode$int(2);
	}
};
var author$project$External$Notification$encodeVibrationPattern = function (durs) {
	return elm$json$Json$Encode$string(
		elm$core$String$concat(
			A2(
				elm$core$List$map,
				A2(elm$core$Basics$composeL, elm$core$String$fromInt, author$project$SmartTime$Duration$inMs),
				durs)));
};
var author$project$SmartTime$Moment$unixEpoch = function () {
	var jan1st1970_rataDie = 719163;
	return A2(author$project$SmartTime$Duration$scale, author$project$SmartTime$Duration$aDay, jan1st1970_rataDie);
}();
var author$project$SmartTime$Moment$toUnixTime = function (givenMoment) {
	return A3(author$project$SmartTime$Moment$toInt, givenMoment, 0, author$project$SmartTime$Moment$unixEpoch) / 1000;
};
var author$project$SmartTime$Moment$toUnixTimeInt = function (mo) {
	return elm$core$Basics$floor(
		author$project$SmartTime$Moment$toUnixTime(mo));
};
var author$project$External$Notification$encodeNotification = function (v) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$string(v.dl)),
				_Utils_Tuple2(
				'persistent',
				elm$json$Json$Encode$bool(v.cg)),
				_Utils_Tuple2(
				'timeout',
				author$project$External$Notification$encodeDuration(v.cI)),
				_Utils_Tuple2(
				'update',
				function () {
					var _n0 = v.cM;
					switch (_n0) {
						case 0:
							return elm$json$Json$Encode$string('New');
						case 1:
							return elm$json$Json$Encode$string('Replace');
						default:
							return elm$json$Json$Encode$string('Append');
					}
				}()),
				_Utils_Tuple2(
				'priority',
				author$project$External$Notification$encodePriority(v.cp)),
				_Utils_Tuple2(
				'privacy',
				function () {
					var _n1 = v.cq;
					switch (_n1.$) {
						case 0:
							return elm$json$Json$Encode$string('Public');
						case 1:
							return elm$json$Json$Encode$string('Private');
						case 2:
							var publicversion = _n1.a;
							return elm$json$Json$Encode$string('PrivateWithPublicVersion');
						default:
							return elm$json$Json$Encode$string('Secret');
					}
				}()),
				_Utils_Tuple2(
				'useHTML',
				elm$json$Json$Encode$bool(v.cO)),
				_Utils_Tuple2(
				'title',
				elm$json$Json$Encode$string(v.ba)),
				_Utils_Tuple2(
				'title_expanded',
				elm$json$Json$Encode$string(v.cJ)),
				_Utils_Tuple2(
				'body',
				elm$json$Json$Encode$string(v.bi)),
				_Utils_Tuple2(
				'body_expanded',
				elm$json$Json$Encode$string(v.bM)),
				_Utils_Tuple2(
				'subtext',
				elm$json$Json$Encode$string(v.cE)),
				_Utils_Tuple2(
				'detail',
				function () {
					var _n2 = v.bT;
					if (!_n2.$) {
						var n = _n2.a;
						return elm$json$Json$Encode$int(n);
					} else {
						var s = _n2.a;
						return elm$json$Json$Encode$string(s);
					}
				}()),
				_Utils_Tuple2(
				'ticker',
				elm$json$Json$Encode$string(v.cG)),
				_Utils_Tuple2(
				'icon',
				elm$json$Json$Encode$string(v.g)),
				_Utils_Tuple2(
				'status_icon',
				elm$json$Json$Encode$string(v.cB)),
				_Utils_Tuple2(
				'status_text_size',
				elm$json$Json$Encode$int(v.cC)),
				_Utils_Tuple2(
				'background_color',
				elm$json$Json$Encode$string(v.bK)),
				_Utils_Tuple2(
				'color_from_media',
				elm$json$Json$Encode$bool(v.bP)),
				_Utils_Tuple2(
				'badge',
				function () {
					var _n3 = v.bL;
					switch (_n3) {
						case 0:
							return elm$json$Json$Encode$string('NoBadge');
						case 1:
							return elm$json$Json$Encode$string('SmallIcon');
						default:
							return elm$json$Json$Encode$string('LargeIcon');
					}
				}()),
				_Utils_Tuple2(
				'picture',
				elm$json$Json$Encode$string(v.ci)),
				_Utils_Tuple2(
				'picture_skip_cache',
				elm$json$Json$Encode$bool(v.ck)),
				_Utils_Tuple2(
				'picture_expanded_icon',
				elm$json$Json$Encode$string(v.cj)),
				_Utils_Tuple2(
				'media_layout',
				elm$json$Json$Encode$bool(v.b2)),
				_Utils_Tuple2(
				'media',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$External$Notification$encodeMediaInfo, v.b1)),
				_Utils_Tuple2(
				'url',
				elm$json$Json$Encode$string(v.cN)),
				_Utils_Tuple2(
				'on_create',
				elm$json$Json$Encode$string(v.b9)),
				_Utils_Tuple2(
				'on_touch',
				elm$json$Json$Encode$string(v.cb)),
				_Utils_Tuple2(
				'on_dismiss',
				elm$json$Json$Encode$string(v.ca)),
				_Utils_Tuple2(
				'dismiss_on_touch',
				elm$json$Json$Encode$bool(v.bU)),
				_Utils_Tuple2(
				'time',
				A2(
					elm_community$json_extra$Json$Encode$Extra$maybe,
					elm$json$Json$Encode$int,
					A2(elm$core$Maybe$map, author$project$SmartTime$Moment$toUnixTimeInt, v.ea))),
				_Utils_Tuple2(
				'chronometer',
				elm$json$Json$Encode$bool(v.bO)),
				_Utils_Tuple2(
				'countdown',
				elm$json$Json$Encode$bool(v.bR)),
				_Utils_Tuple2(
				'category',
				elm$json$Json$Encode$string(v.e)),
				_Utils_Tuple2(
				'led_color',
				elm$json$Json$Encode$string(v.b_)),
				_Utils_Tuple2(
				'led_on_duration',
				author$project$External$Notification$encodeDuration(v.b0)),
				_Utils_Tuple2(
				'led_off_duration',
				author$project$External$Notification$encodeDuration(v.b$)),
				_Utils_Tuple2(
				'progress_max',
				elm$json$Json$Encode$int(v.ct)),
				_Utils_Tuple2(
				'progress_current',
				elm$json$Json$Encode$int(v.cr)),
				_Utils_Tuple2(
				'progress_indeterminate',
				elm$json$Json$Encode$bool(v.cs)),
				_Utils_Tuple2(
				'sound',
				elm$json$Json$Encode$string(v.cz)),
				_Utils_Tuple2(
				'vibration_pattern',
				author$project$External$Notification$encodeVibrationPattern(v.cP)),
				_Utils_Tuple2(
				'phone_only',
				elm$json$Json$Encode$bool(v.ch))
			]));
};
var author$project$Activity$Reminder$encodeAction = function (v) {
	switch (v.$) {
		case 0:
			var notif = v.a;
			return elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'notify',
						author$project$External$Notification$encodeNotification(notif))
					]));
		case 1:
			var name = v.a;
			var param = v.b;
			return elm$json$Json$Encode$string('RunTaskerTask');
		default:
			return elm$json$Json$Encode$string('SendIntent');
	}
};
var author$project$Porting$encodeMoment = function (dur) {
	return elm$json$Json$Encode$int(
		author$project$SmartTime$Moment$toSmartInt(dur));
};
var author$project$Activity$Reminder$encodeAlarm = function (v) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'schedule',
				author$project$Porting$encodeMoment(v.bC)),
				_Utils_Tuple2(
				'actions',
				A2(elm$json$Json$Encode$list, author$project$Activity$Reminder$encodeAction, v.bg))
			]));
};
var author$project$External$Commands$scheduleNotify = function (alarmList) {
	var compareReminders = F2(
		function (a, b) {
			return A2(author$project$SmartTime$Moment$compareBasic, a.bC, b.bC);
		});
	var orderedList = A2(elm$core$List$sortWith, compareReminders, alarmList);
	var alarmsObject = elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'alarms',
				A2(elm$json$Json$Encode$list, author$project$Activity$Reminder$encodeAlarm, alarmList))
			]));
	return author$project$External$Tasker$variableOut(
		_Utils_Tuple2(
			'scheduled',
			A2(elm$json$Json$Encode$encode, 0, alarmsObject)));
};
var author$project$Activity$Switching$switchActivity = F3(
	function (activityID, app, env) {
		var updatedApp = _Utils_update(
			app,
			{
				cH: A2(
					elm$core$List$cons,
					A2(author$project$Activity$Activity$Switch, env.ea, activityID),
					app.cH)
			});
		var onTaskStatus = A3(author$project$Activity$Switching$determineOnTask, activityID, app, env);
		var oldActivityID = author$project$Activity$Switching$currentActivityFromApp(app);
		var oldActivity = A2(
			author$project$Activity$Activity$getActivity,
			oldActivityID,
			author$project$Activity$Activity$allActivities(app.bH));
		var newActivity = A2(
			author$project$Activity$Activity$getActivity,
			activityID,
			author$project$Activity$Activity$allActivities(app.bH));
		return _Utils_Tuple2(
			updatedApp,
			elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						author$project$External$Commands$toast(
						A4(
							author$project$Activity$Switching$switchPopup,
							updatedApp.cH,
							env,
							_Utils_Tuple2(activityID, newActivity),
							_Utils_Tuple2(oldActivityID, oldActivity))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'OnTaskStatus',
							author$project$Activity$Activity$statusToString(onTaskStatus))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'ExcusedUsage',
							A3(
								author$project$Activity$Measure$exportExcusedUsageSeconds,
								app,
								env.ea,
								_Utils_Tuple2(activityID, newActivity)))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'OnTaskUsage',
							A3(
								author$project$Activity$Measure$exportExcusedUsageSeconds,
								app,
								env.ea,
								_Utils_Tuple2(activityID, newActivity)))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'ActivityTotal',
							elm$core$String$fromInt(
								author$project$SmartTime$Duration$inMinutesRounded(
									A3(
										author$project$Activity$Measure$excusedUsage,
										app.cH,
										env.ea,
										_Utils_Tuple2(activityID, newActivity)))))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'ExcusedLimit',
							elm$core$String$fromInt(
								author$project$SmartTime$Duration$inSecondsRounded(
									author$project$Activity$Measure$excusableLimit(newActivity))))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'CurrentActivity',
							author$project$Activity$Activity$getName(newActivity))),
						author$project$External$Tasker$variableOut(
						_Utils_Tuple2(
							'PreviousSessionTotal',
							A2(author$project$Activity$Measure$exportLastSession, updatedApp, oldActivityID))),
						author$project$External$Commands$hideWindow,
						author$project$External$Commands$scheduleNotify(
						A4(
							author$project$Activity$Switching$scheduleReminders,
							env,
							updatedApp.cH,
							onTaskStatus,
							_Utils_Tuple2(activityID, newActivity))),
						A2(author$project$Activity$Switching$exportNextTask, app, env)
					])));
	});
var author$project$TimeTracker$update = F4(
	function (msg, state, app, env) {
		if (!msg.$) {
			return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
		} else {
			var activityId = msg.a;
			var _n1 = _Utils_eq(
				activityId,
				author$project$Activity$Switching$currentActivityFromApp(app)) ? _Utils_Tuple2(
				app,
				author$project$External$Commands$toast('Switched to same activity!')) : A3(author$project$Activity$Switching$switchActivity, activityId, app, env);
			var updatedApp = _n1.a;
			var cmds = _n1.b;
			return _Utils_Tuple3(state, updatedApp, cmds);
		}
	});
var author$project$TimeTracker$NoOp = {$: 0};
var author$project$TimeTracker$StartTracking = function (a) {
	return {$: 1, a: a};
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
				activity.c),
			A2(
				elm$core$List$map,
				function (nm) {
					return _Utils_Tuple2(
						elm$core$String$toLower(nm),
						author$project$TimeTracker$StartTracking(
							author$project$ID$tag(id)));
				},
				activity.c));
	};
	var activitiesWithNames = elm$core$List$concat(
		A2(
			elm$core$List$map,
			entriesPerActivity,
			elm_community$intdict$IntDict$toList(
				author$project$Activity$Activity$allActivities(app.bH))));
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
var elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === -2) {
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
var elm$url$Url$Parser$query = function (_n0) {
	var queryParser = _n0;
	return function (_n1) {
		var visited = _n1.au;
		var unvisited = _n1.ah;
		var params = _n1.aq;
		var frag = _n1.al;
		var value = _n1.X;
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
	};
};
var elm$url$Url$Parser$Internal$Parser = elm$core$Basics$identity;
var elm$url$Url$Parser$Query$custom = F2(
	function (key, func) {
		return function (dict) {
			return func(
				A2(
					elm$core$Maybe$withDefault,
					_List_Nil,
					A2(elm$core$Dict$get, key, dict)));
		};
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
		var appData = model.N;
		var environment = model.O;
		var wrapMsgs = F2(
			function (tagger, _n25) {
				var key = _n25.a;
				var dict = _n25.b;
				return _Utils_Tuple2(
					key,
					A2(
						elm$core$Dict$map,
						F2(
							function (_n24, msg) {
								return tagger(msg);
							}),
						dict));
			});
		var url = author$project$Main$bypassFakeFragment(rawUrl);
		var removeTriggersFromUrl = function () {
			var _n23 = environment.dG;
			if (!_n23.$) {
				var navkey = _n23.a;
				return A2(
					elm$browser$Browser$Navigation$replaceUrl,
					navkey,
					elm$url$Url$toString(
						_Utils_update(
							url,
							{cu: elm$core$Maybe$Nothing})));
			} else {
				return elm$core$Platform$Cmd$none;
			}
		}();
		var normalizedUrl = _Utils_update(
			url,
			{dI: ''});
		var fancyRecursiveParse = function (checkList) {
			fancyRecursiveParse:
			while (true) {
				if (checkList.b) {
					var _n11 = checkList.a;
					var triggerName = _n11.a;
					var triggerValues = _n11.b;
					var rest = checkList.b;
					var _n12 = A2(
						elm$url$Url$Parser$parse,
						elm$url$Url$Parser$query(
							A2(elm$url$Url$Parser$Query$enum, triggerName, triggerValues)),
						normalizedUrl);
					if (_n12.$ === 1) {
						var $temp$checkList = rest;
						checkList = $temp$checkList;
						continue fancyRecursiveParse;
					} else {
						if (_n12.a.$ === 1) {
							var _n13 = _n12.a;
							var $temp$checkList = rest;
							checkList = $temp$checkList;
							continue fancyRecursiveParse;
						} else {
							var match = _n12.a;
							return elm$core$Maybe$Just(match);
						}
					}
				} else {
					return elm$core$Maybe$Nothing;
				}
			}
		};
		var createQueryParsers = function (_n22) {
			var key = _n22.a;
			var values = _n22.b;
			return A2(elm$url$Url$Parser$Query$enum, key, values);
		};
		var allTriggers = _Utils_ap(
			A2(
				elm$core$List$map,
				wrapMsgs(author$project$Main$TaskListMsg),
				A2(author$project$TaskList$urlTriggers, appData, environment)),
			_Utils_ap(
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
					])));
		var parseList = A2(
			elm$core$List$map,
			elm$url$Url$Parser$query,
			A2(elm$core$List$map, createQueryParsers, allTriggers));
		var parsed = A2(
			elm$url$Url$Parser$parse,
			elm$url$Url$Parser$oneOf(parseList),
			normalizedUrl);
		var _n14 = fancyRecursiveParse(allTriggers);
		if (!_n14.$) {
			var parsedUrlSuccessfully = _n14.a;
			var _n15 = _Utils_Tuple2(parsedUrlSuccessfully, normalizedUrl.cu);
			if (!_n15.a.$) {
				if (!_n15.b.$) {
					var triggerMsg = _n15.a.a;
					var _n16 = A2(author$project$Main$update, triggerMsg, model);
					var newModel = _n16.a;
					var newCmd = _n16.b;
					var newCmdWithUrlCleaner = elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[newCmd, removeTriggersFromUrl]));
					return _Utils_Tuple2(newModel, newCmdWithUrlCleaner);
				} else {
					var triggerMsg = _n15.a.a;
					var _n18 = _n15.b;
					var problemText = 'Handle URL Triggers: impossible situation. No query (Nothing) but we still successfully parsed it!';
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								N: A2(author$project$AppData$saveError, appData, problemText)
							}),
						author$project$External$Commands$toast(problemText));
				}
			} else {
				if (!_n15.b.$) {
					var _n17 = _n15.a;
					var query = _n15.b.a;
					var problemText = 'Handle URL Triggers: none of  ' + (elm$core$String$fromInt(
						elm$core$List$length(parseList)) + (' parsers matched key and value: ' + query));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								N: A2(author$project$AppData$saveError, appData, problemText)
							}),
						author$project$External$Commands$toast(problemText));
				} else {
					var _n19 = _n15.a;
					var _n20 = _n15.b;
					return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
				}
			}
		} else {
			var _n21 = normalizedUrl.cu;
			if (_n21.$ === 1) {
				return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
			} else {
				var queriesPresent = _n21.a;
				var problemText = 'URL: not sure what to do with: ' + (queriesPresent + ', so I just left it there. Is the trigger misspelled?');
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							N: A2(author$project$AppData$saveError, appData, problemText)
						}),
					author$project$External$Commands$toast(problemText));
			}
		}
	});
var author$project$Main$update = F2(
	function (msg, model) {
		var viewState = model.be;
		var appData = model.N;
		var environment = model.O;
		var justSetEnv = function (newEnv) {
			return _Utils_Tuple2(
				A3(author$project$Main$Model, viewState, appData, newEnv),
				elm$core$Platform$Cmd$none);
		};
		var justRunCommand = function (command) {
			return _Utils_Tuple2(model, command);
		};
		switch (msg.$) {
			case 4:
				return _Utils_Tuple2(
					A3(
						author$project$Main$Model,
						viewState,
						_Utils_update(
							appData,
							{aj: _List_Nil}),
						environment),
					elm$core$Platform$Cmd$none);
			case 5:
				return justRunCommand(
					A2(
						elm$core$Platform$Cmd$map,
						author$project$Main$TodoistServerResponse,
						author$project$Integrations$Todoist$fetchUpdates(appData.cK)));
			case 6:
				var response = msg.a;
				var _n1 = A2(author$project$Integrations$Todoist$handle, response, appData);
				var newAppData = _n1.a;
				var whatHappened = _n1.b;
				return _Utils_Tuple2(
					A3(author$project$Main$Model, viewState, newAppData, environment),
					author$project$External$Commands$toast(whatHappened));
			case 7:
				var urlRequest = msg.a;
				if (!urlRequest.$) {
					var url = urlRequest.a;
					var _n3 = environment.dG;
					if (!_n3.$) {
						var navkey = _n3.a;
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
			case 8:
				var url = msg.a;
				var _n4 = A2(author$project$Main$handleUrlTriggers, url, model);
				var modelAfter = _n4.a;
				var effectsAfter = _n4.b;
				return _Utils_Tuple2(
					_Utils_update(
						modelAfter,
						{
							be: author$project$Main$viewUrl(url)
						}),
					effectsAfter);
			case 9:
				var subMsg = msg.a;
				var subViewState = function () {
					var _n6 = viewState.aP;
					if (!_n6.$) {
						var subView = _n6.a;
						return subView;
					} else {
						return author$project$TaskList$defaultView;
					}
				}();
				var _n5 = A4(author$project$TaskList$update, subMsg, subViewState, appData, environment);
				var newState = _n5.a;
				var newApp = _n5.b;
				var newCommand = _n5.c;
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
			case 10:
				var subMsg = msg.a;
				var subViewState = function () {
					var _n8 = viewState.aP;
					if (_n8.$ === 1) {
						var subView = _n8.a;
						return subView;
					} else {
						return author$project$TimeTracker$defaultView;
					}
				}();
				var _n7 = A4(author$project$TimeTracker$update, subMsg, subViewState, appData, environment);
				var newState = _n7.a;
				var newApp = _n7.b;
				var newCommand = _n7.c;
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
			case 11:
				var newJSON = msg.a;
				var maybeNewApp = author$project$Main$appDataFromJson(newJSON);
				switch (maybeNewApp.$) {
					case 3:
						var savedAppData = maybeNewApp.a;
						return _Utils_Tuple2(
							A3(author$project$Main$Model, viewState, savedAppData, environment),
							author$project$External$Commands$toast('Synced with another browser tab!'));
					case 2:
						var warnings = maybeNewApp.a;
						var savedAppData = maybeNewApp.b;
						return _Utils_Tuple2(
							A3(
								author$project$Main$Model,
								viewState,
								A2(author$project$AppData$saveWarnings, savedAppData, warnings),
								environment),
							elm$core$Platform$Cmd$none);
					case 1:
						var errors = maybeNewApp.a;
						return _Utils_Tuple2(
							A3(
								author$project$Main$Model,
								viewState,
								A2(author$project$AppData$saveDecodeErrors, appData, errors),
								environment),
							elm$core$Platform$Cmd$none);
					default:
						return _Utils_Tuple2(
							A3(
								author$project$Main$Model,
								viewState,
								A2(author$project$AppData$saveError, appData, 'Got bad JSON from cross-sync'),
								environment),
							elm$core$Platform$Cmd$none);
				}
			default:
				return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
		}
	});
var author$project$Activity$Activity$encodeCategory = function (v) {
	switch (v) {
		case 0:
			return elm$json$Json$Encode$string('Transit');
		case 1:
			return elm$json$Json$Encode$string('Entertainment');
		case 2:
			return elm$json$Json$Encode$string('Hygiene');
		case 3:
			return elm$json$Json$Encode$string('Slacking');
		default:
			return elm$json$Json$Encode$string('Communication');
	}
};
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
		case 0:
			return elm$json$Json$Encode$string('NeverExcused');
		case 1:
			var dpp = v.a;
			return elm$json$Json$Encode$string('TemporarilyExcused');
		default:
			return elm$json$Json$Encode$string('IndefinitelyExcused');
	}
};
var author$project$Activity$Activity$encodeIcon = function (v) {
	switch (v.$) {
		case 0:
			var path = v.a;
			return elm$json$Json$Encode$string('File');
		case 1:
			return elm$json$Json$Encode$string('Ion');
		default:
			return elm$json$Json$Encode$string('Other');
	}
};
var author$project$Activity$Template$encodeTemplate = function (v) {
	switch (v) {
		case 0:
			return elm$json$Json$Encode$string('DillyDally');
		case 1:
			return elm$json$Json$Encode$string('Apparel');
		case 2:
			return elm$json$Json$Encode$string('Messaging');
		case 3:
			return elm$json$Json$Encode$string('Restroom');
		case 4:
			return elm$json$Json$Encode$string('Grooming');
		case 5:
			return elm$json$Json$Encode$string('Meal');
		case 6:
			return elm$json$Json$Encode$string('Supplements');
		case 7:
			return elm$json$Json$Encode$string('Workout');
		case 8:
			return elm$json$Json$Encode$string('Shower');
		case 9:
			return elm$json$Json$Encode$string('Toothbrush');
		case 10:
			return elm$json$Json$Encode$string('Floss');
		case 11:
			return elm$json$Json$Encode$string('Wakeup');
		case 12:
			return elm$json$Json$Encode$string('Sleep');
		case 13:
			return elm$json$Json$Encode$string('Plan');
		case 14:
			return elm$json$Json$Encode$string('Configure');
		case 15:
			return elm$json$Json$Encode$string('Email');
		case 16:
			return elm$json$Json$Encode$string('Work');
		case 17:
			return elm$json$Json$Encode$string('Call');
		case 18:
			return elm$json$Json$Encode$string('Chores');
		case 19:
			return elm$json$Json$Encode$string('Parents');
		case 20:
			return elm$json$Json$Encode$string('Prepare');
		case 21:
			return elm$json$Json$Encode$string('Lover');
		case 22:
			return elm$json$Json$Encode$string('Driving');
		case 23:
			return elm$json$Json$Encode$string('Riding');
		case 24:
			return elm$json$Json$Encode$string('SocialMedia');
		case 25:
			return elm$json$Json$Encode$string('Pacing');
		case 26:
			return elm$json$Json$Encode$string('Sport');
		case 27:
			return elm$json$Json$Encode$string('Finance');
		case 28:
			return elm$json$Json$Encode$string('Laundry');
		case 29:
			return elm$json$Json$Encode$string('Bedward');
		case 30:
			return elm$json$Json$Encode$string('Browse');
		case 31:
			return elm$json$Json$Encode$string('Fiction');
		case 32:
			return elm$json$Json$Encode$string('Learning');
		case 33:
			return elm$json$Json$Encode$string('BrainTrain');
		case 34:
			return elm$json$Json$Encode$string('Music');
		case 35:
			return elm$json$Json$Encode$string('Create');
		case 36:
			return elm$json$Json$Encode$string('Children');
		case 37:
			return elm$json$Json$Encode$string('Meeting');
		case 38:
			return elm$json$Json$Encode$string('Cinema');
		case 39:
			return elm$json$Json$Encode$string('FilmWatching');
		case 40:
			return elm$json$Json$Encode$string('Series');
		case 41:
			return elm$json$Json$Encode$string('Broadcast');
		case 42:
			return elm$json$Json$Encode$string('Theatre');
		case 43:
			return elm$json$Json$Encode$string('Shopping');
		case 44:
			return elm$json$Json$Encode$string('VideoGaming');
		case 45:
			return elm$json$Json$Encode$string('Housekeeping');
		case 46:
			return elm$json$Json$Encode$string('MealPrep');
		case 47:
			return elm$json$Json$Encode$string('Networking');
		case 48:
			return elm$json$Json$Encode$string('Meditate');
		case 49:
			return elm$json$Json$Encode$string('Homework');
		case 50:
			return elm$json$Json$Encode$string('Flight');
		case 51:
			return elm$json$Json$Encode$string('Course');
		case 52:
			return elm$json$Json$Encode$string('Pet');
		case 53:
			return elm$json$Json$Encode$string('Presentation');
		case 54:
			return elm$json$Json$Encode$string('Projects');
		default:
			return elm$json$Json$Encode$string('Research');
	}
};
var author$project$ID$encode = function (_n0) {
	var _int = _n0;
	return elm$json$Json$Encode$int(_int);
};
var author$project$Activity$Activity$encodeCustomizations = function (record) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$normal(
				_Utils_Tuple2(
					'template',
					author$project$Activity$Template$encodeTemplate(record.j))),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'stock',
					author$project$ID$encode(record.dl))),
				author$project$Porting$omittable(
				_Utils_Tuple3(
					'names',
					elm$json$Json$Encode$list(elm$json$Json$Encode$string),
					record.c)),
				author$project$Porting$omittable(
				_Utils_Tuple3('icon', author$project$Activity$Activity$encodeIcon, record.g)),
				author$project$Porting$omittable(
				_Utils_Tuple3('excusable', author$project$Activity$Activity$encodeExcusable, record.a)),
				author$project$Porting$omittable(
				_Utils_Tuple3('taskOptional', elm$json$Json$Encode$bool, record.i)),
				author$project$Porting$omittable(
				_Utils_Tuple3(
					'evidence',
					elm$json$Json$Encode$list(author$project$Activity$Activity$encodeEvidence),
					record.f)),
				author$project$Porting$omittable(
				_Utils_Tuple3('category', author$project$Activity$Activity$encodeCategory, record.e)),
				author$project$Porting$omittable(
				_Utils_Tuple3('backgroundable', elm$json$Json$Encode$bool, record.d)),
				author$project$Porting$omittable(
				_Utils_Tuple3('maxTime', author$project$Activity$Activity$encodeDurationPerPeriod, record.h)),
				author$project$Porting$omittable(
				_Utils_Tuple3('hidden', elm$json$Json$Encode$bool, record.b))
			]));
};
var author$project$Activity$Activity$encodeStoredActivities = function (value) {
	return A2(
		elm$json$Json$Encode$list,
		A2(author$project$Porting$encodeTuple2, elm$json$Json$Encode$int, author$project$Activity$Activity$encodeCustomizations),
		elm_community$intdict$IntDict$toList(value));
};
var author$project$Activity$Activity$encodeSwitch = function (_n0) {
	var time = _n0.a;
	var activityId = _n0.b;
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'Time',
				author$project$Porting$encodeMoment(time)),
				_Utils_Tuple2(
				'Activity',
				author$project$ID$encode(activityId))
			]));
};
var author$project$Incubator$Todoist$encodeIncrementalSyncToken = function (_n0) {
	var token = _n0;
	return elm$json$Json$Encode$string(token);
};
var author$project$Incubator$Todoist$Item$encodeItem = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$int(record.dl)),
				_Utils_Tuple2(
				'user_id',
				elm$json$Json$Encode$int(record.ef)),
				_Utils_Tuple2(
				'project_id',
				elm$json$Json$Encode$int(record.dN)),
				_Utils_Tuple2(
				'content',
				elm$json$Json$Encode$string(record.bl)),
				_Utils_Tuple2(
				'due',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$Incubator$Todoist$Item$encodeDue, record.aD)),
				_Utils_Tuple2(
				'priority',
				author$project$Incubator$Todoist$Item$encodePriority(record.cp)),
				_Utils_Tuple2(
				'parent_id',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$int, record.bx)),
				_Utils_Tuple2(
				'child_order',
				elm$json$Json$Encode$int(record._)),
				_Utils_Tuple2(
				'day_order',
				elm$json$Json$Encode$int(record.bm)),
				_Utils_Tuple2(
				'collapsed',
				author$project$Porting$encodeBoolToInt(record.aB)),
				_Utils_Tuple2(
				'children',
				A2(elm$json$Json$Encode$list, elm$json$Json$Encode$int, record.c6)),
				_Utils_Tuple2(
				'assigned_by_uid',
				elm$json$Json$Encode$int(record.cV)),
				_Utils_Tuple2(
				'responsible_uid',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$int, record.dY)),
				_Utils_Tuple2(
				'checked',
				author$project$Porting$encodeBoolToInt(record.c5)),
				_Utils_Tuple2(
				'in_history',
				author$project$Porting$encodeBoolToInt(record.dn)),
				_Utils_Tuple2(
				'is_deleted',
				author$project$Porting$encodeBoolToInt(record.bY)),
				_Utils_Tuple2(
				'is_archived',
				author$project$Porting$encodeBoolToInt(record.dt)),
				_Utils_Tuple2(
				'date_added',
				elm$json$Json$Encode$string(record.c8))
			]));
};
var author$project$Incubator$Todoist$Project$encodeProject = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$int(record.dl)),
				_Utils_Tuple2(
				'name',
				elm$json$Json$Encode$string(record.bu)),
				_Utils_Tuple2(
				'color',
				elm$json$Json$Encode$int(record.bk)),
				_Utils_Tuple2(
				'parent_id',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$int, record.bx)),
				_Utils_Tuple2(
				'child_order',
				elm$json$Json$Encode$int(record._)),
				_Utils_Tuple2(
				'collapsed',
				elm$json$Json$Encode$int(record.aB)),
				_Utils_Tuple2(
				'shared',
				elm$json$Json$Encode$bool(record.d0)),
				_Utils_Tuple2(
				'is_deleted',
				author$project$Porting$encodeBoolToInt(record.bY)),
				_Utils_Tuple2(
				'is_archived',
				author$project$Porting$encodeBoolToInt(record.dt)),
				_Utils_Tuple2(
				'is_favorite',
				author$project$Porting$encodeBoolToInt(record.br)),
				_Utils_Tuple2(
				'inbox_project',
				elm$json$Json$Encode$bool(record.$7)),
				_Utils_Tuple2(
				'team_inbox',
				elm$json$Json$Encode$bool(record.d8))
			]));
};
var author$project$Incubator$Todoist$encodeCache = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'nextSync',
				author$project$Incubator$Todoist$encodeIncrementalSyncToken(record.ap)),
				_Utils_Tuple2(
				'items',
				A2(author$project$Porting$encodeIntDict, author$project$Incubator$Todoist$Item$encodeItem, record.P)),
				_Utils_Tuple2(
				'projects',
				A2(author$project$Porting$encodeIntDict, author$project$Incubator$Todoist$Project$encodeProject, record.T)),
				_Utils_Tuple2(
				'pendingCommands',
				A2(elm$json$Json$Encode$list, elm$json$Json$Encode$string, record.by))
			]));
};
var author$project$AppData$encodeTodoistIntegrationData = function (data) {
	return author$project$Porting$encodeObjectWithoutNothings(
		_List_fromArray(
			[
				author$project$Porting$normal(
				_Utils_Tuple2(
					'cache',
					author$project$Incubator$Todoist$encodeCache(data.bN))),
				author$project$Porting$omittable(
				_Utils_Tuple3('parentProjectID', elm$json$Json$Encode$int, data.cf)),
				author$project$Porting$normal(
				_Utils_Tuple2(
					'activityProjectIDs',
					A2(author$project$Porting$encodeIntDict, author$project$ID$encode, data.bI)))
			]));
};
var author$project$Porting$encodeDuration = function (dur) {
	return elm$json$Json$Encode$int(
		author$project$SmartTime$Duration$inMs(dur));
};
var author$project$Task$Progress$encodeProgress = function (progress) {
	return elm$json$Json$Encode$int(
		author$project$Task$Progress$getPortion(progress));
};
var author$project$Task$Task$encodeHistoryEntry = function (record) {
	return elm$json$Json$Encode$object(_List_Nil);
};
var author$project$SmartTime$Human$Clock$midnight = author$project$SmartTime$Duration$zero;
var author$project$SmartTime$Human$Moment$fromDate = F2(
	function (zone, date) {
		return A3(author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, author$project$SmartTime$Human$Clock$midnight);
	});
var author$project$SmartTime$Human$Moment$fromFuzzy = F2(
	function (zone, fuzzy) {
		switch (fuzzy.$) {
			case 2:
				var date = fuzzy.a;
				return A2(author$project$SmartTime$Human$Moment$fromDate, zone, date);
			case 1:
				var _n1 = fuzzy.a;
				var date = _n1.a;
				var time = _n1.b;
				return A3(author$project$SmartTime$Human$Moment$fromDateAndTime, zone, date, time);
			default:
				var moment = fuzzy.a;
				return moment;
		}
	});
var author$project$SmartTime$Human$Moment$fuzzyToString = function (fuzzyMoment) {
	switch (fuzzyMoment.$) {
		case 0:
			var moment = fuzzyMoment.a;
			return author$project$SmartTime$Human$Moment$toStandardString(moment);
		case 1:
			return A2(
				elm$core$String$dropRight,
				1,
				author$project$SmartTime$Human$Moment$toStandardString(
					A2(author$project$SmartTime$Human$Moment$fromFuzzy, author$project$SmartTime$Human$Moment$utc, fuzzyMoment)));
		default:
			var date = fuzzyMoment.a;
			return author$project$SmartTime$Human$Calendar$toStandardString(date);
	}
};
var author$project$Task$Task$encodeTaskMoment = function (fuzzy) {
	return elm$json$Json$Encode$string(
		author$project$SmartTime$Human$Moment$fuzzyToString(fuzzy));
};
var author$project$Task$Task$encodeTask = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				elm$json$Json$Encode$string(record.ba)),
				_Utils_Tuple2(
				'completion',
				author$project$Task$Progress$encodeProgress(record.bQ)),
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$int(record.dl)),
				_Utils_Tuple2(
				'minEffort',
				author$project$Porting$encodeDuration(record.dC)),
				_Utils_Tuple2(
				'predictedEffort',
				author$project$Porting$encodeDuration(record.cn)),
				_Utils_Tuple2(
				'maxEffort',
				author$project$Porting$encodeDuration(record.eN)),
				_Utils_Tuple2(
				'history',
				A2(elm$json$Json$Encode$list, author$project$Task$Task$encodeHistoryEntry, record.a2)),
				_Utils_Tuple2(
				'parent',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$int, record.ce)),
				_Utils_Tuple2(
				'tags',
				A2(elm$json$Json$Encode$list, elm$json$Json$Encode$int, record.e7)),
				_Utils_Tuple2(
				'activity',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$ID$encode, record.ek)),
				_Utils_Tuple2(
				'deadline',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$Task$Task$encodeTaskMoment, record.et)),
				_Utils_Tuple2(
				'plannedStart',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$Task$Task$encodeTaskMoment, record.cm)),
				_Utils_Tuple2(
				'plannedFinish',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$Task$Task$encodeTaskMoment, record.cl)),
				_Utils_Tuple2(
				'relevanceStarts',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$Task$Task$encodeTaskMoment, record.cw)),
				_Utils_Tuple2(
				'relevanceEnds',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, author$project$Task$Task$encodeTaskMoment, record.cv)),
				_Utils_Tuple2(
				'importance',
				elm$json$Json$Encode$float(record.eG))
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
				A2(author$project$Porting$encodeIntDict, author$project$Task$Task$encodeTask, record.e8)),
				_Utils_Tuple2(
				'activities',
				author$project$Activity$Activity$encodeStoredActivities(record.bH)),
				_Utils_Tuple2(
				'uid',
				elm$json$Json$Encode$int(record.cL)),
				_Utils_Tuple2(
				'errors',
				A2(
					elm$json$Json$Encode$list,
					elm$json$Json$Encode$string,
					A2(elm$core$List$take, 100, record.aj))),
				_Utils_Tuple2(
				'timeline',
				A2(elm$json$Json$Encode$list, author$project$Activity$Activity$encodeSwitch, record.cH)),
				_Utils_Tuple2(
				'todoist',
				author$project$AppData$encodeTodoistIntegrationData(record.cK))
			]));
};
var author$project$Main$appDataToJson = function (appData) {
	return A2(
		elm$json$Json$Encode$encode,
		0,
		author$project$AppData$encodeAppData(appData));
};
var author$project$Main$setStorage = _Platform_outgoingPort('setStorage', elm$json$Json$Encode$string);
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
						author$project$Main$appDataToJson(newModel.N)),
						cmds
					])));
	});
var author$project$SmartTime$Moment$fromElmInt = function (intMsUtc) {
	return A3(
		author$project$SmartTime$Moment$moment,
		0,
		author$project$SmartTime$Moment$unixEpoch,
		author$project$SmartTime$Duration$fromInt(intMsUtc));
};
var elm$time$Time$posixToMillis = function (_n0) {
	var millis = _n0;
	return millis;
};
var author$project$SmartTime$Moment$fromElmTime = function (intMsUtc) {
	return author$project$SmartTime$Moment$fromElmInt(
		elm$time$Time$posixToMillis(intMsUtc));
};
var elm$time$Time$Name = function (a) {
	return {$: 0, a: a};
};
var elm$time$Time$Offset = function (a) {
	return {$: 1, a: a};
};
var elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$time$Time$customZone = elm$time$Time$Zone;
var elm$time$Time$Posix = elm$core$Basics$identity;
var elm$time$Time$millisToPosix = elm$core$Basics$identity;
var elm$time$Time$now = _Time_now(elm$time$Time$millisToPosix);
var author$project$SmartTime$Moment$now = A2(elm$core$Task$map, author$project$SmartTime$Moment$fromElmTime, elm$time$Time$now);
var author$project$Main$updateWithTime = F2(
	function (msg, model) {
		updateWithTime:
		while (true) {
			var environment = model.O;
			switch (msg.$) {
				case 0:
					return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
				case 1:
					var submsg = msg.a;
					return _Utils_Tuple2(
						model,
						A2(
							elm$core$Task$perform,
							author$project$Main$Tock(submsg),
							author$project$SmartTime$Moment$now));
				case 2:
					if (!msg.a.$) {
						var _n1 = msg.a;
						var time = msg.b;
						var newEnv = _Utils_update(
							environment,
							{ea: time});
						return A2(
							author$project$Main$update,
							author$project$Main$NoOp,
							_Utils_update(
								model,
								{O: newEnv}));
					} else {
						var submsg = msg.a;
						var time = msg.b;
						var newEnv = _Utils_update(
							environment,
							{ea: time});
						return A2(
							author$project$Main$updateWithStorage,
							submsg,
							_Utils_update(
								model,
								{O: newEnv}));
					}
				case 3:
					var zone = msg.a;
					var time = msg.b;
					var newEnv = _Utils_update(
						environment,
						{ea: time, e9: zone});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{O: newEnv}),
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
var author$project$SmartTime$Human$Calendar$Month$clampToValidDayOfMonth = F3(
	function (givenYear, givenMonth, _n0) {
		var originalDay = _n0;
		var targetMonthLength = A2(author$project$SmartTime$Human$Calendar$Month$length, givenYear, givenMonth);
		return A3(elm$core$Basics$clamp, 1, targetMonthLength, originalDay);
	});
var author$project$SmartTime$Human$Calendar$fromPartsForced = function (given) {
	return author$project$SmartTime$Human$Calendar$fromPartsTrusted(
		{
			y: A3(author$project$SmartTime$Human$Calendar$Month$clampToValidDayOfMonth, given.t, given.x, given.y),
			x: given.x,
			t: given.t
		});
};
var author$project$SmartTime$Human$Moment$importElmMonth = function (elmMonth) {
	switch (elmMonth) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		case 3:
			return 3;
		case 4:
			return 4;
		case 5:
			return 5;
		case 6:
			return 6;
		case 7:
			return 7;
		case 8:
			return 8;
		case 9:
			return 9;
		case 10:
			return 10;
		default:
			return 11;
	}
};
var elm$time$Time$flooredDiv = F2(
	function (numerator, denominator) {
		return elm$core$Basics$floor(numerator / denominator);
	});
var elm$time$Time$toAdjustedMinutesHelp = F3(
	function (defaultOffset, posixMinutes, eras) {
		toAdjustedMinutesHelp:
		while (true) {
			if (!eras.b) {
				return posixMinutes + defaultOffset;
			} else {
				var era = eras.a;
				var olderEras = eras.b;
				if (_Utils_cmp(era.cA, posixMinutes) < 0) {
					return posixMinutes + era.l;
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
		y: (dayOfYear - ((((153 * mp) + 2) / 5) | 0)) + 1,
		x: month,
		t: year + ((month <= 2) ? 1 : 0)
	};
};
var elm$time$Time$toDay = F2(
	function (zone, time) {
		return elm$time$Time$toCivil(
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).y;
	});
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
var elm$time$Time$Apr = 3;
var elm$time$Time$Aug = 7;
var elm$time$Time$Dec = 11;
var elm$time$Time$Feb = 1;
var elm$time$Time$Jan = 0;
var elm$time$Time$Jul = 6;
var elm$time$Time$Jun = 5;
var elm$time$Time$Mar = 2;
var elm$time$Time$May = 4;
var elm$time$Time$Nov = 10;
var elm$time$Time$Oct = 9;
var elm$time$Time$Sep = 8;
var elm$time$Time$toMonth = F2(
	function (zone, time) {
		var _n0 = elm$time$Time$toCivil(
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).x;
		switch (_n0) {
			case 1:
				return 0;
			case 2:
				return 1;
			case 3:
				return 2;
			case 4:
				return 3;
			case 5:
				return 4;
			case 6:
				return 5;
			case 7:
				return 6;
			case 8:
				return 7;
			case 9:
				return 8;
			case 10:
				return 9;
			case 11:
				return 10;
			default:
				return 11;
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
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).t;
	});
var author$project$SmartTime$Human$Moment$deduceZoneOffset = F2(
	function (zone, elmTime) {
		var zonedTime = A4(
			author$project$SmartTime$Human$Clock$clock,
			A2(elm$time$Time$toHour, zone, elmTime),
			A2(elm$time$Time$toMinute, zone, elmTime),
			A2(elm$time$Time$toSecond, zone, elmTime),
			A2(elm$time$Time$toMillis, zone, elmTime));
		var zonedDate = author$project$SmartTime$Human$Calendar$fromPartsForced(
			{
				y: A2(elm$time$Time$toDay, zone, elmTime),
				x: author$project$SmartTime$Human$Moment$importElmMonth(
					A2(elm$time$Time$toMonth, zone, elmTime)),
				t: A2(elm$time$Time$toYear, zone, elmTime)
			});
		var utcTime = author$project$SmartTime$Moment$fromElmTime(elmTime);
		var combinedMoment = A3(author$project$SmartTime$Human$Moment$fromDateAndTime, author$project$SmartTime$Human$Moment$utc, zonedDate, zonedTime);
		var localTime = combinedMoment;
		var offset = author$project$SmartTime$Moment$toSmartInt(localTime) - author$project$SmartTime$Moment$toSmartInt(utcTime);
		return author$project$SmartTime$Duration$fromMs(offset);
	});
var author$project$SmartTime$Human$Moment$makeZone = F3(
	function (elmZoneName, elmZone, now) {
		var deducedOffset = A2(author$project$SmartTime$Human$Moment$deduceZoneOffset, elmZone, now);
		if (!elmZoneName.$) {
			var zoneName = elmZoneName.a;
			return {a0: deducedOffset, a2: _List_Nil, bu: zoneName};
		} else {
			var offsetMinutes = elmZoneName.a;
			return {
				a0: author$project$SmartTime$Duration$fromMinutes(offsetMinutes),
				a2: _List_Nil,
				bu: 'Unsupported'
			};
		}
	});
var elm$core$Task$map3 = F4(
	function (func, taskA, taskB, taskC) {
		return A2(
			elm$core$Task$andThen,
			function (a) {
				return A2(
					elm$core$Task$andThen,
					function (b) {
						return A2(
							elm$core$Task$andThen,
							function (c) {
								return elm$core$Task$succeed(
									A3(func, a, b, c));
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var elm$time$Time$getZoneName = _Time_getZoneName(0);
var elm$time$Time$here = _Time_here(0);
var author$project$SmartTime$Human$Moment$localZone = A4(elm$core$Task$map3, author$project$SmartTime$Human$Moment$makeZone, elm$time$Time$getZoneName, elm$time$Time$here, elm$time$Time$now);
var author$project$Main$init = F3(
	function (maybeJson, url, maybeKey) {
		var startingModel = function () {
			if (!maybeJson.$) {
				var jsonAppDatabase = maybeJson.a;
				var _n2 = author$project$Main$appDataFromJson(jsonAppDatabase);
				switch (_n2.$) {
					case 3:
						var savedAppData = _n2.a;
						return A3(author$project$Main$buildModel, savedAppData, url, maybeKey);
					case 2:
						var warnings = _n2.a;
						var savedAppData = _n2.b;
						return A3(
							author$project$Main$buildModel,
							A2(author$project$AppData$saveWarnings, savedAppData, warnings),
							url,
							maybeKey);
					case 1:
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
var author$project$Main$NewAppData = function (a) {
	return {$: 11, a: a};
};
var author$project$Main$storageChangedElsewhere = _Platform_incomingPort('storageChangedElsewhere', elm$json$Json$Decode$string);
var elm$time$Time$Every = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$time$Time$State = F2(
	function (taggers, processes) {
		return {dM: processes, d7: taggers};
	});
var elm$time$Time$init = elm$core$Task$succeed(
	A2(elm$time$Time$State, elm$core$Dict$empty, elm$core$Dict$empty));
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
var elm$time$Time$addMySub = F2(
	function (_n0, state) {
		var interval = _n0.a;
		var tagger = _n0.b;
		var _n1 = A2(elm$core$Dict$get, interval, state);
		if (_n1.$ === 1) {
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
		var processes = _n0.dM;
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
				elm$core$Task$succeed(0)));
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
		var _n0 = A2(elm$core$Dict$get, interval, state.d7);
		if (_n0.$ === 1) {
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
var elm$browser$Browser$Events$Document = 0;
var elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {dJ: pids, d5: subs};
	});
var elm$browser$Browser$Events$init = elm$core$Task$succeed(
	A2(elm$browser$Browser$Events$State, _List_Nil, elm$core$Dict$empty));
var elm$browser$Browser$Events$nodeToKey = function (node) {
	if (!node) {
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
		return {dc: event, dz: key};
	});
var elm$browser$Browser$Events$spawn = F3(
	function (router, key, _n0) {
		var node = _n0.a;
		var name = _n0.b;
		var actualNode = function () {
			if (!node) {
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
			state.dJ,
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
		var key = _n0.dz;
		var event = _n0.dc;
		var toMessage = function (_n2) {
			var subKey = _n2.a;
			var _n3 = _n2.b;
			var node = _n3.a;
			var name = _n3.b;
			var decoder = _n3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : elm$core$Maybe$Nothing;
		};
		var messages = A2(elm$core$List$filterMap, toMessage, state.d5);
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
var elm$browser$Browser$Events$Hidden = 1;
var elm$browser$Browser$Events$Visible = 0;
var elm$browser$Browser$Events$withHidden = F2(
	function (func, isHidden) {
		return func(
			isHidden ? 1 : 0);
	});
var elm$json$Json$Decode$field = _Json_decodeField;
var elm$browser$Browser$Events$onVisibilityChange = function (func) {
	var info = _Browser_visibilityInfo(0);
	return A3(
		elm$browser$Browser$Events$on,
		0,
		info.eq,
		A2(
			elm$json$Json$Decode$map,
			elm$browser$Browser$Events$withHidden(func),
			A2(
				elm$json$Json$Decode$field,
				'target',
				A2(elm$json$Json$Decode$field, info.b, elm$json$Json$Decode$bool))));
};
var elm$core$Platform$Sub$batch = _Platform_batch;
var author$project$Main$subscriptions = function (model) {
	var appData = model.N;
	var environment = model.O;
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
				}),
				author$project$Main$storageChangedElsewhere(author$project$Main$NewAppData)
			]));
};
var author$project$Main$ClearErrors = {$: 4};
var rtfeldman$elm_css$VirtualDom$Styled$Node = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var rtfeldman$elm_css$VirtualDom$Styled$node = rtfeldman$elm_css$VirtualDom$Styled$Node;
var rtfeldman$elm_css$Html$Styled$node = rtfeldman$elm_css$VirtualDom$Styled$node;
var rtfeldman$elm_css$Html$Styled$div = rtfeldman$elm_css$Html$Styled$node('div');
var rtfeldman$elm_css$Html$Styled$li = rtfeldman$elm_css$Html$Styled$node('li');
var rtfeldman$elm_css$Html$Styled$ol = rtfeldman$elm_css$Html$Styled$node('ol');
var elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var rtfeldman$elm_css$VirtualDom$Styled$Unstyled = function (a) {
	return {$: 4, a: a};
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
		return {$: 0, a: a, b: b, c: c};
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
var elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 0, a: a};
};
var elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
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
var author$project$TaskList$DeleteComplete = {$: 5};
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
var author$project$TaskList$CompleteTasksOnly = 2;
var author$project$TaskList$Refilter = function (a) {
	return {$: 0, a: a};
};
var author$project$TaskList$filterName = function (filter) {
	switch (filter) {
		case 0:
			return 'All';
		case 2:
			return 'Complete';
		default:
			return 'Remaining';
	}
};
var elm_community$list_extra$List$Extra$remove = F2(
	function (x, xs) {
		if (!xs.b) {
			return _List_Nil;
		} else {
			var y = xs.a;
			var ys = xs.b;
			return _Utils_eq(x, y) ? ys : A2(
				elm$core$List$cons,
				y,
				A2(elm_community$list_extra$List$Extra$remove, x, ys));
		}
	});
var rtfeldman$elm_css$Html$Styled$input = rtfeldman$elm_css$Html$Styled$node('input');
var rtfeldman$elm_css$Html$Styled$label = rtfeldman$elm_css$Html$Styled$node('label');
var rtfeldman$elm_css$Html$Styled$Attributes$checked = rtfeldman$elm_css$Html$Styled$Attributes$boolProperty('checked');
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
var rtfeldman$elm_css$Html$Styled$Attributes$for = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('htmlFor');
var rtfeldman$elm_css$Html$Styled$Attributes$name = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('name');
var rtfeldman$elm_css$Html$Styled$Attributes$type_ = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('type');
var author$project$TaskList$visibilitySwap = F3(
	function (name, visibilityToDisplay, actualVisibility) {
		var isCurrent = A2(elm$core$List$member, visibilityToDisplay, actualVisibility);
		var changeList = isCurrent ? A2(elm_community$list_extra$List$Extra$remove, visibilityToDisplay, actualVisibility) : A2(elm$core$List$cons, visibilityToDisplay, actualVisibility);
		return A2(
			rtfeldman$elm_css$Html$Styled$li,
			_List_Nil,
			_List_fromArray(
				[
					A2(
					rtfeldman$elm_css$Html$Styled$input,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$type_('checkbox'),
							rtfeldman$elm_css$Html$Styled$Attributes$checked(isCurrent),
							rtfeldman$elm_css$Html$Styled$Events$onClick(
							author$project$TaskList$Refilter(changeList)),
							rtfeldman$elm_css$Html$Styled$Attributes$classList(
							_List_fromArray(
								[
									_Utils_Tuple2('selected', isCurrent)
								])),
							rtfeldman$elm_css$Html$Styled$Attributes$name(name)
						]),
					_List_Nil),
					A2(
					rtfeldman$elm_css$Html$Styled$label,
					_List_fromArray(
						[
							rtfeldman$elm_css$Html$Styled$Attributes$for(name)
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
				A3(author$project$TaskList$visibilitySwap, 'all', 0, visibilityFilters),
				rtfeldman$elm_css$Html$Styled$text(' '),
				A3(author$project$TaskList$visibilitySwap, 'active', 1, visibilityFilters),
				rtfeldman$elm_css$Html$Styled$text(' '),
				A3(author$project$TaskList$visibilitySwap, 'completed', 2, visibilityFilters)
			]));
};
var elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var elm$virtual_dom$VirtualDom$lazy2 = _VirtualDom_lazy2;
var elm$virtual_dom$VirtualDom$node = function (tag) {
	return _VirtualDom_node(
		_VirtualDom_noScript(tag));
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
			case 4:
				var vdom = html.a;
				return _Utils_Tuple2(
					A2(
						elm$core$List$cons,
						_Utils_Tuple2(key, vdom),
						pairs),
					styles);
			case 0:
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
			case 1:
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
			case 2:
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
			case 4:
				var vdomNode = html.a;
				return _Utils_Tuple2(
					A2(elm$core$List$cons, vdomNode, nodes),
					styles);
			case 0:
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
			case 1:
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
			case 2:
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
		return A5(elm$core$Dict$RBNode_elm_builtin, 1, key, value, elm$core$Dict$RBEmpty_elm_builtin, elm$core$Dict$RBEmpty_elm_builtin);
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
	if (_n0.$ === 1) {
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
	return {c4: elm$core$Maybe$Nothing, dm: _List_Nil, dF: _List_Nil, d1: snippets};
};
var rtfeldman$elm_css$Css$Preprocess$unwrapSnippet = function (_n0) {
	var declarations = _n0;
	return declarations;
};
var rtfeldman$elm_css$Css$Preprocess$Resolve$collectSelectors = function (declarations) {
	collectSelectors:
	while (true) {
		if (!declarations.b) {
			return _List_Nil;
		} else {
			if (!declarations.a.$) {
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
			if (maybe.$ === 1) {
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
	return {$: 9, a: a};
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
		return {$: 3, a: a, b: b, c: c, d: d, e: e};
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule = F5(
	function (str1, str2, str3, str4, declaration) {
		if (!declaration.$) {
			var structureStyleBlock = declaration.a;
			return A5(rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4, structureStyleBlock);
		} else {
			return declaration;
		}
	});
var rtfeldman$elm_css$Css$Structure$MediaRule = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$SupportsRule = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule = F2(
	function (mediaQueries, declaration) {
		switch (declaration.$) {
			case 0:
				var structureStyleBlock = declaration.a;
				return A2(
					rtfeldman$elm_css$Css$Structure$MediaRule,
					mediaQueries,
					_List_fromArray(
						[structureStyleBlock]));
			case 1:
				var newMediaQueries = declaration.a;
				var structureStyleBlocks = declaration.b;
				return A2(
					rtfeldman$elm_css$Css$Structure$MediaRule,
					_Utils_ap(mediaQueries, newMediaQueries),
					structureStyleBlocks);
			case 2:
				var str = declaration.a;
				var declarations = declaration.b;
				return A2(
					rtfeldman$elm_css$Css$Structure$SupportsRule,
					str,
					A2(
						elm$core$List$map,
						rtfeldman$elm_css$Css$Preprocess$Resolve$toMediaRule(mediaQueries),
						declarations));
			case 3:
				var str1 = declaration.a;
				var str2 = declaration.b;
				var str3 = declaration.c;
				var str4 = declaration.d;
				var structureStyleBlock = declaration.e;
				return A5(rtfeldman$elm_css$Css$Structure$DocumentRule, str1, str2, str3, str4, structureStyleBlock);
			case 4:
				return declaration;
			case 5:
				return declaration;
			case 6:
				return declaration;
			case 7:
				return declaration;
			case 8:
				return declaration;
			default:
				return declaration;
		}
	});
var rtfeldman$elm_css$Css$Structure$CounterStyle = function (a) {
	return {$: 8, a: a};
};
var rtfeldman$elm_css$Css$Structure$FontFace = function (a) {
	return {$: 5, a: a};
};
var rtfeldman$elm_css$Css$Structure$Keyframes = function (a) {
	return {$: 6, a: a};
};
var rtfeldman$elm_css$Css$Structure$PageRule = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$Selector = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var rtfeldman$elm_css$Css$Structure$StyleBlock = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration = function (a) {
	return {$: 0, a: a};
};
var rtfeldman$elm_css$Css$Structure$Viewport = function (a) {
	return {$: 7, a: a};
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
					case 0:
						var styleBlock = declarations.a.a;
						return _List_fromArray(
							[
								rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration(
								A2(rtfeldman$elm_css$Css$Structure$withPropertyAppended, property, styleBlock))
							]);
					case 1:
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
		return {$: 2, a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$TypeSelectorSequence = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$UniversalSelectorSequence = function (a) {
	return {$: 1, a: a};
};
var rtfeldman$elm_css$Css$Structure$appendRepeatable = F2(
	function (selector, sequence) {
		switch (sequence.$) {
			case 0:
				var typeSelector = sequence.a;
				var list = sequence.b;
				return A2(
					rtfeldman$elm_css$Css$Structure$TypeSelectorSequence,
					typeSelector,
					_Utils_ap(
						list,
						_List_fromArray(
							[selector])));
			case 1:
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
						case 0:
							var styleBlock = declarations.a.a;
							return A2(
								elm$core$List$map,
								rtfeldman$elm_css$Css$Structure$StyleBlockDeclaration,
								update(styleBlock));
						case 1:
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
									if ((_n5.b && (_n5.a.$ === 1)) && (!_n5.b.b)) {
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
						case 2:
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
						case 3:
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
						case 4:
							var _n9 = declarations.a;
							return declarations;
						case 5:
							return declarations;
						case 6:
							return declarations;
						case 7:
							return declarations;
						case 8:
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
		if (!declaration.$) {
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
		return {aA: charsProcessed, aI: hash, ar: seed, aR: shift};
	});
var Skinney$murmur3$Murmur3$c1 = 3432918353;
var Skinney$murmur3$Murmur3$c2 = 461845907;
var elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var Skinney$murmur3$Murmur3$multiplyBy = F2(
	function (b, a) {
		return ((a & 65535) * b) + ((((a >>> 16) * b) & 65535) << 16);
	});
var Skinney$murmur3$Murmur3$rotlBy = F2(
	function (b, a) {
		return (a << b) | (a >>> (32 - b));
	});
var Skinney$murmur3$Murmur3$finalize = function (data) {
	var acc = data.aI ? (data.ar ^ A2(
		Skinney$murmur3$Murmur3$multiplyBy,
		Skinney$murmur3$Murmur3$c2,
		A2(
			Skinney$murmur3$Murmur3$rotlBy,
			15,
			A2(Skinney$murmur3$Murmur3$multiplyBy, Skinney$murmur3$Murmur3$c1, data.aI)))) : data.ar;
	var h0 = acc ^ data.aA;
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
		var res = data.aI | ((255 & elm$core$Char$toCode(c)) << data.aR);
		var _n0 = data.aR;
		if (_n0 === 24) {
			return {
				aA: data.aA + 1,
				aI: 0,
				ar: A2(Skinney$murmur3$Murmur3$mix, data.ar, res),
				aR: 0
			};
		} else {
			return {aA: data.aA + 1, aI: res, ar: data.ar, aR: data.aR + 8};
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
				return '0';
			case 1:
				return '1';
			case 2:
				return '2';
			case 3:
				return '3';
			case 4:
				return '4';
			case 5:
				return '5';
			case 6:
				return '6';
			case 7:
				return '7';
			case 8:
				return '8';
			case 9:
				return '9';
			case 10:
				return 'a';
			case 11:
				return 'b';
			case 12:
				return 'c';
			case 13:
				return 'd';
			case 14:
				return 'e';
			case 15:
				return 'f';
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
			'-',
			A2(rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, -num)) : A2(rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, num));
};
var rtfeldman$elm_css$Hash$fromString = function (str) {
	return A2(
		elm$core$String$cons,
		'_',
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
			if ((!_n14.a.$) && (!_n14.b.$)) {
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
				case 0:
					var property = styles.a.a;
					var rest = styles.b;
					return A2(
						rtfeldman$elm_css$Css$Preprocess$Resolve$applyStyles,
						rest,
						A2(rtfeldman$elm_css$Css$Structure$appendProperty, property, declarations));
				case 1:
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
				case 2:
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
							case 0:
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
							case 1:
								var mediaQueries = declaration.a;
								var styleBlocks = declaration.b;
								return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule, mediaQueries, styleBlocks);
							case 2:
								var str = declaration.a;
								var otherSnippets = declaration.b;
								return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule, str, otherSnippets);
							case 3:
								var str1 = declaration.a;
								var str2 = declaration.b;
								var str3 = declaration.c;
								var str4 = declaration.d;
								var styleBlock = declaration.e;
								return A2(
									elm$core$List$map,
									A4(rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule, str1, str2, str3, str4),
									rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
							case 4:
								var str = declaration.a;
								var properties = declaration.b;
								return _List_fromArray(
									[
										A2(rtfeldman$elm_css$Css$Structure$PageRule, str, properties)
									]);
							case 5:
								var properties = declaration.a;
								return _List_fromArray(
									[
										rtfeldman$elm_css$Css$Structure$FontFace(properties)
									]);
							case 6:
								var properties = declaration.a;
								return _List_fromArray(
									[
										rtfeldman$elm_css$Css$Structure$Viewport(properties)
									]);
							case 7:
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
				case 3:
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
				case 5:
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
								{eu: str, bu: name})
							]));
				case 4:
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
		case 0:
			var styleBlock = snippetDeclaration.a;
			return rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock);
		case 1:
			var mediaQueries = snippetDeclaration.a;
			var styleBlocks = snippetDeclaration.b;
			return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveMediaRule, mediaQueries, styleBlocks);
		case 2:
			var str = snippetDeclaration.a;
			var snippets = snippetDeclaration.b;
			return A2(rtfeldman$elm_css$Css$Preprocess$Resolve$resolveSupportsRule, str, snippets);
		case 3:
			var str1 = snippetDeclaration.a;
			var str2 = snippetDeclaration.b;
			var str3 = snippetDeclaration.c;
			var str4 = snippetDeclaration.d;
			var styleBlock = snippetDeclaration.e;
			return A2(
				elm$core$List$map,
				A4(rtfeldman$elm_css$Css$Preprocess$Resolve$toDocumentRule, str1, str2, str3, str4),
				rtfeldman$elm_css$Css$Preprocess$Resolve$expandStyleBlock(styleBlock));
		case 4:
			var str = snippetDeclaration.a;
			var properties = snippetDeclaration.b;
			return _List_fromArray(
				[
					A2(rtfeldman$elm_css$Css$Structure$PageRule, str, properties)
				]);
		case 5:
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					rtfeldman$elm_css$Css$Structure$FontFace(properties)
				]);
		case 6:
			var properties = snippetDeclaration.a;
			return _List_fromArray(
				[
					rtfeldman$elm_css$Css$Structure$Viewport(properties)
				]);
		case 7:
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
	var charset = _n0.c4;
	var imports = _n0.dm;
	var namespaces = _n0.dF;
	var snippets = _n0.d1;
	var declarations = rtfeldman$elm_css$Css$Preprocess$Resolve$extract(
		A2(elm$core$List$concatMap, rtfeldman$elm_css$Css$Preprocess$unwrapSnippet, snippets));
	return {c4: charset, ev: declarations, dm: imports, dF: namespaces};
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
			case 0:
				var _n2 = declaration.a;
				var properties = _n2.c;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 1:
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
			case 2:
				var otherDeclarations = declaration.b;
				return elm$core$List$isEmpty(otherDeclarations) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 3:
				return _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 4:
				var properties = declaration.b;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 5:
				var properties = declaration.a;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 6:
				var record = declaration.a;
				return elm$core$String$isEmpty(record.eu) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					A3(elm$core$Dict$insert, record.bu, record.eu, keyframesByName),
					declarations);
			case 7:
				var properties = declaration.a;
				return elm$core$List$isEmpty(properties) ? _Utils_Tuple2(keyframesByName, declarations) : _Utils_Tuple2(
					keyframesByName,
					A2(elm$core$List$cons, declaration, declarations));
			case 8:
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
						{eu: decl, bu: name});
				},
				elm$core$Dict$toList(keyframesByName)),
			compactedDeclarations);
	});
var rtfeldman$elm_css$Css$Structure$compactStylesheet = function (_n0) {
	var charset = _n0.c4;
	var imports = _n0.dm;
	var namespaces = _n0.dF;
	var declarations = _n0.ev;
	var _n1 = A3(
		elm$core$List$foldr,
		rtfeldman$elm_css$Css$Structure$compactHelp,
		_Utils_Tuple2(elm$core$Dict$empty, _List_Nil),
		declarations);
	var keyframesByName = _n1.a;
	var compactedDeclarations = _n1.b;
	var finalDeclarations = A2(rtfeldman$elm_css$Css$Structure$withKeyframeDeclarations, keyframesByName, compactedDeclarations);
	return {c4: charset, ev: finalDeclarations, dm: imports, dF: namespaces};
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
	return '(' + (expression.de + (A2(
		elm$core$Maybe$withDefault,
		'',
		A2(
			elm$core$Maybe$map,
			elm$core$Basics$append(': '),
			expression.X)) + ')'));
};
var rtfeldman$elm_css$Css$Structure$Output$mediaTypeToString = function (mediaType) {
	switch (mediaType) {
		case 0:
			return 'print';
		case 1:
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
		case 0:
			var expressions = mediaQuery.a;
			return A2(
				elm$core$String$join,
				' and ',
				A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$mediaExpressionToString, expressions));
		case 1:
			var mediaType = mediaQuery.a;
			var expressions = mediaQuery.b;
			return A3(prefixWith, 'only', mediaType, expressions);
		case 2:
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
	var str = _n0;
	return '::' + str;
};
var rtfeldman$elm_css$Css$Structure$Output$combinatorToString = function (combinator) {
	switch (combinator) {
		case 0:
			return '+';
		case 1:
			return '~';
		case 2:
			return '>';
		default:
			return '';
	}
};
var rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString = function (repeatableSimpleSelector) {
	switch (repeatableSimpleSelector.$) {
		case 0:
			var str = repeatableSimpleSelector.a;
			return '.' + str;
		case 1:
			var str = repeatableSimpleSelector.a;
			return '#' + str;
		case 2:
			var str = repeatableSimpleSelector.a;
			return ':' + str;
		default:
			var str = repeatableSimpleSelector.a;
			return '[' + (str + ']');
	}
};
var rtfeldman$elm_css$Css$Structure$Output$simpleSelectorSequenceToString = function (simpleSelectorSequence) {
	switch (simpleSelectorSequence.$) {
		case 0:
			var str = simpleSelectorSequence.a;
			var repeatableSimpleSelectors = simpleSelectorSequence.b;
			return A2(
				elm$core$String$join,
				'',
				A2(
					elm$core$List$cons,
					str,
					A2(elm$core$List$map, rtfeldman$elm_css$Css$Structure$Output$repeatableSimpleSelectorToString, repeatableSimpleSelectors)));
		case 1:
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
		case 0:
			var styleBlock = decl.a;
			return A2(rtfeldman$elm_css$Css$Structure$Output$prettyPrintStyleBlock, rtfeldman$elm_css$Css$Structure$Output$noIndent, styleBlock);
		case 1:
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
		case 2:
			return 'TODO';
		case 3:
			return 'TODO';
		case 4:
			return 'TODO';
		case 5:
			return 'TODO';
		case 6:
			var name = decl.a.bu;
			var declaration = decl.a.eu;
			return '@keyframes ' + (name + (' {\n' + (declaration + '\n}')));
		case 7:
			return 'TODO';
		case 8:
			return 'TODO';
		default:
			return 'TODO';
	}
};
var rtfeldman$elm_css$Css$Structure$Output$prettyPrint = function (_n0) {
	var charset = _n0.c4;
	var imports = _n0.dm;
	var namespaces = _n0.dF;
	var declarations = _n0.ev;
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
	return {$: 0, a: a};
};
var rtfeldman$elm_css$Css$Preprocess$Snippet = elm$core$Basics$identity;
var rtfeldman$elm_css$Css$Preprocess$StyleBlock = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var rtfeldman$elm_css$Css$Preprocess$StyleBlockDeclaration = function (a) {
	return {$: 0, a: a};
};
var rtfeldman$elm_css$VirtualDom$Styled$makeSnippet = F2(
	function (styles, sequence) {
		var selector = A3(rtfeldman$elm_css$Css$Structure$Selector, sequence, _List_Nil, elm$core$Maybe$Nothing);
		return _List_fromArray(
			[
				rtfeldman$elm_css$Css$Preprocess$StyleBlockDeclaration(
				A3(rtfeldman$elm_css$Css$Preprocess$StyleBlock, selector, _List_Nil, styles))
			]);
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
		case 4:
			var plainNode = vdom.a;
			return plainNode;
		case 0:
			var elemType = vdom.a;
			var properties = vdom.b;
			var children = vdom.c;
			return A3(rtfeldman$elm_css$VirtualDom$Styled$unstyle, elemType, properties, children);
		case 1:
			var ns = vdom.a;
			var elemType = vdom.b;
			var properties = vdom.c;
			var children = vdom.d;
			return A4(rtfeldman$elm_css$VirtualDom$Styled$unstyleNS, ns, elemType, properties, children);
		case 2:
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
var author$project$TaskList$Add = {$: 3};
var author$project$TaskList$UpdateNewEntryField = function (a) {
	return {$: 9, a: a};
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
var rtfeldman$elm_css$Html$Styled$Attributes$autofocus = rtfeldman$elm_css$Html$Styled$Attributes$boolProperty('autofocus');
var rtfeldman$elm_css$Html$Styled$Attributes$placeholder = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('placeholder');
var rtfeldman$elm_css$Html$Styled$Attributes$value = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('value');
var rtfeldman$elm_css$Html$Styled$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 1, a: a};
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
	return {$: 4, a: a};
};
var author$project$TaskList$EditingTitle = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var author$project$TaskList$FocusSlider = F2(
	function (a, b) {
		return {$: 7, a: a, b: b};
	});
var author$project$TaskList$UpdateTitle = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var author$project$TaskList$UpdateTaskDate = F3(
	function (a, b, c) {
		return {$: 8, a: a, b: b, c: c};
	});
var author$project$TaskList$extractDate = F3(
	function (task, field, input) {
		var _n0 = author$project$SmartTime$Human$Calendar$fromNumberString(input);
		if (!_n0.$) {
			var date = _n0.a;
			return A3(
				author$project$TaskList$UpdateTaskDate,
				task,
				field,
				elm$core$Maybe$Just(
					author$project$SmartTime$Human$Moment$DateOnly(date)));
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
var rtfeldman$elm_css$Css$Structure$Compatible = 0;
var rtfeldman$elm_css$Css$angleConverter = F2(
	function (suffix, angleVal) {
		return {
			en: 0,
			U: 0,
			X: _Utils_ap(
				elm$core$String$fromFloat(angleVal),
				suffix)
		};
	});
var rtfeldman$elm_css$Css$deg = rtfeldman$elm_css$Css$angleConverter('deg');
var rtfeldman$elm_css$Css$Preprocess$ExtendSelector = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$PseudoClassSelector = function (a) {
	return {$: 2, a: a};
};
var rtfeldman$elm_css$Css$pseudoClass = function (_class) {
	return rtfeldman$elm_css$Css$Preprocess$ExtendSelector(
		rtfeldman$elm_css$Css$Structure$PseudoClassSelector(_class));
};
var rtfeldman$elm_css$Css$focus = rtfeldman$elm_css$Css$pseudoClass('focus');
var rtfeldman$elm_css$Css$Preprocess$WithPseudoElement = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var rtfeldman$elm_css$Css$Structure$PseudoElement = elm$core$Basics$identity;
var rtfeldman$elm_css$Css$pseudoElement = function (element) {
	return rtfeldman$elm_css$Css$Preprocess$WithPseudoElement(element);
};
var rtfeldman$elm_css$Css$PxUnits = 0;
var rtfeldman$elm_css$Css$Internal$lengthConverter = F3(
	function (units, unitLabel, numericValue) {
		return {
			cR: 0,
			c1: 0,
			aF: 0,
			G: 0,
			a3: 0,
			aK: 0,
			ad: 0,
			aL: 0,
			aM: 0,
			am: 0,
			an: 0,
			V: 0,
			ag: numericValue,
			aV: 0,
			aX: unitLabel,
			bd: units,
			X: _Utils_ap(
				elm$core$String$fromFloat(numericValue),
				unitLabel)
		};
	});
var rtfeldman$elm_css$Css$px = A2(rtfeldman$elm_css$Css$Internal$lengthConverter, 0, 'px');
var rtfeldman$elm_css$Css$cssFunction = F2(
	function (funcName, args) {
		return funcName + ('(' + (A2(elm$core$String$join, ', ', args) + ')'));
	});
var rtfeldman$elm_css$Css$rotate = function (_n0) {
	var value = _n0.X;
	return {
		w: 0,
		X: A2(
			rtfeldman$elm_css$Css$cssFunction,
			'rotate',
			_List_fromArray(
				[value]))
	};
};
var rtfeldman$elm_css$Css$Preprocess$AppendProperty = function (a) {
	return {$: 0, a: a};
};
var rtfeldman$elm_css$Css$property = F2(
	function (key, value) {
		return rtfeldman$elm_css$Css$Preprocess$AppendProperty(key + (':' + value));
	});
var rtfeldman$elm_css$Css$prop1 = F2(
	function (key, arg) {
		return A2(rtfeldman$elm_css$Css$property, key, arg.X);
	});
var rtfeldman$elm_css$Css$valuesOrNone = function (list) {
	return elm$core$List$isEmpty(list) ? {X: 'none'} : {
		X: A2(
			elm$core$String$join,
			' ',
			A2(
				elm$core$List$map,
				function ($) {
					return $.X;
				},
				list))
	};
};
var rtfeldman$elm_css$Css$transforms = A2(
	elm$core$Basics$composeL,
	rtfeldman$elm_css$Css$prop1('transform'),
	rtfeldman$elm_css$Css$valuesOrNone);
var rtfeldman$elm_css$Css$translateY = function (_n0) {
	var value = _n0.X;
	return {
		w: 0,
		X: A2(
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
		'_',
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
			task.dl,
			A2(
				author$project$Task$Progress$setPortion,
				task.bQ,
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
					author$project$Task$Progress$getPortion(task.bQ))),
				rtfeldman$elm_css$Html$Styled$Attributes$min('0'),
				rtfeldman$elm_css$Html$Styled$Attributes$max(
				elm$core$String$fromInt(
					author$project$Task$Progress$getWhole(task.bQ))),
				rtfeldman$elm_css$Html$Styled$Attributes$step(
				author$project$Task$Progress$isDiscrete(
					author$project$Task$Progress$getUnits(task.bQ)) ? '1' : 'any'),
				rtfeldman$elm_css$Html$Styled$Events$onInput(
				author$project$TaskList$extractSliderInput(task)),
				rtfeldman$elm_css$Html$Styled$Events$onDoubleClick(
				A2(author$project$TaskList$EditingTitle, task.dl, true)),
				rtfeldman$elm_css$Html$Styled$Events$onFocus(
				A2(author$project$TaskList$FocusSlider, task.dl, true)),
				rtfeldman$elm_css$Html$Styled$Events$onBlur(
				A2(author$project$TaskList$FocusSlider, task.dl, false)),
				author$project$TaskList$dynamicSliderThumbCss(
				author$project$Task$Progress$getNormalizedPortion(task.bQ))
			]),
		_List_Nil);
};
var author$project$TaskList$describeEffort = function (task) {
	var sayEffort = function (amount) {
		return author$project$SmartTime$Human$Duration$breakdownNonzero(amount);
	};
	var _n0 = _Utils_Tuple2(
		sayEffort(task.dC),
		sayEffort(task.eN));
	if (!_n0.a.b) {
		if (!_n0.b.b) {
			return '';
		} else {
			var givenMax = _n0.b;
			return 'up to ' + (author$project$SmartTime$Human$Duration$abbreviatedSpaced(givenMax) + ' by ');
		}
	} else {
		if (!_n0.b.b) {
			var givenMin = _n0.a;
			return 'at least ' + (author$project$SmartTime$Human$Duration$abbreviatedSpaced(givenMin) + ' by ');
		} else {
			var givenMin = _n0.a;
			var givenMax = _n0.b;
			return author$project$SmartTime$Human$Duration$abbreviatedSpaced(givenMin) + (' - ' + (author$project$SmartTime$Human$Duration$abbreviatedSpaced(givenMax) + ' by '));
		}
	}
};
var author$project$SmartTime$Human$Calendar$Week$Fri = 4;
var author$project$SmartTime$Human$Calendar$Week$Mon = 0;
var author$project$SmartTime$Human$Calendar$Week$Sat = 5;
var author$project$SmartTime$Human$Calendar$Week$Sun = 6;
var author$project$SmartTime$Human$Calendar$Week$Thu = 3;
var author$project$SmartTime$Human$Calendar$Week$Tue = 1;
var author$project$SmartTime$Human$Calendar$Week$Wed = 2;
var author$project$SmartTime$Human$Calendar$Week$numberToDay = function (n) {
	var _n0 = A2(elm$core$Basics$max, 1, n);
	switch (_n0) {
		case 1:
			return 0;
		case 2:
			return 1;
		case 3:
			return 2;
		case 4:
			return 3;
		case 5:
			return 4;
		case 6:
			return 5;
		default:
			return 6;
	}
};
var author$project$SmartTime$Human$Calendar$dayOfWeek = function (_n0) {
	var rd = _n0;
	var dayNum = function () {
		var _n1 = A2(elm$core$Basics$modBy, 7, rd);
		if (!_n1) {
			return 7;
		} else {
			var n = _n1;
			return n;
		}
	}();
	return author$project$SmartTime$Human$Calendar$Week$numberToDay(dayNum);
};
var author$project$SmartTime$Human$Calendar$intIsBetween = F3(
	function (a, b, x) {
		return (_Utils_cmp(a, x) < 1) && (_Utils_cmp(x, b) < 1);
	});
var author$project$SmartTime$Human$Calendar$subtract = F2(
	function (_n0, _n1) {
		var startDate = _n0;
		var endDate = _n1;
		return startDate - endDate;
	});
var author$project$SmartTime$Human$Calendar$Week$dayToName = function (d) {
	switch (d) {
		case 0:
			return 'Monday';
		case 1:
			return 'Tuesday';
		case 2:
			return 'Wednesday';
		case 3:
			return 'Thursday';
		case 4:
			return 'Friday';
		case 5:
			return 'Saturday';
		default:
			return 'Sunday';
	}
};
var author$project$SmartTime$Human$Calendar$describeVsToday = F2(
	function (today, describee) {
		var des = author$project$SmartTime$Human$Calendar$toParts(describee);
		var dayDiff = A2(author$project$SmartTime$Human$Calendar$subtract, describee, today);
		var _n0 = _Utils_Tuple2(dayDiff, -dayDiff);
		_n0$2:
		while (true) {
			_n0$3:
			while (true) {
				switch (_n0.b) {
					case 1:
						return 'yesterday';
					case 0:
						switch (_n0.a) {
							case 0:
								return 'today';
							case 1:
								break _n0$2;
							default:
								break _n0$3;
						}
					default:
						if (_n0.a === 1) {
							break _n0$2;
						} else {
							break _n0$3;
						}
				}
			}
			var futureDays = _n0.a;
			var pastDays = _n0.b;
			return A3(author$project$SmartTime$Human$Calendar$intIsBetween, 0, 6, futureDays) ? ('this coming ' + author$project$SmartTime$Human$Calendar$Week$dayToName(
				author$project$SmartTime$Human$Calendar$dayOfWeek(describee))) : (A3(author$project$SmartTime$Human$Calendar$intIsBetween, 0, 6, pastDays) ? ('this past ' + author$project$SmartTime$Human$Calendar$Week$dayToName(
				author$project$SmartTime$Human$Calendar$dayOfWeek(describee))) : (_Utils_eq(
				author$project$SmartTime$Human$Calendar$year(today),
				des.t) ? (author$project$SmartTime$Human$Calendar$Month$toName(des.x) + (' ' + elm$core$String$fromInt(
				author$project$SmartTime$Human$Calendar$Month$dayToInt(des.y)))) : (author$project$SmartTime$Human$Calendar$Month$toName(des.x) + (' ' + (elm$core$String$fromInt(
				author$project$SmartTime$Human$Calendar$Month$dayToInt(des.y)) + (' ' + author$project$SmartTime$Human$Calendar$Year$toString(des.t)))))));
		}
		return 'tomorrow';
	});
var author$project$SmartTime$Human$Clock$toShortString = function (timeOfDay) {
	return author$project$SmartTime$Human$Duration$colonSeparated(
		author$project$SmartTime$Human$Duration$breakdownHM(timeOfDay));
};
var author$project$SmartTime$Human$Moment$extractDate = F2(
	function (zone, moment) {
		return A2(author$project$SmartTime$Human$Moment$humanize, zone, moment).a;
	});
var author$project$SmartTime$Human$Moment$humanizeFuzzy = F2(
	function (zone, fuzzy) {
		var wrapTimeWithJust = function (_n2) {
			var date = _n2.a;
			var time = _n2.b;
			return _Utils_Tuple2(
				date,
				elm$core$Maybe$Just(time));
		};
		switch (fuzzy.$) {
			case 2:
				var date = fuzzy.a;
				return _Utils_Tuple2(date, elm$core$Maybe$Nothing);
			case 1:
				var _n1 = fuzzy.a;
				var date = _n1.a;
				var time = _n1.b;
				return _Utils_Tuple2(
					date,
					elm$core$Maybe$Just(time));
			default:
				var moment = fuzzy.a;
				return wrapTimeWithJust(
					A2(author$project$SmartTime$Human$Moment$humanize, zone, moment));
		}
	});
var author$project$SmartTime$Human$Moment$fuzzyDescription = F3(
	function (now, zone, fuzzyMoment) {
		var _n0 = A2(author$project$SmartTime$Human$Moment$humanizeFuzzy, zone, fuzzyMoment);
		if (_n0.b.$ === 1) {
			var date = _n0.a;
			var _n1 = _n0.b;
			return A2(
				author$project$SmartTime$Human$Calendar$describeVsToday,
				A2(author$project$SmartTime$Human$Moment$extractDate, zone, now),
				date);
		} else {
			var date = _n0.a;
			var time = _n0.b.a;
			return A2(
				author$project$SmartTime$Human$Calendar$describeVsToday,
				A2(author$project$SmartTime$Human$Moment$extractDate, zone, now),
				date) + (' at ' + author$project$SmartTime$Human$Clock$toShortString(time));
		}
	});
var author$project$TaskList$describeTaskMoment = F3(
	function (now, zone, dueMoment) {
		return A3(author$project$SmartTime$Human$Moment$fuzzyDescription, now, zone, dueMoment);
	});
var author$project$TaskList$timingInfo = F2(
	function (env, task) {
		var effortDescription = author$project$TaskList$describeEffort(task);
		var dueDescription = A2(
			elm$core$Maybe$withDefault,
			'whenever',
			A2(
				elm$core$Maybe$map,
				A2(author$project$TaskList$describeTaskMoment, env.ea, env.e9),
				task.et));
		return rtfeldman$elm_css$Html$Styled$text(
			_Utils_ap(effortDescription, dueDescription));
	});
var rtfeldman$elm_css$Html$Styled$Attributes$id = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('id');
var rtfeldman$elm_css$Html$Styled$Attributes$pattern = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('pattern');
var rtfeldman$elm_css$Html$Styled$Attributes$title = rtfeldman$elm_css$Html$Styled$Attributes$stringProperty('title');
var author$project$TaskList$viewTask = F2(
	function (env, task) {
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
						])),
					rtfeldman$elm_css$Html$Styled$Attributes$title(
					elm$core$String$concat(
						A2(
							elm$core$List$intersperse,
							'\n',
							A2(
								elm$core$List$filterMap,
								elm$core$Basics$identity,
								_List_fromArray(
									[
										A2(
										elm$core$Maybe$map,
										A2(
											elm$core$Basics$composeR,
											author$project$ID$read,
											A2(
												elm$core$Basics$composeR,
												elm$core$String$fromInt,
												elm$core$String$append('activity: '))),
										task.ek),
										elm$core$Maybe$Just(
										'importance: ' + elm$core$String$fromFloat(task.eG))
									])))))
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
										task.dl,
										(!author$project$Task$Task$completed(task)) ? author$project$Task$Progress$maximize(task.bQ) : A2(author$project$Task$Progress$setPortion, task.bQ, 0)))
								]),
							_List_Nil),
							A2(
							rtfeldman$elm_css$Html$Styled$label,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Events$onDoubleClick(
									A2(author$project$TaskList$EditingTitle, task.dl, true)),
									rtfeldman$elm_css$Html$Styled$Events$onClick(
									A2(author$project$TaskList$FocusSlider, task.dl, true))
								]),
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$text(task.ba)
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$div,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$class('timing-info')
								]),
							_List_fromArray(
								[
									A2(author$project$TaskList$timingInfo, env, task)
								])),
							A2(
							rtfeldman$elm_css$Html$Styled$button,
							_List_fromArray(
								[
									rtfeldman$elm_css$Html$Styled$Attributes$class('destroy'),
									rtfeldman$elm_css$Html$Styled$Events$onClick(
									author$project$TaskList$Delete(task.dl))
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
							rtfeldman$elm_css$Html$Styled$Attributes$value(task.ba),
							rtfeldman$elm_css$Html$Styled$Attributes$name('title'),
							rtfeldman$elm_css$Html$Styled$Attributes$id(
							'task-' + elm$core$String$fromInt(task.dl)),
							rtfeldman$elm_css$Html$Styled$Events$onInput(
							author$project$TaskList$UpdateTitle(task.dl)),
							rtfeldman$elm_css$Html$Styled$Events$onBlur(
							A2(author$project$TaskList$EditingTitle, task.dl, false)),
							author$project$TaskList$onEnter(
							A2(author$project$TaskList$EditingTitle, task.dl, false))
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
									A2(author$project$TaskList$extractDate, task.dl, 'Ready')),
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
									A2(author$project$TaskList$extractDate, task.dl, 'Start')),
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
									A2(author$project$TaskList$extractDate, task.dl, 'Finish')),
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
									A2(author$project$TaskList$extractDate, task.dl, 'Deadline')),
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
									A2(author$project$TaskList$extractDate, task.dl, 'Expires')),
									rtfeldman$elm_css$Html$Styled$Attributes$pattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')
								]),
							_List_Nil)
						]))
				]));
	});
var elm$virtual_dom$VirtualDom$lazy3 = _VirtualDom_lazy3;
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
	function (env, task) {
		return _Utils_Tuple2(
			elm$core$String$fromInt(task.dl),
			A3(rtfeldman$elm_css$Html$Styled$Lazy$lazy2, author$project$TaskList$viewTask, env, task));
	});
var rtfeldman$elm_css$Html$Styled$section = rtfeldman$elm_css$Html$Styled$node('section');
var rtfeldman$elm_css$VirtualDom$Styled$KeyedNode = F3(
	function (a, b, c) {
		return {$: 2, a: a, b: b, c: c};
	});
var rtfeldman$elm_css$VirtualDom$Styled$keyedNode = rtfeldman$elm_css$VirtualDom$Styled$KeyedNode;
var rtfeldman$elm_css$Html$Styled$Keyed$node = rtfeldman$elm_css$VirtualDom$Styled$keyedNode;
var rtfeldman$elm_css$Html$Styled$Keyed$ul = rtfeldman$elm_css$Html$Styled$Keyed$node('ul');
var author$project$TaskList$viewTasks = F3(
	function (env, filter, tasks) {
		var isVisible = function (task) {
			switch (filter) {
				case 2:
					return author$project$Task$Task$completed(task);
				case 1:
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
						author$project$TaskList$viewKeyedTask(env),
						A2(elm$core$List$filter, isVisible, tasks)))
				]));
	});
var rtfeldman$elm_css$Css$hidden = {I: 0, aN: 0, X: 'hidden', bf: 0};
var rtfeldman$elm_css$Css$UnitlessFloat = 0;
var rtfeldman$elm_css$Css$num = function (val) {
	return {
		an: 0,
		V: 0,
		eP: 0,
		ag: val,
		aX: '',
		bd: 0,
		X: elm$core$String$fromFloat(val)
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
		var sortedTasks = A3(
			author$project$Task$Task$prioritize,
			env.ea,
			env.e9,
			elm_community$intdict$IntDict$values(app.e8));
		var activeFilter = A2(
			elm$core$Maybe$withDefault,
			0,
			elm$core$List$head(filters));
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
							A4(rtfeldman$elm_css$Html$Styled$Lazy$lazy3, author$project$TaskList$viewTasks, env, activeFilter, sortedTasks),
							A3(
							rtfeldman$elm_css$Html$Styled$Lazy$lazy2,
							author$project$TaskList$viewControls,
							filters,
							elm_community$intdict$IntDict$values(app.e8))
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
	return !activity.b;
};
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
	return {$: 6, a: a};
};
var rtfeldman$elm_css$Css$Internal$getOverloadedProperty = F3(
	function (functionName, desiredKey, style) {
		getOverloadedProperty:
		while (true) {
			switch (style.$) {
				case 0:
					var str = style.a;
					var key = A2(
						elm$core$Maybe$withDefault,
						'',
						elm$core$List$head(
							A2(elm$core$String$split, ':', str)));
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, key);
				case 1:
					var selector = style.a;
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-selector'));
				case 2:
					var combinator = style.a;
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-combinator'));
				case 3:
					var pseudoElement = style.a;
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-pseudo-element setter'));
				case 4:
					return A2(rtfeldman$elm_css$Css$Internal$property, desiredKey, 'elm-css-error-cannot-apply-' + (functionName + '-with-inapplicable-Style-for-media-query'));
				case 5:
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
var rtfeldman$elm_css$Css$Internal$IncompatibleUnits = 0;
var rtfeldman$elm_css$Css$Internal$lengthForOverloadedProperty = A3(rtfeldman$elm_css$Css$Internal$lengthConverter, 0, '', 0);
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
		case 0:
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
		case 1:
			return rtfeldman$elm_css$Html$Styled$text('');
		default:
			return rtfeldman$elm_css$Html$Styled$text('');
	}
};
var author$project$SmartTime$Duration$fromHours = function (_float) {
	return elm$core$Basics$round(_float * author$project$SmartTime$Duration$hourLength);
};
var author$project$SmartTime$Human$Moment$setTime = F3(
	function (newTime, zone, moment) {
		var _n0 = A2(author$project$SmartTime$Human$Moment$humanize, zone, moment);
		var oldDate = _n0.a;
		return A3(author$project$SmartTime$Human$Moment$fromDateAndTime, zone, oldDate, newTime);
	});
var author$project$SmartTime$Human$Moment$clockTurnBack = F3(
	function (timeOfDay, zone, moment) {
		var newMoment = A3(author$project$SmartTime$Human$Moment$setTime, timeOfDay, zone, moment);
		return (A2(author$project$SmartTime$Moment$compare, newMoment, moment) === 1) ? newMoment : A2(author$project$SmartTime$Moment$past, newMoment, author$project$SmartTime$Duration$aDay);
	});
var author$project$Activity$Measure$justToday = F2(
	function (timeline, _n0) {
		var now = _n0.a;
		var zone = _n0.b;
		var threeAM = author$project$SmartTime$Duration$fromHours(3);
		var last3am = A3(author$project$SmartTime$Human$Moment$clockTurnBack, threeAM, zone, now);
		return A3(author$project$Activity$Measure$timelineLimit, timeline, now, last3am);
	});
var author$project$Activity$Measure$justTodayTotal = F3(
	function (timeline, env, activityID) {
		var lastPeriod = A2(
			author$project$Activity$Measure$justToday,
			timeline,
			_Utils_Tuple2(env.ea, env.e9));
		return A3(author$project$Activity$Measure$totalLive, env.ea, lastPeriod, activityID);
	});
var author$project$TimeTracker$writeActivityToday = F3(
	function (app, env, activityID) {
		return author$project$Activity$Measure$inHoursMinutes(
			A3(author$project$Activity$Measure$justTodayTotal, app.cH, env, activityID));
	});
var author$project$TimeTracker$writeActivityUsage = F3(
	function (app, env, _n0) {
		var activityID = _n0.a;
		var activity = _n0.b;
		var period = activity.h.b;
		var lastPeriod = A3(author$project$Activity$Measure$relevantTimeline, app.cH, env.ea, period);
		var total = A3(author$project$Activity$Measure$totalLive, env.ea, lastPeriod, activityID);
		var totalMinutes = author$project$SmartTime$Duration$inMinutesRounded(total);
		return (author$project$SmartTime$Duration$inMs(total) > 0) ? (elm$core$String$fromInt(totalMinutes) + ('/' + (elm$core$String$fromInt(
			author$project$SmartTime$Duration$inMinutesRounded(
				author$project$SmartTime$Human$Duration$toDuration(period))) + 'm'))) : '';
	});
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
									A2(author$project$Activity$Measure$sessions, app.cH, activityID))))
						]),
					_List_fromArray(
						[
							author$project$TimeTracker$viewIcon(activity.g),
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
								author$project$Incubator$IntDict$Extra$filterValues,
								author$project$Activity$Activity$showing,
								author$project$Activity$Activity$allActivities(app.bH)))))
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
var elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var rtfeldman$elm_css$VirtualDom$Styled$KeyedNodeNS = F4(
	function (a, b, c, d) {
		return {$: 3, a: a, b: b, c: c, d: d};
	});
var rtfeldman$elm_css$VirtualDom$Styled$NodeNS = F4(
	function (a, b, c, d) {
		return {$: 1, a: a, b: b, c: c, d: d};
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
			case 0:
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
			case 1:
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
			case 2:
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
			case 3:
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
	var viewState = _n0.be;
	var appData = _n0.N;
	var environment = _n0.O;
	if (_Utils_eq(environment.ea, author$project$SmartTime$Moment$zero)) {
		return {
			bi: _List_fromArray(
				[
					rtfeldman$elm_css$Html$Styled$toUnstyled(
					A2(
						rtfeldman$elm_css$Html$Styled$map,
						function (_n1) {
							return author$project$Main$NoOp;
						},
						rtfeldman$elm_css$Html$Styled$text('Loading')))
				]),
			ba: 'Loading...'
		};
	} else {
		var _n2 = viewState.aP;
		switch (_n2.$) {
			case 0:
				var subState = _n2.a;
				return {
					bi: A2(
						elm$core$List$map,
						rtfeldman$elm_css$Html$Styled$toUnstyled,
						_List_fromArray(
							[
								A2(
								rtfeldman$elm_css$Html$Styled$map,
								author$project$Main$TaskListMsg,
								A3(author$project$TaskList$view, subState, appData, environment)),
								author$project$Main$infoFooter,
								author$project$Main$errorList(appData.aj)
							])),
					ba: 'Docket - Task List'
				};
			case 1:
				var subState = _n2.a;
				return {
					bi: A2(
						elm$core$List$map,
						rtfeldman$elm_css$Html$Styled$toUnstyled,
						_List_fromArray(
							[
								A2(
								rtfeldman$elm_css$Html$Styled$map,
								author$project$Main$TimeTrackerMsg,
								A3(author$project$TimeTracker$view, subState, appData, environment)),
								author$project$Main$infoFooter,
								author$project$Main$errorList(appData.aj)
							])),
					ba: 'Docket Time Tracker'
				};
			default:
				return {
					bi: A2(
						elm$core$List$map,
						rtfeldman$elm_css$Html$Styled$toUnstyled,
						_List_fromArray(
							[author$project$Main$infoFooter])),
					ba: 'TODO Some other page'
				};
		}
	}
};
var elm$browser$Browser$application = _Browser_application;
var author$project$Main$main = elm$browser$Browser$application(
	{eI: author$project$Main$initGraphical, eT: author$project$Main$NewUrl, eU: author$project$Main$Link, e5: author$project$Main$subscriptions, cM: author$project$Main$updateWithTime, fb: author$project$Main$view});
_Platform_export({'Main':{'init':author$project$Main$main(
	elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				elm$json$Json$Decode$null(elm$core$Maybe$Nothing),
				A2(elm$json$Json$Decode$map, elm$core$Maybe$Just, elm$json$Json$Decode$string)
			])))(0)}});}(this));