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
	if (region.bX.aX === region.ct.aX)
	{
		return 'on line ' + region.bX.aX;
	}
	return 'on lines ' + region.bX.aX + ' through ' + region.ct.aX;
}



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
		impl.dP,
		impl.ec,
		impl.d9,
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


// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.dG.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done(elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done(elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.dG.b, xhr)); });
		elm$core$Maybe$isJust(request.H) && _Http_track(router, xhr, request.H.a);

		try {
			xhr.open(request.E, request.ee, true);
		} catch (e) {
			return done(elm$http$Http$BadUrl_(request.ee));
		}

		_Http_configureRequest(xhr, request);

		request.ba.a && xhr.setRequestHeader('Content-Type', request.ba.a);
		xhr.send(request.ba.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.B; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.F.a || 0;
	xhr.responseType = request.dG.d;
	xhr.withCredentials = request.al;
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
		ee: xhr.responseURL,
		de: xhr.status,
		d8: xhr.statusText,
		B: _Http_parseHeaders(xhr.getAllResponseHeaders())
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
			d7: event.loaded,
			bW: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2(elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, elm$http$Http$Receiving({
			d1: event.loaded,
			bW: event.lengthComputable ? elm$core$Maybe$Just(event.total) : elm$core$Maybe$Nothing
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
		V: func(record.V),
		bY: record.bY,
		bS: record.bS
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
		var message = !tag ? value : tag < 3 ? value.a : value.V;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.bY;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.bS) && event.preventDefault(),
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
		impl.dP,
		impl.ec,
		impl.d9,
		function(sendToApp, initialModel) {
			var view = impl.ef;
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
		impl.dP,
		impl.ec,
		impl.d9,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.a0 && impl.a0(sendToApp)
			var view = impl.ef;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.ba);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.a3) && (_VirtualDom_doc.title = title = doc.a3);
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
	var onUrlChange = impl.dU;
	var onUrlRequest = impl.dV;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		a0: function(sendToApp)
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
							&& curr.d$ === next.d$
							&& curr.dM === next.dM
							&& curr.dZ.a === next.dZ.a
						)
							? elm$browser$Browser$Internal(next)
							: elm$browser$Browser$External(href)
					));
				}
			});
		},
		dP: function(flags)
		{
			return A3(impl.dP, flags, _Browser_getUrl(), key);
		},
		ef: impl.ef,
		ec: impl.ec,
		d9: impl.d9
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
		? { b: 'hidden', dA: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { b: 'mozHidden', dA: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { b: 'msHidden', dA: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { b: 'webkitHidden', dA: 'webkitvisibilitychange' }
		: { b: 'hidden', dA: 'visibilitychange' };
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
		c9: _Browser_getScene(),
		dq: {
			bt: _Browser_window.pageXOffset,
			bu: _Browser_window.pageYOffset,
			aR: _Browser_doc.documentElement.clientWidth,
			ax: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		aR: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		ax: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
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
			c9: {
				aR: node.scrollWidth,
				ax: node.scrollHeight
			},
			dq: {
				bt: node.scrollLeft,
				bu: node.scrollTop,
				aR: node.clientWidth,
				ax: node.clientHeight
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
			c9: _Browser_getScene(),
			dq: {
				bt: x,
				bu: y,
				aR: _Browser_doc.documentElement.clientWidth,
				ax: _Browser_doc.documentElement.clientHeight
			},
			dE: {
				bt: x + rect.left,
				bu: y + rect.top,
				aR: rect.width,
				ax: rect.height
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
var elm$core$Array$branchFactor = 32;
var elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var elm$core$Basics$EQ = 1;
var elm$core$Basics$GT = 2;
var elm$core$Basics$LT = 0;
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
var elm$core$List$cons = _List_cons;
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
var elm$core$Array$toList = function (array) {
	return A3(elm$core$Array$foldr, elm$core$List$cons, _List_Nil, array);
};
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
var elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
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
var elm$core$Basics$add = _Basics_add;
var elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var elm$core$Basics$floor = _Basics_floor;
var elm$core$Basics$gt = _Utils_gt;
var elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var elm$core$Basics$mul = _Basics_mul;
var elm$core$Basics$sub = _Basics_sub;
var elm$core$Elm$JsArray$length = _JsArray_length;
var elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.v) {
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.y),
				elm$core$Array$shiftStep,
				elm$core$Elm$JsArray$empty,
				builder.y);
		} else {
			var treeLen = builder.v * elm$core$Array$branchFactor;
			var depth = elm$core$Basics$floor(
				A2(elm$core$Basics$logBase, elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? elm$core$List$reverse(builder.z) : builder.z;
			var tree = A2(elm$core$Array$treeFromBuilder, correctNodeList, builder.v);
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.y) + treeLen,
				A2(elm$core$Basics$max, 5, depth * elm$core$Array$shiftStep),
				tree,
				builder.y);
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
					{z: nodeList, v: (len / elm$core$Array$branchFactor) | 0, y: tail});
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
var elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var elm$core$Maybe$Nothing = {$: 1};
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
var elm$core$Basics$append = _Utils_append;
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
var elm$core$String$fromInt = _String_fromNumber;
var elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
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
var elm$json$Json$Encode$encode = _Json_encode;
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
var elm$json$Json$Decode$string = _Json_decodeString;
var author$project$Headless$headlessMsg = _Platform_incomingPort('headlessMsg', elm$json$Json$Decode$string);
var elm$url$Url$Http = 0;
var author$project$Headless$fallbackUrl = {dJ: elm$core$Maybe$Nothing, dM: 'headless.docket.com', dX: '', dZ: elm$core$Maybe$Nothing, d$: 0, d0: elm$core$Maybe$Nothing};
var elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
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
var elm$url$Url$Https = 1;
var elm$core$String$indexes = _String_indexes;
var elm$core$String$isEmpty = function (string) {
	return string === '';
};
var elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3(elm$core$String$slice, 0, n, string);
	});
var elm$core$String$contains = _String_contains;
var elm$core$String$toInt = _String_toInt;
var elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {dJ: fragment, dM: host, dX: path, dZ: port_, d$: protocol, d0: query};
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
var author$project$Headless$urlOrElse = function (urlAsString) {
	return A2(
		elm$core$Maybe$withDefault,
		author$project$Headless$fallbackUrl,
		elm$url$Url$fromString(urlAsString));
};
var author$project$Main$NewUrl = function (a) {
	return {$: 8, a: a};
};
var elm$core$Platform$Sub$batch = _Platform_batch;
var author$project$Headless$headlessSubscriptions = function (model) {
	var appData = model.dx;
	var environment = model.dF;
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
var author$project$AppData$Tokens = function (todoistSyncToken) {
	return {dl: todoistSyncToken};
};
var author$project$AppData$emptyTokens = author$project$AppData$Tokens('*');
var author$project$AppData$fromScratch = {b6: _List_Nil, _: _List_Nil, b_: _List_Nil, b0: _List_Nil, b1: author$project$AppData$emptyTokens, b2: 0};
var author$project$AppData$saveError = F2(
	function (appData, error) {
		return _Utils_update(
			appData,
			{
				_: A2(elm$core$List$cons, error, appData._)
			});
	});
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
var elm$core$String$trimRight = _String_trimRight;
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
				_: _Utils_ap(
					_List_fromArray(
						[
							zwilias$json_decode_exploration$Json$Decode$Exploration$warningsToString(warnings)
						]),
					appData._)
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
											return {f: backgroundable, g: category, h: evidence, a: excusable, b: hidden, i: icon, c: id, j: maxTime, d: names, k: taskOptional, e: template};
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
var author$project$Activity$Activity$Custom = function (a) {
	return {$: 1, a: a};
};
var author$project$Activity$Activity$Stock = function (a) {
	return {$: 0, a: a};
};
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
var elm$core$Basics$identity = function (x) {
	return x;
};
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
				var _n2 = toDecoderB(accA.N);
				var decoderFnB = _n2;
				return A2(
					elm$core$Result$map,
					function (accB) {
						return _Utils_update(
							accB,
							{
								t: _Utils_ap(accA.t, accB.t)
							});
					},
					decoderFnB(accA.w));
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
			{w: json, N: val, t: _List_Nil});
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
var author$project$Porting$decodeCustom = function (tagsWithDecoders) {
	var tryValues = function (_n0) {
		var tag = _n0.a;
		var decoder = _n0.b;
		return A3(zwilias$json_decode_exploration$Json$Decode$Exploration$check, zwilias$json_decode_exploration$Json$Decode$Exploration$string, tag, decoder);
	};
	return zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
		A2(elm$core$List$map, tryValues, tagsWithDecoders));
};
var zwilias$json_decode_exploration$Json$Decode$Exploration$succeed = function (val) {
	return function (json) {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$ok, json, val);
	};
};
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
			_Utils_Tuple2('Presentation', 53)
		]));
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
								w: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Object, true, values),
								N: v,
								t: warnings
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
								_Utils_Tuple2(key, res.w),
								acc),
							_Utils_ap(
								A2(
									elm$core$List$map,
									A2(
										elm$core$Basics$composeR,
										mgold$elm_nonempty_list$List$Nonempty$fromElement,
										zwilias$json_decode_exploration$Json$Decode$Exploration$Located$InField(key)),
									res.t),
								warnings),
							elm$core$Maybe$Just(
								elm$core$Result$Ok(res.N)));
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
			w: acc.w,
			N: f(acc.N),
			t: acc.t
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
var author$project$Activity$Activity$decodeActivityId = zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
	_List_fromArray(
		[
			A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$field,
			'Stock',
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$Activity$Activity$Stock, author$project$Activity$Template$decodeTemplate)),
			A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$field,
			'Custom',
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$Activity$Activity$Custom, zwilias$json_decode_exploration$Json$Decode$Exploration$int))
		]));
