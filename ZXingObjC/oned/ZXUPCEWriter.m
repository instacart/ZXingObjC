//
//  ZXUPCEWriter.m
//  ZXingObjC
//
//  Created by Sean Cashin on 1/3/17.
//  Copyright © 2017 zxing. All rights reserved.
//

#import "ZXUPCEWriter.h"
#import "ZXUPCEANReader.h"
#import "ZXUPCEReader.h"
#import "ZXBoolArray.h"

const int ZX_UPCE_CODE_WIDTH = 3 + (7 * 6) + 6;

@implementation ZXUPCEWriter

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints error:(NSError **)error {
  if (format != kBarcodeFormatUPCE) {
      [NSException raise:NSInvalidArgumentException format:@"Can only encode UPC_E"];
  }
  return [super encode:contents format:format width:width height:height hints:hints error:error];
}

- (ZXBoolArray *)encode:(NSString *)contents {
  if ([contents length] != 8) {
    @throw [NSException exceptionWithName:@"IllegalArgumentException"
                                   reason:[NSString stringWithFormat:@"Requested contents should be 8 digits long, but got %d", (int)[contents length]]
                                 userInfo:nil];
  }

  int checkDigit = [[contents substringWithRange:NSMakeRange(7, 1)] intValue];
  int parities = CHECK_DIGIT_ENCODINGS[checkDigit];
  ZXBoolArray *result = [[ZXBoolArray alloc] initWithLength:ZX_UPCE_CODE_WIDTH];
  int pos = 0;

  pos += [self appendPattern:result pos:pos pattern:ZX_UPC_EAN_START_END_PATTERN patternLen:ZX_UPC_EAN_START_END_PATTERN_LEN startColor:YES];

  for (int i = 1; i <= 6; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    if ((parities >> (6 - i) & 1) == 1) {
      digit += 10;
    }
    pos += [self appendPattern:result pos:pos pattern:ZX_UPC_EAN_L_AND_G_PATTERNS[digit] patternLen:ZX_UPC_EAN_L_PATTERNS_SUB_LEN startColor:NO];
  }

  [self appendPattern:result pos:pos pattern:ZX_UPCE_MIDDLE_END_PATTERN patternLen:ZX_UPCE_MIDDLE_END_PATTERN_LEN startColor:NO];

  return result;
}

@end
