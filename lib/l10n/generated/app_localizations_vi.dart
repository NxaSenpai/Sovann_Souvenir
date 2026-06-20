// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Sovann Quà Lưu Niệm';

  @override
  String get settings => 'Cài đặt';

  @override
  String get notifications => 'Thông báo';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get about => 'Giới thiệu';

  @override
  String get aboutVersion => 'Sovann Quà Lưu Niệm v1.0.0';

  @override
  String get home => 'Trang chủ';

  @override
  String get saved => 'Đã lưu';

  @override
  String get map => 'Bản đồ';

  @override
  String get promos => 'Khuyến mãi';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signInPrompt => 'Đăng nhập để tiếp tục';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get joinCommunity => 'Tham gia cộng đồng Sovann';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản? ';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get emailRequired => 'Vui lòng nhập email của bạn';

  @override
  String get emailInvalid => 'Vui lòng nhập email hợp lệ';

  @override
  String get passwordRequired => 'Vui lòng nhập mật khẩu của bạn';

  @override
  String get passwordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get createPasswordRequired => 'Vui lòng tạo mật khẩu';

  @override
  String get passwordMismatch => 'Mật khẩu không khớp';

  @override
  String get nameRequired => 'Vui lòng nhập họ tên của bạn';

  @override
  String get nameTooShort => 'Tên phải có ít nhất 2 ký tự';

  @override
  String get verifyEmail => 'Xác minh Email';

  @override
  String get verifyEmailSent => 'Chúng tôi đã gửi liên kết xác minh đến';

  @override
  String get verifyEmailPrompt =>
      'Nhấp vào liên kết trong email để kích hoạt tài khoản của bạn.';

  @override
  String get verificationEmailResent => 'Đã gửi lại email xác minh!';

  @override
  String get checking => 'Đang kiểm tra...';

  @override
  String get iveVerifiedCheckNow => 'Tôi đã xác minh — Kiểm tra ngay';

  @override
  String get resendVerificationEmail => 'Gửi lại email xác minh';

  @override
  String get resending => 'Đang gửi lại...';

  @override
  String get or => 'hoặc';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get searchGifts => 'Tìm kiếm quà tặng, nghệ nhân...';

  @override
  String get categories => 'Danh mục';

  @override
  String get featured => 'Nổi bật';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get collections => 'Bộ sưu tập';

  @override
  String get meetArtisans => 'Gặp gỡ nghệ nhân';

  @override
  String get notSureWhatToGet => 'Không biết nên chọn gì?';

  @override
  String get takeQuiz => 'Làm bài trắc nghiệm tìm quà';

  @override
  String get savedGifts => 'Quà đã lưu';

  @override
  String get noSavedGifts => 'Chưa có quà nào được lưu';

  @override
  String get tapHeartToSave =>
      'Chạm vào trái tim trên bất kỳ món hàng nào để lưu tại đây';

  @override
  String get nearbyShops => 'Cửa hàng gần đây';

  @override
  String get openNow => 'Đang mở';

  @override
  String get distance => 'Khoảng cách';

  @override
  String get rating => 'Đánh giá';

  @override
  String get open => 'Mở';

  @override
  String get closed => 'Đóng';

  @override
  String get center => 'Trung tâm';

  @override
  String get directions => 'Chỉ đường';

  @override
  String get searchBranches => 'Tìm chi nhánh...';

  @override
  String get listView => 'Xem danh sách';

  @override
  String kmAway(double distance) {
    return 'Cách $distance km';
  }

  @override
  String mAway(int distance) {
    return 'Cách $distance m';
  }

  @override
  String get promotionsAndCoupons => 'Khuyến mãi & Mã giảm giá';

  @override
  String get codeCopied => 'Đã sao chép mã!';

  @override
  String get off => 'GIẢM';

  @override
  String get yourItem => 'Món hàng của bạn';

  @override
  String get giftWrapQuestion => 'Bạn có muốn gói quà không?';

  @override
  String get yesWrapIt => 'Có, gói đẹp giúp tôi 🎁';

  @override
  String get noGiftWrap => 'Không cần gói quà';

  @override
  String get personalMessage => 'Lời nhắn cá nhân';

  @override
  String get addHeartfeltNote => 'Thêm lời nhắn chân thành (tùy chọn).';

  @override
  String get writeYourMessage => 'Viết lời nhắn của bạn ở đây...';

  @override
  String get availableTimeSlots => 'Khung giờ có sẵn';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String get bookingConfirmed => 'Đặt hàng đã xác nhận';

  @override
  String get orderPlaced => 'Đơn hàng của bạn đã được đặt thành công.';

  @override
  String get orderDetails => 'Chi tiết đơn hàng';

  @override
  String get giftWrapLabel => 'Gói quà';

  @override
  String get messageLabel => 'Lời nhắn';

  @override
  String get delivery => 'Giao hàng';

  @override
  String get dateLabel => 'Ngày';

  @override
  String get timeLabel => 'Giờ';

  @override
  String get itemLabel => 'Món hàng';

  @override
  String get deliveryDate => 'Ngày giao hàng';

  @override
  String get backToHome => 'Về trang chủ';

  @override
  String get bookNow => 'Đặt ngay';

  @override
  String get bookingNotice =>
      'Bạn đang đặt hàng tùy chỉnh. Chúng tôi sẽ xác nhận tình trạng có sẵn trong vòng 24 giờ.';

  @override
  String get chooseDeliveryDate => 'Vui lòng chọn ngày giao hàng từ lịch';

  @override
  String get selectTimeSlot => 'Vui lòng chọn khung giờ giao hàng';

  @override
  String get yes => 'Có';

  @override
  String get no => 'Không';

  @override
  String get details => 'Chi tiết';

  @override
  String get materials => 'Chất liệu';

  @override
  String get dimensions => 'Kích thước';

  @override
  String get theStory => 'Câu chuyện';

  @override
  String get tags => 'Thẻ';

  @override
  String get viewGallery => 'Xem thư viện ảnh';

  @override
  String get seeAllReviews => 'Xem tất cả đánh giá';

  @override
  String ratingOutOf(double rating, int count) {
    return '$rating ($count)';
  }

  @override
  String get reviews => 'Đánh giá';

  @override
  String get writeReview => 'Viết đánh giá';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đánh giá',
    );
    return '$_temp0';
  }

  @override
  String get messages => 'Tin nhắn';

  @override
  String get online => 'Trực tuyến';

  @override
  String get now => 'Bây giờ';

  @override
  String get chat => 'Trò chuyện';

  @override
  String get typeMessage => 'Nhập tin nhắn...';

  @override
  String get productPhotos => 'Ảnh sản phẩm';

  @override
  String get makingOf => 'Quá trình làm';

  @override
  String get theirStory => 'Câu chuyện của họ';

  @override
  String get theirCrafts => 'Tác phẩm của họ';

  @override
  String get messageArtisan => 'Nhắn tin cho nghệ nhân';

  @override
  String yearsExperience(int years) {
    return '$years năm kinh nghiệm';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món hàng',
    );
    return '$_temp0';
  }

  @override
  String get step => 'Bước';

  @override
  String get ofLabel => 'của';

  @override
  String get stepItem => 'Món hàng';

  @override
  String get stepGiftWrap => 'Gói quà';

  @override
  String get stepMessage => 'Lời nhắn';

  @override
  String get stepDate => 'Ngày';

  @override
  String get stepConfirm => 'Xác nhận';

  @override
  String get quizWho => 'Món quà này dành cho ai?';

  @override
  String get quizWhoSub =>
      'Chúng tôi sẽ điều chỉnh gợi ý theo sở thích của họ.';

  @override
  String get quizBudget => 'Ngân sách của bạn là bao nhiêu?';

  @override
  String get quizBudgetSub => 'Chúng tôi có những lựa chọn đẹp ở mọi mức giá.';

  @override
  String get quizType => 'Loại quà tặng nào?';

  @override
  String get quizTypeSub => 'Chọn một danh mục truyền cảm hứng cho bạn.';

  @override
  String get quizExperience => 'Kinh nghiệm của bạn với đồ thủ công Campuchia?';

  @override
  String get quizExperienceSub =>
      'Điều này giúp chúng tôi ghép nối tác phẩm hoàn hảo cho bạn.';

  @override
  String get quizSeeking => 'Bạn đang tìm kiếm loại trải nghiệm nào?';

  @override
  String get quizSeekingSub =>
      'Mỗi tác phẩm kể một câu chuyện — câu chuyện nào nói với bạn?';

  @override
  String get quizFound => 'Chúng tôi đã tìm thấy món quà hoàn hảo cho bạn!';

  @override
  String get quizFoundSub =>
      'Dựa trên câu trả lời của bạn, đây là những gì chúng tôi gợi ý.';

  @override
  String get quizNoResults => 'Chưa có gợi ý — hãy thử kết hợp khác.';

  @override
  String get retakeQuiz => 'Làm lại trắc nghiệm';

  @override
  String get quizHer => 'Cô ấy';

  @override
  String get quizHim => 'Anh ấy';

  @override
  String get quizCouple => 'Một cặp đôi';

  @override
  String get quizMyself => 'Bản thân tôi';

  @override
  String get quizAffordable => 'Dưới \$20';

  @override
  String get quizModerate => '\$20–\$50';

  @override
  String get quizMidRange => '\$50–\$100';

  @override
  String get quizPremium => 'Trên \$100';

  @override
  String get quizWearable => 'Có thể đeo';

  @override
  String get quizDecorative => 'Trang trí';

  @override
  String get quizEdible => 'Thực phẩm';

  @override
  String get quizCollectible => 'Sưu tập';

  @override
  String get quizDiscovering => 'Mới tìm hiểu';

  @override
  String get quizSomewhat => 'Hơi quen thuộc';

  @override
  String get quizVery => 'Rất quen thuộc';

  @override
  String get quizCollector => 'Tôi là nhà sưu tập';

  @override
  String get quizTraditional => 'Truyền thống & đích thực';

  @override
  String get quizModern => 'Hiện đại & kết hợp';

  @override
  String get quizLuxurious => 'Sang trọng & cao cấp';

  @override
  String get quizEveryday => 'Hàng ngày & bình dân';

  @override
  String get onboardingCraftedTitle => 'Chế tác tại Campuchia';

  @override
  String get onboardingCraftedSub =>
      'Khám phá quà tặng thủ công bởi các nghệ nhân Campuchia, mỗi món đều có câu chuyện riêng.';

  @override
  String get onboardingGiftTitle => 'Quà tặng ý nghĩa';

  @override
  String get onboardingGiftSub =>
      'Đặt hàng với lời nhắn cá nhân, gói quà và giao hàng linh hoạt.';

  @override
  String get onboardingFindTitle => 'Tìm cửa hàng nghệ nhân';

  @override
  String get onboardingFindSub =>
      'Xác định vị trí các xưởng và chợ thủ công trên khắp Campuchia.';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get next => 'Tiếp';

  @override
  String get getStarted => 'Bắt đầu';

  @override
  String get textile => 'Dệt may';

  @override
  String get silver => 'Bạc';

  @override
  String get wood => 'Gỗ';

  @override
  String get edible => 'Thực phẩm';

  @override
  String get jewelry => 'Trang sức';

  @override
  String get chatAutoReply1 => 'Cảm ơn tin nhắn của bạn! 🙏';

  @override
  String get chatAutoReply2 =>
      'Lựa chọn tuyệt vời! Món hàng này rất được khách hàng của chúng tôi ưa chuộng.';

  @override
  String get chatAutoReply3 =>
      'Tôi làm thủ công từng món bằng tình yêu và sự chăm chút.';

  @override
  String get chatAutoReply4 =>
      'Chúng tôi chỉ sử dụng những nguyên liệu tự nhiên tốt nhất từ Campuchia.';

  @override
  String get chatAutoReply5 =>
      'Bạn có muốn kích thước hoặc màu sắc tùy chỉnh không?';

  @override
  String get chatSeed1 => 'Xin chào! Tôi quan tâm đến đồ thủ công của bạn.';

  @override
  String get chatSeed2 =>
      'Cảm ơn bạn đã liên hệ! Bạn quan tâm đến món hàng nào?';

  @override
  String get chatSeed3 =>
      'Tôi thích khăn krama. Bạn có giao hàng quốc tế không?';

  @override
  String get chatSeed4 =>
      'Có, chúng tôi giao hàng toàn thế giới! Giao hàng mất 7–14 ngày. 🙏';

  @override
  String get unexpectedError =>
      'Đã xảy ra lỗi không mong đợi. Vui lòng thử lại.';

  @override
  String get couldNotResend => 'Không thể gửi lại email xác minh.';

  @override
  String get noEmailFound => 'Không tìm thấy địa chỉ email.';

  @override
  String get heroTitle1 => 'Chế tác tại Campuchia';

  @override
  String get heroSub1 =>
      'Quà tặng thủ công bởi nghệ nhân, mỗi món một câu chuyện';

  @override
  String get heroTitle2 => 'Truyền thống lụa thuần khiết';

  @override
  String get heroSub2 => 'Dệt tay qua nhiều thế hệ';

  @override
  String get heroTitle3 => 'Bạc & Tâm hồn';

  @override
  String get heroSub3 => 'Nghề thủ công hoàng gia';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get khmer => 'Tiếng Khmer';

  @override
  String get chinese => 'Tiếng Trung';

  @override
  String get japanese => 'Tiếng Nhật';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get languageNameEn => 'Tiếng Anh';

  @override
  String get languageNameKm => 'Tiếng Khmer';

  @override
  String get languageNameZh => 'Tiếng Trung';

  @override
  String get languageNameJa => 'Tiếng Nhật';

  @override
  String get languageNameVi => 'Tiếng Việt';
}