var author$project$Activity$Activity$Communication = 4;
var author$project$Activity$Activity$Entertainment = 1;
var author$project$Activity$Activity$Hygiene = 2;
var author$project$Activity$Activity$Slacking = 3;
var author$project$Activity$Activity$Transit = 0;
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
var author$project$SmartTime$Duration$inWholeHours = function (duration) {
	return (author$project$SmartTime$Duration$inMs(duration) / 3600000) | 0;
};
var author$project$SmartTime$Duration$inWholeMinutes = function (duration) {
	return (author$project$SmartTime$Duration$inMs(duration) / 60000) | 0;
};
var author$project$SmartTime$Duration$inWholeSeconds = function (duration) {
	return (author$project$SmartTime$Duration$inMs(duration) / 1000) | 0;
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
var author$project$SmartTime$Duration$breakdown = function (duration) {
	var all = author$project$SmartTime$Duration$inMs(duration);
	var days = (all / 86400000) | 0;
	var withoutDays = all - (days * 86400000);
	var hours = (withoutDays / 3600000) | 0;
	var withoutHours = withoutDays - (hours * 3600000);
	var minutes = (withoutHours / 60000) | 0;
	var withoutMinutes = withoutHours - (minutes * 60000);
	var seconds = (withoutMinutes / 1000) | 0;
	var withoutSeconds = withoutMinutes - (seconds * 1000);
	return {cr: days, cz: hours, cP: withoutSeconds, cQ: minutes, da: seconds};
};
var author$project$SmartTime$Human$Duration$breakdownDHMSM = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var days = _n0.cr;
	var hours = _n0.cz;
	var minutes = _n0.cQ;
	var seconds = _n0.da;
	var milliseconds = _n0.cP;
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
var author$project$SmartTime$Human$Duration$inLargestExactUnits = function (duration) {
	var partsSmallToBig = elm$core$List$reverse(
		author$project$SmartTime$Human$Duration$breakdownDHMSM(duration));
	var smallestPart = A2(
		elm$core$Maybe$withDefault,
		author$project$SmartTime$Human$Duration$Milliseconds(0),
		elm$core$List$head(partsSmallToBig));
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
								w: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, values),
								N: v,
								t: warnings
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
								A2(elm$core$List$cons, res.w, acc),
								_Utils_ap(res.t, warnings),
								elm$core$Maybe$Just(
									elm$core$Result$Ok(res.N))));
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
				var _n3 = decoderFnB(accA.w);
				if (!_n3.$) {
					var accB = _n3.a;
					return elm$core$Result$Ok(
						{
							w: accB.w,
							N: A2(f, accA.N, accB.N),
							t: _Utils_ap(accA.t, accB.t)
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
var author$project$Porting$ifPresent = F2(
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
			w: A2(zwilias$json_decode_exploration$Json$Decode$Exploration$Array, true, json),
			N: values,
			t: warnings
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
								A2(elm$core$List$cons, res.w, jsonAcc),
								_Utils_ap(res.t, warnAcc),
								A2(elm$core$List$cons, res.N, valAcc))));
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
	author$project$Activity$Activity$decodeActivityId,
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
var author$project$Activity$Activity$decodeStoredActivities = zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Activity$Activity$decodeCustomizations);
var author$project$Activity$Activity$Switch = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$Porting$subtype2 = F5(
	function (tagger, fieldName1, subType1Decoder, fieldName2, subType2Decoder) {
		return A3(
			zwilias$json_decode_exploration$Json$Decode$Exploration$map2,
			tagger,
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName1, subType1Decoder),
			A2(zwilias$json_decode_exploration$Json$Decode$Exploration$field, fieldName2, subType2Decoder));
	});
var author$project$SmartTime$Moment$Moment = elm$core$Basics$identity;
var author$project$SmartTime$Moment$fromSmartInt = function (_int) {
	return author$project$SmartTime$Duration$fromInt(_int);
};
var author$project$Task$TaskMoment$decodeMoment = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$SmartTime$Moment$fromSmartInt, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var author$project$Activity$Activity$decodeSwitch = A5(author$project$Porting$subtype2, author$project$Activity$Activity$Switch, 'Time', author$project$Task$TaskMoment$decodeMoment, 'Activity', author$project$Activity$Activity$decodeActivityId);
var author$project$AppData$AppData = F6(
	function (uid, errors, tasks, activities, timeline, tokens) {
		return {b6: activities, _: errors, b_: tasks, b0: timeline, b1: tokens, b2: uid};
	});
