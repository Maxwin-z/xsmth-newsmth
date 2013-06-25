var fs = require('fs');
var schema = fs.readFileSync('./types.schema').toString();

console.log(schema);

var primyTypeTpl = '\
- (${type})${name}\n\
{\n\
	return [[self.dict objectForKey:@"${name}"] ${type}Value];\n\
}\n\
';

var primyTypeTplSetter = '\
- (void)set${nameWithCapital}:(${type})${name}_\n\
{\n\
	[self.dict set${typeWithCapital}:${name}_ forKey:@"${name}"];\n\
}\n\
';

var boolTypeTpl = '\
- (BOOL)${name}\n\
{\n\
	return [[self.dict objectForKey:@"${name}"] boolValue];\n\
}\n\
';

var boolTypeTplSetter = '\
- (void)set${nameWithCapital}:(BOOL)${name}_\n\
{\n\
	[self.dict setBool:${name}_ forKey:@"${name}"];\n\
}\n\
';

var longTypeTpl = '\
- (long long)${name}\n\
{\n\
	return [[self.dict objectForKey:@"${name}"] longLongValue];\n\
}\n\
';

var longTypeTplSetter = '\
- (void)set${nameWithCapital}:(long long)${name}_\n\
{\n\
	[self.dict setLongLong:${name}_ forKey:@"${name}"];\n\
}\n\
';

var stringTypeTpl = '\
- (NSString *)${name}\n\
{\n\
	return [self.dict objectForKey:@"${name}"];\n\
}\n\
';

var stringTypeTplSetter = '\
- (void)set${nameWithCapital}:(NSString *)${name}_\n\
{\n\
	[self.dict setObject:${name}_ forKey:@"${name}"];\n\
}\n\
';

var objTypeTpl = '\
- (${type} *)${name}\n\
{\n\
	SMBaseData *data = [[SMBaseData alloc] initWithData:[self.dict objectForKey:@"${name}"]];\n\
	return data;\n\
}\n\
';

var objTypeTplSetter = '\
- (void)set${nameWithCapital}:(SMBaseData *)${name}_\n\
{\n\
	[self.dict setObject:${name}_.dict forKey:@"${name}"];\n\
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

var arrTypeTplSetter = '\
- (void)set${nameWithCapital}:(NSArray *)${name}_\n\
{\n\
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:${name}_.count];\n\
    for (int i = 0; i != ${name}_.count; ++i) {\n\
        [arr addObject:[${name}_[i] dict]];\n\
    }\n\
    [self.dict setObject:arr forKey:@"${name}"];\n\
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

			var nameWithCapital = name.replace(/^./, function ($0) {
				return $0.toUpperCase();
			});
			var typeWithCapital = type.replace(/^./, function ($0) {
				return $0.toUpperCase();
			});

			if (type == 'int') {
				typeWithCapital = 'Integer';
			}

			var tpl, setterTpl, propType, propReferStrong;
			propReferStrong = true;
			if (type.match(/(int|double|float)/)) {	// prime types
				tpl = primyTypeTpl;
				setterTpl = primyTypeTplSetter;
				propType = type;
				propReferStrong = false;
			} else if (type == 'bool') {
				tpl = boolTypeTpl;
				setterTpl = boolTypeTplSetter;
				propType = 'BOOL';
				propReferStrong = false;
			} else if (type == 'long') {
				tpl = longTypeTpl;
				setterTpl = longTypeTplSetter;
				propType = 'long long';
				propReferStrong = false;
			} else if (type == 'string') {
				tpl = stringTypeTpl;
				setterTpl = stringTypeTplSetter;
				propType = "NSString*";
			} else if (type.indexOf('[]') !== -1) {
				tpl = arrTypeTpl;
				setterTpl = arrTypeTplSetter;
				propType = "NSArray*";
			} else {
				tpl = objTypeTpl;
				setterTpl = objTypeTplSetter;
				propType = type + "*";
			}

			props.push('@property (' + (propReferStrong ? 'strong' : 'assign') + ', nonatomic) ' + propType + ' ' + name + ';');
			impls.push(
				tpl.replace(/\$\{type\}/g, type)
							.replace(/\$\{name\}/g, name)
							.replace(/\$\{nameWithCapital\}/g, nameWithCapital)
							.replace(/\$\{typeWithCapital\}/g, typeWithCapital)
			);

			impls.push(
				setterTpl.replace(/\$\{type\}/g, type)
							.replace(/\$\{name\}/g, name)
							.replace(/\$\{nameWithCapital\}/g, nameWithCapital)
							.replace(/\$\{typeWithCapital\}/g, typeWithCapital)
			);
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

