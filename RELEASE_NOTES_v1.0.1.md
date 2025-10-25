# Release Notes - v1.0.1

**Release Date**: October 25, 2025  

**Build Number**: 1.0.1+2  

**Previous Version**: 1.0.0+1


## 🐛 Bug Fix Release


This release addresses critical bugs related to product type classification and display in both text and image search functionalities. All reported issues have been resolved with comprehensive fixes across multiple service layers.
  
---
  
## 🔧 Bug Fixes


### Text Search Functionality


#### Issue #1: Food Products Misclassified as Drug Products

**Severity**: High  

**Status**: ✅ Fixed


**Problem**:

- When searching for food products using text search, the results screen incorrectly displayed them as "Drug Product"

- The product card header showed "Drug Product" label instead of "Food Product"

- This issue affected all food products in the database


**Root Cause**:

- The `_convertFoodResults()` method in `text_verification_service.dart` was incorrectly setting the `genericName` field (which is drug-specific) to the food product's `product_name`

- This caused the GenericProduct model to misidentify food products as drugs


**Solution**:

- Completely rewrote the `_convertFoodResults()` method to properly map food-specific fields

- Set `genericName` to `null` for food products (as it should only be used for drugs)

- Added proper mapping for `companyName` and `typeOfProduct` fields

- Correctly mapped `company_name` to both `manufacturer` and `companyName` fields

- Added proper date parsing for `issuanceDate` and `expiryDate`


**Impact**: All food products now correctly display as "Food Product" in text search results


---


#### Issue #2: Drug-Specific Fields Populated for Non-Drug Products

**Severity**: Medium  

**Status**: ✅ Fixed


**Problem**:

- Food, cosmetic, and medical device products were incorrectly having drug-specific fields populated

- Fields like `genericName`, `dosageStrength`, `dosageForm` were showing data for non-drug products


**Root Cause**:

- The generic `_convertResults()` helper method was setting `genericName` for all product types

- Cosmetic and medical device conversion methods were incorrectly using `product_name` for `genericName`


**Solution**:

- Updated `_convertCosmeticResults()` to set `genericName` to `null`

- Updated `_convertMedicalDeviceResults()` to set `genericName` to `null`

- Added clear comments indicating these fields are drug-specific only


**Impact**: Clean data separation between product types


---


### Image Search Functionality


#### Issue #3: Food Products Display as Drug Products in Image Results

**Severity**: High  

**Status**: ✅ Fixed


**Problem**:

- When scanning food products via image search, the result screen showed them as "Drug Product"

- The Product Details card displayed incorrect product type

- Alternative matches also showed wrong product types


**Root Cause**:

- The `toGenericProduct()` method in `ProductVerificationResponse` was unconditionally setting drug-specific fields for all products

- No type checking was performed before populating drug fields like `genericName`, `dosageStrength`, etc.


**Solution**:

- Enhanced `toGenericProduct()` method with product type validation

- Added `shouldIncludeGenericName` flag that only returns `true` for drugs and drug applications

- Only set drug-specific fields when `shouldIncludeGenericName` is `true`, otherwise set to `null`

- For food products, correctly use `company_name` as manufacturer


**Impact**: Food products from image search now display correctly as "Food Product"


---


#### Issue #4: Products Display as "Unknown Product"

**Severity**: High  

**Status**: ✅ Fixed


**Problem**:

- Some products were showing "Unknown Product" label instead of their actual type

- Occurred when backend didn't provide explicit product type in response


**Root Cause**:

- The `_determineProductType()` method was defaulting to `'unknown'` when it couldn't determine the type

- This caused the `productTypeDisplay` getter to return "Unknown Product"


**Solution**:

- Enhanced `_determineProductType()` with multiple detection layers:

  1. Check `matchedProduct['product_type']` directly

  2. Analyze registration number patterns (FR- for food, DR-/CPR- for drugs)

  3. Expanded keyword matching with drug-specific terms (mg, ml, paracetamol, ibuprofen, med, pharma)

  4. Expanded food keywords (juice, coffee, tea, candy, chocolate, biscuit, cookie)

  5. Expanded cosmetic keywords (lotion, cream, shampoo)

  6. If matched product exists but no type determined, default to 'drug' (most common)

  7. Only return 'unknown' if no matched product and no keywords match

  

**Impact**: Products now correctly display their actual type instead of "Unknown Product"


---


## 🚀 Technical Improvements


### Enhanced Service Layer

- **text_verification_service.dart**: Complete rewrite of food product conversion logic with proper field mapping

- **image_verification_service.dart**: Added conditional logic to prevent drug fields on non-drug products

- **image_search_provider.dart**: Comprehensive product type detection with multi-layer fallback system


### Improved Data Model

- **generic_product.dart**: Enhanced `displayName` getter with robust fallback logic for all product types

- Better handling of 'unknown' product types throughout the application

  

### Code Quality

- Added clear inline comments explaining drug-specific field restrictions

- Improved null safety handling across all conversion methods

- More maintainable code structure with explicit product type checks


---


## 📋 Testing & Validation


### Testing Performed

- ✅ All changes passed Flutter static analysis (`flutter analyze`)

- ✅ Tested text search for food products - displays "Food Product" correctly

- ✅ Tested text search for drug products - still displays "Drug Product" correctly

- ✅ Tested image search for food products - displays "Food Product" correctly

- ✅ Tested image search with unknown product types - shows proper product names

- ✅ Tested alternative matches - each shows correct individual type

- ✅ Verified no breaking changes to existing functionality


### Regression Testing

- ✅ Drug product search (text) - Working as expected

- ✅ Drug product search (image) - Working as expected

- ✅ Saved products screen - Displays correctly

- ✅ Search history - Logs correctly

- ✅ Report functionality - Unaffected


### Backward Compatibility

- ✅ No database schema changes

- ✅ No API contract changes

- ✅ Compatible with v1.0.0 saved data

- ✅ No migration required


---


## 📁 Files Modified


### Services

- `lib/services/text_verification_service.dart` - Food product conversion rewrite

- `lib/services/image_verification_service.dart` - Conditional drug field logic
 

### Providers

- `lib/providers/image_search_provider.dart` - Enhanced type detection system


### Models

- `lib/models/generic_product.dart` - Improved display name fallback logic

  
**Total Files Changed**: 4  

**Lines Added**: ~150  

**Lines Modified**: ~80  

**Lines Removed**: ~30

  
---


## 📦 Installation & Upgrade

  
### For New Users

1. Download the APK file from the release assets

2. Enable "Install from Unknown Sources" in your Android settings

3. Install the APK

4. Launch "Totoo Ba?" and start verifying products

  

### For Existing Users (Upgrading from v1.0.0)

1. Download the v1.0.1 APK

2. Install over the existing app (data will be preserved)

3. No additional steps required - bug fixes are automatically applied

  
### Requirements

- Android 5.0 (API level 21) or higher

- Internet connection required

- ~50MB storage space

  
---

## 📞 Support

### Reporting Issues

If you encounter any problems:

1. Check the CHANGELOG.mb for known issues
2. Review logs for error messages
3. Open an issue on GitHub with:
    - Environment details (Flutter Version, Emulator)
    - Error messages or logs
  

---


## 🐛 Known Issues


None reported in this release.


---


## 👥 Contributors

  Thanks to everyone who contributed to identifying and fixing these critical issues!


---

**Full Changelog**: https://github.com/Neil-urk12/buytime/compare/v1.0.0...v1.0.1

---

*Note: This is a maintenance release focused on bug fixes. No new features were added to maintain stability and reliability.*