var author$project$AppData$decodeTokens = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'todoistSyncToken',
	zwilias$json_decode_exploration$Json$Decode$Exploration$string,
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$AppData$Tokens));
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
		return function (editing) {
			return function (id) {
				return function (predictedEffort) {
					return function (history) {
						return function (parent) {
							return function (tags) {
								return function (project) {
									return function (deadline) {
										return function (plannedStart) {
											return function (plannedFinish) {
												return function (relevanceStarts) {
													return function (relevanceEnds) {
														return {bx: completion, bA: deadline, bB: editing, bE: history, c: id, bO: parent, bP: plannedFinish, bQ: plannedStart, bR: predictedEffort, d_: project, bU: relevanceEnds, bV: relevanceStarts, ea: tags, a3: title};
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
	return {$: 1, a: a};
};
var author$project$Task$TaskMoment$Localized = function (a) {
	return {$: 2, a: a};
};
var author$project$Task$TaskMoment$Universal = function (a) {
	return {$: 3, a: a};
};
var author$project$Task$TaskMoment$Unset = {$: 0};
var justinmimbs$date$Date$RD = elm$core$Basics$identity;
var justinmimbs$date$Date$fromRataDie = function (rd) {
	return rd;
};
var author$project$Task$TaskMoment$decodeDate = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, justinmimbs$date$Date$fromRataDie, zwilias$json_decode_exploration$Json$Decode$Exploration$int);
var author$project$SmartTime$Moment$utcFromLinear = function (num) {
	return num;
};
var elm$time$Time$Posix = elm$core$Basics$identity;
var elm$time$Time$millisToPosix = elm$core$Basics$identity;
var author$project$SmartTime$Moment$toElmTime = function (_n0) {
	var dur = _n0;
	return elm$time$Time$millisToPosix(
		author$project$SmartTime$Moment$utcFromLinear(
			author$project$SmartTime$Duration$inMs(dur)));
};
var elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
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
	var millis = _n0;
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
				if (_Utils_cmp(era.bX, posixMinutes) < 0) {
					return posixMinutes + era.m;
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
var elm$core$Basics$negate = function (n) {
	return -n;
};
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
		cp: (dayOfYear - ((((153 * mp) + 2) / 5) | 0)) + 1,
		cR: month,
		dt: year + ((month <= 2) ? 1 : 0)
	};
};
var elm$time$Time$toDay = F2(
	function (zone, time) {
		return elm$time$Time$toCivil(
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).cp;
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
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).cR;
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
			A2(elm$time$Time$toAdjustedMinutes, zone, time)).dt;
	});
var justinmimbs$time_extra$Time$Extra$posixToParts = F2(
	function (zone, posix) {
		return {
			cp: A2(elm$time$Time$toDay, zone, posix),
			bf: A2(elm$time$Time$toHour, zone, posix),
			bI: A2(elm$time$Time$toMillis, zone, posix),
			bi: A2(elm$time$Time$toMinute, zone, posix),
			cR: A2(elm$time$Time$toMonth, zone, posix),
			bq: A2(elm$time$Time$toSecond, zone, posix),
			dt: A2(elm$time$Time$toYear, zone, posix)
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
var zwilias$json_decode_exploration$Json$Decode$Exploration$maybe = function (decoder) {
	return zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
		_List_fromArray(
			[
				A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, elm$core$Maybe$Just, decoder),
				zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(elm$core$Maybe$Nothing)
			]));
};
var author$project$Task$Task$decodeTask = A3(
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
						'project',
						zwilias$json_decode_exploration$Json$Decode$Exploration$maybe(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
						A3(
							zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
							'tags',
							zwilias$json_decode_exploration$Json$Decode$Exploration$list(zwilias$json_decode_exploration$Json$Decode$Exploration$string),
							A3(
								zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
								'parent',
								zwilias$json_decode_exploration$Json$Decode$Exploration$maybe(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
								A3(
									zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
									'history',
									zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Task$Task$decodeHistoryEntry),
									A3(
										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'predictedEffort',
										zwilias$json_decode_exploration$Json$Decode$Exploration$int,
										A3(
											zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
											'id',
											zwilias$json_decode_exploration$Json$Decode$Exploration$int,
											A3(
												zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
												'editing',
												zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
												A3(
													zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
													'completion',
													author$project$Task$Progress$decodeProgress,
													A3(
														zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
														'title',
														zwilias$json_decode_exploration$Json$Decode$Exploration$string,
														zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$Task$Task$Task)))))))))))))));
var author$project$AppData$decodeAppData = A4(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
	'tokens',
	author$project$AppData$decodeTokens,
	author$project$AppData$emptyTokens,
	A4(
		zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
		'timeline',
		zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Activity$Activity$decodeSwitch),
		_List_Nil,
		A4(
			zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
			'activities',
			author$project$Activity$Activity$decodeStoredActivities,
			_List_Nil,
			A4(
				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional,
				'tasks',
				zwilias$json_decode_exploration$Json$Decode$Exploration$list(author$project$Task$Task$decodeTask),
				_List_Nil,
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
					acc.t,
					zwilias$json_decode_exploration$Json$Decode$Exploration$gatherWarnings(acc.w));
				if (!_n3.b) {
					return zwilias$json_decode_exploration$Json$Decode$Exploration$Success(acc.N);
				} else {
					var x = _n3.a;
					var xs = _n3.b;
					return A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$WithWarnings,
						A2(mgold$elm_nonempty_list$List$Nonempty$Nonempty, x, xs),
						acc.N);
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
var author$project$SmartTime$Human$Clock$utc = elm$time$Time$utc;
var author$project$SmartTime$Duration$zero = 0;
var author$project$SmartTime$Moment$zero = author$project$SmartTime$Duration$zero;
var author$project$Environment$preInit = function (maybeKey) {
	return {cT: maybeKey, dj: author$project$SmartTime$Moment$zero, eb: author$project$SmartTime$Human$Clock$utc};
};
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
		var _n0 = url.d$;
		if (!_n0) {
			return 'http://';
		} else {
			return 'https://';
		}
	}();
	return A3(
		elm$url$Url$addPrefixed,
		'#',
		url.dJ,
		A3(
			elm$url$Url$addPrefixed,
			'?',
			url.d0,
			_Utils_ap(
				A2(
					elm$url$Url$addPort,
					url.dZ,
					_Utils_ap(http, url.dM)),
				url.dX)));
};
var author$project$Main$bypassFakeFragment = function (url) {
	var _n0 = A2(elm$core$Maybe$map, elm$core$String$uncons, url.dJ);
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
				elm$url$Url$fromString(front + ('/' + fakeFragment)));
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
		return {a_: primaryView, b2: uid};
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
	return {a_: screen, b2: 0};
};
var author$project$TaskList$IncompleteTasksOnly = 1;
var author$project$TaskList$Normal = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm$url$Url$Parser$Parser = elm$core$Basics$identity;
var elm$url$Url$Parser$State = F5(
	function (visited, unvisited, params, frag, value) {
		return {ab: frag, af: params, Y: unvisited, N: value, aj: visited};
	});
var elm$url$Url$Parser$mapState = F2(
	function (func, _n0) {
		var visited = _n0.aj;
		var unvisited = _n0.Y;
		var params = _n0.af;
		var frag = _n0.ab;
		var value = _n0.N;
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
			var visited = _n1.aj;
			var unvisited = _n1.Y;
			var params = _n1.af;
			var frag = _n1.ab;
			var value = _n1.N;
			return A2(
				elm$core$List$map,
				elm$url$Url$Parser$mapState(value),
				parseArg(
					A5(elm$url$Url$Parser$State, visited, unvisited, params, frag, subValue)));
		};
	});
var elm$url$Url$Parser$s = function (str) {
	return function (_n0) {
		var visited = _n0.aj;
		var unvisited = _n0.Y;
		var params = _n0.af;
		var frag = _n0.ab;
		var value = _n0.N;
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
		'Test'),
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
			var _n1 = state.Y;
			if (!_n1.b) {
				return elm$core$Maybe$Just(state.N);
			} else {
				if ((_n1.a === '') && (!_n1.b.b)) {
					return elm$core$Maybe$Just(state.N);
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
var elm$core$Basics$compare = _Utils_compare;
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
					elm$url$Url$Parser$preparePath(url.dX),
					elm$url$Url$Parser$prepareQuery(url.d0),
					url.dJ,
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
			dx: appData,
			dF: author$project$Environment$preInit(maybeKey),
			a7: author$project$Main$viewUrl(url)
		};
	});
var author$project$Main$Tick = function (a) {
	return {$: 1, a: a};
};
var author$project$Main$Tock = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
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
		default:
			return elm$json$Json$Encode$string('Presentation');
	}
};
var elm$json$Json$Encode$int = _Json_wrap;
var author$project$Activity$Activity$encodeActivityId = function (v) {
	if (!v.$) {
		var template = v.a;
		return elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'Stock',
					author$project$Activity$Template$encodeTemplate(template))
				]));
	} else {
		var num = v.a;
		return elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'Custom',
					elm$json$Json$Encode$int(num))
				]));
	}
};
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
var author$project$SmartTime$Human$Duration$toDuration = function (humanDuration) {
	switch (humanDuration.$) {
		case 4:
			var days = humanDuration.a;
			return author$project$SmartTime$Duration$fromInt(days * 86400000);
		case 3:
			var hours = humanDuration.a;
			return author$project$SmartTime$Duration$fromInt(hours * 3600000);
		case 2:
			var minutes = humanDuration.a;
			return author$project$SmartTime$Duration$fromInt(minutes * 60000);
		case 1:
			var seconds = humanDuration.a;
			return author$project$SmartTime$Duration$fromInt(seconds * 1000);
		default:
			var milliseconds = humanDuration.a;
			return author$project$SmartTime$Duration$fromInt(milliseconds);
	}
};
var author$project$Activity$Activity$encodeHumanDuration = function (humanDuration) {
	return elm$json$Json$Encode$int(
		author$project$SmartTime$Duration$inMs(
			author$project$SmartTime$Human$Duration$toDuration(humanDuration)));
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
var author$project$Porting$normal = elm$core$Maybe$Just;
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
						author$project$Activity$Template$encodeTemplate(record.e))),
					author$project$Porting$normal(
					_Utils_Tuple2(
						'stock',
						author$project$Activity$Activity$encodeActivityId(record.c))),
					author$project$Porting$omittable(
					_Utils_Tuple3(
						'names',
						elm$json$Json$Encode$list(elm$json$Json$Encode$string),
						record.d)),
					author$project$Porting$omittable(
					_Utils_Tuple3('icon', author$project$Activity$Activity$encodeIcon, record.i)),
					author$project$Porting$omittable(
					_Utils_Tuple3('excusable', author$project$Activity$Activity$encodeExcusable, record.a)),
					author$project$Porting$omittable(
					_Utils_Tuple3('taskOptional', elm$json$Json$Encode$bool, record.k)),
					author$project$Porting$omittable(
					_Utils_Tuple3(
						'evidence',
						elm$json$Json$Encode$list(author$project$Activity$Activity$encodeEvidence),
						record.h)),
					author$project$Porting$omittable(
					_Utils_Tuple3('category', author$project$Activity$Activity$encodeCategory, record.g)),
					author$project$Porting$omittable(
					_Utils_Tuple3('backgroundable', elm$json$Json$Encode$bool, record.f)),
					author$project$Porting$omittable(
					_Utils_Tuple3('maxTime', author$project$Activity$Activity$encodeDurationPerPeriod, record.j)),
					author$project$Porting$omittable(
					_Utils_Tuple3('hidden', elm$json$Json$Encode$bool, record.b))
				])));
};
var author$project$Activity$Activity$encodeStoredActivities = elm$json$Json$Encode$list(author$project$Activity$Activity$encodeCustomizations);
var author$project$SmartTime$Moment$toSmartInt = function (_n0) {
	var dur = _n0;
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
				author$project$Activity$Activity$encodeActivityId(activityId))
			]));
};
var author$project$AppData$encodeTokens = function (record) {
	return elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'todoistSyncToken',
				elm$json$Json$Encode$string(record.dl))
			]));
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
		case 0:
			return elm$json$Json$Encode$string('Unset');
		case 1:
			var date = v.a;
			return elm$json$Json$Encode$string('LocalDate');
		case 2:
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
				elm$json$Json$Encode$string(record.a3)),
				_Utils_Tuple2(
				'completion',
				author$project$Task$Progress$encodeProgress(record.bx)),
				_Utils_Tuple2(
				'editing',
				elm$json$Json$Encode$bool(record.bB)),
				_Utils_Tuple2(
				'id',
				elm$json$Json$Encode$int(record.c)),
				_Utils_Tuple2(
				'predictedEffort',
				elm$json$Json$Encode$int(record.bR)),
				_Utils_Tuple2(
				'history',
				A2(elm$json$Json$Encode$list, author$project$Task$Task$encodeHistoryEntry, record.bE)),
				_Utils_Tuple2(
				'parent',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$int, record.bO)),
				_Utils_Tuple2(
				'tags',
				A2(elm$json$Json$Encode$list, elm$json$Json$Encode$string, record.ea)),
				_Utils_Tuple2(
				'project',
				A2(elm_community$json_extra$Json$Encode$Extra$maybe, elm$json$Json$Encode$int, record.d_)),
				_Utils_Tuple2(
				'deadline',
				author$project$Task$TaskMoment$encodeTaskMoment(record.bA)),
				_Utils_Tuple2(
				'plannedStart',
				author$project$Task$TaskMoment$encodeTaskMoment(record.bQ)),
				_Utils_Tuple2(
				'plannedFinish',
				author$project$Task$TaskMoment$encodeTaskMoment(record.bP)),
				_Utils_Tuple2(
				'relevanceStarts',
				author$project$Task$TaskMoment$encodeTaskMoment(record.bV)),
				_Utils_Tuple2(
				'relevanceEnds',
				author$project$Task$TaskMoment$encodeTaskMoment(record.bU))
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
				A2(elm$json$Json$Encode$list, author$project$Task$Task$encodeTask, record.b_)),
				_Utils_Tuple2(
				'activities',
				author$project$Activity$Activity$encodeStoredActivities(record.b6)),
				_Utils_Tuple2(
				'uid',
				elm$json$Json$Encode$int(record.b2)),
				_Utils_Tuple2(
				'errors',
				A2(
					elm$json$Json$Encode$list,
					elm$json$Json$Encode$string,
					A2(elm$core$List$take, 100, record._))),
				_Utils_Tuple2(
				'timeline',
				A2(elm$json$Json$Encode$list, author$project$Activity$Activity$encodeSwitch, record.b0)),
				_Utils_Tuple2(
				'tokens',
				author$project$AppData$encodeTokens(record.b1))
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
			bx: _Utils_Tuple2(0, author$project$Task$Progress$Percent),
			bA: author$project$Task$TaskMoment$Unset,
			bB: false,
			bE: _List_Nil,
			c: id,
			bO: elm$core$Maybe$Nothing,
			bP: author$project$Task$TaskMoment$Unset,
			bQ: author$project$Task$TaskMoment$Unset,
			bR: 0,
			d_: elm$core$Maybe$Just(0),
			bU: author$project$Task$TaskMoment$Unset,
			bV: author$project$Task$TaskMoment$Unset,
			ea: _List_Nil,
			a3: description
		};
	});
