grammar ASDML;

asdml:
	Whitespace* content? (Whitespace+ content)* Whitespace*;

content: value | property;

value: literal | group;

property: Punctation SimpleText Whitespace value;

literal:
	Null
	| ID
	| Logical
	| Number
	| SimpleText
	| Text
	| MultilineText
	| array;

array: normalArray | arrayWithoutType;

normalArray:
	SimpleText Whitespace* LSquare Whitespace* value? (
		Whitespace+ value
	)* Whitespace* RSquare;

arrayWithoutType:
	AtSign LSquare Whitespace* value? (Whitespace+ value)* Whitespace* RSquare;

group: normalGroup | anonymousGroup;

normalGroup:
	SimpleText Whitespace* genericParameters? Whitespace* constructor? Whitespace* ID? Whitespace*
		groupInner;

anonymousGroup: AtSign groupInner;

groupInner:
	LCurly Whitespace* content? (Whitespace+ content)* Whitespace* RCurly;

genericParameters:
	LessThan SimpleText? (Whitespace+ SimpleText)* GreaterThan;

constructor: LParen value? (Whitespace+ value)* RParen;

fragment A: ('A' | 'a');
fragment E: ('E' | 'e');
fragment F: ('F' | 'f');
fragment N: ('N' | 'n');
fragment U: ('U' | 'u');
fragment L: ('L' | 'l');
fragment R: ('R' | 'r');
fragment S: ('S' | 's');
fragment T: ('T' | 't');

fragment Sign: Plus | Minus;
fragment HashSign: '#';
fragment Underscore: '_';
fragment Quote: '"';
fragment Backslash: '\\';
fragment Plus: '+';
fragment Minus: '-';

fragment Letter: [a-zA-Z];
fragment Digit: [0-9];
fragment HexDigit: [0-9a-fA-F];

fragment EscapeSequence: (Backslash ["#\\0abfnrtv])
	| (Backslash 'x' HexDigit HexDigit)
	| (Backslash 'u' HexDigit HexDigit HexDigit HexDigit);

LParen: '(';
RParen: ')';
LSquare: '[';
RSquare: ']';
LCurly: '{';
RCurly: '}';
LessThan: '<';
GreaterThan: '>';

Whitespace: (' ' | '\t' | LineFeed);
LineFeed: '\n' | '\r' | '\r\n';
Punctation: '.';
AtSign: '@';

SimpleText: (Letter | Underscore) (
		Letter
		| Digit
		| Punctation
		| Underscore
		| Plus
		| Minus
	)*;

Null: AtSign N U L L;

ID: HashSign SimpleText;

Logical: (True | False);
True: AtSign T R U E;
False: AtSign F A L S E;

Number: Sign? Digit+ (Punctation Digit+)? (E Sign Digit)?;

Text: Quote (EscapeSequence | ~["\\\r\n])*? Quote;

MultilineText: AtSign Quote (EscapeSequence | ~["\\])*? Quote;
