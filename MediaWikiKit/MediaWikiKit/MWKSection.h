//
//  MWKSection.h
//  MediaWikiKit
//
//  Created by Brion on 10/7/14.
//  Copyright (c) 2014 Wikimedia Foundation. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

#import "MWKSiteDataObject.h"

@class MWKArticle;
@class MWKImageList;

@interface MWKSection : MWKSiteDataObject

@property (readonly, strong, nonatomic) MWKTitle* title;
@property (readonly, weak, nonatomic) MWKArticle* article;

@property (readonly, copy, nonatomic) NSNumber* toclevel;      // optional
@property (readonly, copy, nonatomic) NSNumber* level;         // optional; string in JSON, but seems to be number-safe?
@property (readonly, copy, nonatomic) NSString* line;          // optional; HTML
@property (readonly, copy, nonatomic) NSString* number;        // optional; can be "1.2.3"
@property (readonly, copy, nonatomic) NSString* index;         // optional; can be "T-3" for transcluded sections
@property (readonly, strong, nonatomic) MWKTitle* fromtitle; // optional
@property (readonly, copy, nonatomic) NSString* anchor;        // optional
@property (readonly, assign, nonatomic) int sectionId;           // required; -> id
@property (readonly, assign, nonatomic) BOOL references;         // optional; marked by presence of key with empty string in JSON

/**
 * Lazily-initialized HTML content of this section.
 *
 * Might be wrapped in a `div` and/or `html`/`body` tags depending on where it came from and how you're parsing it.
 * HTML returned from the `mobileview` API module wraps sections in a `div`, and `TFHpple` wraps HTML in `<html><body>`.
 *
 * @return The HTML for this section of the receiver's `article` or `nil` if it doesn't exist on disk.
 */
@property (readonly, copy, nonatomic /*, nullable*/) NSString* text;
@property (readonly, strong, nonatomic) MWKImageList* images;

- (instancetype)initWithArticle:(MWKArticle*)article dict:(NSDictionary*)dict;

- (BOOL)     isLeadSection;
- (MWKTitle*)sourceTitle;

- (BOOL)isEqualToSection:(MWKSection*)section;

- (void)save;

///
/// @name Extraction
///

/**
 * Query the receiver's `text` with the given `xpath`.
 *
 * @param xpath The XPath to use when selecting HTML (or text) elements.
 *
 * @warning This might be expensive, but if you want to calculate/cache it off the main thread, create a separate
 *          section object to avoid properties from being get/set from different threads.
 *
 * @return The results of the XPath query, potentially `nil` if there are no results, this section hasn't been
 *         downloaded yet, or an error occurred.
 */
- (NSString*)textForXPath:(NSString*)xpath;

/**
 * Plain text extracted from the receiver's HTML (`text`) using a "standard" XPath.
 *
 * @see -[MWKSection textForXPath:]
 */
- (NSString*)extractedText;

/**
 * HTML extracted from the receiver's HTML (`text`) using a "standard" XPath.
 *
 * @see -[MWKSection textForXPath:]
 */
- (NSString*)extractedHTML;

@end