var author$project$External$TodoistSync$itemToTask = function (item) {
	var base = A2(author$project$Task$Task$newTask, item.by, item.c);
	return _Utils_update(
		base,
		{
			bx: item.bw ? author$project$Task$Progress$maximize(base.bx) : base.bx,
			d_: elm$core$Maybe$Just(item.bT),
			ea: _List_Nil
		});
};
var author$project$External$TodoistSync$handle = F2(
	function (_n0, app) {
		var result = _n0;
		var tasks = app.b_;
		var activities = app.b6;
		var tokens = app.b1;
		if (!result.$) {
			var data = result.a;
			return _Utils_update(
				app,
				{
					b_: A2(elm$core$List$map, author$project$External$TodoistSync$itemToTask, data.bF),
					b1: {dl: data.bZ}
				});
		} else {
			var err = result.a;
			switch (err.$) {
				case 0:
					var msg = err.a;
					return A2(author$project$AppData$saveError, app, msg);
				case 1:
					return A2(author$project$AppData$saveError, app, 'Timeout?');
				case 2:
					return A2(author$project$AppData$saveError, app, 'Network Error');
				case 3:
					var status = err.a;
					return A2(
						author$project$AppData$saveError,
						app,
						'Got Error code' + elm$core$String$fromInt(status));
				default:
					var string = err.a;
					return A2(author$project$AppData$saveError, app, string);
			}
		}
	});
var author$project$External$TodoistSync$SyncResponded = elm$core$Basics$identity;
var author$project$External$TodoistSync$Response = F4(
	function (sync_token, full_sync, items, projects) {
		return {dK: full_sync, bF: items, c0: projects, bZ: sync_token};
	});
var author$project$External$TodoistSync$Item = function (id) {
	return function (user_id) {
		return function (project_id) {
			return function (content) {
				return function (due) {
					return function (indent) {
						return function (priority) {
							return function (parent_id) {
								return function (item_order) {
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
																				return {ca: assigned_by_uid, bw: checked, cl: children, Q: collapsed, by: content, co: date_added, cq: day_order, cs: due, c: id, cB: in_history, cC: indent, cH: is_archived, cI: is_deleted, cK: item_order, cN: labels, cV: parent_id, cY: priority, bT: project_id, c7: responsible_uid, dp: user_id};
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
		return {cn: date, cG: isRecurring, cO: lang, df: string, dk: timezone};
	});
var author$project$External$TodoistSync$decodeDue = A3(
	zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
	'isRecurring',
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
				zwilias$json_decode_exploration$Json$Decode$Exploration$maybe(zwilias$json_decode_exploration$Json$Decode$Exploration$string),
				A3(
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
					'date',
					zwilias$json_decode_exploration$Json$Decode$Exploration$string,
					zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$Due))))));
var author$project$External$TodoistSync$Priority = elm$core$Basics$identity;
var author$project$External$TodoistSync$decodePriority = zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
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
var author$project$External$TodoistSync$optionalIgnored = F2(
	function (field, pipeline) {
		return A2(
			zwilias$json_decode_exploration$Json$Decode$Exploration$andThen,
			function (_n0) {
				return pipeline;
			},
			zwilias$json_decode_exploration$Json$Decode$Exploration$oneOf(
				_List_fromArray(
					[
						A2(
						zwilias$json_decode_exploration$Json$Decode$Exploration$field,
						field,
						zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(0)),
						zwilias$json_decode_exploration$Json$Decode$Exploration$succeed(0)
					])));
	});
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
var author$project$External$TodoistSync$decodeItem = A2(
	author$project$External$TodoistSync$optionalIgnored,
	'sync_id',
	A2(
		author$project$External$TodoistSync$optionalIgnored,
		'legacy_project_id',
		A2(
			author$project$External$TodoistSync$optionalIgnored,
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
									zwilias$json_decode_exploration$Json$Decode$Exploration$maybe(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
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
																zwilias$json_decode_exploration$Json$Decode$Exploration$maybe(zwilias$json_decode_exploration$Json$Decode$Exploration$int),
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
																			zwilias$json_decode_exploration$Json$Decode$Exploration$maybe(author$project$External$TodoistSync$decodeDue),
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
																							zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$Item))))))))))))))))))))))));
