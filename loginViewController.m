/*
 Handles loggin in for a user
 This includes automatically logging in for a user who
 uses the application frequently
 */

#import "loginViewController.h"

@interface loginViewController ()

@end

@implementation loginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.loginLabel setTextColor:[UIColor whiteColor]];
    [self.loginLabel setFont:[UIFont fontWithName:@"Aero" size:30.0]];
    [self.loginLabel setText:@"Login"];

    self.usernameTextfield.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:@"UITextFieldTextDidChangeNotification" object:self.usernameTextfield];
    
    self.passwordTextfield.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:@"UITextFieldTextDidChangeNotification" object:self.passwordTextfield];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseXML" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLogin) name:@"checkLogin" object:nil];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    self.loggedIn = NO;
    self.loginActivityIndicator.hidden = YES;
    self.xmlString = [[NSString alloc]init];
    
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"crankAppLogin" accessGroup:nil];
    self.password = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    self.username = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    
    // if there is already something in the keychain, login automatically for the user
    if(![self.password isEqualToString:@""] && ![self.username isEqualToString:@""])
        [self autoLogin];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

// auto logs in the user if possible
-(void)autoLogin
{
    [self.loginActivityIndicator stopAnimating];
    self.loggedIn = TRUE;
    [self performSegueWithIdentifier: @"login_successful_segue" sender: self];
}

// resets the key chain item if the login screen reappears, meaning they have logged out
-(void)viewDidAppear:(BOOL)animated
{
    self.loggedIn = NO;
    [self.keychainItem resetKeychainItem];
}

#pragma mark networking methods

-(void)connect
{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    NSError *err = nil;
    if (![self.socket connectToHost:@"203.143.84.128" onPort:20100 error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return;
    }
    
    NSData *request = [self.requestString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:request withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Cool, I'm connected! That was easy.");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 0)
        NSLog(@"Login ride request sent");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    self.readString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	self.xmlString = [self.xmlString stringByAppendingString:self.readString];
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parseXML" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if(textField.tag == 0)
    {
        self.username = textField.text;
    }
    else if(textField.tag == 1)
    {
        self.password = textField.text;
    }
    
    return YES;
}

// ensures that if the user changes text field by tapping directly in another one that the value is saved
- (void)textFieldDidChange:(NSNotification *)notif
{
    if([(UITextField*)notif.object tag] == 0)
    {
        self.username = [(UITextField*)notif.object text];
    }
    else if([(UITextField*)notif.object tag] == 1)
    {
        self.password = [(UITextField*)notif.object text];
    }
    
    if(self.password && self.username)
    {
        self.loginButton.enabled = YES;
    }   
}

- (IBAction)loginButtonPressed:(id)sender
{
    self.signUpView.hidden = true;
    self.unencryptedPassword = self.password;
    
    self.requestString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.requestString = [self.requestString stringByAppendingString:self.username];
    self.requestString = [self.requestString stringByAppendingString:@"\" pw=\""];
    self.password = [self md5:self.password];
    self.password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.requestString = [self.requestString stringByAppendingString:self.password];
    self.requestString = [self.requestString stringByAppendingString:@"\"/>\n<command>login</command>\n</msg>\n||\n"];
    
    [self.requestString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.loginActivityIndicator.hidden = NO;
    [self.loginActivityIndicator startAnimating];
    self.loginButton.enabled = NO;
    
    self.xmlString = [[NSString alloc]init];
    [self connect];
}

// checks the login and gives the user information depending on what has been returned, if successful it logs in
- (void)checkLogin
{
    if([self.resultString isEqualToString:@"successful"] && !self.loggedIn)
    {
        //saves the user name and password to a keychain
        [self.keychainItem resetKeychainItem];
        [self.keychainItem setObject:self.unencryptedPassword forKey:(__bridge id)(kSecValueData)];
        [self.keychainItem setObject:self.username forKey:(__bridge id)(kSecAttrAccount)];
        
        [self.loginActivityIndicator stopAnimating];
        self.loggedIn = TRUE;
        [self performSegueWithIdentifier: @"login_successful_segue" sender: self];
    }
    else if([self.resultString isEqualToString:@"doesnt exist"])
    {
        [self.loginActivityIndicator stopAnimating];
        self.loginButton.enabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"That user name doesn't exist!" message:nil  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
        self.signUpView.hidden = false;

    }
    else if([self.resultString isEqualToString:@"bad password"])
    {
        [self.loginActivityIndicator stopAnimating];
        self.loginButton.enabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Incorrect password!" message:nil  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
        self.signUpView.hidden = false;

    }
    else if(!self.loggedIn)
    {
        [self.loginActivityIndicator stopAnimating];
        self.loginButton.enabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"An uxpected error occured. Please try logging in again" message:nil  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
        self.signUpView.hidden = false;
    }
}

#pragma mark NSXML methods

-(void)setUpParseObject
{
        NSData *data = [self.xmlString dataUsingEncoding:NSASCIIStringEncoding];
        self.xmlParserObject = [[NSXMLParser alloc] initWithData:data];
        [self.xmlParserObject setDelegate:self];
        [self.xmlParserObject setShouldProcessNamespaces:NO];
        [self.xmlParserObject setShouldReportNamespacePrefixes:NO];
        [self.xmlParserObject setShouldResolveExternalEntities:NO];
        [self.xmlParserObject parse];
        [self checkLogin];
}

// called when it found an element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    self.currentElementValue = [[NSMutableString alloc] init];
    if ([elementName isEqualToString:@"result"])
    {
        self.resultString = [[NSString alloc]init];
    }
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"result"])
    {
        self.resultString = self.currentElementValue;
    }
    
    self.currentElementValue = nil;
}

// called when it found the characters in the data of the element
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.currentElementValue)
    {
        // init the ad hoc string with the value
        self.currentElementValue = [[NSMutableString alloc] init];
    }
    
    [self.currentElementValue appendString:string];
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

// clears the username and password fields after a user has clicked ok on an error alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        self.usernameTextfield.text = @"";
        self.passwordTextfield.text = @"";
        self.username = [[NSString alloc]init];
        self.password = [[NSString alloc]init];
    }
}

@end
