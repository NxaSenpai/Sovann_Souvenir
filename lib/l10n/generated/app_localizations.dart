import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_km.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('km'),
    Locale('vi'),
    Locale('zh')
  ];

  /// App title shown in app bar and about section
  ///
  /// In en, this message translates to:
  /// **'Sovann Souvenir'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Sovann Souvenir v1.0.0'**
  String get aboutVersion;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @promos.
  ///
  /// In en, this message translates to:
  /// **'Promos'**
  String get promos;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInPrompt;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the Sovann community'**
  String get joinCommunity;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @createPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please create a password'**
  String get createPasswordRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmail;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to'**
  String get verifyEmailSent;

  /// No description provided for @verifyEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Click the link in the email to activate your account.'**
  String get verifyEmailPrompt;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent!'**
  String get verificationEmailResent;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @iveVerifiedCheckNow.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified — Check Now'**
  String get iveVerifiedCheckNow;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @resending.
  ///
  /// In en, this message translates to:
  /// **'Resending...'**
  String get resending;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @searchGifts.
  ///
  /// In en, this message translates to:
  /// **'Search gifts, artisans...'**
  String get searchGifts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @meetArtisans.
  ///
  /// In en, this message translates to:
  /// **'Meet the Artisans'**
  String get meetArtisans;

  /// No description provided for @notSureWhatToGet.
  ///
  /// In en, this message translates to:
  /// **'Not sure what to get?'**
  String get notSureWhatToGet;

  /// No description provided for @takeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take our Gift Finder Quiz'**
  String get takeQuiz;

  /// No description provided for @savedGifts.
  ///
  /// In en, this message translates to:
  /// **'Saved Gifts'**
  String get savedGifts;

  /// No description provided for @noSavedGifts.
  ///
  /// In en, this message translates to:
  /// **'No saved gifts yet'**
  String get noSavedGifts;

  /// No description provided for @tapHeartToSave.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any item to save it here'**
  String get tapHeartToSave;

  /// No description provided for @nearbyShops.
  ///
  /// In en, this message translates to:
  /// **'Nearby Shops'**
  String get nearbyShops;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @searchBranches.
  ///
  /// In en, this message translates to:
  /// **'Search branches...'**
  String get searchBranches;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(double distance);

  /// No description provided for @mAway.
  ///
  /// In en, this message translates to:
  /// **'{distance}m away'**
  String mAway(int distance);

  /// No description provided for @promotionsAndCoupons.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Coupons'**
  String get promotionsAndCoupons;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @yourItem.
  ///
  /// In en, this message translates to:
  /// **'Your item'**
  String get yourItem;

  /// No description provided for @giftWrapQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like gift wrapping?'**
  String get giftWrapQuestion;

  /// No description provided for @yesWrapIt.
  ///
  /// In en, this message translates to:
  /// **'Yes, wrap it beautifully 🎁'**
  String get yesWrapIt;

  /// No description provided for @noGiftWrap.
  ///
  /// In en, this message translates to:
  /// **'No gift wrap'**
  String get noGiftWrap;

  /// No description provided for @personalMessage.
  ///
  /// In en, this message translates to:
  /// **'Personal message'**
  String get personalMessage;

  /// No description provided for @addHeartfeltNote.
  ///
  /// In en, this message translates to:
  /// **'Add a heartfelt note (optional).'**
  String get addHeartfeltNote;

  /// No description provided for @writeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get writeYourMessage;

  /// No description provided for @availableTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Available time slots'**
  String get availableTimeSlots;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully.'**
  String get orderPlaced;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @giftWrapLabel.
  ///
  /// In en, this message translates to:
  /// **'Gift Wrap'**
  String get giftWrapLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemLabel;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @bookingNotice.
  ///
  /// In en, this message translates to:
  /// **'You\'re booking a custom order. We\'ll confirm availability within 24 hours.'**
  String get bookingNotice;

  /// No description provided for @chooseDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Please choose a delivery date from the calendar'**
  String get chooseDeliveryDate;

  /// No description provided for @selectTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery time slot'**
  String get selectTimeSlot;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @theStory.
  ///
  /// In en, this message translates to:
  /// **'The Story'**
  String get theStory;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @viewGallery.
  ///
  /// In en, this message translates to:
  /// **'View Gallery'**
  String get viewGallery;

  /// No description provided for @seeAllReviews.
  ///
  /// In en, this message translates to:
  /// **'See all reviews'**
  String get seeAllReviews;

  /// No description provided for @ratingOutOf.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count})'**
  String ratingOutOf(double rating, int count);

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews} =1{1 review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @productPhotos.
  ///
  /// In en, this message translates to:
  /// **'Product Photos'**
  String get productPhotos;

  /// No description provided for @makingOf.
  ///
  /// In en, this message translates to:
  /// **'Making-of'**
  String get makingOf;

  /// No description provided for @theirStory.
  ///
  /// In en, this message translates to:
  /// **'Their Story'**
  String get theirStory;

  /// No description provided for @theirCrafts.
  ///
  /// In en, this message translates to:
  /// **'Their Crafts'**
  String get theirCrafts;

  /// No description provided for @messageArtisan.
  ///
  /// In en, this message translates to:
  /// **'Message Artisan'**
  String get messageArtisan;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{years} years of experience'**
  String yearsExperience(int years);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @stepItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get stepItem;

  /// No description provided for @stepGiftWrap.
  ///
  /// In en, this message translates to:
  /// **'Gift Wrap'**
  String get stepGiftWrap;

  /// No description provided for @stepMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get stepMessage;

  /// No description provided for @stepDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get stepDate;

  /// No description provided for @stepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get stepConfirm;

  /// No description provided for @quizWho.
  ///
  /// In en, this message translates to:
  /// **'Who is this gift for?'**
  String get quizWho;

  /// No description provided for @quizWhoSub.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tailor recommendations to their taste.'**
  String get quizWhoSub;

  /// No description provided for @quizBudget.
  ///
  /// In en, this message translates to:
  /// **'What is your budget?'**
  String get quizBudget;

  /// No description provided for @quizBudgetSub.
  ///
  /// In en, this message translates to:
  /// **'We have beautiful options at every price.'**
  String get quizBudgetSub;

  /// No description provided for @quizType.
  ///
  /// In en, this message translates to:
  /// **'What type of gift?'**
  String get quizType;

  /// No description provided for @quizTypeSub.
  ///
  /// In en, this message translates to:
  /// **'Choose a category that inspires you.'**
  String get quizTypeSub;

  /// No description provided for @quizExperience.
  ///
  /// In en, this message translates to:
  /// **'Your experience with Cambodian crafts?'**
  String get quizExperience;

  /// No description provided for @quizExperienceSub.
  ///
  /// In en, this message translates to:
  /// **'This helps us match the perfect piece for you.'**
  String get quizExperienceSub;

  /// No description provided for @quizSeeking.
  ///
  /// In en, this message translates to:
  /// **'What kind of experience are you seeking?'**
  String get quizSeeking;

  /// No description provided for @quizSeekingSub.
  ///
  /// In en, this message translates to:
  /// **'Every piece tells a story — what story speaks to you?'**
  String get quizSeekingSub;

  /// No description provided for @quizFound.
  ///
  /// In en, this message translates to:
  /// **'We found your perfect gifts!'**
  String get quizFound;

  /// No description provided for @quizFoundSub.
  ///
  /// In en, this message translates to:
  /// **'Based on your answers, here\'s what we recommend.'**
  String get quizFoundSub;

  /// No description provided for @quizNoResults.
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet — try a different combination.'**
  String get quizNoResults;

  /// No description provided for @retakeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get retakeQuiz;

  /// No description provided for @quizHer.
  ///
  /// In en, this message translates to:
  /// **'Her'**
  String get quizHer;

  /// No description provided for @quizHim.
  ///
  /// In en, this message translates to:
  /// **'Him'**
  String get quizHim;

  /// No description provided for @quizCouple.
  ///
  /// In en, this message translates to:
  /// **'A couple'**
  String get quizCouple;

  /// No description provided for @quizMyself.
  ///
  /// In en, this message translates to:
  /// **'Myself'**
  String get quizMyself;

  /// No description provided for @quizAffordable.
  ///
  /// In en, this message translates to:
  /// **'Under \$20'**
  String get quizAffordable;

  /// No description provided for @quizModerate.
  ///
  /// In en, this message translates to:
  /// **'\$20–\$50'**
  String get quizModerate;

  /// No description provided for @quizMidRange.
  ///
  /// In en, this message translates to:
  /// **'\$50–\$100'**
  String get quizMidRange;

  /// No description provided for @quizPremium.
  ///
  /// In en, this message translates to:
  /// **'Over \$100'**
  String get quizPremium;

  /// No description provided for @quizWearable.
  ///
  /// In en, this message translates to:
  /// **'Wearable'**
  String get quizWearable;

  /// No description provided for @quizDecorative.
  ///
  /// In en, this message translates to:
  /// **'Decorative'**
  String get quizDecorative;

  /// No description provided for @quizEdible.
  ///
  /// In en, this message translates to:
  /// **'Edible'**
  String get quizEdible;

  /// No description provided for @quizCollectible.
  ///
  /// In en, this message translates to:
  /// **'Collectible'**
  String get quizCollectible;

  /// No description provided for @quizDiscovering.
  ///
  /// In en, this message translates to:
  /// **'Just discovering'**
  String get quizDiscovering;

  /// No description provided for @quizSomewhat.
  ///
  /// In en, this message translates to:
  /// **'Somewhat familiar'**
  String get quizSomewhat;

  /// No description provided for @quizVery.
  ///
  /// In en, this message translates to:
  /// **'Very familiar'**
  String get quizVery;

  /// No description provided for @quizCollector.
  ///
  /// In en, this message translates to:
  /// **'I\'m a collector'**
  String get quizCollector;

  /// No description provided for @quizTraditional.
  ///
  /// In en, this message translates to:
  /// **'Authentic & traditional'**
  String get quizTraditional;

  /// No description provided for @quizModern.
  ///
  /// In en, this message translates to:
  /// **'Modern & fusion'**
  String get quizModern;

  /// No description provided for @quizLuxurious.
  ///
  /// In en, this message translates to:
  /// **'Luxurious & premium'**
  String get quizLuxurious;

  /// No description provided for @quizEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday & casual'**
  String get quizEveryday;

  /// No description provided for @onboardingCraftedTitle.
  ///
  /// In en, this message translates to:
  /// **'Crafted in Cambodia'**
  String get onboardingCraftedTitle;

  /// No description provided for @onboardingCraftedSub.
  ///
  /// In en, this message translates to:
  /// **'Discover handmade gifts by Cambodian artisans, each with a unique story.'**
  String get onboardingCraftedSub;

  /// No description provided for @onboardingGiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift with Meaning'**
  String get onboardingGiftTitle;

  /// No description provided for @onboardingGiftSub.
  ///
  /// In en, this message translates to:
  /// **'Order with personalized messages, gift wrapping, and flexible delivery.'**
  String get onboardingGiftSub;

  /// No description provided for @onboardingFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Artisan Shops'**
  String get onboardingFindTitle;

  /// No description provided for @onboardingFindSub.
  ///
  /// In en, this message translates to:
  /// **'Locate physical ateliers and markets across Cambodia.'**
  String get onboardingFindSub;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @textile.
  ///
  /// In en, this message translates to:
  /// **'Textile'**
  String get textile;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @wood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get wood;

  /// No description provided for @edible.
  ///
  /// In en, this message translates to:
  /// **'Edible'**
  String get edible;

  /// No description provided for @jewelry.
  ///
  /// In en, this message translates to:
  /// **'Jewelry'**
  String get jewelry;

  /// No description provided for @chatAutoReply1.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your message! 🙏'**
  String get chatAutoReply1;

  /// No description provided for @chatAutoReply2.
  ///
  /// In en, this message translates to:
  /// **'Great choice! This item is very popular with our customers.'**
  String get chatAutoReply2;

  /// No description provided for @chatAutoReply3.
  ///
  /// In en, this message translates to:
  /// **'I handcraft every piece with love and care.'**
  String get chatAutoReply3;

  /// No description provided for @chatAutoReply4.
  ///
  /// In en, this message translates to:
  /// **'We use only the finest natural materials from Cambodia.'**
  String get chatAutoReply4;

  /// No description provided for @chatAutoReply5.
  ///
  /// In en, this message translates to:
  /// **'Would you like a custom size or color?'**
  String get chatAutoReply5;

  /// No description provided for @chatSeed1.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m interested in your crafts.'**
  String get chatSeed1;

  /// No description provided for @chatSeed2.
  ///
  /// In en, this message translates to:
  /// **'Thank you for reaching out! Which items interest you?'**
  String get chatSeed2;

  /// No description provided for @chatSeed3.
  ///
  /// In en, this message translates to:
  /// **'I love the krama scarves. Do you ship internationally?'**
  String get chatSeed3;

  /// No description provided for @chatSeed4.
  ///
  /// In en, this message translates to:
  /// **'Yes, we ship worldwide! Delivery takes 7–14 days. 🙏'**
  String get chatSeed4;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @couldNotResend.
  ///
  /// In en, this message translates to:
  /// **'Could not resend verification email.'**
  String get couldNotResend;

  /// No description provided for @noEmailFound.
  ///
  /// In en, this message translates to:
  /// **'No email address found.'**
  String get noEmailFound;

  /// No description provided for @heroTitle1.
  ///
  /// In en, this message translates to:
  /// **'Crafted in Cambodia'**
  String get heroTitle1;

  /// No description provided for @heroSub1.
  ///
  /// In en, this message translates to:
  /// **'Artisan-made gifts with a story'**
  String get heroSub1;

  /// No description provided for @heroTitle2.
  ///
  /// In en, this message translates to:
  /// **'Pure Silk Tradition'**
  String get heroTitle2;

  /// No description provided for @heroSub2.
  ///
  /// In en, this message translates to:
  /// **'Woven by hand for generations'**
  String get heroSub2;

  /// No description provided for @heroTitle3.
  ///
  /// In en, this message translates to:
  /// **'Silver & Soul'**
  String get heroTitle3;

  /// No description provided for @heroSub3.
  ///
  /// In en, this message translates to:
  /// **'Royal court craftsmanship'**
  String get heroSub3;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @khmer.
  ///
  /// In en, this message translates to:
  /// **'ភាសាខ្មែរ'**
  String get khmer;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @languageNameEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// No description provided for @languageNameKm.
  ///
  /// In en, this message translates to:
  /// **'ភាសាខ្មែរ'**
  String get languageNameKm;

  /// No description provided for @languageNameZh.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageNameZh;

  /// No description provided for @languageNameJa.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageNameJa;

  /// No description provided for @languageNameVi.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageNameVi;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'km', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'km':
      return AppLocalizationsKm();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