var author$project$External$TodoistSync$ProjectChanges = function (id) {
	return function (name) {
		return function (color) {
			return function (parentId) {
				return function (childOrder) {
					return function (collapsed) {
						return function (shared) {
							return function (isDeleted) {
								return function (isArchived) {
									return function (isFavorite) {
										return {ap: childOrder, Q: collapsed, aq: color, c: id, ay: isArchived, az: isDeleted, aA: isFavorite, aE: name, aG: parentId, aJ: shared};
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
var author$project$Porting$ChangedTo = function (a) {
	return {$: 1, a: a};
};
var author$project$Porting$NoChange = {$: 0};
var author$project$Porting$updateable = F3(
	function (key, valDecoder, decoder) {
		var wrappedValDecoder = A2(zwilias$json_decode_exploration$Json$Decode$Exploration$map, author$project$Porting$ChangedTo, valDecoder);
		return A4(zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$optional, key, wrappedValDecoder, author$project$Porting$NoChange, decoder);
	});
var author$project$External$TodoistSync$decodeProjectChanges = A3(
	author$project$Porting$updateable,
	'isFavorite',
	zwilias$json_decode_exploration$Json$Decode$Exploration$int,
	A3(
		author$project$Porting$updateable,
		'isArchived',
		zwilias$json_decode_exploration$Json$Decode$Exploration$int,
		A3(
			author$project$Porting$updateable,
			'isDeleted',
			zwilias$json_decode_exploration$Json$Decode$Exploration$int,
			A3(
				author$project$Porting$updateable,
				'shared',
				zwilias$json_decode_exploration$Json$Decode$Exploration$bool,
				A3(
					author$project$Porting$updateable,
					'collapsed',
					zwilias$json_decode_exploration$Json$Decode$Exploration$int,
					A3(
						author$project$Porting$updateable,
						'childOrder',
						zwilias$json_decode_exploration$Json$Decode$Exploration$int,
						A3(
							author$project$Porting$updateable,
							'parentId',
							zwilias$json_decode_exploration$Json$Decode$Exploration$int,
							A3(
								author$project$Porting$updateable,
								'color',
								zwilias$json_decode_exploration$Json$Decode$Exploration$int,
								A3(
									author$project$Porting$updateable,
									'name',
									zwilias$json_decode_exploration$Json$Decode$Exploration$string,
									A3(
										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$required,
										'id',
										zwilias$json_decode_exploration$Json$Decode$Exploration$int,
										zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$ProjectChanges)))))))))));
var author$project$External$TodoistSync$decodeResponse = A2(
	author$project$External$TodoistSync$optionalIgnored,
	'sections',
	A2(
		author$project$External$TodoistSync$optionalIgnored,
		'userSettings',
		A2(
			author$project$External$TodoistSync$optionalIgnored,
			'user',
			A2(
				author$project$External$TodoistSync$optionalIgnored,
				'tempIdMapping',
				A2(
					author$project$External$TodoistSync$optionalIgnored,
					'settingsNotifications',
					A2(
						author$project$External$TodoistSync$optionalIgnored,
						'reminders',
						A2(
							author$project$External$TodoistSync$optionalIgnored,
							'projectNotes',
							A2(
								author$project$External$TodoistSync$optionalIgnored,
								'notes',
								A2(
									author$project$External$TodoistSync$optionalIgnored,
									'liveNotificationsLastReadId',
									A2(
										author$project$External$TodoistSync$optionalIgnored,
										'liveNotifications',
										A2(
											author$project$External$TodoistSync$optionalIgnored,
											'labels',
											A2(
												author$project$External$TodoistSync$optionalIgnored,
												'filters',
												A2(
													author$project$External$TodoistSync$optionalIgnored,
													'dayOrders',
													A2(
														author$project$External$TodoistSync$optionalIgnored,
														'collaboratorStates',
														A2(
															author$project$External$TodoistSync$optionalIgnored,
															'collaborators',
															A2(
																author$project$External$TodoistSync$optionalIgnored,
																'temp_id_mapping',
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
																				zwilias$json_decode_exploration$Json$Decode$Exploration$Pipeline$decode(author$project$External$TodoistSync$Response)))))))))))))))))))));
var elm$core$String$concat = function (strings) {
	return A2(elm$core$String$join, '', strings);
};
var author$project$External$TodoistSync$syncUrl = function (incrementalSyncToken) {
	var resources = '[%22all%22]';
	var devSecret = '0bdc5149510737ab941485bace8135c60e2d812b';
	var query = elm$core$String$concat(
		A2(
			elm$core$List$intersperse,
			'&',
			_List_fromArray(
				['token=' + devSecret, 'sync_token=' + incrementalSyncToken, 'resource_types=' + resources])));
	return {
		dJ: elm$core$Maybe$Nothing,
		dM: 'todoist.com',
		dX: '/api/v8/sync',
		dZ: elm$core$Maybe$Nothing,
		d$: 1,
		d0: elm$core$Maybe$Just(query)
	};
};
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
var author$project$Porting$toClassicLoose = function (decoder) {
	var runRealDecoder = function (value) {
		return A2(zwilias$json_decode_exploration$Json$Decode$Exploration$decodeValue, decoder, value);
	};
	var asResult = function (value) {
		var _n0 = runRealDecoder(value);
		switch (_n0.$) {
			case 0:
				return elm$core$Result$Err('Bad JSON');
			case 1:
				var errors = _n0.a;
				return elm$core$Result$Err(
					zwilias$json_decode_exploration$Json$Decode$Exploration$errorsToString(errors));
			case 2:
				var result = _n0.b;
				return elm$core$Result$Ok(result);
			default:
				var result = _n0.a;
				return elm$core$Result$Ok(result);
		}
	};
	var _final = function (value) {
		return asResult(value);
	};
	return A2(
		elm$json$Json$Decode$andThen,
		A2(elm$core$Basics$composeL, elm_community$json_extra$Json$Decode$Extra$fromResult, _final),
		elm$json$Json$Decode$value);
};
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
					elm$http$Http$BadStatus(metadata.de));
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
	return {$: 1, a: a};
};
var elm$core$Task$succeed = _Scheduler_succeed;
var elm$http$Http$State = F2(
	function (reqs, subs) {
		return {c3: reqs, dg: subs};
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
							var _n4 = req.H;
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
			A3(elm$http$Http$updateReqs, router, cmds, state.c3));
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
					state.dg)));
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
					al: r.al,
					ba: r.ba,
					dG: A2(_Http_mapExpect, func, r.dG),
					B: r.B,
					E: r.E,
					F: r.F,
					H: r.H,
					ee: r.ee
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
			{al: false, ba: r.ba, dG: r.dG, B: r.B, E: r.E, F: r.F, H: r.H, ee: r.ee}));
};
var elm$http$Http$get = function (r) {
	return elm$http$Http$request(
		{ba: elm$http$Http$emptyBody, dG: r.dG, B: _List_Nil, E: 'GET', F: elm$core$Maybe$Nothing, H: elm$core$Maybe$Nothing, ee: r.ee});
};
var author$project$External$TodoistSync$sync = function (incrementalSyncToken) {
	return elm$http$Http$get(
		{
			dG: A2(
				elm$http$Http$expectJson,
				elm$core$Basics$identity,
				author$project$Porting$toClassicLoose(author$project$External$TodoistSync$decodeResponse)),
			ee: elm$url$Url$toString(
				author$project$External$TodoistSync$syncUrl(incrementalSyncToken))
		});
};
var author$project$Main$Model = F3(
	function (viewState, appData, environment) {
		return {dx: appData, dF: environment, a7: viewState};
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
			return $.bx;
		}(task));
};
var author$project$TaskList$NoOp = {$: 9};
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
var elm$core$Basics$neq = _Utils_notEqual;
var elm$core$Basics$not = _Basics_not;
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
var elm$core$Platform$Cmd$batch = _Platform_batch;
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
var author$project$TaskList$update = F4(
	function (msg, state, app, env) {
		switch (msg.$) {
			case 2:
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
								b_: _Utils_ap(
									app.b_,
									_List_fromArray(
										[
											A2(
											author$project$Task$Task$newTask,
											newTaskTitle,
											author$project$SmartTime$Moment$toSmartInt(env.dj))
										]))
							}),
						elm$core$Platform$Cmd$none);
				}
			case 8:
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
			case 0:
				var id = msg.a;
				var isEditing = msg.b;
				var updateTask = function (t) {
					return _Utils_eq(t.c, id) ? _Utils_update(
						t,
						{bB: isEditing}) : t;
				};
				var focus = elm$browser$Browser$Dom$focus(
					'task-' + elm$core$String$fromInt(id));
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							b_: A2(elm$core$List$map, updateTask, app.b_)
						}),
					A2(
						elm$core$Task$attempt,
						function (_n3) {
							return author$project$TaskList$NoOp;
						},
						focus));
			case 1:
				var id = msg.a;
				var task = msg.b;
				var updateTask = function (t) {
					return _Utils_eq(t.c, id) ? _Utils_update(
						t,
						{a3: task}) : t;
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							b_: A2(elm$core$List$map, updateTask, app.b_)
						}),
					elm$core$Platform$Cmd$none);
			case 7:
				var id = msg.a;
				var field = msg.b;
				var date = msg.c;
				var updateTask = function (t) {
					return _Utils_eq(t.c, id) ? _Utils_update(
						t,
						{bA: date}) : t;
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							b_: A2(elm$core$List$map, updateTask, app.b_)
						}),
					elm$core$Platform$Cmd$none);
			case 3:
				var id = msg.a;
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							b_: A2(
								elm$core$List$filter,
								function (t) {
									return !_Utils_eq(t.c, id);
								},
								app.b_)
						}),
					elm$core$Platform$Cmd$none);
			case 4:
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							b_: A2(
								elm$core$List$filter,
								A2(elm$core$Basics$composeL, elm$core$Basics$not, author$project$Task$Task$completed),
								app.b_)
						}),
					elm$core$Platform$Cmd$none);
			case 5:
				var id = msg.a;
				var new_completion = msg.b;
				var updateTask = function (t) {
					return _Utils_eq(t.c, id) ? _Utils_update(
						t,
						{bx: new_completion}) : t;
				};
				return _Utils_Tuple3(
					state,
					_Utils_update(
						app,
						{
							b_: A2(elm$core$List$map, updateTask, app.b_)
						}),
					elm$core$Platform$Cmd$none);
			case 6:
				var task = msg.a;
				var focused = msg.b;
				return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple3(state, app, elm$core$Platform$Cmd$none);
		}
	});
