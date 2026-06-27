import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class BookingState {
  final Product? product;
  final bool giftWrap;
  final String personalMessage;
  final DateTime? deliveryDate;
  final String timeSlot;
  final int step;

  const BookingState({
    this.product,
    this.giftWrap = false,
    this.personalMessage = '',
    this.deliveryDate,
    this.timeSlot = '',
    this.step = 0,
  });

  BookingState copyWith({
    Product? product, bool? giftWrap, String? personalMessage,
    DateTime? deliveryDate, String? timeSlot, int? step,
  }) => BookingState(
    product: product ?? this.product,
    giftWrap: giftWrap ?? this.giftWrap,
    personalMessage: personalMessage ?? this.personalMessage,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    timeSlot: timeSlot ?? this.timeSlot,
    step: step ?? this.step,
  );
}

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() => const BookingState();

  void setProduct(Product p)            => state = state.copyWith(product: p);
  void setGiftWrap(bool v)              => state = state.copyWith(giftWrap: v);
  void setMessage(String m)             => state = state.copyWith(personalMessage: m);
  void setDeliveryDate(DateTime d)      => state = state.copyWith(deliveryDate: d);
  void setTimeSlot(String t)            => state = state.copyWith(timeSlot: t);
  void nextStep()                        => state = state.copyWith(step: state.step + 1);
  void prevStep()                        => state = state.copyWith(step: state.step - 1);
  void reset()                           => state = const BookingState();
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(
  BookingNotifier.new,
);