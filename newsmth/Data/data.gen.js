
/* tpls */

/////////// decode ///////////
// NSString
var decodeTplString = '\t_${field} = [dict objectForKey:@"${field}"];';

// NSArray 
var decodeTplArray = [
	'\tid ${field} = [dict objectForKey:@"${field}"];',
	'\tif ([${field} isKindOfClass:[NSArray class]]) {',
	'\t\t_${field} = ${field};',
	'\t}'
].join('\n');

// int 
var decodeTplInt = '\t_${field} = [[dict objectForKey:@"${field}"] intValue];';

// float
var decodeTplFloat = '\t_${field} = [[dict objectForKey:@"${field}"] floatValue];';

// double
var decodeTplDouble = '\t_${field} = [[dict objectForKey:@"${field}"] doubleValue];';

// long 
var decodeTplLong = '\t_${field} = [[dict objectForKey:@"${field}"] longLongValue];';

// bool
var decodeTplBool = '\t_${field} = [[dict objectForKey:@"${field}"] boolValue];';

// XObject
var decodeTplXObject = '\t_${field} = [[${type} alloc] initWithJSON:[dict objectForKey:@"${field}"]];';

// XObject[]
var decodeTplXObjectArray = [
	'\tNSMutableArray *tmp_${field} = [[NSMutableArray alloc] init];',
	'\tNSArray *${field} = [dict objectForKey:@"${field}"];',
	'\tfor (int i = 0; i != ${field}.count; ++i) {',
	'\t\t[tmp_${field} addObject:[[${type} alloc] initWithJSON:${field}[i]]];',
	'\t}',
	'\t_${field} = tmp_${field};'
].join('\n');

/////////// encode ///////////

// NSString, NSArray
var encodeTplString_Array = [
	'\tif (_${field} != nil) {',
	'\t\t[dict setObject:_${field} forKey:@"${field}"];',
	'\t}'
].join('\n');

// int 
var encodeTplInt_float_long_double_bool = '\t[dict setObject:@(_${field}) forKey:@"${field}"];';

// XObject
var encodeTplXObject = [
	'\tif (_${field} != nil) {',
	'\t\t[dict setObject:[_${field} encode] forKey:@"${field}"];',
	'\t}'
].join('\n');

// XObject[]
var encodeTplXObjectArray = [
	'\tNSMutableArray *tmp_${field} = [[NSMutableArray alloc] init];',
	'\tfor (int i = 0; i != _${field}.count; ++i) {',
	'\t\t[tmp_${field} addObject:[_${field}[i] encode]];',
	'\t}',
	'\t[dict setObject:tmp_${field} forKey:@"${field}"];'
].join('\n');

var decodeMap = {
	'int': decodeTplInt,
	'float': decodeTplFloat,
	'double': decodeTplDouble,
	'long': decodeTplLong,
	'bool': decodeTplBool,
	'string': decodeTplString,
	'array': decodeTplArray,
	'xobject': decodeTplXObject,
	'xobject_array': decodeTplXObjectArray
};

var encodeMap = {
	'int': encodeTplInt_float_long_double_bool,
	'float': encodeTplInt_float_long_double_bool,
	'double': encodeTplInt_float_long_double_bool,
	'long': encodeTplInt_float_long_double_bool,
	'bool': encodeTplInt_float_long_double_bool,
	'string': encodeTplString_Array,
	'array': encodeTplString_Array,
	'xobject': encodeTplXObject,
	'xobject_array': encodeTplXObjectArray
};


//////////////////////////////////////////////////////////////////////
function unique(arr) {
	var map = {};
	arr.forEach(function(el) {
		map[el] = true;
	});
	var res = [];
	for (var k in map) {
		res.push(k);
	}

	return res;
}

//////////////////////////////////////////////////////////////////////
var fs = require('fs');
var scheme = fs.readFileSync('./types.schema').toString();

// console.log(scheme);

var regex = /(\w+)\s*\{([^\}]*)\}/g;

var primaryTypes = ['int', 'float', 'double', 'long', 'bool', 'string'];
var classes = [];
while ((match = regex.exec(scheme)) != null) {
	// @Class XPost; ...
	var refClass = [];

	// @property (...)
	var props = [];

	// _field = [dict objectForKey:@"field"];
	var decodes = [];

	// [dict setObject:_field forKey:@"field"];
	var encodes = [];

	var clz = match[1];
	var body = match[2];
	var fields = body.split('\n');

	for (var i = 0; i != fields.length; ++i) {
		var field = fields[i].replace(/[^\w\[\]\s]/g, '').trim();
		var type_field = field.split(/\s+/);
		if (type_field.length == 2) {
			var type = type_field[0];
			var field = type_field[1];

			var decodeTpl, encodeTpl;
			if (type.indexOf('[]') != -1) {	// array
				type = type.replace(/[\[\]]/g, '');

				if (primaryTypes.indexOf(type) != -1) {
					// objc array
					decodeTpl = decodeMap['array'];
					encodeTpl = encodeMap['array'];
				} else {	// xobject array
					decodeTpl = decodeMap['xobject_array'];
					encodeTpl = encodeMap['xobject_array'];
					refClass.push('@class ' + type + ';');
				}
				props.push('@property (strong, nonatomic) NSArray* ' + field + ';');
			} else if (primaryTypes.indexOf(type) != -1) {
				decodeTpl = decodeMap[type];
				encodeTpl = encodeMap[type];
				if (type == 'string') {
					props.push('@property (strong, nonatomic) NSString* ' + field + ';');
				} else if (type == 'long') {
					props.push('@property (assign, nonatomic) long long ' + field + ';');
				} else if (type == 'bool') {
					props.push('@property (assign, nonatomic) BOOL ' + field + ';');
				} else {
					props.push('@property (assign, nonatomic) ' + type + ' ' + field + ';');
				}
			} else {	// xobject
				decodeTpl = decodeMap['xobject'];
				encodeTpl = encodeMap['xobject'];
				props.push('@property (strong, nonatomic) ' + type + '* ' + field + ';');
				refClass.push('@class ' + type + ';');
			}

			decodes.push(decodeTpl.replace(/\$\{field\}/g, field).replace(/\$\{type\}/g, type));
			encodes.push(encodeTpl.replace(/\$\{field\}/g, field).replace(/\$\{type\}/g, type));
		}
	}

	refClass = unique(refClass);
	// console.log(clz);
	// console.log(unique(refClass));
	// console.log(props.join('\n'));
	// console.log(decodes.join('\n\n'));
	// console.log(encodes.join('\n\n'));



	var header = ['#import "SMBaseData.h"\n',
		refClass.join('\n'),
		'@interface ' + clz + ' : SMBaseData',
		props.join('\n'),
		'@end'].join('\n');

	var source = ['#import "SMData.h"\n',
		'@implementation ' + clz,
		'- (void)decode:(id)json',
		'{',
		'\tNSDictionary *dict = json;',
		decodes.join('\n\n'),
		'}',
		'',
		'- (id)encode',
		'{',
		'\tNSMutableDictionary *dict = [[NSMutableDictionary alloc] init];',
		encodes.join('\n\n'),
		'\treturn dict;',
		'}',
		'@end'].join('\n');

	// console.log(header);
	// console.log(source);

	fs.writeFileSync(clz + '.h', header);
	fs.writeFileSync(clz + '.m', source);

	classes.push('#import "' + clz + '.h"');

	console.log(clz);
	// console.log(fields);
}

fs.writeFileSync('SMData.h', classes.join('\n'));