var author$project$Activity$Activity$defaults = function (startWith) {
	switch (startWith) {
		case 0:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('shrugging-attempt.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(0),
					author$project$SmartTime$Human$Duration$Hours(1)),
				d: _List_fromArray(
					['Nothing', 'Dilly-dally', 'Distracted']),
				k: true,
				e: startWith
			};
		case 1:
			return {
				f: false,
				g: 2,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				i: author$project$Activity$Activity$File('shirt.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Appareling', 'Dressing', 'Getting Dressed', 'Dressing Up']),
				k: true,
				e: startWith
			};
		case 2:
			return {
				f: false,
				g: 4,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(5),
						author$project$SmartTime$Human$Duration$Minutes(30))),
				b: false,
				i: author$project$Activity$Activity$File('messaging.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Hours(5)),
				d: _List_fromArray(
					['Messaging', 'Texting', 'Chatting', 'Text Messaging']),
				k: true,
				e: startWith
			};
		case 3:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(15),
						author$project$SmartTime$Human$Duration$Hours(2))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(20),
					author$project$SmartTime$Human$Duration$Hours(2)),
				d: _List_fromArray(
					['Restroom', 'Toilet', 'WC', 'Washroom', 'Latrine', 'Lavatory', 'Water Closet']),
				k: true,
				e: startWith
			};
		case 4:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Grooming', 'Tending', 'Groom']),
				k: true,
				e: startWith
			};
		case 5:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Meal', 'Eating', 'Food', 'Lunch', 'Dinner', 'Breakfast']),
				k: true,
				e: startWith
			};
		case 6:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Supplements', 'Pills', 'Medication']),
				k: true,
				e: startWith
			};
		case 7:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Workout', 'Working Out', 'Work Out']),
				k: true,
				e: startWith
			};
		case 8:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(20),
						author$project$SmartTime$Human$Duration$Hours(18))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Shower', 'Bathing', 'Showering']),
				k: true,
				e: startWith
			};
		case 9:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Toothbrush', 'Teeth', 'Brushing Teeth', 'Teethbrushing']),
				k: true,
				e: startWith
			};
		case 10:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Floss', 'Flossing']),
				k: true,
				e: startWith
			};
		case 11:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(12),
						author$project$SmartTime$Human$Duration$Hours(15))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Wakeup', 'Waking Up', 'Wakeup Walk']),
				k: true,
				e: startWith
			};
		case 12:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$IndefinitelyExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Sleep', 'Sleeping']),
				k: true,
				e: startWith
			};
		case 13:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(15),
						author$project$SmartTime$Human$Duration$Hours(2))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Plan', 'Planning', 'Plans']),
				k: true,
				e: startWith
			};
		case 14:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Hours(5))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Configure', 'Configuring', 'Configuration']),
				k: true,
				e: startWith
			};
		case 15:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(2))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Email', 'E-Mail', 'E-mail', 'Emailing', 'E-mails', 'Emails', 'E-mailing']),
				k: true,
				e: startWith
			};
		case 16:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(12))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(8),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Work', 'Working', 'Listings Work']),
				k: true,
				e: startWith
			};
		case 17:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(35),
						author$project$SmartTime$Human$Duration$Hours(4))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Call', 'Calling', 'Phone Call', 'Phone', 'Phone Calls', 'Calling', 'Voice Call', 'Voice Chat', 'Video Call']),
				k: true,
				e: startWith
			};
		case 18:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Chore', 'Chores']),
				k: true,
				e: startWith
			};
		case 19:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(12))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Parents', 'Parent']),
				k: true,
				e: startWith
			};
		case 20:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(30),
					author$project$SmartTime$Human$Duration$Hours(24)),
				d: _List_fromArray(
					['Prepare', 'Preparing', 'Preparation']),
				k: true,
				e: startWith
			};
		case 21:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(2),
						author$project$SmartTime$Human$Duration$Hours(8))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Lover', 'S.O.', 'Partner']),
				k: true,
				e: startWith
			};
		case 22:
			return {
				f: false,
				g: 0,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Hours(1),
						author$project$SmartTime$Human$Duration$Hours(6))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Driving', 'Drive']),
				k: true,
				e: startWith
			};
		case 23:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Hours(8))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Minutes(30),
					author$project$SmartTime$Human$Duration$Hours(5)),
				d: _List_fromArray(
					['Riding', 'Ride', 'Passenger']),
				k: true,
				e: startWith
			};
		case 24:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(10),
						author$project$SmartTime$Human$Duration$Hours(4))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Social Media']),
				k: true,
				e: startWith
			};
		case 25:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Pacing', 'Pace']),
				k: true,
				e: startWith
			};
		case 26:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Sport', 'Sports', 'Playing Sports']),
				k: true,
				e: startWith
			};
		case 27:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Finance', 'Financial']),
				k: true,
				e: startWith
			};
		case 28:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Laundry']),
				k: true,
				e: startWith
			};
		case 29:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Bedward', 'Bedward-bound', 'Going to Bed']),
				k: true,
				e: startWith
			};
		case 30:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Browse', 'Browsing']),
				k: true,
				e: startWith
			};
		case 31:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Fiction', 'Reading Fiction']),
				k: true,
				e: startWith
			};
		case 32:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Learn', 'Learning']),
				k: true,
				e: startWith
			};
		case 33:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(30),
						author$project$SmartTime$Human$Duration$Days(1))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Brain Training', 'Braining', 'Brain Train', 'Mental Math Practice']),
				k: true,
				e: startWith
			};
		case 34:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Music', 'Music Listening']),
				k: true,
				e: startWith
			};
		case 35:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Create', 'Creating', 'Creation', 'Making']),
				k: true,
				e: startWith
			};
		case 36:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Children', 'Kids']),
				k: true,
				e: startWith
			};
		case 37:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Meeting', 'Meet', 'Meetings']),
				k: true,
				e: startWith
			};
		case 38:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Cinema', 'Movies', 'Movie Theatre', 'Movie Theater']),
				k: true,
				e: startWith
			};
		case 39:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Films', 'Film Watching', 'Watching Movies']),
				k: true,
				e: startWith
			};
		case 40:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Series', 'TV Shows', 'TV Series']),
				k: true,
				e: startWith
			};
		case 41:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Broadcast']),
				k: true,
				e: startWith
			};
		case 42:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Theatre', 'Play', 'Play/Musical', 'Drama']),
				k: true,
				e: startWith
			};
		case 43:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Shopping', 'Shop']),
				k: true,
				e: startWith
			};
		case 44:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Video', 'Video Gaming', 'Gaming']),
				k: true,
				e: startWith
			};
		case 45:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Housekeeping']),
				k: true,
				e: startWith
			};
		case 46:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$TemporarilyExcused(
					_Utils_Tuple2(
						author$project$SmartTime$Human$Duration$Minutes(45),
						author$project$SmartTime$Human$Duration$Hours(3))),
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Meal Prep', 'Cooking', 'Food making']),
				k: true,
				e: startWith
			};
		case 47:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Networking']),
				k: true,
				e: startWith
			};
		case 48:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Meditate', 'Meditation', 'Meditating']),
				k: true,
				e: startWith
			};
		case 49:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Homework', 'Schoolwork']),
				k: true,
				e: startWith
			};
		case 50:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Flight', 'Aviation', 'Flying', 'Airport']),
				k: true,
				e: startWith
			};
		case 51:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Course', 'Courses', 'Classes', 'Class']),
				k: true,
				e: startWith
			};
		case 52:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('unknown.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Pet', 'Pets', 'Pet Care']),
				k: true,
				e: startWith
			};
		default:
			return {
				f: false,
				g: 3,
				h: _List_Nil,
				a: author$project$Activity$Activity$NeverExcused,
				b: false,
				i: author$project$Activity$Activity$File('presentation.svg'),
				c: author$project$Activity$Activity$Stock(startWith),
				j: _Utils_Tuple2(
					author$project$SmartTime$Human$Duration$Hours(2),
					author$project$SmartTime$Human$Duration$Days(1)),
				d: _List_fromArray(
					['Presentation', 'Presenting', 'Present']),
				k: true,
				e: startWith
			};
	}
};
var author$project$Activity$Activity$isStock = function (activity) {
	var _n0 = activity.c;
	if (!_n0.$) {
		var template = _n0.a;
		return true;
	} else {
		var _int = _n0.a;
		return false;
	}
};
var author$project$Activity$Activity$withTemplate = function (delta) {
	var over = F2(
		function (b, s) {
			return A2(elm$core$Maybe$withDefault, b, s);
		});
	var base = author$project$Activity$Activity$defaults(delta.e);
	return {
		f: A2(over, base.f, delta.f),
		g: A2(over, base.g, delta.g),
		h: A2(over, base.h, delta.h),
		a: A2(over, base.a, delta.a),
		b: A2(over, base.b, delta.b),
		i: A2(over, base.i, delta.i),
		c: delta.c,
		j: A2(over, base.j, delta.j),
		d: A2(over, base.d, delta.d),
		k: A2(over, base.k, delta.k),
		e: delta.e
	};
};
var author$project$Activity$Template$stockActivities = _List_fromArray(
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53]);
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
var author$project$Activity$Activity$allActivities = function (stored) {
	var customizedActivities = A2(elm$core$List$map, author$project$Activity$Activity$withTemplate, stored);
	var customizedStockActivities = A2(elm$core$List$filter, author$project$Activity$Activity$isStock, customizedActivities);
	var templatesCovered = A2(
		elm$core$List$map,
		function ($) {
			return $.e;
		},
		customizedStockActivities);
	var templateMissing = function (template) {
		return !A2(elm$core$List$member, template, templatesCovered);
	};
	var remainingActivities = A2(
		elm$core$List$map,
		author$project$Activity$Activity$defaults,
		A2(elm$core$List$filter, templateMissing, author$project$Activity$Template$stockActivities));
	return _Utils_ap(customizedActivities, remainingActivities);
};
var author$project$Activity$Activity$latestSwitch = function (timeline) {
	return A2(
		elm$core$Maybe$withDefault,
		A2(
			author$project$Activity$Activity$Switch,
			author$project$SmartTime$Moment$zero,
			author$project$Activity$Activity$Stock(0)),
		elm$core$List$head(timeline));
};
var author$project$Activity$Activity$currentActivityId = function (switchList) {
	var getId = function (_n0) {
		var activityId = _n0.b;
		return activityId;
	};
	return getId(
		author$project$Activity$Activity$latestSwitch(switchList));
};
var author$project$Activity$Activity$getActivity = F2(
	function (activities, activityId) {
		var matches = function (act) {
			return _Utils_eq(act.c, activityId);
		};
		return A2(
			elm$core$Maybe$withDefault,
			author$project$Activity$Activity$defaults(0),
			elm$core$List$head(
				A2(elm$core$List$filter, matches, activities)));
	});
var author$project$Activity$Activity$currentActivity = F2(
	function (activities, switchList) {
		return A2(
			author$project$Activity$Activity$getActivity,
			activities,
			author$project$Activity$Activity$currentActivityId(switchList));
	});
var author$project$Activity$Switching$currentActivityFromApp = function (app) {
	return A2(
		author$project$Activity$Activity$currentActivity,
		author$project$Activity$Activity$allActivities(app.b6),
		app.b0);
};
var author$project$Activity$Activity$getName = function (activity) {
	return A2(
		elm$core$Maybe$withDefault,
		'?',
		elm$core$List$head(activity.d));
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
var author$project$SmartTime$Duration$subtract = F2(
	function (_n0, _n1) {
		var int1 = _n0;
		var int2 = _n1;
		return int1 - int2;
	});
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
			author$project$SmartTime$Human$Duration$toDuration(humanDuration));
	});
