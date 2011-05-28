// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheTemplateParser_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheSection_private.h"
#import "GRBoolean.h"
#import "GRMustacheError.h"

@interface GRMustacheTemplateParser()
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) GRMustacheToken *currentSectionOpeningToken;
@property (nonatomic, retain) GRMustacheTemplateLoader *templateLoader;
@property (nonatomic, retain) NSMutableArray *currentElements;
@property (nonatomic, retain) NSMutableArray *elementsStack;
@property (nonatomic, retain) NSMutableArray *sectionOpeningTokenStack;
@property (nonatomic, retain) id templateId;
- (void)start;
- (void)finish;
- (void)finishWithError:(NSError *)error;
- (NSError *)parseErrorAtLine:(NSInteger)line description:(NSString *)description;
@end

@implementation GRMustacheTemplateParser
@synthesize error;
@synthesize currentSectionOpeningToken;
@synthesize templateLoader;
@synthesize templateId;
@synthesize currentElements;
@synthesize elementsStack;
@synthesize sectionOpeningTokenStack;

- (id)initWithTemplateLoader:(GRMustacheTemplateLoader *)theTemplateLoader templateId:(id)theTemplateId {
	if ((self = [self init])) {
		self.templateLoader = theTemplateLoader;
		self.templateId = theTemplateId;
	}
	return self;
}

- (GRMustacheTemplate *)templateReturningError:(NSError **)outError {
	if (error) {
		if (outError != NULL) {
			*outError = error;
		}
		return nil;
	}
	
	return [GRMustacheTemplate templateWithElements:currentElements];
}

- (void)dealloc {
	[error release];
	[currentSectionOpeningToken release];
	[templateLoader release];
	[templateId release];
	[currentElements release];
	[elementsStack release];
	[sectionOpeningTokenStack release];
	[super dealloc];
}

#pragma mark GRMustacheTokenizerDelegate

- (BOOL)tokenizer:(GRMustacheTokenizer *)tokenizer shouldContinueAfterParsingToken:(GRMustacheToken *)token {
	switch (token.type) {
		case GRMustacheTokenTypeText:
			[currentElements addObject:[GRMustacheTextElement textElementWithString:token.content]];
			break;
			
		case GRMustacheTokenTypeComment:
			break;
			
		case GRMustacheTokenTypeEscapedVariable:
			[currentElements addObject:[GRMustacheVariableElement variableElementWithName:token.content raw:NO]];
			break;
			
		case GRMustacheTokenTypeUnescapedVariable:
			[currentElements addObject:[GRMustacheVariableElement variableElementWithName:token.content raw:YES]];
			break;
			
		case GRMustacheTokenTypeSectionOpening:
		case GRMustacheTokenTypeInvertedSectionOpening:
			self.currentSectionOpeningToken = token;
			[sectionOpeningTokenStack addObject:token];
			
			self.currentElements = [NSMutableArray array];
			[elementsStack addObject:currentElements];
			break;
			
		case GRMustacheTokenTypeSectionClosing:
			if ([token.content isEqualToString:currentSectionOpeningToken.content]) {
				NSRange currentSectionOpeningTokenRange = currentSectionOpeningToken.range;
				NSString *sectionOpeningTemplateString = currentSectionOpeningToken.templateString;
				NSAssert(sectionOpeningTemplateString == token.templateString, @"not implemented");
				NSString *sectionString = [sectionOpeningTemplateString substringWithRange:NSMakeRange(currentSectionOpeningTokenRange.location + currentSectionOpeningTokenRange.length, token.range.location - currentSectionOpeningTokenRange.location - currentSectionOpeningTokenRange.length)];
				GRMustacheSection *section = [GRMustacheSection sectionElementWithName:currentSectionOpeningToken.content
																				string:sectionString
																			  inverted:currentSectionOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening
																			  elements:currentElements];
				[sectionOpeningTokenStack removeLastObject];
				self.currentSectionOpeningToken = [sectionOpeningTokenStack lastObject];
				
				[elementsStack removeLastObject];
				self.currentElements = [elementsStack lastObject];
				
				[currentElements addObject:section];
			} else {
				[self finishWithError:[self parseErrorAtLine:token.line description:[NSString stringWithFormat:@"Unexpected `%@` section closing tag", token.content]]];
				return NO;
			}
			break;
			
		case GRMustacheTokenTypePartial: {
			NSError *partialError;
			GRMustacheTemplate *partialTemplate = [templateLoader parseTemplateNamed:token.content
																relativeToTemplateId:templateId
																			   error:&partialError];
			if (partialTemplate == nil) {
				[self finishWithError:partialError];
				return NO;
			} else {
				[currentElements addObject:partialTemplate];
			}
		} break;
			
		case GRMustacheTokenTypeSetDelimiter:
			// ignore
			break;
			
		default:
			NSAssert(NO, nil);
			break;
			
	}
	return YES;
}

- (BOOL)tokenizerShouldStart:(GRMustacheTokenizer *)tokenizer {
	[self start];
	return YES;
}

- (void)tokenizerDidFinish:(GRMustacheTokenizer *)tokenizer withError:(NSError *)theError {
	if (theError) {
		[self finishWithError:theError];
	} else if (currentSectionOpeningToken) {
		[self finishWithError:[self parseErrorAtLine:currentSectionOpeningToken.line
										 description:[NSString stringWithFormat:@"Unclosed `%@` section", currentSectionOpeningToken.content]]];
	} else {
		[self finish];
	}
}

#pragma mark Private

- (void)start {
	self.currentElements = [NSMutableArray arrayWithCapacity:20];
	self.elementsStack = [[NSMutableArray alloc] initWithCapacity:20];
	[elementsStack addObject:currentElements];
	self.sectionOpeningTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
}

- (void)finishWithError:(NSError *)theError {
	self.error = theError;
	[self finish];
}

- (void)finish {
	if (error) {
		self.currentElements = nil;
	}
	self.currentSectionOpeningToken = nil;
	self.elementsStack = nil;
	self.sectionOpeningTokenStack = nil;
}

- (NSError *)parseErrorAtLine:(NSInteger)line description:(NSString *)description {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
	[userInfo setObject:[NSString stringWithFormat:@"Parse error at line %d: %@", line, description]
				 forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:[NSNumber numberWithInteger:line]
				 forKey:GRMustacheErrorLine];
	return [NSError errorWithDomain:GRMustacheErrorDomain
							   code:GRMustacheErrorCodeParseError
						   userInfo:userInfo];
}

@end
