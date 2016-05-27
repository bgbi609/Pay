//
//  ViewController.m
//  Pay
//
//  Created by Zoltan Takacs on 2016. 05. 16..
//  Copyright © 2016. Zoltan Takacs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Pay:(id)sender {
}

- (IBAction)transaction:(id)sender {
    MPTransactionProvider* transactionProvider =
    [MPMpos transactionProviderForMode:MPProviderModeMOCK
                    merchantIdentifier:@"MERCHANT_IDENTIFIER"
                     merchantSecretKey:@"MERCHANT_SECRET_KEY"];
    
    MPTransactionParameters *transactionParameters =
    [MPTransactionParameters chargeWithAmount:[NSDecimalNumber decimalNumberWithString:@"5.00"]
                                     currency:MPCurrencyEUR
                                    optionals:^(id<MPTransactionParametersOptionals>  _Nonnull optionals) {
                                        optionals.subject = @"Food";
                                        optionals.customIdentifier = @"yourReferenceForTheTransaction";
                                    }];
    
    MPAccessoryParameters *accessoryParameters =
    [MPAccessoryParameters externalAccessoryParametersWithFamily:MPAccessoryFamilyMock
                                                        protocol:@"com.miura.shuttle"
                                                       optionals:nil];
    
    MPTransactionProcess *process =
    [transactionProvider startTransactionWithParameters:transactionParameters
                                    accessoryParameters:accessoryParameters
                                             registered:^(MPTransactionProcess *process,
                                                          MPTransaction *transaction)
     {
         NSLog(@"registered MPTransactionProcess, transaction id: %@", transaction.identifier);
     }
                                          statusChanged:^(MPTransactionProcess *process,
                                                          MPTransaction *transaction,
                                                          MPTransactionProcessDetails *details)
     {
         NSLog(@"%@\n%@", details.information[0], details.information[1]);
     }
                                         actionRequired:^(MPTransactionProcess *process,
                                                          MPTransaction *transaction,
                                                          MPTransactionAction action,
                                                          MPTransactionActionSupport *support)
     {
         switch (action) {
             case MPTransactionActionCustomerSignature: {
                 NSLog(@"show a UI that let's the customer provide his/her signature!");
                 // In a live app, this image comes from your signature screen
                 UIGraphicsBeginImageContext(CGSizeMake(1, 1));
                 UIImage *capturedSignature = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 [process continueWithCustomerSignature:capturedSignature verified:YES];
                 break;
             }
             case MPTransactionActionCustomerIdentification: {
                 // always return NO here
                 [process continueWithCustomerIdentityVerified:NO];
                 break;
             }
             case MPTransactionActionApplicationSelection: {
                 // This happens only for readers that don't support application selection on their screen
                 break;
             }
             default: {
                 break;
             }
         }
     }
                                              completed:^(MPTransactionProcess *process,
                                                          MPTransaction *transaction,
                                                          MPTransactionProcessDetails *details)
     {
         NSLog(@"Transaction ended, transaction status is %lu", (unsigned long) transaction.status);
         
         if (details.state == MPTransactionProcessDetailsStateApproved) {
             // Ask the merchant, whether the shopper wants to have a receipt
             // and close the checkout UI
         } else {
             // Allow your merchant to try another transaction
         }
         
         // only close your modal here
     }];
}
  // review this part here:



    @end