var author$project$Activity$Activity$dummy = author$project$Activity$Activity$Stock(0);
var author$project$SmartTime$Moment$compare = F2(
	function (_n0, _n1) {
		var time1 = _n0;
		var time2 = _n1;
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
		var switchActivityId = function (_n2) {
			var id = _n2.b;
			return id;
		};
		var recentEnough = function (_n1) {
			var moment = _n1.a;
			return A2(author$project$SmartTime$Moment$compare, moment, pastLimit) === 2;
		};
		var _n0 = A2(elm$core$List$partition, recentEnough, timeline);
		var pass = _n0.a;
		var fail = _n0.b;
		var justMissedId = A2(
			elm$core$Maybe$withDefault,
			author$project$Activity$Activity$dummy,
			A2(
				elm$core$Maybe$map,
				switchActivityId,
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
var author$project$SmartTime$Duration$add = F2(
	function (_n0, _n1) {
		var int1 = _n0;
		var int2 = _n1;
		return int1 + int2;
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
	function (timeline, now, activity) {
		var excusableLimit = author$project$Activity$Activity$excusableFor(activity);
		var lastPeriod = A3(author$project$Activity$Measure$relevantTimeline, timeline, now, excusableLimit.b);
		return A3(author$project$Activity$Measure$totalLive, now, lastPeriod, activity.c);
	});
var author$project$SmartTime$Duration$inSecondsRounded = function (duration) {
	return elm$core$Basics$round(
		author$project$SmartTime$Duration$inMs(duration) / 1000);
};
var author$project$Activity$Measure$exportExcusedUsageSeconds = F3(
	function (app, now, activity) {
		return elm$core$String$fromInt(
			author$project$SmartTime$Duration$inSecondsRounded(
				A3(author$project$Activity$Measure$excusedUsage, app.b0, now, activity)));
	});
var author$project$SmartTime$Duration$inMinutesRounded = function (duration) {
	return elm$core$Basics$round(
		author$project$SmartTime$Duration$inMs(duration) / 60000);
};
var author$project$Activity$Measure$exportLastSession = F2(
	function (app, old) {
		var timeSpent = A2(
			elm$core$Maybe$withDefault,
			author$project$SmartTime$Duration$zero,
			elm$core$List$head(
				A2(author$project$Activity$Measure$sessions, app.b0, old.c)));
		return elm$core$String$fromInt(
			author$project$SmartTime$Duration$inMinutesRounded(timeSpent));
	});
var author$project$SmartTime$Human$Duration$breakdownMS = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var seconds = _n0.da;
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
	function (timeline, env, _new, old) {
		var timeSpentString = function (dur) {
			return author$project$SmartTime$Human$Duration$singleLetterSpaced(
				author$project$SmartTime$Human$Duration$breakdownMS(dur));
		};
		var timeSpentLastSession = A2(
			elm$core$Maybe$withDefault,
			author$project$SmartTime$Duration$zero,
			elm$core$List$head(
				A2(author$project$Activity$Measure$sessions, timeline, old.c)));
		return timeSpentString(timeSpentLastSession) + (' spent on ' + (author$project$Activity$Activity$getName(old) + ('\n\n' + (author$project$Activity$Activity$getName(old) + (' ➤ ' + (author$project$Activity$Activity$getName(_new) + ('\n\n' + ('Starting from ' + timeSpentString(
			A3(author$project$Activity$Measure$excusedUsage, timeline, env.dj, _new))))))))));
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
var author$project$External$Commands$changeActivity = F3(
	function (newName, newTotal, oldTotal) {
		return elm$core$Platform$Cmd$batch(
			_List_fromArray(
				[
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('ActivityTotalSec', newTotal)),
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('ElmSelected', newName)),
					author$project$External$Tasker$variableOut(
					_Utils_Tuple2('PreviousActivityTotal', oldTotal))
				]));
	});
var author$project$External$Tasker$exit = _Platform_outgoingPort(
	'exit',
	function ($) {
		return elm$json$Json$Encode$null;
	});
var author$project$External$Commands$hideWindow = author$project$External$Tasker$exit(0);
var author$project$Activity$Switching$sameActivity = F3(
	function (activityId, app, env) {
		var activity = author$project$Activity$Switching$currentActivityFromApp(app);
		return _Utils_Tuple2(
			app,
			elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						author$project$External$Commands$toast(
						A4(author$project$Activity$Switching$switchPopup, app.b0, env, activity, activity)),
						A3(
						author$project$External$Commands$changeActivity,
						author$project$Activity$Activity$getName(activity),
						A3(author$project$Activity$Measure$exportExcusedUsageSeconds, app, env.dj, activity),
						A2(author$project$Activity$Measure$exportLastSession, app, activity)),
						author$project$External$Commands$hideWindow
					])));
	});
var author$project$Activity$Measure$excusedLeft = F3(
	function (timeline, now, activity) {
		var excusableLimit = author$project$SmartTime$Human$Duration$toDuration(
			author$project$Activity$Activity$excusableFor(activity).a);
		return A2(
			author$project$SmartTime$Duration$difference,
			excusableLimit,
			A3(author$project$Activity$Measure$excusedUsage, timeline, now, activity));
	});
var author$project$SmartTime$Duration$scale = F2(
	function (_n0, scalar) {
		var dur = _n0;
		return elm$core$Basics$round(dur * scalar);
	});
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
var author$project$SmartTime$Human$Duration$breakdownHM = function (duration) {
	var _n0 = author$project$SmartTime$Duration$breakdown(duration);
	var minutes = _n0.cQ;
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
var author$project$Activity$Reminder$scheduleExcusedReminders = F2(
	function (now, timeLeft) {
		var write = function (durLeft) {
			return author$project$SmartTime$Human$Duration$abbreviatedSpaced(
				author$project$SmartTime$Human$Duration$breakdownHM(durLeft));
		};
		var thirdLeft = A2(author$project$SmartTime$Duration$scale, timeLeft, 2 / 3);
		var quarterLeft = A2(author$project$SmartTime$Duration$scale, timeLeft, 3 / 4);
		var halfLeft = A2(author$project$SmartTime$Duration$scale, timeLeft, 1 / 2);
		var fifthLeft = A2(author$project$SmartTime$Duration$scale, timeLeft, 4 / 5);
		return _List_fromArray(
			[
				{
				aS: _List_Nil,
				a$: A2(author$project$SmartTime$Moment$future, now, halfLeft),
				a1: write(halfLeft) + ' left',
				a3: 'Half Time!'
			},
				{
				aS: _List_Nil,
				a$: A2(author$project$SmartTime$Moment$future, now, thirdLeft),
				a1: 'Only one third left',
				a3: 'Excused for ' + (write(
					A2(author$project$SmartTime$Duration$difference, timeLeft, thirdLeft)) + ' more')
			},
				{
				aS: _List_Nil,
				a$: A2(author$project$SmartTime$Moment$future, now, quarterLeft),
				a1: 'Only one quarter left',
				a3: 'Excused for ' + (write(
					A2(author$project$SmartTime$Duration$difference, timeLeft, quarterLeft)) + ' more')
			},
				{
				aS: _List_Nil,
				a$: A2(author$project$SmartTime$Moment$future, now, fifthLeft),
				a1: 'Only one fifth left',
				a3: 'Excused for ' + (write(
					A2(author$project$SmartTime$Duration$difference, timeLeft, fifthLeft)) + ' more')
			}
			]);
	});
var author$project$External$Commands$compileList = function (reminderList) {
	return elm$core$String$concat(
		A2(elm$core$List$intersperse, '§', reminderList));
};
var author$project$SmartTime$Duration$inSeconds = function (duration) {
	return author$project$SmartTime$Duration$inMs(duration) / 1000;
};
var author$project$SmartTime$Moment$toUnixTime = function (_n0) {
	var dur = _n0;
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
					author$project$SmartTime$Moment$toUnixTimeInt(reminder.a$)),
					reminder.a3,
					reminder.a1
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
	function (activityId, app, env) {
		var updatedApp = _Utils_update(
			app,
			{
				b0: A2(
					elm$core$List$cons,
					A2(author$project$Activity$Activity$Switch, env.dj, activityId),
					app.b0)
			});
		var oldActivity = author$project$Activity$Switching$currentActivityFromApp(app);
		var newActivity = A2(
			author$project$Activity$Activity$getActivity,
			author$project$Activity$Activity$allActivities(app.b6),
			activityId);
		return _Utils_Tuple2(
			updatedApp,
			elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						author$project$External$Commands$toast(
						A4(author$project$Activity$Switching$switchPopup, updatedApp.b0, env, newActivity, oldActivity)),
						A3(
						author$project$External$Commands$changeActivity,
						author$project$Activity$Activity$getName(newActivity),
						A3(author$project$Activity$Measure$exportExcusedUsageSeconds, app, env.dj, newActivity),
						A2(author$project$Activity$Measure$exportLastSession, updatedApp, oldActivity)),
						author$project$External$Commands$hideWindow,
						author$project$External$Commands$scheduleNotify(
						A2(
							author$project$Activity$Reminder$scheduleExcusedReminders,
							env.dj,
							A3(author$project$Activity$Measure$excusedLeft, updatedApp.b0, env.dj, newActivity)))
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
				author$project$Activity$Switching$currentActivityFromApp(app).c) ? A3(author$project$Activity$Switching$sameActivity, activityId, app, env) : A3(author$project$Activity$Switching$switchActivity, activityId, app, env);
			var updatedApp = _n1.a;
			var cmds = _n1.b;
			return _Utils_Tuple3(state, updatedApp, cmds);
		}
	});
