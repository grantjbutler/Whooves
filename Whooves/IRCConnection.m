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
	
	NSMutableString *p_buffer;
}

@synthesize socket = _socket;
@synthesize delegate = _delegate;

- (id)init {
	if((self = [super init])) {
		p_delegateQueue = dispatch_queue_create("com.whooves.delegateQueue", NULL);
		p_buffer = [[NSMutableString alloc] init];
		
		_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:p_delegateQueue];
	}
	
	return self;
}

- (BOOL)connectToHost:(NSString *)host port:(NSUInteger)port error:(NSError **)error {
	return [_socket connectToHost:host onPort:port error:error];
}

- (void)write:(NSString *)string {
	NSLog(@"> %@", string);
	
	NSMutableData *data = [[string dataUsingEncoding:NSASCIIStringEncoding] mutableCopy];
	[data appendData:[GCDAsyncSocket CRLFData]];
	
	[_socket writeData:data withTimeout:-1 tag:1];
}

#pragma mark - GCDAsyncSocket Delegate Methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
	if(self.delegate) {
		[self.delegate connectionDidConnectToServer:self];
	}
	
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	// if ircmsg.find(' PRIVMSG ') != -1:
	// nick = ircmsg.split('!')[0][1:];
	// channel = ircmsg.split(' PRIVMSG ')[1].split(' :')[0];
	//
	// mess = message.split(":",2)[2];
	
	NSString *line = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	NSLog(@"< %@", line);
	
	IRCMessage *message = [[IRCMessage alloc] initWithString:line];
	
	if([message.command isEqualToString:@"PING"]) {
		[self write:[NSString stringWithFormat:@"PONG :%@", [message.args objectAtIndex:0]]];
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
