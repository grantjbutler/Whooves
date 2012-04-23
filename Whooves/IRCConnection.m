//
//  IRCConnection.m
//  Whooves
//
//  Created by Grant Butler on 1/6/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "IRCConnection.h"

@implementation IRCConnection{
	dispatch_queue_t p_delegateQueue;
	
	NSMutableArray *p_buffer;
}

@synthesize socket = _socket;
@synthesize delegate = _delegate;

- (id)init {
	if((self = [super init])) {
		p_delegateQueue = dispatch_queue_create("com.whooves.delegateQueue", NULL);
		p_buffer = [[NSMutableArray alloc] init];
		
		_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:p_delegateQueue];
	}
	
	return self;
}

- (BOOL)connectToHost:(NSString *)host port:(NSUInteger)port error:(NSError **)error {
	return [_socket connectToHost:host onPort:port error:error];
}

- (void)write:(NSString *)format, ... {
	va_list list;
	va_start(list, format);
	
	[self write:format args:list];
	
	va_end(list);
}

- (void)write:(NSString *)format args:(va_list)args {
	NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
	
	WHLog(@"> %@", string);
	
	NSMutableData *data = [[string dataUsingEncoding:NSASCIIStringEncoding] mutableCopy];
	[data appendData:[GCDAsyncSocket CRLFData]];
	
	if([_socket isConnected]) {
		[_socket writeData:data withTimeout:-1 tag:1];
	} else {
		[p_buffer addObject:data];
	}
}

#pragma mark - GCDAsyncSocket Delegate Methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
	if(self.delegate) {
		[self.delegate connectionDidConnectToServer:self];
	}
	
	for(NSData *data in p_buffer) {
		[_socket writeData:data withTimeout:-1 tag:1];
	}
	
	[p_buffer removeAllObjects];
	
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	NSString *line = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	WHLog(@"< %@", line);
	
	IRCMessage *message = [[IRCMessage alloc] initWithString:line];
	
	if([message.command isEqualToString:@"PING"]) {
		[self write:[NSString stringWithFormat:@"PONG %@", [message.args objectAtIndex:0]]];
	} else {
		if(self.delegate) {
			[self.delegate connection:self didReceiveMessage:message];
		}
	}
	
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
	
}

@end