var author$project$TimeTracker$NoOp = {$: 0};
var author$project$TimeTracker$StartTracking = function (a) {
	return {$: 1, a: a};
};
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
var elm$core$String$toLower = _String_toLower;
var author$project$TimeTracker$urlTriggers = function (app) {
	var entriesPerActivity = function (activity) {
		return _Utils_ap(
			A2(
				elm$core$List$map,
				function (n) {
					return _Utils_Tuple2(
						n,
						author$project$TimeTracker$StartTracking(activity.c));
				},
				activity.d),
			A2(
				elm$core$List$map,
				function (n) {
					return _Utils_Tuple2(
						elm$core$String$toLower(n),
						author$project$TimeTracker$StartTracking(activity.c));
				},
				activity.d));
	};
	var activitiesWithNames = elm$core$List$concat(
		A2(
			elm$core$List$map,
			entriesPerActivity,
			author$project$Activity$Activity$allActivities(app.b6)));
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
var elm$core$Platform$Cmd$map = _Platform_map;
var elm$url$Url$Parser$query = function (_n0) {
	var queryParser = _n0;
	return function (_n1) {
		var visited = _n1.aj;
		var unvisited = _n1.Y;
		var params = _n1.af;
		var frag = _n1.ab;
		var value = _n1.N;
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
var elm$url$Url$Parser$Query$map = F2(
	function (func, _n0) {
		var a = _n0;
		return function (dict) {
			return func(
				a(dict));
		};
	});
var author$project$Main$handleUrlTriggers = F2(
	function (rawUrl, model) {
		var appData = model.dx;
		var environment = model.dF;
		var url = author$project$Main$bypassFakeFragment(rawUrl);
		var taskTriggers = _List_Nil;
		var removeTriggersFromUrl = function () {
			var _n16 = environment.cT;
			if (!_n16.$) {
				var navkey = _n16.a;
				return A2(
					elm$browser$Browser$Navigation$replaceUrl,
					navkey,
					elm$url$Url$toString(
						_Utils_update(
							url,
							{d0: elm$core$Maybe$Nothing})));
			} else {
				return elm$core$Platform$Cmd$none;
			}
		}();
		var normalizedUrl = _Utils_update(
			url,
			{dX: ''});
		var mainTriggers = _List_fromArray(
			[
				A2(
				elm$url$Url$Parser$Query$enum,
				'sync',
				elm$core$Dict$fromList(
					_List_fromArray(
						[
							_Utils_Tuple2('todoist', author$project$Main$SyncTodoist)
						])))
			]);
		var createQueryParsers = function (_n15) {
			var key = _n15.a;
			var values = _n15.b;
			return A2(elm$url$Url$Parser$Query$enum, key, values);
		};
		var timeTrackerTriggers = A2(
			elm$core$List$map,
			elm$url$Url$Parser$Query$map(
				elm$core$Maybe$map(author$project$Main$TimeTrackerMsg)),
			A2(
				elm$core$List$map,
				createQueryParsers,
				author$project$TimeTracker$urlTriggers(appData)));
		var parseList = A2(
			elm$core$List$map,
			elm$url$Url$Parser$query,
			_Utils_ap(
				taskTriggers,
				_Utils_ap(timeTrackerTriggers, mainTriggers)));
		var parsed = A2(
			elm$url$Url$Parser$parse,
			elm$url$Url$Parser$oneOf(parseList),
			normalizedUrl);
		if (!parsed.$) {
			var parsedUrlSuccessfully = parsed.a;
			var _n9 = _Utils_Tuple2(parsedUrlSuccessfully, normalizedUrl.d0);
			if (!_n9.a.$) {
				if (!_n9.b.$) {
					var triggerMsg = _n9.a.a;
					var _n10 = A2(author$project$Main$update, triggerMsg, model);
					var newModel = _n10.a;
					var newCmd = _n10.b;
					var newCmdWithUrlCleaner = elm$core$Platform$Cmd$batch(
						_List_fromArray(
							[newCmd, removeTriggersFromUrl]));
					return _Utils_Tuple2(newModel, newCmdWithUrlCleaner);
				} else {
					var triggerMsg = _n9.a.a;
					var _n12 = _n9.b;
					var problemText = 'Handle URL Triggers: impossible situation. No query (Nothing) but we still successfully parsed it!';
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								dx: A2(author$project$AppData$saveError, appData, problemText)
							}),
						author$project$External$Commands$toast(problemText));
				}
			} else {
				if (!_n9.b.$) {
					var _n11 = _n9.a;
					var query = _n9.b.a;
					var problemText = 'Handle URL Triggers: none of  ' + (elm$core$String$fromInt(
						elm$core$List$length(parseList)) + (' parsers matched key and value: ' + query));
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								dx: A2(author$project$AppData$saveError, appData, problemText)
							}),
						author$project$External$Commands$toast(problemText));
				} else {
					var _n13 = _n9.a;
					var _n14 = _n9.b;
					return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
				}
			}
		} else {
			var problemText = 'Handle URL Triggers: failed to parse URL ' + elm$url$Url$toString(normalizedUrl);
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{
						dx: A2(author$project$AppData$saveError, appData, problemText)
					}),
				author$project$External$Commands$toast(problemText));
		}
	});
var author$project$Main$update = F2(
	function (msg, model) {
		var viewState = model.a7;
		var appData = model.dx;
		var environment = model.dF;
		var justSetEnv = function (newEnv) {
			return _Utils_Tuple2(
				A3(author$project$Main$Model, viewState, appData, newEnv),
				elm$core$Platform$Cmd$none);
		};
		var justRunCommand = function (command) {
			return _Utils_Tuple2(model, command);
		};
		var _n0 = _Utils_Tuple2(msg, viewState.a_);
		_n0$7:
		while (true) {
			switch (_n0.a.$) {
				case 4:
					var _n1 = _n0.a;
					return _Utils_Tuple2(
						A3(
							author$project$Main$Model,
							viewState,
							_Utils_update(
								appData,
								{_: _List_Nil}),
							environment),
						elm$core$Platform$Cmd$none);
				case 5:
					var _n2 = _n0.a;
					return justRunCommand(
						A2(
							elm$core$Platform$Cmd$map,
							author$project$Main$TodoistServerResponse,
							author$project$External$TodoistSync$sync(appData.b1.dl)));
				case 6:
					var response = _n0.a.a;
					return _Utils_Tuple2(
						A3(
							author$project$Main$Model,
							viewState,
							A2(author$project$External$TodoistSync$handle, response, appData),
							environment),
						elm$core$Platform$Cmd$none);
				case 7:
					var urlRequest = _n0.a.a;
					if (!urlRequest.$) {
						var url = urlRequest.a;
						var _n4 = environment.cT;
						if (!_n4.$) {
							var navkey = _n4.a;
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
					var url = _n0.a.a;
					var _n5 = A2(author$project$Main$handleUrlTriggers, url, model);
					var modelAfter = _n5.a;
					var effectsAfter = _n5.b;
					return _Utils_Tuple2(
						_Utils_update(
							modelAfter,
							{
								a7: author$project$Main$viewUrl(url)
							}),
						effectsAfter);
				case 9:
					if (!_n0.b.$) {
						var subMsg = _n0.a.a;
						var subViewState = _n0.b.a;
						var _n6 = A4(author$project$TaskList$update, subMsg, subViewState, appData, environment);
						var newState = _n6.a;
						var newApp = _n6.b;
						var newCommand = _n6.c;
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
				case 10:
					if (_n0.b.$ === 1) {
						var subMsg = _n0.a.a;
						var subViewState = _n0.b.a;
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
						author$project$Main$appDataToJson(newModel.dx)),
						cmds
					])));
	});
var author$project$SmartTime$Moment$CoordinatedUniversal = 0;
var author$project$SmartTime$Moment$UnixEpoch = 0;
var author$project$SmartTime$Duration$map = F2(
	function (func, _n0) {
		var _int = _n0;
		return func(_int);
	});
var author$project$SmartTime$Moment$linearFromUTC = function (num) {
	return num;
};
var author$project$SmartTime$Moment$moment = F3(
	function (scale, epoch, duration) {
		var _n0 = _Utils_Tuple2(scale, epoch);
		return A2(author$project$SmartTime$Duration$map, author$project$SmartTime$Moment$linearFromUTC, duration);
	});
var author$project$SmartTime$Moment$fromElmInt = function (intMsUtc) {
	return A3(
		author$project$SmartTime$Moment$moment,
		0,
		0,
		author$project$SmartTime$Duration$fromInt(intMsUtc));
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
var elm$time$Time$customZone = elm$time$Time$Zone;
var elm$time$Time$now = _Time_now(elm$time$Time$millisToPosix);
var author$project$SmartTime$Moment$now = A2(elm$core$Task$map, author$project$SmartTime$Moment$fromElmTime, elm$time$Time$now);
var author$project$Main$updateWithTime = F2(
	function (msg, model) {
		updateWithTime:
		while (true) {
			var environment = model.dF;
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
					var submsg = msg.a;
					var time = msg.b;
					var newEnv = _Utils_update(
						environment,
						{dj: time});
					return A2(
						author$project$Main$updateWithStorage,
						submsg,
						_Utils_update(
							model,
							{dF: newEnv}));
				case 3:
					var zone = msg.a;
					var time = msg.b;
					var newEnv = _Utils_update(
						environment,
						{dj: time, eb: zone});
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{dF: newEnv}),
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
var elm$time$Time$here = _Time_here(0);
var author$project$SmartTime$Human$Clock$localZone = elm$time$Time$here;
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
				A3(elm$core$Task$map2, author$project$Main$SetZoneAndTime, author$project$SmartTime$Human$Clock$localZone, author$project$SmartTime$Moment$now)),
				firstEffects
			]);
		return _Utils_Tuple2(
			modelWithFirstUpdate,
			elm$core$Platform$Cmd$batch(effects));
	});
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
	{dP: author$project$Headless$initHeadless, d9: author$project$Headless$headlessSubscriptions, ec: author$project$Main$updateWithTime});
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
		A2(elm$json$Json$Decode$index, 0, elm$json$Json$Decode$string)))(0)}});}(this));