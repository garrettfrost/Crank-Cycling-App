//
//  riddenSegmentsViewController.h
//  ui testing
//
//  Created by Garrett on 19/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "segment.h"
#import <CommonCrypto/CommonDigest.h>

@interface riddenSegmentsViewController : UITableViewController<NSXMLParserDelegate, UIAlertViewDelegate>

@property(nonatomic)IBOutlet UIBarButtonItem *sidebarButton;

@property(retain, nonatomic)NSString* getSegmentsString, *xmlString, *readString, *userName, *password;
@property(strong, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSMutableString *currentElementValue;
@property(retain, nonatomic)NSMutableArray *segmentsArray;
@property(retain, nonatomic)segment *segment;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)GCDAsyncSocket *socket;

-(void)setUpParseObject;
-(void)connect;

@end
