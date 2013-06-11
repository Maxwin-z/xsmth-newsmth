var fs = require('fs');
var schema = fs.readFileSync('./types.schema').toString();

console.log(schema);

var primyTypeTpl = '\
- (${type})${name}\n\
{\n\
	return [[self.dict objectForKey:@"${name}"] ${type}Value];\n\
}\n\
';

var longTypeTpl = '\
- (long long)${name}\n\
{\n\
	return [[self.dict objectForKey:@"${name}"] longLongValue];\n\
}\n\
';

var stringTypeTpl = '\
- (NSString *)${name}\n\
{\n\
	return [self.dict objectForKey:@"${name}"];\n\
}\n\
';

var objTypeTpl = '\
- (${type} *)${name}\n\
{\n\
	SMBaseData *data = [[SMBaseData alloc] initWithData:[self.dict objectForKey:@"${name}"]];\n\
	return data;\n\
}\n\
';

var arrTypeTpl = '\
- (NSArray *)${name}\n\
{\n\
	NSArray *objs = [self.dict objectForKey:@"${name}"];\n\
	NSMutableArray *res = [[NSMutableArray alloc] init];\n\
	for (int i = 0; i != objs.count; ++i) {\n\
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];\n\
		[res addObject:data];\n\
	}\n\
	return res;\n\
}\n\
';

console.log(primyTypeTpl);

var regex = /(\w+)\s\{([^\}]*)\}/g;
var match;
while ((match = regex.exec(schema)) != null) {
	var clz = match[1];
	var body = match[2];
	// console.log(clz, fields);
	// console.log('----');
	// parser field
	var fields = body.split('\n');

	var props = [];
	var impls = [];
	for (var i = 0; i != fields.length; ++i) {
		var field = fields[i].trim();
		var type_name = field.split(/\s/);
		if (type_name.length == 2) {
			var type = type_name[0];
			var name = type_name[1];

			var tpl, propType, propReferStrong;
			propReferStrong = true;
			if (type.match(/(int|double|float)/)) {	// prime types
				tpl = primyTypeTpl;
				propType = type;
				propReferStrong = false;
			} else if (type == 'long') {
				tpl = longTypeTpl;
				propType = 'long long';
				propReferStrong = false;
			} else if (type == 'string') {
				tpl = stringTypeTpl;
				propType = "NSString*";
			} else if (type.indexOf('[]') !== false) {
				tpl = arrTypeTpl;
				propType = "NSArray*";
			} else {
				tpl = objTypeTpl;
				propType = type + "*";
			}

			props.push('@property (' + (propReferStrong ? 'strong' : 'assign') + ', nonatomic) ' + propType + ' ' + name + ';');
			impls.push(tpl.replace(/\$\{type\}/g, type).replace(/\$\{name\}/g, name));
		}
	}
	var header = ['#import "SMBaseData.h"\n',
		'@interface ' + clz + ' : SMBaseData',
		props.join('\n'),
		'@end'].join('\n');

	var source = ['#import "' + clz + '.h"\n',
		'@implementation ' + clz,
		impls.join('\n'),
		'@end'].join('\n');
	console.log(header);
	console.log(source);

	fs.writeFileSync(clz + '.h', header);
	fs.writeFileSync(clz + '.m', source);
	// console.log(fields);
}

/*
- (${type})${name}
{
	return [_dict objectForKey:@"${name}"];
}

- (${type})
*/

